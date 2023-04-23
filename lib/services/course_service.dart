
import 'package:edusign_v3/models/course_model.dart';
import 'package:edusign_v3/models/merged_course.model.dart';
import 'package:edusign_v3/models/user_model.dart';
import 'package:edusign_v3/services/edusign_service.dart';

class CourseService {
  static Map<String, List<Course>> _cachedUsersCourses = {};

  static Future<List<Course>> getUserCourses(User user) async {
    if (_cachedUsersCourses.containsKey(user.username))
      return _cachedUsersCourses[user.username]!;

    List<Course> courses = await EdusignService.getCourses(user);
    _cachedUsersCourses[user.username] = courses;
    return courses;
  }

  static invalidateCachedUserCourses(User user) {
    _cachedUsersCourses.remove(user.username);
  }

  static invalidateAllCachedUsersCourses() {
    _cachedUsersCourses.clear();
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

  static Future<List<MergedCourse>> getMergedCourses(List<User> users) async {
    Map<User, List<Course>> usersCourses = {};

    for (var user in users) {
      usersCourses[user] = await getUserCourses(user);
    }

    List<MergedCourse> mergedCourses = [];
    
    for (var user in usersCourses.keys) {
      for (var course in usersCourses[user]!) {
        int mergedCourseIndex = mergedCourses.indexWhere((mergedCourse) => mergedCourse.id == course.id);

        if (_isMergedCourseHasBeenFound(mergedCourseIndex)) {
          MergedCourse mergedCourse = mergedCourses[mergedCourseIndex];
          mergedCourse.userCourseDetails[user.username] = UserCourseDetails(
            presence: course.presence,
            absence: course.absence,
          );
          mergedCourses[mergedCourseIndex] = mergedCourse;
        } else {
          MergedCourse mergedCourse = MergedCourse(
            id: course.id,
            name: course.name,
            professor: course.professor,
            start: course.start,
            end: course.end,
            userCourseDetails: {
              user.username: UserCourseDetails(
                presence: course.presence,
                absence: course.absence,
              )
            }
          );
          mergedCourses.add(mergedCourse);
        }
      }
    }

    return mergedCourses;
  }

  static bool _isMergedCourseHasBeenFound(int mergedCourseIndex) => mergedCourseIndex != -1;
}