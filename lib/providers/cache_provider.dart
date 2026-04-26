import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/routine.dart';
import 'routine_provider.dart';

final routinesCacheProvider = NotifierProvider<RoutinesCache, List<Routine>?>(() {
  return RoutinesCache();
});

class RoutinesCache extends Notifier<List<Routine>?> {
  @override
  List<Routine>? build() {
    // Listen to the stream and update cache
    ref.listen(routinesStreamProvider, (previous, next) {
      next.whenData((data) {
        state = data;
      });
    });
    return null;
  }
}
