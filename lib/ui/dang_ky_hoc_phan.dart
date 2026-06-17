import 'package:flutter/material.dart';
import '../utils/theme_app.dart';
import '../services/dang_ky_service.dart';
import '../services/session_service.dart';

class DangKyHocPhanScreen extends StatefulWidget {
  final int hocKy;

  const DangKyHocPhanScreen({super.key, required this.hocKy});

  @override
  State<DangKyHocPhanScreen> createState() => _DangKyHocPhanScreenState();
}

class _DangKyHocPhanScreenState extends State<DangKyHocPhanScreen> {
  final DangKyService _service = DangKyService();
  late Future<void> _loadFuture;

  List<Map<String, dynamic>> _danhSachMon = [];
  Set<String> _daDangKy = {};
  List<Map<String, dynamic>> _lichDangKy = [];
  int _tongTinDangKy = 0;

  @override
  void initState() {
    super.initState();
    _loadFuture = _loadData();
  }

  Future<void> _loadData() async {
    final maSV = SessionService.layMaSV();
    _danhSachMon = await _service.layTatCaMonHoc();
    // lọc theo học kỳ (chỉ giữ môn có trường hocKy == widget.hocKy)
    _danhSachMon = _danhSachMon.where((m) {
      final hk = m['hocKy'];
      if (hk is int) return hk == widget.hocKy;
      if (hk is String) return int.tryParse(hk) == widget.hocKy;
      return false;
    }).toList();
    final da = await _service.layMonDaDangKy(maSV, widget.hocKy);
    _daDangKy = da.toSet();
    _lichDangKy = await _service.layLichCuaDangKy(maSV, widget.hocKy);

    // tính tổng tín của các môn đã đăng ký
    _tongTinDangKy = 0;
    for (final mon in _danhSachMon) {
      final maMon = mon['maMon'] ?? mon['id'] ?? '';
      if (_daDangKy.contains(maMon)) {
        _tongTinDangKy += (mon['soTinChi'] is int)
            ? mon['soTinChi'] as int
            : int.tryParse('${mon['soTinChi']}') ?? 0;
      }
    }
  }

