import 'package:flutter/material.dart';
import '../../models/mon_hoc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NhapMonScreen extends StatefulWidget {
  const NhapMonScreen({super.key});

  @override
  State<NhapMonScreen> createState() => _NhapMonScreenState();
}

class _NhapMonScreenState extends State<NhapMonScreen> {
  // removed unused FirestoreService instance

  String _searchQuery = '';
  String _selectedSubjectType = '';
  // ✅ THÊM MỚI: Bộ lọc theo học kỳ ('' = tất cả)
  int? _selectedHocKy;

  List<MonHoc> _allMonHocList = [];
  List<MonHoc> _filteredMonHocList = [];
  bool _isLoading = true;

  final Color _primaryColor = const Color(0xFF006491);
  final Color _backgroundColor = const Color(0xFFF7F9FF);
  final Color _surfaceColor = const Color(0xFFFFFFFF);
  final Color _borderColor = const Color(0xFFD6EAF8);
  final Color _accentBlue = const Color(0xFF5DADE2);
  final Color _errorRed = const Color(0xFFC0392B);

  @override
  void initState() {
    super.initState();
    _loadDanhSachMonHoc();
  }

  Future<void> _loadDanhSachMonHoc() async {
    setState(() => _isLoading = true);
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('mon_hoc')
          .get();

      _allMonHocList = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return MonHoc(
          maMon: doc.id,
          tenMon: data['tenMon'] ?? '',
          soTinChi: data['soTinChi'] ?? 0,
          hocKy: data['hocKy'] ?? 1,
        );
      }).toList();

      _filterSubjects();
    } catch (e) {
      print('Lỗi tải danh sách môn học: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể tải dữ liệu môn học: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterSubjects() {
    setState(() {
      _filteredMonHocList = _allMonHocList.where((monHoc) {
        final matchesSearchQuery =
            (monHoc.maMon).toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (monHoc.tenMon).toLowerCase().contains(_searchQuery.toLowerCase());

        final matchesSubjectType =
            _selectedSubjectType.isEmpty ||
            (_selectedSubjectType == 'mandatory' && monHoc.soTinChi > 2) ||
            (_selectedSubjectType == 'elective' && monHoc.soTinChi <= 2);

        // ✅ THÊM MỚI: Lọc theo học kỳ
        final matchesHocKy =
            _selectedHocKy == null || monHoc.hocKy == _selectedHocKy;

        return matchesSearchQuery && matchesSubjectType && matchesHocKy;
      }).toList();
    });
  }

  void _addMonHoc() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildAddEditMonHocDialog(null),
    );
  }

  void _editMonHoc(MonHoc monHoc) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildAddEditMonHocDialog(monHoc),
    );
  }

  void _deleteMonHoc(MonHoc monHoc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
          "Bạn có chắc chắn muốn xóa môn học '${monHoc.tenMon}' khỏi hệ thống không? Hành động này không thể hoàn tác.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);
              try {
                await FirebaseFirestore.instance
                    .collection('mon_hoc')
                    .doc(monHoc.maMon)
                    .delete();

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Xóa môn học thành công!')),
                  );
                }
                _loadDanhSachMonHoc();
              } catch (e) {
                setState(() => _isLoading = false);
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Xóa thất bại: $e')));
                }
              }
            },
            child: Text('Xóa', style: TextStyle(color: _errorRed)),
          ),
        ],
      ),
    );
  }

  Widget _buildAddEditMonHocDialog(MonHoc? existingMonHoc) {
    final isEditing = existingMonHoc != null;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: _AddEditDialogContent(
          existingMonHoc: existingMonHoc,
          isEditing: isEditing,
          allMonHocList: _allMonHocList,
          accentBlue: _accentBlue,
          onSaveSuccess: () {
            _loadDanhSachMonHoc();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 768;

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : isDesktop
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

  Widget _buildTopBar() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 32),
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
              Container(
                width: 200,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDF4FF),
                  border: Border.all(color: _borderColor),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Tìm kiếm nhanh...',
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search, size: 18),
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                      _filterSubjects();
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadDanhSachMonHoc,
              ),
              const SizedBox(width: 16),
              Container(width: 1, height: 30, color: _borderColor),
              const SizedBox(width: 16),
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
                        'Quản trị viên',
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
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDanhSachMonHoc,
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
          _buildPageHeader(),
          const SizedBox(height: 24),
          _buildFiltersAndSearchSection(),
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
              'Quản lý danh sách môn học',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              'Xem, tìm kiếm và đồng bộ trực tiếp thông tin các môn học với hệ thống cơ sở dữ liệu đám mây Firestore.',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: _addMonHoc,
          icon: const Icon(Icons.add),
          label: const Text('Thêm môn học mới'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ],
    );
  }

  // ✅ CẬP NHẬT: Thêm dropdown lọc theo học kỳ
  Widget _buildFiltersAndSearchSection() {
    // Lấy danh sách học kỳ duy nhất từ dữ liệu hiện có để làm options cho dropdown
    final List<int> danhSachHocKy =
        _allMonHocList.map((m) => m.hocKy).toSet().toList()..sort();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _surfaceColor,
        border: Border.all(color: _borderColor),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFEAF4FB),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tìm kiếm và Bộ lọc nâng cao',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Ô tìm kiếm
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Nhập mã môn học hoặc tên môn học cần lọc...',
                    labelText: 'Từ khóa tìm kiếm',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 12,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                      _filterSubjects();
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),

              // Dropdown lọc loại môn
              SizedBox(
                width: 200,
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Loại cấu trúc môn',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 12,
                    ),
                  ),
                  initialValue: _selectedSubjectType.isEmpty
                      ? null
                      : _selectedSubjectType,
                  items: const [
                    DropdownMenuItem(value: '', child: Text('Tất cả các loại')),
                    DropdownMenuItem(
                      value: 'mandatory',
                      child: Text('Bắt buộc (> 2 TC)'),
                    ),
                    DropdownMenuItem(
                      value: 'elective',
                      child: Text('Tự chọn (≤ 2 TC)'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedSubjectType = value ?? '';
                      _filterSubjects();
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),

              // ✅ THÊM MỚI: Dropdown lọc theo học kỳ
              SizedBox(
                width: 180,
                child: DropdownButtonFormField<int?>(
                  decoration: const InputDecoration(
                    labelText: 'Học kỳ',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 12,
                    ),
                  ),
                  initialValue: _selectedHocKy,
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('Tất cả học kỳ'),
                    ),
                    ...danhSachHocKy.map(
                      (hk) => DropdownMenuItem<int?>(
                        value: hk,
                        child: Text('Học kỳ $hk'),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedHocKy = value;
                      _filterSubjects();
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTableSection() {
    return Container(
      decoration: BoxDecoration(
        color: _surfaceColor,
        border: Border.all(color: _borderColor),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFEAF4FB),
            blurRadius: 12,
            offset: Offset(0, 4),
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
            'Danh sách môn học hiện hành',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF9AD6FF),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Tổng số dòng: ${_filteredMonHocList.length}',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF165E81),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTable() {
    if (_filteredMonHocList.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(child: Text('Không tìm thấy môn học nào phù hợp.')),
      );
    }

    return DataTable(
      columnSpacing: 24,
      dataRowMinHeight: 60,
      dataRowMaxHeight: 60,
      headingRowHeight: 56,
      headingRowColor: WidgetStateColor.resolveWith(
        (states) => const Color(0xFFF7F9FF),
      ),
      columns: const [
        DataColumn(
          label: Text(
            'Mã môn',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
        DataColumn(
          label: Text(
            'Tên môn học',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
        DataColumn(
          label: Text(
            'Số tín chỉ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
        // ✅ THÊM MỚI: Cột học kỳ
        DataColumn(
          label: Text(
            'Học kỳ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
        DataColumn(
          label: Text(
            'Phân loại',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
        DataColumn(
          label: Text(
            'Thao tác',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
      ],
      rows: _filteredMonHocList.map((monHoc) => _buildDataRow(monHoc)).toList(),
    );
  }

  DataRow _buildDataRow(MonHoc monHoc) {
    bool isMandatory = monHoc.soTinChi > 2;
    String subjectType = isMandatory ? 'Bắt buộc' : 'Tự chọn';
    Color typeColor = isMandatory ? _errorRed : _accentBlue;
    Color bgColor = isMandatory
        ? const Color(0xFFFDEDEC)
        : const Color(0xFFEAF4FB);

    return DataRow(
      cells: [
        DataCell(
          Text(
            monHoc.maMon,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF006491),
            ),
          ),
        ),
        DataCell(Text(monHoc.tenMon, style: const TextStyle(fontSize: 12))),
        DataCell(
          Text(
            monHoc.soTinChi.toString(),
            style: const TextStyle(fontSize: 12),
          ),
        ),
        // ✅ THÊM MỚI: Cell hiển thị học kỳ
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFEDF7FF),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFADD8F7)),
            ),
            child: Text(
              'HK ${monHoc.hocKy}',
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF006491),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              subjectType,
              style: TextStyle(
                fontSize: 11,
                color: typeColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        DataCell(
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.edit, size: 18, color: _primaryColor),
                onPressed: () => _editMonHoc(monHoc),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: Icon(Icons.delete, size: 18, color: _errorRed),
                onPressed: () => _deleteMonHoc(monHoc),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTableFooter() {
    return Container(
      color: const Color(0xFFF7F9FF),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Hiển thị toàn bộ ${_filteredMonHocList.length} kết quả.',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, size: 16),
                onPressed: null,
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF4FB),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '1',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, size: 16),
                onPressed: null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==================== WIDGET DIALOG ====================
class _AddEditDialogContent extends StatefulWidget {
  final MonHoc? existingMonHoc;
  final bool isEditing;
  final List<MonHoc> allMonHocList;
  final Color accentBlue;
  final VoidCallback onSaveSuccess;

  const _AddEditDialogContent({
    required this.existingMonHoc,
    required this.isEditing,
    required this.allMonHocList,
    required this.accentBlue,
    required this.onSaveSuccess,
  });

  @override
  State<_AddEditDialogContent> createState() => _AddEditDialogContentState();
}

class _AddEditDialogContentState extends State<_AddEditDialogContent> {
  late TextEditingController maMonController;
  late TextEditingController tenMonController;
  late TextEditingController soTinChiController;
  // ✅ THÊM MỚI: Controller cho trường học kỳ
  late TextEditingController hocKyController;
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    maMonController = TextEditingController(
      text: widget.isEditing ? widget.existingMonHoc!.maMon : '',
    );
    tenMonController = TextEditingController(
      text: widget.isEditing ? widget.existingMonHoc!.tenMon : '',
    );
    soTinChiController = TextEditingController(
      text: widget.isEditing ? widget.existingMonHoc!.soTinChi.toString() : '',
    );
    // ✅ THÊM MỚI: Khởi tạo với học kỳ hiện tại nếu đang sửa, mặc định '1' nếu thêm mới
    hocKyController = TextEditingController(
      text: widget.isEditing ? widget.existingMonHoc!.hocKy.toString() : '1',
    );
  }

  @override
  void dispose() {
    maMonController.dispose();
    tenMonController.dispose();
    soTinChiController.dispose();
    hocKyController.dispose(); // ✅ Giải phóng controller mới
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.isEditing
                ? 'Chỉnh sửa thông tin môn học'
                : 'Thêm dữ liệu môn học mới',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Mã môn
          TextFormField(
            controller: maMonController,
            decoration: const InputDecoration(
              labelText: 'Mã môn học',
              border: OutlineInputBorder(),
            ),
            enabled: !widget.isEditing,
            validator: (val) {
              if (val == null || val.trim().isEmpty)
                return 'Vui lòng nhập mã môn';
              if (!widget.isEditing) {
                bool isDup = widget.allMonHocList.any(
                  (m) =>
                      m.maMon.trim().toLowerCase() == val.trim().toLowerCase(),
                );
                if (isDup) return 'Mã môn học này đã có trên cơ sở dữ liệu!';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Tên môn
          TextFormField(
            controller: tenMonController,
            decoration: const InputDecoration(
              labelText: 'Tên định danh môn học',
              border: OutlineInputBorder(),
            ),
            validator: (val) => (val == null || val.trim().isEmpty)
                ? 'Tên môn học bắt buộc nhập'
                : null,
          ),
          const SizedBox(height: 16),

          // Số tín chỉ
          TextFormField(
            controller: soTinChiController,
            decoration: const InputDecoration(
              labelText: 'Số lượng tín chỉ cấu thành',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: (val) {
              if (val == null || val.trim().isEmpty)
                return 'Vui lòng điền số tín chỉ';
              final parsed = int.tryParse(val.trim());
              if (parsed == null || parsed <= 0)
                return 'Số tín chỉ phải lớn hơn 0';
              return null;
            },
          ),
          const SizedBox(height: 16),

          // ✅ THÊM MỚI: Trường nhập học kỳ
          TextFormField(
            controller: hocKyController,
            decoration: const InputDecoration(
              labelText: 'Học kỳ môn học',
              hintText: 'Ví dụ: 1, 2, 3...',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.school_outlined),
            ),
            keyboardType: TextInputType.number,
            validator: (val) {
              if (val == null || val.trim().isEmpty)
                return 'Vui lòng nhập học kỳ';
              final parsed = int.tryParse(val.trim());
              if (parsed == null || parsed <= 0)
                return 'Học kỳ phải là số nguyên lớn hơn 0';
              return null;
            },
          ),
          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _isSaving ? null : () => Navigator.pop(context),
                child: const Text('Đóng'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _isSaving ? null : _saveDataToFirestore,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.accentBlue,
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        widget.isEditing
                            ? 'Cập nhật Firestore'
                            : 'Lưu lên Cloud',
                        style: const TextStyle(color: Colors.white),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _saveDataToFirestore() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final mMa = maMonController.text.trim();
    final mTen = tenMonController.text.trim();
    final mTin = int.parse(soTinChiController.text.trim());
    // ✅ THÊM MỚI: Lấy giá trị học kỳ từ controller
    final mHocKy = int.parse(hocKyController.text.trim());

    try {
      await FirebaseFirestore.instance.collection('mon_hoc').doc(mMa).set({
        'maMon': mMa,
        'tenMon': mTen,
        'soTinChi': mTin,
        'hocKy': mHocKy, // ✅ Lưu đúng giá trị học kỳ người dùng nhập
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      Navigator.pop(context);
      widget.onSaveSuccess();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEditing
                  ? 'Cập nhật môn học thành công!'
                  : 'Thêm môn học mới lên Firestore thành công!',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lưu thất bại: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
