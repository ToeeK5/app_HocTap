import 'package:cloud_firestore/cloud_firestore.dart';

class InitDataService {
  static final InitDataService _instance = InitDataService._internal();
  late FirebaseFirestore _db;

  InitDataService._internal() {
    _db = FirebaseFirestore.instance;
  }

  factory InitDataService() {
    return _instance;
  }

  /// Kiểm tra Firestore đã có dữ liệu chưa
  Future<bool> isDataInitialized() async {
    try {
      QuerySnapshot snapshot = await _db.collection('sinh_vien').limit(1).get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking data: $e');
      return false;
    }
  }

  /// Khởi tạo dữ liệu sinh viên vào Firestore
  Future<bool> initializeSinhVienData() async {
    try {
      // Kiểm tra đã có dữ liệu?
      bool hasData = await isDataInitialized();
      if (hasData) {
        print('Dữ liệu sinh viên đã tồn tại');
        return true;
      }

      // Tạo batch để thêm dữ liệu
      WriteBatch batch = _db.batch();

      // Danh sách sinh viên mẫu - CNTT1
      List<Map<String, dynamic>> sinhVienData = [
        // Lớp CNTT1
        {
          'maSV': 'SV001',
          'hoTen': 'Nguyễn Văn A',
          'lop': 'CNTT1',
          'email': 'nguyenvana@student.edu.vn',
          'sdt': '0901234567',
          'namSinh': 2003,
          'hocKyHienTai': 1,
        },
        {
          'maSV': 'SV002',
          'hoTen': 'Trần Thị B',
          'lop': 'CNTT1',
          'email': 'tranthib@student.edu.vn',
          'sdt': '0912345678',
          'namSinh': 2003,
          'hocKyHienTai': 1,
        },
        {
          'maSV': 'SV003',
          'hoTen': 'Lê Văn C',
          'lop': 'CNTT1',
          'email': 'levanc@student.edu.vn',
          'sdt': '0923456789',
          'namSinh': 2004,
          'hocKyHienTai': 1,
        },
        {
          'maSV': 'SV004',
          'hoTen': 'Phạm Văn D',
          'lop': 'CNTT1',
          'email': 'phamvand@student.edu.vn',
          'sdt': '0934567890',
          'namSinh': 2003,
          'hocKyHienTai': 1,
        },
        {
          'maSV': 'SV005',
          'hoTen': 'Hoàng Thị E',
          'lop': 'CNTT1',
          'email': 'hoangthie@student.edu.vn',
          'sdt': '0945678901',
          'namSinh': 2004,
          'hocKyHienTai': 1,
        },
        // Lớp CNTT2
        {
          'maSV': 'SV006',
          'hoTen': 'Võ Văn F',
          'lop': 'CNTT2',
          'email': 'vovanf@student.edu.vn',
          'sdt': '0956789012',
          'namSinh': 2003,
          'hocKyHienTai': 1,
        },
        {
          'maSV': 'SV007',
          'hoTen': 'Đặng Văn G',
          'lop': 'CNTT2',
          'email': 'dangvang@student.edu.vn',
          'sdt': '0967890123',
          'namSinh': 2003,
          'hocKyHienTai': 1,
        },
        {
          'maSV': 'SV008',
          'hoTen': 'Bùi Thị H',
          'lop': 'CNTT2',
          'email': 'buithih@student.edu.vn',
          'sdt': '0978901234',
          'namSinh': 2004,
          'hocKyHienTai': 1,
        },
        {
          'maSV': 'SV009',
          'hoTen': 'Dương Văn I',
          'lop': 'CNTT2',
          'email': 'duongvani@student.edu.vn',
          'sdt': '0989012345',
          'namSinh': 2003,
          'hocKyHienTai': 1,
        },
        {
          'maSV': 'SV010',
          'hoTen': 'Trương Thị K',
          'lop': 'CNTT2',
          'email': 'truongthik@student.edu.vn',
          'sdt': '0990123456',
          'namSinh': 2004,
          'hocKyHienTai': 1,
        },
        // Lớp CNTT3
        {
          'maSV': 'SV011',
          'hoTen': 'Câu Văn L',
          'lop': 'CNTT3',
          'email': 'cauvanl@student.edu.vn',
          'sdt': '0901122334',
          'namSinh': 2002,
          'hocKyHienTai': 1,
        },
        {
          'maSV': 'SV012',
          'hoTen': 'Vương Thị M',
          'lop': 'CNTT3',
          'email': 'vuongthim@student.edu.vn',
          'sdt': '0912233445',
          'namSinh': 2002,
          'hocKyHienTai': 1,
        },
        {
          'maSV': 'SV013',
          'hoTen': 'Đinh Văn N',
          'lop': 'CNTT3',
          'email': 'dinhvann@student.edu.vn',
          'sdt': '0923344556',
          'namSinh': 2003,
          'hocKyHienTai': 1,
        },
        {
          'maSV': 'SV014',
          'hoTen': 'Tạ Thị O',
          'lop': 'CNTT3',
          'email': 'tathio@student.edu.vn',
          'sdt': '0934455667',
          'namSinh': 2002,
          'hocKyHienTai': 1,
        },
        // Lớp CNTT4
        {
          'maSV': 'SV015',
          'hoTen': 'Hồ Văn P',
          'lop': 'CNTT4',
          'email': 'hovanp@student.edu.vn',
          'sdt': '0945566778',
          'namSinh': 2001,
          'hocKyHienTai': 1,
        },
        {
          'maSV': 'SV016',
          'hoTen': 'Chế Thị Q',
          'lop': 'CNTT4',
          'email': 'chethiq@student.edu.vn',
          'sdt': '0956677889',
          'namSinh': 2001,
          'hocKyHienTai': 1,
        },
        {
          'maSV': 'SV017',
          'hoTen': 'Lý Văn R',
          'lop': 'CNTT4',
          'email': 'lyvanr@student.edu.vn',
          'sdt': '0967788990',
          'namSinh': 2002,
          'hocKyHienTai': 1,
        },
      ];

      // Thêm tất cả sinh viên vào Firestore
      for (var sv in sinhVienData) {
        batch.set(
          _db.collection('sinh_vien').doc(sv['maSV']),
          {
            ...sv,
            'createdAt': FieldValue.serverTimestamp(),
          },
        );
      }

      // Commit batch
      await batch.commit();
      print('Khởi tạo ${sinhVienData.length} sinh viên thành công!');
      return true;
    } catch (e) {
      print('Error initializing data: $e');
      return false;
    }
  }

  /// Xóa tất cả dữ liệu sinh viên (dùng cho testing)
  Future<bool> clearAllData() async {
    try {
      WriteBatch batch = _db.batch();

      // Xóa tất cả sinh viên
      QuerySnapshot svSnapshot =
          await _db.collection('sinh_vien').get();
      for (var doc in svSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Xóa tất cả điểm
      QuerySnapshot diemSnapshot =
          await _db.collection('diem').get();
      for (var doc in diemSnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print('Xóa tất cả dữ liệu thành công!');
      return true;
    } catch (e) {
      print('Error clearing data: $e');
      return false;
    }
  }
}
