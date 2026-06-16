import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/sinh_vien.dart';
import '../../models/lop.dart';
import '../../models/hoc_ki.dart';

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

  // Lấy danh sách Lớp (Future hoặc bạn có thể dùng Stream tương tự môn học)
 Future<List<Lop>> getDanhSachLop() async {
    try {
      print('AdminService: Fetching class list...');
      QuerySnapshot snapshot = await _db.collection('lop').get();
      return snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return Lop(
          id: doc.id,
          //  SỬA TẠI ĐÂY: Đổi từ 'ten_lop' thành 'tenLop'
          tenLop: data['tenlop'] ?? '', 
        );
      }).toList();
    } catch (e) {
      print('Error getting danh sach lop: $e');
      return [];
    }
  }

  // Lấy danh sách Học Kỳ (Sắp xếp tăng dần theo giá trị số)
  Future<List<HocKy>> getDanhSachHocKy() async {
    var snapshot = await _db.collection('hoc_ky').orderBy('value').get();
    return snapshot.docs.map((doc) => HocKy.fromFirestore(doc.id, doc.data())).toList();
  }

  // Hàm thêm nhanh Lớp mới
  Future<void> addLop(String idLop, String tenLop) async {
    // Sử dụng .doc(idLop).set(...) để lấy idLop làm ID của document
    await _db.collection('lop').doc(idLop).set({
      'ID': idLop,
      'tenlop': tenLop,
    });
  }

  // Hàm thêm nhanh Học Kỳ mới
  Future<void> addHocKy(String idHocKy, String tenHocKy, int value) async {
    await _db.collection('hoc_ky').doc(idHocKy).set({
      'ID': idHocKy,
      'tenHocKy': tenHocKy, 
      'value': value,
    });
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
