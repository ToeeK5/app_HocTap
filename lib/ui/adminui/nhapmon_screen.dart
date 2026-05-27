import 'package:flutter/material.dart';
import '../../data/app_data.dart';
import '../../models/mon_hoc.dart';

class NhapMonScreen extends StatefulWidget {
  const NhapMonScreen({super.key});

  @override
  State<NhapMonScreen> createState() => _NhapMonScreenState();
}

class _NhapMonScreenState extends State<NhapMonScreen> {
  String _searchQuery = '';
  String _selectedSubjectType = ''; // 'mandatory', 'elective', or '' for all
  late List<MonHoc> _filteredMonHocList;

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
    _filterSubjects();
  }

  void _filterSubjects() {
    setState(() {
      _filteredMonHocList = AppData.danhSachMonHoc.where((monHoc) {
        final matchesSearchQuery =
            monHoc.maMon.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            monHoc.tenMon.toLowerCase().contains(_searchQuery.toLowerCase());

        final matchesSubjectType =
            _selectedSubjectType.isEmpty ||
            (_selectedSubjectType == 'mandatory' &&
                monHoc.soTinChi > 2) || // Example logic, adjust as needed
            (_selectedSubjectType == 'elective' &&
                monHoc.soTinChi <= 2); // Example logic, adjust as needed

        return matchesSearchQuery && matchesSubjectType;
      }).toList();
    });
  }

  void _addMonHoc() {
    showDialog(
      context: context,
      barrierDismissible: false, // Ngăn bấm ra ngoài làm rò rỉ controller
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
        // Sửa lỗi dấu nháy đơn lồng nhau bằng cách dùng dấu nháy kép bọc ngoài
        content: Text(
          "Bạn có chắc chắn muốn xóa môn học '${monHoc.tenMon}' không?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                AppData.danhSachMonHoc.removeWhere(
                  (m) => m.maMon == monHoc.maMon,
                );
                // Đảm bảo hàm _filterSubjects() tồn tại trong file của bạn
                _filterSubjects();
              });
              Navigator.pop(context);
            },
            child: Text('Xóa', style: TextStyle(color: _errorRed)),
          ),
        ],
      ),
    );
  }

  Widget _buildAddEditMonHocDialog(MonHoc? existingMonHoc) {
    final isEditing = existingMonHoc != null;

    // Sử dụng StatefulBuilder để quản lý đóng mở và khởi tạo Controller an toàn
    return StatefulBuilder(
      builder: (context, setDialogState) {
        // Khởi tạo controllers an toàn bên trong block builder
        final maMonController = TextEditingController(
          text: isEditing ? existingMonHoc.maMon : '',
        );
        final tenMonController = TextEditingController(
          text: isEditing ? existingMonHoc.tenMon : '',
        );
        final soTinChiController = TextEditingController(
          text: isEditing ? existingMonHoc.soTinChi.toString() : '',
        );

        return AlertDialog(
          title: Text(isEditing ? 'Chỉnh sửa môn học' : 'Thêm môn học mới'),
          content: SingleChildScrollView(
            // Chống tràn màn hình khi bật bàn phím ảo
            child: Column(
              mainAxisSize:
                  MainAxisSize.min, // Sửa lỗi chữ 'quizás' thành 'min'
              children: [
                TextField(
                  controller: maMonController,
                  decoration: const InputDecoration(
                    labelText: 'Mã môn',
                    border: OutlineInputBorder(),
                  ),
                  enabled: !isEditing,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: tenMonController,
                  decoration: const InputDecoration(
                    labelText: 'Tên môn học',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: soTinChiController,
                  decoration: const InputDecoration(
                    labelText: 'Số tín chỉ',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Giải phóng bộ nhớ trước khi đóng
                maMonController.dispose();
                tenMonController.dispose();
                soTinChiController.dispose();
                Navigator.pop(context);
              },
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                if (maMonController.text.trim().isEmpty ||
                    tenMonController.text.trim().isEmpty ||
                    soTinChiController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vui lòng điền đầy đủ thông tin'),
                    ),
                  );
                  return;
                }

                final newMaMon = maMonController.text.trim();
                final newTenMon = tenMonController.text.trim();
                final newSoTinChi = int.tryParse(
                  soTinChiController.text.trim(),
                );

                if (newSoTinChi == null || newSoTinChi <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Số tín chỉ không hợp lệ')),
                  );
                  return;
                }

                // Kiểm tra trùng mã môn khi THÊM MỚI
                if (!isEditing) {
                  final isDuplicate = AppData.danhSachMonHoc.any(
                    (m) =>
                        (m.maMon ?? '').trim().toLowerCase() ==
                        newMaMon.toLowerCase(),
                  );
                  if (isDuplicate) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Mã môn học này đã tồn tại'),
                      ),
                    );
                    return;
                  }
                }

                // Cập nhật lên State tổng của màn hình chính
                setState(() {
                  if (isEditing) {
                    existingMonHoc.tenMon = newTenMon;
                    existingMonHoc.soTinChi = newSoTinChi;
                  } else {
                    AppData.danhSachMonHoc.add(
                      MonHoc(
                        maMon: newMaMon,
                        tenMon: newTenMon,
                        soTinChi: newSoTinChi,
                        hocKy: 3,
                      ),
                    );
                  }
                  _filterSubjects(); // Gọi hàm cập nhật lại UI màn hình cha
                });

                // Giải phóng bộ nhớ sau khi lưu thành công
                maMonController.dispose();
                tenMonController.dispose();
                soTinChiController.dispose();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: _accentBlue),
              child: Text(
                isEditing ? 'Cập nhật' : 'Thêm',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
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

  // ==================== TOP BAR (reused from nhapdiem_screen) ====================
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
              'Xem, tìm kiếm và cập nhật thông tin các môn học trong chương trình đào tạo.',
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

  Widget _buildFiltersAndSearchSection() {
    return Container(
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
          Text(
            'Tìm kiếm và Lọc',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Nhập mã hoặc tên môn học...',
                    labelText: 'Tìm kiếm',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.search),
                    contentPadding: const EdgeInsets.symmetric(
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
              SizedBox(
                width: 200,
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Loại môn học',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 12,
                    ),
                  ),
                  value: _selectedSubjectType.isEmpty
                      ? null
                      : _selectedSubjectType,
                  items: const [
                    DropdownMenuItem(value: '', child: Text('Tất cả các loại')),
                    DropdownMenuItem(
                      value: 'mandatory',
                      child: Text('Bắt buộc'),
                    ),
                    DropdownMenuItem(value: 'elective', child: Text('Tự chọn')),
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
              ElevatedButton.icon(
                onPressed: _filterSubjects,
                icon: const Icon(Icons.filter_list),
                label: const Text('Lọc'),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _accentBlue, // Use accent blue for consistency
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
      ),
    );
  }

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
            'Danh sách môn học',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF9AD6FF),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Tổng: ${_filteredMonHocList.length} môn học',
              style: const TextStyle(fontSize: 12, color: Color(0xFF165E81)),
            ),
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
            textAlign: TextAlign.center,
          ),
        ),
        DataColumn(
          label: Text(
            'Loại môn',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
        DataColumn(
          label: Text(
            'Hành động',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ),
      ],
      rows: _filteredMonHocList.map((monHoc) => _buildDataRow(monHoc)).toList(),
    );
  }

  DataRow _buildDataRow(MonHoc monHoc) {
    String subjectType = (monHoc.soTinChi > 2)
        ? 'Bắt buộc'
        : 'Tự chọn'; // Example logic
    Color typeColor = (monHoc.soTinChi > 2)
        ? _errorRed
        : _accentBlue; // Example color
    Color bgColor = (monHoc.soTinChi > 2)
        ? const Color(0xFFFDEDEC)
        : const Color(0xFFEAF4FB); // Example color

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
            textAlign: TextAlign.center,
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.edit, size: 18, color: _primaryColor),
                onPressed: () => _editMonHoc(monHoc),
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(4),
              ),
              IconButton(
                icon: Icon(Icons.delete, size: 18, color: _errorRed),
                onPressed: () => _deleteMonHoc(monHoc),
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
    // Basic pagination, needs to be hooked up to actual pagination logic
    return Container(
      color: const Color(0xFFF7F9FF),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Hiển thị 1-${_filteredMonHocList.length} trên ${_filteredMonHocList.length} môn học',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          Row(
            children: [
              _buildPaginationButton(Icons.chevron_left, () {}),
              _buildPaginationPageButton('1', true),
              _buildPaginationButton(Icons.chevron_right, () {}),
            ],
          ),
        ],
      ),
    );
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
