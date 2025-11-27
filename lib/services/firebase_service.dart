import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';

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

  // Upload resume bytes to Firebase Storage and return the download URL.
  // Provides optional progress updates via `onProgress` (0.0 - 1.0).
  Future<String> uploadResume(
    Uint8List bytes,
    String filename, {
    String? docId,
    void Function(double progress)? onProgress,
  }) async {
    final pathPrefix = (docId != null && docId.isNotEmpty)
        ? 'resumes/$docId'
        : 'resumes';
    final ref = FirebaseStorage.instance.ref().child(
      '$pathPrefix/${DateTime.now().millisecondsSinceEpoch}_$filename',
    );
    final UploadTask task = ref.putData(bytes);

    final sub = task.snapshotEvents.listen((TaskSnapshot snap) {
      try {
        final total = snap.totalBytes;
        final transferred = snap.bytesTransferred;
        final progress = (total > 0) ? (transferred / total) : 0.0;
        if (onProgress != null) onProgress(progress);
      } catch (_) {
        // ignore errors from progress reporting
      }
    });

    try {
      await task.whenComplete(() {});
      final url = await ref.getDownloadURL();
      return url;
    } finally {
      await sub.cancel();
    }
  }
}
