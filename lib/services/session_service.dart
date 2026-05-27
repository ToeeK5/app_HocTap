import '../models/tai_khoan.dart';

class SessionService{

 static TaiKhoan? taiKhoanDangNhap;

 static String? maTKDoiMatKhau;

 static void luuDangNhap(
 TaiKhoan tk
 ){

  taiKhoanDangNhap=tk;

 }

 static String layMaSV(){

  return taiKhoanDangNhap?.maSV
  ?? "SV001";

 }

 static void dangXuat(){

  taiKhoanDangNhap=null;

 }

 static void luuMaTKDoiMatKhau(
 String maTK
 ){

  maTKDoiMatKhau=maTK;

 }

 static void xoaMaTKDoiMatKhau(){

  maTKDoiMatKhau=null;

 }

}
