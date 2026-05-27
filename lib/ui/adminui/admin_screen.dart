import 'package:flutter/material.dart';
import '../adminui/nhapmon_screen.dart'; 
import '../adminui/nhapdiem_screen.dart'; 
import '../login_screen.dart'; 

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  // Biến lưu trữ vị trí trang đang chọn (0: Nhập môn học, 1: Nhập điểm)
  int _selectedIndex = 0;

  // Bảng màu sắc đồng bộ hoàn toàn với nhapmon_screen và nhapdiem_screen
  final Color _primaryColor = const Color(0xFF006491);
  final Color _backgroundColor = const Color(0xFFF7F9FF);
  final Color _surfaceColor = const Color(0xFFFFFFFF);
  final Color _borderColor = const Color(0xFFD6EAF8);
  final Color _accentBlue = const Color(0xFF5DADE2);
  final Color _errorRed = const Color(0xFFC0392B); // Đã khai báo màu đỏ lỗi làm biến Instance hợp lệ

  // Danh sách các màn hình tương ứng với từng mục trên Sidebar
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const NhapMonScreen(), // Trang Nhập danh sách môn học (Index 0)
      const NhapDiemScreen(), // Trang Nhập điểm sinh viên (Index 1)
      const Center(child: Text('Báo cáo thống kê')), // Trang Báo cáo thống kê (Index 2 - giả định)
      const Center(child: Text('Cài đặt hệ thống')), // Trang Cài đặt hệ
      //const LoginScreen(), // Trang Đăng xuất (Index 4 - giả định)
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Row(
        children: [
          // ==================== SIDEBAR TRẮNG THEO MẪU ẢNH ====================
          Container(
            width: 280, // Độ rộng Sidebar chuẩn
            height: double.infinity,
            decoration: BoxDecoration(
              color: _surfaceColor, // Nền trắng sáng cao cấp
              border: Border(
                right: BorderSide(color: _borderColor, width: 1), // Đường kẻ phân cách phải mờ
              ),
            ),
            child: Column(
              children: [
                // 1. LOGO HEADER SIDEBAR
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  child: Row(
                    children: [
                      // Khối hộp xanh bo góc chứa icon trường học
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _accentBlue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.school, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 15),
                      // Chữ tiêu đề hệ thống
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'EduAdmin Pro',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              'Hệ thống quản lý',
                              style: TextStyle(fontSize: 13, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Divider(height: 1, thickness: 1, indent: 20, endIndent: 20),
                const SizedBox(height: 20),

                // 2. DANH SÁCH ĐIỀU HƯỚNG CHÍNH (BODY)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        _buildNavItem(
                          index: 0,
                          icon: Icons.menu_book_outlined,
                          label: 'Danh sách môn học',
                        ),
                        _buildNavItem(
                          index: 1,
                          icon: Icons.edit_note_outlined,
                          label: 'Nhập điểm',
                        ),
                        _buildNavItem(
                          index: 2, // Mục giả định thêm cho giống thiết kế ảnh mẫu
                          icon: Icons.assessment_outlined,
                          label: 'Báo cáo thống kê',
                        ),
                      ],
                    ),
                  ),
                ),

                // 3. PHẦN CHÂN TRANG (FOOTER)
                const Divider(height: 1, thickness: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Column(
                    children: [
                      _buildNavItem(
                        index: 3,
                        icon: Icons.settings_outlined,
                        label: 'Cài đặt hệ thống',
                        isFooter: true,
                      ),
                      _buildNavItem(
                        index: 4,
                        icon: Icons.logout,
                        label: 'Đăng xuất',
                        isFooter: true,
                        isError: true, // Đánh dấu đổi màu đỏ cảnh báo
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // ==================== NỘI DUNG MÀN HÌNH CHÍNH (BÊN PHẢI) ====================
          Expanded(
            child: Container(
              color: _backgroundColor,
              // IndexedStack giữ nguyên trạng thái dữ liệu khi chuyển tab qua lại mượt mà
              child: IndexedStack(
                index: _selectedIndex,
                children: _pages,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== WIDGET TAO ITEM MENU (NẰM TRONG LỚP STATE HỢP LỆ) ====================
  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    bool isFooter = false,
    bool isError = false,
  }) {
    // Xác định xem nút này có đang active hay không
    final bool isActive = _selectedIndex == index;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          if (isError) {
            // Xử lý sự kiện khi nhấn Đăng xuất tại đây
            return;
          }
          // Chỉ chuyển trang cho các tab có view thực tế (0 và 1)
          if (index < 2) {
            setState(() {
              _selectedIndex = index;
            });
          }
        },
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            // Màu nền: Nếu đang Active thì hiển thị màu xanh nhạt sáng bóng, không thì trong suốt
            color: isActive ? const Color(0xFF9AD6FF).withOpacity(0.4) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 24,
                // Ưu tiên màu đỏ nếu lỗi, màu xanh đậm nếu active, còn lại màu xám
                color: isError 
                    ? _errorRed 
                    : (isActive ? _primaryColor : Colors.grey[600]),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    color: isError 
                        ? _errorRed 
                        : (isActive ? _primaryColor : Colors.black54),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
