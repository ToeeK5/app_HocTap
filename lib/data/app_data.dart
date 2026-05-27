import '../models/diem.dart';
import '../models/ke_hoach_on_tap.dart';
import '../models/lich_hoc.dart';
import '../models/mon_hoc.dart';
import '../models/sinh_vien.dart';
import '../models/tai_khoan.dart';

class AppData {
  static List<SinhVien> danhSachSinhVien = [
    // Lớp CNTT1
    SinhVien(
      maSV: "20120001",
      hoTen: "Nguyễn An",
      email: "an@gmail.com",
      namSinh: 2005,
      lop: "CNTT1",
      hocKyHienTai: 3,
    ),
    SinhVien(
      maSV: "20120002",
      hoTen: "Trần Bình",
      email: "binh@gmail.com",
      namSinh: 2004,
      lop: "CNTT1",
      hocKyHienTai: 3,
    ),
    SinhVien(
      maSV: "20120003",
      hoTen: "Lê Cường",
      email: "cuong@gmail.com",
      namSinh: 2005,
      lop: "CNTT1",
      hocKyHienTai: 3,
    ),
    SinhVien(
      maSV: "20120004",
      hoTen: "Phạm Dũng",
      email: "dung@gmail.com",
      namSinh: 2004,
      lop: "CNTT1",
      hocKyHienTai: 3,
    ),
    SinhVien(
      maSV: "20120005",
      hoTen: "Hoàng Minh",
      email: "minh@gmail.com",
      namSinh: 2005,
      lop: "CNTT1",
      hocKyHienTai: 3,
    ),
    SinhVien(
      maSV: "20120006",
      hoTen: "Vũ Nhật",
      email: "nhat@gmail.com",
      namSinh: 2004,
      lop: "CNTT1",
      hocKyHienTai: 3,
    ),
    SinhVien(
      maSV: "20120007",
      hoTen: "Đặng Linh",
      email: "linh@gmail.com",
      namSinh: 2005,
      lop: "CNTT1",
      hocKyHienTai: 3,
    ),
    SinhVien(
      maSV: "20120008",
      hoTen: "Tô Thu",
      email: "thu@gmail.com",
      namSinh: 2004,
      lop: "CNTT1",
      hocKyHienTai: 3,
    ),
    SinhVien(
      maSV: "20120009",
      hoTen: "Kiều Anh",
      email: "anh@gmail.com",
      namSinh: 2005,
      lop: "CNTT1",
      hocKyHienTai: 3,
    ),
    SinhVien(
      maSV: "20120010",
      hoTen: "Phan Khánh",
      email: "khanh@gmail.com",
      namSinh: 2004,
      lop: "CNTT1",
      hocKyHienTai: 3,
    ),

    // Lớp CNTT2
    SinhVien(
      maSV: "20120011",
      hoTen: "Bùi Huy",
      email: "huy@gmail.com",
      namSinh: 2005,
      lop: "CNTT2",
      hocKyHienTai: 3,
    ),
    SinhVien(
      maSV: "20120012",
      hoTen: "Cao Thắng",
      email: "thang@gmail.com",
      namSinh: 2004,
      lop: "CNTT2",
      hocKyHienTai: 3,
    ),
    SinhVien(
      maSV: "20120013",
      hoTen: "Dương Long",
      email: "long@gmail.com",
      namSinh: 2005,
      lop: "CNTT2",
      hocKyHienTai: 3,
    ),
    SinhVien(
      maSV: "20120014",
      hoTen: "Gia Bảo",
      email: "bao@gmail.com",
      namSinh: 2004,
      lop: "CNTT2",
      hocKyHienTai: 3,
    ),
    SinhVien(
      maSV: "20120015",
      hoTen: "Hải Yến",
      email: "yen@gmail.com",
      namSinh: 2005,
      lop: "CNTT2",
      hocKyHienTai: 3,
    ),
    SinhVien(
      maSV: "20120016",
      hoTen: "Ích Thắng",
      email: "ithang@gmail.com",
      namSinh: 2004,
      lop: "CNTT2",
      hocKyHienTai: 3,
    ),
    SinhVien(
      maSV: "20120017",
      hoTen: "Khoa Học",
      email: "khoa@gmail.com",
      namSinh: 2005,
      lop: "CNTT2",
      hocKyHienTai: 3,
    ),
    SinhVien(
      maSV: "20120018",
      hoTen: "Lâm Trí",
      email: "lam@gmail.com",
      namSinh: 2004,
      lop: "CNTT2",
      hocKyHienTai: 3,
    ),
    SinhVien(
      maSV: "20120019",
      hoTen: "Minh Tuệ",
      email: "tue@gmail.com",
      namSinh: 2005,
      lop: "CNTT2",
      hocKyHienTai: 3,
    ),
    SinhVien(
      maSV: "20120020",
      hoTen: "Ngân Anh",
      email: "ngan@gmail.com",
      namSinh: 2004,
      lop: "CNTT2",
      hocKyHienTai: 3,
    ),
  ];

