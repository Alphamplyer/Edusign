
import 'package:edusign_v3/models/user_credential.dart';
import 'package:edusign_v3/services/user_credentials_service.dart';
import 'package:edusign_v3/services/user_service.dart';
import 'package:edusign_v3/views/loging_in_users/models/logged_user_state.model.dart';
import 'package:flutter/material.dart';

class LogingInUsersViewModel with ChangeNotifier {
  late List<String> _selectedUsers;

  Map<String, UserLoginState> _loggedUsers = {};
  List<UserLoginState> get loggedUsers => _loggedUsers.values.toList();

  ValueNotifier<bool> _isProcessingNotifier = ValueNotifier(false);
  ValueNotifier<bool> get isProcessingNotifier => _isProcessingNotifier;

  LogingInUsersViewModel({
    required List<String> selectedUsers, 
  }) {
    _selectedUsers = selectedUsers;
  }

  Future<void> loadState() async {
    _isProcessingNotifier.value = true;
    _createLoggedUsers();
    notifyListeners();
    await _loggingInSelectedUsers();
    _isProcessingNotifier.value = false;
  }

  void _createLoggedUsers() {
    _loggedUsers = {};
    for (final username in _selectedUsers) {
      _loggedUsers[username] = UserLoginState.waiting(username: username);
    }
  }

  Future<void> _loggingInSelectedUsers() async {
    List<String> loggedUserUsernames = await UserService.getLoggedUsersUsernames();

    for (final username in _selectedUsers) {
      _loggedUsers[username]!.setProcessing();
      notifyListeners();

      if (loggedUserUsernames.contains(username)) {
        _loggedUsers[username]!.setSucceed();
        notifyListeners();
        continue;
      }

      final UserCredential? userCredential = await UserCredentialsService.loadUserCredentials(username);

      if (userCredential == null) {
        _loggedUsers[username]!.setFailed("This user is not well configured.");
        UserCredentialsService.deleteUserCredentials(username);
        continue;
      }

      try {
        await UserService.login(userCredential);
        _loggedUsers[username]!.setSucceed();
        notifyListeners();
      } catch (e) {
        _loggedUsers[username]!.setFailed(e.toString());
        notifyListeners();
        continue;
      }
    }
  }
}