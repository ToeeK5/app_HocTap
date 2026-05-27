import '../../data/app_data.dart';
import '../../models/tai_khoan.dart';

class AuthService{
 // NOTE FIREBASE:
 // Sau nay doi AppData thanh FirebaseAuth hoac Firestore collection TAIKHOAN.

 TaiKhoan? dangNhap(String taiKhoan,String matKhau){
  try{
   return AppData.danhSachTaiKhoan.firstWhere((tk)=>
    tk.tenDangNhap==taiKhoan.trim() && tk.matKhau==matKhau.trim()
   );
  }catch(e){
   return null;
  }
 }

 bool laAdmin(TaiKhoan tk){
  return tk.vaiTro.toLowerCase()=="admin";
 }

 TaiKhoan? kiemTraQuenMatKhau(String taiKhoan,String email){
  try{
   final tk=AppData.danhSachTaiKhoan.firstWhere((x)=>x.tenDangNhap==taiKhoan.trim());
   final sv=AppData.danhSachSinhVien.firstWhere((x)=>x.maSV==tk.maSV);
   if(sv.email.toLowerCase()==email.trim().toLowerCase())return tk;
   return null;
  }catch(e){
   return null;
  }
 }

 bool doiMatKhau(String maTK,String matKhauMoi){
  try{
   final tk=AppData.danhSachTaiKhoan.firstWhere((x)=>x.maTK==maTK);
   tk.matKhau=matKhauMoi.trim();
   return true;
  }catch(e){
   return false;
  }
 }
}
