import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:counterclaimer/core/theme/app_theme.dart';
import 'package:counterclaimer/features/app_shell.dart';
import 'package:counterclaimer/core/simple_api.dart';
import 'package:counterclaimer/features/chatbot/screens/animated_welcome_screen.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:counterclaimer/core/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  
  try {
    final analysis = await CambridgeApi.addCase(AddCaseRequest("My employer fired me unfairly."));
    print('API Response: $analysis');
  } catch (e) {
    print('Error calling API: $e');
  }

  runApp(const ProviderScope(child: CounterclaimerApp()));
}

class CounterclaimerApp extends ConsumerWidget {
  const CounterclaimerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Counterclaimer Assistant',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light, // Default to light mode
      
      // ⭐ CAMBIA QUESTA RIGA ⭐
      // DA: home: const AppShell(),
      // A:
      home: const AnimatedWelcomeScreen(
        appContent: AppShell(),
      ),
    );
  }
}