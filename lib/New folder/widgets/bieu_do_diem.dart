import 'dart:math';
import 'package:flutter/material.dart';
import '../services/diem_service.dart';
import '../utils/theme_app.dart';

class BieuDoDiem extends StatelessWidget{
 final List<DiemMonHienThi> ds;
 final bool dangTron;

 const BieuDoDiem({super.key,required this.ds,required this.dangTron});

 @override
 Widget build(BuildContext context){
  return SizedBox(
   height:dangTron?230:220,
   width:double.infinity,
   child:CustomPaint(
    painter:dangTron?_PiePainter(ds):_BarPainter(ds),
   ),
  );
 }
}

class _PiePainter extends CustomPainter{
 final List<DiemMonHienThi> ds;
 _PiePainter(this.ds);

 @override
 void paint(Canvas canvas,Size size){
  if(ds.isEmpty)return;

  final center=Offset(size.width/2,size.height/2);
  final maxDiem=ds.map((e)=>e.diemTongKet).reduce(max);
  final tong=ds.fold<double>(0,(sum,e)=>sum+e.diemTongKet);
  if(tong<=0)return;
  double start=-pi/2;

  final colors=[
   ThemeApp.mauChinh,
   const Color(0xff85C1E9),
   const Color(0xffAED6F1),
   const Color(0xffD6EAF8),
   const Color(0xff2E86C1),
  ];

  for(int i=0;i<ds.length;i++){
   final item=ds[i];
   final sweep=(item.diemTongKet/tong)*2*pi;
   final radius=item.diemTongKet==maxDiem?82.0:68.0;
   final rect=Rect.fromCircle(center:center,radius:radius);
   final paint=Paint()..color=colors[i%colors.length]..style=PaintingStyle.fill;

   canvas.drawArc(rect,start,sweep,true,paint);

   final mid=start+sweep/2;
   final textOffset=Offset(center.dx+cos(mid)*radius*0.55,center.dy+sin(mid)*radius*0.55);
   final tp=TextPainter(
    text:TextSpan(
     text:"${item.monHoc.tenMon}\n${item.diemTongKet.toStringAsFixed(1)}",
     style:const TextStyle(color:Colors.white,fontSize:10,fontWeight:FontWeight.bold),
    ),
    textAlign:TextAlign.center,
    textDirection:TextDirection.ltr,
   )..layout(maxWidth:70);

   tp.paint(canvas,textOffset-Offset(tp.width/2,tp.height/2));
   start+=sweep;
  }

  canvas.drawCircle(center,34,Paint()..color=Colors.white);
 }

 @override
 bool shouldRepaint(covariant CustomPainter oldDelegate)=>true;
}

class _BarPainter extends CustomPainter{
 final List<DiemMonHienThi> ds;
 _BarPainter(this.ds);

 @override
 void paint(Canvas canvas,Size size){
  if(ds.isEmpty)return;

  final paint=Paint()..color=ThemeApp.mauChinh..style=PaintingStyle.fill;
  final textStyle=const TextStyle(color:ThemeApp.chuDam,fontSize:11,fontWeight:FontWeight.bold);
  final labelStyle=const TextStyle(color:ThemeApp.chuPhu,fontSize:10);
  final barWidth=size.width/(ds.length*2);
  final maxHeight=size.height-45;

  for(int i=0;i<ds.length;i++){
   final item=ds[i];
   final x=barWidth*(i*2+0.6);
   final h=(item.diemTongKet/10)*maxHeight;
   final rect=RRect.fromRectAndRadius(
    Rect.fromLTWH(x,size.height-30-h,barWidth,h),
    const Radius.circular(10),
   );

   canvas.drawRRect(rect,paint);

   final diem=TextPainter(
    text:TextSpan(text:item.diemTongKet.toStringAsFixed(1),style:textStyle),
    textDirection:TextDirection.ltr,
   )..layout();

   diem.paint(canvas,Offset(x+barWidth/2-diem.width/2,size.height-38-h));

   final ten=TextPainter(
    text:TextSpan(text:item.monHoc.tenMon.length>8?item.monHoc.tenMon.substring(0,8):item.monHoc.tenMon,style:labelStyle),
    textDirection:TextDirection.ltr,
   )..layout(maxWidth:barWidth+20);

   ten.paint(canvas,Offset(x+barWidth/2-ten.width/2,size.height-22));
  }
 }

 @override
 bool shouldRepaint(covariant CustomPainter oldDelegate)=>true;
}
