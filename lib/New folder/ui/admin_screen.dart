import 'package:flutter/material.dart';
import '../utils/theme_app.dart';

class AdminScreen extends StatelessWidget{
 const AdminScreen({super.key});

 @override
 Widget build(BuildContext context){
  return Scaffold(
   backgroundColor:ThemeApp.mauNen,
   appBar:AppBar(title:const Text("Admin"),backgroundColor:ThemeApp.mauNen,foregroundColor:ThemeApp.chuDam),
   body:const Center(child:Text("Trang Admin",style:TextStyle(fontSize:24,fontWeight:FontWeight.bold,color:ThemeApp.chuDam))),
  );
 }
}
