import 'package:flutter/material.dart';
import '../screens/legal_arguments_screen.dart';
import 'package:counterclaimer/core/theme/colors.dart';

class CaseDetailPopup extends StatelessWidget {
  final PrecedentCase precedentCase;
  final Color accentColor;

  const CaseDetailPopup({
    super.key,
    required this.precedentCase,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 600,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    // Case icon
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.gavel,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Case Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: accentColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            precedentCase.caseNumber,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Close button
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Color(0xFF6B7280)),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Case Name
                      _buildDetailSection(
                        'Case Name',
                        precedentCase.caseName,
                        isTitle: true,
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Year and Court
                      Row(
                        children: [
                          Expanded(
                            child: _buildDetailSection(
                              'Year',
                              precedentCase.year,
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: _buildDetailSection(
                              'Court',
                              precedentCase.court,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Case Number
                      if (precedentCase.caseNumber.isNotEmpty && precedentCase.caseNumber != 'N/A')
                        _buildDetailSection(
                          'Case Number',
                          precedentCase.caseNumber,
                          isMonospace: true,
                        ),
                      
                      if (precedentCase.caseNumber.isNotEmpty && precedentCase.caseNumber != 'N/A')
                        const SizedBox(height: 24),
                      
                      // Status
                      if (precedentCase.status.isNotEmpty && precedentCase.status != 'N/A')
                        _buildDetailSection(
                          'Status',
                          precedentCase.status,
                        ),
                      
                      if (precedentCase.status.isNotEmpty && precedentCase.status != 'N/A')
                        const SizedBox(height: 24),
                      
                      // Institution
                      if (precedentCase.institution.isNotEmpty && precedentCase.institution != 'N/A')
                        _buildDetailSection(
                          'Institution',
                          precedentCase.institution,
                        ),
                      
                      if (precedentCase.institution.isNotEmpty && precedentCase.institution != 'N/A')
                        const SizedBox(height: 24),
                      
                      // Industries
                      if (precedentCase.industries.isNotEmpty)
                        _buildListSection(
                          'Industries',
                          precedentCase.industries,
                        ),
                      
                      if (precedentCase.industries.isNotEmpty)
                        const SizedBox(height: 24),
                      
                      // Party Nationalities
                      if (precedentCase.partyNationalities.isNotEmpty)
                        _buildListSection(
                          'Party Nationalities',
                          precedentCase.partyNationalities,
                        ),
                      
                      if (precedentCase.partyNationalities.isNotEmpty)
                        const SizedBox(height: 24),
                      
                      // Rules of Arbitration
                      if (precedentCase.rulesOfArbitration.isNotEmpty)
                        _buildListSection(
                          'Rules of Arbitration',
                          precedentCase.rulesOfArbitration,
                          isLongText: true,
                        ),
                      
                      if (precedentCase.rulesOfArbitration.isNotEmpty)
                        const SizedBox(height: 24),
                      
                      // Applicable Treaties
                      if (precedentCase.applicableTreaties.isNotEmpty)
                        _buildListSection(
                          'Applicable Treaties',
                          precedentCase.applicableTreaties,
                          isLongText: true,
                        ),
                      
                      if (precedentCase.applicableTreaties.isNotEmpty)
                        const SizedBox(height: 24),
                      
                      // Relevant Holding
                      _buildDetailSection(
                        'Relevant Holding',
                        precedentCase.relevantHolding,
                        isLongText: true,
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Citation
                      _buildDetailSection(
                        'Citation',
                        precedentCase.citation,
                        isMonospace: true,
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Additional Information Section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: accentColor.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 16,
                                  color: accentColor,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Case Summary',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: accentColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'This case provides important precedent for the current legal argument. '
                              'The court\'s decision and reasoning establish key principles that support '
                              'the analysis presented.',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6B7280),
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Footer
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(
    String label,
    String value, {
    bool isTitle = false,
    bool isLongText = false,
    bool isMonospace = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: accentColor,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: isTitle ? 16 : 14,
            fontWeight: isTitle ? FontWeight.w600 : FontWeight.w400,
            color: isTitle ? const Color(0xFF1F2937) : const Color(0xFF6B7280),
            height: isLongText ? 1.5 : 1.3,
            fontFamily: isMonospace ? 'monospace' : null,
          ),
          maxLines: isLongText ? null : 3,
          overflow: isLongText ? null : TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildListSection(
    String label,
    List<String> items, {
    bool isLongText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: accentColor,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '• ',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: accentColor,
                ),
              ),
              Expanded(
                child: Text(
                  item,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF6B7280),
                    height: isLongText ? 1.5 : 1.3,
                  ),
                ),
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }
} 