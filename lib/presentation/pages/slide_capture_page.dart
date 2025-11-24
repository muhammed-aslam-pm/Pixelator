import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';

import '../../domain/entities/slide_capture_entity.dart';
import '../../domain/services/alignment_calculator.dart';
import '../../domain/services/perspective_corrector.dart';
import '../cubit/slide_capture_cubit.dart';

class SlideCapturePageArgs {
  final int caseId;
  final String caseNo;

  const SlideCapturePageArgs({required this.caseId, required this.caseNo});
}

class SlideCapturePage extends StatelessWidget {
  final SlideCapturePageArgs args;

  const SlideCapturePage({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          SlideCaptureCubit(AlignmentCalculator(), PerspectiveCorrector())
            ..initializeCamera(),
      child: _SlideCaptureView(args: args),
    );
  }
}

class _SlideCaptureView extends StatelessWidget {
  final SlideCapturePageArgs args;

  const _SlideCaptureView({required this.args});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocConsumer<SlideCaptureCubit, SlideCaptureState>(
        listener: (context, state) {
          if (state is SlideCaptureError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                action: SnackBarAction(
                  label: 'Retry',
                  textColor: Colors.white,
                  onPressed: () {
                    context.read<SlideCaptureCubit>().retryCapture();
                  },
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is SlideCaptureLoading || state is SlideCaptureInitial) {
            return _buildLoadingView();
          } else if (state is SlideCameraReady ||
              state is SlideAligning ||
              state is SlideCaptureProcessing ||
              state is SlideCaptureCaptured) {
            return _buildCameraView(context, state);
          } else {
            return _buildErrorView(context);
          }
        },
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF4299E1)),
          SizedBox(height: 16),
          Text(
            'Initializing camera...',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 64),
          const SizedBox(height: 16),
          const Text(
            'Camera Error',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.read<SlideCaptureCubit>().initializeCamera();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4299E1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraView(BuildContext context, SlideCaptureState state) {
    CameraController? controller;
    SlideAlignmentData? alignmentData;
    CapturedSlide? capturedSlide;

    if (state is SlideCameraReady) {
      controller = state.cameraController;
    } else if (state is SlideAligning) {
      controller = state.cameraController;
      alignmentData = state.alignmentData;
    } else if (state is SlideCaptureProcessing) {
      controller = state.cameraController;
    } else if (state is SlideCaptureCaptured) {
      controller = state.cameraController;
      capturedSlide = state.capturedSlide;
    }

    if (controller == null || !controller.value.isInitialized) {
      return _buildLoadingView();
    }

    return Stack(
      children: [
        // Camera Preview
        Positioned.fill(child: CameraPreview(controller)),

        // Grid Overlay
        if (capturedSlide == null) _buildGridOverlay(),

        // Target Rectangle
        if (capturedSlide == null) _buildTargetRectangle(alignmentData?.status),

        // Alignment Indicator
        if (alignmentData != null && capturedSlide == null)
          _buildAlignmentIndicator(alignmentData),

        // Feedback Message
        if (alignmentData != null && capturedSlide == null)
          _buildFeedbackMessage(alignmentData),

        // Processing Overlay
        if (state is SlideCaptureProcessing) _buildProcessingOverlay(),

        // Captured Preview
        if (capturedSlide != null) _buildCapturedPreview(capturedSlide),

        // Top Bar
        _buildTopBar(context),

        // Bottom Controls
        if (capturedSlide == null) _buildBottomControls(context, state),
      ],
    );
  }

  Widget _buildGridOverlay() {
    return Positioned.fill(child: CustomPaint(painter: GridPainter()));
  }

  Widget _buildTargetRectangle(AlignmentStatus? status) {
    Color borderColor = Colors.white.withOpacity(0.5);
    if (status != null) {
      switch (status) {
        case AlignmentStatus.aligned:
          borderColor = const Color(0xFF34D399);
          break;
        case AlignmentStatus.nearlyAligned:
          borderColor = const Color(0xFFFCD34D);
          break;
        case AlignmentStatus.misaligned:
          borderColor = const Color(0xFFEF4444);
          break;
      }
    }

    // Landscape rectangle for microscope slides (wider than tall)
    // In portrait mode, this will be horizontally oriented
    return Center(
      child: Container(
        width: 320, // Wider
        height: 180, // Shorter - landscape aspect ratio
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: 3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            // Corner indicators
            _buildCornerIndicator(Alignment.topLeft, borderColor),
            _buildCornerIndicator(Alignment.topRight, borderColor),
            _buildCornerIndicator(Alignment.bottomLeft, borderColor),
            _buildCornerIndicator(Alignment.bottomRight, borderColor),

            // Center crosshair
            Center(
              child: Icon(
                Icons.center_focus_weak,
                color: borderColor,
                size: 48,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCornerIndicator(Alignment alignment, Color color) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }

  Widget _buildAlignmentIndicator(SlideAlignmentData alignmentData) {
    Color indicatorColor;
    IconData icon;

    switch (alignmentData.status) {
      case AlignmentStatus.aligned:
        indicatorColor = const Color(0xFF34D399);
        icon = Icons.check_circle;
        break;
      case AlignmentStatus.nearlyAligned:
        indicatorColor = const Color(0xFFFCD34D);
        icon = Icons.warning;
        break;
      case AlignmentStatus.misaligned:
        indicatorColor = const Color(0xFFEF4444);
        icon = Icons.error;
        break;
    }

    return Positioned(
      top: 100,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Icon(icon, color: indicatorColor, size: 40),
        ),
      ),
    );
  }

  Widget _buildFeedbackMessage(SlideAlignmentData alignmentData) {
    return Positioned(
      bottom: 120,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                alignmentData.feedbackMessage,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Tilt: ${alignmentData.totalTilt.toStringAsFixed(1)}° | Stable: ${alignmentData.isStable ? "Yes" : "No"}',
                style: const TextStyle(color: Color(0xFFA0AEC0), fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProcessingOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.7),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Color(0xFF4299E1)),
              SizedBox(height: 16),
              Text(
                'Processing image...',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCapturedPreview(CapturedSlide capturedSlide) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.9),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              constraints: const BoxConstraints(maxHeight: 400),
              child: Image.file(
                File(capturedSlide.filePath),
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 24),
            const Icon(Icons.check_circle, color: Color(0xFF34D399), size: 64),
            const SizedBox(height: 16),
            const Text(
              'Slide Captured Successfully!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tilt: ${capturedSlide.tiltAtCapture.toStringAsFixed(1)}°',
              style: const TextStyle(color: Color(0xFFA0AEC0), fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black.withOpacity(0.7), Colors.transparent],
            ),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Capture Biopsy Slide',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Case: ${args.caseNo}',
                      style: const TextStyle(
                        color: Color(0xFFA0AEC0),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.info_outline, color: Colors.white),
                onPressed: () => _showInstructions(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls(BuildContext context, SlideCaptureState state) {
    final isProcessing = state is SlideCaptureProcessing;
    final cubit = context.read<SlideCaptureCubit>();

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Colors.black.withOpacity(0.7), Colors.transparent],
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControlButton(
                icon: Icons.flip_camera_android,
                label: 'Flip',
                onPressed: isProcessing
                    ? null
                    : () {
                        cubit.switchCamera();
                      },
              ),
              _buildCaptureButton(context, isProcessing),
              _buildControlButton(
                icon: Icons.flash_auto,
                label: 'Flash',
                onPressed: isProcessing
                    ? null
                    : () {
                        // Flash toggle will be implemented if needed
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Flash control coming soon'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    VoidCallback? onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon, color: Colors.white),
          iconSize: 28,
          onPressed: onPressed,
        ),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }

  Widget _buildCaptureButton(BuildContext context, bool isProcessing) {
    return GestureDetector(
      onTap: isProcessing
          ? null
          : () {
              context.read<SlideCaptureCubit>().captureImage();
            },
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
          color: isProcessing
              ? Colors.grey.withOpacity(0.5)
              : Colors.white.withOpacity(0.3),
        ),
        child: isProcessing
            ? const Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            : const Icon(Icons.camera, color: Colors.white, size: 32),
      ),
    );
  }

  void _showInstructions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D3748),
        title: const Text(
          'Capture Instructions',
          style: TextStyle(color: Color(0xFF4299E1)),
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '1. Position the slide within the target rectangle',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 8),
              Text(
                '2. Hold device parallel to the slide',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 8),
              Text(
                '3. Wait for alignment indicator to turn green',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 8),
              Text(
                '4. Keep steady - auto-capture will trigger',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 8),
              Text(
                '5. Or tap the capture button manually',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..strokeWidth = 1;

    // Draw vertical lines
    for (int i = 1; i < 3; i++) {
      final x = size.width * i / 3;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw horizontal lines
    for (int i = 1; i < 3; i++) {
      final y = size.height * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
