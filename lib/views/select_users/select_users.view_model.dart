
import 'package:edusign_v3/services/app_flow_states_service.dart';
import 'package:edusign_v3/services/user_credentials_service.dart';
import 'package:flutter/material.dart';

class SelectUsersViewModel with ChangeNotifier {  
  List<String> _registeredUsers = [];
  List<String> get registeredUsers => _registeredUsers;

  List<String> _selectedUsers = [];
  List<String> get selectedUsers => _selectedUsers;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  ValueNotifier<bool> _isProcessingNotifier = ValueNotifier(false);
  ValueNotifier<bool> get isProcessingNotifier => _isProcessingNotifier;

  Future<void> loadState() async {
    _isLoading = true;
    notifyListeners();
    await _loadRegisteredUsers();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadRegisteredUsers() async {
    _registeredUsers = await UserCredentialsService.loadAllPersitedUserCredentialsUsersnames();
  }

  Future<void> toggleUserSelection(String username) async {
    if (_selectedUsers.contains(username))
      _selectedUsers.remove(username);
    else
      _selectedUsers.add(username);
    notifyListeners();
  }

  Future<void> saveSelectedUsers() async {
    _isProcessingNotifier.value = true;
    await AppFlowStatesService.savePreviouslySelectedUsernames(_selectedUsers);
    _isProcessingNotifier.value = false;
  }
}