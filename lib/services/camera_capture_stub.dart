import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Camera capture interface for non-web / mobile platforms
class CameraCaptureService {
  CameraCaptureService._();
  static final CameraCaptureService instance = CameraCaptureService._();

  bool get isWebLiveCameraSupported => false;

  /// Native mobile camera capture fallback
  Future<String?> capturePhoto({required bool isFrontCamera}) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: isFrontCamera ? CameraDevice.front : CameraDevice.rear,
        maxWidth: 1280,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        final b64 = base64Encode(bytes);
        return 'data:image/jpeg;base64,$b64';
      }
    } catch (e) {
      debugPrint('Native camera capture error: $e');
    }
    return null;
  }

  /// Non-web fallback widget
  Widget buildLiveCameraView({
    required bool isFrontCamera,
    required void Function(bool ready) onCameraReady,
  }) {
    onCameraReady(true);
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isFrontCamera ? Icons.face_rounded : Icons.camera_alt_rounded,
              size: 72,
              color: Colors.white54,
            ),
            const SizedBox(height: 12),
            const Text(
              'Device Camera Viewfinder',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> flipCamera(bool isFront) async {}
  Future<String?> snapPhoto() async => null;
  void disposeCamera() {}
}
