import 'package:flutter/material.dart';
import 'package:needs_app/config/colors.dart';
import 'custom_button.dart';

/// 错误对话框
class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmButtonText;
  final VoidCallback? onConfirm;

  const ErrorDialog({
    super.key,
    this.title = '错误',
    required this.message,
    this.confirmButtonText = '确认',
    this.onConfirm,
  });

  /// 显示错误对话框
  static Future<void> show(
    BuildContext context, {
    String title = '错误',
    required String message,
    String confirmButtonText = '确认',
    VoidCallback? onConfirm,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ErrorDialog(
          title: title,
          message: message,
          confirmButtonText: confirmButtonText,
          onConfirm: onConfirm,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor,
                blurRadius: 8.0,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题
              Text(
                title,
                style: const TextStyle(
                  fontSize: AppTheme.fontSizeXLarge,
                  fontWeight: AppTheme.fontWeightSemiBold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16.0),
              // 错误图标和消息
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppColors.error,
                    size: 24.0,
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Text(
                      message,
                      style: const TextStyle(
                        fontSize: AppTheme.fontSizeMedium,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24.0),
              // 确认按钮
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  label: confirmButtonText,
                  isPrimary: true,
                  onPressed: () {
                    Navigator.of(context).pop();
                    onConfirm?.call();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
