
import 'package:edusign_v3/config/constants.dart';
import 'package:edusign_v3/views/loading_user_data/loading_user_data.view.dart';
import 'package:edusign_v3/views/select_users/select_users.view_model.dart';
import 'package:edusign_v3/widgets/edusign_scaffold.dart';
import 'package:flutter/material.dart';

class SelectUsersView extends StatefulWidget {
  final String courseId;
  
  const SelectUsersView({
    super.key,
    required this.courseId
  });

  @override
  State<SelectUsersView> createState() => _SelectUsersViewState();
}

class _SelectUsersViewState extends State<SelectUsersView> {
  late SelectUsersViewModel _viewModel;

  @override
  void initState() {
    _viewModel = SelectUsersViewModel();
    super.initState();
    _viewModel.loadState();
  }

  Future<void> onValidate() async {
    await _viewModel.saveSelectedUsers();
    Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => LogingInUsersView(
          courseId: widget.courseId,
          selectedUsers: _viewModel.selectedUsers,
        )
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return EdusignScaffold(
      title: 'Select users to scan',
      body: AnimatedBuilder(
        animation: _viewModel,
        builder: (context, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: _viewModel.registeredUsers.length,
                  itemBuilder: (context, index) {
                    if (_viewModel.isLoading)
                      return Center(child: const CircularProgressIndicator());
                      
                    final username = _viewModel.registeredUsers[index];
                    return SwitchListTile(
                      title: Text(username),
                      value: _viewModel.selectedUsers.contains(username),
                      onChanged: (value) => _viewModel.toggleUserSelection(username),
                    );
                  }
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  right: Constants.kDefaultPadding, 
                  left: Constants.kDefaultPadding, 
                  bottom: Constants.kDefaultPadding,
                  top: 0.0
                ),
                child: SizedBox(
                  height: Constants.kDefaultButtonHeight,
                  child: ValueListenableBuilder(
                    valueListenable: _viewModel.isProcessingNotifier,
                    builder: (context, isProcessing, child) {
                      return ElevatedButton(
                        onPressed: onValidate,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Select (${_viewModel.selectedUsers.length})'),
                            if (isProcessing)
                              const CircularProgressIndicator()
                          ],
                        ),
                      );
                    }
                  ),
                ),
              ),
            ],
          );
        }
      ),
    );
  }
}