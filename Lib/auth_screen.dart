import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';
import 'api_service.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  bool _isLogin = true;
  bool _isLoading = false;
  bool _showDevCode = false;
  String _errorMsg = '';

  final _userCtrl    = TextEditingController();
  final _passCtrl    = TextEditingController();
  final _refCtrl     = TextEditingController();
  final _devCtrl     = TextEditingController();
  bool _obscurePass  = true;
  bool _obscureDev   = true;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 400));
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(_animCtrl);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _userCtrl.dispose();
    _passCtrl.dispose();
    _refCtrl.dispose();
    _devCtrl.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
      _errorMsg = '';
      _showDevCode = false;
    });
  }

  Future<void> _submit() async {
    final username = _userCtrl.text.trim();
    final password = _passCtrl.text.trim();
    final refCode  = _refCtrl.text.trim();
    final devCode  = _devCtrl.text.trim();

    if (username.length < 3) {
      setState(() => _errorMsg = 'Username must be at least 3 characters.');
      return;
    }
    if (password.length < 4) {
      setState(() => _errorMsg = 'Password must be at least 4 characters.');
      return;
    }

    setState(() { _isLoading = true; _errorMsg = ''; });

    Map<String, dynamic> result;
    if (_isLogin) {
      result = await ApiService.login(
        username: username, password: password, devCode: devCode);
    } else {
      result = await ApiService.register(
        username: username, password: password,
        referralCode: refCode, devCode: devCode);
    }

    setState(() => _isLoading = false);

    if (result['success'] == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', username);
      await prefs.setBool('is_developer', result['role'] == 'developer');
      await prefs.setString('referral_code', result['referral_code'] ?? '');
      await prefs.setInt('remaining', result['remaining'] ?? 20);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(
            username: username,
            isDeveloper: result['role'] == 'developer',
            referralCode: result['referral_code'] ?? '',
            remaining: result['remaining'] ?? 20,
            welcomeMessage: result['message'] ?? '',
          ),
        ),
      );
    } else {
      setState(() => _errorMsg = result['message'] ?? 'Something went wrong.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 48),
                // Logo area
                _buildLogoSection(),
                const SizedBox(height: 40),
                // Auth card
                _buildAuthCard(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: headerGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: headerLight.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.air, size: 48, color: Colors.white),
        ),
        const SizedBox(height: 16),
        const Text(
          'GARUDA',
          style: TextStyle(
            fontSize: 28, fontWeight: FontWeight.w900,
            color: headerDark, letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'RESEARCH VOICE AGENT BOT',
          style: TextStyle(
            fontSize: 11, letterSpacing: 2,
            color: textGray, fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAuthCard() {
    return Container(
      decoration: BoxDecoration(
        color: surfaceWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: headerDark.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isLogin ? 'Login to your account' : 'Create your account',
            style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.w700, color: textDark),
          ),
          const SizedBox(height: 24),

          // Username
          _buildField(
            controller: _userCtrl,
            hint: 'Username',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 14),

          // Password
          _buildField(
            controller: _passCtrl,
            hint: 'Password',
            icon: Icons.lock_outline,
            isPassword: true,
            obscure: _obscurePass,
            onToggleObscure: () => setState(() => _obscurePass = !_obscurePass),
          ),
          const SizedBox(height: 14),

          // Register-only fields
          if (!_isLogin) ...[
            _buildField(
              controller: _refCtrl,
              hint: 'Referral code (optional)',
              icon: Icons.card_giftcard_outlined,
            ),
            const SizedBox(height: 14),
          ],

          // Dev code toggle
          GestureDetector(
            onTap: () => setState(() => _showDevCode = !_showDevCode),
            child: Row(
              children: [
                Icon(Icons.developer_mode, size: 16, color: textGray),
                const SizedBox(width: 6),
                Text(
                  _showDevCode ? 'Hide developer code' : 'Have a developer code?',
                  style: TextStyle(fontSize: 12, color: textGray),
                ),
              ],
            ),
          ),

          if (_showDevCode) ...[
            const SizedBox(height: 12),
            _buildField(
              controller: _devCtrl,
              hint: 'Developer code',
              icon: Icons.key_outlined,
              isPassword: true,
              obscure: _obscureDev,
              onToggleObscure: () => setState(() => _obscureDev = !_obscureDev),
            ),
          ],

          const SizedBox(height: 16),

          // Error message
          if (_errorMsg.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: errorRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, size: 16, color: errorRed),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(_errorMsg,
                      style: const TextStyle(fontSize: 12, color: errorRed)),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 20),

          // Submit button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: accentTeal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26)),
                elevation: 4,
                shadowColor: accentTeal.withOpacity(0.4),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                  : Text(
                      _isLogin ? 'LOGIN' : 'REGISTER',
                      style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w800,
                        letterSpacing: 2),
                    ),
            ),
          ),

          const SizedBox(height: 16),

          // Toggle
          Center(
            child: GestureDetector(
              onTap: _toggleMode,
              child: RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 13, color: textGray),
                  children: [
                    TextSpan(
                      text: _isLogin
                          ? "Don't have an account? "
                          : "Already have an account? "),
                    TextSpan(
                      text: _isLogin ? 'Register' : 'Login',
                      style: const TextStyle(
                        color: accentTeal, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? onToggleObscure,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: inputColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? obscure : false,
        style: const TextStyle(fontSize: 14, color: textDark),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontSize: 13, color: textGray),
          prefixIcon: Icon(icon, size: 20, color: textGray),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscure ? Icons.visibility_off : Icons.visibility,
                    size: 20, color: textGray),
                  onPressed: onToggleObscure,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
