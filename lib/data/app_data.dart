import '../models/diem.dart';
import '../models/ke_hoach_on_tap.dart';
import '../models/lich_hoc.dart';
import '../models/mon_hoc.dart';
import '../models/sinh_vien.dart';
import '../models/tai_khoan.dart';

class AppData {
  static List<SinhVien> danhSachSinhVien = [
    SinhVien(maSV: 'SV001', hoTen: 'Đinh Hoàng Cước', email: 'cuoc@gmail.com', namSinh: 2005, lop: 'CNTT', hocKyHienTai: 3),
    SinhVien(maSV: 'SV002', hoTen: 'Nguyễn Văn A', email: 'vana@gmail.com', namSinh: 2004, lop: 'CNTT', hocKyHienTai: 2),
    SinhVien(maSV: 'SV003', hoTen: 'Lê Thành Hiệp', email: 'hiep@gmail.com', namSinh: 2005, lop: 'CNTT', hocKyHienTai: 3),
    SinhVien(maSV: 'SV004', hoTen: 'Nguyễn Minh Tuệ', email: 'tue@gmail.com', namSinh: 2004, lop: 'CNTT', hocKyHienTai: 4),
    SinhVien(maSV: 'SV005', hoTen: 'Huỳnh Đình Tùng', email: 'tung@gmail.com', namSinh: 2005, lop: 'CNTT', hocKyHienTai: 3),
  ];

  static List<TaiKhoan> danhSachTaiKhoan = [
    TaiKhoan(maTK: 'TK001', maSV: 'SV001', tenDangNhap: 'SV001', matKhau: 'SV001', vaiTro: 'sinhvien'),
    TaiKhoan(maTK: 'TK002', maSV: 'SV002', tenDangNhap: 'admin', matKhau: 'admin', vaiTro: 'admin'),
    TaiKhoan(maTK: 'TK003', maSV: 'SV003', tenDangNhap: 'SV003', matKhau: 'SV003', vaiTro: 'sinhvien'),
    TaiKhoan(maTK: 'TK004', maSV: 'SV004', tenDangNhap: 'SV004', matKhau: 'SV004', vaiTro: 'sinhvien'),
    TaiKhoan(maTK: 'TK005', maSV: 'SV005', tenDangNhap: 'SV005', matKhau: 'SV005', vaiTro: 'sinhvien'),
  ];

  static List<MonHoc> danhSachMonHoc = [
    MonHoc(maMon: 'MH001', tenMon: 'Lập Trình Flutter', soTinChi: 3, hocKy: 3),
    MonHoc(maMon: 'MH002', tenMon: 'Cơ Sở Dữ Liệu', soTinChi: 3, hocKy: 3),
    MonHoc(maMon: 'MH003', tenMon: 'Lập Trình Web', soTinChi: 2, hocKy: 3),
    MonHoc(maMon: 'MH004', tenMon: 'Java Nâng Cao', soTinChi: 3, hocKy: 4),
  ];

