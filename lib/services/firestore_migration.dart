import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../data/app_data.dart';

/// Seeds Firestore collections from AppData if they are empty.
class FirestoreMigration {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> seedAllIfNeeded() async {
    await _seedCollectionIfEmpty(
      'sinh_vien',
      AppData.danhSachSinhVien.map((s) => s.toFirestore()).toList(),
      idField: 'maSV',
    );
    await _seedCollectionIfEmpty(
      'tai_khoan',
      AppData.danhSachTaiKhoan.map((t) => t.toMap()).toList(),
      idField: 'maTK',
    );
    await _seedCollectionIfEmpty(
      'mon_hoc',
      AppData.danhSachMonHoc.map((m) => m.toMap()).toList(),
      idField: 'maMon',
    );
    await _seedCollectionIfEmpty(
      'diem',
      AppData.danhSachDiem.map((d) => d.toFirestore()).toList(),
      idField: 'maDiem',
    );
    // ke_hoach and lich_hoc may be seeded separately if needed
  }

  Future<void> _seedCollectionIfEmpty(
    String collection,
    List<Map<String, dynamic>> docs, {
    required String idField,
  }) async {
    try {
      final snapshot = await _db.collection(collection).limit(1).get();
      if (snapshot.docs.isNotEmpty) {
        debugPrint(
          'FirestoreMigration: collection $collection already has data, skipping seed.',
        );
        return;
      }

      debugPrint(
        'FirestoreMigration: seeding collection $collection with ${docs.length} documents...',
      );
      final batch = _db.batch();
      for (final doc in docs) {
        final id = (doc[idField] ?? '').toString();
        if (id.isEmpty) continue;
        batch.set(_db.collection(collection).doc(id), doc);
      }
      await batch.commit();
      debugPrint('FirestoreMigration: seeded $collection successfully.');
    } catch (e) {
      debugPrint('FirestoreMigration: error seeding $collection: $e');
    }
  }
}
