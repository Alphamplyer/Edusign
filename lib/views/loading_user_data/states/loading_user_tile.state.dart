
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:edusign_v3/models/course_model.dart';
import 'package:edusign_v3/models/user_credential.dart';
import 'package:edusign_v3/models/user_model.dart';
import 'package:edusign_v3/services/course_service.dart';
import 'package:edusign_v3/services/user_credentials_service.dart';
import 'package:edusign_v3/services/user_service.dart';
import 'package:edusign_v3/views/loading_user_data/models/loading_user_state.enum.dart';
import 'package:flutter/material.dart';

class LoadingUserTileState {
  final String courseId;
  final String username;

  ValueNotifier<LoadingUserState> _stateValueNotifier = ValueNotifier(LoadingUserState.loggingUser);
  ValueNotifier<LoadingUserState> get stateValueNotifier => _stateValueNotifier;

  Course? _course;
  Course? get course => _course;

  String _failingReason = "";
  String get failingReason => _failingReason;

  LoadingUserTileState({
    required this.courseId,
    required this.username,
  });

  Future<void> startLoading() async {
    await _loadUserCredentials();
  }

  Future<void> retry() async {
    _stateValueNotifier.value = LoadingUserState.loggingUser;
    await startLoading();
  }

  Future<void> _loadUserCredentials() async {
    UserCredential? userCredential = await UserCredentialsService.loadUserCredentials(username);
    if (userCredential == null) {
      _stateValueNotifier.value = LoadingUserState.failed;
      return;
    }
    _loginUser(userCredential);
  }

  Future<void> _loginUser(UserCredential userCredential) async {
    try {
      User user = await UserService.login(userCredential);
      _loadUserCourse(user);
    } on SocketException {
      _failingReason = "Failed to login user: Unable to contact the server or something went " +
        "wrong. Please try again later. If the problem persists, please contact the support.";
      _stateValueNotifier.value = LoadingUserState.failed;
    } catch (e) {
      _failingReason = "Failed to login user: Wrong credentials. Did you change your password?";
      _stateValueNotifier.value = LoadingUserState.failed;
    }
  }

  Future<void> _loadUserCourse(User user) async {
    try {
      _stateValueNotifier.value = LoadingUserState.loadingUserCourses;
      List<Course> userCourses = await CourseService.getUserCourses(user);
      await _tryGetTheEnrolledCourse(userCourses);
    } catch (e) {
      _failingReason = "Failed to load user courses: Unable to contact the server or something went " +
        "wrong. Please try again later. If the problem persists, please contact the support.";
      _stateValueNotifier.value = LoadingUserState.failed;
      return;
    }
  }

  Future<void> _tryGetTheEnrolledCourse(List<Course> userCourses) async {
    _stateValueNotifier.value = LoadingUserState.checkingIfUserIsEnrolled;
    Course? enrolledCourse = userCourses.firstWhereOrNull((course) => course.id == courseId);
    
    if (enrolledCourse == null) {
      _failingReason = "User is not enrolled in this course.";
      _stateValueNotifier.value = LoadingUserState.failed;
      return;
    }

    _course = enrolledCourse;
    _stateValueNotifier.value = LoadingUserState.succeed;
  }
}