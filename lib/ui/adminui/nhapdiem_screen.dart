import 'package:flutter/material.dart';
import '../../models/sinh_vien.dart';
import '../../models/diem.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/firestore_service.dart';
import '../../services/admin_services/admin_service.dart';
import 'widgets_admin/index.dart';

class NhapDiemScreen extends StatefulWidget {
  const NhapDiemScreen({super.key});

  @override
  State<NhapDiemScreen> createState() => _NhapDiemScreenState();
}

class _NhapDiemScreenState extends State<NhapDiemScreen> {
  final firestoreInstance = FirebaseFirestore.instance;
  final _firestoreService = FirestoreService();
  final _adminService = AdminService();

  int _currentPage = 1;
  String _selectedMonHoc = '';
  List<String> _danhSachMonHoc = [];

  late List<Map<String, dynamic>> _studentData;
  late Map<int, Map<String, TextEditingController>> _controllers;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedMonHoc = '';
    _studentData = [];
    _controllers = {};
    _loadInitialData();
  }

  /// Tải dữ liệu danh sách môn học TRỰC TIẾP TỪ FIREBASE (Bỏ hẳn static AppData)
  Future<void> _loadInitialData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // 1. Lấy danh sách môn học từ collection 'mon_hoc' trên Firestore
      QuerySnapshot subjectSnapshot = await firestoreInstance
          .collection('mon_hoc')
          .get();

      List<String> clearListSubject = [];
      for (var doc in subjectSnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        // Ưu tiên lấy trường 'maMH' làm mã môn học
        if (data.containsKey('maMH') && data['maMH'] != null) {
          clearListSubject.add(data['maMH'].toString().trim());
        } else if (data.containsKey('maMon') && data['maMon'] != null) {
          clearListSubject.add(data['maMon'].toString().trim());
        }
      }

      if (clearListSubject.isNotEmpty) {
        clearListSubject.sort(); // Sắp xếp danh sách môn học tăng dần
        setState(() {
          _danhSachMonHoc = clearListSubject;
          _selectedMonHoc = _danhSachMonHoc.first;
        });
      }

      // 2. Tải danh sách sinh viên cho môn học đầu tiên vừa lấy từ Firebase
      await _loadStudentDataFromFirestore();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading initial data from Firebase: $e');
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải dữ liệu môn học từ Firebase: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  /// Lấy danh sách sinh viên từ Firestore cho môn học đã chọn
  Future<void> _loadStudentDataFromFirestore() async {
    if (_selectedMonHoc.isEmpty) {
      setState(() {
        _studentData = [];
        _controllers = {};
      });
      return;
    }

    try {
      final targetMon = _selectedMonHoc.trim();
      // Lấy danh sách sinh viên từ Firestore
      final allSinhVien = await _firestoreService.getSinhVienList();
      if (allSinhVien.isEmpty) {
        print('Không có sinh viên nào trong Firestore');
        setState(() {
          _studentData = [];
          _controllers = {};
        });
        return;
      }

      // Sắp xếp theo lớp rồi theo tên sinh viên
      allSinhVien.sort((a, b) {
        int lopCompare = a.lop.compareTo(b.lop);
        if (lopCompare != 0) return lopCompare;
        return a.hoTen.compareTo(b.hoTen);
      });

      // Lấy danh sách điểm từ Firestore (Hỗ trợ cả 2 tên hàm thường dùng trong project)
      List<Diem> diemList = [];
      try {
        diemList = await _firestoreService.getDiemByMonHoc(targetMon);
      } catch (_) {
        // Fallback phòng trường hợp service của bạn đặt tên là getDiemListByMonHoc
        diemList = await _firestoreService.getDiemByMonHoc(targetMon);
      }

      List<Map<String, dynamic>> tempStudentData = [];
      for (int i = 0; i < allSinhVien.length; i++) {
        SinhVien sv = allSinhVien[i];

        // Tìm điểm tương ứng của sinh viên này
        var diem = diemList.firstWhere(
          (d) => d.maSV == sv.maSV,
          orElse: () => Diem(
            maDiem: '${sv.maSV}_$targetMon',
            maSV: sv.maSV,
            maMon: targetMon,
            diemGiuaKy:
                0.0, // Để mặc định null hoặc 0.0 tùy thuộc vào Model của bạn
            diemCuoiKy: 0.0,
            heSoGiuaKy: 0.4,
            heSoCuoiKy: 0.6,
          ),
        );

        // Map dữ liệu chính xác (giữ nguyên 'lop' để table hiển thị thêm cột lớp)
        tempStudentData.add({
          'stt': i + 1,
          'mssv': sv.maSV,
          'ten': sv.hoTen,
          'lop': sv.lop,
          'gk': diem.diemGiuaKy,
          'ck': diem.diemCuoiKy,
        });
      }

      _studentData = tempStudentData;
      _initializeControllers();

      setState(() {
        _currentPage = 1;
      });
    } catch (e) {
      print('Error loading student data from Firestore: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải bảng điểm sinh viên: $e')),
        );
      }
    }
  }

  void _initializeControllers() {
    // Giải phóng bộ nhớ controllers cũ trước khi tạo mới để tránh tràn bộ nhớ leak memory
    if (this._controllers.isNotEmpty) {
      for (var controllers in _controllers.values) {
        controllers['gk']?.dispose();
        controllers['ck']?.dispose();
      }
    }

    _controllers = {};
    for (int i = 0; i < _studentData.length; i++) {
      double gkVal = _studentData[i]['gk'] is double
          ? _studentData[i]['gk']
          : 0.0;
      double ckVal = _studentData[i]['ck'] is double
          ? _studentData[i]['ck']
          : 0.0;

      _controllers[i] = {
        'gk': TextEditingController(
          text: gkVal > 0 ? gkVal.toStringAsFixed(1) : '',
        ),
        'ck': TextEditingController(
          text: ckVal > 0 ? ckVal.toStringAsFixed(1) : '',
        ),
      };
    }
  }

  @override
  void dispose() {
    for (var controllers in _controllers.values) {
      controllers['gk']?.dispose();
      controllers['ck']?.dispose();
    }
    super.dispose();
  }

  // ==================== METHODS ====================
  void _addStudent() async {
    final result = await StudentDialogs.showAddStudentDialog(
      context,
      danhSachLop: const ['CNTT1', 'CNTT2', 'CNTT3', 'CNTT4'],
    );

    if (result != null && mounted) {
      try {
        print('DEBUG: Attempting to add student...');

        bool success = await _adminService.addSingleSinhVien(
          maSV: result['mssv']!,
          hoTen: result['ten']!,
          lop: result['lop']!,
        );

        if (success) {
          await _loadStudentDataFromFirestore();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Thêm sinh viên thành công!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Lỗi: Mã số sinh viên (MSSV) này đã tồn tại trên hệ thống!',
              ),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      } catch (e) {
        print('Error adding student to Firestore: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi hệ thống Firebase: $e'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _deleteStudent(int index) async {
    final confirmed = await StudentDialogs.showDeleteConfirmDialog(context);
    if (confirmed == true && mounted) {
      String maSV = _studentData[index]['mssv'] as String;

      bool success = await _firestoreService.deleteSinhVien(maSV);

      if (success) {
        await _loadStudentDataFromFirestore();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Xóa sinh viên thành công!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lỗi xóa sinh viên!'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _editStudent(int index) async {
    final result = await StudentDialogs.showEditStudentDialog(
      context,
      _studentData[index]['mssv'] as String,
      _studentData[index]['ten'] as String,
    );

    if (result != null && mounted) {
      String maSV = _studentData[index]['mssv'] as String;

      bool success = await _firestoreService.updateSinhVien(maSV, {
        'hoTen': result['ten'],
      });

      if (success) {
        setState(() {
          _studentData[index]['ten'] = result['ten'];
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật sinh viên thành công!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _updateScore(int index, String field, String value) {
    setState(() {
      if (field == 'gk') {
        _studentData[index]['gk'] = value.isEmpty
            ? 0.0
            : double.tryParse(value) ?? 0.0;
      } else if (field == 'ck') {
        _studentData[index]['ck'] = value.isEmpty
            ? 0.0
            : double.tryParse(value) ?? 0.0;
      }
    });
  }

  /// Lưu tất cả điểm vào Firestore
  Future<void> _saveAllScores() async {
    try {
      List<Diem> diemList = [];

      for (int i = 0; i < _studentData.length; i++) {
        var student = _studentData[i];
        double gk =
            double.tryParse(_controllers[i]?['gk']?.text ?? '') ??
            (student['gk'] as double);
        double ck =
            double.tryParse(_controllers[i]?['ck']?.text ?? '') ??
            (student['ck'] as double);

        // Chỉ đưa vào danh sách nếu có nhập điểm lớn hơn 0
        if (gk > 0 || ck > 0) {
          diemList.add(
            Diem(
              maDiem: '${student['mssv']}_$_selectedMonHoc',
              maSV: student['mssv'] as String,
              maMon: _selectedMonHoc,
              diemGiuaKy: gk,
              diemCuoiKy: ck,
              heSoGiuaKy: 0.4,
              heSoCuoiKy: 0.6,
            ),
          );
        }
      }

      if (diemList.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không có dữ liệu điểm mới nào để lưu!'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      bool success = await _firestoreService.saveBatchDiem(diemList);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Lưu ${diemList.length} điểm thành công vào Firebase!',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lỗi tiến trình khi lưu điểm lên Firebase!'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 768;

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF7F9FF),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF006491)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FF),
      body: isDesktop
          ? Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      TopBarWidget(isDesktop: isDesktop),
                      Expanded(
                        child: SingleChildScrollView(
                          child: _buildMainContent(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Column(
              children: [
                TopBarWidget(isDesktop: isDesktop),
                Expanded(
                  child: SingleChildScrollView(child: _buildMainContent()),
                ),
              ],
            ),
    );
  }

  Widget _buildMainContent() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeaderWidget(
            onAddStudent: _addStudent,
            onSaveAll: _saveAllScores,
            onEnsureAccounts: () async {
              // ensure accounts exist for all students
              final firestore = FirestoreService();
              final created = await firestore.ensureAccountsForAllSinhVien();
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Đã tạo $created tài khoản còn thiếu.')),
              );
            },
          ),
          const SizedBox(height: 24),
          FilterAndStatsWidget(
            selectedMonHoc: _selectedMonHoc,
            danhSachMonHoc: _danhSachMonHoc,
            studentData: _studentData,
            onMonHocChanged: (value) {
              setState(() {
                _selectedMonHoc = value;
                for (var controllers in _controllers.values) {
                  controllers['gk']?.dispose();
                  controllers['ck']?.dispose();
                }
                _controllers.clear();
                _loadStudentDataFromFirestore();
                _currentPage = 1;
              });
            },
          ),
          const SizedBox(height: 24),
          TableSectionWidget(
            studentData: _studentData,
            controllers: _controllers,
            onUpdateScore: _updateScore,
            onEdit: _editStudent,
            onDelete: _deleteStudent,
            currentPage: _currentPage,
            onPageChanged: (page) {
              setState(() => _currentPage = page);
            },
          ),
        ],
      ),
    );
  }
}
