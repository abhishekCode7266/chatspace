// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

/// Web Live Camera Capture Service with WebRTC Video Stream & Snapshot Canvas
class CameraCaptureService {
  CameraCaptureService._();
  static final CameraCaptureService instance = CameraCaptureService._();

  bool get isWebLiveCameraSupported => true;

  html.VideoElement? _videoElement;
  html.MediaStream? _mediaStream;
  String? _registeredViewType;
  bool _isFrontCamera = true;
  bool _isStreaming = false;

  bool get isStreaming => _isStreaming;
  bool get isFrontCamera => _isFrontCamera;

  /// Starts live camera stream using browser navigator.mediaDevices.getUserMedia
  Future<bool> startCameraStream({required bool isFrontCamera}) async {
    _isFrontCamera = isFrontCamera;
    _stopActiveStream();

    try {
      final mediaDevices = html.window.navigator.mediaDevices;
      if (mediaDevices == null) {
        debugPrint('WebRTC mediaDevices not available in browser');
        return false;
      }

      final constraints = {
        'video': {
          'facingMode': isFrontCamera ? 'user' : 'environment',
          'width': {'ideal': 1280},
          'height': {'ideal': 720},
        },
        'audio': false,
      };

      final stream = await mediaDevices.getUserMedia(constraints);
      _mediaStream = stream;

      _videoElement ??= html.VideoElement()
        ..autoplay = true
        ..muted = true
        ..playsInline = true
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'cover'
        ..style.backgroundColor = '#000000';

      _videoElement!.style.transform = isFrontCamera ? 'scaleX(-1)' : 'none';
      _videoElement!.srcObject = stream;
      await _videoElement!.play();
      _isStreaming = true;

      return true;
    } catch (e) {
      debugPrint('Error starting camera stream: $e');
      _isStreaming = false;
      return false;
    }
  }

  /// Builds the Flutter HtmlElementView embedding the live HTML5 <video> camera element
  Widget buildLiveCameraView({
    required bool isFrontCamera,
    required void Function(bool ready) onCameraReady,
  }) {
    if (_registeredViewType == null) {
      _registeredViewType = 'universal-camera-view-${DateTime.now().millisecondsSinceEpoch}';
      
      _videoElement = html.VideoElement()
        ..autoplay = true
        ..muted = true
        ..playsInline = true
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'cover'
        ..style.backgroundColor = '#000000';

      ui_web.platformViewRegistry.registerViewFactory(
        _registeredViewType!,
        (int viewId) => _videoElement!,
      );
    }

    startCameraStream(isFrontCamera: isFrontCamera).then((success) {
      onCameraReady(success);
    });

    return HtmlElementView(viewType: _registeredViewType!);
  }

  /// Flips between front selfie camera and rear environment camera
  Future<bool> flipCamera(bool isFront) async {
    return await startCameraStream(isFrontCamera: isFront);
  }

  /// Captures current video frame to HTML canvas and exports as JPEG Data URL
  Future<String?> snapPhoto() async {
    if (_videoElement == null || _mediaStream == null) return null;

    try {
      final video = _videoElement!;
      final width = video.videoWidth > 0 ? video.videoWidth : 640;
      final height = video.videoHeight > 0 ? video.videoHeight : 480;

      final canvas = html.CanvasElement(width: width, height: height);
      final ctx = canvas.context2D;

      // Match selfie orientation if front camera
      if (_isFrontCamera) {
        ctx.translate(width, 0);
        ctx.scale(-1, 1);
      }

      ctx.drawImage(video, 0, 0);

      // Play camera shutter sound effect
      _playShutterSound();

      final dataUrl = canvas.toDataUrl('image/jpeg', 0.85);
      return dataUrl;
    } catch (e) {
      debugPrint('Error snapping photo from video element: $e');
      return null;
    }
  }

  void _playShutterSound() {
    try {
      final audioCtx = html.AudioContext();
      final osc = audioCtx.createOscillator();
      final gain = audioCtx.createGain();

      final now = audioCtx.currentTime ?? 0;
      osc.type = 'triangle';
      osc.frequency?.setValueAtTime(800, now);
      osc.frequency?.exponentialRampToValueAtTime(200, now + 0.08);

      gain.gain?.setValueAtTime(0.3, now);
      gain.gain?.exponentialRampToValueAtTime(0.01, now + 0.08);

      osc.connect(gain);
      gain.connect(audioCtx.destination);

      osc.start(now);
      osc.stop(now + 0.08);
    } catch (_) {}
  }

  void _stopActiveStream() {
    if (_mediaStream != null) {
      try {
        final tracks = _mediaStream!.getTracks();
        for (final track in tracks) {
          track.stop();
        }
      } catch (_) {}
      _mediaStream = null;
    }
    _isStreaming = false;
  }

  /// Releases webcam hardware stream
  void disposeCamera() {
    _stopActiveStream();
    if (_videoElement != null) {
      _videoElement!.srcObject = null;
    }
  }
}
