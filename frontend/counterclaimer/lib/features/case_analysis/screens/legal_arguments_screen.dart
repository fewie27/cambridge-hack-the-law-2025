import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/arguments_header.dart';
import '../widgets/tab_navigation.dart';
import '../widgets/arguments_list.dart';
import '../widgets/argument_detail.dart';
import '../../../simple_api/simple_api.dart';

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
  // Additional case details
  final List<String> industries;
  final String status;
  final List<String> partyNationalities;
  final String institution;
  final List<String> rulesOfArbitration;
  final List<String> applicableTreaties;
  final List<Map<String, dynamic>> decisions;

  PrecedentCase({
    required this.caseNumber,
    required this.caseName,
    required this.court,
    required this.year,
    required this.relevantHolding,
    required this.citation,
    this.industries = const [],
    this.status = '',
    this.partyNationalities = const [],
    this.institution = '',
    this.rulesOfArbitration = const [],
    this.applicableTreaties = const [],
    this.decisions = const [],
  });
}

// Providers
final selectedArgumentProvider = StateProvider<LegalArgument?>((ref) => null);
final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedTabProvider = StateProvider<int>((ref) => 0);

// API Data Providers
final analysisDataProvider = FutureProvider<AnalysisResponse?>((ref) async {
  try {
    // You can modify this prompt or make it configurable
    const userPrompt = "I'm working on a case representing Fenoscadia Limited, a mining company from Ticadia that was operating in Kronos under an 80-year concession to extract lindoro, a rare earth metal. In 2016, Kronos passed a decree that revoked Fenoscadia's license and terminated the concession agreement, citing environmental concerns. The government had funded a study that suggested lindoro mining contaminated the Rhea River and caused health issues, although the study didn't conclusively prove this.";
    
    print('Calling API with prompt: $userPrompt');
    final response = await CambridgeApi.addCase(AddCaseRequest(userPrompt));
    print('API Response received: ${response.caseId}');
    print('Strengths: ${response.strengths.length}');
    print('Weaknesses: ${response.weaknesses.length}');
    return response;
  } catch (e) {
    print('Error fetching analysis data: $e');
    rethrow; // Re-throw to let the FutureProvider handle the error state
  }
});

final isLoadingProvider = StateProvider<bool>((ref) => true);

// Convert API data to UI models
final strengthsProvider = Provider<List<LegalArgument>>((ref) {
  final analysisData = ref.watch(analysisDataProvider);
  return analysisData.when(
    data: (data) {
      if (data == null) return [];
      return data.strengths.map((apiArgument) {
        final title = apiArgument.argument.isNotEmpty 
            ? apiArgument.argument.split('.')[0] + '.'
            : 'Legal Argument';
            
        return LegalArgument(
          id: apiArgument.argument.hashCode.toString(),
          title: title,
          description: apiArgument.argument,
          strength: 'strong',
          category: 'Legal Analysis',
          precedentCases: apiArgument.caseReferences.map((ref) {
            return PrecedentCase(
              caseNumber: ref.caseIdentifier.isNotEmpty ? ref.caseIdentifier : 'N/A',
              caseName: ref.title.isNotEmpty ? ref.title : 'Unknown Case',
              court: 'Court',
              year: ref.date ?? 'N/A',
              relevantHolding: 'Relevant holding based on case analysis',
              citation: ref.sourcefileRawMd.isNotEmpty ? ref.sourcefileRawMd : 'N/A',
              industries: ref.industries,
              status: ref.status ?? '',
              partyNationalities: ref.partyNationalities,
              institution: ref.institution ?? '',
              rulesOfArbitration: ref.rulesOfArbitration,
              applicableTreaties: ref.applicableTreaties,
              decisions: ref.decisions,
            );
          }).toList(),
        );
      }).toList();
    },
    loading: () => [],
    error: (error, stack) {
      print('Error in strengths provider: $error');
      return [];
    },
  );
});

final weaknessesProvider = Provider<List<LegalArgument>>((ref) {
  final analysisData = ref.watch(analysisDataProvider);
  return analysisData.when(
    data: (data) {
      if (data == null) return [];
      return data.weaknesses.map((apiArgument) {
        final title = apiArgument.argument.isNotEmpty 
            ? apiArgument.argument.split('.')[0] + '.'
            : 'Legal Argument';
            
        return LegalArgument(
          id: apiArgument.argument.hashCode.toString(),
          title: title,
          description: apiArgument.argument,
          strength: 'moderate',
          category: 'Legal Analysis',
          precedentCases: apiArgument.caseReferences.map((ref) {
            return PrecedentCase(
              caseNumber: ref.caseIdentifier.isNotEmpty ? ref.caseIdentifier : 'N/A',
              caseName: ref.title.isNotEmpty ? ref.title : 'Unknown Case',
              court: 'Court',
              year: ref.date ?? 'N/A',
              relevantHolding: 'Relevant holding based on case analysis',
              citation: ref.sourcefileRawMd.isNotEmpty ? ref.sourcefileRawMd : 'N/A',
              industries: ref.industries,
              status: ref.status ?? '',
              partyNationalities: ref.partyNationalities,
              institution: ref.institution ?? '',
              rulesOfArbitration: ref.rulesOfArbitration,
              applicableTreaties: ref.applicableTreaties,
              decisions: ref.decisions,
            );
          }).toList(),
        );
      }).toList();
    },
    loading: () => [],
    error: (error, stack) {
      print('Error in weaknesses provider: $error');
      return [];
    },
  );
});

class LegalArgumentsScreen extends ConsumerWidget {
  const LegalArgumentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedArgument = ref.watch(selectedArgumentProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final selectedTab = ref.watch(selectedTabProvider);
    final analysisData = ref.watch(analysisDataProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: analysisData.when(
        data: (data) {
          if (data == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Failed to load case analysis',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          
          return Column(
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
          );
        },
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Analyzing your case...',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error loading case analysis',
                style: const TextStyle(fontSize: 18, color: Colors.red),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}