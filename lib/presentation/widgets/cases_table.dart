import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/case_entity.dart';

class CasesTable extends StatelessWidget {
  final List<CaseEntity> cases;
  final int currentPage;
  final int pageSize;
  final int totalPages;
  final Function(int) onPageChanged;
  final Function(int) onPageSizeChanged;

  const CasesTable({
    super.key,
    required this.cases,
    required this.currentPage,
    required this.pageSize,
    required this.totalPages,
    required this.onPageChanged,
    required this.onPageSizeChanged,
  });

  String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return const Color(0xFFE53E3E);
      case 2:
        return const Color(0xFFED8936);
      case 3:
        return const Color(0xFFECC94B);
      case 4:
        return const Color(0xFF4299E1);
      case 5:
        return const Color(0xFF48BB78);
      default:
        return Colors.grey;
    }
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return const Color(0xFF4299E1);
      case 'inactive':
        return Colors.grey;
      case 'archived':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Cases (${cases.length})',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            PopupMenuButton<int>(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: const Color(0xFF2D3748),
              itemBuilder: (context) => [10, 20, 50, 100]
                  .map((size) => PopupMenuItem(
                        value: size,
                        child: Text(
                          '$size per page',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ))
                  .toList(),
              onSelected: onPageSizeChanged,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D3748),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$pageSize per page',
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_drop_down, color: Colors.white70, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Content: Cards for mobile, Table for desktop
        if (isMobile)
          _buildMobileList()
        else
          _buildDesktopTable(),
        const SizedBox(height: 16),
        // Pagination
        _buildPagination(),
      ],
    );
  }

  Widget _buildMobileList() {
    if (cases.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            'No cases found',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    return Column(
      children: cases.map((caseEntity) => _CaseCard(caseEntity: caseEntity)).toList(),
    );
  }

  Widget _buildDesktopTable() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2D3748),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(const Color(0xFF1A202C)),
          dataRowColor: WidgetStateProperty.resolveWith<Color>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.selected)) {
                return const Color(0xFF4299E1).withValues(alpha: 0.2);
              }
              return Colors.transparent;
            },
          ),
          columns: const [
            DataColumn(
              label: Text('CASE NAME', style: TextStyle(color: Colors.white70, fontSize: 12)),
            ),
            DataColumn(
              label: Text('CASE NUMBER', style: TextStyle(color: Colors.white70, fontSize: 12)),
            ),
            DataColumn(
              label: Text('HOSPITAL', style: TextStyle(color: Colors.white70, fontSize: 12)),
            ),
            DataColumn(
              label: Text('SPECIALIZATION', style: TextStyle(color: Colors.white70, fontSize: 12)),
            ),
            DataColumn(
              label: Text('PRIORITY', style: TextStyle(color: Colors.white70, fontSize: 12)),
            ),
            DataColumn(
              label: Text('STATUS', style: TextStyle(color: Colors.white70, fontSize: 12)),
            ),
            DataColumn(
              label: Text('CREATED', style: TextStyle(color: Colors.white70, fontSize: 12)),
            ),
            DataColumn(
              label: Text('ACTIONS', style: TextStyle(color: Colors.white70, fontSize: 12)),
            ),
          ],
          rows: cases.map((caseEntity) {
            return DataRow(
              cells: [
                DataCell(Text(caseEntity.caseName, style: const TextStyle(color: Colors.white))),
                DataCell(Text(caseEntity.caseNo, style: const TextStyle(color: Colors.white))),
                DataCell(Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(caseEntity.hospitalName, style: const TextStyle(color: Colors.white)),
                    Text(
                      'Patient: ${caseEntity.patientId}',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
                    ),
                  ],
                )),
                DataCell(Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(caseEntity.specialization, style: const TextStyle(color: Colors.white)),
                    Text(
                      caseEntity.site,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
                    ),
                  ],
                )),
                DataCell(Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: getPriorityColor(caseEntity.priority).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: getPriorityColor(caseEntity.priority),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    caseEntity.priorityText,
                    style: TextStyle(
                      color: getPriorityColor(caseEntity.priority),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )),
                DataCell(Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: getStatusColor(caseEntity.status).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    caseEntity.status.toUpperCase(),
                    style: TextStyle(
                      color: getStatusColor(caseEntity.status),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )),
                DataCell(Text(formatDate(caseEntity.createdAt), style: const TextStyle(color: Colors.white))),
                DataCell(Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.people_outline, size: 18),
                      color: Colors.white70,
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.flag_outlined, size: 18),
                      color: Colors.white70,
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      color: Colors.white70,
                      onPressed: () {},
                    ),
                  ],
                )),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white70),
          onPressed: currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
        ),
        const SizedBox(width: 8),
        Text(
          'Page $currentPage of $totalPages',
          style: const TextStyle(color: Colors.white70),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.chevron_right, color: Colors.white70),
          onPressed: currentPage < totalPages ? () => onPageChanged(currentPage + 1) : null,
        ),
      ],
    );
  }
}

// Mobile Case Card
class _CaseCard extends StatelessWidget {
  final CaseEntity caseEntity;

  const _CaseCard({required this.caseEntity});

  String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return const Color(0xFFE53E3E);
      case 2:
        return const Color(0xFFED8936);
      case 3:
        return const Color(0xFFECC94B);
      case 4:
        return const Color(0xFF4299E1);
      case 5:
        return const Color(0xFF48BB78);
      default:
        return Colors.grey;
    }
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return const Color(0xFF4299E1);
      case 'inactive':
        return Colors.grey;
      case 'archived':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D3748),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  caseEntity.caseName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: getStatusColor(caseEntity.status).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  caseEntity.status.toUpperCase(),
                  style: TextStyle(
                    color: getStatusColor(caseEntity.status),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Case Number
          Row(
            children: [
              const Icon(Icons.numbers, size: 16, color: Colors.white70),
              const SizedBox(width: 8),
              Text(
                caseEntity.caseNo,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Hospital & Patient
          Row(
            children: [
              const Icon(Icons.local_hospital, size: 16, color: Colors.white70),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${caseEntity.hospitalName} • Patient: ${caseEntity.patientId}',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Specialization
          Row(
            children: [
              const Icon(Icons.science, size: 16, color: Colors.white70),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${caseEntity.specialization} • ${caseEntity.site}',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Priority & Created Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: getPriorityColor(caseEntity.priority).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: getPriorityColor(caseEntity.priority),
                    width: 1,
                  ),
                ),
                child: Text(
                  caseEntity.priorityText,
                  style: TextStyle(
                    color: getPriorityColor(caseEntity.priority),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                formatDate(caseEntity.createdAt),
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.people_outline, size: 20),
                color: Colors.white70,
                onPressed: () {},
                tooltip: 'View',
              ),
              IconButton(
                icon: const Icon(Icons.flag_outlined, size: 20),
                color: Colors.white70,
                onPressed: () {},
                tooltip: 'Flag',
              ),
              IconButton(
                icon: const Icon(Icons.check_circle_outline, size: 20),
                color: Colors.white70,
                onPressed: () {},
                tooltip: 'Complete',
              ),
              IconButton(
                icon: const Icon(Icons.description_outlined, size: 20),
                color: Colors.white70,
                onPressed: () {},
                tooltip: 'Details',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
