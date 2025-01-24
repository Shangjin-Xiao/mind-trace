import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'services/database_service.dart';
import 'pages/home_page.dart';

Future<void> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Web 平台不需要初始化 SQLite
  if (!kIsWeb) {
    await DatabaseService.init();
  }
}

void main() async {
  try {
    await initializeApp();
    runApp(const MyApp());
  } catch (e) {
    debugPrint('应用程序启动错误: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DatabaseService()),
      ],
      child: MaterialApp(
        title: '每日一言',
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
