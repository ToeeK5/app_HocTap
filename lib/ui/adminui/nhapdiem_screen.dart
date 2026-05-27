import 'package:flutter/material.dart';
import '../../data/app_data.dart';
import '../../models/sinh_vien.dart';

class NhapDiemScreen extends StatefulWidget {
  const NhapDiemScreen({super.key});

  @override
  State<NhapDiemScreen> createState() => _NhapDiemScreenState();
}

class _NhapDiemScreenState extends State<NhapDiemScreen> {
  int _currentPage = 1;
  String _selectedMonHoc = '';
  String _selectedLopHoc = '';

  late List<Map<String, dynamic>> _studentData;
  late Map<int, Map<String, TextEditingController>> _controllers;
  late List<String> _danhSachLop;

  final Color _primaryColor = const Color(0xFF006491);
  final Color _secondaryColor = const Color(0xFF206488);
  final Color _tertiaryColor = const Color(0xFF006397);
  final Color _backgroundColor = const Color(0xFFF7F9FF);
  final Color _surfaceColor = const Color(0xFFFFFFFF);
  final Color _borderColor = const Color(0xFFD6EAF8);
  final Color _accentBlue = const Color(0xFF5DADE2);
  final Color _successGreen = const Color(0xFF117A65);
  final Color _errorRed = const Color(0xFFC0392B);

  @override
  void initState() {
    super.initState();

    // 1. Dọn sạch dữ liệu môn học đầu vào
    if (AppData.danhSachMonHoc.isNotEmpty) {
      _selectedMonHoc = (AppData.danhSachMonHoc.first.maMon ?? '').trim();
    } else {
      _selectedMonHoc = "MH001";
    }

    // 2. Gom danh sách lớp học duy nhất từ danh sách Sinh viên, xóa khoảng trắng thừa
    final lopSet = AppData.danhSachSinhVien
        .map((sv) => (sv.lop ?? '').trim())
        .where((s) => s.isNotEmpty)
        .toSet();
    _danhSachLop = lopSet.toList()..sort();

    // Nếu không có dữ liệu lớp nào trong hệ thống, cấu hình mảng mặc định an toàn
    if (_danhSachLop.isEmpty) {
      _danhSachLop = ['CNTT1', 'CNTT2'];
    }

    // 3. Gán giá trị chọn mặc định bắt buộc trùng khớp với phần tử đầu tiên trong mảng sạch
    _selectedLopHoc = _danhSachLop.first;

    // 4. Khởi tạo mảng dữ liệu sinh viên hiển thị ban đầu
    _studentData = [];
    _controllers = {};

    _loadStudentData();
  }

