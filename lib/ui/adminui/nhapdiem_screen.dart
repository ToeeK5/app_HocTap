import 'package:flutter/material.dart';
import '../../models/sinh_vien.dart';
import '../../models/diem.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/firestore_service.dart';
import '../../../services/admin_services/admin_service.dart';
import '../../../services/init_data_service.dart';
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
  final _initDataService = InitDataService();

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

  /// Tải dữ liệu môn học từ AppData và khởi tạo Firestore nếu cần
  Future<void> _loadInitialData() async {
    try {
      // 1. Khởi tạo dữ liệu sinh viên vào Firestore (lần đầu tiên)
      await _initDataService.initializeSinhVienData();

      // 2. Lấy danh sách môn học từ AppData (vẫn có thể giữ AppData cho môn học)
      // Bạn có thể thêm môn học vào Firestore nếu muốn
      // Tạm thời giữ từ AppData
      String monHoc1 = 'MH001';
      String monHoc2 = 'MH002';
      String monHoc3 = 'MH003';
      
      _danhSachMonHoc = [monHoc1, monHoc2, monHoc3];

      if (_danhSachMonHoc.isNotEmpty) {
        setState(() {
          _selectedMonHoc = _danhSachMonHoc.first;
        });
      }

      // 3. Tải danh sách sinh viên cho môn học đầu tiên
      await _loadStudentDataFromFirestore();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading initial data: $e');
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi tải dữ liệu: $e'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  /// Lấy danh sách sinh viên từ Firestore cho môn học đã chọn
  Future<void> _loadStudentDataFromFirestore() async {
    try {
      final targetMon = _selectedMonHoc.trim();

      // Lấy danh sách sinh viên từ Firestore
      List<SinhVien> allSinhVien =
          await _firestoreService.getSinhVienList();

      if (allSinhVien.isEmpty) {
        print('Không có sinh viên nào trong Firestore');
        setState(() {
          _studentData = [];
          _controllers = {};
        });
        return;
      }

      // Sắp xếp theo lớp rồi theo tên
      allSinhVien.sort((a, b) {
        int lopCompare = a.lop.compareTo(b.lop);
        if (lopCompare != 0) return lopCompare;
        return a.hoTen.compareTo(b.hoTen);
      });

      // Lấy danh sách điểm từ Firestore
      List<Diem> diemList =
          await _firestoreService.getDiemByMonHoc(targetMon);

      _studentData = [];
      for (int i = 0; i < allSinhVien.length; i++) {
        SinhVien sv = allSinhVien[i];

        // Tìm điểm cho sinh viên này
        var diem = diemList.firstWhere(
          (d) => d.maSV == sv.maSV,
          orElse: () => Diem(
            maDiem: '',
            maSV: sv.maSV,
            maMon: targetMon,
            diemGiuaKy: 0.0,
            diemCuoiKy: 0.0,
            heSoGiuaKy: 0.4,
            heSoCuoiKy: 0.6,
          ),
        );

        _studentData.add({
          'stt': i + 1,
          'mssv': sv.maSV,
          'ten': sv.hoTen,
          'lop': sv.lop,
          'gk': diem.diemGiuaKy,
          'ck': diem.diemCuoiKy,
        });
      }

      _initializeControllers();

      setState(() {
        _currentPage = 1;
      });
    } catch (e) {
      print('Error loading student data from Firestore: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải dữ liệu: $e')),
      );
    }
  }

  void _initializeControllers() {
    _controllers = {};
    for (int i = 0; i < _studentData.length; i++) {
      _controllers[i] = {
        'gk': TextEditingController(
          text: _studentData[i]['gk'] > 0
              ? (_studentData[i]['gk'] as double).toStringAsFixed(1)
              : '',
        ),
        'ck': TextEditingController(
          text: _studentData[i]['ck'] > 0
              ? (_studentData[i]['ck'] as double).toStringAsFixed(1)
              : '',
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
      // Thêm sinh viên vào Firestore
      bool success = await _adminService.addSingleSinhVien(
        maSV: result['mssv']!,
        hoTen: result['ten']!,
        lop: result['lop']!,
      );

      if (success) {
        // Reload dữ liệu
        await _loadStudentDataFromFirestore();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thêm sinh viên thành công!'),
            backgroundColor: AppColors.successGreen,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lỗi: MSSV có thể đã tồn tại!'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  void _deleteStudent(int index) async {
    final confirmed = await StudentDialogs.showDeleteConfirmDialog(context);
    if (confirmed == true && mounted) {
      String maSV = _studentData[index]['mssv'] as String;

      // Xóa từ Firestore
      bool success = await _firestoreService.deleteSinhVien(maSV);

      if (success) {
        // Reload dữ liệu
        await _loadStudentDataFromFirestore();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Xóa sinh viên thành công!'),
            backgroundColor: AppColors.successGreen,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lỗi xóa sinh viên!'),
            backgroundColor: AppColors.errorRed,
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

      // Cập nhật Firestore
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
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
    }
  }

  void _updateScore(int index, String field, String value) {
    setState(() {
      if (field == 'gk') {
        _studentData[index]['gk'] =
            value.isEmpty ? 0.0 : double.tryParse(value) ?? 0.0;
      } else if (field == 'ck') {
        _studentData[index]['ck'] =
            value.isEmpty ? 0.0 : double.tryParse(value) ?? 0.0;
      }
    });
  }

  /// Lưu tất cả điểm vào Firestore
  Future<void> _saveAllScores() async {
    try {
      List<Diem> diemList = [];

      for (var student in _studentData) {
        double gk = double.tryParse(
              _controllers[_studentData.indexOf(student)]?['gk']?.text ?? '',
            ) ??
            (student['gk'] as double);
        double ck = double.tryParse(
              _controllers[_studentData.indexOf(student)]?['ck']?.text ?? '',
            ) ??
            (student['ck'] as double);

        // Chỉ lưu nếu có điểm
        if (gk > 0 || ck > 0) {
          diemList.add(Diem(
            maDiem: '${student['mssv']}_${_selectedMonHoc}',
            maSV: student['mssv'] as String,
            maMon: _selectedMonHoc,
            diemGiuaKy: gk,
            diemCuoiKy: ck,
            heSoGiuaKy: 0.4,
            heSoCuoiKy: 0.6,
          ));
        }
      }

      if (diemList.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không có điểm nào để lưu!'),
            backgroundColor: AppColors.errorRed,
          ),
        );
        return;
      }

      bool success = await _firestoreService.saveBatchDiem(diemList);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lưu ${diemList.length} điểm thành công!'),
            backgroundColor: AppColors.successGreen,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lỗi khi lưu điểm!'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 768;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
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
                  child: SingleChildScrollView(
                    child: _buildMainContent(),
                  ),
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