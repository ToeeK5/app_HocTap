import '../../data/app_data.dart';
import '../../models/sinh_vien.dart';

class SinhVienService{
 // NOTE FIREBASE:
 // Sau nay doi thanh query collection SINHVIEN where maSV.
 SinhVien? laySinhVienTheoMa(String maSV){
  try{
   return AppData.danhSachSinhVien.firstWhere((sv)=>sv.maSV==maSV);
  }catch(e){
   return null;
  }
 }
}
