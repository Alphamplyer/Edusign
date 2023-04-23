
import 'package:edusign_v3/models/course_model.dart';
import 'package:edusign_v3/models/user_model.dart';
import 'package:edusign_v3/services/app_flow_states_service.dart';
import 'package:edusign_v3/services/course_service.dart';
import 'package:edusign_v3/services/user_credentials_service.dart';
import 'package:edusign_v3/services/user_service.dart';
import 'package:flutter/material.dart';


class BrowseCoursesViewModel with ChangeNotifier {
  List<Course> _courses = [];
  List<Course> get courses => _courses;

  List<Course> get nextCourses => _courses.sublist(0, 2);

  bool _displayOnlyNextCourses = true;
  bool get displayOnlyNextCourses => _displayOnlyNextCourses;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  Future<void> loadState() async {
    _isLoading = true;
    notifyListeners();
    await _loadDisplayOnlyNextCourses();
    await _getCourses();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshState() async {
    _isLoading = true;
    notifyListeners();
    await _getCourses();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleDisplayOnlyNextCourses() async {
    _displayOnlyNextCourses = !_displayOnlyNextCourses;
    await AppFlowStatesService.saveDisplayOnlyNextCoursesState(_displayOnlyNextCourses);
    notifyListeners();
  }

  Future<void> _loadDisplayOnlyNextCourses() async {
    _displayOnlyNextCourses = await AppFlowStatesService.shouldDisplayOnlyNextCourses();
  }

  Future<void> _getCourses() async {
    String? mainUserUsername = await UserCredentialsService.loadMainUserUsername();
    if (mainUserUsername == null)
      return;
    User? user = await UserService.getLoggedUser(mainUserUsername);
    if (user == null)
      return;
    _courses = await CourseService.getUserCourses(user);
  }
}