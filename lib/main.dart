import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'providers/theme_provider.dart';
import 'theme/app_theme.dart';
import 'services/notification_service.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Start Firebase initialization in parallel with app startup
  final firebaseInitialization = Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize notifications
  await NotificationService().init();

  runApp(
    ProviderScope(
      child: SchedulingApp(firebaseInitialization: firebaseInitialization),
    ),
  );
}

class SchedulingApp extends ConsumerWidget {
  final Future<FirebaseApp> firebaseInitialization;
  
  const SchedulingApp({super.key, required this.firebaseInitialization});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Scheduling App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: FutureBuilder(
        future: firebaseInitialization,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return const HomeScreen();
          }
          // Show a blank screen with theme background while initializing
          return Scaffold(backgroundColor: Theme.of(context).scaffoldBackgroundColor);
        },
      ),
    );
  }
}
