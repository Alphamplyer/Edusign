
import 'package:edusign_v3/models/user_credential.dart';
import 'package:flutter/material.dart';

class RegisterView extends StatefulWidget {
  final Function(UserCredential) onRegister;

  RegisterView({
    super.key,
    required this.onRegister,
  });

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? usernameErrorText;
  String? passwordErrorText;

  String? validateUsername() {
    String? value = usernameController.text;
    if (value.isEmpty) {
      return 'Username cannot be empty';
    }
    return null;
  }

  String? validatePassword() {
    String? value = passwordController.text;
    if (value.isEmpty) {
      return 'Password cannot be empty';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: AutofillGroup(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Register", style: Theme.of(context).textTheme.titleLarge),
                    SizedBox(height: 64.0),
                    TextField(
                      controller: usernameController,
                      autofillHints: [AutofillHints.username],
                      decoration: InputDecoration(
                        labelText: 'Username',
                        errorText: usernameErrorText,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    TextField(
                      controller: passwordController,
                      autofillHints: [AutofillHints.password],
                      decoration: InputDecoration(
                        labelText: 'Password',
                        errorText: passwordErrorText,
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                    SizedBox(height: 64.0),
                  ],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () { 
                setState(() {
                  usernameErrorText = validateUsername();
                  passwordErrorText = validatePassword();
                });

                if (usernameController.text.isEmpty || passwordController.text.isEmpty) return;
                
                widget.onRegister(UserCredential(
                  username: usernameController.text,
                  password: passwordController.text,
                ));
              },
              child: Text('Register'),
            )
          ],
        ),
      ),
    );
  }
}