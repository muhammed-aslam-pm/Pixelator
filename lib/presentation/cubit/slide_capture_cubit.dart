import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:camera/camera.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:vibration/vibration.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../../domain/entities/slide_capture_entity.dart';
import '../../domain/services/alignment_calculator.dart';
import '../../domain/services/perspective_corrector.dart';

part 'slide_capture_state.dart';

class SlideCaptureCubit extends Cubit<SlideCaptureState> {
  final AlignmentCalculator _alignmentCalculator;
  final PerspectiveCorrector _perspectiveCorrector;

  CameraController? _cameraController;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  Timer? _autoCaptureTimer;
  bool _isCapturing = false;
  List<CameraDescription> _availableCameras = [];
  int _currentCameraIndex = 0;

  SlideCaptureCubit(this._alignmentCalculator, this._perspectiveCorrector)
    : super(SlideCaptureInitial());

  Future<void> initializeCamera() async {
    try {
      emit(SlideCaptureLoading());

      _availableCameras = await availableCameras();

      // Find back camera
      _currentCameraIndex = _availableCameras.indexWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
      );

      if (_currentCameraIndex == -1) {
        _currentCameraIndex = 0;
      }

      await _initializeCurrentCamera();
    } catch (e) {
      emit(SlideCaptureError('Failed to initialize camera: ${e.toString()}'));
    }
  }

  Future<void> _initializeCurrentCamera() async {
    if (_availableCameras.isEmpty) {
      throw Exception('No cameras available');
    }

    // Dispose previous controller if exists
    await _cameraController?.dispose();

    _cameraController = CameraController(
      _availableCameras[_currentCameraIndex],
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await _cameraController!.initialize();

    if (!isClosed) {
      emit(SlideCameraReady(_cameraController!));
      _startAccelerometerListening();
    }
  }

  Future<void> switchCamera() async {
    try {
      if (_availableCameras.length < 2) {
        return;
      }

      _cancelAutoCapture();
      _accelerometerSubscription?.cancel();

      _currentCameraIndex =
          (_currentCameraIndex + 1) % _availableCameras.length;

      emit(SlideCaptureLoading());
      await _initializeCurrentCamera();
    } catch (e) {
      emit(SlideCaptureError('Failed to switch camera: ${e.toString()}'));
      if (_cameraController != null && _cameraController!.value.isInitialized) {
        emit(SlideCameraReady(_cameraController!));
      }
    }
  }

  void _startAccelerometerListening() {
    _accelerometerSubscription = accelerometerEventStream().listen(
      (AccelerometerEvent event) {
        if (state is! SlideCameraReady && state is! SlideAligning) {
          return;
        }

        if (_cameraController == null ||
            !_cameraController!.value.isInitialized) {
          return;
        }

        final alignment = _alignmentCalculator.calculateAlignment(
          event.x,
          event.y,
          event.z,
        );

        emit(SlideAligning(_cameraController!, alignment));

        // Handle vibration feedback
        _handleVibrationFeedback(alignment.status);

        // Auto-capture when aligned and stable
        if (alignment.status == AlignmentStatus.aligned &&
            alignment.isStable &&
            !_isCapturing) {
          _scheduleAutoCapture();
        } else {
          _cancelAutoCapture();
        }
      },
      onError: (error) {
        // Ignore accelerometer errors and continue
      },
      cancelOnError: false,
    );
  }

  void _handleVibrationFeedback(AlignmentStatus status) async {
    final hasVibrator = await Vibration.hasVibrator() ?? false;
    if (!hasVibrator) return;

    switch (status) {
      case AlignmentStatus.aligned:
        // Single short vibration for aligned
        Vibration.vibrate(duration: 50);
        break;
      case AlignmentStatus.nearlyAligned:
        // No vibration for nearly aligned
        break;
      case AlignmentStatus.misaligned:
        // No vibration for misaligned
        break;
    }
  }

  void _scheduleAutoCapture() {
    if (_autoCaptureTimer != null && _autoCaptureTimer!.isActive) {
      return;
    }

    _autoCaptureTimer = Timer(const Duration(milliseconds: 500), () {
      captureImage();
    });
  }

  void _cancelAutoCapture() {
    _autoCaptureTimer?.cancel();
    _autoCaptureTimer = null;
  }

  Future<void> captureImage() async {
    if (_isCapturing ||
        _cameraController == null ||
        !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      _isCapturing = true;
      _cancelAutoCapture(); // Cancel any pending auto-capture

      emit(SlideCaptureProcessing(_cameraController!));

      // Small delay to ensure UI updates
      await Future.delayed(const Duration(milliseconds: 100));

      // Capture image
      final image = await _cameraController!.takePicture();

      // Get alignment data
      final currentState = state;
      double tiltAtCapture = 0.0;
      if (currentState is SlideAligning) {
        tiltAtCapture = currentState.alignmentData.totalTilt;
      }

      // Apply perspective correction
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final correctedPath = path.join(
        directory.path,
        'slide_corrected_$timestamp.jpg',
      );

      final finalPath = await _perspectiveCorrector.correctPerspective(
        image.path,
        correctedPath,
      );

      // Vibrate on successful capture
      final hasVibrator = await Vibration.hasVibrator() ?? false;
      if (hasVibrator) {
        Vibration.vibrate(duration: 200, amplitude: 128);
      }

      final capturedSlide = CapturedSlide(
        filePath: finalPath,
        capturedAt: DateTime.now(),
        tiltAtCapture: tiltAtCapture,
        isPerspectiveCorrected: true,
      );

      emit(SlideCaptureCaptured(_cameraController!, capturedSlide));

      // Wait a moment before returning to ready state
      // await Future.delayed(const Duration(seconds: 2));

      // if (_cameraController != null && _cameraController!.value.isInitialized) {
      //   emit(SlideCameraReady(_cameraController!));
      // }
    } catch (e) {
      emit(SlideCaptureError('Failed to capture image: ${e.toString()}'));
      if (_cameraController != null && _cameraController!.value.isInitialized) {
        emit(SlideCameraReady(_cameraController!));
      }
    } finally {
      _isCapturing = false;
    }
  }

  Future<void> retryCapture() async {
    if (_cameraController != null) {
      _alignmentCalculator.reset();
      emit(SlideCameraReady(_cameraController!));
    } else {
      await initializeCamera();
    }
  }

  @override
  Future<void> close() {
    _accelerometerSubscription?.cancel();
    _autoCaptureTimer?.cancel();
    _cameraController?.dispose();
    return super.close();
  }
}
