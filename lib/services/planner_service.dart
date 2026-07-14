import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/planner_activity.dart';

class PlannerFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionPath = 'planner_activities';

  Stream<List<PlannerActivity>> getActivities() {
    return _firestore.collection(collectionPath).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => PlannerActivity.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> saveActivity(PlannerActivity activity) async {
    if (activity.id.isEmpty) {
      await _firestore.collection(collectionPath).add(activity.toMap());
    } else {
      await _firestore
          .collection(collectionPath)
          .doc(activity.id)
          .set(activity.toMap());
    }
  }

  Future<void> deleteActivity(String id) async {
    await _firestore.collection(collectionPath).doc(id).delete();
  }
}
