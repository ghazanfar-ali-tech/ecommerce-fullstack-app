import 'package:flutter/material.dart';
import 'package:ecommerceapp/services/chat_service.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AppColors {
  static const Color lightBg = Color(0xFFF6F7FB);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightBotBubble = Color(0xFFFFFFFF);
  static const Color lightUserBubble = Color(0xFF1A1A2E);
  static const Color lightText = Color(0xFF1A1A2E);
  static const Color lightSubText = Color(0xFF8A8FAB);
  static const Color lightBorder = Color(0xFFEAECF4);
  static const Color lightInputBg = Color(0xFFF0F2FA);

  static const Color darkBg = Color(0xFF0F0F1A);
  static const Color darkSurface = Color(0xFF1A1A2E);
  static const Color darkBotBubble = Color(0xFF1E1E32);
  static const Color darkUserBubble = Color(0xFF4F46E5);
  static const Color darkText = Color(0xFFF0F1FF);
  static const Color darkSubText = Color(0xFF6B7280);
  static const Color darkBorder = Color(0xFF2A2A45);
  static const Color darkInputBg = Color(0xFF1E1E32);

  static const Color accent = Color(0xFF4F46E5);
  static const Color accentLight = Color(0xFF818CF8);
  static const Color accentGlow = Color(0x334F46E5);
  static const Color success = Color(0xFF10B981);
  static const Color gold = Color(0xFFF59E0B);
}

const String kGrokLogoUrl =
    'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f7/Grok-feb-2025-logo.svg/1280px-Grok-feb-2025-logo.svg.png';

final RegExp _urlRegex = RegExp(
  r'(https?://[^\s<>"{}|\\^`\[\]]+)',
  caseSensitive: false,
);

List<String> _extractImageUrls(String text) =>
    _urlRegex.allMatches(text).map((m) => m.group(0)!).toList();

String _stripMarkdown(String text) {
  String result = text;

  result = result.replaceAll(RegExp(r'^#{1,6}\s+', multiLine: true), '');

  result = result.replaceAll(RegExp(r'\*{3}(.+?)\*{3}'), r'$1');
  result = result.replaceAll(RegExp(r'_{3}(.+?)_{3}'), r'$1');

  result = result.replaceAll(RegExp(r'\*{2}(.+?)\*{2}'), r'$1');
  result = result.replaceAll(RegExp(r'_{2}(.+?)_{2}'), r'$1');

  result = result.replaceAll(RegExp(r'\*(.+?)\*'), r'$1');
  result = result.replaceAll(RegExp(r'_(.+?)_'), r'$1');

  result = result.replaceAll(RegExp(r'`(.+?)`'), r'$1');

  result = result.replaceAll(RegExp(r'^[-*]{3,}\s*$', multiLine: true), '');

  result = result.replaceAll(RegExp(r'^>\s+', multiLine: true), '');

  result = result.replaceAll(RegExp(r'\n{3,}'), '\n\n');

  return result.trim();
}

class ChatSession {
  final String id;
  final String title;
  final DateTime createdAt;
  final List<Map<String, dynamic>> messages;

  ChatSession({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.messages,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'createdAt': createdAt.toIso8601String(),
    'messages': messages,
  };

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    DateTime parseDate;
    if (json['createdAt'] == null) {
      parseDate = DateTime.now();
    } else if (json['createdAt'] is String) {
      parseDate = DateTime.parse(json['createdAt']);
    } else {
      parseDate = DateTime.now();
    }

    return ChatSession(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] ?? 'New Chat',
      createdAt: parseDate,
      messages: json['messages'] != null
          ? List<Map<String, dynamic>>.from(json['messages'])
          : [],
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _typingAnimController;

  List<ChatSession> _chatHistory = [];
  String? _currentSessionId;
  String? _sessionId;

  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;

  static String _currentTime() {
    final now = DateTime.now();
    final h = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final m = now.minute.toString().padLeft(2, '0');
    final ampm = now.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ampm';
  }

  static String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  void initState() {
    super.initState();
    _typingAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
    _loadChatHistory();
    _checkAndFixCorruptedData();
  }

  Future<void> _checkAndFixCorruptedData() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionsJson = prefs.getStringList('chat_sessions') ?? [];
    bool needsFix = false;

    for (String jsonStr in sessionsJson) {
      try {
        final Map<String, dynamic> jsonData = jsonDecode(jsonStr);
        if (jsonData['createdAt'] == null || jsonData['id'] == null) {
          needsFix = true;
          break;
        }
      } catch (e) {
        needsFix = true;
        break;
      }
    }

    if (needsFix) {
      await prefs.remove('chat_sessions');
      print('Corrupted chat history cleared');
    }

    _loadChatHistory();
  }

