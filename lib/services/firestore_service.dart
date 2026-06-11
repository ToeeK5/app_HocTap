import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sinh_vien.dart';
import '../models/diem.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  late FirebaseFirestore _db;

  FirestoreService._internal() {
    _db = FirebaseFirestore.instance;
  }

  factory FirestoreService() {
    return _instance;
  }

  // ==================== SINH VIÊN ====================

  /// Lấy danh sách sinh viên từ Firestore
  Future<List<SinhVien>> getSinhVienList() async {
    try {
      QuerySnapshot querySnapshot = await _db.collection('sinh_vien').get();
      return querySnapshot.docs
          .map((doc) => SinhVien.fromFirestore(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting sinh vien: $e');
      return [];
    }
  }

  /// Lấy danh sách sinh viên theo lớp
  Future<List<SinhVien>> getSinhVienByLop(String lop) async {
    try {
      QuerySnapshot querySnapshot = await _db
          .collection('sinh_vien')
          .where('lop', isEqualTo: lop)
          .get();
      return querySnapshot.docs
          .map((doc) => SinhVien.fromFirestore(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting sinh vien by lop: $e');
      return [];
    }
  }

  /// Thêm sinh viên vào Firestore
  Future<bool> addSinhVien(SinhVien sinhVien) async {
    try {
      await _db.collection('sinh_vien').doc(sinhVien.maSV).set({
        'maSV': sinhVien.maSV,
        'hoTen': sinhVien.hoTen,
        'lop': sinhVien.lop,
        'email': sinhVien.email,
        'sdt': sinhVien.sdt,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error adding sinh vien: $e');
      return false;
    }
  }

  /// Cập nhật sinh viên
  Future<bool> updateSinhVien(String maSV, Map<String, dynamic> data) async {
    try {
      await _db.collection('sinh_vien').doc(maSV).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error updating sinh vien: $e');
      return false;
    }
  }

  /// Xóa sinh viên
  Future<bool> deleteSinhVien(String maSV) async {
    try {
      await _db.collection('sinh_vien').doc(maSV).delete();
      return true;
    } catch (e) {
      print('Error deleting sinh vien: $e');
      return false;
    }
  }

  // ==================== ĐIỂM ====================

  /// Lấy điểm của sinh viên
  Future<Diem?> getDiemBySinhVienAndMonHoc(String maSV, String maMon) async {
    try {
      DocumentSnapshot doc = await _db
          .collection('diem')
          .doc('${maSV}_$maMon')
          .get();

      if (doc.exists) {
        return Diem.fromFirestore(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting diem: $e');
      return null;
    }
  }

  /// Lấy danh sách điểm theo môn học
  Future<List<Diem>> getDiemByMonHoc(String maMon) async {
    try {
      QuerySnapshot querySnapshot = await _db
          .collection('diem')
          .where('maMon', isEqualTo: maMon)
          .get();
      return querySnapshot.docs
          .map((doc) => Diem.fromFirestore(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting diem by mon hoc: $e');
      return [];
    }
  }

  /// Thêm hoặc cập nhật điểm
  Future<bool> saveDiem(Diem diem) async {
    try {
      String docId = '${diem.maSV}_${diem.maMon}';
      await _db.collection('diem').doc(docId).set({
        'maSV': diem.maSV,
        'maMon': diem.maMon,
        'diemGiuaKy': diem.diemGiuaKy,
        'diemCuoiKy': diem.diemCuoiKy,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return true;
    } catch (e) {
      print('Error saving diem: $e');
      return false;
    }
  }

  /// Cập nhật hàng loạt điểm
  Future<bool> saveBatchDiem(List<Diem> diemList) async {
    try {
      WriteBatch batch = _db.batch();
      
      for (Diem diem in diemList) {
        String docId = '${diem.maSV}_${diem.maMon}';
        batch.set(
          _db.collection('diem').doc(docId),
          {
            'maSV': diem.maSV,
            'maMon': diem.maMon,
            'diemGiuaKy': diem.diemGiuaKy,
            'diemCuoiKy': diem.diemCuoiKy,
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      }
      
      await batch.commit();
      return true;
    } catch (e) {
      print('Error saving batch diem: $e');
      return false;
    }
  }

  /// Lấy danh sách danh sách lớp học
  Future<List<String>> getDanhSachLop() async {
    try {
      QuerySnapshot querySnapshot = await _db.collection('sinh_vien').get();
      Set<String> lopSet = {};
      
      for (var doc in querySnapshot.docs) {
        String? lop = doc['lop'];
        if (lop != null && lop.isNotEmpty) {
          lopSet.add(lop);
        }
      }
      
      return lopSet.toList()..sort();
    } catch (e) {
      print('Error getting danh sach lop: $e');
      return [];
    }
  }

  // ==================== STREAMERS ====================

  /// Stream danh sách sinh viên theo lớp
  Stream<List<SinhVien>> streamSinhVienByLop(String lop) {
    return _db
        .collection('sinh_vien')
        .where('lop', isEqualTo: lop)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SinhVien.fromFirestore(doc.data()))
            .toList());
  }

  /// Stream danh sách điểm theo môn học
  Stream<List<Diem>> streamDiemByMonHoc(String maMon) {
    return _db
        .collection('diem')
        .where('maMon', isEqualTo: maMon)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Diem.fromFirestore(doc.data()))
            .toList());
  }

   /// Lấy danh sách điểm của 1 môn học cụ thể
  /// Hàm này thay thế cho getDiemByMonHoc cũ nếu cần
  Future<List<Diem>> getDiemCuaMonHoc(String maMon) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('diem')
        .where('maMon', isEqualTo: maMon)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Diem(
        maDiem: doc.id,
        maSV: data['maSV'] ?? '',
        maMon: data['maMon'] ?? '',
        diemGiuaKy: (data['diemGiuaKy'] ?? 0).toDouble(),
        diemCuoiKy: (data['diemCuoiKy'] ?? 0).toDouble(),
        heSoGiuaKy: (data['heSoGiuaKy'] ?? 0.4).toDouble(),
        heSoCuoiKy: (data['heSoCuoiKy'] ?? 0.6).toDouble(),
      );
    }).toList();
  }

  /// Thêm 1 sinh viên vào môn học (tạo bản ghi điểm rỗng)
  /// Gọi khi user muốn thêm SV vào 1 môn cụ thể
  Future<bool> themSinhVienVaoMon({
    required String maSV,
    required String maMon,
  }) async {
    try {
      // Document ID = maSV + maMon để không trùng lặp
      final docId = '${maSV}_$maMon';
      final docRef = FirebaseFirestore.instance.collection('diem').doc(docId);

      // Kiểm tra đã tồn tại chưa
      final doc = await docRef.get();
      if (doc.exists) {
        return false; // SV đã có trong môn này rồi
      }

      // Tạo mới với điểm rỗng
      await docRef.set({
        'maDiem': docId,
        'maSV': maSV,
        'maMon': maMon,
        'diemGiuaKy': 0.0,
        'diemCuoiKy': 0.0,
        'heSoGiuaKy': 0.4,
        'heSoCuoiKy': 0.6,
      });
      return true;
    } catch (e) {
      print('Lỗi thêm SV vào môn: $e');
      return false;
    }
  }

  /// Xóa sinh viên khỏi môn học (xóa bản ghi điểm)
  Future<bool> xoaSinhVienKhoiMon({
    required String maSV,
    required String maMon,
  }) async {
    try {
      final docId = '${maSV}_$maMon';
      await FirebaseFirestore.instance
          .collection('diem')
          .doc(docId)
          .delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Lưu hàng loạt điểm (dùng cho nút "Lưu tất cả")
  Future<bool> luuDiemHangLoat(List<Diem> danhSachDiem) async {
    try {
      final batch = FirebaseFirestore.instance.batch();
      for (var diem in danhSachDiem) {
        final ref = FirebaseFirestore.instance
            .collection('diem')
            .doc(diem.maDiem);
        batch.set(ref, diem.toFirestore(), SetOptions(merge: true));
      }
      await batch.commit();
      return true;
    } catch (e) {
      print('Lỗi lưu điểm: $e');
      return false;
    }
  }
}
