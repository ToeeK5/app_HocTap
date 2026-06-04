import 'package:flutter/material.dart';
import '../../services/init_data_service.dart';
import 'widgets_admin/app_colors.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final _initDataService = InitDataService();
  bool _isLoading = false;
  String _message = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quản Lý Dữ Liệu',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            // Card khởi tạo dữ liệu
            _buildDataCard(
              title: 'Khởi Tạo Dữ Liệu Sinh Viên',
              description:
                  'Tạo 17 sinh viên mẫu từ 4 lớp (CNTT1, CNTT2, CNTT3, CNTT4)',
              buttonText: 'Khởi Tạo',
              onPressed: _initializeData,
              icon: Icons.person_add,
              color: AppColors.accentBlue,
            ),
            const SizedBox(height: 16),
            // Card xóa dữ liệu
            _buildDataCard(
              title: 'Xóa Tất Cả Dữ Liệu',
              description: 'Xóa tất cả sinh viên và điểm từ Firestore (dùng cho testing)',
              buttonText: 'Xóa Dữ Liệu',
              onPressed: _clearData,
              icon: Icons.delete,
              color: AppColors.errorRed,
            ),
            const SizedBox(height: 32),
            // Message
            if (_message.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _message.contains('thành công')
                      ? AppColors.successGreen.withOpacity(0.2)
                      : AppColors.errorRed.withOpacity(0.2),
                  border: Border.all(
                    color: _message.contains('thành công')
                        ? AppColors.successGreen
                        : AppColors.errorRed,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _message,
                  style: TextStyle(
                    color: _message.contains('thành công')
                        ? AppColors.successGreen
                        : AppColors.errorRed,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataCard({
    required String title,
    required String description,
    required String buttonText,
    required VoidCallback onPressed,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        border: Border.all(color: AppColors.borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                disabledBackgroundColor: Colors.grey[400],
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      buttonText,
                      style: const TextStyle(color: Colors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _initializeData() async {
    try {
      setState(() {
        _isLoading = true;
        _message = '';
      });

      bool isInitialized = await _initDataService.isDataInitialized();
      
      if (isInitialized) {
        setState(() {
          _message = 'ℹ️ Dữ liệu sinh viên đã tồn tại trong Firestore!';
          _isLoading = false;
        });
      } else {
        bool success = await _initDataService.initializeSinhVienData();

        setState(() {
          _message = success
              ? '✅ Khởi tạo 17 sinh viên thành công! Kiểm tra Firestore để xem dữ liệu.'
              : '❌ Khởi tạo thất bại. Vui lòng kiểm tra lại.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _message = '❌ Lỗi: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _clearData() async {
    // Hiển thị dialog xác nhận
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác Nhận Xóa'),
        content: const Text(
          'Bạn có chắc chắn muốn xóa TẤT CẢ dữ liệu sinh viên và điểm?\n\nHành động này không thể hoàn tác!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Xóa',
              style: TextStyle(color: AppColors.errorRed),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      setState(() {
        _isLoading = true;
        _message = '';
      });

      bool success = await _initDataService.clearAllData();

      setState(() {
        _message = success
            ? '✅ Xóa tất cả dữ liệu thành công!'
            : '❌ Xóa thất bại. Vui lòng kiểm tra lại.';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _message = '❌ Lỗi: $e';
        _isLoading = false;
      });
    }
  }
}
