import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/theme_app.dart';

class ForgotPasswordScreen extends StatefulWidget{
 const ForgotPasswordScreen({super.key});

 @override
 State<ForgotPasswordScreen> createState()=>_ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>{
 final taiKhoanController=TextEditingController();
 final emailController=TextEditingController();
 final authService=AuthService();

 @override
 void dispose(){
  taiKhoanController.dispose();
  emailController.dispose();
  super.dispose();
 }

 InputDecoration oNhap(String hint,IconData icon){
  return InputDecoration(
   hintText:hint,
   prefixIcon:Icon(icon,color:ThemeApp.mauChinh),
   filled:true,
   fillColor:Colors.white,
   border:OutlineInputBorder(borderRadius:BorderRadius.circular(18),borderSide:BorderSide.none),
  );
 }

 void xacNhan(){
  if(taiKhoanController.text.trim().isEmpty||emailController.text.trim().isEmpty){
   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text("Vui long nhap day du thong tin")));
   return;
  }

  final tk=authService.kiemTraQuenMatKhau(taiKhoanController.text,emailController.text);

  if(tk==null){
   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text("Tai khoan hoac email khong dung")));
   return;
  }

  Navigator.pushNamed(context,"/reset-password",arguments:tk.maTK);
 }

 @override
 Widget build(BuildContext context){
  return Scaffold(
   backgroundColor:ThemeApp.mauNen,
   appBar:AppBar(title:const Text("Quen mat khau"),backgroundColor:ThemeApp.mauNen,foregroundColor:ThemeApp.chuDam,elevation:0),
   body:SafeArea(
    child:SingleChildScrollView(
     padding:const EdgeInsets.all(24),
     child:Column(
      children:[
       const SizedBox(height:25),
       Container(
        width:100,height:100,
        decoration:BoxDecoration(color:ThemeApp.mauPhu,borderRadius:BorderRadius.circular(28)),
        child:const Icon(Icons.lock_reset_rounded,size:55,color:ThemeApp.mauIcon),
       ),
       const SizedBox(height:20),
       const Text("Xac minh tai khoan",style:TextStyle(fontSize:25,fontWeight:FontWeight.bold,color:ThemeApp.chuDam)),
       const SizedBox(height:8),
       const Text("Nhap tai khoan va email de doi mat khau",textAlign:TextAlign.center,style:TextStyle(color:ThemeApp.chuPhu)),
       const SizedBox(height:30),
       TextField(controller:taiKhoanController,decoration:oNhap("Nhap tai khoan",Icons.person_rounded)),
       const SizedBox(height:16),
       TextField(controller:emailController,keyboardType:TextInputType.emailAddress,decoration:oNhap("Nhap email",Icons.email_rounded)),
       const SizedBox(height:30),
       SizedBox(
        width:double.infinity,height:56,
        child:ElevatedButton(
         onPressed:xacNhan,
         style:ElevatedButton.styleFrom(backgroundColor:ThemeApp.mauChinh,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(18))),
         child:const Text("XAC NHAN",style:TextStyle(color:Colors.white,fontWeight:FontWeight.bold,fontSize:17)),
        ),
       ),
      ],
     ),
    ),
   ),
  );
 }
}
