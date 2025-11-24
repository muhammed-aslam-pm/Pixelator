import 'package:equatable/equatable.dart';

enum AlignmentStatus { aligned, nearlyAligned, misaligned }

class SlideAlignmentData extends Equatable {
  final double tiltX;
  final double tiltY;
  final double totalTilt;
  final AlignmentStatus status;
  final bool isStable;
  final String feedbackMessage;

  const SlideAlignmentData({
    required this.tiltX,
    required this.tiltY,
    required this.totalTilt,
    required this.status,
    required this.isStable,
    required this.feedbackMessage,
  });

  @override
  List<Object?> get props => [
    tiltX,
    tiltY,
    totalTilt,
    status,
    isStable,
    feedbackMessage,
  ];
}

class CapturedSlide extends Equatable {
  final String filePath;
  final DateTime capturedAt;
  final double tiltAtCapture;
  final bool isPerspectiveCorrected;

  const CapturedSlide({
    required this.filePath,
    required this.capturedAt,
    required this.tiltAtCapture,
    required this.isPerspectiveCorrected,
  });

  @override
  List<Object?> get props => [
    filePath,
    capturedAt,
    tiltAtCapture,
    isPerspectiveCorrected,
  ];
}
