
import 'package:edusign_v3/services/storage_service.dart';

import '../config/storage_keys.dart';

class AppFlowStatesService {

  /// Returns true if the app has already been launched once, false otherwise.
  static Future<bool> hasAlreadyLaunchedOnce() async {
    return await StorageService.containsKey(key: StorageKeys.FIRST_APP_LAUNCH);
  }

  /// Saves the fact that the app has already been launched once.
  static Future<void> setHasAlreadyLaunchedOnce() async {
    await StorageService.write(key: StorageKeys.FIRST_APP_LAUNCH, value: 'true');
  }

  /// Returns the list of usernames that have been selected by the user in the past.
  static Future<List<String>> loadPreviousSelectedUsernames() async {
    String? storedValue = await StorageService.read(key: StorageKeys.PREVIOUSLY_SELECTED_USERNAMES);
    return storedValue?.split(',') ?? [];
  }

  /// Saves the list of [usernames] that have been selected by the user in the past.
  static Future<void> savePreviouslySelectedUsernames(List<String> usernames) async {
    await StorageService.write(key: StorageKeys.PREVIOUSLY_SELECTED_USERNAMES, value: usernames.join(','));
  }

  static Future<void> deleteAllPreviouslySelectedUsernames() async {
    await StorageService.delete(key: StorageKeys.PREVIOUSLY_SELECTED_USERNAMES);
  }

  /// Removes the given [username] from the list of usernames that have been selected by the user in the past.
  static Future<void> removeUsernameFromPreviouslySelectedOnes(String username) async {
    List<String> previouslySelectedUsernames = await loadPreviousSelectedUsernames();
    previouslySelectedUsernames.remove(username);
    await savePreviouslySelectedUsernames(previouslySelectedUsernames);
  }

  static Future<void> saveDisplayOnlyNextCoursesState(bool isActive) async {
    await StorageService.write(key: StorageKeys.DISPLAY_ONLY_NEXT_COURSES, value: isActive ? 'true' : "false");
  }

  static Future<bool> shouldDisplayOnlyNextCourses() async {
    String? storedValue = await StorageService.read(key: StorageKeys.DISPLAY_ONLY_NEXT_COURSES);
    return storedValue == null ? true : storedValue == 'true';
  }
}