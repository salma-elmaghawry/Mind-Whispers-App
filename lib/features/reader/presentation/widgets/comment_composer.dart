import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mind_whispers_app/core/helpers/spacing.dart';
import 'package:mind_whispers_app/core/widgets/app_text_field.dart';

/// Bottom-docked "add a comment" bar on [PostDetailScreen]. Note: submits
/// only via the send button — [AppTextField] doesn't expose a
/// field-submitted callback, so the keyboard's own action key is left at
/// its default rather than showing a "send" icon that would do nothing.
class CommentComposer extends StatefulWidget {
  final bool isSubmitting;
  final ValueChanged<String> onSubmit;

  const CommentComposer({super.key, required this.isSubmitting, required this.onSubmit});

  @override
  State<CommentComposer> createState() => _CommentComposerState();
}

class _CommentComposerState extends State<CommentComposer> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty || widget.isSubmitting) return;
    widget.onSubmit(text);
    _controller.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final canSend = _controller.text.trim().isNotEmpty && !widget.isSubmitting;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(12.w, 8.h, 12.w, 8.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: AppTextField(
                controller: _controller,
                label: 'comments.composer_label'.tr(),
                hint: 'comments.composer_hint'.tr(),
                onChanged: (_) => setState(() {}),
              ),
            ),
            horizontalSpace(8),
            IconButton.filled(
              onPressed: canSend ? _submit : null,
              icon: widget.isSubmitting
                  ? SizedBox(
                      width: 18.w,
                      height: 18.w,
                      child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.send_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
