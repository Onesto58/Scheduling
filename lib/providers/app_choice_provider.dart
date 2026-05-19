import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_provider.dart';

const String _appChoiceKey = 'selected_app_choice';

final appChoiceProvider = NotifierProvider<AppChoiceNotifier, String?>(AppChoiceNotifier.new);

class AppChoiceNotifier extends Notifier<String?> {
  late SharedPreferences _prefs;

  @override
  String? build() {
    _prefs = ref.watch(sharedPreferencesProvider);
    return _prefs.getString(_appChoiceKey);
  }

  void setAppChoice(String? choice) {
    state = choice;
    if (choice == null) {
      _prefs.remove(_appChoiceKey);
    } else {
      _prefs.setString(_appChoiceKey, choice);
    }
  }
}
