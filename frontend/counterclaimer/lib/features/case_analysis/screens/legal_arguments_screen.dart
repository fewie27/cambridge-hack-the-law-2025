import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/arguments_header.dart';
import '../widgets/tab_navigation.dart';
import '../widgets/arguments_list.dart';
import '../widgets/argument_detail.dart';

// Models
class LegalArgument {
  final String id;
  final String title;
  final String description;
  final List<PrecedentCase> precedentCases;
  final String strength; // 'strong', 'moderate', 'weak'
  final String category;

  LegalArgument({
    required this.id,
    required this.title,
    required this.description,
    required this.precedentCases,
    required this.strength,
    required this.category,
  });
}

class PrecedentCase {
  final String caseNumber;
  final String caseName;
  final String court;
  final String year;
  final String relevantHolding;
  final String citation;

  PrecedentCase({
    required this.caseNumber,
    required this.caseName,
    required this.court,
    required this.year,
    required this.relevantHolding,
    required this.citation,
  });
}

// Mock Data - OUR CASE STRENGTHS
final ourStrengths = [
  LegalArgument(
    id: '1',
    title: 'Complete Environmental Compliance',
    description: 'Our project has completed all required environmental impact studies and obtained all necessary permits from competent authorities.',
    strength: 'strong',
    category: 'Environmental Law',
    precedentCases: [
      PrecedentCase(
        caseNumber: 'CV-2019-0234',
        caseName: 'Sierra Club v. Atlantic Coast Pipeline',
        court: 'Fourth Circuit Court of Appeals',
        year: '2019',
        relevantHolding: 'Comprehensive environmental impact assessments satisfy federal requirements',
        citation: '912 F.3d 13 (4th Cir. 2019)',
      ),
      PrecedentCase(
        caseNumber: 'CV-2020-0156',
        caseName: 'Environmental Defense Fund v. FERC',
        court: 'D.C. Circuit Court of Appeals',
        year: '2020',
        relevantHolding: 'Adequate mitigation measures protect against environmental challenges',
        citation: '952 F.3d 389 (D.C. Cir. 2020)',
      ),
    ],
  ),
  LegalArgument(
    id: '2',
    title: 'Legal Eminent Domain Authority',
    description: 'Federal law grants clear eminent domain authority for interstate pipeline infrastructure projects serving public interest.',
    strength: 'strong',
    category: 'Property Law',
    precedentCases: [
      PrecedentCase(
        caseNumber: 'CV-2021-0223',
        caseName: 'PennEast Pipeline v. New Jersey',
        court: 'U.S. Supreme Court',
        year: '2021',
        relevantHolding: 'Federal eminent domain authority extends to state-owned properties',
        citation: '141 S. Ct. 2244 (2021)',
      ),
      PrecedentCase(
        caseNumber: 'CV-2018-0089',
        caseName: 'Kinder Morgan v. Upland Owner Coalition',
        court: 'Texas Supreme Court',
        year: '2018',
        relevantHolding: 'Common carriers have broad eminent domain authority for interstate pipelines',
        citation: '587 S.W.3d 273 (Tex. 2018)',
      ),
    ],
  ),
  LegalArgument(
    id: '3',
    title: 'Federal Preemption Defense',
    description: 'Interstate pipeline operations fall under federal jurisdiction, preempting state and local regulatory challenges.',
    strength: 'strong',
    category: 'Constitutional Law',
    precedentCases: [
      PrecedentCase(
        caseNumber: 'CV-2019-0167',
        caseName: 'National Fuel Gas v. New York State DEC',
        court: 'Second Circuit Court of Appeals',
        year: '2019',
        relevantHolding: 'Federal authority preempts state environmental permitting for interstate pipelines',
        citation: '934 F.3d 77 (2d Cir. 2019)',
      ),
    ],
  ),
  LegalArgument(
    id: '4',
    title: 'Economic Necessity and Public Interest',
    description: 'The project serves critical energy security needs and provides substantial economic benefits to local communities.',
    strength: 'moderate',
    category: 'Economic Policy',
    precedentCases: [
      PrecedentCase(
        caseNumber: 'CV-2020-0134',
        caseName: 'Mountain Valley Pipeline v. Virginia DEQ',
        court: 'Virginia Supreme Court',
        year: '2020',
        relevantHolding: 'Economic benefits must be weighed against environmental costs in permitting decisions',
        citation: '845 S.E.2d 456 (Va. 2020)',
      ),
    ],
  ),
  LegalArgument(
    id: '5',
    title: 'Safety Standards Compliance',
    description: 'Full adherence to federal pipeline safety regulations and industry best practices throughout construction and operation.',
    strength: 'strong',
    category: 'Regulatory Compliance',
    precedentCases: [
      PrecedentCase(
        caseNumber: 'CV-2020-0198',
        caseName: 'PHMSA v. Enbridge Energy',
        court: 'Federal District Court',
        year: '2020',
        relevantHolding: 'Compliance with federal safety standards provides strong defense against liability claims',
        citation: '487 F. Supp. 3d 234 (D. Minn. 2020)',
      ),
    ],
  ),
];

