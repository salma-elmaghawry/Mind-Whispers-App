import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  // Headings
  static TextStyle get font32Bold =>
      GoogleFonts.nunito(fontSize: 32.sp, fontWeight: FontWeight.bold);

  static TextStyle get font24Bold =>
      GoogleFonts.nunito(fontSize: 24.sp, fontWeight: FontWeight.bold);

  static TextStyle get font20SemiBold =>
      GoogleFonts.nunito(fontSize: 20.sp, fontWeight: FontWeight.w600);

  static TextStyle get font20Bold =>
      GoogleFonts.nunito(fontSize: 20.sp, fontWeight: FontWeight.bold);

  // Body
  static TextStyle get font18Normal =>
      GoogleFonts.nunito(fontSize: 18.sp, fontWeight: FontWeight.normal);
  static TextStyle get font16Normal =>
      GoogleFonts.nunito(fontSize: 16.sp, fontWeight: FontWeight.normal);

  static TextStyle get font14Normal =>
      GoogleFonts.nunito(fontSize: 14.sp, fontWeight: FontWeight.normal);

  // Labels & Captions
  static TextStyle get font14SemiBold =>
      GoogleFonts.nunito(fontSize: 14.sp, fontWeight: FontWeight.w500);
  static TextStyle get font12SemiBold =>
      GoogleFonts.nunito(fontSize: 12.sp, fontWeight: FontWeight.w500);

  static TextStyle get font10Normal =>
      GoogleFonts.nunito(fontSize: 10.sp, fontWeight: FontWeight.normal);
}
