
import 'package:edusign_v3/config/constants.dart';
import 'package:edusign_v3/config/edusign_colors.dart';
import 'package:edusign_v3/views/loading_user_data/models/loading_user_state.enum.dart';
import 'package:edusign_v3/views/loading_user_data/states/loading_user_tile.state.dart';
import 'package:flutter/material.dart';

class LoadingUserTile extends StatelessWidget {
  final LoadingUserTileState state;

  const LoadingUserTile({
    super.key,
    required this.state,
  });

  List<Widget> _buildErrorReasonChildren(BuildContext context, LoadingUserState loadingState) {
    return [
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
              state.failingReason,
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
    ];
  }

  Widget _buildUsernameLabel(BuildContext context) {
    return Text(
      "Username:",
      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildUsername(BuildContext context) {
    return Expanded(
      child: Text(
        state.username,
        style: Theme.of(context).textTheme.bodyMedium,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
      )
    );
  }

  double _getBottomPadding(BuildContext context, LoadingUserState loadingState) {
    return loadingState == LoadingUserState.failed ? 0 : Constants.kDefaultPadding;
  }

  Widget _buildMark(BuildContext context, LoadingUserState loadingState) {
    switch (loadingState) {
      case LoadingUserState.loggingUser:
      case LoadingUserState.loadingUserCourses:
      case LoadingUserState.tryingToGetTheEnrolledCourse:
        return SizedBox(
          width: 20,
          height: 20,
          child: const CircularProgressIndicator()
        );
      case LoadingUserState.succeed:
        return const Icon(
          Icons.check_rounded,
          color: EdusignColors.successColorForeground,
          size: 24,
        );
      case LoadingUserState.failed:
        return const Icon(
          Icons.warning_amber_rounded,
          color: EdusignColors.errorColorForeground,
          size: 24,
        );
    }
  }

  List<Widget> _buildChildren(BuildContext context, LoadingUserState loadingState) {
    List<Widget> children = [
      Padding(
        padding: EdgeInsets.only(
          top: Constants.kDefaultPadding,
          right: Constants.kDefaultPadding,
          bottom: _getBottomPadding(context, loadingState),
          left: Constants.kDefaultPadding,
        ),
        child: Row(
          children: [
            _buildUsernameLabel(context),
            const SizedBox(width: Constants.kDefaultMargin),
            _buildUsername(context),
            const SizedBox(width: Constants.kDefaultPadding),
            _buildMark(context, loadingState),
          ],
        ),
      ),        
    ];

    if (loadingState == LoadingUserState.failed) {
      children.addAll(_buildErrorReasonChildren(context, loadingState));
    }

    return children;
  }

  Color _getLoginStateColor(BuildContext context, LoadingUserState loadingState) {
    switch (loadingState) {        
      case LoadingUserState.succeed:
        return EdusignColors.successColorForeground;
      case LoadingUserState.failed:
        return EdusignColors.errorColorForeground;
      default:
        return Theme.of(context).colorScheme.outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: state.stateValueNotifier,
      builder: (context, loadingState, child) {
        return Card(
          key: ValueKey(state.username),
          clipBehavior: Clip.hardEdge,
          margin: EdgeInsets.symmetric(vertical: Constants.kDefaultMargin),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(Radius.circular(Constants.kDefaultBorderRadius)),
            side: BorderSide(
              color: _getLoginStateColor(context, loadingState),
            ),
          ),
          child: Column(
            children: _buildChildren(context, loadingState),
          ),
        );
      },
    );
  }
}