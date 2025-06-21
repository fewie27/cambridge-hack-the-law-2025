import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:counterclaimer/core/theme/app_theme.dart';
import 'package:counterclaimer/features/app_shell.dart';
import 'package:counterclaimer/simple_api/simple_api.dart';
import 'package:counterclaimer/features/chatbot/screens/animated_welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  
  try {
    final analysis = await CambridgeApi.addCase(AddCaseRequest("I’m working on a case representing Fenoscadia Limited, a mining company from Ticadia that was operating in Kronos under an 80-year concession to extract lindoro, a rare earth metal. In 2016, Kronos passed a decree that revoked Fenoscadia’s license and terminated the concession agreement, citing environmental concerns. The government had funded a study that suggested lindoro mining contaminated the Rhea River and caused health issues, although the study didn’t conclusively prove this. "));
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
      
      home: const AnimatedWelcomeScreen(
        appContent: AppShell(),
      ),
    );
  }
}