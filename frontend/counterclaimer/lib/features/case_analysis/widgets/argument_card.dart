import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/legal_arguments_screen.dart';
import 'package:counterclaimer/core/theme/colors.dart';

class ArgumentCard extends ConsumerWidget {
  final LegalArgument argument;

  const ArgumentCard({
    super.key,
    required this.argument,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Determine bar color based on argument type
    Color barColor;
    if (argument.id.startsWith('w')) {
      // Weakness arguments (ids start with 'w')
      barColor = const Color(0xFFD67B7B); // Red for weaknesses
    } else {
      // Strength arguments
      barColor = const Color(0xFF678D7F); // Green for strengths
    }

    return GestureDetector(
      onTap: () => ref.read(selectedArgumentProvider.notifier).state = argument,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          border: Border(
            top: BorderSide(color: AppColors.borderLight.withOpacity(0.5), width: 0.5),
            bottom: BorderSide(color: AppColors.borderLight.withOpacity(0.5), width: 0.5),
          ),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Dynamic colored left border bar
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: barColor, // Dynamic color based on argument type
                ),
              ),
              
              // Main content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      // Left content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Category label (styled box with dynamic color)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: barColor.withOpacity(0.1), // Use dynamic color
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: barColor.withOpacity(0.3), // Use dynamic color
                                  width: 0.5,
                                ),
                              ),
                              child: Text(
                                argument.category,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: barColor, // Use dynamic color
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 8),
                            
                            // Description (now the main text)
                            Text(
                              argument.description,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textMedium,
                                height: 1.4,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      
                      // Right side - Folder icon
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Icon(
                          Icons.folder_outlined,
                          size: 20,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
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