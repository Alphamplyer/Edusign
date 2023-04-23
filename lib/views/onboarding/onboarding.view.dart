import 'package:edusign_v3/views/onboarding/subviews/loading.view.dart';
import 'package:flutter/material.dart';

import '../../models/user_credential.dart';
import '../browse_courses/browse_courses.view.dart';
import 'onboarding.view_model.dart';
import 'subviews/login.view.dart';
import 'subviews/register.view.dart';
import 'subviews/welcome.view.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  late OnboardingViewModel _viewModel;

  @override
  void initState() {
    _viewModel = OnboardingViewModel(
      onLoginSuccess: _onLoginSuccess,
      onLoginFailure: _onLoginFailure,
    );
    super.initState();
    _viewModel.loading();
  }

  void _onLoginSuccess() async {
    await Future.delayed(Duration(seconds: 3));
    if (!mounted) return;
    Navigator.pushReplacement(
      context, 
      MaterialPageRoute(builder: (context) => const BrowseCoursesView()),
    );
  }

  void _onLoginFailure() async {
    await Future.delayed(Duration(seconds: 3));
    if (!mounted) return;
    _viewModel.goToRegister();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: AnimatedBuilder(
              animation: _viewModel, 
              builder: (BuildContext context, Widget? child) {
                return PageView(
                  controller: _viewModel.pageController,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    LoadingView(),
                    WelcomeView(
                      onContinue: () => _viewModel.goToRegister(),
                    ),
                    RegisterView(
                      onRegister: (UserCredential userCredential) => _viewModel.register(userCredential),
                    ),
                    LoginView(loginResponseMessage: _viewModel.loginResponseMessage),
                  ],
                );
              },
            ),
          ),
          SizedBox(

          )
        ],
      )
    );
  }
}