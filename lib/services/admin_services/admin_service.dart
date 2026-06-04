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

  /// Thêm một sinh viên vào Firebase
  Future<bool> addSingleSinhVien({
    required String maSV,
    required String hoTen,
    required String lop,
    String? email,
    String? sdt,
  }) async {
    try {
      // Kiểm tra sinh viên đã tồn tại?
      DocumentSnapshot doc = await _db.collection('sinh_vien').doc(maSV).get();
      if (doc.exists) {
        print('Sinh viên $maSV đã tồn tại!');
        return false;
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

      print('Thêm sinh viên $maSV thành công!');
      return true;
    } catch (e) {
      print('Error adding single sinh vien: $e');
      return false;
    }
  }

  /// Thêm hàng loạt sinh viên vào Firebase
  Future<Map<String, dynamic>> addBatchSinhVien(
    List<Map<String, String>> sinhVienList,
  ) async {
    try {
      WriteBatch batch = _db.batch();
      int successCount = 0;
      int failCount = 0;
      List<String> errors = [];

      for (var sv in sinhVienList) {
        String maSV = sv['maSV'] ?? '';
        String hoTen = sv['hoTen'] ?? '';
        String lop = sv['lop'] ?? '';

        if (maSV.isEmpty || hoTen.isEmpty || lop.isEmpty) {
          failCount++;
          errors.add('Dòng thiếu dữ liệu: MSSV=$maSV, Tên=$hoTen, Lớp=$lop');
          continue;
        }

        // Kiểm tra sinh viên đã tồn tại
        DocumentSnapshot doc =
            await _db.collection('sinh_vien').doc(maSV).get();
        if (doc.exists) {
          failCount++;
          errors.add('MSSV $maSV đã tồn tại');
          continue;
        }

        batch.set(_db.collection('sinh_vien').doc(maSV), {
          'maSV': maSV,
          'hoTen': hoTen,
          'lop': lop,
          'email': sv['email'] ?? '',
          'sdt': sv['sdt'] ?? '',
          'createdAt': FieldValue.serverTimestamp(),
        });

        successCount++;
      }

      // Commit batch
      await batch.commit();

      return {
        'success': successCount,
        'failed': failCount,
        'errors': errors,
        'total': successCount + failCount,
      };
    } catch (e) {
      print('Error adding batch sinh vien: $e');
      return {
        'success': 0,
        'failed': sinhVienList.length,
        'errors': ['Lỗi: $e'],
        'total': sinhVienList.length,
      };
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
          .map((doc) => SinhVien.fromFirestore(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting sinh vien by lop: $e');
      return [];
    }
  }

  /// Lấy danh sách sinh viên chưa có điểm cho một môn học
  Future<List<SinhVien>> getSinhVienWithoutDiem(String maMon, String lop) async {
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
      QuerySnapshot svSnapshot =
          await _db.collection('sinh_vien').where('lop', isEqualTo: lop).get();

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
        'passRate':
            totalWithDiem > 0 ? (passCount / totalWithDiem * 100).toStringAsFixed(1) : '0.0',
      };
    } catch (e) {
      print('Error getting diem stats: $e');
      return {};
    }
  }

  /// Tạo dữ liệu mẫu cho các lớp 1-4
  Future<bool> createSampleData() async {
    try {
      List<Map<String, String>> sampleData = [];

      // Sinh viên lớp CNTT1
      sampleData.addAll([
        {
          'maSV': 'SV001',
          'hoTen': 'Nguyễn Văn A',
          'lop': 'CNTT1',
          'email': 'nguyenvana@gmail.com',
          'sdt': '0901234567'
        },
        {
          'maSV': 'SV002',
          'hoTen': 'Trần Thị B',
          'lop': 'CNTT1',
          'email': 'tranthib@gmail.com',
          'sdt': '0912345678'
        },
        {
          'maSV': 'SV003',
          'hoTen': 'Lê Văn C',
          'lop': 'CNTT1',
          'email': 'levanc@gmail.com',
          'sdt': '0923456789'
        },
      ]);

      // Sinh viên lớp CNTT2
      sampleData.addAll([
        {
          'maSV': 'SV004',
          'hoTen': 'Phạm Văn D',
          'lop': 'CNTT2',
          'email': 'phamvand@gmail.com',
          'sdt': '0934567890'
        },
        {
          'maSV': 'SV005',
          'hoTen': 'Hoàng Thị E',
          'lop': 'CNTT2',
          'email': 'hoangthie@gmail.com',
          'sdt': '0945678901'
        },
      ]);

      // Sinh viên lớp CNTT3
      sampleData.addAll([
        {
          'maSV': 'SV006',
          'hoTen': 'Võ Văn F',
          'lop': 'CNTT3',
          'email': 'vovanf@gmail.com',
          'sdt': '0956789012'
        },
      ]);

      // Sinh viên lớp CNTT4
      sampleData.addAll([
        {
          'maSV': 'SV007',
          'hoTen': 'Đặng Văn G',
          'lop': 'CNTT4',
          'email': 'dangvang@gmail.com',
          'sdt': '0967890123'
        },
      ]);

      var result = await addBatchSinhVien(sampleData);
      print('Sample data created: $result');
      return result['success'] > 0;
    } catch (e) {
      print('Error creating sample data: $e');
      return false;
    }
  }
}
