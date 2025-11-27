import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  FirebaseService();

  // Authentication helpers
  Future<UserCredential> signInAnonymously() async {
    return await _auth.signInAnonymously();
  }

  Future<UserCredential> signInWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Firestore helpers for CV records
  CollectionReference get _cvs => _db.collection('cvs');

  Future<DocumentReference> addCv(Map<String, dynamic> data) async {
    return await _cvs.add(data);
  }

  Stream<QuerySnapshot> streamCvs() {
    return _cvs.orderBy('createdAt', descending: true).snapshots();
  }

  Future<void> updateCv(String id, Map<String, dynamic> data) async {
    await _cvs.doc(id).update(data);
  }

  Future<void> deleteCv(String id) async {
    await _cvs.doc(id).delete();
  }
}
