import '../services/diem_service.dart';

class TinhToanHocTap{
 static double lamTron(double value)=>double.parse(value.toStringAsFixed(2));

 static double tinhGPAHe10(List<DiemMonHienThi> ds){
  if(ds.isEmpty)return 0;

  double tongDiem=0;
  int tongTin=0;

  for(final item in ds){
   tongDiem+=item.diemTongKet*item.monHoc.soTinChi;
   tongTin+=item.monHoc.soTinChi;
  }

  if(tongTin==0)return 0;
  return lamTron(tongDiem/tongTin);
 }

 static double tinhGPAHe4(double gpa10)=>lamTron(gpa10/10*4);

 static int tinhTongTin(List<DiemMonHienThi> ds){
  int tong=0;
  for(final item in ds){
   tong+=item.monHoc.soTinChi;
  }
  return tong;
 }

 static String xepLoaiHocLuc(double gpa10){
  if(gpa10>=8.5)return "Gioi";
  if(gpa10>=7.0)return "Kha";
  if(gpa10>=5.0)return "Trung binh";
  return "Yeu";
 }
}
