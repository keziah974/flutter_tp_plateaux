import 'package:cloud_firestore/cloud_firestore.dart';

/// Thin wrapper around Firestore collections used by the app.
class FirestoreDatasource {
  final FirebaseFirestore _firestore;

  FirestoreDatasource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get usersCollection =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get scoresCollection =>
      _firestore.collection('scores');

  Future<void> setUserDocument(String uid, Map<String, dynamic> data) {
    return usersCollection.doc(uid).set(data);
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDocument(String uid) {
    return usersCollection.doc(uid).get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getScoresForUser(String uid) {
    return scoresCollection.where('userId', isEqualTo: uid).get();
  }

  Future<void> upsertScore(String docId, Map<String, dynamic> data) {
    return scoresCollection.doc(docId).set(data, SetOptions(merge: true));
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getScoreDoc(String docId) {
    return scoresCollection.doc(docId).get();
  }
}
