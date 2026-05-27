import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/theme_app.dart';

class ResetPasswordScreen extends StatefulWidget{
 const ResetPasswordScreen({super.key});

 @override
 State<ResetPasswordScreen> createState()=>_ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen>{
 bool hienMK=false;
 final matKhauMoiController=TextEditingController();
 final xacNhanController=TextEditingController();
 final authService=AuthService();

 @override
 void dispose(){
  matKhauMoiController.dispose();
  xacNhanController.dispose();
  super.dispose();
 }

 InputDecoration oNhap(String hint){
  return InputDecoration(
   hintText:hint,
   prefixIcon:const Icon(Icons.lock_rounded,color:ThemeApp.mauChinh),
   suffixIcon:IconButton(
    onPressed:()=>setState(()=>hienMK=!hienMK),
    icon:Icon(hienMK?Icons.visibility_rounded:Icons.visibility_off_rounded,color:ThemeApp.chuPhu),
   ),
   filled:true,
   fillColor:Colors.white,
   border:OutlineInputBorder(borderRadius:BorderRadius.circular(18),borderSide:BorderSide.none),
  );
 }

 void doiMatKhau(){
  final arguments=ModalRoute.of(context)?.settings.arguments;
  if(arguments is! String || arguments.trim().isEmpty){
   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text("Không tìm thấy tài khoản cần đổi mật khẩu")));
   Navigator.pushNamedAndRemoveUntil(context,"/forgot-password",(route)=>false);
   return;
  }

  final maTK=arguments;
  final mk=matKhauMoiController.text.trim();
  final xacNhan=xacNhanController.text.trim();

  if(mk.isEmpty||xacNhan.isEmpty){
   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text("Vui lòng nhập đầy đủ mật khẩu")));
   return;
  }

  if(mk.length<3){
   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text("Mật khẩu phải từ 3 ký tự")));
   return;
  }

  if(mk!=xacNhan){
   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text("Mật khẩu xác nhận không khớp")));
   return;
  }

  final ok=authService.doiMatKhau(maTK,mk);

  if(ok){
   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text("Đổi mật khẩu thành công")));
   Navigator.pushNamedAndRemoveUntil(context,"/login",(route)=>false);
  }else{
   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text("Không đổi được mật khẩu")));
  }
 }

 @override
 Widget build(BuildContext context){
  return Scaffold(
   backgroundColor:ThemeApp.mauNen,
   appBar:AppBar(title:const Text("Đổi mật khẩu"),backgroundColor:ThemeApp.mauNen,foregroundColor:ThemeApp.chuDam,elevation:0),
   body:SafeArea(
    child:SingleChildScrollView(
     padding:const EdgeInsets.all(24),
     child:Column(
      children:[
       const SizedBox(height:25),
       Container(
        width:100,height:100,
        decoration:BoxDecoration(color:ThemeApp.mauPhu,borderRadius:BorderRadius.circular(28)),
        child:const Icon(Icons.password_rounded,size:55,color:ThemeApp.mauIcon),
       ),
       const SizedBox(height:20),
       const Text("Tạo mật khẩu mới",style:TextStyle(fontSize:25,fontWeight:FontWeight.bold,color:ThemeApp.chuDam)),
       const SizedBox(height:8),
       const Text("Nhập và xác nhận lại mật khẩu mới",style:TextStyle(color:ThemeApp.chuPhu)),
       const SizedBox(height:30),
       TextField(controller:matKhauMoiController,obscureText:!hienMK,decoration:oNhap("Nhập mật khẩu mới")),
       const SizedBox(height:16),
       TextField(controller:xacNhanController,obscureText:!hienMK,decoration:oNhap("Xác nhận mật khẩu")),
       const SizedBox(height:30),
       SizedBox(
        width:double.infinity,height:56,
        child:ElevatedButton(
         onPressed:doiMatKhau,
         style:ElevatedButton.styleFrom(backgroundColor:ThemeApp.mauChinh,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(18))),
         child:const Text("LƯU MẬT KHẨU",style:TextStyle(color:Colors.white,fontWeight:FontWeight.bold,fontSize:17)),
        ),
       ),
      ],
     ),
    ),
   ),
  );
 }
}
