
import 'package:edusign_v3/config/constants.dart';
import 'package:edusign_v3/config/edusign_Colors.dart';
import 'package:edusign_v3/views/loging_in_users/loging_in_users.view_model.dart';
import 'package:edusign_v3/views/loging_in_users/models/logged_user_state.model.dart';
import 'package:edusign_v3/views/loging_in_users/models/login_state.enum.dart';
import 'package:edusign_v3/views/scanning_user_state/scanning_user_state.view.dart';
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
    _viewModel = LogingInUsersViewModel(selectedUsers: widget.selectedUsers);
    super.initState();
    _viewModel.loadState();
  }

  void _onContinueButtonPressed() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScanningUserStateView(),
      ),
    );
  }

  Color _getLoginStateColor(LoginState loginState) {
    switch (loginState) {
      case LoginState.waiting:
        return Colors.transparent;
      case LoginState.processing:
        return Theme.of(context).colorScheme.outline;
      case LoginState.succeed:
        return EdusignColors.successColorForeground;
      case LoginState.failed:
        return EdusignColors.errorColorForeground;
    }
  }

  Widget _buildMark(LoginState loginState) {
    switch (loginState) {
      case LoginState.waiting:
      case LoginState.processing:
        return SizedBox(
          width: 20,
          height: 20,
          child: const CircularProgressIndicator()
        );
      case LoginState.succeed:
        return const Icon(
          Icons.check_rounded,
          color: EdusignColors.successColorForeground,
          size: 24,
        );
      case LoginState.failed:
        return const Icon(
          Icons.warning_amber_rounded,
          color: EdusignColors.errorColorForeground,
          size: 24,
        );
    }
  } 

  Widget _buildUserCard(UserLoginState userLoginState) {
    return ValueListenableBuilder(
      valueListenable: userLoginState.state,
      builder: (context, loginState, child) {
        return Card(
          key: ValueKey(userLoginState.username),
          clipBehavior: Clip.hardEdge,
          margin: EdgeInsets.symmetric(vertical: Constants.kDefaultMargin),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(Radius.circular(Constants.kDefaultBorderRadius)),
            side: BorderSide(
              color: _getLoginStateColor(loginState),
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: Constants.kDefaultPadding,
                  right: Constants.kDefaultPadding,
                  bottom: loginState == LoginState.failed ? 0 : Constants.kDefaultPadding,
                  left: Constants.kDefaultPadding,
                ),
                child: Row(
                  children: [
                    Text(
                      "Username:",
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: Constants.kDefaultMargin),
                    Expanded(
                      child: Text(
                        userLoginState.username,
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                      )
                    ),
                    const SizedBox(width: Constants.kDefaultPadding),
                    _buildMark(loginState),
                  ],
                ),
              ),
              if (loginState == LoginState.failed) 
                Padding(
                  padding: const EdgeInsets.only(
                    right: Constants.kDefaultPadding,
                    bottom: Constants.kDefaultPadding,
                    left: Constants.kDefaultPadding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Reason:", 
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: EdusignColors.errorColorForeground,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        userLoginState.failedReason,
                        style: const TextStyle(
                          color: EdusignColors.errorColorForeground,
                        ),
                        textAlign: TextAlign.justify,
                        maxLines: 3,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
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
                    itemCount: _viewModel.loggedUsers.length,
                    itemBuilder: (context, index) {
                      return _buildUserCard(_viewModel.loggedUsers[index]);
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