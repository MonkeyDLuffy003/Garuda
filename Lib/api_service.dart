import 'dart:convert';
import 'package:http/http.dart' as http;
import 'constants.dart';

class ApiService {
  static const Duration timeout = Duration(seconds: 20);

  // ─────────────────────────────────────────────
  // REGISTER
  // ─────────────────────────────────────────────
  static Future<Map<String, dynamic>> register({
    required String username,
    required String password,
    String referralCode = '',
    String devCode = '',
  }) async {
    try {
      final resp = await http
          .post(
            Uri.parse('$serverUrl/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'username': username,
              'password': password,
              'referral_code': referralCode,
              'dev_code': devCode,
            }),
          )
          .timeout(timeout);
      return jsonDecode(resp.body);
    } catch (e) {
      return {'success': false, 'message': 'Cannot reach server. Check internet.'};
    }
  }

  // ─────────────────────────────────────────────
  // LOGIN
  // ─────────────────────────────────────────────
  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
    String devCode = '',
  }) async {
    try {
      final resp = await http
          .post(
            Uri.parse('$serverUrl/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'username': username,
              'password': password,
              'dev_code': devCode,
            }),
          )
          .timeout(timeout);
      return jsonDecode(resp.body);
    } catch (e) {
      return {'success': false, 'message': 'Cannot reach server. Check internet.'};
    }
  }

  // ─────────────────────────────────────────────
  // CHAT
  // ─────────────────────────────────────────────
  static Future<Map<String, dynamic>> chat({
    required String username,
    required String query,
  }) async {
    try {
      final resp = await http
          .post(
            Uri.parse('$serverUrl/chat'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'username': username, 'query': query}),
          )
          .timeout(timeout);
      return jsonDecode(resp.body);
    } catch (e) {
      return {'success': false, 'message': 'Cannot reach server. Check internet.'};
    }
  }

  // ─────────────────────────────────────────────
  // RESEARCH
  // ─────────────────────────────────────────────
  static Future<Map<String, dynamic>> research({
    required String username,
    required String query,
    String category = '',
  }) async {
    try {
      final resp = await http
          .post(
            Uri.parse('$serverUrl/research'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'username': username,
              'query': query,
              'category': category,
            }),
          )
          .timeout(timeout);
      return jsonDecode(resp.body);
    } catch (e) {
      return {'success': false, 'message': 'Cannot reach server. Check internet.'};
    }
  }

  // ─────────────────────────────────────────────
  // STATUS
  // ─────────────────────────────────────────────
  static Future<Map<String, dynamic>> status(String username) async {
    try {
      final resp = await http
          .get(Uri.parse('$serverUrl/status?username=$username'))
          .timeout(timeout);
      return jsonDecode(resp.body);
    } catch (e) {
      return {'success': false};
    }
  }

  // ─────────────────────────────────────────────
  // ROUTE QUERY
  // ─────────────────────────────────────────────
  static Future<Map<String, dynamic>> sendQuery({
    required String username,
    required String query,
  }) async {
    final q = query.toLowerCase();
    if (q.contains('tech news')) {
      return research(username: username, query: query, category: 'tech');
    } else if (q.contains('sports news') || q.contains('sports')) {
      return research(username: username, query: query, category: 'sports');
    } else if (q.contains('news') || q.contains('latest news')) {
      return research(username: username, query: query, category: 'general');
    } else {
      final resResult = await research(username: username, query: query);
      if (resResult['success'] == true && resResult['response'] != null) {
        return resResult;
      }
      return chat(username: username, query: query);
    }
  }
}