  static List<TaiKhoan> danhSachTaiKhoan = [
    // --- TÀI KHOẢN SINH VIÊN 1 ---
    TaiKhoan(
      maTK: 'TK001',
      maSV: '20120001',       // Đổi mã sinh viên sang số mới
      tenDangNhap: 'SV001',   // Giữ nguyên
      matKhau: 'SV001',       // Giữ nguyên
      vaiTro: 'sinhvien',
    ),

    // --- TÀI KHOẢN ADMIN ---
    TaiKhoan(
      maTK: 'TK002',
      maSV: 'AD001',          
      tenDangNhap: 'admin',   
      matKhau: 'admin',      
      vaiTro: 'admin',
    ),

    // --- TÀI KHOẢN SINH VIÊN 2 ---
    TaiKhoan(
      maTK: 'TK003',
      maSV: '20120002',       
      tenDangNhap: 'SV003',   
      matKhau: 'SV003',       
      vaiTro: 'sinhvien',
    ),

    // --- TÀI KHOẢN SINH VIÊN 3 ---
    TaiKhoan(
      maTK: 'TK004',
      maSV: '20120003',       
      tenDangNhap: 'SV004',   
      matKhau: 'SV004',       
      vaiTro: 'sinhvien',
    ),

    // --- TÀI KHOẢN SINH VIÊN 4 ---
    TaiKhoan(
      maTK: 'TK005',
      maSV: '20120004',       
      tenDangNhap: 'SV005',   
      matKhau: 'SV005',       
      vaiTro: 'sinhvien',
    ),
  ];

  static List<MonHoc> danhSachMonHoc = [
    MonHoc(maMon: 'MH001', tenMon: 'Lập Trình Flutter', soTinChi: 3, hocKy: 3),
    MonHoc(maMon: 'MH002', tenMon: 'Cơ Sở Dữ Liệu', soTinChi: 3, hocKy: 3),
    MonHoc(maMon: 'MH003', tenMon: 'Lập Trình Web', soTinChi: 2, hocKy: 3),
    MonHoc(maMon: 'MH004', tenMon: 'Java Nâng Cao', soTinChi: 3, hocKy: 4),
  ];

