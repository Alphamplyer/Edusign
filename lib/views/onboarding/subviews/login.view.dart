
import 'package:animated_check/animated_check.dart';
import 'package:animated_cross/animated_cross.dart';
import 'package:edusign_v3/config/constants.dart';
import 'package:edusign_v3/views/onboarding/onboarding.view_model.dart';
import 'package:flutter/material.dart';

import '../../../config/edusign_Colors.dart';

class LoginView extends StatefulWidget {
  final LoginResponseMessage? loginResponseMessage;

  const LoginView({
    super.key,
    required this.loginResponseMessage,  
  });

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: Constants.defaultIconAnimationDuration,
    );
    animation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeInCubic,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Widget _buildAnimatedCross() {
    return FractionallySizedBox(
      widthFactor: 0.4,
      child: AspectRatio(
        aspectRatio: 1,
        child: AnimatedCross(
          progress: animation,
          size: 60,
          color: EdusignColors.errorColorForeground,
        ),
      ),
    );
  }

  Widget _buildAnimatedCheck() {
    return FractionallySizedBox(
      widthFactor: 0.4,
      child: AspectRatio(
        aspectRatio: 1,
        child: AnimatedCheck(
          progress: animation,
          size: 60,
          color: EdusignColors.successColorForeground,
        ),
      ),
    );
  }

  Widget _buildAnimatedIcon() {
    return widget.loginResponseMessage!.isError ? _buildAnimatedCross() : _buildAnimatedCheck();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Builder(
          builder: (BuildContext context) {
            if (widget.loginResponseMessage != null) {
              controller.forward();
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildAnimatedIcon(),
                  Text(
                    widget.loginResponseMessage!.message,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: widget.loginResponseMessage!.isError ? EdusignColors.errorColorForeground : EdusignColors.successColorForeground,
                    ),
                  )
                ],
              );
            }
            controller.reset();
            return CircularProgressIndicator();
          }
        )
      )
    );
  }
}