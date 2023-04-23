
import 'package:edusign_v3/config/storage_keys.dart';
import 'package:edusign_v3/models/user_credential.dart';
import 'package:edusign_v3/services/app_flow_states_service.dart';
import 'package:edusign_v3/services/storage_service.dart';

class UserCredentialsService {

  /// Loads the main user username.
  static Future<String?> loadMainUserUsername() async {
    return await StorageService.read(key: StorageKeys.MAIN_USER_USERNAME);
  }

  /// Loads the main user credentials.
  static Future<UserCredential?> loadMainUserCredentials() async {
    String? storedMainUserUsername = await loadMainUserUsername();
    if (storedMainUserUsername == null)
      return null;
    UserCredential? userCredential = await loadUserCredentials(storedMainUserUsername);
    return userCredential;
  }

  /// Saves the main user username.
  static Future<void> saveMainUserUsername(String username) async {
    await StorageService.write(key: StorageKeys.MAIN_USER_USERNAME, value: username);
  }

  /// Deletes the main user username.
  static Future<void> deleteMainUserUsername() {
    return StorageService.delete(key: StorageKeys.MAIN_USER_USERNAME);
  }

  static Future<UserCredential?> loadUserCredentials(String identifier) async {
    String? password = await StorageService.read(key: identifier);
    
    if (password != null) {
      return UserCredential(username: identifier, password: password);
    }

    return null;
  }

  /// Saves an user's credentials.
  /// 
  /// [user] is the user's credentials to save.
  static Future<void> saveUserCrendential(UserCredential user) async {
    List<String> persistedUsernames = await loadAllPersitedUserCredentialsUsersnames();
    persistedUsernames.sort((a, b) => a.compareTo(b));
    
    if (!persistedUsernames.contains(user.username)) {
      persistedUsernames.add(user.username);
    }

    await saveAllPersitedUserCredentialsUsersnames(persistedUsernames);
    await StorageService.write(key: user.username, value: user.password);
  }

  /// Loads all the saved users credentials.
  static Future<List<UserCredential>> loadAllUsersCredentials() async {
    List<String> savedUsernames = await loadAllPersitedUserCredentialsUsersnames();
    List<UserCredential> users = [];

    for (String username in savedUsernames) {
      String? password = await StorageService.read(key: username);

      if (password != null) {
        users.add(UserCredential(username: username, password: password));
      }
    }

    return users;
  }

  /// Loads all the saved user credentials usernames.
  static Future<List<String>> loadAllPersitedUserCredentialsUsersnames() async {
    String? storedValue = await StorageService.read(key: StorageKeys.SAVED_USER_NAMES);
    return storedValue?.split(',') ?? [];
  }

  /// Saves all the saved user credentials usernames.
  /// 
  /// [usernames] is the list of usernames to save.
  static Future<void> saveAllPersitedUserCredentialsUsersnames(List<String> usernames) async {
    await StorageService.write(key: StorageKeys.SAVED_USER_NAMES, value: usernames.join(','));
  }

  static Future<void> deleteAllPersitedUserCredentialsUsersnames() async {
    await StorageService.delete(key: StorageKeys.SAVED_USER_NAMES);
  }

  /// Deletes an user's credentials.
  /// 
  /// [username] is the username of the user's credentials to delete.
  static Future<void> deleteUserCredentials(String username) async {
    List<String> savedUsernames = await loadAllPersitedUserCredentialsUsersnames();

    if (savedUsernames.isEmpty || !savedUsernames.contains(username)) {
      return;
    }

    savedUsernames.remove(username);
    await saveAllPersitedUserCredentialsUsersnames(savedUsernames);
    await StorageService.delete(key: username);

    if (savedUsernames.isEmpty) {
      deleteMainUserUsername();
      return;
    } else {
      String? mainUserUsername = await loadMainUserUsername();
      if (mainUserUsername == username) {
        await saveMainUserUsername(savedUsernames.first);
      }
    }

    AppFlowStatesService.removeUsernameFromPreviouslySelectedOnes(username);
  }

  /// Deletes all the saved users credentials. 
  /// Also deletes the main user username and the previously selected usernames.
  static Future<void> deleteUsersCredentials() async {
    List<String> savedUsernames = await loadAllPersitedUserCredentialsUsersnames();

    if (savedUsernames.isEmpty) {
      return;
    }

    await deleteAllPersitedUserCredentialsUsersnames();
    await deleteMainUserUsername();
    await AppFlowStatesService.deleteAllPreviouslySelectedUsernames();
    
    for (String username in savedUsernames) {
      await StorageService.delete(key: username);
    }
  }
}