import 'package:flutter/cupertino.dart';
import 'package:mind_whispers_app/core/animations/app_animations.dart';
import 'package:mind_whispers_app/core/const/app_assets.dart';
import 'package:mind_whispers_app/core/theme/app_colors.dart';

Widget centeredCupertinoLoader({Color? color, double size = 30}) {
  return Center(
    child: SizedBox(
      width: size,
      height: size,
      child: CupertinoActivityIndicator(
        color: color ?? AppColors.primary,
        radius: size / 2,
      ),
    ),
  );
}

//add logo image
Widget AddlogoPng() {
  return Image.asset(AppAssets.logoPng, width: 150, height: 150).fadeInScale();
}