  void _loadStudentData() {
  // 1. Chuẩn hóa chuỗi chọn lớp (xóa khoảng trắng thừa) để so sánh chính xác
  final targetLop = _selectedLopHoc.trim();
  final targetMon = _selectedMonHoc.trim();

  // Lấy danh sách sinh viên thuộc lớp đã chọn sau khi đã trim()
  List<SinhVien> sinhVienLop = AppData.danhSachSinhVien
      .where((sv) => (sv.lop ?? '').trim() == targetLop)
      .toList();

  _studentData = [];
  for (int i = 0; i < sinhVienLop.length; i++) {
    SinhVien sv = sinhVienLop[i];
    
    // 2. Tìm kiếm điểm an toàn bằng cách lọc danh sách trước để tránh lỗi orElse: () => null
    final diemTimDuoc = AppData.danhSachDiem.where(
      (d) => (d.maSV ?? '').trim() == (sv.maSV ?? '').trim() && 
             (d.maMon ?? '').trim() == targetMon
    ).toList();

    // Nếu tìm thấy phần tử trong danh sách lọc thì lấy cái đầu tiên, ngược lại gán null
    var diem = diemTimDuoc.isNotEmpty ? diemTimDuoc.first : null;

    _studentData.add({
      'stt': i + 1,
      'mssv': sv.maSV,
      'ten': sv.hoTen,
      'gk': diem != null ? (diem.diemGiuaKy?.toDouble() ?? 0.0) : 0.0,
      'ck': diem != null ? (diem.diemCuoiKy?.toDouble() ?? 0.0) : 0.0,
    });
  }

  _controllers = {};
  _initializeControllers();
}
  void _initializeControllers() {
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
  void _addStudent() {
    showDialog(
      context: context,
      builder: (context) => _buildAddStudentDialog(),
    );
  }

  void _deleteStudent(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa sinh viên này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _controllers[index]?['gk']?.dispose();
                _controllers[index]?['ck']?.dispose();
                _controllers.remove(index);
                _studentData.removeAt(index);
                _renumberStudents();
              });
              Navigator.pop(context);
            },
            child: const Text(
              'Xóa',
              style: TextStyle(color: Color(0xFFC0392B)),
            ),
          ),
        ],
      ),
    );
  }

  void _renumberStudents() {
    for (int i = 0; i < _studentData.length; i++) {
      _studentData[i]['stt'] = i + 1;
    }
  }

  void _editStudent(int index) {
    showDialog(
      context: context,
      builder: (context) => _buildEditStudentDialog(index),
    );
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

  Widget _buildAddStudentDialog() {
    final mssvController = TextEditingController();
    final tenController = TextEditingController();

    return AlertDialog(
      title: const Text('Thêm sinh viên mới'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: mssvController,
            decoration: const InputDecoration(
              labelText: 'MSSV',
              hintText: 'Nhập MSSV',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: tenController,
            decoration: const InputDecoration(
              labelText: 'Tên sinh viên',
              hintText: 'Nhập tên sinh viên',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            mssvController.dispose();
            tenController.dispose();
            Navigator.pop(context);
          },
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: () {
            if (mssvController.text.isEmpty || tenController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')),
              );
              return;
            }

            setState(() {
              int newIndex = _studentData.length;
              _studentData.add({
                'stt': newIndex + 1,
                'mssv': mssvController.text,
                'ten': tenController.text,
                'gk': 0.0,
                'ck': 0.0,
              });

              _controllers[newIndex] = {
                'gk': TextEditingController(text: ''),
                'ck': TextEditingController(text: ''),
              };
            });

            mssvController.dispose();
            tenController.dispose();
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(backgroundColor: _accentBlue),
          child: const Text('Thêm', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildEditStudentDialog(int index) {
    final mssvController = TextEditingController(
      text: _studentData[index]['mssv'],
    );
    final tenController = TextEditingController(
      text: _studentData[index]['ten'],
    );

    return AlertDialog(
      title: const Text('Chỉnh sửa thông tin sinh viên'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: mssvController,
            decoration: const InputDecoration(
              labelText: 'MSSV',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: tenController,
            decoration: const InputDecoration(
              labelText: 'Tên sinh viên',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            mssvController.dispose();
            tenController.dispose();
            Navigator.pop(context);
          },
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _studentData[index]['mssv'] = mssvController.text;
              _studentData[index]['ten'] = tenController.text;
            });

            mssvController.dispose();
            tenController.dispose();
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(backgroundColor: _accentBlue),
          child: const Text('Cập nhật', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  double _calculateDTB(double gk, double ck) {
    if (gk == 0 && ck == 0) return 0;
    return double.parse((gk * 0.4 + ck * 0.6).toStringAsFixed(1));
  }

  String _getStatus(double dtb) {
    if (dtb == 0) return 'Chưa nhập';
    return dtb >= 4.0 ? 'Đạt' : 'Trượt';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Đạt':
        return _successGreen;
      case 'Trượt':
        return _errorRed;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 768;

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: isDesktop
          ? Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _buildTopBar(),
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
                _buildTopBarMobile(),
                Expanded(
                  child: SingleChildScrollView(child: _buildMainContent()),
                ),
              ],
            ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    bool isActive, {
    bool isError = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF9AD6FF) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          size: 20,
          color: isError ? _errorRed : (isActive ? _primaryColor : Colors.grey),
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            color: isError ? _errorRed : Colors.black87,
          ),
        ),
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      ),
    );
  }

  // ==================== TOP BAR ====================
  Widget _buildTopBar() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 0),
      decoration: BoxDecoration(
        color: _surfaceColor,
        border: Border(bottom: BorderSide(color: _borderColor, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'EduAdmin Dashboard',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Row(
            children: [
              // Search
              Container(
                width: 200,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDF4FF),
                  border: Border.all(color: _borderColor),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm...',
                    border: InputBorder.none,
                    prefixIcon: const Icon(Icons.search, size: 18),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Notifications
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {},
              ),
              const SizedBox(width: 16),
              // Help
              IconButton(
                icon: const Icon(Icons.help_outline),
                onPressed: () {},
              ),
              const SizedBox(width: 16),
              // Divider
              Container(width: 1, height: 30, color: _borderColor),
              const SizedBox(width: 16),
              // User Info
              Row(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: const [
                      Text(
                        'Nguyễn Văn A',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        'Giảng viên',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: _accentBlue,
                    child: const Text(
                      'A',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopBarMobile() {
    return Container(
      height: 64,
      color: _surfaceColor,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'EduAdmin',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          CircleAvatar(
            backgroundColor: _accentBlue,
            child: const Text('A', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ==================== MAIN CONTENT ====================
  Widget _buildMainContent() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPageHeader(),
          const SizedBox(height: 24),
          _buildFilterAndStatsSection(),
          const SizedBox(height: 24),
          _buildTableSection(),
        ],
      ),
    );
  }

  Widget _buildPageHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nhập điểm sinh viên',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              'Học kỳ 1 - Năm học 2023-2024',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _addStudent,
              icon: const Icon(Icons.person_add),
              label: const Text('Thêm sinh viên'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _successGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.save),
              label: const Text('Lưu bảng điểm'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _accentBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterAndStatsSection() {
    // Calculate class average
    double totalDTB = 0;
    int count = 0;
    for (var student in _studentData) {
      double dtb = _calculateDTB(
        student['gk'] as double,
        student['ck'] as double,
      );
      if (dtb > 0) {
        totalDTB += dtb;
        count++;
      }
    }
    double classAverage = count > 0 ? totalDTB / count : 0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filters Card
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _surfaceColor,
              border: Border.all(color: _borderColor),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFEAF4FB),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Chọn Lớp & Môn Học',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    // Môn Học Dropdown
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Môn học',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: _borderColor),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                value: _selectedMonHoc.isNotEmpty
                                    ? _selectedMonHoc
                                    : null,
                                items: AppData.danhSachMonHoc
                                    .map((m) => (m.maMon ?? '').trim())
                                    .where((s) => s.isNotEmpty)
                                    .toSet()
                                    .toList()
                                    .map((maMon) {
                                      final monHoc = AppData.danhSachMonHoc
                                          .firstWhere(
                                            (m) =>
                                                (m.maMon ?? '').trim() == maMon,
                                            orElse: () =>
                                                AppData.danhSachMonHoc.first,
                                          );
                                      return DropdownMenuItem<String>(
                                        value: maMon,
                                        child: Text(monHoc.tenMon ?? maMon),
                                      );
                                    })
                                    .toList(),
                                onChanged: (v) {
                                  if (v != null) {
                                    setState(() {
                                      _selectedMonHoc = v;
                                      for (var controllers
                                          in _controllers.values) {
                                        controllers['gk']?.dispose();
                                        controllers['ck']?.dispose();
                                      }
                                      _controllers.clear();
                                      _loadStudentData();
                                      _currentPage = 1;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Lớp Học Dropdown
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lớp học',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: _borderColor),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                value: _danhSachLop.contains(_selectedLopHoc)
                                    ? _selectedLopHoc
                                    : _danhSachLop.first,
                                items: _danhSachLop
                                    .map(
                                      (lop) => DropdownMenuItem<String>(
                                        value: lop,
                                        child: Text(lop),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) {
                                  if (v != null) {
                                    setState(() {
                                      _selectedLopHoc = v;
                                      for (var controllers
                                          in _controllers.values) {
                                        controllers['gk']?.dispose();
                                        controllers['ck']?.dispose();
                                      }
                                      _controllers.clear();
                                      _loadStudentData();
                                      _currentPage = 1;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 24),
        // Stats Cards (side-by-side)
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Tổng số SV',
                  '${_studentData.length}',
                  Icons.groups,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'ĐTB Lớp',
                  classAverage.toStringAsFixed(1),
                  Icons.analytics,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceColor,
        border: Border.all(color: _borderColor),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEAF4FB),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFEDF4FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: _accentBlue, size: 20),
          ),
          const SizedBox(height: 8),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E86C1),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== TABLE SECTION ====================
  Widget _buildTableSection() {
    return Container(
      decoration: BoxDecoration(
        color: _surfaceColor,
        border: Border.all(color: _borderColor),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEAF4FB),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTableHeader(),
          const Divider(height: 1, color: Color(0xFFD6EAF8)),
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: _buildTable(),
                ),
              );
            },
          ),
          const Divider(height: 1, color: Color(0xFFD6EAF8)),
          _buildTableFooter(),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      color: const Color(0xFFF7F9FF),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Danh sách nhập điểm',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF9AD6FF),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Tổng: ${_studentData.length} SV',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF165E81),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                child: const Text(
                  'Lưu tất cả',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTable() {
    return DataTable(
      columnSpacing: 24,
      dataRowHeight: 60,
      headingRowHeight: 56,
      headingRowColor: MaterialStateColor.resolveWith(
        (states) => const Color(0xFFF7F9FF),
      ),
      columns: const [
        DataColumn(
          label: Text(
            'STT',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          numeric: false,
        ),
        DataColumn(
          label: Text(
            'MSSV',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
        DataColumn(
          label: Text(
            'Họ và Tên',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
        DataColumn(
          label: Text(
            'Giữa kỳ (0.4)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
        DataColumn(
          label: Text(
            'Cuối kỳ (0.6)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
        DataColumn(
          label: Text(
            'ĐTB',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
        DataColumn(
          label: Text(
            'Trạng thái',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
        DataColumn(
          label: Text(
            'Hành động',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
      ],
      rows: _buildDataRows(),
    );
  }

  List<DataRow> _buildDataRows() {
    return _studentData.asMap().entries.map((entry) {
      int index = entry.key;
      Map<String, dynamic> data = entry.value;

      double gk =
          double.tryParse(_controllers[index]?['gk']?.text ?? '') ??
          (data['gk'] as double);
      double ck =
          double.tryParse(_controllers[index]?['ck']?.text ?? '') ??
          (data['ck'] as double);

      double dtb = _calculateDTB(gk, ck);
      String status = _getStatus(dtb);

      return _buildDataRow(
        data['stt'] as int,
        data['mssv'] as String,
        data['ten'] as String,
        gk,
        ck,
        dtb,
        status,
      );
    }).toList();
  }

  DataRow _buildDataRow(
    int stt,
    String mssv,
    String ten,
    double gk,
    double ck,
    double dtb,
    String status,
  ) {
    int index = _studentData.indexWhere((e) => e['mssv'] == mssv);

    return DataRow(
      cells: [
        DataCell(
          Text(
            '$stt',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ),
        DataCell(
          Text(
            mssv,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
        DataCell(Text(ten, style: const TextStyle(fontSize: 12))),
        DataCell(
          Container(
            width: 80,
            height: 36,
            decoration: BoxDecoration(
              border: Border.all(color: _borderColor),
              borderRadius: BorderRadius.circular(4),
            ),
            child: TextField(
              textAlign: TextAlign.center,
              controller: _controllers[index]?['gk'],
              onChanged: (value) => _updateScore(index, 'gk', value),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: '0',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ),
        DataCell(
          Container(
            width: 80,
            height: 36,
            decoration: BoxDecoration(
              border: Border.all(color: _borderColor),
              borderRadius: BorderRadius.circular(4),
            ),
            child: TextField(
              textAlign: TextAlign.center,
              controller: _controllers[index]?['ck'],
              onChanged: (value) => _updateScore(index, 'ck', value),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: '0',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ),
        DataCell(
          Text(
            dtb > 0 ? dtb.toStringAsFixed(1) : '-',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: dtb > 0 ? const Color(0xFF2E86C1) : Colors.grey,
            ),
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: status == 'Đạt'
                  ? const Color(0xFFE8F8F5)
                  : status == 'Trượt'
                  ? const Color(0xFFFDEDEC)
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              status,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: status == 'Đạt'
                    ? _successGreen
                    : status == 'Trượt'
                    ? _errorRed
                    : Colors.grey[600],
              ),
            ),
          ),
        ),
        DataCell(
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.edit,
                  size: 18,
                  color: Color(0xFF006491),
                ),
                onPressed: () => _editStudent(index),
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(4),
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete,
                  size: 18,
                  color: Color(0xFFC0392B),
                ),
                onPressed: () => _deleteStudent(index),
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(4),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTableFooter() {
    int totalStudents = _studentData.length;
    int itemsPerPage = 4;
    int totalPages = (totalStudents / itemsPerPage).ceil();
    int startIndex = (_currentPage - 1) * itemsPerPage + 1;
    int endIndex = (_currentPage * itemsPerPage).clamp(0, totalStudents);

    return Container(
      color: const Color(0xFFF7F9FF),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Hiển thị $startIndex-$endIndex trên $totalStudents sinh viên',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          Row(
            children: [
              _buildPaginationButton(Icons.chevron_left, () {
                if (_currentPage > 1) setState(() => _currentPage--);
              }),
              ..._buildPageNumbers(totalPages),
              _buildPaginationButton(Icons.chevron_right, () {
                if (_currentPage < totalPages) setState(() => _currentPage++);
              }),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageNumbers(int totalPages) {
    List<Widget> pages = [];
    for (int i = 1; i <= totalPages && i <= 3; i++) {
      pages.add(_buildPaginationPageButton('$i', _currentPage == i));
      if (i < totalPages && i == 2) {
        pages.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              '...',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
        );
        break;
      }
    }
    return pages;
  }

  Widget _buildPaginationButton(IconData icon, VoidCallback onPressed) {
    return SizedBox(
      width: 32,
      height: 32,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: _borderColor),
          borderRadius: BorderRadius.circular(4),
        ),
        child: IconButton(
          icon: Icon(icon, size: 16),
          onPressed: onPressed,
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _buildPaginationPageButton(String page, bool isActive) {
    return Container(
      width: 32,
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFEAF4FB) : Colors.transparent,
        border: Border.all(color: isActive ? _accentBlue : _borderColor),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Text(
          page,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isActive ? const Color(0xFF2E86C1) : Colors.grey[600],
          ),
        ),
      ),
    );
  }
}