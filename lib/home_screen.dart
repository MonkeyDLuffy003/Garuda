import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'constants.dart';
import 'api_service.dart';
import 'memory_screen.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final bool isError;
  final DateTime time;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.isError = false,
    DateTime? time,
  }) : time = time ?? DateTime.now();
}

class HomeScreen extends StatefulWidget {
  final String username;
  final bool isDeveloper;
  final String referralCode;
  final int remaining;
  final String welcomeMessage;

  const HomeScreen({
    super.key,
    required this.username,
    required this.isDeveloper,
    required this.referralCode,
    required this.remaining,
    this.welcomeMessage = '',
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _msgCtrl      = TextEditingController();
  final _scrollCtrl   = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping      = false;
  late int _remaining;
  late bool _isDev;

  @override
  void initState() {
    super.initState();
    _remaining = widget.remaining;
    _isDev     = widget.isDeveloper ||
                 widget.username.toLowerCase() == devUsername.toLowerCase();
    _addWelcome();
    _refreshStatus();
  }

  void _addWelcome() {
    final greeting = widget.welcomeMessage.isNotEmpty
        ? widget.welcomeMessage
        : 'Welcome, ${widget.username}! I am Garuda.\n\n'
          'Ask me:\n'
          '• Any research topic\n'
          '• Latest news / tech news / sports news\n'
          '• Medical or educational topics\n\n'
          'Powered by Gemini Pro.';
    _messages.add(ChatMessage(text: greeting, isUser: false));

    if (widget.referralCode.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _messages.add(ChatMessage(
              text: '🎁 Your referral code: ${widget.referralCode}\n'
                    'Share it to earn +2 extra requests/day per friend!',
              isUser: false,
            ));
          });
          _scrollToBottom();
        }
      });
    }
  }

  Future<void> _refreshStatus() async {
    final result = await ApiService.status(widget.username);
    if (result['success'] == true && mounted) {
      setState(() {
        _remaining = result['remaining'] ?? _remaining;
        _isDev     = result['developer'] ?? _isDev ||
                     widget.username.toLowerCase() == devUsername.toLowerCase();
      });
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final query = _msgCtrl.text.trim();
    if (query.isEmpty || _isTyping) return;

    _msgCtrl.clear();
    setState(() {
      _messages.add(ChatMessage(text: query, isUser: true));
      _isTyping = true;
    });
    _scrollToBottom();

    final result = await ApiService.sendQuery(
      username: widget.username, query: query);

    final isError = result['success'] != true;
    final response = isError
        ? (result['message'] ?? 'Something went wrong.')
        : result['response'] ?? '';

    final ytQuery = Uri.encodeComponent(query);
    final fullResponse = isError
        ? response
        : '$response\n\n🎬 YouTube: https://www.youtube.com/results?search_query=$ytQuery';

    if (mounted) {
      setState(() {
        _isTyping = false;
        _messages.add(ChatMessage(
          text: fullResponse, isUser: false, isError: isError));
        if (!isError) {
          _remaining = result['remaining'] ?? _remaining;
          _isDev     = result['developer'] ?? _isDev ||
                       widget.username.toLowerCase() == devUsername.toLowerCase();
        }
      });
      _scrollToBottom();
    }
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildChatArea()),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(gradient: headerGradient),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.air, size: 26, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('GARUDA RESEARCH', style: appTitleStyle),
                    const Text('Voice Agent Bot', style: appSubtitleStyle),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3), width: 1),
                ),
                child: Text(
                  _isDev ? 'DEV ∞' : '$_remaining left',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _isDev
                        ? successGreen
                        : (_remaining > 5 ? Colors.white : errorRed),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MemoryScreen(
                      messages: _messages,
                      referralCode: widget.referralCode,
                      username: widget.username,
                    ),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('MEM',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatArea() {
    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      itemCount: _messages.length + (_isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (_isTyping && index == _messages.length) {
          return _buildTypingIndicator();
        }
        return _buildBubble(_messages[index]);
      },
    );
  }

  Widget _buildBubble(ChatMessage msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            msg.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!msg.isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: headerGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.air, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: msg.isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  msg.isUser ? 'You' : 'GARUDA',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: msg.isUser ? accentOrange : accentTeal,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: msg.isError
                        ? errorBubble
                        : (msg.isUser ? userBubble : botBubble),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(msg.isUser ? 16 : 4),
                      bottomRight: Radius.circular(msg.isUser ? 4 : 16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: SelectableText(
                    msg.text,
                    style: TextStyle(
                      fontSize: 13,
                      color: msg.isError ? errorRed : textDark,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (msg.isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: accentOrange,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.person, size: 18, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: headerGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.air, size: 18, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: botBubble,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) => _dot(i)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 600 + (index * 200)),
      builder: (context, value, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: accentTeal.withOpacity(0.3 + (value * 0.7)),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  Widget _buildInputBar() {
    return Container(
      color: surfaceWhite,
      padding: EdgeInsets.only(
        left: 12, right: 12, top: 10,
        bottom: MediaQuery.of(context).padding.bottom + 10,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: inputColor,
                borderRadius: BorderRadius.circular(28),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: TextField(
                controller: _msgCtrl,
                style: const TextStyle(fontSize: 14, color: textDark),
                decoration: InputDecoration(
                  hintText: 'Ask Garuda anything...',
                  hintStyle: TextStyle(fontSize: 13, color: textGray),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onSubmitted: (_) => _sendMessage(),
                textInputAction: TextInputAction.send,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _showMicPopup,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: headerGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: accentTeal.withOpacity(0.3),
                    blurRadius: 8, offset: const Offset(0, 3)),
                ],
              ),
              child: const Icon(Icons.mic, color: Colors.white, size: 22),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: accentOrange,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: accentOrange.withOpacity(0.3),
                    blurRadius: 8, offset: const Offset(0, 3)),
                ],
              ),
              child: const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  void _showMicPopup() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)),
        title: const Text('Voice Input',
          style: TextStyle(fontWeight: FontWeight.w700, color: textDark)),
        content: const Text(
          'Voice input will be available in the next update.\nPlease type your query.',
          style: TextStyle(color: textGray, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK',
              style: TextStyle(color: accentTeal, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
