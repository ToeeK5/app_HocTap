import '../data/app_data.dart';
import '../models/diem.dart';
import '../models/mon_hoc.dart';

class DiemMonHienThi{
 final Diem diem;
 final MonHoc monHoc;
 final double diemTongKet;

 DiemMonHienThi({required this.diem,required this.monHoc,required this.diemTongKet});
}

class DiemService{
 // NOTE FIREBASE:
 // Sau nay doi AppData thanh Firestore collection DIEM va MONHOC.
 List<DiemMonHienThi> layDiemTheoSinhVien(String maSV){
  final dsDiem=AppData.danhSachDiem.where((d)=>d.maSV==maSV).toList();

  final ketQua=<DiemMonHienThi>[];
  for(final d in dsDiem){
   final mon=timMonHocTheoMa(d.maMon);
   if(mon==null)continue;
   ketQua.add(DiemMonHienThi(diem:d,monHoc:mon,diemTongKet:tinhDiemTongKet(d)));
  }

  return ketQua;
 }

 double tinhDiemTongKet(Diem d){
  final tongHeSo=d.heSoGiuaKy+d.heSoCuoiKy;
  if(tongHeSo==0)return 0;
  final diem=(d.diemGiuaKy*d.heSoGiuaKy+d.diemCuoiKy*d.heSoCuoiKy)/tongHeSo;
  return diem.clamp(0,10).toDouble();
 }

 MonHoc? timMonHocTheoMa(String maMon){
  try{
   return AppData.danhSachMonHoc.firstWhere((m)=>m.maMon==maMon);
  }catch(e){
   return null;
  }
 }
}