  static List<Diem> danhSachDiem=[
    // Dữ liệu điểm cho lớp CNTT1
    Diem(
      maDiem:"D001",
      maSV:"20120001",
      maMon:"MH001",
      diemGiuaKy:8,
      diemCuoiKy:9,
      heSoGiuaKy:0.4,
      heSoCuoiKy:0.6
    ),
    Diem(
      maDiem:"D002",
      maSV:"20120002",
      maMon:"MH001",
      diemGiuaKy:7,
      diemCuoiKy:8,
      heSoGiuaKy:0.4,
      heSoCuoiKy:0.6
    ),
    Diem(
      maDiem:"D003",
      maSV:"20120003",
      maMon:"MH001",
      diemGiuaKy:6,
      diemCuoiKy:6.5,
      heSoGiuaKy:0.4,
      heSoCuoiKy:0.6
    ),
    Diem(
      maDiem:"D004",
      maSV:"20120004",
      maMon:"MH001",
      diemGiuaKy:5,
      diemCuoiKy:5.5,
      heSoGiuaKy:0.4,
      heSoCuoiKy:0.6
    ),
    Diem(
      maDiem:"D005",
      maSV:"20120005",
      maMon:"MH001",
      diemGiuaKy:9,
      diemCuoiKy:8.5,
      heSoGiuaKy:0.4,
      heSoCuoiKy:0.6
    ),
    Diem(
      maDiem:"D006",
      maSV:"20120006",
      maMon:"MH001",
      diemGiuaKy:7.5,
      diemCuoiKy:8,
      heSoGiuaKy:0.4,
      heSoCuoiKy:0.6
    ),
    Diem(
      maDiem:"D007",
      maSV:"20120007",
      maMon:"MH001",
      diemGiuaKy:8,
      diemCuoiKy:7.5,
      heSoGiuaKy:0.4,
      heSoCuoiKy:0.6
    ),
    Diem(
      maDiem:"D008",
      maSV:"20120008",
      maMon:"MH001",
      diemGiuaKy:6.5,
      diemCuoiKy:7,
      heSoGiuaKy:0.4,
      heSoCuoiKy:0.6
    ),
    Diem(
      maDiem:"D009",
      maSV:"20120009",
      maMon:"MH001",
      diemGiuaKy:7,
      diemCuoiKy:7.5,
      heSoGiuaKy:0.4,
      heSoCuoiKy:0.6
    ),
    Diem(
      maDiem:"D010",
      maSV:"20120010",
      maMon:"MH001",
      diemGiuaKy:8.5,
      diemCuoiKy:8.5,
      heSoGiuaKy:0.4,
      heSoCuoiKy:0.6
    ),
    
    // Dữ liệu điểm cho lớp CNTT2
    Diem(
      maDiem:"D011",
      maSV:"20120011",
      maMon:"MH001",
      diemGiuaKy:7.5,
      diemCuoiKy:8,
      heSoGiuaKy:0.4,
      heSoCuoiKy:0.6
    ),
    Diem(
      maDiem:"D012",
      maSV:"20120012",
      maMon:"MH001",
      diemGiuaKy:6,
      diemCuoiKy:6.5,
      heSoGiuaKy:0.4,
      heSoCuoiKy:0.6
    ),
    Diem(
      maDiem:"D013",
      maSV:"20120013",
      maMon:"MH001",
      diemGiuaKy:8,
      diemCuoiKy:8.5,
      heSoGiuaKy:0.4,
      heSoCuoiKy:0.6
    ),
    Diem(
      maDiem:"D014",
      maSV:"20120014",
      maMon:"MH001",
      diemGiuaKy:7,
      diemCuoiKy:7,
      heSoGiuaKy:0.4,
      heSoCuoiKy:0.6
    ),
    Diem(
      maDiem:"D015",
      maSV:"20120015",
      maMon:"MH001",
      diemGiuaKy:9,
      diemCuoiKy:9,
      heSoGiuaKy:0.4,
      heSoCuoiKy:0.6
    ),
    Diem(
      maDiem:"D016",
      maSV:"20120016",
      maMon:"MH001",
      diemGiuaKy:6.5,
      diemCuoiKy:7,
      heSoGiuaKy:0.4,
      heSoCuoiKy:0.6
    ),
    Diem(
      maDiem:"D017",
      maSV:"20120017",
      maMon:"MH001",
      diemGiuaKy:8,
      diemCuoiKy:8,
      heSoGiuaKy:0.4,
      heSoCuoiKy:0.6
    ),
    Diem(
      maDiem:"D018",
      maSV:"20120018",
      maMon:"MH001",
      diemGiuaKy:5.5,
      diemCuoiKy:6,
      heSoGiuaKy:0.4,
      heSoCuoiKy:0.6
    ),
    Diem(
      maDiem:"D019",
      maSV:"20120019",
      maMon:"MH001",
      diemGiuaKy:7.5,
      diemCuoiKy:8,
      heSoGiuaKy:0.4,
      heSoCuoiKy:0.6
    ),
    Diem(
      maDiem:"D020",
      maSV:"20120020",
      maMon:"MH001",
      diemGiuaKy:8.5,
      diemCuoiKy:9,
      heSoGiuaKy:0.4,
      heSoCuoiKy:0.6
    )

  ];

