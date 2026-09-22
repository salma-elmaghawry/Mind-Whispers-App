import 'package:flutter/material.dart';
import 'package:mind_whispers_app/core/auth/app_role.dart';
import 'package:mind_whispers_app/core/theme/app_colors.dart';
import 'package:mind_whispers_app/core/widgets/role_home_placeholder.dart';

class AuthorHomeScreen extends StatelessWidget {
  const AuthorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const RoleHomePlaceholder(
      role: AppRole.author,
      accentColor: AppColors.roleAuthor,
    );
  }
}
