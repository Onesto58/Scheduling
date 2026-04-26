import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/routine_service.dart';
import '../models/routine.dart';

final routineServiceProvider = Provider((ref) => RoutineFirestoreService());

final routinesStreamProvider = StreamProvider.keepAlive<List<Routine>>((ref) {
  final service = ref.watch(routineServiceProvider);
  return service.getRoutines();
});
