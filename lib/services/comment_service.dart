import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/comment_mon.dart';

class CommentService {
  final _db = FirebaseFirestore.instance;

  Stream<List<CommentMon>> layCommentTheoMon(String maMon) {
    return _db
    .collection('comments')
    .where('maMon', isEqualTo: maMon)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => CommentMon.fromFirestore(
                  doc.id,
                  doc.data(),
                ),
              )
              .toList(),
        );
  }

  Future<void> themComment(CommentMon comment) async {
    await _db.collection('comments').add(
          comment.toFirestore(),
        );
  }

  Future<void> xoaComment(String id) async {
    await _db.collection('comments').doc(id).delete();
  }
}