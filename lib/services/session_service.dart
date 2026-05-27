import '../models/tai_khoan.dart';

class SessionService{
 static TaiKhoan? taiKhoanDangNhap;

 static void luuDangNhap(TaiKhoan tk){
  taiKhoanDangNhap=tk;
 }

 static String layMaSV(){
  return taiKhoanDangNhap?.maSV ?? "SV001";
 }

 static void dangXuat(){
  taiKhoanDangNhap=null;
 }
}
