import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'constants.dart';
import 'home_screen.dart';

class MemoryScreen extends StatefulWidget {
  final List<ChatMessage> messages;
  final String referralCode;
  final String username;

  const MemoryScreen({
    super.key,
    required this.messages,
    required this.referralCode,
    required this.username,
  });

  @override
  State<MemoryScreen> createState() => _MemoryScreenState();
}

class _MemoryScreenState extends State<MemoryScreen> {
  @override
  Widget build(BuildContext context) {
    final history = widget.messages
        .where((m) => m.isUser)
        .toList()
        .reversed
        .toList();

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          _buildHeader(context),
          if (widget.referralCode.isNotEmpty) _buildReferralBar(),
          Expanded(
            child: history.isEmpty
                ? _buildEmpty()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final msg = history[index];
                      final response = _findResponse(msg);
                      return _buildHistoryItem(msg, response, index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _findResponse(ChatMessage userMsg) {
    final idx = widget.messages.indexOf(userMsg);
    if (idx >= 0 && idx + 1 < widget.messages.length) {
      final next = widget.messages[idx + 1];
      if (!next.isUser) return next.text;
    }
    return '';
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: headerGradient),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new,
                    size: 16, color: Colors.white),
                ),
              ),
              const SizedBox(width: 14),
              const Icon(Icons.history, color: Colors.white, size: 22),
              const SizedBox(width: 10),
              const Text('Research Memory',
                style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w700,
                  color: Colors.white)),
              const Spacer(),
              GestureDetector(
                onTap: _confirmClear,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: errorRed.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('CLEAR',
                    style: TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w700,
                      color: errorRed)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReferralBar() {
    return Container(
      color: accentTeal.withOpacity(0.08),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.card_giftcard, size: 16, color: accentTeal),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Your referral code: ${widget.referralCode}',
              style: const TextStyle(
                fontSize: 12, color: accentTeal,
                fontWeight: FontWeight.w600),
            ),
          ),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: widget.referralCode));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Referral code copied!'),
                  backgroundColor: accentTeal,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Icon(Icons.copy, size: 16, color: accentTeal),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off,
            size: 64, color: textGray.withOpacity(0.4)),
          const SizedBox(height: 16),
          Text('No history yet',
            style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w600,
              color: textGray.withOpacity(0.6))),
          const SizedBox(height: 8),
          Text('Ask Garuda something!',
            style: TextStyle(fontSize: 13, color: textGray.withOpacity(0.5))),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(ChatMessage msg, String response, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Query row
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: accentOrange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.person,
                    size: 16, color: accentOrange),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    msg.text.length > 80
                        ? '${msg.text.substring(0, 80)}...'
                        : msg.text,
                    style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600,
                      color: textDark),
                  ),
                ),
              ],
            ),
          ),
          if (response.isNotEmpty) ...[
            const Divider(height: 1, color: Color(0xFFEEF2F0)),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      gradient: headerGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.air,
                      size: 16, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      response.length > 120
                          ? '${response.substring(0, 120)}...'
                          : response,
                      style: TextStyle(
                        fontSize: 12, color: textGray, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _confirmClear() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear History',
          style: TextStyle(fontWeight: FontWeight.w700, color: textDark)),
        content: const Text('Clear all chat history?',
          style: TextStyle(color: textGray)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
              style: TextStyle(color: textGray)),
          ),
          TextButton(
            onPressed: () {
              widget.messages.clear();
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Clear',
              style: TextStyle(
                color: errorRed, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
