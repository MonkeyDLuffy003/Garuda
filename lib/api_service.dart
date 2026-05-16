import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String geminiBase =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro:generateContent';
  static const String groqUrl =
      'https://api.groq.com/openai/v1/chat/completions';
  static const String groqModel = 'llama-3.1-8b-instant';

  static const String garudaSystem = '''You are Garuda, a powerful male AI research assistant.
Sharp, precise, direct. Like an eagle - clear vision, no fluff.
Format every response:
- Brief intro (1-2 sentences)
- Key points (3-5 bullets using *)
- Closing insight
Rules: No adult or illegal content. Be concise and factual.''';

  static const String researchSystem = '''You are Garuda research engine.
Process data and give clear structured summaries.
Format: Summary (2-3 sentences), Key findings (* bullets), Source insight.
Be factual. If data is limited say so.''';

  // ── Key management ──────────────────────────
  static Future<String> getChatKey() async {
    final p = await SharedPreferences.getInstance();
    return p.getString('gemini_chat_key') ?? '';
  }

  static Future<String> getSearchKey() async {
    final p = await SharedPreferences.getInstance();
    return p.getString('gemini_search_key') ?? '';
  }

  static Future<String> getGroqKey() async {
    final p = await SharedPreferences.getInstance();
    return p.getString('groq_key') ?? '';
  }

  static Future<void> saveKeys({
    required String chatKey,
    required String searchKey,
    required String groqKey,
  }) async {
    final p = await SharedPreferences.getInstance();
    await p.setString('gemini_chat_key', chatKey.trim());
    await p.setString('gemini_search_key', searchKey.trim());
    await p.setString('groq_key', groqKey.trim());
  }

  static Future<bool> keysConfigured() async {
    final c = await getChatKey();
    final s = await getSearchKey();
    final g = await getGroqKey();
    return c.isNotEmpty && s.isNotEmpty && g.isNotEmpty;
  }

  // ── Gemini call ─────────────────────────────
  static Future<String> callGemini(
      String apiKey, String prompt, String system) async {
    try {
      final url = Uri.parse('$geminiBase?key=$apiKey');
      final body = jsonEncode({
        'contents': [
          {'role': 'user', 'parts': [{'text': system}]},
          {'role': 'model', 'parts': [{'text': 'Understood.'}]},
          {'role': 'user', 'parts': [{'text': prompt}]},
        ],
        'generationConfig': {'maxOutputTokens': 700, 'temperature': 0.7},
      });
      final resp = await http
          .post(url, headers: {'Content-Type': 'application/json'}, body: body)
          .timeout(const Duration(seconds: 20));
      final data = jsonDecode(resp.body);
      return data['candidates'][0]['content']['parts'][0]['text'].toString().trim();
    } catch (e) {
      return 'Garuda error: $e';
    }
  }

  // ── Groq call ───────────────────────────────
  static Future<String> callGroq(String prompt,
      {int maxTokens = 500, double temperature = 0.2}) async {
    try {
      final key = await getGroqKey();
      if (key.isEmpty) return '';
      final resp = await http
          .post(
            Uri.parse(groqUrl),
            headers: {
              'Authorization': 'Bearer $key',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': groqModel,
              'messages': [{'role': 'user', 'content': prompt}],
              'max_tokens': maxTokens,
              'temperature': temperature,
            }),
          )
          .timeout(const Duration(seconds: 15));
      return jsonDecode(resp.body)['choices'][0]['message']['content']
          .toString()
          .trim();
    } catch (e) {
      return '';
    }
  }

  // ── Web search ──────────────────────────────
  static Future<String> searchWeb(String query) async {
    try {
      final url = Uri.parse(
          'https://api.duckduckgo.com/?q=${Uri.encodeComponent(query)}&format=json&no_html=1&skip_disambig=1');
      final resp = await http.get(url).timeout(const Duration(seconds: 8));
      final data = jsonDecode(resp.body);
      String result = data['AbstractText'] ?? '';
      if (result.isEmpty) {
        for (final t in (data['RelatedTopics'] as List).take(3)) {
          if (t is Map && t['Text'] != null) result += '${t['Text']}\n';
        }
      }
      return result.trim();
    } catch (e) {
      return '';
    }
  }

  // ── News ────────────────────────────────────
  static const Map<String, String> newsSources = {
    'general': 'https://feeds.bbci.co.uk/news/rss.xml',
    'tech': 'https://feeds.feedburner.com/TechCrunch',
    'sports': 'https://www.espn.com/espn/rss/news',
  };

  static Future<String> fetchNews(String category) async {
    try {
      final url = Uri.parse(newsSources[category] ?? newsSources['general']!);
      final resp = await http.get(url).timeout(const Duration(seconds: 8));
      final matches = RegExp(r'<title><!\[CDATA\[(.*?)\]\]></title>')
          .allMatches(resp.body)
          .map((m) => m.group(1) ?? '')
          .where((t) => t.isNotEmpty)
          .take(5)
          .toList();
      if (matches.isEmpty) {
        return RegExp(r'<title>(.*?)</title>')
            .allMatches(resp.body)
            .skip(1)
            .map((m) => m.group(1) ?? '')
            .where((t) => t.isNotEmpty)
            .take(5)
            .join('\n');
      }
      return matches.join('\n');
    } catch (e) {
      return '';
    }
  }

  // ── Main query router ───────────────────────
  static Future<Map<String, dynamic>> sendQuery(String query) async {
    final chatKey   = await getChatKey();
    final searchKey = await getSearchKey();

    if (chatKey.isEmpty || searchKey.isEmpty) {
      return {'success': false, 'message': 'API keys not configured. Open Settings.'};
    }

    final q = query.toLowerCase();
    String response;

    if (q.contains('tech news')) {
      final raw = await fetchNews('tech');
      response = await callGemini(searchKey,
          'Summarize these tech headlines:\n$raw', researchSystem);
    } else if (q.contains('sports news') || q.contains('sports')) {
      final raw = await fetchNews('sports');
      response = await callGemini(searchKey,
          'Summarize these sports headlines:\n$raw', researchSystem);
    } else if (q.contains('news') || q.contains('latest news')) {
      final raw = await fetchNews('general');
      response = await callGemini(searchKey,
          'Summarize these headlines:\n$raw', researchSystem);
    } else {
      final web = await searchWeb(query);
      if (web.isNotEmpty) {
        response = await callGemini(searchKey,
            'Web data:\n$web\n\nQuestion: $query', researchSystem);
      } else {
        response = await callGemini(chatKey, query, garudaSystem);
      }
    }

    return {'success': true, 'response': response};
  }
}
