import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/sinh_vien.dart';
import '../../models/diem.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/firestore_service.dart';
import '../../services/admin_services/admin_service.dart';
import 'widgets_admin/WidgetNhapDiemScreen/index.dart';
import 'package:app_hoctap/models/hoc_ki.dart';
import 'package:app_hoctap/models/lop.dart';
import 'package:app_hoctap/services/day_du_lieu_firestore_service.dart';

class NhapDiemScreen extends StatefulWidget {
  const NhapDiemScreen({super.key});

  @override
  State<NhapDiemScreen> createState() => _NhapDiemScreenState();
}

class _NhapDiemScreenState extends State<NhapDiemScreen> {
  final firestoreInstance = FirebaseFirestore.instance;
  final _firestoreService = FirestoreService();
  final _adminService = AdminService();
  final _dayDuLieuService = DayDuLieuFirestoreService();

  int _currentPage = 1;
  String _selectedMonHoc = '';
  List<String> _danhSachMonHoc = [];

  late List<Map<String, dynamic>> _studentData;
  late Map<int, Map<String, TextEditingController>> _controllers;
  List<SinhVien> _selectedStudents = [];
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
        .listen(
          (snapshot) {
            // Lấy danh sách mã môn học
            List<String> clearListSubject = [];
            for (var doc in snapshot.docs) {
              var data = doc.data();
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
          },
          onError: (e) {
            debugPrint('Lỗi lắng nghe môn học: $e');
            setState(() => _isLoading = false);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Lỗi tải dữ liệu môn học: $e'),
                  backgroundColor: Colors.redAccent,
                ),
              );
            }
          },
        );
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
      await _dayDuLieuService.themDiemDayDuChoTatCaSinhVien();
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
            'gk': diem.diemGiuaKy,
            'ck': diem.diemCuoiKy,
            'hocKyMon': diem.hocKyMon,
            'hocKySinhVien': diem.hocKySinhVien,
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
      debugPrint('Error loading student data from Firestore: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải bảng điểm sinh viên: $e')),
        );
      }
    }
  }

  void _initializeControllers() {
    // Giải phóng bộ nhớ controllers cũ trước khi tạo mới để tránh tràn bộ nhớ leak memory
    if (_controllers.isNotEmpty) {
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

  // ==================== METHODS ====================
  void _addStudent() async {
    setState(() => _isLoading = true);

    try {
      // 1. Tải danh sách Lớp và Học kỳ từ Firebase
      List<Lop> activeLops = await _adminService.getDanhSachLop();
      List<HocKy> activeHocKys = await _adminService.getDanhSachHocKy();

      //  THÊM DÒNG PRINT NÀY ĐỂ DEBUG TRÊN TERMINAL
      print(
        "DEBUG: Tìm thấy ${activeLops.length} lớp và ${activeHocKys.length} học kỳ trên Firebase.",
      );

      setState(() => _isLoading = false);

      if (!mounted) return;

      // Nếu dữ liệu rỗng, cảnh báo ngay từ màn hình chính để tránh crash Dialog
      if (activeLops.isEmpty || activeHocKys.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Hệ thống chưa có dữ liệu Lớp hoặc Học kỳ. Vui lòng thêm nhanh trước!',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // 2. Gọi hiển thị Dialog
      final result = await StudentDialogs.showAddStudentDialog(
        context,
        danhSachLop: activeLops,
        danhSachHocKy: activeHocKys,
      );

      if (result != null && mounted) {
        setState(() => _isLoading = true);
        final int hocKySinhVien =
            int.tryParse(result['hocKySinhVien'] ?? '1') ?? 1;
        bool success = await _adminService.addSingleSinhVien(
          maSV: result['mssv']!,
          hoTen: result['ten']!,
          lop: result['lop']!,
          hocKySinhVien: hocKySinhVien,
        );

        if (success) {
          int hocKyMon = 0;
          final monSnap = await firestoreInstance
              .collection('mon_hoc')
              .where('maMon', isEqualTo: _selectedMonHoc)
              .get();
          if (monSnap.docs.isNotEmpty) {
            hocKyMon = (monSnap.docs.first.data()['hocKy'] ?? 0) as int;
          }
          await firestoreInstance
              .collection('diem')
              .doc('${result['mssv']}_$_selectedMonHoc')
              .set({
                'maDiem': '${result['mssv']}_$_selectedMonHoc',
                'maSV': result['mssv']!,
                'maMon': _selectedMonHoc,
                'hocKyMon': hocKyMon,
                'hocKySinhVien': hocKySinhVien,
                'diemGiuaKy': 0.0,
                'diemCuoiKy': 0.0,
                'heSoGiuaKy': 0.4,
                'heSoCuoiKy': 0.6,
              });

          await _loadStudentDataFromFirestore();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Thêm sinh viên thành công!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Lỗi: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// ✅ THÊM MỚI: Chọn sinh viên từ danh sách có sẵn
  Future<void> _selectExistingStudent() async {
    if (_selectedMonHoc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn môn học trước!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final svSnap = await firestoreInstance.collection('sinh_vien').get();

      List<SinhVien> danhSachSinhVien = svSnap.docs
          .map((doc) => SinhVien.fromFirestore(doc.data()))
          .toList();

      final diemSnap = await firestoreInstance
          .collection('diem')
          .where('maMon', isEqualTo: _selectedMonHoc)
          .get();

      Set<String> maSVDaCoScore = {};

      for (var doc in diemSnap.docs) {
        maSVDaCoScore.add(doc['maSV'] ?? '');
      }

      List<SinhVien> danhSachSinhVienConLai = danhSachSinhVien
          .where((sv) => !maSVDaCoScore.contains(sv.maSV))
          .toList();

      setState(() => _isLoading = false);

      if (danhSachSinhVienConLai.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tất cả sinh viên đã có điểm môn này!'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final selectedStudents = await showDialog<List<SinhVien>>(
        context: context,
        builder: (context) => _buildSelectStudentDialog(danhSachSinhVienConLai),
      );

      if (selectedStudents == null || selectedStudents.isEmpty) return;

      setState(() => _isLoading = true);

      try {
        int hocKyMon = 0;

        final monSnap = await firestoreInstance
            .collection('mon_hoc')
            .where('maMon', isEqualTo: _selectedMonHoc)
            .get();

        if (monSnap.docs.isNotEmpty) {
          hocKyMon = monSnap.docs.first['hocKy'] ?? 0;
        }

        WriteBatch batch = firestoreInstance.batch();

        for (var sv in selectedStudents) {
          final svDoc = await firestoreInstance
              .collection('sinh_vien')
              .doc(sv.maSV)
              .get();

          int hocKySinhVien = (svDoc.data()?['hocKySinhVien'] ?? 1) as int;

          final diemRef = firestoreInstance
              .collection('diem')
              .doc('${sv.maSV}_$_selectedMonHoc');

          batch.set(diemRef, {
            'maDiem': '${sv.maSV}_$_selectedMonHoc',
            'maSV': sv.maSV,
            'maMon': _selectedMonHoc,
            'hocKyMon': hocKyMon,
            'hocKySinhVien': hocKySinhVien,
            'diemGiuaKy': 0.0,
            'diemCuoiKy': 0.0,
            'heSoGiuaKy': 0.4,
            'heSoCuoiKy': 0.6,
          });
        }

        await batch.commit();

        await _loadStudentDataFromFirestore();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Đã thêm ${selectedStudents.length} sinh viên thành công!',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi tải danh sách: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// ✅ THÊM MỚI: Dialog chọn sinh viên từ danh sách
  Widget _buildSelectStudentDialog(List<SinhVien> danhSach) {
    return StatefulBuilder(
      builder: (context, setDialogState) {
        bool isAllSelected =
            danhSach.isNotEmpty && _selectedStudents.length == danhSach.length;

        return Dialog(
          child: Container(
            width: 1000,
            height: 600,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Chọn sinh viên để thêm vào môn học',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Checkbox(
                      value: isAllSelected,
                      onChanged: (value) {
                        setDialogState(() {
                          if (value == true) {
                            _selectedStudents = List.from(danhSach);
                          } else {
                            _selectedStudents.clear();
                          }
                        });
                      },
                    ),
                    const Text(
                      'Chọn tất cả',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),

                    const Spacer(),

                    Text(
                      'Đã chọn: ${_selectedStudents.length}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: DataTable(
                        showCheckboxColumn: true,
                        columnSpacing: 20,
                        horizontalMargin: 12,
                        dataRowHeight: 56,
                        headingRowHeight: 56,
                        headingRowColor: WidgetStateProperty.all(
                          const Color(0xFFF7F9FF),
                        ),
                        border: TableBorder.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                        columns: const [
                          DataColumn(
                            label: SizedBox(
                              width: 90,
                              child: Text(
                                'MSSV',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: 180,
                              child: Text(
                                'Họ và Tên',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: 100,
                              child: Text(
                                'Lớp',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: 100,
                              child: Text(
                                'Học Kỳ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: 250,
                              child: Text(
                                'Email',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ],
                        rows: danhSach.map((sv) {
                          bool isSelected = _selectedStudents.any(
                            (item) => item.maSV == sv.maSV,
                          );

                          return DataRow(
                            selected: isSelected,
                            onSelectChanged: (selected) {
                              setDialogState(() {
                                if (selected == true) {
                                  if (!isSelected) {
                                    _selectedStudents.add(sv);
                                  }
                                } else {
                                  _selectedStudents.removeWhere(
                                    (item) => item.maSV == sv.maSV,
                                  );
                                }
                              });
                            },
                            cells: [
                              DataCell(
                                SizedBox(
                                  width: 90,
                                  child: Text(
                                    sv.maSV,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ),

                              DataCell(
                                SizedBox(
                                  width: 180,
                                  child: Text(
                                    sv.hoTen,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ),

                              DataCell(
                                SizedBox(
                                  width: 100,
                                  child: Text(
                                    sv.lop,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ),

                              DataCell(
                                SizedBox(
                                  width: 100,
                                  child: Center(
                                    child: Text(
                                      sv.hocKyHienTai.toString(),
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ),
                              ),

                              DataCell(
                                SizedBox(
                                  width: 250,
                                  child: Text(
                                    sv.email ?? '-',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.close),
                      label: const Text('Đóng'),
                    ),

                    const SizedBox(width: 12),

                    ElevatedButton.icon(
                      onPressed: _selectedStudents.isEmpty
                          ? null
                          : () {
                              Navigator.pop(context, _selectedStudents);
                            },
                      icon: const Icon(Icons.add),
                      label: Text('Thêm (${_selectedStudents.length})'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _deleteStudent(int index) async {
    final confirmed = await StudentDialogs.showDeleteConfirmDialog(context);
    if (confirmed == true && mounted) {
      String maSV = _studentData[index]['mssv'] as String;

      bool success = await _firestoreService.deleteSinhVien(maSV);

      if (success) {
        await _loadStudentDataFromFirestore();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Xóa sinh viên thành công!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Lỗi xóa sinh viên!'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
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

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cập nhật sinh viên thành công!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    }
  }

  // Hàm xử lý kích hoạt Dialog thêm Lớp học
  void _quickAddLop() async {
    final result = await StudentDialogs.showAddLopDialog(context);

    if (result != null && mounted) {
      setState(() => _isLoading = true);
      try {
        // Đọc dữ liệu ra an toàn theo đúng cấu trúc Map
        await _adminService.addLop(result['ID']!, result['tenlop']!);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã thêm lớp thành công: ${result['tenlop']}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi thêm lớp: $e'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  // Hàm xử lý kích hoạt Dialog thêm Học kỳ mới
  void _quickAddHocKy() async {
    final result = await StudentDialogs.showAddHocKyDialog(context);

    if (result != null && mounted) {
      setState(() => _isLoading = true);
      try {
        await _adminService.addHocKy(
          result['ID'],
          result['tenHocKy'],
          result['value'],
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã thêm học kỳ thành công: ${result['tenHocKy']}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi thêm học kỳ: $e'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      } finally {
        setState(() => _isLoading = false);
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
              hocKyMon: (student['hocKyMon'] as int?) ?? 1,
              hocKySinhVien: (student['hocKySinhVien'] as int?) ?? 1,
              diemGiuaKy: gk,
              diemCuoiKy: ck,
              heSoGiuaKy: 0.4,
              heSoCuoiKy: 0.6,
            ),
          );
        }
      }

      if (diemList.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không có dữ liệu điểm mới nào để lưu!'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      bool success = await _firestoreService.saveBatchDiem(diemList);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Lưu ${diemList.length} điểm thành công vào Firebase!',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Lỗi tiến trình khi lưu điểm lên Firebase!'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.redAccent),
        );
      }
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
          // Row chứa 2 nút: Thêm sinh viên mới + Chọn sinh viên có sẵn
          Row(
            children: [
              Expanded(
                child: PageHeaderWidget(
                  onAddStudent: _addStudent,
                  onSaveAll: _saveAllScores,
                  onQuickAddLop: _quickAddLop,
                  onQuickAddHocKy: _quickAddHocKy,
                ),
              ),
              const SizedBox(width: 16),
              // ✅ THÊM MỚI: Nút chọn sinh viên có sẵn
              ElevatedButton.icon(
                onPressed: _selectExistingStudent,
                icon: const Icon(Icons.person_add),
                label: const Text('Chọn SV có sẵn'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00AA66),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
            ],
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
