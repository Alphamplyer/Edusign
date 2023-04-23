
import 'package:flutter/material.dart';

import 'login_state.enum.dart';

class UserLoginState {
  final String username;
  late ValueNotifier<LoginState> state;
  String _failedReason = '';

  String get failedReason => _failedReason;

  UserLoginState({
    required this.username,
    LoginState state = LoginState.waiting,
  }) {
    this.state = ValueNotifier(state);
  }

  factory UserLoginState.waiting({required String username}) {
    return UserLoginState(username: username, state: LoginState.waiting);
  }

  factory UserLoginState.processing({required String username}) {
    return UserLoginState(username: username, state: LoginState.processing);
  }

  factory UserLoginState.succeed({required String username}) {
    return UserLoginState(username: username, state: LoginState.succeed);
  }

  factory UserLoginState.failed({required String username, required String reason}) {
    final userLoginState = UserLoginState(username: username, state: LoginState.failed);
    userLoginState._failedReason = reason;
    return userLoginState;
  }

  void setWaiting() {
    state.value = LoginState.waiting;
  }

  void setProcessing() {
    state.value = LoginState.processing;
  }

  void setSucceed() {
    state.value = LoginState.succeed;
  }

  void setFailed(String reason) {
    _failedReason = reason;
    state.value = LoginState.failed;
  }
}
