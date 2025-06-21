import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/legal_arguments_screen.dart';
import 'package:counterclaimer/core/theme/colors.dart';

class ArgumentDetail extends ConsumerWidget {
  final LegalArgument argument;

  const ArgumentDetail({
    super.key,
    required this.argument,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Determine color based on argument type (same logic as ArgumentCard)
    Color argumentColor;
    if (argument.id.startsWith('w')) {
      // Weakness arguments (ids start with 'w')
      argumentColor = const Color(0xFFD67B7B); // Red for weaknesses
    } else {
      // Strength arguments
      argumentColor = const Color(0xFF678D7F); // Green for strengths
    }

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: const Color(0xFFE5E7EB))),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => ref.read(selectedArgumentProvider.notifier).state = null,
                  child: const Icon(Icons.arrow_back, color: Color(0xFF6B7280)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        argument.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        argument.category,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  Text(
                    'Overview',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    argument.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                      height: 1.5,
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Supporting Cases with dynamic color title
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 20,
                        decoration: BoxDecoration(
                          color: argumentColor, // Dynamic color
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Supporting Precedent Cases',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: argumentColor, // Dynamic color
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  ...argument.precedentCases.map((precedentCase) => 
                    _buildPrecedentCaseCard(precedentCase, argumentColor),
                  ).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrecedentCaseCard(PrecedentCase precedentCase, Color argumentColor) {
    return Container(
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
                color: argumentColor, // Dynamic color
              ),
            ),
            
            // Main content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Year badge and case number with dynamic color
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: argumentColor.withOpacity(0.1), // Dynamic color
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: argumentColor.withOpacity(0.3), // Dynamic color
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            precedentCase.year,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: argumentColor, // Dynamic color
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          precedentCase.caseNumber,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Case Name (main title) with dynamic color
                    Text(
                      precedentCase.caseName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: argumentColor, // Dynamic color instead of fixed green
                        height: 1.4,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Relevant Holding
                    Text(
                      precedentCase.relevantHolding,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textMedium,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 6),
                    
                    // Citation
                    Text(
                      precedentCase.citation,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textLight,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}