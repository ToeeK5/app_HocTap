import 'package:flutter/material.dart';
import 'app_colors.dart';

class StudentDialogs {
  /// Dialog thêm sinh viên mới với chọn lớp
  static Future<Map<String, String>?> showAddStudentDialog(
    BuildContext context, {
    List<String> danhSachLop = const ['CNTT1', 'CNTT2', 'CNTT3', 'CNTT4'],
  }) async {
    final mssvController = TextEditingController();
    final tenController = TextEditingController();
    String selectedLop = danhSachLop.isNotEmpty ? danhSachLop.first : 'CNTT1';

    return showDialog<Map<String, String>?>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
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
              const SizedBox(height: 16),
              // Chọn lớp
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Chọn lớp',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.borderColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        value: selectedLop,
                        items: danhSachLop
                            .map(
                              (lop) => DropdownMenuItem<String>(
                                value: lop,
                                child: Text(lop),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => selectedLop = value);
                          }
                        },
                      ),
                    ),
                  ),
                ],
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

                Navigator.pop(
                  context,
                  {
                    'mssv': mssvController.text,
                    'ten': tenController.text,
                    'lop': selectedLop,
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentBlue,
              ),
              child: const Text('Thêm', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    ).then((result) {
      mssvController.dispose();
      tenController.dispose();
      return result;
    });
  }

  /// Dialog chỉnh sửa thông tin sinh viên (không chỉnh lớp)
  static Future<Map<String, String>?> showEditStudentDialog(
    BuildContext context,
    String currentMssv,
    String currentName,
  ) async {
    final mssvController = TextEditingController(text: currentMssv);
    final tenController = TextEditingController(text: currentName);

    return showDialog<Map<String, String>?>(
      context: context,
      builder: (context) => AlertDialog(
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
              Navigator.pop(
                context,
                {
                  'mssv': mssvController.text,
                  'ten': tenController.text,
                },
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentBlue,
            ),
            child: const Text('Cập nhật', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ).then((result) {
      mssvController.dispose();
      tenController.dispose();
      return result;
    });
  }

  /// Dialog xác nhận xóa sinh viên
  static Future<bool?> showDeleteConfirmDialog(BuildContext context) {
    return showDialog<bool?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa sinh viên này?'),
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
  }

  /// Dialog hiển thị kết quả import sinh viên
  static void showImportResultDialog(
    BuildContext context,
    Map<String, dynamic> result,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kết quả nhập dữ liệu'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildResultRow('Thành công', '${result['success']}', AppColors.successGreen),
              const SizedBox(height: 8),
              _buildResultRow('Thất bại', '${result['failed']}', AppColors.errorRed),
              const SizedBox(height: 8),
              _buildResultRow('Tổng cộng', '${result['total']}', AppColors.primaryColor),
              if ((result['errors'] as List).isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Lỗi:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...((result['errors'] as List).cast<String>().take(5).map(
                  (error) => Text(
                    '• $error',
                    style: const TextStyle(fontSize: 12),
                  ),
                )),
              ],
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentBlue,
            ),
            child: const Text(
              'Đóng',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildResultRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
