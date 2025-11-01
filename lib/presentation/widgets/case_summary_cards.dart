import 'package:flutter/material.dart';

class CaseSummaryCards extends StatelessWidget {
  final int totalCases;
  final int activeCases;
  final int pendingCases;
  final int completedCases;

  const CaseSummaryCards({
    super.key,
    required this.totalCases,
    required this.activeCases,
    required this.pendingCases,
    required this.completedCases,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    if (isMobile) {
      // Mobile: 2x2 grid
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  title: 'Total Cases',
                  value: totalCases.toString(),
                  icon: Icons.description_outlined,
                  color: const Color(0xFF4299E1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  title: 'Active Cases',
                  value: activeCases.toString(),
                  icon: Icons.check_circle_outline,
                  color: const Color(0xFF48BB78),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  title: 'Pending Cases',
                  value: pendingCases.toString(),
                  icon: Icons.access_time_outlined,
                  color: const Color(0xFFED8936),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  title: 'Completed Cases',
                  value: completedCases.toString(),
                  icon: Icons.auto_awesome_outlined,
                  color: const Color(0xFF805AD5),
                ),
              ),
            ],
          ),
        ],
      );
    }
    
    // Desktop: Horizontal row
    return Row(
      children: [
        Expanded(child: _SummaryCard(
          title: 'Total Cases',
          value: totalCases.toString(),
          icon: Icons.description_outlined,
          color: const Color(0xFF4299E1),
        )),
        const SizedBox(width: 12),
        Expanded(child: _SummaryCard(
          title: 'Active Cases',
          value: activeCases.toString(),
          icon: Icons.check_circle_outline,
          color: const Color(0xFF48BB78),
        )),
        const SizedBox(width: 12),
        Expanded(child: _SummaryCard(
          title: 'Pending Cases',
          value: pendingCases.toString(),
          icon: Icons.access_time_outlined,
          color: const Color(0xFFED8936),
        )),
        const SizedBox(width: 12),
        Expanded(child: _SummaryCard(
          title: 'Completed Cases',
          value: completedCases.toString(),
          icon: Icons.auto_awesome_outlined,
          color: const Color(0xFF805AD5),
        )),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D3748),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Icon(icon, color: color, size: 24),
              ),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    value,
                    style: TextStyle(
                      color: color,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
