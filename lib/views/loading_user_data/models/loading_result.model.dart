
import 'package:edusign_v3/models/merged_course.model.dart';

class LoadingResult {
  final bool allUsersLoadedSuccessfully;
  final List<String> failedUsers;
  final MergedCourse? mergedCourse;

  LoadingResult({
    required this.allUsersLoadedSuccessfully,
    required this.failedUsers,
    required this.mergedCourse,
  });
}