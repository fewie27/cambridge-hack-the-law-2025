// lib/features/welcome/screens/animated_welcome_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:counterclaimer/core/theme/colors.dart';

// Provider per gestire lo stato della transizione
final welcomeStateProvider = StateProvider<WelcomeState>((ref) => WelcomeState.welcome);
final chatMessagesProvider = StateProvider<List<ChatMessage>>((ref) => []);

enum WelcomeState { welcome, transitioning, chat }

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class AnimatedWelcomeScreen extends ConsumerStatefulWidget {
  final Widget appContent;
  
  const AnimatedWelcomeScreen({
    super.key,
    required this.appContent,
  });

  @override
  ConsumerState<AnimatedWelcomeScreen> createState() => _AnimatedWelcomeScreenState();
}

class _AnimatedWelcomeScreenState extends ConsumerState<AnimatedWelcomeScreen>
    with TickerProviderStateMixin {
  
  late AnimationController _slideController;
  late Animation<double> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Controller per l'animazione di slide (da 1.0 a 0.4 invece che a 0)
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Animazione che riduce la width della welcome screen da 100% a 40%
    _slideAnimation = Tween<double>(
      begin: 1.0, // Schermo intero
      end: 0.4,   // 40% dello schermo (chat a destra)
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }
  
  void _startTransition(String userMessage) {
    // Aggiungi il messaggio dell'utente
    final messages = ref.read(chatMessagesProvider);
    ref.read(chatMessagesProvider.notifier).state = [
      ...messages,
      ChatMessage(
        text: userMessage,
        isUser: true,
        timestamp: DateTime.now(),
      ),
    ];
    
    ref.read(welcomeStateProvider.notifier).state = WelcomeState.transitioning;
    _slideController.forward().then((_) {
      ref.read(welcomeStateProvider.notifier).state = WelcomeState.chat;
      
      // Simula una risposta del bot dopo 1 secondo
      Future.delayed(const Duration(seconds: 1), () {
        final currentMessages = ref.read(chatMessagesProvider);
        ref.read(chatMessagesProvider.notifier).state = [
          ...currentMessages,
          ChatMessage(
            text: "Ho ricevuto la tua richiesta: \"$userMessage\". Come posso aiutarti ulteriormente?",
            isUser: false,
            timestamp: DateTime.now(),
          ),
        ];
      });
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final welcomeState = ref.watch(welcomeStateProvider);
    
    return Scaffold(
      body: Row(
        children: [
          // App principale (a sinistra, si espande quando la chat appare)
          Expanded(
            flex: welcomeState == WelcomeState.chat ? 60 : 0,
            child: welcomeState == WelcomeState.chat 
                ? widget.appContent 
                : const SizedBox.shrink(),
          ),
          
          // Welcome Screen / Chat (a destra)
          AnimatedBuilder(
            animation: _slideAnimation,
            builder: (context, child) {
              return SizedBox(
                width: MediaQuery.of(context).size.width * _slideAnimation.value,
                child: welcomeState == WelcomeState.welcome
                    ? ClaudeStyleWelcome(
                        onSubmit: _startTransition,
                      )
                    : ChatInterface(
                        onSendMessage: (message) {
                          final messages = ref.read(chatMessagesProvider);
                          ref.read(chatMessagesProvider.notifier).state = [
                            ...messages,
                            ChatMessage(
                              text: message,
                              isUser: true,
                              timestamp: DateTime.now(),
                            ),
                          ];
                          
                          // Simula risposta del bot
                          Future.delayed(const Duration(seconds: 1), () {
                            final currentMessages = ref.read(chatMessagesProvider);
                            ref.read(chatMessagesProvider.notifier).state = [
                              ...currentMessages,
                              ChatMessage(
                                text: "Risposta a: \"$message\"",
                                isUser: false,
                                timestamp: DateTime.now(),
                              ),
                            ];
                          });
                        },
                      ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Chat Interface che sostituisce la welcome screen
class ChatInterface extends ConsumerStatefulWidget {
  final Function(String) onSendMessage;
  
  const ChatInterface({
    super.key,
    required this.onSendMessage,
  });

  @override
  ConsumerState<ChatInterface> createState() => _ChatInterfaceState();
}

class _ChatInterfaceState extends ConsumerState<ChatInterface> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatMessagesProvider);
    
    return Container(
      color: AppColors.backgroundLight,
      child: Column(
        children: [
          // Header della chat
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: const BoxDecoration(
              color: Color(0xFF1F1F1F),
              border: Border(
                bottom: BorderSide(color: Color(0xFF404040), width: 1),
                left: BorderSide(color: Color(0xFF404040), width: 1),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.chat, color: Color(0xFF678D7F), size: 20),
                SizedBox(width: 12),
                Text(
                  'ARIA',
                  style: TextStyle(
                    color: Color(0xFFE5E5E5),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          // Lista messaggi
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return ChatBubble(message: message);
              },
            ),
          ),
          
          // Input della chat
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFF404040), width: 1),
                left: BorderSide(color: Color(0xFF404040), width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Color(0xFFE5E5E5)),
                    decoration: const InputDecoration(
                      hintText: 'Write a message...',
                      hintStyle: TextStyle(color: Color(0xFF888888)),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF404040)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF404040)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF678D7F)),
                      ),
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _sendMessage(_controller.text),
                  icon: const Icon(
                    Icons.send,
                    color: Color(0xFF678D7F),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    
    widget.onSendMessage(text);
    _controller.clear();
    
    // Scroll verso il basso
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }
}

// Bubble per i messaggi della chat
class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  
  const ChatBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: message.isUser 
              ? const Color(0xFF678D7F) 
              : const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(18),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.3,
        ),
        child: Text(
          message.text,
          style: const TextStyle(
            color: Color(0xFFE5E5E5),
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

// La ClaudeStyleWelcome rimane uguale, ma cambia la signature di onSubmit
class ClaudeStyleWelcome extends StatefulWidget {
  final Function(String) onSubmit; // Ora passa il testo del messaggio
  
  const ClaudeStyleWelcome({
    super.key,
    required this.onSubmit,
  });

  @override
  State<ClaudeStyleWelcome> createState() => _ClaudeStyleWelcomeState();
}

class _ClaudeStyleWelcomeState extends State<ClaudeStyleWelcome> {
  final TextEditingController _controller = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppColors.backgroundLight,
      child: Column(
        children: [
          // Top bar scura (stesso codice di prima)
          _buildTopBar(context),
          
          // Contenuto principale (stesso codice di prima)
          Expanded(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 800),
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icona e titolo (stesso codice di prima)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF678D7F),
                                const Color(0xFF678D7F).withOpacity(0.8),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.balance,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        
                        const SizedBox(width: 24),
                        
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Hello, ',
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w300,
                                  color: const Color(0xFF000000),
                                  height: 1.1,
                                  letterSpacing: -1.5,
                                ),
                              ),
                              TextSpan(
                                text: 'Julia',
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF678D7F),
                                  height: 1.1,
                                  letterSpacing: -1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 60),
                    
                    // Input principale (stesso codice di prima)
                    _buildMainInput(context),
                    
                    const SizedBox(height: 32),
                    
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Tutti i metodi _build rimangono uguali...
  Widget _buildTopBar(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: AppColors.backgroundLight,
        border: Border(
          bottom: BorderSide(color: AppColors.backgroundLight, width: 1),
        ),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/images/ius_mundi_logo.png',
            width: 32,
            height: 32,
            fit: BoxFit.contain,
          ),
          Image.asset(
            'assets/images/codex_logo.jpeg',
            width: 32,
            height: 32,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 16),
          const Text(
            'ARIA',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF000000),
            ),
          ),
          const Spacer(),
          const SizedBox(width: 16),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF678D7F),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text(
                'MK',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainInput(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 800),
      decoration: BoxDecoration(
        // color: const Color(0xFF2A2A2A),
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.primaryGreen, width: 1.5),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: IconButton(
              onPressed: () => _handleAddFile(),
              icon: const Icon(
                Icons.add,
                color: Color(0xFFAAAAAA),
                size: 20,
              ),
            ),
          ),
          IconButton(
            onPressed: () => _handleMenu(),
            icon: const Icon(
              Icons.tune,
              color: Color(0xFFAAAAAA),
              size: 20,
            ),
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF000000),
              ),
              decoration: const InputDecoration(
                hintText: 'How can I help you today?',
                hintStyle: TextStyle(
                  color: Color(0xFF888888),
                  fontSize: 16,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 18,
                ),
              ),
              onSubmitted: (text) => _handleSubmit(text),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF678D7F),
                borderRadius: BorderRadius.circular(20),
              ),
              child: IconButton(
                onPressed: () => _handleSubmit(_controller.text),
                icon: const Icon(
                  Icons.arrow_upward,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap, {bool showNew = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF404040)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: const Color(0xFFAAAAAA),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFFE5E5E5),
                fontWeight: FontWeight.w500,
              ),
            ),
            if (showNew) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF678D7F),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'NUOVO',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _handleSubmit(String text) {
    if (text.trim().isEmpty) return;
    
    print('Submitted: $text');
    _controller.clear();
    
    // Passa il testo del messaggio
    widget.onSubmit(text);
  }

  void _handleAction(String action) {
    print('Action selected: $action');
    
    // Passa l'azione come messaggio
    widget.onSubmit(action);
  }

  void _handleAddFile() {
    print('Add file pressed');
  }

  void _handleMenu() {
    print('Menu pressed');
  }

  void _handleSearch() {
    print('Search pressed');
  }
}