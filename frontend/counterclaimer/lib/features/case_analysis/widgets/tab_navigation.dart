import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/legal_arguments_screen.dart';

class TabNavigation extends ConsumerWidget {
  final int selectedTab;

  const TabNavigation({
    super.key,
    required this.selectedTab,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: Colors.white,
      child: Row(
        children: [
          _buildTab(context, ref, 0, 'Our Strengths', selectedTab),
          _buildTab(context, ref, 1, 'Potential Weaknesses', selectedTab),
        ],
      ),
    );
  }

  Widget _buildTab(BuildContext context, WidgetRef ref, int index, String title, int selectedTab) {
    final isSelected = selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => ref.read(selectedTabProvider.notifier).state = index,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? const Color(0xFF3B82F6) : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFF6B7280),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}