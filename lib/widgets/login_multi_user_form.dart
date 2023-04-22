
import 'package:edusign_v3/config/constants.dart';
import 'package:edusign_v3/config/storage_keys.dart';
import 'package:edusign_v3/services/storage_service.dart';
import 'package:flutter/material.dart';

class LoginMultiUserForm extends StatefulWidget {
  final List<String> userNames;
  final List<String> previouslySelectedUsernames;
  final Function(List<String>) onLogin;

  const LoginMultiUserForm({
    super.key,
    required this.userNames,
    required this.previouslySelectedUsernames,
    required this.onLogin,
  });

  @override
  State<LoginMultiUserForm> createState() => _LoginMultiUserFormState();
}

class _LoginMultiUserFormState extends State<LoginMultiUserForm> {
  List<String> selectedUsers = [];

  @override
  void initState() {
    selectedUsers = widget.previouslySelectedUsernames.where((element) => widget.userNames.contains(element)).toList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: widget.userNames.length,
            itemBuilder: (context, index) {
              return CheckboxListTile(
                activeColor: Constants.interactableBackgroundColor,
                checkColor: Constants.interactableForegroundColor,
                title: Text(widget.userNames[index]),
                value: selectedUsers.contains(widget.userNames[index]),
                onChanged: (value) {
                  setState(() {
                    if (value!) {
                      selectedUsers.add(widget.userNames[index]);
                    } else {
                      selectedUsers.remove(widget.userNames[index]);
                    }
                  });
                },
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: selectedUsers.isEmpty 
                ? null 
                : () async {
                  await StorageService.write(key: StorageKeys.PREVIOUSLY_SELECTED_USERNAMES, value: selectedUsers.join(','));
                  widget.onLogin(selectedUsers);
                },
              child: Text(
                selectedUsers.length > 1 
                  ? 'Select (${selectedUsers.length})' 
                  : 'Select',
              ),
            ),
          ),
        ),
      ],
    );
  }
}