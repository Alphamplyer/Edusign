
import 'package:flutter/material.dart';

class WelcomeView extends StatelessWidget {
  final VoidCallback onContinue;

  const WelcomeView({
    super.key,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Welcome to Edusign',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 20),
                  Text(
                    "This is a clone of the Edusign app. It is not affiliated with Edusign in any way. " +
                    "The original app did not work on my phone, so I decided to make my own. " +
                    "This app is not intended for production use.",
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: onContinue,
              child: Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}