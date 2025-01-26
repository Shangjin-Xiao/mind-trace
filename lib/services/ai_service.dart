import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'settings_service.dart';
import '../models/quote_model.dart';

class AIService extends ChangeNotifier {
  final SettingsService _settingsService;

  AIService({required SettingsService settingsService})
      : _settingsService = settingsService;

  Future<void> _validateSettings() async {
    final settings = _settingsService.aiSettings;
    if (settings.apiKey.isEmpty) {
      throw Exception('请先在设置中配置 API Key');
    }
  }

  Future<String> summarizeNote(String noteContent) async {
    try {
      await _validateSettings();
      final settings = _settingsService.aiSettings;
      final response = await http.post(
        Uri.parse(settings.apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${settings.apiKey}',
        },
        body: json.encode({
          'model': settings.model,
          'messages': [
            {
              'role': 'system',
              'content': '你是一个专业的笔记助手，负责总结和分析用户的笔记内容。请从以下几个方面进行分析：\n1. 核心思想\n2. 情感倾向\n3. 行动建议',
            },
            {
              'role': 'user',
              'content': '请对以下内容进行分析：\n\n$noteContent',
            },
          ],
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('API请求失败：${response.statusCode}');
      }
    } catch (e) {
      debugPrint('AI服务错误: $e');
      rethrow;
    }
  }

  Future<String> askQuestion(String noteContent, String question) async {
    try {
      await _validateSettings();
      final settings = _settingsService.aiSettings;
      final response = await http.post(
        Uri.parse(settings.apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${settings.apiKey}',
        },
        body: json.encode({
          'model': settings.model,
          'messages': [
            {
              'role': 'system',
              'content': '你是一个知识问答助手，基于用户的笔记内容回答问题。回答要有理有据，并尽可能引用笔记中的相关内容。',
            },
            {
              'role': 'user',
              'content': '基于以下笔记内容：\n\n$noteContent\n\n回答问题：$question',
            },
          ],
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('API请求失败：${response.statusCode}');
      }
    } catch (e) {
      debugPrint('AI服务错误: $e');
      rethrow;
    }
  }

  Future<String> generateInsights(List<Quote> quotes) async {
    try {
      await _validateSettings();
      final settings = _settingsService.aiSettings;

      final messages = [
        {
          "role": "system",
          "content": "你是一个专业的心理分析师，请分析用户的日记内容并给出洞察。"
        },
        {
          "role": "user",
          "content": "基于以下日记内容，给出一份深入的分析：\n" +
              quotes.map((q) => "日期：${q.date}\n内容：${q.content}").join("\n\n")
        }
      ];

      final response = await http.post(
        Uri.parse(settings.apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${settings.apiKey}',
        },
        body: json.encode({
          'model': settings.model,
          'messages': messages,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('AI请求失败: ${response.body}');
      }
    } catch (e) {
      debugPrint('AI服务错误: $e');
      rethrow;
    }
  }

  Future<String> generateDailyPrompt() async {
    try {
      await _validateSettings();
      final settings = _settingsService.aiSettings;
      final response = await http.post(
        Uri.parse(settings.apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${settings.apiKey}',
        },
        body: json.encode({
          'model': settings.model,
          'messages': [
            {
              'role': 'system',
              'content': '你是一个反思提示生成器，负责生成有深度的日常反思问题。问题应该发人深省，促进自我认知和个人成长。',
            },
            {
              'role': 'user',
              'content': '请生成一个今日反思问题。',
            },
          ],
          'temperature': 0.9,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('API请求失败：${response.statusCode}');
      }
    } catch (e) {
      debugPrint('AI服务错误: $e');
      rethrow;
    }
  }
}