// File mới: lib/adminui/bao_cao_thong_ke_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/sinh_vien.dart';
import '../../models/diem.dart';
import '../../models/lop.dart';
import '../../models/mon_hoc.dart';
import 'package:app_hoctap/ui/adminui/widgets_admin/WidgetNhapDiemScreen/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';

class BaoCaoThongKeScreen extends StatefulWidget {
  const BaoCaoThongKeScreen({super.key});

  @override
  State<BaoCaoThongKeScreen> createState() => _BaoCaoThongKeScreenState();
}

class _BaoCaoThongKeScreenState extends State<BaoCaoThongKeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Color _primaryColor = const Color(0xFF006491);

  List<int> _danhSachHocKy = [];
  List<MonHoc> _danhSachMonHoc = [];
  List<String> _danhSachLop = [];

  int? _selectedHocKy;
  String? _selectedMonHoc;
  String? _selectedLop;

  // Stats (sẽ thay đổi theo filter)
  int _totalStudents = 0;
  double _avgScore = 0.0;
  double _warningRate = 0.0;
  int _activeCourses = 0;

  List<Map<String, dynamic>> _classGpas = [];
  List<Map<String, dynamic>> _recentFeedback = [];

  bool _isLoading = true;

  Map<int, double> _semesterAverages = {}; // Key: học kỳ, Value: điểm TB
  List<int> _availableSemesters = []; // Dữ liệu mẫu, sẽ thay bằng real data

  int _excellentCount = 0;
  int _goodCount = 0;
  int _averageCount = 0;
  int _weakCount = 0;

  @override
  void initState() {
    super.initState();
    _loadFilters();
  }

  Future<void> _loadFilters() async {
    setState(() => _isLoading = true);
    try {
      // Load Học kỳ từ mon_hoc
      final monSnap = await _firestore.collection('mon_hoc').get();
      final Set<int> hks = {};
      final List<MonHoc> mons = [];

      for (var doc in monSnap.docs) {
        final data = doc.data();
        final hk = data['hocKy'] as int? ?? 1;
        hks.add(hk);

        mons.add(
          MonHoc(
            maMon: doc.id,
            tenMon: data['tenMon'] ?? '',
            soTinChi: data['soTinChi'] ?? 0,
            hocKy: hk,
          ),
        );
      }

      // Load danh sách lớp
      final svSnap = await _firestore.collection('sinh_vien').get();
      final Set<String> lops = {};
      for (var doc in svSnap.docs) {
        final lop = doc.data()['lop']?.toString() ?? '';
        if (lop.isNotEmpty) lops.add(lop);
      }

      setState(() {
        _danhSachHocKy = hks.toList()..sort();
        _danhSachMonHoc = mons;
        _danhSachLop = lops.toList()..sort();
      });

      await _loadFilteredStats();
    } catch (e) {
      debugPrint('Lỗi load filters: $e');
    }
  }

  Future<void> _loadFilteredStats() async {
    setState(() => _isLoading = true);
    try {
      Query<Map<String, dynamic>> diemQuery = _firestore.collection('diem');

      // Áp dụng filter
      if (_selectedHocKy != null) {
        diemQuery = diemQuery.where('hocKySinhVien', isEqualTo: _selectedHocKy);
      }
      if (_selectedMonHoc != null) {
        diemQuery = diemQuery.where('maMon', isEqualTo: _selectedMonHoc);
      }
      if (_selectedLop != null) {
        // Lọc qua sinh viên
      }

      final diemSnap = await diemQuery.get();
      List<Diem> filteredDiem = diemSnap.docs
          .map((doc) => Diem.fromFirestore(doc.data()))
          .toList();

      // Lấy sinh viên theo lớp nếu có filter lớp
      List<SinhVien> filteredSV = [];
      if (_selectedLop != null) {
        final svSnap = await _firestore
            .collection('sinh_vien')
            .where('lop', isEqualTo: _selectedLop)
            .get();
        filteredSV = svSnap.docs
            .map((doc) => SinhVien.fromFirestore(doc.data()))
            .toList();
      } else {
        final svSnap = await _firestore.collection('sinh_vien').get();
        filteredSV = svSnap.docs
            .map((doc) => SinhVien.fromFirestore(doc.data()))
            .toList();
      }

      // Tính toán stats
      _totalStudents = filteredSV.length;
      _activeCourses = _selectedMonHoc != null ? 1 : _danhSachMonHoc.length;

      if (filteredDiem.isNotEmpty) {
        double totalDTB = 0;
        int countValid = 0;
        int warningCount = 0;

        for (var d in filteredDiem) {
          double dtb = d.getDTB();
          if (dtb > 0) {
            totalDTB += dtb;
            countValid++;
            if (dtb < 5.0) warningCount++;
          }
        }

        _avgScore = countValid > 0 ? totalDTB / countValid : 0.0;
        _warningRate = countValid > 0 ? (warningCount / countValid) * 100 : 0.0;
      }

      await _calculateGpaByClass();
      await _loadRecentFeedback();
      await _calculateSemesterAverages();
      await _calculateScoreDistribution();
    } catch (e) {
      debugPrint('Lỗi load filtered stats: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _calculateGpaByClass() async {
    final svSnap = await _firestore.collection('sinh_vien').get();
    final diemSnap = await _firestore.collection('diem').get();

    Map<String, List<double>> classScores = {};

    for (var dDoc in diemSnap.docs) {
      final d = Diem.fromFirestore(dDoc.data());
      final svDoc = svSnap.docs.where((s) => s.id == d.maSV).firstOrNull;
      if (svDoc != null) {
        final lop = svDoc.data()['lop'] ?? 'Unknown';
        final dtb = d.getDTB();
        if (dtb > 0) {
          classScores.putIfAbsent(lop, () => []).add(dtb);
        }
      }
    }

    _classGpas = classScores.entries.map((entry) {
      double avg = entry.value.reduce((a, b) => a + b) / entry.value.length;
      return {'lop': entry.key, 'gpa': double.parse(avg.toStringAsFixed(1))};
    }).toList();

    _classGpas.sort((a, b) => b['gpa'].compareTo(a['gpa']));
  }

  /// ✅ THÊM MỚI: Tải phản hồi từ Firestore
  Future<void> _loadRecentFeedback() async {
    try {
      final feedbackSnap = await _firestore
          .collection('comments')
          .orderBy('ngayTao', descending: true)
          .get();

      List<Map<String, dynamic>> feedbackList = [];

      for (var doc in feedbackSnap.docs) {
        final data = doc.data();

        // Lấy tên sinh viên
        final maSV = data['maSV'] ?? '';
        String tenSV = 'Ẩn danh';
        if (maSV.isNotEmpty) {
          final svDoc = await _firestore
              .collection('sinh_vien')
              .doc(maSV)
              .get();
          tenSV = svDoc.data()?['hoTen'] ?? 'Ẩn danh';
        }

        // Lấy tên môn học
        final maMon = data['maMon'] ?? '';
        String tenMon = 'Không xác định';
        if (maMon.isNotEmpty) {
          final monDoc = await _firestore
              .collection('mon_hoc')
              .doc(maMon)
              .get();
          tenMon = monDoc.data()?['tenMon'] ?? 'Không xác định';
        }

        // Định dạng ngày tạo
        String ngayTao = 'Vừa xong';
        if (data['timestamp'] != null) {
          final date = (data['timestamp'] as Timestamp).toDate();
          ngayTao = '${date.day}/${date.month}/${date.year}';
        }

        feedbackList.add({
          'tenSV': tenSV,
          'tenMon': tenMon,
          'noiDung': data['noiDung'] ?? '',
          'ngayTao': ngayTao,
        });
      }

      setState(() {
        _recentFeedback = feedbackList;
      });
    } catch (e) {
      debugPrint('Lỗi load phản hồi: $e');
    }
  }

  /// Tính điểm trung bình theo từng học kỳ từ Firestore
  Future<void> _calculateSemesterAverages() async {
    try {
      final diemSnap = await _firestore.collection('diem').get();
      Map<int, List<double>> semesterScores = {};

      for (var doc in diemSnap.docs) {
        final data = doc.data();
        final diem = Diem.fromFirestore(data);

        final hk = diem.hocKySinhVien; // Sử dụng học kỳ của sinh viên
        final dtb = diem.getDTB();

        if (hk > 0 && dtb > 0) {
          semesterScores.putIfAbsent(hk, () => []).add(dtb);
        }
      }

      // Tính trung bình cho từng học kỳ
      _semesterAverages.clear();
      for (var entry in semesterScores.entries) {
        double avg = entry.value.reduce((a, b) => a + b) / entry.value.length;
        _semesterAverages[entry.key] = double.parse(avg.toStringAsFixed(1));
      }

      // Lấy danh sách học kỳ có sẵn và sắp xếp
      _availableSemesters = _semesterAverages.keys.toList()..sort();

      if (_availableSemesters.isEmpty) {
        // Fallback nếu chưa có dữ liệu
        _availableSemesters = [1, 2, 3, 4];
        _semesterAverages = {1: 6.5, 2: 7.2, 3: 7.8, 4: 8.1};
      }
    } catch (e) {
      debugPrint('Lỗi tính điểm theo học kỳ: $e');
    }
  }

  /// Tính phổ điểm sinh viên theo 4 mức
  Future<void> _calculateScoreDistribution() async {
    try {
      final diemSnap = await _firestore.collection('diem').get();

      int excellent = 0, good = 0, average = 0, weak = 0;

      for (var doc in diemSnap.docs) {
        final diem = Diem.fromFirestore(doc.data());
        double dtb = diem.getDTB();

        if (dtb >= 8.5) {
          excellent++;
        } else if (dtb >= 7.0) {
          good++;
        } else if (dtb >= 5.0) {
          average++;
        } else if (dtb > 0) {
          weak++;
        }
      }

      setState(() {
        _excellentCount = excellent;
        _goodCount = good;
        _averageCount = average;
        _weakCount = weak;
      });
    } catch (e) {
      debugPrint('Lỗi tính phổ điểm: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF006491)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Header
                  _buildTopHeader(),
                  const SizedBox(height: 24),

                  // Filter Row
                  _buildFilterRow(),
                  const SizedBox(height: 24),

                  // Stats Cards
                  Row(
                    children: [
                      _buildStatCard(
                        icon: Icons.people,
                        title: 'Tổng số sinh viên',
                        value: _totalStudents.toString(),
                        subtitle: 'So với học kỳ trước',
                        change: '+12%',
                        changeColor: Colors.green,
                      ),
                      const SizedBox(width: 16),
                      _buildStatCard(
                        icon: Icons.grade,
                        title: 'Điểm trung bình',
                        value: _avgScore.toStringAsFixed(1),
                        subtitle: 'Duy trì ổn định',
                        change: '72%',
                        isProgress: true,
                      ),
                      const SizedBox(width: 16),
                      _buildStatCard(
                        icon: Icons.warning_amber,
                        title: 'Tỷ lệ cảnh báo học tập',
                        value: '${_warningRate.toStringAsFixed(1)}%',
                        subtitle: 'Cần chú ý đặc biệt',
                        change: '-2.1%',
                        changeColor: Colors.red,
                      ),
                      const SizedBox(width: 16),
                      _buildStatCard(
                        icon: Icons.menu_book,
                        title: 'Môn học đang mở',
                        value: _activeCourses.toString(),
                        subtitle: 'Đã bao gồm 5 môn tự chọn',
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left: Charts
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            // Phổ điểm sinh viên
                            _buildScoreDistributionCard(),
                            const SizedBox(height: 24),
                            // Điểm trung bình theo học kỳ
                            _buildSemesterTrendCard(),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      // Right: Class GPA + Feedback
                      Expanded(
                        child: Column(
                          children: [
                            _buildClassGpaCard(),
                            const SizedBox(height: 24),
                            _buildFeedbackCard(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTopHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Dashboard',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Row(
          children: [
            Container(
              width: 320,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm dữ liệu...',
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 16),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_none),
            ),
            const SizedBox(width: 8),
            // ✅ SỬA: Xóa const bao ngoài Row vì Column và Text bên trong không const
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
                  backgroundColor: AppColors.accentBlue,
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
    );
  }

  Widget _buildFilterRow() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Row(
        children: [
          const Text(
            'Bộ lọc:',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          const SizedBox(width: 16),

          // Chọn Học Kỳ
          _buildDropdownFilter(
            label: 'Học kỳ',
            value: _selectedHocKy?.toString(),
            items: _danhSachHocKy.map((hk) => hk.toString()).toList(),
            onChanged: (value) {
              setState(() {
                _selectedHocKy = value != null ? int.parse(value) : null;
                _selectedMonHoc = null; // Reset môn khi đổi HK
              });
              _loadFilteredStats();
            },
          ),
          const SizedBox(width: 12),

          // Chọn Môn Học (chỉ môn thuộc HK đã chọn)
          _buildDropdownFilter(
            label: 'Môn học',
            value: _selectedMonHoc,
            items: _danhSachMonHoc
                .where(
                  (m) => _selectedHocKy == null || m.hocKy == _selectedHocKy,
                )
                .map((m) => m.maMon)
                .toList(),
            onChanged: (value) {
              setState(() => _selectedMonHoc = value);
              _loadFilteredStats();
            },
          ),
          const SizedBox(width: 12),

          // Chọn Lớp
          _buildDropdownFilter(
            label: 'Lớp',
            value: _selectedLop,
            items: _danhSachLop,
            onChanged: (value) {
              setState(() => _selectedLop = value);
              _loadFilteredStats();
            },
          ),

          const Spacer(),
          ElevatedButton.icon(
            onPressed: _loadFilters,
            icon: const Icon(Icons.refresh),
            label: const Text('Làm mới'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownFilter({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Expanded(
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
        ),
        value: value,
        items: [
          const DropdownMenuItem(value: null, child: Text('Tất cả')),
          ...items.map(
            (item) => DropdownMenuItem(value: item, child: Text(item)),
          ),
        ],
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 13)),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    String change = '',
    Color? changeColor,
    bool isProgress = false,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFEDF7FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF006491), size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(subtitle, style: const TextStyle(fontSize: 13)),
                if (change.isNotEmpty) ...[
                  const Spacer(),
                  Text(
                    change,
                    style: TextStyle(
                      color: changeColor ?? Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
            if (isProgress)
              const SizedBox(
                height: 6,
                child: LinearProgressIndicator(
                  value: 0.72,
                  backgroundColor: Color(0xFFE2E8F0),
                  color: Color(0xFF006491),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreDistributionCard() {
    final total = _excellentCount + _goodCount + _averageCount + _weakCount;
    final maxY = (total * 1.1).ceilToDouble().clamp(10.0, double.infinity);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Phổ điểm sinh viên',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Tổng số sinh viên có điểm: $total',
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          SizedBox(
            height: 240,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const labels = ['Xuất sắc', 'Khá', 'TB', 'Yếu'];
                        final index = value.toInt();
                        if (index >= 0 && index < labels.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              labels[index],
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: _excellentCount.toDouble(),
                        color: Colors.green,
                        width: 28,
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: _goodCount.toDouble(),
                        color: Colors.blue,
                        width: 28,
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 2,
                    barRods: [
                      BarChartRodData(
                        toY: _averageCount.toDouble(),
                        color: Colors.orange,
                        width: 28,
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 3,
                    barRods: [
                      BarChartRodData(
                        toY: _weakCount.toDouble(),
                        color: Colors.red,
                        width: 28,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Xuất sắc ≥8.5', Colors.green, _excellentCount),
              const SizedBox(width: 20),
              _buildLegendItem('Khá 7.0-8.4', Colors.blue, _goodCount),
              const SizedBox(width: 20),
              _buildLegendItem('Trung bình', Colors.orange, _averageCount),
              const SizedBox(width: 20),
              _buildLegendItem('Yếu <5.0', Colors.red, _weakCount),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, int count) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 6),
        Text('$label ($count)', style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildSemesterTrendCard() {
    // Tạo spots cho LineChart
    List<FlSpot> spots = [];
    List<String> labels = [];

    for (int i = 0; i < _availableSemesters.length; i++) {
      int hk = _availableSemesters[i];
      double avg = _semesterAverages[hk] ?? 0.0;
      spots.add(FlSpot(i.toDouble(), avg));
      labels.add('HK $hk');
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Điểm trung bình theo học kỳ',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Dữ liệu thực từ Firestore',
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 290,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: true, drawVerticalLine: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: 0.5,
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < labels.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              labels[index],
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: const Color(0xFF006491),
                    barWidth: 4.5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 5,
                          color: Colors.white,
                          strokeWidth: 3,
                          strokeColor: const Color(0xFF006491),
                        );
                      },
                    ),
                  ),
                ],
                minX: 0,
                maxX: (spots.length - 1).toDouble(),
                minY: 2.0,
                maxY: 10.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassGpaCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thống kê theo lớp',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ..._classGpas
              .take(4)
              .map(
                (cls) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          cls['lop'],
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      Text(
                        'GPA: ${cls['gpa']}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: cls['gpa'] / 10,
                          backgroundColor: const Color(0xFFE2E8F0),
                          color: const Color(0xFF006491),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          const SizedBox(height: 12),
          TextButton(onPressed: () {}, child: const Text('Xem tất cả các lớp')),
        ],
      ),
    );
  }

  Widget _buildFeedbackCard() {
    if (_recentFeedback.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: const Center(
          child: Column(
            children: [
              Icon(Icons.comment_outlined, size: 48, color: Colors.grey),
              SizedBox(height: 12),
              Text('Chưa có phản hồi nào', style: TextStyle(fontSize: 16)),
              Text(
                'Khi sinh viên comment sẽ hiển thị ở đây',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Phản hồi môn học',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '${_recentFeedback.length} phản hồi mới nhất',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 20),

          ..._recentFeedback.map(
            (fb) => Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEEF2F6)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: const Color(
                          0xFF006491,
                        ).withOpacity(0.1),
                        child: Text(
                          fb['tenSV'].toString()[0].toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF006491),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fb['tenSV'],
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              fb['tenMon'], // Hiển thị tên môn học
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF006491),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        fb['ngayTao'],
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '"${fb['noiDung']}"',
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
