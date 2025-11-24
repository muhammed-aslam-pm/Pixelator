import 'dart:math';
import '../entities/slide_capture_entity.dart';

class AlignmentCalculator {
  static const double _alignedThreshold = 5.0; // degrees
  static const double _nearlyAlignedThreshold = 10.0; // degrees
  static const double _stabilityThreshold = 2.0; // degrees change
  static const int _stabilitySamples = 5;

  final List<double> _tiltHistory = [];

  SlideAlignmentData calculateAlignment(double x, double y, double z) {
    // Calculate tilt angles in degrees
    final tiltX = _calculateTiltX(x, y, z);
    final tiltY = _calculateTiltY(x, y, z);
    final totalTilt = sqrt(tiltX * tiltX + tiltY * tiltY);

    // Track stability
    _tiltHistory.add(totalTilt);
    if (_tiltHistory.length > _stabilitySamples) {
      _tiltHistory.removeAt(0);
    }

    final isStable = _isStable();
    final status = _getAlignmentStatus(totalTilt);
    final feedbackMessage = _getFeedbackMessage(status, isStable, tiltX, tiltY);

    return SlideAlignmentData(
      tiltX: tiltX,
      tiltY: tiltY,
      totalTilt: totalTilt,
      status: status,
      isStable: isStable,
      feedbackMessage: feedbackMessage,
    );
  }

  double _calculateTiltX(double x, double y, double z) {
    return atan2(x, sqrt(y * y + z * z)) * 180 / pi;
  }

  double _calculateTiltY(double x, double y, double z) {
    return atan2(y, sqrt(x * x + z * z)) * 180 / pi;
  }

  AlignmentStatus _getAlignmentStatus(double totalTilt) {
    if (totalTilt <= _alignedThreshold) {
      return AlignmentStatus.aligned;
    } else if (totalTilt <= _nearlyAlignedThreshold) {
      return AlignmentStatus.nearlyAligned;
    } else {
      return AlignmentStatus.misaligned;
    }
  }

  bool _isStable() {
    if (_tiltHistory.length < _stabilitySamples) {
      return false;
    }

    final max = _tiltHistory.reduce((a, b) => a > b ? a : b);
    final min = _tiltHistory.reduce((a, b) => a < b ? a : b);
    return (max - min) <= _stabilityThreshold;
  }

  String _getFeedbackMessage(
    AlignmentStatus status,
    bool isStable,
    double tiltX,
    double tiltY,
  ) {
    if (status == AlignmentStatus.aligned && isStable) {
      return 'Perfect! Auto-capturing...';
    } else if (status == AlignmentStatus.aligned) {
      return 'Good alignment. Hold steady...';
    } else if (status == AlignmentStatus.nearlyAligned) {
      final direction = _getTiltDirection(tiltX, tiltY);
      return 'Almost there. Adjust $direction';
    } else {
      final direction = _getTiltDirection(tiltX, tiltY);
      return 'Align device $direction';
    }
  }

  String _getTiltDirection(double tiltX, double tiltY) {
    if (tiltX.abs() > tiltY.abs()) {
      return tiltX > 0 ? 'left' : 'right';
    } else {
      return tiltY > 0 ? 'down' : 'up';
    }
  }

  void reset() {
    _tiltHistory.clear();
  }
}
