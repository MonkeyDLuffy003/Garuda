import 'package:flutter/material.dart';
import 'constants.dart';
import 'api_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Step 1: dev code gate
  bool _unlocked = false;
  bool _loading  = false;
  String _error  = '';

  final _codeCtrl   = TextEditingController();
  final _chatCtrl   = TextEditingController();
  final _searchCtrl = TextEditingController();
  final _groqCtrl   = TextEditingController();

  bool _obscureCode   = true;
  bool _obscureChat   = true;
  bool _obscureSearch = true;
  bool _obscureGroq   = true;

  @override
  void initState() {
    super.initState();
    _loadKeys();
  }

  Future<void> _loadKeys() async {
    _chatCtrl.text   = await ApiService.getChatKey();
    _searchCtrl.text = await ApiService.getSearchKey();
    _groqCtrl.text   = await ApiService.getGroqKey();
  }

  void _unlock() {
    if (_codeCtrl.text.trim() == devCode) {
      setState(() { _unlocked = true; _error = ''; });
    } else {
      setState(() => _error = 'Invalid developer code.');
    }
  }

  Future<void> _saveKeys() async {
    setState(() => _loading = true);
    await ApiService.saveKeys(
      chatKey:   _chatCtrl.text,
      searchKey: _searchCtrl.text,
      groqKey:   _groqCtrl.text,
    );
    setState(() => _loading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Keys saved!'),
            backgroundColor: Color(0xFF1B8A7A)));
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _codeCtrl.dispose(); _chatCtrl.dispose();
    _searchCtrl.dispose(); _groqCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _unlocked ? _buildKeysForm() : _buildCodeGate(),
            ),
          ),
        ],
      ),
    );
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
              const Text('Developer Settings', style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCodeGate() {
    return Container(
      decoration: BoxDecoration(
        color: surfaceWhite, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06),
            blurRadius: 20, offset: const Offset(0, 6))],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lock_outline, size: 40, color: Color(0xFF1B8A7A)),
          const SizedBox(height: 16),
          const Text('Developer Access', style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w700, color: textDark)),
          const SizedBox(height: 8),
          Text('Enter developer code to access API key settings.',
              style: TextStyle(fontSize: 13, color: textGray)),
          const SizedBox(height: 24),
          _buildField(ctrl: _codeCtrl, hint: 'Developer code',
              icon: Icons.key_outlined,
              obscure: _obscureCode,
              onToggle: () => setState(() => _obscureCode = !_obscureCode)),
          if (_error.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(_error, style: const TextStyle(color: errorRed, fontSize: 13)),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity, height: 52,
            child: ElevatedButton(
              onPressed: _unlock,
              style: ElevatedButton.styleFrom(
                backgroundColor: accentTeal, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26))),
              child: const Text('UNLOCK', style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: 2)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeysForm() {
    return Container(
      decoration: BoxDecoration(
        color: surfaceWhite, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06),
            blurRadius: 20, offset: const Offset(0, 6))],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('API Keys', style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w700, color: textDark)),
          const SizedBox(height: 6),
          Text('Keys stored only on this device.',
              style: TextStyle(fontSize: 12, color: textGray)),
          const SizedBox(height: 24),
          const Text('Gemini Key 1 — Chat Brain',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                  color: accentTeal)),
          const SizedBox(height: 8),
          _buildField(ctrl: _chatCtrl, hint: 'AIza...',
              icon: Icons.smart_toy_outlined,
              obscure: _obscureChat,
              onToggle: () => setState(() => _obscureChat = !_obscureChat)),
          const SizedBox(height: 16),
          const Text('Gemini Key 2 — Search + Research',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                  color: accentTeal)),
          const SizedBox(height: 8),
          _buildField(ctrl: _searchCtrl, hint: 'AIza...',
              icon: Icons.search_outlined,
              obscure: _obscureSearch,
              onToggle: () => setState(() => _obscureSearch = !_obscureSearch)),
          const SizedBox(height: 16),
          const Text('Groq Key — Translation',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                  color: accentTeal)),
          const SizedBox(height: 8),
          _buildField(ctrl: _groqCtrl, hint: 'gsk_...',
              icon: Icons.translate_outlined,
              obscure: _obscureGroq,
              onToggle: () => setState(() => _obscureGroq = !_obscureGroq)),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity, height: 52,
            child: ElevatedButton(
              onPressed: _loading ? null : _saveKeys,
              style: ElevatedButton.styleFrom(
                backgroundColor: accentTeal, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26))),
              child: _loading
                  ? const SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('SAVE KEYS', style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: 2)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController ctrl,
    required String hint,
    required IconData icon,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
          color: inputColor, borderRadius: BorderRadius.circular(14)),
      child: TextField(
        controller: ctrl,
        obscureText: obscure,
        style: const TextStyle(fontSize: 13, color: textDark),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontSize: 12, color: textGray),
          prefixIcon: Icon(icon, size: 20, color: textGray),
          suffixIcon: IconButton(
            icon: Icon(obscure ? Icons.visibility_off : Icons.visibility,
                size: 20, color: textGray),
            onPressed: onToggle,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
