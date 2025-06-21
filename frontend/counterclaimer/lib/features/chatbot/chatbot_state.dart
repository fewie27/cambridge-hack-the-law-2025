import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ChatbotMode {
  fullscreen,  // Chatbot al centro, app nascosta
  sidebar,     // Chatbot a destra, app visibile
}

// Provider per controllare se il chatbot è fullscreen o sidebar
final chatbotModeProvider = StateProvider<ChatbotMode>((ref) => ChatbotMode.fullscreen);

// Provider per i messaggi semplici
final chatMessagesProvider = StateProvider<List<String>>((ref) => [
  "Hi! I'm your legal assistant. Tell me about your case and I'll help you analyze it."
]);

// Provider per l'input dell'utente
final userInputProvider = StateProvider<String>((ref) => '');