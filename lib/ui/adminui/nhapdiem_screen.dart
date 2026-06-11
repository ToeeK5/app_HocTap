import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/sinh_vien.dart';
import '../../models/diem.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/firestore_service.dart';
import '../../services/admin_services/admin_service.dart';
import 'widgets_admin/WidgetNhapDiemScreen/index.dart';

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

  // ⭐ THÊM: Subscription để lắng nghe danh sách môn học
  StreamSubscription<QuerySnapshot>? _monHocSubscription;

  @override
  void initState() {
    super.initState();
    _selectedMonHoc = '';
    _studentData = [];
    _controllers = {};

    // ⭐ Bắt đầu lắng nghe danh sách môn học
    _listenDanhSachMonHoc();
  }

  @override
  void dispose() {
    // ⭐ Hủy subscription khi widget bị hủy
    _monHocSubscription?.cancel();
    for (var controllers in _controllers.values) {
      controllers['gk']?.dispose();
      controllers['ck']?.dispose();
    }
    super.dispose();
  }

  // ================================================================
  // ⭐ HÀM MỚI: Lắng nghe danh sách môn học REAL-TIME
  // Khi có môn mới được thêm vào → tự động cập nhật
  // ================================================================
  void _listenDanhSachMonHoc() {
    _monHocSubscription = firestoreInstance
        .collection('mon_hoc')
        .snapshots() // ← .snapshots() thay vì .get()
        .listen((snapshot) {
      // Lấy danh sách mã môn học
      List<String> clearListSubject = [];
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('maMH') && data['maMH'] != null) {
          clearListSubject.add(data['maMH'].toString().trim());
        } else if (data.containsKey('maMon') && data['maMon'] != null) {
          clearListSubject.add(data['maMon'].toString().trim());
        }
      }

      clearListSubject.sort();
      // ⭐ Nếu môn đang chọn không còn tồn tại → reset
      if (!clearListSubject.contains(_selectedMonHoc)) {
        _selectedMonHoc = clearListSubject.isNotEmpty
            ? clearListSubject.first
            : '';
        if (_selectedMonHoc.isNotEmpty) {
          _loadStudentDataFromFirestore();
        } else {
          setState(() {
            _studentData = [];
            _controllers = {};
          });
        }
      }

      setState(() {
        _danhSachMonHoc = clearListSubject;
        _isLoading = false;
      });
    }, onError: (e) {
      print('Lỗi lắng nghe môn học: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải dữ liệu môn học: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    });
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

      // 1. Chỉ lấy danh sách ĐIỂM của môn học này từ Firebase
      List<Diem> diemList = await _firestoreService.getDiemByMonHoc(targetMon);

      // 2. Lấy toàn bộ danh sách sinh viên để đối chiếu thông tin (Tên, Lớp)
      List<SinhVien> allSinhVien = await _firestoreService.getSinhVienList();

      // Chuyển danh sách sinh viên thành Map để tra cứu Tên/Lớp theo maSV cho nhanh
      Map<String, SinhVien> svMap = {for (var sv in allSinhVien) sv.maSV: sv};

      List<Map<String, dynamic>> tempStudentData = [];
      int sttCounter = 1;

      // 3. Duyệt qua những ai THỰC SỰ ĐÃ CÓ ĐIỂM (hoặc đã được thêm) ở môn này
      for (var diem in diemList) {
        // Tìm xem sinh viên này thông tin gốc (Tên, Lớp) là gì
        SinhVien? svGoc = svMap[diem.maSV];
        
        if (svGoc != null) {
          tempStudentData.add({
            'stt': sttCounter++,
            'mssv': diem.maSV,
            'ten': svGoc.hoTen,
            'lop': svGoc.lop,
            'gk': diem.diemGiuaKy ?? 0.0,
            'ck': diem.diemCuoiKy ?? 0.0,
          });
        }
      }

      // 4. Sắp xếp danh sách hiển thị theo Lớp rồi theo Tên cho gọn gàng
      tempStudentData.sort((a, b) {
        int lopCompare = a['lop'].toString().compareTo(b['lop'].toString());
        if (lopCompare != 0) return lopCompare;
        return a['ten'].toString().compareTo(b['ten'].toString());
      });

      // Cập nhật lại số thứ tự (stt) sau khi sắp xếp
      for (int i = 0; i < tempStudentData.length; i++) {
        tempStudentData[i]['stt'] = i + 1;
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
      double gkVal = _studentData[i]['gk'] is double ? _studentData[i]['gk'] : 0.0;
      double ckVal = _studentData[i]['ck'] is double ? _studentData[i]['ck'] : 0.0;

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
          // ⭐ THÊM ĐOẠN NÀY: Tạo luôn 1 bản ghi điểm 0.0 cho sinh viên này RIÊNG tại môn học hiện tại
          await firestoreInstance
              .collection('diem')
              .doc('${result['mssv']}_$_selectedMonHoc')
              .set({
            'maDiem': '${result['mssv']}_$_selectedMonHoc',
            'maSV': result['mssv']!,
            'maMon': _selectedMonHoc,
            'diemGiuaKy': 0.0,
            'diemCuoiKy': 0.0,
            'heSoGiuaKy': 0.4,
            'heSoCuoiKy': 0.6,
          });

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
              content: Text('Lỗi: Mã số sinh viên (MSSV) này đã tồn tại trên hệ thống!'),
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

      for (int i = 0; i < _studentData.length; i++) {
        var student = _studentData[i];
        double gk = double.tryParse(_controllers[i]?['gk']?.text ?? '') ?? (student['gk'] as double);
        double ck = double.tryParse(_controllers[i]?['ck']?.text ?? '') ?? (student['ck'] as double);

        // Chỉ đưa vào danh sách nếu có nhập điểm lớn hơn 0
        if (gk > 0 || ck > 0) {
          diemList.add(Diem(
            maDiem: '${student['mssv']}_$_selectedMonHoc',
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
            content: Text('Lưu ${diemList.length} điểm thành công vào Firebase!'),
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
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Colors.redAccent,
        ),
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