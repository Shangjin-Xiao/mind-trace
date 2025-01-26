import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/settings_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();
  // 在变量声明时初始化控制器
  late TextEditingController _apiUrlController = TextEditingController();
  late TextEditingController _apiKeyController = TextEditingController();
  late TextEditingController _modelController = TextEditingController();
  bool _enableSentimentAnalysis = false;
  bool _enableKeywordExtraction = false;
  bool _enableAutoSummary = false;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsService>().aiSettings;
    // 设置初始值
    _apiUrlController.text = settings.apiUrl;
    _apiKeyController.text = settings.apiKey;
    _modelController.text = settings.model;
    _enableSentimentAnalysis = settings.enableSentimentAnalysis;
    _enableKeywordExtraction = settings.enableKeywordExtraction;
    _enableAutoSummary = settings.enableAutoSummary;
  }

  @override
  void dispose() {
    // 释放控制器
    _apiUrlController.dispose();
    _apiKeyController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI设置'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AI模型配置',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _apiUrlController,
                      decoration: const InputDecoration(
                        labelText: 'API地址',
                        hintText: '例如：https://api.openai.com/v1/chat/completions',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入API地址';
                        }
                        try {
                          Uri.parse(value);
                        } catch (e) {
                          return '请输入有效的URL';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _apiKeyController,
                      decoration: const InputDecoration(
                        labelText: 'API密钥',
                        hintText: '输入你的API密钥',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入API密钥';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _modelController,
                      decoration: const InputDecoration(
                        labelText: '模型名称',
                        hintText: '例如：gpt-3.5-turbo',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入模型名称';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AI功能设置',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SwitchListTile(
                      title: const Text('情感分析'),
                      subtitle: const Text('分析文本情感倾向'),
                      value: _enableSentimentAnalysis,
                      onChanged: (bool value) {
                        setState(() {
                          _enableSentimentAnalysis = value;
                        });
                      },
                    ),
                    SwitchListTile(
                      title: const Text('关键词提取'),
                      subtitle: const Text('自动提取文本关键词'),
                      value: _enableKeywordExtraction,
                      onChanged: (bool value) {
                        setState(() {
                          _enableKeywordExtraction = value;
                        });
                      },
                    ),
                    SwitchListTile(
                      title: const Text('自动摘要'),
                      subtitle: const Text('生成文本摘要'),
                      value: _enableAutoSummary,
                      onChanged: (bool value) {
                        setState(() {
                          _enableAutoSummary = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveSettings,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
              child: const Text('保存设置'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveSettings() {
    if (_formKey.currentState!.validate()) {
      final settings = AISettings(
        apiUrl: _apiUrlController.text,
        apiKey: _apiKeyController.text,
        model: _modelController.text,
        enableSentimentAnalysis: _enableSentimentAnalysis,
        enableKeywordExtraction: _enableKeywordExtraction,
        enableAutoSummary: _enableAutoSummary,
      );
      
      context.read<SettingsService>().updateAISettings(settings);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('设置已保存')),
      );
    }
  }
}