// lib/features/welcome/screens/animated_welcome_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:counterclaimer/core/theme/colors.dart';

// Provider per gestire lo stato della transizione
final welcomeStateProvider = StateProvider<WelcomeState>((ref) => WelcomeState.welcome);
final chatMessagesProvider = StateProvider<List<ChatMessage>>((ref) => []);
final chatWidthProvider = StateProvider<double>((ref) => 300.0); // Larghezza iniziale chat

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
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _appSlideAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Controller principale per slide
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    // Controller per fade
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Controller per scale
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    // Welcome screen slides out to the right
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(1.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeInQuart),
    ));
    
    // Welcome screen fades out
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
    
    // Chat scales in from small
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
    
    // App slides in from left
    _appSlideAnimation = Tween<double>(
      begin: -1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
    ));
  }
  
  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
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
    
    // Avvia tutte le animazioni in sequenza
    _fadeController.forward();
    _slideController.forward();
    
    Future.delayed(const Duration(milliseconds: 600), () {
      _scaleController.forward();
    });
    
    Future.delayed(const Duration(milliseconds: 1200), () {
      ref.read(welcomeStateProvider.notifier).state = WelcomeState.chat;
      
      // Simula risposta del bot
      Future.delayed(const Duration(seconds: 1), () {
        final currentMessages = ref.read(chatMessagesProvider);
        ref.read(chatMessagesProvider.notifier).state = [
          ...currentMessages,
          ChatMessage(
            text: "Perfect! I've analyzed your request: \"$userMessage\". How can I assist you further?",
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
    final chatWidth = ref.watch(chatWidthProvider);
    
    return Scaffold(
      body: Stack(
        children: [
          // App principale (con animazione slide da sinistra)
          if (welcomeState == WelcomeState.transitioning || welcomeState == WelcomeState.chat)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              right: welcomeState == WelcomeState.chat ? chatWidth : 0,
              child: AnimatedBuilder(
                animation: _appSlideAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      _appSlideAnimation.value * MediaQuery.of(context).size.width,
                      0,
                    ),
                    child: widget.appContent,
                  );
                },
              ),
            ),
          
          // Chat sidebar (quando attiva)
          if (welcomeState == WelcomeState.chat)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    alignment: Alignment.centerRight,
                    child: ResizableChat(
                      width: chatWidth,
                      onWidthChanged: (newWidth) {
                        ref.read(chatWidthProvider.notifier).state = newWidth;
                      },
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
                              text: "Response to: \"$message\"",
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
            ),
          
          // Welcome screen (con animazioni slide + fade)
          if (welcomeState != WelcomeState.chat)
            AnimatedBuilder(
              animation: Listenable.merge([_slideAnimation, _fadeAnimation]),
              builder: (context, child) {
                return SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: ClaudeStyleWelcome(
                      onSubmit: _startTransition,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

// Chat ridimensionabile in stile Claude
class ResizableChat extends ConsumerStatefulWidget {
  final double width;
  final Function(double) onWidthChanged;
  final Function(String) onSendMessage;
  
  const ResizableChat({
    super.key,
    required this.width,
    required this.onWidthChanged,
    required this.onSendMessage,
  });

  @override
  ConsumerState<ResizableChat> createState() => _ResizableChatState();
}

class _ResizableChatState extends ConsumerState<ResizableChat> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isExpanded = false;
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatMessagesProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Container(
      width: widget.width,
      height: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F), // Sfondo scuro come Claude
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          bottomLeft: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 30,
            offset: const Offset(-8, 0),
          ),
          BoxShadow(
            color: const Color(0xFF678D7F).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(-4, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header elegante stile Claude
          _buildClaudeHeader(screenWidth),
          
          // Divisore sottile
          Container(
            height: 1,
            color: const Color(0xFF2A2A2A),
          ),
          
          // Lista messaggi con sfondo scuro
          Expanded(
            child: Container(
              color: AppColors.backgroundLight,
              child: messages.isEmpty 
                  ? _buildEmptyState()
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        return ClaudeChatBubble(message: message);
                      },
                    ),
            ),
          ),
          
          // Input area stile Claude
          _buildClaudeInput(),
        ],
      ),
    );
  }

  Widget _buildClaudeHeader(double screenWidth) {
    return Container(
      height: 65,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          // Resize handle più elegante
          MouseRegion(
            cursor: SystemMouseCursors.resizeLeftRight,
            child: GestureDetector(
              onPanStart: (_) => setState(() => _isDragging = true),
              onPanEnd: (_) => setState(() => _isDragging = false),
              onPanUpdate: (details) {
                final newWidth = widget.width - details.delta.dx;
                if (newWidth >= 280 && newWidth <= screenWidth * 0.7) {
                  widget.onWidthChanged(newWidth);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24,
                height: 40,
                decoration: BoxDecoration(
                  color: _isDragging 
                      ? const Color(0xFF678D7F).withOpacity(0.3)
                      : const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isDragging 
                        ? const Color(0xFF678D7F)
                        : const Color(0xFF404040),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 12,
                    height: 2,
                    decoration: BoxDecoration(
                      color: _isDragging 
                          ? const Color(0xFF678D7F)
                          : const Color(0xFF888888),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Icona e titolo
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF678D7F),
                  const Color(0xFF678D7F).withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.balance,
              color: Colors.white,
              size: 16,
            ),
          ),
          
          const SizedBox(width: 12),
          
          const Text(
            'ARIA',
            style: TextStyle(
              color: Color(0xFF000000),
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          
          const Spacer(),
          
          const SizedBox(width: 16),
          
          // Pulsanti azione
          _buildHeaderButton(
            icon: _isExpanded ? Icons.fullscreen_exit : Icons.fullscreen,
            onTap: () {
              setState(() => _isExpanded = !_isExpanded);
              widget.onWidthChanged(_isExpanded ? 280 : 500);
            },
          ),
          
          const SizedBox(width: 8),
          
        ],
      ),
    );
  }

  Widget _buildHeaderButton({required IconData icon, required VoidCallback onTap}) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.transparent),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF374151), // Icone grigio scuro
            size: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6), // Sfondo grigio chiaro
              borderRadius: BorderRadius.circular(32),
            ),
            child: const Icon(
              Icons.chat_bubble_outline,
              color: Color(0xFF678D7F),
              size: 28,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Start a conversation',
            style: TextStyle(
              color: Color(0xFF111827), // Testo nero
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ask me anything about your legal case',
            style: TextStyle(
              color: Color(0xFF6B7280), // Testo grigio
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildClaudeInput() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white, // Sfondo bianco per input
        border: Border(
          top: BorderSide(color: Color(0xFFE5E7EB), width: 1), // Bordo grigio chiaro
        ),
      ),
      child: Column(
        children: [
          // Input container stile Claude
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6), // Sfondo grigio chiaro
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE5E7EB), width: 1), // Bordo grigio
            ),
            child: Row(
              children: [
                // Pulsante attach
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: _buildInputButton(Icons.add, () {}),
                ),
                
                // TextField
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(
                      color: Color(0xFF111827), // Testo nero
                      fontSize: 14,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Message ARIA...',
                      hintStyle: TextStyle(
                        color: Color(0xFF6B7280), // Hint grigio
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                
                // Pulsante send
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _controller.text.trim().isNotEmpty
                          ? const Color(0xFF678D7F)
                          : const Color(0xFF404040),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: IconButton(
                      onPressed: _controller.text.trim().isNotEmpty
                          ? () => _sendMessage(_controller.text)
                          : null,
                      icon: Icon(
                        Icons.arrow_upward,
                        color: _controller.text.trim().isNotEmpty
                            ? Colors.white
                            : const Color(0xFF666666),
                        size: 16,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Footer info
          const SizedBox(height: 12),
          Text(
            'ARIA can make mistakes. Please verify important information.',
            style: TextStyle(
              color: const Color(0xFF6B7280), // Grigio per il disclaimer
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInputButton(IconData icon, VoidCallback onTap) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: const Color(0xFFE5E7EB), // Sfondo grigio
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF6B7280), // Icona grigia
            size: 16,
          ),
        ),
      ),
    );
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    
    widget.onSendMessage(text);
    _controller.clear();
    setState(() {}); // Per aggiornare il pulsante send
    
    // Auto scroll
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}

// Bubble stile Claude per i messaggi
class ClaudeChatBubble extends StatelessWidget {
  final ChatMessage message;
  
  const ClaudeChatBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: message.isUser 
                  ? const Color(0xFF404040)
                  : const Color(0xFF678D7F),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              message.isUser ? Icons.person : Icons.balance,
              color: Colors.white,
              size: 14,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Contenuto messaggio
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nome utente
                Text(
                  message.isUser ? 'You' : 'ARIA',
                  style: TextStyle(
                    color: const Color(0xFFE5E5E5),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                const SizedBox(height: 6),
                
                // Testo messaggio
                Container(
                  padding: const EdgeInsets.all(0),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: const Color(0xFFE5E5E5),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
                
                // Timestamp
                const SizedBox(height: 8),
                Text(
                  _formatTime(message.timestamp),
                  style: TextStyle(
                    color: const Color(0xFF666666),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

// La ClaudeStyleWelcome rimane uguale
class ClaudeStyleWelcome extends StatefulWidget {
  final Function(String) onSubmit;
  
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
          _buildTopBar(context),
          Expanded(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 800),
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
                    _buildMainInput(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: AppColors.backgroundLight,
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

  void _handleSubmit(String text) {
    if (text.trim().isEmpty) return;
    
    _controller.clear();
    widget.onSubmit(text);
  }

  void _handleAddFile() => print('Add file pressed');
  void _handleMenu() => print('Menu pressed');
}