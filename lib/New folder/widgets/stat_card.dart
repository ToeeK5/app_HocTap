import 'package:flutter/material.dart';
import '../utils/theme_app.dart';

class StatCard extends StatelessWidget{
 final String title;
 final String value;
 final IconData icon;

 const StatCard({super.key,required this.title,required this.value,required this.icon});

 @override
 Widget build(BuildContext context){
  return Container(
   padding:const EdgeInsets.all(14),
   decoration:BoxDecoration(
    color:Colors.white,
    borderRadius:BorderRadius.circular(18),
    border:Border.all(color:ThemeApp.mauVien),
    boxShadow:const [BoxShadow(color:Color(0x11000000),blurRadius:8,offset:Offset(0,4))],
   ),
   child:Column(
    children:[
     Icon(icon,color:ThemeApp.mauIcon),
     const SizedBox(height:8),
     Text(value,style:const TextStyle(fontSize:20,fontWeight:FontWeight.bold,color:ThemeApp.chuDam)),
     const SizedBox(height:4),
     Text(title,textAlign:TextAlign.center,style:const TextStyle(fontSize:12,color:ThemeApp.chuPhu)),
    ],
   ),
  );
 }
}
