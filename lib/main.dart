import 'package:edusign_v3/pages/login_users_page.dart';
import 'package:edusign_v3/views/onboarding/onboarding.view.dart';
import 'package:flutter/material.dart';

import 'config/edusign_Colors.dart';

void main() {
  runApp(const EdusignApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fluttersign',
      theme: ThemeData.dark(useMaterial3: false).copyWith(
        colorScheme: ColorScheme.dark(
          primary: EdusignColors.defaultBackgroundColor,
          onPrimary: EdusignColors.defaultForegroundColor,
          secondary: EdusignColors.interactableBackgroundColor,
          onSecondary: EdusignColors.interactableForegroundColor,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(32),
            ),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: EdusignColors.interactableBackgroundColor,
            foregroundColor: EdusignColors.interactableForegroundColor,
            disabledBackgroundColor: Colors.grey.shade400.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
          ),
        ),
        cardTheme: CardTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
        ),
      ),
      home: const LoginUsersPage(),
    );
  }
}

class EdusignApp extends StatelessWidget {
  const EdusignApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Edusign',
      theme: ThemeData.dark(useMaterial3: true),
      home: const OnboardingView(),
    );
  }
}
