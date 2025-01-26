import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'services/database_service.dart';
import 'services/ai_service.dart';
import 'services/settings_service.dart';
import 'pages/home_page.dart';

Future<SettingsService> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 仅在Windows平台初始化SQLite
  if (!kIsWeb && Platform.isWindows) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  await DatabaseService.init();
  final settingsService = SettingsService();
  await settingsService.init();

  return settingsService;
}

void main() async {
  try {
    final settingsService = await initializeApp();
    runApp(MyApp(settingsService: settingsService));
  } catch (e) {
    debugPrint('应用程序启动错误: $e');
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('应用启动错误: $e'),
        ),
      ),
    ));
  }
}

class MyApp extends StatelessWidget {
  final SettingsService settingsService;

  const MyApp({super.key, required this.settingsService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settingsService),
        ChangeNotifierProvider(create: (_) => DatabaseService()),
        ChangeNotifierProvider(
          create: (context) => AIService(
            settingsService: context.read<SettingsService>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: '心迹 Mind Trace',
        debugShowCheckedModeBanner: false,  // 移除调试标签
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: MediaQuery.platformBrightnessOf(context),
          ),
          useMaterial3: true,
          // 添加自定义主题
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
          cardTheme: CardTheme(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        home: const HomePage(),
      ),
    );
  }
}
