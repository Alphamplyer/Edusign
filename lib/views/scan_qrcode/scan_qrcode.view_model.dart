
import 'package:edusign_v3/models/merged_course.model.dart';
import 'package:edusign_v3/models/user_model.dart';
import 'package:edusign_v3/services/edusign_service.dart';
import 'package:edusign_v3/services/signature_service.dart';
import 'package:edusign_v3/views/scan_qrcode/model/scan_qrcode_result.model.dart';
import 'package:flutter/material.dart';

class ScanQrcodeViewModel with ChangeNotifier {
  final MergedCourse mergedCourse;
  final List<User> successfullyLoadedUsers = [];
  final List<String> _successfullyValidatedUsers = [];

  ScanQrcodeViewModel({
    required this.mergedCourse,
  });

  bool isAllUserSuccessfullyValidated() {
    return _successfullyValidatedUsers.length == successfullyLoadedUsers.length;
  }

  Future<bool> onScan(String barcodeRawValue) async {
    List<Future<ScanQrcodeResult>> futures = [];

    for (var user in successfullyLoadedUsers) {
      UserCourseDetails userCourseDetails = mergedCourse.userCourseDetails[user.username]!;
      if (userCourseDetails.isScanned) continue;
      futures.add(onValidateUserPresence(user, barcodeRawValue, mergedCourse.id, userCourseDetails));
    }

    List<ScanQrcodeResult> scanQrcodeResults = await Future.wait<ScanQrcodeResult>(futures);

    for (var scanQrcodeResult in scanQrcodeResults) {
      if (scanQrcodeResult.isValidated) _successfullyValidatedUsers.add(scanQrcodeResult.username);
    }

    return _successfullyValidatedUsers.length == successfullyLoadedUsers.length;
  }

  Future<ScanQrcodeResult> onValidateUserPresence(User user,  String barcodeRawValue, String courseId, UserCourseDetails courseDetails) async {
    try {
      String signature = await SignatureService.getSignature(user);
      bool userIsValidated = await EdusignService.validateCourse(
        user,
        courseId,
        barcodeRawValue,
        signature,
      );
      return ScanQrcodeResult(
        username: user.username,
        isValidated: userIsValidated
      );
    } catch (e) {
      return ScanQrcodeResult.failure(user.username);
    } 
  }
}