  static List<Diem> danhSachDiem = [
    Diem(maDiem: 'D001', maSV: 'SV001', maMon: 'MH001', diemGiuaKy: 8, diemCuoiKy: 9, heSoGiuaKy: 0.4, heSoCuoiKy: 0.6),
    Diem(maDiem: 'D002', maSV: 'SV001', maMon: 'MH002', diemGiuaKy: 7, diemCuoiKy: 8, heSoGiuaKy: 0.4, heSoCuoiKy: 0.6),
    Diem(maDiem: 'D003', maSV: 'SV001', maMon: 'MH003', diemGiuaKy: 9, diemCuoiKy: 8.5, heSoGiuaKy: 0.4, heSoCuoiKy: 0.6),
    Diem(maDiem: 'D004', maSV: 'SV001', maMon: 'MH004', diemGiuaKy: 8, diemCuoiKy: 7.5, heSoGiuaKy: 0.4, heSoCuoiKy: 0.6),

    Diem(maDiem: 'D005', maSV: 'SV002', maMon: 'MH001', diemGiuaKy: 6, diemCuoiKy: 7, heSoGiuaKy: 0.4, heSoCuoiKy: 0.6),
    Diem(maDiem: 'D006', maSV: 'SV002', maMon: 'MH002', diemGiuaKy: 5, diemCuoiKy: 6, heSoGiuaKy: 0.4, heSoCuoiKy: 0.6),
    Diem(maDiem: 'D007', maSV: 'SV002', maMon: 'MH003', diemGiuaKy: 7, diemCuoiKy: 7, heSoGiuaKy: 0.4, heSoCuoiKy: 0.6),
    Diem(maDiem: 'D008', maSV: 'SV002', maMon: 'MH004', diemGiuaKy: 8, diemCuoiKy: 6.5, heSoGiuaKy: 0.4, heSoCuoiKy: 0.6),

    Diem(maDiem: 'D009', maSV: 'SV003', maMon: 'MH001', diemGiuaKy: 9, diemCuoiKy: 9, heSoGiuaKy: 0.4, heSoCuoiKy: 0.6),
    Diem(maDiem: 'D010', maSV: 'SV003', maMon: 'MH002', diemGiuaKy: 8, diemCuoiKy: 8, heSoGiuaKy: 0.4, heSoCuoiKy: 0.6),
    Diem(maDiem: 'D011', maSV: 'SV003', maMon: 'MH003', diemGiuaKy: 7, diemCuoiKy: 9, heSoGiuaKy: 0.4, heSoCuoiKy: 0.6),
    Diem(maDiem: 'D012', maSV: 'SV003', maMon: 'MH004', diemGiuaKy: 10, diemCuoiKy: 9, heSoGiuaKy: 0.4, heSoCuoiKy: 0.6),

    Diem(maDiem: 'D013', maSV: 'SV004', maMon: 'MH001', diemGiuaKy: 7.5, diemCuoiKy: 8, heSoGiuaKy: 0.4, heSoCuoiKy: 0.6),
    Diem(maDiem: 'D014', maSV: 'SV004', maMon: 'MH002', diemGiuaKy: 8, diemCuoiKy: 7, heSoGiuaKy: 0.4, heSoCuoiKy: 0.6),
    Diem(maDiem: 'D015', maSV: 'SV004', maMon: 'MH003', diemGiuaKy: 6.5, diemCuoiKy: 7.5, heSoGiuaKy: 0.4, heSoCuoiKy: 0.6),
    Diem(maDiem: 'D016', maSV: 'SV004', maMon: 'MH004', diemGiuaKy: 9, diemCuoiKy: 8, heSoGiuaKy: 0.4, heSoCuoiKy: 0.6),

    Diem(maDiem: 'D017', maSV: 'SV005', maMon: 'MH001', diemGiuaKy: 5, diemCuoiKy: 6, heSoGiuaKy: 0.4, heSoCuoiKy: 0.6),
    Diem(maDiem: 'D018', maSV: 'SV005', maMon: 'MH002', diemGiuaKy: 6, diemCuoiKy: 6.5, heSoGiuaKy: 0.4, heSoCuoiKy: 0.6),
    Diem(maDiem: 'D019', maSV: 'SV005', maMon: 'MH003', diemGiuaKy: 7, diemCuoiKy: 5.5, heSoGiuaKy: 0.4, heSoCuoiKy: 0.6),
    Diem(maDiem: 'D020', maSV: 'SV005', maMon: 'MH004', diemGiuaKy: 8, diemCuoiKy: 8.5, heSoGiuaKy: 0.4, heSoCuoiKy: 0.6),
  ];

