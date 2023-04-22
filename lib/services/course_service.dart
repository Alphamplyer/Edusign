
import 'package:edusign_v3/models/course_model.dart';
import 'package:edusign_v3/models/user_model.dart';
import 'package:edusign_v3/services/edusign_service.dart';

class CourseService {
  static Future<List<Course>> getUserCourses(User user) async {
    return EdusignService.getCourses(user);
  }

  static Future<List<Course>> getUsersCoursesInCommon(List<User> users) async {
    Map<User, List<Course>> usersCourses = {};

    for (var user in users) {
      usersCourses[user] = await getUserCourses(user);
    }

    return usersCourses.values.reduce((values, elements) {
      return values.where((course) => elements.any((element) => element.id == course.id)).toList();
    });
  }
}