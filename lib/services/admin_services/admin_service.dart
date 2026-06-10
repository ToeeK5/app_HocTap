import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/sinh_vien.dart';

class AdminService {
  static final AdminService _instance = AdminService._internal();
  late FirebaseFirestore _db;

  AdminService._internal() {
    _db = FirebaseFirestore.instance;
  }

  factory AdminService() {
    return _instance;
  }

  Future<bool> addSingleSinhVien({
    required String maSV,
    required String hoTen,
    required String lop,
    String? email,
    String? sdt,
  }) async {
    try {
      print('AdminService: Checking if student with maSV: $maSV exists.');
      DocumentSnapshot doc = await _db
          .collection('sinh_vien')
          .doc(maSV)
          .get(const GetOptions(source: Source.server));
      
      print('AdminService: doc.exists = ${doc.exists}');
      if (doc.exists) {
        print('AdminService: Sinh viên $maSV đã tồn tại!');
        return false; // Chỉ trả về false khi TRÙNG MÃ THỰC SỰ
      }

      // Thêm sinh viên mới
      await _db.collection('sinh_vien').doc(maSV).set({
        'maSV': maSV,
        'hoTen': hoTen,
        'lop': lop,
        'email': email ?? '',
        'sdt': sdt ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error adding single sinh vien: $e');
      // SỬA DÒNG NÀY: Thay vì 'return false;', hãy đổi thành 'rethrow;'
      rethrow; // Ném lỗi này ra màn hình UI xử lý
    }
  }

  /// Lấy danh sách sinh viên theo lớp từ Firebase
  Future<List<SinhVien>> getSinhVienByLop(String lop) async {
    try {
      QuerySnapshot querySnapshot = await _db
          .collection('sinh_vien')
          .where('lop', isEqualTo: lop)
          .get();

      return querySnapshot.docs
          .map(
            (doc) => SinhVien.fromFirestore(doc.data() as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      print('Error getting sinh vien by lop: $e');
      return [];
    }
  }

  /// Lấy danh sách sinh viên chưa có điểm cho một môn học
  Future<List<SinhVien>> getSinhVienWithoutDiem(
    String maMon,
    String lop,
  ) async {
    try {
      // Lấy tất cả sinh viên trong lớp
      List<SinhVien> allSV = await getSinhVienByLop(lop);

      // Lấy danh sách sinh viên đã có điểm
      QuerySnapshot diemSnapshot = await _db
          .collection('diem')
          .where('maMon', isEqualTo: maMon)
          .get();

      Set<String> maSVWithDiem = {};
      for (var doc in diemSnapshot.docs) {
        String maSV = doc['maSV'] ?? '';
        maSVWithDiem.add(maSV);
      }

      // Lọc sinh viên chưa có điểm
      return allSV.where((sv) => !maSVWithDiem.contains(sv.maSV)).toList();
    } catch (e) {
      print('Error getting sinh vien without diem: $e');
      return [];
    }
  }

  /// Lấy thống kê điểm theo môn học và lớp
  Future<Map<String, dynamic>> getDiemStats(String maMon, String lop) async {
    try {
      // Lấy tất cả sinh viên trong lớp
      QuerySnapshot svSnapshot = await _db
          .collection('sinh_vien')
          .where('lop', isEqualTo: lop)
          .get();

      // Lấy tất cả điểm cho môn học này
      QuerySnapshot diemSnapshot = await _db
          .collection('diem')
          .where('maMon', isEqualTo: maMon)
          .get();

      int totalSV = svSnapshot.docs.length;
      int totalWithDiem = 0;
      double totalAverage = 0;
      int passCount = 0;
      int failCount = 0;

      for (var doc in diemSnapshot.docs) {
        String maSV = doc['maSV'] ?? '';

        // Kiểm tra sinh viên có trong lớp không
        bool inLop = svSnapshot.docs.any((sv) => sv['maSV'] == maSV);
        if (!inLop) continue;

        totalWithDiem++;
        double gk = (doc['diemGiuaKy'] ?? 0).toDouble();
        double ck = (doc['diemCuoiKy'] ?? 0).toDouble();
        double dtb = gk * 0.4 + ck * 0.6;

        totalAverage += dtb;
        if (dtb >= 4.0) {
          passCount++;
        } else {
          failCount++;
        }
      }

      return {
        'totalSV': totalSV,
        'totalWithDiem': totalWithDiem,
        'totalWithoutDiem': totalSV - totalWithDiem,
        'averageDTB': totalWithDiem > 0 ? totalAverage / totalWithDiem : 0.0,
        'passCount': passCount,
        'failCount': failCount,
        'passRate': totalWithDiem > 0
            ? (passCount / totalWithDiem * 100).toStringAsFixed(1)
            : '0.0',
      };
    } catch (e) {
      print('Error getting diem stats: $e');
      return {};
    }
  }
}
