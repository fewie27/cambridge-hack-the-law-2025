import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/legal_arguments_screen.dart';
import 'package:counterclaimer/core/theme/colors.dart';

class TabNavigation extends ConsumerWidget {
  final int selectedTab;

  const TabNavigation({
    super.key,
    required this.selectedTab,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strengths = ref.watch(strengthsProvider);
    final weaknesses = ref.watch(weaknessesProvider);
    
    return Container(
      color: AppColors.backgroundWhite,
      child: Row(
        children: [
          _buildTab(context, ref, 0, 'Our Strengths', selectedTab, strengths.length),
          _buildTab(context, ref, 1, 'Potential Weaknesses', selectedTab, weaknesses.length),
        ],
      ),
    );
  }

  Widget _buildTab(BuildContext context, WidgetRef ref, int index, String title, int selectedTab, int count) {
    final isSelected = selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          // Reset argument selection when changing tabs
          ref.read(selectedArgumentProvider.notifier).state = null;
          // Change tab
          ref.read(selectedTabProvider.notifier).state = index;
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? const Color(0xFF678D7F) : Colors.transparent, // Jus Mundi green
                width: 2,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? AppColors.textDark : AppColors.textMedium, // Updated colors
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  fontSize: 14, // Slightly smaller for cleaner look
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF678D7F) : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textMedium,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}