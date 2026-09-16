import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mind_whispers_app/core/helpers/extensions.dart';
import 'package:mind_whispers_app/core/helpers/spacing.dart';
import 'package:mind_whispers_app/features/reader/domain/entities/category.dart';


class CategoryChipsBar extends StatelessWidget {
  final List<Category> categories;
  final String? selectedCategorySlug;
  final ValueChanged<String?> onSelected;

  const CategoryChipsBar({
    super.key,
    required this.categories,
    required this.selectedCategorySlug,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length + 1,
        separatorBuilder: (_, _) => horizontalSpace(8),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _Pill(
              label: 'feed.all_categories'.tr(),
              selected: selectedCategorySlug == null,
              onTap: () => onSelected(null),
            );
          }
          final category = categories[index - 1];
          return _Pill(
            label: category.name,
            selected: selectedCategorySlug == category.slug,
            color: category.color.toColor(),
            onTap: () => onSelected(category.slug),
          );
        },
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final bool selected;


  final Color? color;
  final VoidCallback onTap;

  const _Pill({required this.label, required this.selected, this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final selectedColor = color ?? colorScheme.secondary;
  
    final onSelectedColor = ThemeData.estimateBrightnessForColor(selectedColor) == Brightness.dark
        ? Colors.white
        : Colors.black;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(horizontal: 18.w),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? selectedColor : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          label,
          style: textTheme.labelLarge?.copyWith(
            color: selected ? onSelectedColor : colorScheme.onSurface.withValues(alpha: 0.7),
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
