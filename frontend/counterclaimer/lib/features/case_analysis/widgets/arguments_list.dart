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