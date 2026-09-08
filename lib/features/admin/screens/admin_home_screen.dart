import 'package:flutter/material.dart';
import 'package:mind_whispers_app/core/auth/app_role.dart';
import 'package:mind_whispers_app/core/theme/app_colors.dart';
import 'package:mind_whispers_app/core/widgets/role_home_placeholder.dart';

/// Placeholder until the admin web dashboard lands (Day 9-11): shell,
/// users management, content moderation.
class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const RoleHomePlaceholder(
      role: AppRole.admin,
      accentColor: AppColors.roleAdmin,
    );
  }
}
