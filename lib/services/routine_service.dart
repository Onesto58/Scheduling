import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/routine.dart';

class RoutineFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionPath = 'routines';

  Stream<List<Routine>> getRoutines() {
    return _firestore.collection(collectionPath).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Routine.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<void> saveRoutine(Routine routine) async {
    if (routine.id.isEmpty) {
      // Create new document (Firestore will generate ID)
      await _firestore.collection(collectionPath).add(routine.toMap());
    } else {
      // Update existing document
      await _firestore.collection(collectionPath).doc(routine.id).set(routine.toMap());
    }
  }

  Future<void> deleteRoutine(String id) async {
    await _firestore.collection(collectionPath).doc(id).delete();
  }
}
