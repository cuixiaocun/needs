import 'package:flutter/material.dart';
import 'package:needs_app/config/colors.dart';

/// 加载对话框
/// 显示中央圆形加载动画 + 文字
class LoadingDialog extends StatelessWidget {
  final String message;

  const LoadingDialog({
    super.key,
    this.message = '加载中...',
  });

  /// 显示加载对话框
  static Future<void> show(
    BuildContext context, {
    String message = '加载中...',
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return LoadingDialog(message: message);
      },
    );
  }

  /// 隐藏加载对话框
  static void hide(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32.0),
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 加载动画
              SizedBox(
                width: 48.0,
                height: 48.0,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primaryDark,
                  ),
                  strokeWidth: 4.0,
                ),
              ),
              const SizedBox(height: 16.0),
              // 加载文案
              Text(
                message,
                style: const TextStyle(
                  fontSize: AppTheme.fontSizeMedium,
                  color: AppColors.textPrimary,
                  fontWeight: AppTheme.fontWeightMedium,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
