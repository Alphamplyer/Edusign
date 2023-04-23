
import 'dart:io';

import 'package:edusign_v3/config/constants.dart';
import 'package:edusign_v3/models/user_credential.dart';
import 'package:edusign_v3/services/app_flow_states_service.dart';
import 'package:edusign_v3/services/user_credentials_service.dart';
import 'package:edusign_v3/services/user_service.dart';
import 'package:edusign_v3/views/onboarding/onboarding_steps.dart';
import 'package:flutter/material.dart';

class OnboardingViewModel with ChangeNotifier {
  PageController _pageController = PageController(initialPage: 0);
  PageController get pageController => _pageController;

  OnboardingSteps _currentStep = OnboardingSteps.loading;
  OnboardingSteps get currentStep => _currentStep;

  UserCredential? _userCredential;
  UserCredential? get userCredential => _userCredential;

  LoginResponseMessage? _loginResponseMessage;
  LoginResponseMessage? get loginResponseMessage => _loginResponseMessage;
  late VoidCallback _onLoginSuccess;
  late VoidCallback _onLoginFailure;

  OnboardingViewModel({
    required VoidCallback onLoginSuccess,
    required VoidCallback onLoginFailure,
  }) {
    _onLoginSuccess = onLoginSuccess;
    _onLoginFailure = onLoginFailure;
  }

  void _setStep(OnboardingSteps step, {bool animateTransition = true}) {
    _currentStep = step;
    _goToPage(
      pageIndex: _getPageIndex(step), 
      animateTransition: animateTransition
    );
    notifyListeners();
  }

  int _getPageIndex(OnboardingSteps currentStep) {
    switch (currentStep) {
      case OnboardingSteps.loading:
        return 0;
      case OnboardingSteps.welcome:
        return 1;
      case OnboardingSteps.register:
        return 2;
      case OnboardingSteps.processRegistration:
        return 3;
      case OnboardingSteps.registrationFailed:
        return 3;
      case OnboardingSteps.registered:
        return 3;
    }
  }

  void _goToPage({required int pageIndex, bool animateTransition = true}) {
    if (animateTransition) {
      _pageController.animateToPage(
        pageIndex,
        duration: const Duration(milliseconds: Constants.defaultAnimationDurationInMiliseconds),
        curve: Curves.easeInOut,
      );
    } else {
      _pageController.jumpToPage(pageIndex);
    }
  }

  Future<void> loading() async {    
    bool hasAlreadyLaunchedOnce = await AppFlowStatesService.hasAlreadyLaunchedOnce();

    if (!hasAlreadyLaunchedOnce) {
      _setStep(OnboardingSteps.welcome, animateTransition: true);
      return;
    } 

    _userCredential = await UserCredentialsService.loadMainUserCredentials();

    if (_userCredential != null) {
      _setStep(OnboardingSteps.processRegistration, animateTransition: false);
      await processRegistration();
      return;
    }

    _setStep(OnboardingSteps.register, animateTransition: false);
  }

  Future<void> register(UserCredential userCredential) async {
    FocusManager.instance.primaryFocus?.unfocus();
    _userCredential = userCredential;
    await UserCredentialsService.saveMainUserUsername(_userCredential!.username);
    _setStep(OnboardingSteps.processRegistration, animateTransition: true);
    await processRegistration();
  }

  Future<void> processRegistration() async {
    if (_userCredential == null) {
      _setStep(OnboardingSteps.register, animateTransition: true);
      return;
    }

    try {
      await UserService.login(_userCredential!);      
      _loginResponseMessage = LoginResponseMessage(
        message: 'Login successful',
        isError: false,
      );
      await AppFlowStatesService.setHasAlreadyLaunchedOnce();
      await UserCredentialsService.saveUserCrendential(_userCredential!);
      _setStep(OnboardingSteps.registered, animateTransition: true);
      _onLoginSuccess.call();
    } on SocketException catch (e) {
      print("Server not reachable ${e}");
      _loginResponseMessage = LoginResponseMessage(
        message: 'Server not reachable',
        isError: true,
      );
      _setStep(OnboardingSteps.registrationFailed, animateTransition: true);
      _onLoginFailure.call();
    } catch (e) {
      print("Wrong credentials ${e}");
      _loginResponseMessage = LoginResponseMessage(
        message: 'Wrong credentials',
        isError: true,
      );
      _setStep(OnboardingSteps.registrationFailed, animateTransition: true);
      _onLoginFailure.call();
    }
  }

  void goToRegister() {
    _setStep(OnboardingSteps.register, animateTransition: true);
  }
}

class LoginResponseMessage {
  final String message;
  final bool isError;

  LoginResponseMessage({
    required this.message,
    this.isError = false,
  });
}