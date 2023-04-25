import 'package:edusign_v3/models/course_model.dart';
import 'package:edusign_v3/models/user_model.dart';
import 'package:edusign_v3/services/edusign_service.dart';
import 'package:edusign_v3/services/signature_service.dart';
import 'package:edusign_v3/widgets/animated_validator.dart';
import 'package:edusign_v3/widgets/barcode_scanner_widget.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class MultiUserCourseScannerPage extends StatefulWidget {
  final Course course;
  final List<User> users;

  const MultiUserCourseScannerPage({
    Key? key,
    required this.course,
    required this.users,
  }) : super(key: key);

  @override
  State<MultiUserCourseScannerPage> createState() => _MultiUserCourseScannerPageState();
}

class _MultiUserCourseScannerPageState extends State<MultiUserCourseScannerPage> with TickerProviderStateMixin {
  late AnimationController _controller;
  List<String> validatedUserIds = [];
  bool shouldPop = false;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    super.initState();
  }

  Future<bool> _onScan(Barcode barcode) async {
    if (barcode.rawValue == null) return false;

    bool allUsersValidated = true;

    for (var user in widget.users) {
      if (validatedUserIds.contains(user.id)) continue;

      try {
        String signature = await SignatureService.getSignature(user);

        bool userIsValidated = await EdusignService.validateCourse(
          user,
          widget.course.id,
          barcode.rawValue!,
          signature,
        );

        Course course = await EdusignService.getCourseById(user, widget.course.id);
        widget.course.updateFrom(course);

        if (userIsValidated) {
          validatedUserIds.add(user.id);
        }

        showMessage(
          context, 
          userIsValidated
            ? 'Successfully logged in ${user.username}'
            : 'Failed to log in ${user.username}',
        );
      } catch (e) {
        allUsersValidated = false;
        break;
      }  
    }

    return allUsersValidated;
  }

  void showMessage(BuildContext context, String message) {
    if (!mounted) return;

    ScaffoldMessengerState scaffoldMessengerState = ScaffoldMessenger.of(context);
    scaffoldMessengerState.hideCurrentSnackBar();
    scaffoldMessengerState.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BarcodeScanner(
        onScan: _onScan,
        afterSuccessAnimation: () {
          Navigator.pop(context);
        },
        allowDuplicates: true,
        scanDelay: const Duration(seconds: 1),
        squareIndicator: true,
        builder: (context, state, animationState, barcodeAnimationController, child) {
          if (animationState == AnimationScanState.waiting) {
            return const FittedBox(
              fit: BoxFit.contain,
              child: Center(
                child: Text(
                  'QR Code',
                ),
              ),
            );
          } else if (animationState == AnimationScanState.processing) {
            return const FractionallySizedBox(
              widthFactor: 0.8,
              child: FittedBox(
                fit: BoxFit.contain,
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.orange,
                  ),
                ),
              ),
            );
          } else if (animationState == AnimationScanState.success) {
            barcodeAnimationController.start(() {
              _controller.forward().whenComplete(() async {
                await Future.delayed(const Duration(milliseconds: 500));
                _controller.reverse().whenComplete(() {
                  barcodeAnimationController.stop();
                });
              });
            });
            return FittedBox(
              fit: BoxFit.contain,
              child: Center(
                child: AnimatedValidator(
                  icon: ValidatorIcon.check,
                  controller: _controller,
                  size: 60,
                  color: Colors.green,
                ),
              ),
            );
          } else {
            barcodeAnimationController.start(() {
              _controller.forward().whenComplete(() async {
                await Future.delayed(const Duration(milliseconds: 500));
                _controller.reverse().whenComplete(() {
                  barcodeAnimationController.stop();
                });
              });
            });
            return FittedBox(
              fit: BoxFit.contain,
              child: Center(
                child: AnimatedValidator(
                  icon: ValidatorIcon.cross,
                  controller: _controller,
                  size: 60,
                  color: Colors.red,
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
