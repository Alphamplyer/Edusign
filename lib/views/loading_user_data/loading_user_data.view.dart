
import 'package:edusign_v3/config/constants.dart';
import 'package:edusign_v3/models/merged_course.model.dart';
import 'package:edusign_v3/views/browse_courses/browse_courses.view.dart';
import 'package:edusign_v3/views/loading_user_data/loading_user_data.view_model.dart';
import 'package:edusign_v3/views/loading_user_data/models/loading_result.model.dart';
import 'package:edusign_v3/views/loading_user_data/widgets/loading_user_tile.widget.dart';
import 'package:edusign_v3/views/scan_qrcode/scan_qrcode.view.dart';
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

    if (loadingResult.allUsersLoadedSuccessfully) {
      _goToScanQrCodeView(loadingResult.mergedCourse!);
      return;
    } 
    
    if (loadingResult.validatedUsers.isEmpty) {
      bool? shouldContinue = await _waitForUserChoice(loadingResult);
      if (shouldContinue == true) {
        _goToScanQrCodeView(loadingResult.mergedCourse!);
      } else {
        _goToBrowseCoursesView();
      }
    }
  }

  Future<bool> _waitForUserChoice(LoadingResult loadingResult) async {
    bool? shouldContinue = null;
    do {
      shouldContinue = await _showErrorLoadingDialog(loadingResult);  
    } while (shouldContinue == null);
    return shouldContinue;
  }

  void _goToScanQrCodeView(MergedCourse mergedCourse) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ScanQrCodeView(mergedCourse: mergedCourse),
      ),
    );
  }

  void _goToBrowseCoursesView() {
    Navigator.pushReplacement(
      context, 
      MaterialPageRoute(
        builder: (context) => BrowseCoursesView(),
      ),
    );
  }

  List<Widget> _buildDialogActions(LoadingResult loadingResult) {
    List<Widget> actions = [
      TextButton(
        child: const Text('Cancel'),
        onPressed: () {
          Navigator.of(context).pop(false);
        },
      ),
    ];

    if (loadingResult.mergedCourse != null) {
      actions.add(
        TextButton(
          child: const Text('Continue'),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
        ),
      );
    }

    return actions;
  }

  Future<bool?> _showErrorLoadingDialog(LoadingResult loadingResult) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error loading users'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('There was an error loading the following users:'),
                Text(
                  "- ${loadingResult.failedUsers.join('\n- ')}",
                ),
                Text("Do you want to continue without them?")
              ],
            ),
          ),
          actions: _buildDialogActions(loadingResult),
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