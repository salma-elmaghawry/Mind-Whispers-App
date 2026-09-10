import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  // Headings — Playfair Display, per the Mind Whispers brand type pairing
  static TextStyle get font32Bold =>
      GoogleFonts.playfairDisplay(fontSize: 32.sp, fontWeight: FontWeight.bold);

  static TextStyle get font24Bold =>
      GoogleFonts.playfairDisplay(fontSize: 24.sp, fontWeight: FontWeight.bold);

  static TextStyle get font20SemiBold =>
      GoogleFonts.playfairDisplay(fontSize: 20.sp, fontWeight: FontWeight.w600);

  static TextStyle get font20Bold =>
      GoogleFonts.playfairDisplay(fontSize: 20.sp, fontWeight: FontWeight.bold);

  // Body — Inter, per the Mind Whispers brand type pairing
  static TextStyle get font18Normal =>
      GoogleFonts.inter(fontSize: 18.sp, fontWeight: FontWeight.normal);
  static TextStyle get font16Normal =>
      GoogleFonts.inter(fontSize: 16.sp, fontWeight: FontWeight.normal);

  static TextStyle get font14Normal =>
      GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.normal);

  // Labels & Captions
  static TextStyle get font14SemiBold =>
      GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.w500);
  static TextStyle get font12SemiBold =>
      GoogleFonts.inter(fontSize: 12.sp, fontWeight: FontWeight.w500);

  static TextStyle get font10Normal =>
      GoogleFonts.inter(fontSize: 10.sp, fontWeight: FontWeight.normal);
}