  Future<void> _toggleDangKy(String maMon) async {
    final maSV = SessionService.layMaSV();
    if (_daDangKy.contains(maMon)) {
      // confirm dialog trước khi hủy
      final confirm = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Xác nhận'),
          content: const Text('Bạn có chắc muốn hủy đăng ký môn này?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Không'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Có'),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      await _service.huyDangKyMon(maSV, maMon);
      _daDangKy.remove(maMon);
      // cập nhật tổng tín
      final mon = _danhSachMon.firstWhere(
        (m) => (m['maMon'] ?? m['id']) == maMon,
        orElse: () => {},
      );
      final tin = (mon['soTinChi'] is int)
          ? mon['soTinChi'] as int
          : int.tryParse('${mon['soTinChi']}') ?? 0;
      _tongTinDangKy -= tin;
    } else {
      // kiểm tra không duplicate (đã có trong set) - đã kiểm bằng contains

      // tìm thông tin môn
      final mon = _danhSachMon.firstWhere(
        (m) => (m['maMon'] ?? m['id']) == maMon,
        orElse: () => {},
      );
      final tin = (mon['soTinChi'] is int)
          ? mon['soTinChi'] as int
          : int.tryParse('${mon['soTinChi']}') ?? 0;

      // kiểm tra giới hạn tín chỉ tối đa 25
      if (_tongTinDangKy + tin > 25) {
        await showDialog<void>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Không thể đăng ký'),
            content: const Text('Tổng tín chỉ vượt quá 25. Vui lòng chọn lại.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }

      // kiểm tra trùng lịch: lấy lịch của môn cần đăng ký và so sánh với lịch các môn đã đăng ký
      final lichMoi = await _service.layLichTheoMaMon([maMon]);
      final maMonDaDangKy = _daDangKy.toList();
      final lichDaCo = await _service.layLichTheoMaMon(maMonDaDangKy);

      bool trungLich = false;
      String ghiChuTrung = '';

      int timeToMinutes(String t) {
        final parts = t.split(':');
        final h = int.tryParse(parts[0]) ?? 0;
        final m = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
        return h * 60 + m;
      }

      // hàm kiểm tra overlap thời gian dạng 'HH:MM'
      bool overlap(String aStart, String aEnd, String bStart, String bEnd) {
        try {
          final as = timeToMinutes(aStart);
          final ae = timeToMinutes(aEnd);
          final bs = timeToMinutes(bStart);
          final be = timeToMinutes(bEnd);
          return as < be && bs < ae;
        } catch (e) {
          return false;
        }
      }

      for (final lm in lichMoi) {
        for (final ld in lichDaCo) {
          final thu1 = lm['thu'] ?? '';
          final thu2 = ld['thu'] ?? '';
          if (thu1 == thu2) {
            final aStart = lm['gioBatDau'] ?? '';
            final aEnd = lm['gioKetThuc'] ?? '';
            final bStart = ld['gioBatDau'] ?? '';
            final bEnd = ld['gioKetThuc'] ?? '';
            if (overlap(aStart, aEnd, bStart, bEnd)) {
              trungLich = true;
              ghiChuTrung = 'Trùng lịch với môn ${ld['maMon'] ?? ''}';
              break;
            }
          }
        }
        if (trungLich) break;
      }

      if (trungLich) {
        if (!mounted) return;
        await showDialog<void>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Trùng lịch'),
            content: Text('Không thể đăng ký vì $ghiChuTrung'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }

      // đăng ký
      await _service.dangKyMon(maSV, maMon, widget.hocKy);
      _daDangKy.add(maMon);
      _tongTinDangKy += tin;
      // cảnh báo nếu < 12 tín chỉ (không chặn)
      if (_tongTinDangKy < 12) {
        if (!mounted) return;
        await showDialog<void>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Cảnh báo'),
            content: Text(
              'Tổng tín chỉ hiện tại $_tongTinDangKy < 12. Bạn nên cân nhắc.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }

    // reload lich
    _lichDangKy = await _service.layLichCuaDangKy(maSV, widget.hocKy);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Đăng ký học phần - Học kỳ ${widget.hocKy}'),
        backgroundColor: ThemeApp.mauChinh,
      ),
      body: FutureBuilder<void>(
        future: _loadFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _danhSachMon.length,
                  itemBuilder: (context, index) {
                    final mon = _danhSachMon[index];
                    final maMon = mon['maMon'] ?? mon['id'] ?? '';
                    final tenMon = mon['tenMon'] ?? '';
                    final soTin = mon['soTinChi']?.toString() ?? '';

                    return Card(
                      child: ListTile(
                        title: Text(tenMon),
                        subtitle: Text('$maMon - $soTin tín chỉ'),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _daDangKy.contains(maMon)
                                ? Colors.redAccent
                                : ThemeApp.mauChinh,
                          ),
                          onPressed: () => _toggleDangKy(maMon),
                          child: Text(
                            _daDangKy.contains(maMon) ? 'Hủy' : 'Đăng ký',
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: ThemeApp.mauVien)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Số môn đã đăng ký: ${_daDangKy.length}'),
                    const SizedBox(height: 6),
                    Text('Tổng tín chỉ đã đăng ký: $_tongTinDangKy'),
                    const SizedBox(height: 8),
                    Text('Lịch học của các môn đã đăng ký:'),
                    const SizedBox(height: 6),
                    if (_lichDangKy.isEmpty)
                      const Text('Chưa có lịch cho các môn đã đăng ký')
                    else
                      ..._lichDangKy.map((l) {
                        final thu = l['thu'] ?? '';
                        final gb = l['gioBatDau'] ?? '';
                        final gk = l['gioKetThuc'] ?? '';
                        final phong = l['phongHoc'] ?? '';
                        final maMon = l['maMon'] ?? '';
                        return Text('- $maMon: $thu, $gb - $gk | Phòng $phong');
                      }),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
