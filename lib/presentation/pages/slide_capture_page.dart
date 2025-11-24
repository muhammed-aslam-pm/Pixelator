import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/entities/slide_capture_entity.dart';
import '../../domain/services/alignment_calculator.dart';
import '../../domain/services/perspective_corrector.dart';
import '../cubit/slide_capture_cubit.dart';
import '../cubit/case_media_cubit.dart';

class SlideCapturePageArgs {
  final int caseId;
  final String caseNo;

  const SlideCapturePageArgs({required this.caseId, required this.caseNo});
}

class SlideCapturePage extends StatefulWidget {
  final SlideCapturePageArgs args;

  const SlideCapturePage({super.key, required this.args});

  @override
  State<SlideCapturePage> createState() => _SlideCapturePageState();
}

class _SlideCapturePageState extends State<SlideCapturePage> {
  @override
  void initState() {
    super.initState();
    // Lock orientation to landscape
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    // Restore all orientations
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          SlideCaptureCubit(AlignmentCalculator(), PerspectiveCorrector())
            ..initializeCamera(),
      child: _SlideCaptureView(args: widget.args),
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
              state is SlideCaptureProcessing) {
            return _buildCameraView(context, state);
          } else if (state is SlideCaptureCaptured) {
            return _buildPreviewView(context, state.capturedSlide);
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

    if (state is SlideCameraReady) {
      controller = state.cameraController;
    } else if (state is SlideAligning) {
      controller = state.cameraController;
      alignmentData = state.alignmentData;
    } else if (state is SlideCaptureProcessing) {
      controller = state.cameraController;
    }

    if (controller == null || !controller.value.isInitialized) {
      return _buildLoadingView();
    }

    final isProcessing = state is SlideCaptureProcessing;

    return Stack(
      children: [
        // Camera Preview
        Positioned.fill(child: CameraPreview(controller)),

        // Grid Overlay
        _buildGridOverlay(),

        // Target Rectangle (Portrait in landscape mode)
        buildTargetRectangle(alignmentData?.status),

        // Alignment Indicator (Top Center)
        if (alignmentData != null) _buildAlignmentIndicator(alignmentData),

        // Feedback Message (Bottom)
        if (alignmentData != null) _buildFeedbackMessage(alignmentData),

        // Processing Overlay
        if (isProcessing) _buildProcessingOverlay(),

        // Top Bar
        _buildTopBar(context),

        // Right Side Controls
        _buildRightControls(context, isProcessing),
      ],
    );
  }

  Widget _buildGridOverlay() {
    return Positioned.fill(child: CustomPaint(painter: GridPainter()));
  }

  Widget buildTargetRectangle([AlignmentStatus? status]) {
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
    // Use 10:1 aspect ratio (e.g., width:600, height:60). Centered in preview
    return Center(
      child: Container(
        width:
            550, // You may want to use e.g. MediaQuery.of(context).size.width * 0.85
        height:
            200, // You may want to use e.g. MediaQuery.of(context).size.width * 0.085
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: 3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            _buildCornerIndicator(Alignment.topLeft, borderColor),
            _buildCornerIndicator(Alignment.topRight, borderColor),
            _buildCornerIndicator(Alignment.bottomLeft, borderColor),
            _buildCornerIndicator(Alignment.bottomRight, borderColor),
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
      top: 16,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Icon(icon, color: indicatorColor, size: 32),
        ),
      ),
    );
  }

  Widget _buildFeedbackMessage(SlideAlignmentData alignmentData) {
    return Positioned(
      bottom: 16,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                alignmentData.feedbackMessage,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'Tilt: ${alignmentData.totalTilt.toStringAsFixed(1)}° | Stable: ${alignmentData.isStable ? "Yes" : "No"}',
                style: const TextStyle(color: Color(0xFFA0AEC0), fontSize: 11),
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

  Widget _buildTopBar(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Capture Biopsy Slide',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Case: ${args.caseNo}',
                    style: const TextStyle(
                      color: Color(0xFFA0AEC0),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.help_outline, color: Colors.white),
                onPressed: () => _showInstructions(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRightControls(BuildContext context, bool isProcessing) {
    return Positioned(
      right: 0,
      top: 0,
      bottom: 0,
      child: SafeArea(
        child: Container(
          width: 80,
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [_buildCaptureButton(context, isProcessing)],
          ),
        ),
      ),
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
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
          color: isProcessing
              ? Colors.grey.withOpacity(0.5)
              : Colors.white.withOpacity(0.3),
        ),
        child: isProcessing
            ? const Padding(
                padding: EdgeInsets.all(14),
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            : const Icon(Icons.camera, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildPreviewView(BuildContext context, CapturedSlide capturedSlide) {
    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          // Image Preview
          Center(
            child: Image.file(
              File(capturedSlide.filePath),
              fit: BoxFit.contain,
            ),
          ),

          // Top Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Color(0xFF34D399),
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Preview',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Case: ${args.caseNo}',
                      style: const TextStyle(
                        color: Color(0xFFA0AEC0),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Action Buttons
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Retake Button
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            context.read<SlideCaptureCubit>().retryCapture();
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retake'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2D3748),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Continue Button
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _uploadImage(context, capturedSlide.filePath);
                          },
                          icon: const Icon(Icons.cloud_upload),
                          label: const Text('Continue'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4299E1),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Image Info Overlay
          Positioned(
            top: 80,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.straighten,
                        color: Color(0xFF4299E1),
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Tilt: ${capturedSlide.tiltAtCapture.toStringAsFixed(1)}°',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.crop,
                        color: Color(0xFF4299E1),
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        capturedSlide.isPerspectiveCorrected
                            ? 'Corrected'
                            : 'Original',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _uploadImage(BuildContext context, String filePath) async {
    // Show uploading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => WillPopScope(
        onWillPop: () async => false,
        child: const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Color(0xFF4299E1)),
                  SizedBox(height: 16),
                  Text('Uploading image...'),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    try {
      // Convert File to XFile for upload
      final xFile = XFile(filePath);

      // Try to get CaseMediaCubit from context
      final mediaCubit = context.read<CaseMediaCubit>();

      // Upload using existing media cubit
      await mediaCubit.uploadImages(args.caseId, [xFile]);

      // Close uploading dialog
      if (context.mounted) {
        Navigator.of(context).pop();

        // Close capture screen and return to case detail
        Navigator.of(context).pop();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Slide uploaded successfully!'),
            backgroundColor: Color(0xFF34D399),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Close uploading dialog
      if (context.mounted) {
        Navigator.of(context).pop();

        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
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
                '1. Hold phone horizontally (landscape)',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 8),
              Text(
                '2. Position the slide within the target rectangle',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 8),
              Text(
                '3. Hold device parallel to the slide',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 8),
              Text(
                '4. Wait for green indicator (aligned)',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 8),
              Text(
                '5. Auto-capture or tap button',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 8),
              Text(
                '6. Review and Continue to upload',
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
