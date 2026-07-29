import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quick_actions/quick_actions.dart';
import '../screens/routine_detail_screen.dart';

class QuickActionsService {
  static final QuickActionsService _instance = QuickActionsService._internal();
  factory QuickActionsService() => _instance;
  QuickActionsService._internal();

  final QuickActions _quickActions = const QuickActions();
  GlobalKey<NavigatorState>? _navigatorKey;

  void initialize(GlobalKey<NavigatorState> navigatorKey) {
    // QuickActions is only supported on Android and iOS (not Web, Windows, macOS, Linux)
    if (kIsWeb || (defaultTargetPlatform != TargetPlatform.android && defaultTargetPlatform != TargetPlatform.iOS)) {
      return;
    }

    _navigatorKey = navigatorKey;
    
    _quickActions.setShortcutItems(<ShortcutItem>[
      const ShortcutItem(
        type: 'action_create_routine',
        localizedTitle: 'Crea routine',
        icon: 'action_new', // Note: On iOS this can be a system icon name or asset
      ),
    ]);

    _quickActions.initialize((String type) {
      if (type == 'action_create_routine') {
        _navigateToCreateRoutine();
      }
    });
  }

  void _navigateToCreateRoutine() {
    _navigatorKey?.currentState?.push(
      MaterialPageRoute(
        builder: (context) => const RoutineDetailScreen(routine: null),
      ),
    );
  }
}