  Future<void> _loadChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionsJson = prefs.getStringList('chat_sessions') ?? [];

    final List<ChatSession> loadedSessions = [];

    for (String jsonStr in sessionsJson) {
      try {
        final Map<String, dynamic> jsonData = jsonDecode(jsonStr);
        final session = ChatSession.fromJson(jsonData);
        loadedSessions.add(session);
      } catch (e) {
        print('Error loading session: $e');
      }
    }

    setState(() {
      _chatHistory = loadedSessions;
      _chatHistory.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });

    if (_chatHistory.isNotEmpty) {
      _loadSession(_chatHistory.first);
    } else {
      _startNewChat();
    }
  }

  Future<void> _saveChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionsJson = _chatHistory
        .map((session) => jsonEncode(session.toJson()))
        .toList();
    await prefs.setStringList('chat_sessions', sessionsJson);
  }

  Future<void> _saveCurrentToHistory() async {
    if (_messages.isEmpty || _messages.length <= 1) return;

    final userMessages = _messages.where((m) => m['sender'] == 'user').toList();
    if (userMessages.isEmpty) return;

    final title = userMessages.last['text'] as String;
    final shortTitle = title.length > 40
        ? '${title.substring(0, 40)}...'
        : title;

    final cleanMessages = _messages.map((msg) {
      return {
        'sender': msg['sender'],
        'text': msg['text'] ?? '',
        'time': msg['time'] ?? _currentTime(),
        'images': msg['images'] ?? [],
      };
    }).toList();

    final existingIndex = _chatHistory.indexWhere(
      (s) => s.id == (_currentSessionId ?? ''),
    );

    if (existingIndex != -1) {
      _chatHistory[existingIndex] = ChatSession(
        id: _chatHistory[existingIndex].id,
        title: shortTitle,
        createdAt: _chatHistory[existingIndex].createdAt,
        messages: cleanMessages,
      );
    } else if (_currentSessionId != null) {
      _chatHistory.insert(
        0,
        ChatSession(
          id: _currentSessionId!,
          title: shortTitle,
          createdAt: DateTime.now(),
          messages: cleanMessages,
        ),
      );
    }

    await _saveChatHistory();
  }

  void _startNewChat() async {
    await _saveCurrentToHistory();
    setState(() {
      _currentSessionId = DateTime.now().millisecondsSinceEpoch.toString();
      _sessionId = null;
      _messages = [
        {
          "sender": "bot",
          "text":
              "✨ Hello! I'm your AI shopping assistant\n\nI can help you with:\n• 📦 Product questions & prices\n• 🚚 Order tracking\n• 💳 Payment support\n• 🔄 Returns & refunds\n\nHow can I help you today?",
          "time": _currentTime(),
          "images": [],
        },
      ];
    });
    if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  void _loadSession(ChatSession session) async {
    await _saveCurrentToHistory();
    setState(() {
      _currentSessionId = session.id;
      _sessionId = null;
      _messages = List.from(session.messages);
    });
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
    _scrollToBottom();
  }

  Future<void> _deleteSession(String id) async {
    setState(() {
      _chatHistory.removeWhere((s) => s.id == id);
    });
    await _saveChatHistory();

    if (_chatHistory.isEmpty) {
      _startNewChat();
    } else if (_currentSessionId == id) {
      _loadSession(_chatHistory.first);
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.insert(0, {
        "sender": "user",
        "text": text,
        "time": _currentTime(),
      });
      _isLoading = true;
    });

    _messageController.clear();
    await _saveCurrentToHistory();

    try {
      final response = await ChatService.sendMessage(text, _sessionId);

      if (mounted) {
        String rawText = response['bot_message']['text'] as String;
        final imageUrls = response['matched_image_urls'] != null
            ? List<String>.from(response['matched_image_urls'])
            : [];

        rawText = _stripMarkdown(rawText);

        setState(() {
          _sessionId = response['session_id'];
          _messages.insert(0, {
            "sender": "bot",
            "text": rawText,
            "time": _currentTime(),
            "images": imageUrls,
          });
          _isLoading = false;
        });
        await _saveCurrentToHistory();
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.insert(0, {
            "sender": "bot",
            "text":
                "❌ Sorry, I couldn't reach the server. Make sure your Django backend is running.",
            "time": _currentTime(),
            "images": [],
          });
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _typingAnimController.dispose();
    _saveCurrentToHistory();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;

    final bg = isDark ? AppColors.darkBg : AppColors.lightBg;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final subText = isDark ? AppColors.darkSubText : AppColors.lightSubText;
    final inputBg = isDark ? AppColors.darkInputBg : AppColors.lightInputBg;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: bg,

      drawer: _buildHistoryDrawer(
        isDark,
        surface,
        textColor,
        subText,
        borderColor,
      ),

      body: Column(
        children: [
          _buildHeader(
            isDark,
            surface,
            textColor,
            subText,
            borderColor,
            padding,
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: true,
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.04,
                vertical: 12,
              ),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isLoading && index == 0) {
                  return _buildTypingIndicator(isDark);
                }
                final msgIndex = _isLoading ? index - 1 : index;
                final message = _messages[msgIndex];
                final isBot = message["sender"] == "bot";
                return _buildMessageBubble(
                  message,
                  isBot,
                  isDark,
                  textColor,
                  subText,
                  size,
                );
              },
            ),
          ),
          _buildInputBar(
            isDark,
            surface,
            inputBg,
            textColor,
            subText,
            borderColor,
            padding,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryDrawer(
    bool isDark,
    Color surface,
    Color textColor,
    Color subText,
    Color borderColor,
  ) {
    final padding = MediaQuery.of(context).padding;

    return Drawer(
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
              top: padding.top + 16,
              left: 20,
              right: 20,
              bottom: 16,
            ),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBg : AppColors.lightBg,
              border: Border(bottom: BorderSide(color: borderColor, width: 1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Image.network(
                        kGrokLogoUrl,
                        fit: BoxFit.contain,
                        color: AppColors.accent,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.smart_toy_rounded,
                          color: AppColors.accent,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Chat History',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                GestureDetector(
                  onTap: _startNewChat,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 11,
                      horizontal: 14,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.accent, AppColors.accentLight],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accentGlow,
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.add_rounded, color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'New Chat',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: _chatHistory.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.history_rounded,
                          size: 48,
                          color: subText.withOpacity(0.4),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No chat history yet',
                          style: TextStyle(color: subText, fontSize: 14),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    itemCount: _chatHistory.length,
                    itemBuilder: (context, index) {
                      final session = _chatHistory[index];
                      final isActive = session.id == _currentSessionId;
                      return _buildHistoryTile(
                        session,
                        isActive,
                        isDark,
                        textColor,
                        subText,
                        borderColor,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTile(
    ChatSession session,
    bool isActive,
    bool isDark,
    Color textColor,
    Color subText,
    Color borderColor,
  ) {
    return Dismissible(
      key: Key(session.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.red, size: 20),
      ),
      onDismissed: (_) => _deleteSession(session.id),
      child: GestureDetector(
        onTap: () => _loadSession(session),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.accent.withOpacity(0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isActive
                ? Border.all(color: AppColors.accent.withOpacity(0.3), width: 1)
                : null,
          ),
          child: Row(
            children: [
              Icon(
                Icons.chat_bubble_outline_rounded,
                size: 16,
                color: isActive ? AppColors.accent : subText,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isActive ? AppColors.accent : textColor,
                        fontSize: 13,
                        fontWeight: isActive
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(session.createdAt),
                      style: TextStyle(color: subText, fontSize: 11),
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

  Widget _buildHeader(
    bool isDark,
    Color surface,
    Color textColor,
    Color subText,
    Color borderColor,
    EdgeInsets padding,
  ) {
    return Container(
      padding: EdgeInsets.only(
        top: padding.top + 8,
        bottom: 12,
        left: 16,
        right: 16,
      ),
      decoration: BoxDecoration(
        color: surface,
        border: Border(bottom: BorderSide(color: borderColor, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBg : AppColors.lightBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.menu_rounded, size: 20, color: textColor),
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Image.network(
                        kGrokLogoUrl,
                        fit: BoxFit.contain,
                        color: isDark ? Colors.white : Colors.black,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.smart_toy_rounded,
                          color: AppColors.accent,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Grok AI Assistant',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Online • Ready to help',
                  style: TextStyle(color: AppColors.success, fontSize: 12),
                ),
              ],
            ),
          ),

          GestureDetector(
            onTap: _startNewChat,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBg : AppColors.lightBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.edit_note_rounded, size: 18, color: textColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
    Map<String, dynamic> message,
    bool isBot,
    bool isDark,
    Color textColor,
    Color subText,
    Size size,
  ) {
    final botBubble = isDark
        ? AppColors.darkBotBubble
        : AppColors.lightBotBubble;
    final userBubble = isDark
        ? AppColors.darkUserBubble
        : AppColors.lightUserBubble;
    final bubbleColor = isBot ? botBubble : userBubble;
    final msgTextColor = isBot ? textColor : Colors.white;
    final msgText = message["text"] ?? "";

    List<String> imageUrls = [];
    if (message.containsKey('images') && message['images'] != null) {
      final images = message['images'];
      if (images is List) {
        imageUrls = List<String>.from(images);
      }
    }

    if (imageUrls.isEmpty && isBot) {
      imageUrls = _extractImageUrls(msgText);
    }

    String displayText = msgText;
    for (var url in imageUrls) {
      displayText = displayText.replaceAll(url, '');
    }
    displayText = displayText.trim();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isBot
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isBot) ...[
            Container(
              width: 32,
              height: 32,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.accent, AppColors.accentLight],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Image.network(
                kGrokLogoUrl,
                fit: BoxFit.contain,
                color: Colors.white,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.smart_toy_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isBot
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              children: [
                if (displayText.isNotEmpty)
                  Container(
                    constraints: BoxConstraints(maxWidth: size.width * 0.72),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: bubbleColor,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(18),
                        topRight: const Radius.circular(18),
                        bottomLeft: Radius.circular(isBot ? 4 : 18),
                        bottomRight: Radius.circular(isBot ? 18 : 4),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isBot
                              ? Colors.black.withOpacity(isDark ? 0.2 : 0.06)
                              : AppColors.accent.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                      border: isBot
                          ? Border.all(
                              color: isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder,
                              width: 1,
                            )
                          : null,
                    ),
                    child: _buildMessageContent(
                      displayText,
                      msgTextColor,
                      isBot,
                    ),
                  ),

                if (imageUrls.isNotEmpty) ...[
                  if (displayText.isNotEmpty) const SizedBox(height: 8),
                  ...imageUrls.asMap().entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildNetworkImage(entry.value, size, isDark),
                    );
                  }),
                ],

                const SizedBox(height: 4),
                Text(
                  message["time"] ?? "",
                  style: TextStyle(
                    color: subText,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (!isBot) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.accent, AppColors.accentLight],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.person_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNetworkImage(String url, Size size, bool isDark) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              constraints: BoxConstraints(maxWidth: size.width * 0.9),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(url),
              ),
            ),
          ),
        );
      },
      child: Container(
        constraints: BoxConstraints(
          maxWidth: size.width * 0.72,
          maxHeight: 200,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.network(
            url,
            fit: BoxFit.cover,
            width: double.infinity,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                height: 160,
                color: isDark ? AppColors.darkBotBubble : AppColors.lightBg,
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                        : null,
                    color: AppColors.accent,
                  ),
                ),
              );
            },
            errorBuilder: (_, __, ___) => Container(
              height: 120,
              color: isDark ? AppColors.darkBotBubble : AppColors.lightBg,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.broken_image_rounded,
                    color: isDark
                        ? AppColors.darkSubText
                        : AppColors.lightSubText,
                    size: 32,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tap to retry',
                    style: TextStyle(color: AppColors.accent, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageContent(String text, Color textColor, bool isBot) {
    if (text.contains('\n•') || text.contains('\n-') || text.contains('•')) {
      final lines = text.split('\n');
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: lines.map((line) {
          final trimmed = line.trim();
          if (trimmed.startsWith('•') ||
              trimmed.startsWith('-') ||
              trimmed.startsWith('✨') ||
              trimmed.startsWith('📂') ||
              trimmed.startsWith('💰')) {
            return Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trimmed.substring(0, 2),
                    style: TextStyle(
                      color: isBot ? AppColors.accent : Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      trimmed.substring(2).trim(),
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          if (trimmed.isEmpty) return const SizedBox(height: 4);
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              trimmed,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                height: 1.5,
                fontWeight: trimmed.endsWith(':')
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      );
    }
    return Text(text, style: const TextStyle(fontSize: 14, height: 1.5));
  }

  Widget _buildTypingIndicator(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 32,
            height: 32,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.accent, AppColors.accentLight],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Image.network(
              kGrokLogoUrl,
              fit: BoxFit.contain,
              color: Colors.white,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.smart_toy_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkBotBubble
                  : AppColors.lightBotBubble,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
              ),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: AnimatedBuilder(
              animation: _typingAnimController,
              builder: (context, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (i) {
                    final delay = i * 0.3;
                    final value =
                        (((_typingAnimController.value - delay) % 1.0 + 1.0) %
                        1.0);
                    final opacity = value < 0.5 ? value * 2 : (1.0 - value) * 2;
                    return Container(
                      margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(
                          0.4 + opacity * 0.6,
                        ),
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(
    bool isDark,
    Color surface,
    Color inputBg,
    Color textColor,
    Color subText,
    Color borderColor,
    EdgeInsets padding,
  ) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: surface,
        border: Border(top: BorderSide(color: borderColor, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: inputBg,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      enabled: !_isLoading,
                      onSubmitted: (_) => _isLoading ? null : _sendMessage(),
                      style: TextStyle(color: textColor, fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'Ask me anything...',
                        hintStyle: TextStyle(color: subText, fontSize: 15),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                      ),
                      maxLines: 3,
                      minLines: 1,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.emoji_emotions_outlined,
                      color: subText,
                      size: 22,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _isLoading ? null : _sendMessage,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: _isLoading
                    ? null
                    : const LinearGradient(
                        colors: [AppColors.accent, AppColors.accentLight],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                color: _isLoading
                    ? (isDark ? AppColors.darkBorder : AppColors.lightBorder)
                    : null,
                borderRadius: BorderRadius.circular(16),
                boxShadow: _isLoading
                    ? []
                    : [
                        BoxShadow(
                          color: AppColors.accentGlow,
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: _isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(14),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.accent,
                      ),
                    )
                  : const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
