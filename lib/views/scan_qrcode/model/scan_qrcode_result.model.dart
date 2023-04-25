
class ScanQrcodeResult {
  String username;
  bool isValidated;

  ScanQrcodeResult({
    required this.username,
    required this.isValidated,
  });

  factory ScanQrcodeResult.success(String username) {
    return ScanQrcodeResult(
      username: username,
      isValidated: true,
    );
  }

  factory ScanQrcodeResult.failure(String username) {
    return ScanQrcodeResult(
      username: username,
      isValidated: false,
    );
  }
}