// Mock Data - OPPONENT WEAKNESSES (What opponents might use against us)
final opponentWeaknesses = [
  LegalArgument(
    id: 'w1',
    title: 'Climate Change Impact Claims',
    description: 'Opponents may argue that the project contributes to climate change and associated environmental damages.',
    strength: 'moderate',
    category: 'Environmental Liability',
    precedentCases: [
      PrecedentCase(
        caseNumber: 'CV-2021-0089',
        caseName: 'City of Oakland v. BP p.l.c.',
        court: 'Ninth Circuit Court of Appeals',
        year: '2021',
        relevantHolding: 'Climate change claims may proceed under state law theories',
        citation: '969 F.3d 895 (9th Cir. 2021)',
      ),
      PrecedentCase(
        caseNumber: 'CV-2019-0234',
        caseName: 'Juliana v. United States',
        court: 'Ninth Circuit Court of Appeals',
        year: '2020',
        relevantHolding: 'Constitutional climate claims face significant justiciability hurdles (favorable to us)',
        citation: '947 F.3d 1159 (9th Cir. 2020)',
      ),
    ],
  ),
  LegalArgument(
    id: 'w2',
    title: 'Indigenous Rights Violations',
    description: 'Potential claims regarding inadequate consultation with tribal governments and impacts on sacred sites.',
    strength: 'strong',
    category: 'Indigenous Rights',
    precedentCases: [
      PrecedentCase(
        caseNumber: 'CV-2020-0456',
        caseName: 'Standing Rock Sioux Tribe v. U.S. Army Corps',
        court: 'D.C. District Court',
        year: '2020',
        relevantHolding: 'Adequate consultation with tribes required for pipeline crossings',
        citation: '471 F. Supp. 3d 71 (D.D.C. 2020)',
      ),
    ],
  ),
  LegalArgument(
    id: 'w3',
    title: 'Property Value Diminution',
    description: 'Landowners may claim reduced property values due to pipeline proximity and construction impacts.',
    strength: 'moderate',
    category: 'Property Damage',
    precedentCases: [
      PrecedentCase(
        caseNumber: 'CV-2019-0345',
        caseName: 'Homeowners Coalition v. Spectra Energy',
        court: 'New Jersey Superior Court',
        year: '2019',
        relevantHolding: 'Proximity to pipelines can constitute compensable property damage',
        citation: '234 A.3d 567 (N.J. Super. 2019)',
      ),
    ],
  ),
  LegalArgument(
    id: 'w4',
    title: 'Inadequate Environmental Review',
    description: 'Challenges to the thoroughness of environmental impact assessments and mitigation measures.',
    strength: 'weak',
    category: 'Environmental Law',
    precedentCases: [
      PrecedentCase(
        caseNumber: 'CV-2021-0178',
        caseName: 'Citizens Against Pipeline v. FERC',
        court: 'Fourth Circuit Court of Appeals',
        year: '2021',
        relevantHolding: 'Environmental reviews must consider cumulative impacts and alternatives',
        citation: '978 F.3d 234 (4th Cir. 2021)',
      ),
    ],
  ),
  LegalArgument(
    id: 'w5',
    title: 'Market Need Challenges',
    description: 'Arguments that the pipeline is not necessary due to changing energy markets and renewable alternatives.',
    strength: 'moderate',
    category: 'Economic Policy',
    precedentCases: [
      PrecedentCase(
        caseNumber: 'CV-2022-0067',
        caseName: 'Environmental Groups v. Atlantic Coast Pipeline',
        court: 'Fourth Circuit Court of Appeals',
        year: '2022',
        relevantHolding: 'Project sponsors must demonstrate current market need for new infrastructure',
        citation: '1045 F.3d 456 (4th Cir. 2022)',
      ),
    ],
  ),
];

// Providers
final selectedArgumentProvider = StateProvider<LegalArgument?>((ref) => null);
final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedTabProvider = StateProvider<int>((ref) => 0);

class LegalArgumentsScreen extends ConsumerWidget {
  const LegalArgumentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedArgument = ref.watch(selectedArgumentProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final selectedTab = ref.watch(selectedTabProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          // Header Component
          ArgumentsHeader(searchQuery: searchQuery),
          
          // Tab Navigation Component
          TabNavigation(selectedTab: selectedTab),
          
          // Main Content
          Expanded(
            child: selectedArgument == null 
              ? ArgumentsList(selectedTab: selectedTab)
              : ArgumentDetail(argument: selectedArgument),
          ),
        ],
      ),
    );
  }
}