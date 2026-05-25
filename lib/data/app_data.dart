
import '../models/sinh_vien.dart';
import '../models/tai_khoan.dart';
import '../models/mon_hoc.dart';
import '../models/diem.dart';
import '../models/lich_hoc.dart';
import '../models/ke_hoach_on_tap.dart';

class AppData{

  static List<SinhVien> danhSachSinhVien=[

    SinhVien(

      maSV:"SV001",

      hoTen:"Dinh Hoang Cuoc",

      email:"cuoc@gmail.com",

      namSinh:2005,

      lop:"CNTT",

      hocKyHienTai:3

    ),

    SinhVien(

      maSV:"SV002",

      hoTen:"Nguyen Van A",

      email:"vana@gmail.com",

      namSinh:2004,

      lop:"CNTT",

      hocKyHienTai:2

    )

  ];



  static List<TaiKhoan> danhSachTaiKhoan=[

    TaiKhoan(

      maTK:"TK001",

      maSV:"SV001",

      tenDangNhap:"SV001",

      matKhau:"SV001",

      vaiTro:"sinhvien"

    ),

    TaiKhoan(

      maTK:"TK002",

      maSV:"SV002",

      tenDangNhap:"admin",

      matKhau:"admin",

      vaiTro:"admin"

    )

  ];



  static List<MonHoc> danhSachMonHoc=[

    MonHoc(

      maMon:"MH001",

      tenMon:"Lap Trinh Flutter",

      soTinChi:3,

      hocKy:3

    ),

    MonHoc(

      maMon:"MH002",

      tenMon:"Co So Du Lieu",

      soTinChi:3,

      hocKy:3

    ),

    MonHoc(

      maMon:"MH003",

      tenMon:"Lap Trinh Web",

      soTinChi:2,

      hocKy:3

    )

  ];



  static List<Diem> danhSachDiem=[

    Diem(

      maDiem:"D001",

      maSV:"SV001",

      maMon:"MH001",

      diemGiuaKy:8,

      diemCuoiKy:9,

      heSoGiuaKy:0.4,

      heSoCuoiKy:0.6

    ),

    Diem(

      maDiem:"D002",

      maSV:"SV001",

      maMon:"MH002",

      diemGiuaKy:7,

      diemCuoiKy:8,

      heSoGiuaKy:0.4,

      heSoCuoiKy:0.6

    ),

    Diem(

      maDiem:"D003",

      maSV:"SV001",

      maMon:"MH003",

      diemGiuaKy:9,

      diemCuoiKy:8.5,

      heSoGiuaKy:0.4,

      heSoCuoiKy:0.6

    )

  ];



  static List<LichHoc> danhSachLichHoc=[

    LichHoc(

      maLich:"L001",

      maSV:"SV001",

      maMon:"MH001",

      thu:"Thu 2",

      gioBatDau:"07:00",

      gioKetThuc:"09:30",

      phongHoc:"A205"

    ),

    LichHoc(

      maLich:"L002",

      maSV:"SV001",

      maMon:"MH002",

      thu:"Thu 4",

      gioBatDau:"13:00",

      gioKetThuc:"15:30",

      phongHoc:"B103"

    )

  ];



  static List<KeHoachOnTap>
  danhSachKeHoach=[

    KeHoachOnTap(

      maKeHoach:"KH001",

      maSV:"SV001",

      tieuDe:"On Flutter",

      noiDung:"On widget",

      ngayOnTap:"25/05/2026",

      trangThai:"Chua xong"

    )

  ];

}

