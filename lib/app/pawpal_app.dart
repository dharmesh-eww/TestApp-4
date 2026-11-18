import 'package:flutter/material.dart';
import 'app_shell.dart';
import '../core/theme/app_theme.dart';
class PawPalApp extends StatelessWidget {const PawPalApp({super.key});@override Widget build(BuildContext context)=>MaterialApp(title:'PawPal',debugShowCheckedModeBanner:false,themeMode:ThemeMode.light,theme:buildPawTheme(),home:const AppShell());}