  static List<LichHoc> danhSachLichHoc = [
    // --- SINH VIÊN 1: Nguyễn An (20120001) ---
    LichHoc(
      maLich: 'L001',
      maSV: '20120001',
      maMon: 'MH001',
      thu: 'Thứ 2',
      gioBatDau: '07:00',
      gioKetThuc: '09:30',
      phongHoc: 'A205',
    ),
    LichHoc(
      maLich: 'L002',
      maSV: '20120001',
      maMon: 'MH002',
      thu: 'Thứ 4',
      gioBatDau: '13:00',
      gioKetThuc: '15:30',
      phongHoc: 'B103',
    ),
    LichHoc(
      maLich: 'L003',
      maSV: '20120001',
      maMon: 'MH003',
      thu: 'Thứ 6',
      gioBatDau: '09:45',
      gioKetThuc: '11:15',
      phongHoc: 'C301',
    ),
    LichHoc(
      maLich: 'L004',
      maSV: '20120001',
      maMon: 'MH004',
      thu: 'Thứ 7',
      gioBatDau: '15:30',
      gioKetThuc: '17:00',
      phongHoc: 'D201',
    ),

    // --- SINH VIÊN 2: Trần Bình (20120002) ---
    LichHoc(
      maLich: 'L005',
      maSV: '20120002',
      maMon: 'MH001',
      thu: 'Thứ 3',
      gioBatDau: '07:00',
      gioKetThuc: '09:30',
      phongHoc: 'A101',
    ),
    LichHoc(
      maLich: 'L006',
      maSV: '20120002',
      maMon: 'MH002',
      thu: 'Thứ 5',
      gioBatDau: '09:45',
      gioKetThuc: '11:15',
      phongHoc: 'B202',
    ),
    LichHoc(
      maLich: 'L007',
      maSV: '20120002',
      maMon: 'MH003',
      thu: 'Thứ 6',
      gioBatDau: '13:00',
      gioKetThuc: '15:30',
      phongHoc: 'C105',
    ),
    LichHoc(
      maLich: 'L008',
      maSV: '20120002',
      maMon: 'MH004',
      thu: 'Thứ 7',
      gioBatDau: '07:00',
      gioKetThuc: '09:30',
      phongHoc: 'D102',
    ),

    // --- SINH VIÊN 3: Lê Cường (20120003) ---
    LichHoc(
      maLich: 'L009',
      maSV: '20120003',
      maMon: 'MH001',
      thu: 'Thứ 2',
      gioBatDau: '13:00',
      gioKetThuc: '15:30',
      phongHoc: 'A301',
    ),
    LichHoc(
      maLich: 'L010',
      maSV: '20120003',
      maMon: 'MH002',
      thu: 'Thứ 3',
      gioBatDau: '09:45',
      gioKetThuc: '11:15',
      phongHoc: 'B305',
    ),
    LichHoc(
      maLich: 'L011',
      maSV: '20120003',
      maMon: 'MH003',
      thu: 'Thứ 5',
      gioBatDau: '07:00',
      gioKetThuc: '09:30',
      phongHoc: 'C204',
    ),
    LichHoc(
      maLich: 'L012',
      maSV: '20120003',
      maMon: 'MH004',
      thu: 'Thứ 6',
      gioBatDau: '15:30',
      gioKetThuc: '17:00',
      phongHoc: 'D303',
    ),

    // --- SINH VIÊN 4: Phạm Dũng (20120004) ---
    LichHoc(
      maLich: 'L013',
      maSV: '20120004',
      maMon: 'MH001',
      thu: 'Thứ 2',
      gioBatDau: '09:45',
      gioKetThuc: '11:15',
      phongHoc: 'A205',
    ),
    LichHoc(
      maLich: 'L014',
      maSV: '20120004',
      maMon: 'MH002',
      thu: 'Thứ 4',
      gioBatDau: '07:00',
      gioKetThuc: '09:30',
      phongHoc: 'B101',
    ),
    LichHoc(
      maLich: 'L015',
      maSV: '20120004',
      maMon: 'MH003',
      thu: 'Thứ 5',
      gioBatDau: '13:00',
      gioKetThuc: '15:30',
      phongHoc: 'C302',
    ),
    LichHoc(
      maLich: 'L016',
      maSV: '20120004',
      maMon: 'MH004',
      thu: 'Thứ 7',
      gioBatDau: '09:45',
      gioKetThuc: '11:15',
      phongHoc: 'D404',
    ),

    // --- SINH VIÊN 5: Hoàng Giang (20120005) ---
    LichHoc(
      maLich: 'L017',
      maSV: '20120005',
      maMon: 'MH001',
      thu: 'Thứ 3',
      gioBatDau: '13:00',
      gioKetThuc: '15:30',
      phongHoc: 'A102',
    ),
    LichHoc(
      maLich: 'L018',
      maSV: '20120005',
      maMon: 'MH002',
      thu: 'Thứ 4',
      gioBatDau: '15:30',
      gioKetThuc: '17:00',
      phongHoc: 'B203',
    ),
    LichHoc(
      maLich: 'L019',
      maSV: '20120005',
      maMon: 'MH003',
      thu: 'Thứ 6',
      gioBatDau: '07:00',
      gioKetThuc: '09:30',
      phongHoc: 'C104',
    ),
    LichHoc(
      maLich: 'L020',
      maSV: '20120005',
      maMon: 'MH004',
      thu: 'Thứ 7',
      gioBatDau: '13:00',
      gioKetThuc: '15:30',
      phongHoc: 'D101',
    ),
  ];

