// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:async';
import 'dart:html' as html;
import 'dart:web_audio' as web_audio;
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

      html.MediaStream? stream;
      // Step 1: Try requested facing mode with ideal resolution
      try {
        final constraints = {
          'video': {
            'facingMode': isFrontCamera ? 'user' : 'environment',
            'width': {'ideal': 1280},
            'height': {'ideal': 720},
          },
          'audio': false,
        };
        stream = await mediaDevices.getUserMedia(constraints);
      } catch (e1) {
        debugPrint('High constraint camera failed: $e1. Trying facingMode fallback...');
        // Step 2: Try facingMode only without resolution constraint
        try {
          stream = await mediaDevices.getUserMedia({
            'video': {'facingMode': isFrontCamera ? 'user' : 'environment'},
            'audio': false,
          });
        } catch (e2) {
          debugPrint('FacingMode fallback failed: $e2. Trying generic video stream...');
          // Step 3: Generic video stream fallback
          stream = await mediaDevices.getUserMedia({
            'video': true,
            'audio': false,
          });
        }
      }

      if (stream == null) {
        _isStreaming = false;
        return false;
      }

      _mediaStream = stream;

      _videoElement ??= html.VideoElement()
        ..autoplay = true
        ..muted = true
        ..setAttribute('playsinline', 'true')
        ..setAttribute('webkit-playsinline', 'true')
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'cover'
        ..style.backgroundColor = '#000000';

      _videoElement!.style.transform = isFrontCamera ? 'scaleX(-1)' : 'none';
      _videoElement!.srcObject = stream;
      try {
        await _videoElement!.play();
      } catch (playErr) {
        debugPrint('Video play call error (will autoplay): $playErr');
      }
      _isStreaming = true;

      return true;
    } catch (e) {
      debugPrint('Error starting camera stream: $e');
      _isStreaming = false;
      return false;
    }
  }

  /// Toggle torch / flashlight if supported by hardware
  Future<bool> toggleTorch(bool enable) async {
    if (_mediaStream == null) return false;
    try {
      final tracks = _mediaStream!.getVideoTracks();
      if (tracks.isNotEmpty) {
        final track = tracks.first;
        await track.applyConstraints({
          'advanced': [{'torch': enable}]
        });
        return true;
      }
    } catch (e) {
      debugPrint('Torch not supported on this browser/camera: $e');
    }
    return false;
  }

  /// Pick QR Code image from gallery/device storage
  Future<String?> pickQrImageFromGallery() async {
    final completer = Completer<String?>();
    final input = html.FileUploadInputElement()..accept = 'image/*';
    input.click();

    input.onChange.listen((event) {
      final files = input.files;
      if (files == null || files.isEmpty) {
        completer.complete(null);
        return;
      }
      final file = files[0];
      final reader = html.FileReader();
      reader.readAsDataUrl(file);
      reader.onLoadEnd.listen((e) {
        final result = reader.result as String?;
        completer.complete(result);
      });
      reader.onError.listen((e) {
        completer.complete(null);
      });
    });

    return completer.future;
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
        ..setAttribute('playsinline', 'true')
        ..setAttribute('webkit-playsinline', 'true')
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
      final audioCtx = web_audio.AudioContext();
      final osc = audioCtx.createOscillator();
      final gain = audioCtx.createGain();

      final now = audioCtx.currentTime ?? 0;
      osc.type = 'triangle';
      osc.frequency?.setValueAtTime(800, now);
      osc.frequency?.exponentialRampToValueAtTime(200, now + 0.08);

      gain.gain?.setValueAtTime(0.3, now);
      gain.gain?.exponentialRampToValueAtTime(0.01, now + 0.08);

      osc.connectNode(gain);
      if (audioCtx.destination != null) {
        gain.connectNode(audioCtx.destination!);
      }

      osc.start2(now);
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
