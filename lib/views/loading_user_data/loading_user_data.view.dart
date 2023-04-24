
import 'package:edusign_v3/config/constants.dart';
import 'package:edusign_v3/views/loading_user_data/loading_user_data.view_model.dart';
import 'package:edusign_v3/views/loading_user_data/models/loading_result.model.dart';
import 'package:edusign_v3/views/loading_user_data/widgets/loading_user_tile.widget.dart';
import 'package:edusign_v3/widgets/edusign_scaffold.dart';
import 'package:flutter/material.dart';

class LogingInUsersView extends StatefulWidget {
  final String courseId;
  final List<String> selectedUsers;

  const LogingInUsersView({
    super.key,
    required this.courseId,
    required this.selectedUsers,
  });

  @override
  State<LogingInUsersView> createState() => _LogingInUsersViewState();
}

class _LogingInUsersViewState extends State<LogingInUsersView> {
  late LogingInUsersViewModel _viewModel;
  @override
  void initState() {
    _viewModel = LogingInUsersViewModel(
      courseId: widget.courseId,
      selectedUsers: widget.selectedUsers
    );
    super.initState();
    _viewModel.loadState();
  }

  void _onContinueButtonPressed() async {
    LoadingResult loadingResult = _viewModel.getLoadingResult();

    // TODO: Implement the logic to continue to the next screen.
    // - Navigate to the next screen if all users were loaded successfully.
    // - Show an error dialog if at least one user failed to load and ask the user if they want to retry, 
    // cancel or continue without the failed users.
  }

  @override
  Widget build(BuildContext context) {
    return EdusignScaffold(
      title: 'Logging in users', 
      body: AnimatedBuilder(
        animation: _viewModel,
        builder: (context, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Constants.kDefaultPadding),
                  child: ListView.builder(
                    itemCount: _viewModel.loadingUserTileStates.length,
                    itemBuilder: (context, index) {
                      return LoadingUserTile(state: _viewModel.loadingUserTileStates[index]);
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(Constants.kDefaultPadding),
                child: SizedBox(
                  height: Constants.kDefaultButtonHeight,
                  child: ValueListenableBuilder(
                    valueListenable: _viewModel.isProcessingNotifier,
                    builder: (context, isProcessing, child) {
                      return ElevatedButton(
                        onPressed: isProcessing ? null : _onContinueButtonPressed,
                        child: const Text('Continue'),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}