  static List<LichHoc> danhSachLichHoc = [
    LichHoc(maLich: 'L001', maSV: 'SV001', maMon: 'MH001', thu: 'Thứ 2', gioBatDau: '07:00', gioKetThuc: '09:30', phongHoc: 'A205'),
    LichHoc(maLich: 'L002', maSV: 'SV001', maMon: 'MH002', thu: 'Thứ 4', gioBatDau: '13:00', gioKetThuc: '15:30', phongHoc: 'B103'),
    LichHoc(maLich: 'L003', maSV: 'SV001', maMon: 'MH003', thu: 'Thứ 6', gioBatDau: '09:45', gioKetThuc: '11:15', phongHoc: 'C301'),
    LichHoc(maLich: 'L004', maSV: 'SV001', maMon: 'MH004', thu: 'Thứ 7', gioBatDau: '15:30', gioKetThuc: '17:00', phongHoc: 'D201'),

    LichHoc(maLich: 'L005', maSV: 'SV002', maMon: 'MH001', thu: 'Thứ 3', gioBatDau: '07:00', gioKetThuc: '09:30', phongHoc: 'A101'),
    LichHoc(maLich: 'L006', maSV: 'SV002', maMon: 'MH002', thu: 'Thứ 5', gioBatDau: '09:45', gioKetThuc: '11:15', phongHoc: 'B202'),
    LichHoc(maLich: 'L007', maSV: 'SV002', maMon: 'MH003', thu: 'Thứ 6', gioBatDau: '13:00', gioKetThuc: '15:30', phongHoc: 'C105'),
    LichHoc(maLich: 'L008', maSV: 'SV002', maMon: 'MH004', thu: 'Thứ 7', gioBatDau: '07:00', gioKetThuc: '09:30', phongHoc: 'D102'),

    LichHoc(maLich: 'L009', maSV: 'SV003', maMon: 'MH001', thu: 'Thứ 2', gioBatDau: '13:00', gioKetThuc: '15:30', phongHoc: 'A301'),
    LichHoc(maLich: 'L010', maSV: 'SV003', maMon: 'MH002', thu: 'Thứ 3', gioBatDau: '09:45', gioKetThuc: '11:15', phongHoc: 'B305'),
    LichHoc(maLich: 'L011', maSV: 'SV003', maMon: 'MH003', thu: 'Thứ 5', gioBatDau: '07:00', gioKetThuc: '09:30', phongHoc: 'C204'),
    LichHoc(maLich: 'L012', maSV: 'SV003', maMon: 'MH004', thu: 'Thứ 6', gioBatDau: '15:30', gioKetThuc: '17:00', phongHoc: 'D303'),

    LichHoc(maLich: 'L013', maSV: 'SV004', maMon: 'MH001', thu: 'Thứ 2', gioBatDau: '09:45', gioKetThuc: '11:15', phongHoc: 'A205'),
    LichHoc(maLich: 'L014', maSV: 'SV004', maMon: 'MH002', thu: 'Thứ 4', gioBatDau: '07:00', gioKetThuc: '09:30', phongHoc: 'B101'),
    LichHoc(maLich: 'L015', maSV: 'SV004', maMon: 'MH003', thu: 'Thứ 5', gioBatDau: '13:00', gioKetThuc: '15:30', phongHoc: 'C302'),
    LichHoc(maLich: 'L016', maSV: 'SV004', maMon: 'MH004', thu: 'Thứ 7', gioBatDau: '09:45', gioKetThuc: '11:15', phongHoc: 'D404'),

    LichHoc(maLich: 'L017', maSV: 'SV005', maMon: 'MH001', thu: 'Thứ 3', gioBatDau: '13:00', gioKetThuc: '15:30', phongHoc: 'A102'),
    LichHoc(maLich: 'L018', maSV: 'SV005', maMon: 'MH002', thu: 'Thứ 4', gioBatDau: '15:30', gioKetThuc: '17:00', phongHoc: 'B203'),
    LichHoc(maLich: 'L019', maSV: 'SV005', maMon: 'MH003', thu: 'Thứ 6', gioBatDau: '07:00', gioKetThuc: '09:30', phongHoc: 'C104'),
    LichHoc(maLich: 'L020', maSV: 'SV005', maMon: 'MH004', thu: 'Thứ 7', gioBatDau: '13:00', gioKetThuc: '15:30', phongHoc: 'D101'),
  ];

  static List<KeHoachOnTap> danhSachKeHoach = [
    KeHoachOnTap(maKeHoach: 'KH001', maSV: 'SV001', tieuDe: 'Ôn Flutter', noiDung: 'Ôn widget', ngayOnTap: '25/05/2026', trangThai: 'Chưa xong'),
    KeHoachOnTap(maKeHoach: 'KH002', maSV: 'SV002', tieuDe: 'Ôn CSDL', noiDung: 'Ôn truy vấn SQL', ngayOnTap: '26/05/2026', trangThai: 'Chưa xong'),
    KeHoachOnTap(maKeHoach: 'KH003', maSV: 'SV003', tieuDe: 'Ôn Web', noiDung: 'Ôn HTML CSS JS', ngayOnTap: '27/05/2026', trangThai: 'Đã xong'),
  ];
}