
import 'package:edusign_v3/models/user_credential.dart';

import '../models/user_model.dart';
import 'edusign_service.dart';

class UserService {
  static User? mainLoggedUser;
  static Map<String, User> _cachedLoggedUsers = {};

  static Future<User> login(UserCredential userCredential) async {
    User user = await EdusignService.login(userCredential.username, userCredential.password);
    _cachedLoggedUsers[user.username] = user;
    return user;
  }

  static Future<User?> getLoggedUser(String username) async {
    if (_cachedLoggedUsers.containsKey(username)) {
      return _cachedLoggedUsers[username]!;
    }
    
    return null;
  }

  static Future<List<User>> getLoggedUsers() async {
    return _cachedLoggedUsers.values.toList();
  }

  static Future<List<String>> getLoggedUsersUsernames() async {
    return _cachedLoggedUsers.keys.toList();
  }

  static Future<void> logout(String username) async {
    _cachedLoggedUsers.remove(username);
  }
}