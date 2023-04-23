
import 'dart:io';

import 'package:edusign_v3/models/user_credential.dart';
import 'package:edusign_v3/services/edusign_service.dart';
import 'package:edusign_v3/services/user_credentials_service.dart';
import 'package:flutter/material.dart';

import '../widgets/login_widget.dart';

class AddUserPage extends StatefulWidget {
  const AddUserPage({super.key});

  @override
  State<AddUserPage> createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {

  @override
  void initState() {
    super.initState();
  }

  void onLogin(String username, String password, bool rememberLogin) async {
    try {
      await EdusignService.login(username, password);
      await UserCredentialsService.saveUserCrendential(UserCredential(
        username: username,
        password: password
      ));

      if (!mounted) return;

      Navigator.pop(context, true);
    } on SocketException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed add user'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2C3E50),
              Color(0xFF4CA1AF),
            ],
          ),
        ),
        child: Center(
          child: FractionallySizedBox(
            widthFactor: 0.8,
            child: SizedBox(
              height: 300,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: LoginWidget(
                  showRememberLogin: false,
                  onLogin: onLogin,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
