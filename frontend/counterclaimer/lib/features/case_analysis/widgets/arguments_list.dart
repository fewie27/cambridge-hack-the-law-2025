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
    final strengths = ref.watch(strengthsProvider);
    final weaknesses = ref.watch(weaknessesProvider);
    final arguments = selectedTab == 0 ? strengths : weaknesses;
    
    if (arguments.isEmpty) {
      return Container(
        color: Colors.white,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, size: 48, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No arguments available',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }
    
    return Container(
      color: Colors.white,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 20), // Aggiunge spazio sopra la prima card
        itemCount: arguments.length,
        itemBuilder: (context, index) {
          final argument = arguments[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ArgumentCard(argument: argument),
          );
        },
      ),
    );
  }
}