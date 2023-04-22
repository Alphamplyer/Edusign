
import 'package:edusign_v3/config/storage_keys.dart';
import 'package:edusign_v3/models/user_credential.dart';
import 'package:edusign_v3/services/storage_service.dart';

class UserCredentialsService {
  static Future<void> addUserCrendential(UserCredential user) async {
    String? savedUserNames = await StorageService.read(key: StorageKeys.SAVED_USER_NAMES);
    List<String> savedUserNamesList = savedUserNames?.split(',') ?? [];
    
    if (!savedUserNamesList.contains(user.username)) {
      savedUserNamesList.add(user.username);
    }

    await StorageService.write(key: StorageKeys.SAVED_USER_NAMES, value: savedUserNamesList.join(','));
    await StorageService.write(key: user.username, value: user.password);
  }

  static Future<UserCredential?> getSavedUserCredentials(String identifier) async {
    String? password = await StorageService.read(key: identifier);
    
    if (password != null) {
      return UserCredential(username: identifier, password: password);
    }

    return null;
  }

  static Future<List<UserCredential>> getSavedUsersCredentials() async {
    String? savedUserNames = await StorageService.read(key: StorageKeys.SAVED_USER_NAMES);
    List<String> savedUserNamesList = savedUserNames?.split(',') ?? [];
    List<UserCredential> users = [];

    for (String username in savedUserNamesList) {
      String? password = await StorageService.read(key: username);

      if (password != null) {
        users.add(UserCredential(username: username, password: password));
      }
    }

    return users;
  }

  static Future<void> clearSavedUsersCredentials() async {
    String? savedUserNames = await StorageService.read(key: StorageKeys.SAVED_USER_NAMES);
    List<String> savedUserNamesList = savedUserNames?.split(',') ?? [];

    await StorageService.delete(key: StorageKeys.SAVED_USER_NAMES);
    await StorageService.delete(key: StorageKeys.PREVIOUSLY_SELECTED_USERNAMES);
    
    for (String username in savedUserNamesList) {
      await StorageService.delete(key: username);
    }
  }
}