import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AISettings {
  final String apiUrl;
  final String apiKey;
  final String model;
  final bool enableSentimentAnalysis;  // 添加情感分析开关
  final bool enableKeywordExtraction;  // 添加关键词提取开关
  final bool enableAutoSummary;        // 添加自动摘要开关

  AISettings({
    required this.apiUrl,
    required this.apiKey,
    required this.model,
    this.enableSentimentAnalysis = false,  // 默认关闭情感分析
    this.enableKeywordExtraction = false,  // 默认关闭关键词提取
    this.enableAutoSummary = false,        // 默认关闭自动摘要
  });

  Map<String, dynamic> toJson() => {
    'apiUrl': apiUrl,
    'apiKey': apiKey,
    'model': model,
    'enableSentimentAnalysis': enableSentimentAnalysis,
    'enableKeywordExtraction': enableKeywordExtraction,
    'enableAutoSummary': enableAutoSummary,
  };

  factory AISettings.fromJson(Map<String, dynamic> json) => AISettings(
    apiUrl: json['apiUrl'] as String,
    apiKey: json['apiKey'] as String,
    model: json['model'] as String,
    enableSentimentAnalysis: json['enableSentimentAnalysis'] as bool? ?? false,
    enableKeywordExtraction: json['enableKeywordExtraction'] as bool? ?? false,
    enableAutoSummary: json['enableAutoSummary'] as bool? ?? false,
  );

  factory AISettings.defaultSettings() => AISettings(
    apiUrl: 'https://api.openai.com/v1/chat/completions',
    apiKey: '',
    model: 'gpt-3.5-turbo',
    enableSentimentAnalysis: false,
    enableKeywordExtraction: false,
    enableAutoSummary: false,
  );

  AISettings copyWith({
    String? apiUrl,
    String? apiKey,
    String? model,
    bool? enableSentimentAnalysis,
    bool? enableKeywordExtraction,
    bool? enableAutoSummary,
  }) {
    return AISettings(
      apiUrl: apiUrl ?? this.apiUrl,
      apiKey: apiKey ?? this.apiKey,
      model: model ?? this.model,
      enableSentimentAnalysis: enableSentimentAnalysis ?? this.enableSentimentAnalysis,
      enableKeywordExtraction: enableKeywordExtraction ?? this.enableKeywordExtraction,
      enableAutoSummary: enableAutoSummary ?? this.enableAutoSummary,
    );
  }
}

class SettingsService extends ChangeNotifier {
  static const String _aiSettingsKey = 'ai_settings';
  late SharedPreferences _prefs;
  late AISettings _aiSettings;

  AISettings get aiSettings => _aiSettings;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadSettings();
  }

  void _loadSettings() {
    final String? settingsJson = _prefs.getString(_aiSettingsKey);
    if (settingsJson != null) {
      _aiSettings = AISettings.fromJson(
        json.decode(settingsJson) as Map<String, dynamic>,
      );
    } else {
      _aiSettings = AISettings.defaultSettings();
    }
    notifyListeners();
  }

  Future<void> updateAISettings(AISettings settings) async {
    _aiSettings = settings;
    await _prefs.setString(_aiSettingsKey, json.encode(settings.toJson()));
    notifyListeners();
  }
}