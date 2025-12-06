import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:ui';
import 'package:askmo/profile/models/user_state.dart';
import 'package:provider/provider.dart';
import 'dart:convert'; // Import untuk base64Decode
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class GeminiChatScreen extends StatefulWidget {
  const GeminiChatScreen({super.key});

  @override
  State<GeminiChatScreen> createState() => _GeminiChatScreenState();
}

class _GeminiChatScreenState extends State<GeminiChatScreen> 
    with SingleTickerProviderStateMixin {
  
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isSending = false;
  
  late final String _apiKey;
  late final GenerativeModel _model;
  late final ChatSession _chat;
  
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    // Prefer compile-time --dart-define for web; fallback to .env for mobile/desktop.
    _apiKey = const String.fromEnvironment('GEMINI_API_KEY',
        defaultValue: '') // web / release define
      .isNotEmpty
        ? const String.fromEnvironment('GEMINI_API_KEY')
        : (dotenv.env['GEMINI_API_KEY'] ?? '');
    
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _apiKey,
    );
    
    _animationController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _chat = _model.startChat(
      history: [
        // Gemini accepts only roles "user" or "model". Seed with a user message as instruction.
        Content(
          'user',
          [
            TextPart(
              'You are ASKMO Sport Assistant, an expert coach, fitness, and nutrition advisor. '
              'Your persona is helpful, knowledgeable, and highly motivating. Give direct, high-quality, '
              'and specific advice related to the user\'s sports, like training plans, form checks '
              '(hypothetically), or nutrition tips. Respond in Indonesian.',
            ),
          ],
        ),
      ]
    );
    
    _addMessage('Halo! Saya ASKMO Assistant, pelatih AI yang siap membantu rencana kebugaran dan olahraga Anda. Ada yang bisa saya bantu?', 'model');
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _addMessage(String text, String role) {
    setState(() {
      _messages.add({'text': text, 'role': role, 'time': DateTime.now()});
    });
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final message = _textController.text.trim();
    if (message.isEmpty || _isSending) return;

    _textController.clear();
    _addMessage(message, 'user');

    if (_apiKey.isEmpty) {
      _addMessage('Konfigurasi kunci API belum diatur. Tambahkan GEMINI_API_KEY di file .env.', 'model');
      return;
    }
    
    setState(() => _isSending = true);

    try {
      final response = await _chat.sendMessage(Content.text(message));
      final responseText = response.text ?? 'Maaf, saya gagal memproses permintaan Anda.';
      _addMessage(responseText, 'model');
    } catch (e) {
      _addMessage('Error: Gagal terhubung ke server Gemini.', 'model');
      print('Gemini Error: $e');
    } finally {
      setState(() => _isSending = false);
    }
  }
  
  Widget _buildBackgroundAura() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned(
              top: -150,
              left: -150,
              child: Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 700,
                  height: 700,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF571E88).withOpacity(0.7),
                        const Color(0xFF06005E).withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -200,
              right: -200,
              child: Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 800,
                  height: 800,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF6F0732).withOpacity(0.7),
                        const Color(0xFF571E88).withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userState = context.watch<UserState>();
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ASKMO Assistant',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              'Pelatih Virtual Anda',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFA4E4FF),
              // Mengganti Image.asset dengan Icon/placeholder
              child: const Icon(Icons.psychology, color: Colors.black, size: 20),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(child: _buildBackgroundAura()),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      return _buildMessageBubble(
                        text: msg['text'],
                        role: msg['role'],
                        userState: userState,
                        isLast: index == _messages.length - 1,
                      );
                    },
                  ),
                ),
                _buildInputBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble({
    required String text, 
    required String role, 
    required UserState userState,
    required bool isLast,
  }) {
    final isUser = role == 'user';
    
    ImageProvider? avatarImage;
    String displayName;
    
    if (isUser) {
      if (userState.avatarPath.startsWith('data:')) {
        avatarImage = MemoryImage(base64Decode(userState.avatarPath.split(',').last));
      } else if (userState.avatarPath.isNotEmpty) {
        avatarImage = AssetImage(userState.avatarPath);
      } else {
        avatarImage = const AssetImage('assets/avatar/default_avatar.png');
      }
      displayName = userState.displayName.split(' ').first; // Nama depan saja
    } else {
      // Logika untuk avatar Gemini/ASKMO Assistant
      displayName = 'ASKMO Assistant';
    }

    // Menggabungkan logika penampilan avatar/ikon
    Widget avatarWidget;
    if (isUser) {
      avatarWidget = CircleAvatar(
        radius: 18,
        backgroundImage: avatarImage,
        backgroundColor: const Color(0xFF6C5CE7),
      );
    } else {
      avatarWidget = const CircleAvatar(
        radius: 18,
        backgroundColor: Color(0xFFA4E4FF),
        child: Icon(Icons.psychology, color: Colors.black, size: 20),
      );
    }


    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            avatarWidget,
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
              decoration: BoxDecoration(
                color: isUser ? const Color(0xFF571E88) : const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isUser ? 16 : 4),
                  topRight: Radius.circular(isUser ? 4 : 16),
                  bottomLeft: const Radius.circular(16),
                  bottomRight: const Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isUser ? displayName : 'ASKMO Assistant',
                    style: GoogleFonts.plusJakartaSans(
                      color: isUser ? Colors.white70 : const Color(0xFFA4E4FF),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  isUser
                      ? Text(
                          text,
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        )
                      : MarkdownBody(
                          data: text,
                          styleSheet: MarkdownStyleSheet(
                            p: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 14,
                              height: 1.4,
                            ),
                            strong: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                            listBullet: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          bulletBuilder: (params) => Text(
                            '• ',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                  if (!isUser && isLast && _isSending) 
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Mengetik...',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white54,
                          fontSize: 10,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            avatarWidget, // Menggunakan avatarWidget yang sudah dibuat
          ],
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            border: Border(
              top: BorderSide(color: Colors.white.withOpacity(0.2), width: 1),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  style: GoogleFonts.plusJakartaSans(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Tanyakan tentang latihan, nutrisi...',
                    hintStyle: GoogleFonts.plusJakartaSans(color: Colors.white54),
                    filled: true,
                    fillColor: Colors.black.withOpacity(0.3),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: _isSending
                        ? const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFFA4E4FF),
                              ),
                            ),
                          )
                        : null,
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _isSending ? null : _sendMessage,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _isSending ? Colors.grey : const Color(0xFF571E88),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.send_rounded, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

