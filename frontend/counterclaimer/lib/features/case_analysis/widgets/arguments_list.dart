import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/legal_arguments_screen.dart';
import 'argument_card.dart';

class ArgumentsList extends ConsumerWidget {
  final int selectedTab;

  const ArgumentsList({
    super.key,
    required this.selectedTab,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final arguments = selectedTab == 0 ? ourStrengths : opponentWeaknesses;
    
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Icon(
                  selectedTab == 0 ? Icons.trending_up : Icons.warning_amber,
                  color: selectedTab == 0 ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  selectedTab == 0 ? 'Our Case Strengths' : 'Potential Weaknesses to Address',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.tune, size: 16, color: Color(0xFF6B7280)),
                      const SizedBox(width: 8),
                      const Text('Filters', style: TextStyle(color: Color(0xFF6B7280))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Arguments List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: arguments.length,
              itemBuilder: (context, index) {
                final argument = arguments[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ArgumentCard(argument: argument),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

