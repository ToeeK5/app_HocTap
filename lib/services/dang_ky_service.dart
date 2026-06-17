import 'package:cloud_firestore/cloud_firestore.dart';

class DangKyService {
  final _db = FirebaseFirestore.instance;

  // Lấy tất cả môn học
  Future<List<Map<String, dynamic>>> layTatCaMonHoc() async {
    final snap = await _db.collection('mon_hoc').get();
    return snap.docs.map((d) => d.data()..['id'] = d.id).toList();
  }

  // Lấy danh sách mã môn đã đăng ký của sinh viên
  Future<List<String>> layMonDaDangKy(String maSV, int hocKy) async {
    final snap = await _db
        .collection('dang_ky_hoc_phan')
        .where('maSV', isEqualTo: maSV)
        .where('hocKy', isEqualTo: hocKy)
        .get();

    return snap.docs.map((d) => d.data()['maMon'] as String).toList();
  }

  // Lấy tất cả mã môn đã đăng ký của sinh viên (không phân biệt học kỳ)
  Future<List<String>> layMonDaDangKyTatCa(String maSV) async {
    final snap = await _db
        .collection('dang_ky_hoc_phan')
        .where('maSV', isEqualTo: maSV)
        .get();

    return snap.docs.map((d) => d.data()['maMon'] as String).toList();
  }

  // Đăng ký môn
  Future<void> dangKyMon(String maSV, String maMon, int hocKy) async {
    final id = '${maSV}_$maMon';
    await _db.collection('dang_ky_hoc_phan').doc(id).set({
      'maSV': maSV,
      'maMon': maMon,
      'hocKy': hocKy,
      'ngayDangKy': FieldValue.serverTimestamp(),
    });
  }

  // Huỷ đăng ký
  Future<void> huyDangKyMon(String maSV, String maMon) async {
    final id = '${maSV}_$maMon';
    await _db.collection('dang_ky_hoc_phan').doc(id).delete();
  }

  // Lấy lịch học của các môn đã đăng ký (nếu có trong collection lich_hoc)
  Future<List<Map<String, dynamic>>> layLichCuaDangKy(
    String maSV,
    int hocKy,
  ) async {
    final docs = await _db
        .collection('dang_ky_hoc_phan')
        .where('maSV', isEqualTo: maSV)
        .where('hocKy', isEqualTo: hocKy)
        .get();

    final maMons = docs.docs.map((d) => d.data()['maMon'] as String).toList();

    if (maMons.isEmpty) return [];

    // Firestore whereIn supports up to 10 elements. Nếu >10, chia thành các batch.
    final List<Map<String, dynamic>> results = [];
    const int batchSize = 10;
    for (var i = 0; i < maMons.length; i += batchSize) {
      final chunk = maMons.sublist(
        i,
        (i + batchSize) > maMons.length ? maMons.length : i + batchSize,
      );
      final lichSnap = await _db
          .collection('lich_hoc')
          .where('maMon', whereIn: chunk)
          .get();

      results.addAll(lichSnap.docs.map((d) => d.data()..['id'] = d.id));
    }

    return results;
  }

  // Lấy lịch theo danh sách mã môn (dùng cho kiểm tra trùng lịch). Hỗ trợ >10 bằng cách chunk.
  Future<List<Map<String, dynamic>>> layLichTheoMaMon(
    List<String> maMons,
  ) async {
    if (maMons.isEmpty) return [];
    final List<Map<String, dynamic>> results = [];
    const int batchSize = 10;
    for (var i = 0; i < maMons.length; i += batchSize) {
      final chunk = maMons.sublist(
        i,
        (i + batchSize) > maMons.length ? maMons.length : i + batchSize,
      );
      final lichSnap = await _db
          .collection('lich_hoc')
          .where('maMon', whereIn: chunk)
          .get();
      results.addAll(lichSnap.docs.map((d) => d.data()..['id'] = d.id));
    }
    return results;
  }
}
