
import 'package:edusign_v3/models/course_model.dart';
import 'package:edusign_v3/models/merged_course.model.dart';
import 'package:edusign_v3/models/user_model.dart';
import 'package:edusign_v3/views/loading_user_data/models/loading_result.model.dart';
import 'package:edusign_v3/views/loading_user_data/states/loading_user_tile.state.dart';
import 'package:flutter/material.dart';

class LogingInUsersViewModel with ChangeNotifier {
  final String courseId;
  final List<String> selectedUsers;

  List<LoadingUserTileState> _loadingUserTileStates = [];
  List<LoadingUserTileState> get loadingUserTileStates => _loadingUserTileStates;

  ValueNotifier<bool> _isProcessingNotifier = ValueNotifier(false);
  ValueNotifier<bool> get isProcessingNotifier => _isProcessingNotifier;

  LogingInUsersViewModel({
    required this.courseId,
    required this.selectedUsers, 
  });

  Future<void> loadState() async {
    _isProcessingNotifier.value = true;
    _createLoadingUserTileStates();
    notifyListeners();
    await _loadingSelectedUsers();
    _isProcessingNotifier.value = false;
  }

  void _createLoadingUserTileStates() {
    _loadingUserTileStates = List.from(
      selectedUsers.map(
        (username) => LoadingUserTileState(
          courseId: courseId,
          username: username,
        )
      )
    );
  }

  Future<void> _loadingSelectedUsers() async {
    List<Future<void>> loadingUserTileStatesFutures = _loadingUserTileStates.map<Future<void>>(
      (loadingUserTileState) => loadingUserTileState.startLoading()
    ).toList();

    await Future.wait(loadingUserTileStatesFutures);
  }

  LoadingResult getLoadingResult() {
    if (_isProcessingNotifier.value) {
      throw Exception("The loading is still in progress.");
    }

    List<User> validatedUsers = [];
    List<String> failedUsers = [];
    Map<String, UserCourseDetails> userCourseDetails = {};
    Course? course;

    for (final loadingUserTileState in _loadingUserTileStates) {
      if (loadingUserTileState.course == null) {
        failedUsers.add(loadingUserTileState.username);
        continue;
      };

      if (course == null) {
        course = loadingUserTileState.course;
      }

      validatedUsers.add(loadingUserTileState.user!);

      userCourseDetails[loadingUserTileState.username] = UserCourseDetails(
        presence: loadingUserTileState.course!.presence,
        absence: loadingUserTileState.course!.absence,
      );
    }

    if (course == null) {
      return LoadingResult(
        allUsersLoadedSuccessfully: false,
        validatedUsers: [],
        failedUsers: failedUsers,
        mergedCourse: null,
      );
    }

    return LoadingResult(
      allUsersLoadedSuccessfully: failedUsers.isEmpty,
      validatedUsers: validatedUsers,
      failedUsers: failedUsers,
      mergedCourse: MergedCourse.fromCourse(
        course, 
        userCourseDetails: userCourseDetails,
      ),
    );
  }
}