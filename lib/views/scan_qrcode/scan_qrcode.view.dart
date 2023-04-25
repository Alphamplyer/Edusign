
import 'package:edusign_v3/models/merged_course.model.dart';
import 'package:edusign_v3/views/browse_courses/browse_courses.view.dart';
import 'package:edusign_v3/views/scan_qrcode/scan_qrcode.view_model.dart';
import 'package:edusign_v3/widgets/animated_validator.dart';
import 'package:edusign_v3/widgets/barcode_scanner_widget.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanQrCodeView extends StatefulWidget {
  final MergedCourse mergedCourse;
  
  const ScanQrCodeView({
    super.key,
    required this.mergedCourse,
  });

  @override
  State<ScanQrCodeView> createState() => _ScanQrCodeViewState();
}

class _ScanQrCodeViewState extends State<ScanQrCodeView> with SingleTickerProviderStateMixin {
  late ScanQrcodeViewModel _viewModel;
  late AnimationController _controller;
  List<String> validatedUserIds = [];

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _viewModel = ScanQrcodeViewModel(mergedCourse: widget.mergedCourse);
    super.initState();
  }

  Future<bool> _onScan(Barcode barcode) async {
    if (barcode.rawValue == null) return false;
    bool allUsersValidated = await _viewModel.onScan(barcode.rawValue!);
    return allUsersValidated;
  }

  void _afterSuccessAnimation() {
    Navigator.pushReplacement(
      context, 
      MaterialPageRoute(builder: (context) => BrowseCoursesView()),
    );
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
        afterSuccessAnimation: _afterSuccessAnimation,
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