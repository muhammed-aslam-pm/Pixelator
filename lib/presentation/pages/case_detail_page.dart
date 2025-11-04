import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../cubit/case_media_cubit.dart';

import '../../core/di/injection_container.dart' as di;
import '../../domain/entities/case_entity.dart';
import '../cubit/case_detail_cubit.dart';

class CaseDetailPage extends StatelessWidget {
  final int caseId;

  const CaseDetailPage({super.key, required this.caseId});

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return const Color(0xFFEF4444); // Critical - Red
      case 2:
        return const Color(0xFFFB923C); // High - Orange
      case 3:
        return const Color(0xFFFCD34D); // Medium - Yellow
      case 4:
        return const Color(0xFF60A5FA); // Low - Blue
      case 5:
        return const Color(0xFF34D399); // Very Low - Green
      default:
        return const Color(0xFF9CA3AF); // Gray
    }
  }

  String _getPriorityText(int priority) {
    switch (priority) {
      case 1:
        return 'Critical';
      case 2:
        return 'High';
      case 3:
        return 'Medium';
      case 4:
        return 'Low';
      case 5:
        return 'Very Low';
      default:
        return 'Unknown';
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFFA0AEC0),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D3748),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF4A5568), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF4299E1),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CaseDetailCubit(di.sl())..getCaseById(caseId),
      child: Scaffold(
        backgroundColor: const Color(0xFF1A202C),
        appBar: AppBar(
          backgroundColor: const Color(0xFF2D3748),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Case Details',
            style: TextStyle(
              color: Color(0xFF4299E1),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: BlocBuilder<CaseDetailCubit, CaseDetailState>(
          builder: (context, state) {
            if (state is CaseDetailLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Color(0xFF4299E1)),
                ),
              );
            } else if (state is CaseDetailError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<CaseDetailCubit>().getCaseById(caseId);
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            } else if (state is CaseDetailLoaded) {
              return _buildDetailView(state.caseEntity);
            } else {
              return const Center(
                child: Text(
                  'No data available',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildDetailView(CaseEntity caseEntity) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Case Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2D3748),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF4A5568), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            caseEntity.caseName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            caseEntity.caseNo,
                            style: const TextStyle(
                              color: Color(0xFFA0AEC0),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getPriorityColor(caseEntity.priority),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _getPriorityText(caseEntity.priority),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: caseEntity.status == 'active'
                        ? const Color(0xFF34D399).withOpacity(0.1)
                        : const Color(0xFFFCD34D).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    caseEntity.status.toUpperCase(),
                    style: TextStyle(
                      color: caseEntity.status == 'active'
                          ? const Color(0xFF34D399)
                          : const Color(0xFFFCD34D),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Case Information
          _buildDetailCard('Case Information', [
            _buildDetailRow('Case ID', caseEntity.caseId.toString()),
            _buildDetailRow('Case UUID', caseEntity.caseUuid),
            _buildDetailRow(
              'Case Description',
              caseEntity.caseDescription.isEmpty
                  ? 'N/A'
                  : caseEntity.caseDescription,
            ),
          ]),

          // Patient Information
          _buildDetailCard('Patient Information', [
            _buildDetailRow('Patient ID', caseEntity.patientId),
            _buildDetailRow('Hospital', caseEntity.hospitalName),
            _buildDetailRow('Site', caseEntity.site),
          ]),

          // Medical Information
          _buildDetailCard('Medical Information', [
            _buildDetailRow('Specialization', caseEntity.specialization),
            _buildDetailRow('Priority', _getPriorityText(caseEntity.priority)),
            _buildDetailRow('Status', caseEntity.status),
          ]),

          // Files & Media
          _buildDetailCard('Files & Media', [
            _buildDetailRow('Slides Count', caseEntity.slidesCount.toString()),
            _buildDetailRow(
              'Media Files',
              caseEntity.mediaFilesCount.toString(),
            ),
            _buildDetailRow(
              'Total File Size',
              '${caseEntity.totalFileSizeMb} MB',
            ),
          ]),

          // Media Library
          _buildDetailCard('Media Library', [
            BlocProvider(
              create: (_) =>
                  CaseMediaCubit(di.sl(), di.sl(), di.sl(), di.sl(), di.sl())
                    ..fetch(caseEntity.caseId),
              child: CaseMediaSection(caseId: caseEntity.caseId),
            ),
          ]),

          // Completion Information
          if (caseEntity.isCompleted)
            _buildDetailCard('Completion Information', [
              _buildDetailRow(
                'Completed At',
                _formatDateTime(caseEntity.completedAt),
              ),
              _buildDetailRow(
                'Completed By',
                caseEntity.completedBy?.toString() ?? 'N/A',
              ),
            ]),

          // Flag Information
          if (caseEntity.isFlagged)
            _buildDetailCard('Flag Information', [
              _buildDetailRow('Flag Reason', caseEntity.flagReason ?? 'N/A'),
              _buildDetailRow(
                'Flagged At',
                _formatDateTime(caseEntity.flaggedAt),
              ),
              _buildDetailRow(
                'Flagged By',
                caseEntity.flaggedBy?.toString() ?? 'N/A',
              ),
            ]),

          // Opinion Information
          if (caseEntity.hasOpinion)
            _buildDetailCard('Opinion Information', [
              _buildDetailRow('Opinion', caseEntity.opinion ?? 'N/A'),
              _buildDetailRow(
                'Added At',
                _formatDateTime(caseEntity.opinionAddedAt),
              ),
              _buildDetailRow(
                'Added By',
                caseEntity.opinionAddedBy?.toString() ?? 'N/A',
              ),
            ]),

          // Archival Information
          if (caseEntity.archivalStatus)
            _buildDetailCard('Archival Information', [
              _buildDetailRow(
                'Archived At',
                _formatDateTime(caseEntity.archivedAt),
              ),
              _buildDetailRow(
                'Archived By',
                caseEntity.archivedBy?.toString() ?? 'N/A',
              ),
            ]),

          // Metadata
          _buildDetailCard('Metadata', [
            _buildDetailRow(
              'Created At',
              _formatDateTime(caseEntity.createdAt),
            ),
            _buildDetailRow('Created By', caseEntity.createdBy.toString()),
            _buildDetailRow(
              'Updated At',
              _formatDateTime(caseEntity.updatedAt),
            ),
            _buildDetailRow('Updated By', caseEntity.updatedBy.toString()),
            _buildDetailRow('Organization ID', caseEntity.orgId.toString()),
            _buildDetailRow('User ID', caseEntity.userId.toString()),
          ]),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class CaseMediaSection extends StatefulWidget {
  final int caseId;

  const CaseMediaSection({super.key, required this.caseId});

  @override
  State<CaseMediaSection> createState() => _CaseMediaSectionState();
}

class _CaseMediaSectionState extends State<CaseMediaSection> {
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _onUploadPressed() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2D3748),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.of(ctx).pop();
                    final XFile? photo = await _picker.pickImage(
                      source: ImageSource.camera,
                      imageQuality: 90,
                    );
                    if (photo != null) {
                      if (!mounted) return;
                      context.read<CaseMediaCubit>().uploadImages(
                        widget.caseId,
                        [photo],
                      );
                    }
                  },
                  icon: const Icon(Icons.photo_camera),
                  label: const Text('Camera'),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.of(ctx).pop();
                    final List<XFile> files = await _picker.pickMultiImage(
                      imageQuality: 90,
                    );
                    if (files.isNotEmpty) {
                      if (!mounted) return;
                      context.read<CaseMediaCubit>().uploadImages(
                        widget.caseId,
                        files,
                      );
                    }
                  },
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // All networking handled by cubit

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Images',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            ElevatedButton.icon(
              onPressed: _onUploadPressed,
              icon: const Icon(Icons.cloud_upload),
              label: const Text('Upload'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        BlocBuilder<CaseMediaCubit, CaseMediaState>(
          builder: (context, mediaState) {
            if (mediaState.loading) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Color(0xFF4299E1)),
                  ),
                ),
              );
            }

            if (mediaState.items.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'No media uploaded yet.',
                  style: TextStyle(color: Color(0xFFA0AEC0)),
                ),
              );
            }

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: mediaState.items.length,
              itemBuilder: (context, index) {
                final item = mediaState.items[index];
                final String? url = item.s3Url;

                return Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF4A5568),
                          width: 1,
                        ),
                        color: const Color(0xFF1A202C),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: url == null
                          ? const Center(
                              child: Icon(
                                Icons.image_not_supported,
                                color: Color(0xFFA0AEC0),
                              ),
                            )
                          : Image.network(url, fit: BoxFit.cover),
                    ),
                    // Delete button overlay
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => _showDeleteConfirmation(
                          context,
                          widget.caseId,
                          item.mediaFileId,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
        BlocBuilder<CaseMediaCubit, CaseMediaState>(
          builder: (context, mediaState) {
            if (mediaState.progress.isEmpty) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const Text(
                  'Uploads',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ...mediaState.progress.entries.map(
                  (e) => _buildProgressRow(e.key, e.value),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildProgressRow(String id, double progress) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          const Icon(Icons.image, color: Color(0xFFA0AEC0), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: const Color(0xFF2D3748),
                valueColor: const AlwaysStoppedAnimation(Color(0xFF4299E1)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 40,
            child: Text(
              '${(progress * 100).toStringAsFixed(0)}%',
              style: const TextStyle(color: Colors.white, fontSize: 12),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    int caseId,
    int mediaFileId,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF2D3748),
        title: const Text(
          'Delete Media',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to delete this media file?',
          style: TextStyle(color: Color(0xFFA0AEC0)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<CaseMediaCubit>().deleteMediaFile(
                caseId,
                mediaFileId,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