  static List<KeHoachOnTap> danhSachKeHoach = [
    // --- SINH VIÊN 1: Nguyễn An (20120001) ---
    KeHoachOnTap(
      maKeHoach: 'KH001',
      maSV: '20120001', // Đổi từ SV001 -> 20120001
      tieuDe: 'Ôn Flutter',
      noiDung: 'Ôn widget',
      ngayOnTap: '25/05/2026',
      trangThai: 'Chưa xong',
    ),
    
    // --- SINH VIÊN 2: Trần Bình (20120002) ---
    KeHoachOnTap(
      maKeHoach: 'KH002',
      maSV: '20120002', // Đổi từ SV002 -> 20120002
      tieuDe: 'Ôn CSDL',
      noiDung: 'Ôn truy vấn SQL',
      ngayOnTap: '26/05/2026',
      trangThai: 'Chưa xong',
    ),
    
    // --- SINH VIÊN 3: Lê Cường (20120003) ---
    KeHoachOnTap(
      maKeHoach: 'KH003',
      maSV: '20120003', // Đổi từ SV003 -> 20120003
      tieuDe: 'Ôn Web',
      noiDung: 'Ôn HTML CSS JS',
      ngayOnTap: '27/05/2026',
      trangThai: 'Đã xong',
    ),
  ];
}
