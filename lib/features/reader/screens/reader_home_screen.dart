import 'package:flutter/material.dart';
import 'package:mind_whispers_app/core/auth/app_role.dart';
import 'package:mind_whispers_app/core/theme/app_colors.dart';
import 'package:mind_whispers_app/core/widgets/role_home_placeholder.dart';

/// Placeholder until the reader experience lands (Day 4-6): feed, post
/// detail, comments, profile & settings.
class ReaderHomeScreen extends StatelessWidget {
  const ReaderHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const RoleHomePlaceholder(
      role: AppRole.reader,
      accentColor: AppColors.roleReader,
    );
  }
}
