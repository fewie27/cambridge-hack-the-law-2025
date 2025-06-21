import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:counterclaimer/core/theme/colors.dart';

class ArgumentsHeader extends ConsumerWidget {
  final String searchQuery;

  const ArgumentsHeader({
    super.key,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 30, 24, 20), // Reduced top padding from 60 to 30
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Stats Row - Jus Mundi Style (without Add to Alerts)
          Row(
            children: [
              _buildJusMundiStatIcon(
                Icons.auto_graph_rounded,
                'Strengths',
                '5',
                AppColors.primaryGreen,
              ),
              const SizedBox(width: 32),
              _buildJusMundiStatIcon(
                Icons.error_outline_rounded,
                'Weaknesses',
                '5',
                AppColors.weaknessRed,
              ),
              const SizedBox(width: 32),
              _buildJusMundiStatIcon(
                Icons.gavel_rounded,
                'Cases',
                '18',
                AppColors.casesGrey,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJusMundiStatIcon(
      IconData icon, String label, String count, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
                border: Border.all(color: color, width: 1.5),
              ),
              child: Center(
                child: Icon(icon, color: color, size: 18),
              ),
            ),
            Positioned(
              top: -8,
              right: -8,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  count,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF4B5563),
          ),
        ),
      ],
    );
  }
}