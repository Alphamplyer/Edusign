
import 'package:edusign_v3/models/merged_course.model.dart';
import 'package:edusign_v3/models/user_model.dart';

class LoadingResult {
  final bool allUsersLoadedSuccessfully;
  final List<User> validatedUsers;
  final List<String> failedUsers;
  final MergedCourse? mergedCourse;

  LoadingResult({
    required this.allUsersLoadedSuccessfully,
    required this.validatedUsers,
    required this.failedUsers,
    required this.mergedCourse,
  });
}