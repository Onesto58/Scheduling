import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'providers/theme_provider.dart';
import 'theme/app_theme.dart';
import 'services/notification_service.dart';
import 'services/quick_actions_service.dart';
import 'screens/home_screen.dart';

import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Start Firebase initialization in parallel with app startup
  final firebaseInitialization = Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize notifications
  await NotificationService().init();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: SchedulingApp(firebaseInitialization: firebaseInitialization),
    ),
  );
}

class SchedulingApp extends ConsumerStatefulWidget {
  final Future<FirebaseApp> firebaseInitialization;
  
  const SchedulingApp({super.key, required this.firebaseInitialization});

  @override
  ConsumerState<SchedulingApp> createState() => _SchedulingAppState();
}

class _SchedulingAppState extends ConsumerState<SchedulingApp> {
  @override
  void initState() {
    super.initState();
    // Initialize QuickActions only once
    QuickActionsService().initialize(navigatorKey);
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Scheduling App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: FutureBuilder(
        future: widget.firebaseInitialization,
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
