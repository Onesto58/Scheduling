import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/routine_service.dart';
import '../models/routine.dart';

final routineServiceProvider = Provider((ref) => RoutineFirestoreService());

final routinesStreamProvider = StreamProvider<List<Routine>>((ref) {
  ref.keepAlive();
  final service = ref.watch(routineServiceProvider);
  return service.getRoutines();
});
