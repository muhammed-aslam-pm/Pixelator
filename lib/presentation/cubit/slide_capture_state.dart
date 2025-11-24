part of 'slide_capture_cubit.dart';

abstract class SlideCaptureState extends Equatable {
  const SlideCaptureState();

  @override
  List<Object?> get props => [];
}

class SlideCaptureInitial extends SlideCaptureState {}

class SlideCaptureLoading extends SlideCaptureState {}

class SlideCameraReady extends SlideCaptureState {
  final CameraController cameraController;

  const SlideCameraReady(this.cameraController);

  @override
  List<Object?> get props => [cameraController];
}

class SlideAligning extends SlideCaptureState {
  final CameraController cameraController;
  final SlideAlignmentData alignmentData;

  const SlideAligning(this.cameraController, this.alignmentData);

  @override
  List<Object?> get props => [cameraController, alignmentData];
}

class SlideCaptureProcessing extends SlideCaptureState {
  final CameraController cameraController;

  const SlideCaptureProcessing(this.cameraController);

  @override
  List<Object?> get props => [cameraController];
}

class SlideCaptureCaptured extends SlideCaptureState {
  final CameraController cameraController;
  final CapturedSlide capturedSlide;

  const SlideCaptureCaptured(this.cameraController, this.capturedSlide);

  @override
  List<Object?> get props => [cameraController, capturedSlide];
}

class SlideCaptureError extends SlideCaptureState {
  final String message;

  const SlideCaptureError(this.message);

  @override
  List<Object?> get props => [message];
}
