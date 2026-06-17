import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'package:app_hoctap/models/hoc_ki.dart';
import 'package:app_hoctap/models/lop.dart';

class StudentDialogs {
  /// Dialog thêm sinh viên mới với chọn lớp và học kỳ
  static Future<Map<String, String>?> showAddStudentDialog(
    BuildContext context, {
    required List<Lop> danhSachLop,
    required List<HocKy> danhSachHocKy,
  }) async {
    final mssvController = TextEditingController();
    final tenController = TextEditingController();
    
    // Kiểm tra dữ liệu từ Firebase trước khi mở Dialog
    if (danhSachLop.isEmpty || danhSachHocKy.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng cấu hình dữ liệu Lớp và Học kỳ trên Firebase trước!')),
      );
      return null;
    }

    // Thiết lập giá trị mặc định ban đầu ban đầu (Dùng kiểu String cho cả hai Dropdown để đồng bộ)
    String initialLopId = danhSachLop.first.id;
    String initialHocKyValue = danhSachHocKy.first.value.toString();

    return showDialog<Map<String, String>?>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, dialogSetState) {
          return AlertDialog(
            title: const Text('Thêm sinh viên mới'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. Ô nhập MSSV
                  TextField(
                    controller: mssvController,
                    decoration: const InputDecoration(
                      labelText: 'MSSV',
                      hintText: 'Nhập MSSV',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // 2. Ô nhập Tên
                  TextField(
                    controller: tenController,
                    decoration: const InputDecoration(
                      labelText: 'Tên sinh viên',
                      hintText: 'Nhập tên sinh viên',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // 3. Dropdown Chọn Lớp
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Chọn lớp',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
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
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            value: initialLopId, // Sử dụng biến đã đồng bộ trạng thái
                            items: danhSachLop
                                .map(
                                  (lop) => DropdownMenuItem<String>(
                                    value: lop.id,
                                    child: Text(lop.tenLop),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                // Sử dụng hàm setstate của StatefulBuilder để ép cập nhật giao diện Dialog
                                dialogSetState(() => initialLopId = value);
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 4. Dropdown Chọn Học Kỳ
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Học kỳ hiện tại của sinh viên',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
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
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            value: initialHocKyValue, // Chắc chắn là một chuỗi String trùng khớp với item value
                            items: danhSachHocKy
                                .map(
                                  (hk) => DropdownMenuItem<String>(
                                    value: hk.value.toString(), // Chuyển int từ model thành String tương ứng
                                    child: Text(hk.tenHocKy),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                dialogSetState(() => initialHocKyValue = value);
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              // Nút Hủy
              TextButton(
                onPressed: () => Navigator.pop(context, null),
                child: const Text('Hủy'),
              ),
              // Nút Thêm
              ElevatedButton(
                onPressed: () {
                  if (mssvController.text.trim().isEmpty || tenController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')),
                    );
                    return;
                  }

                  // Tìm object lớp tương ứng dựa trên ID đang được chọn
                  final lopDuocChon = danhSachLop.firstWhere((e) => e.id == initialLopId);

                  Navigator.pop(
                    context,
                    {
                      'mssv': mssvController.text.trim(),
                      'ten': tenController.text.trim(),
                      'lop': lopDuocChon.tenLop,      
                      'hocKySinhVien': initialHocKyValue, 
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentBlue,
                ),
                child: const Text('Thêm', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    ).then((result) {
      // Dọn dẹp bộ nhớ tập trung tại đây khi dialog đóng hẳn
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
            onPressed: () => Navigator.pop(context, null),
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
            color: color.withAlpha(51), // Thay thế hàm .withValues cũ bị lỗi trên một số phiên bản Flutter
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

  /// Dialog thêm lớp học mới
  static Future<Map<String, String>?> showAddLopDialog(BuildContext context) async {
    final idController = TextEditingController();
    final lopController = TextEditingController();

    return showDialog<Map<String, String>?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm lớp học mới'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: idController,
              decoration: const InputDecoration(
                labelText: 'ID lớp (ví dụ: LOP01, LOP02)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: lopController,
              decoration: const InputDecoration(
                labelText: 'Tên lớp hiển thị',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              if (idController.text.trim().isEmpty || lopController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin!')),
                );
                return;
              }
              Navigator.pop(context, {
                'ID': idController.text.trim(),
                'tenlop': lopController.text.trim(),
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentBlue,
            ),
            child: const Text('Thêm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ).then((result) {
      idController.dispose();
      lopController.dispose();
      return result;
    });
  }

  /// Hộp thoại thêm Học Kỳ mới lên hệ thống
  static Future<Map<String, dynamic>?> showAddHocKyDialog(BuildContext context) async {
    final idHkController = TextEditingController();
    final tenHkController = TextEditingController();
    final valueHkController = TextEditingController();

    return showDialog<Map<String, dynamic>?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm học kỳ mới'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: idHkController,
              decoration: const InputDecoration(
                labelText: 'ID học kỳ (ví dụ: HK01, HK02)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: tenHkController,
              decoration: const InputDecoration(
                labelText: 'Tên học kỳ hiển thị',
                hintText: 'Ví dụ: Học kỳ 1, Học kỳ Hè...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: valueHkController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Giá trị số (để sắp xếp)',
                hintText: 'Ví dụ: 1, 2, 3...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              final intValue = int.tryParse(valueHkController.text.trim());
              if (tenHkController.text.trim().isEmpty || valueHkController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin!')),
                );
                return;
              }
              if (intValue == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Giá trị số phải là số nguyên hợp lệ!')),
                );
                return;
              }

              Navigator.pop(context, {
                'ID': idHkController.text.trim(),
                'tenHocKy': tenHkController.text.trim(),
                'value': intValue,
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentBlue),
            child: const Text('Thêm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ).then((value) {
      idHkController.dispose();
      tenHkController.dispose();
      valueHkController.dispose();
      return value;
    });
  }
}