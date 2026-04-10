import 'package:flutter/material.dart';
import 'package:needs_app/config/colors.dart';

/// 自定义按钮组件
/// 支持主操作按钮（isPrimary=true）和次操作按钮（isPrimary=false）
/// 支持 icon + label、loading 状态、disabled 状态
class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final IconData? icon;
  final bool isLoading;
  final bool isEnabled;
  final double? width;
  final double height;
  final double borderRadius;
  final TextStyle? textStyle;
  final EdgeInsets? padding;

  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isPrimary = true,
    this.icon,
    this.isLoading = false,
    this.isEnabled = true,
    this.width,
    this.height = AppTheme.buttonHeight,
    this.borderRadius = AppTheme.buttonBorderRadius,
    this.textStyle,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = isLoading || !isEnabled;
    final Color backgroundColor = _getBackgroundColor();
    final Color foregroundColor = _getForegroundColor();

    return SizedBox(
      width: width,
      height: height,
      child: isPrimary
          ? _buildPrimaryButton(backgroundColor, foregroundColor, isDisabled)
          : _buildSecondaryButton(foregroundColor, isDisabled),
    );
  }

  /// 构建主操作按钮
  Widget _buildPrimaryButton(
    Color backgroundColor,
    Color foregroundColor,
    bool isDisabled,
  ) {
    return ElevatedButton(
      onPressed: isDisabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        disabledBackgroundColor: AppColors.border,
        disabledForegroundColor: AppColors.textSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        elevation: 0,
        padding: padding ?? EdgeInsets.zero,
      ),
      child: _buildButtonContent(foregroundColor),
    );
  }

  /// 构建次操作按钮
  Widget _buildSecondaryButton(
    Color foregroundColor,
    bool isDisabled,
  ) {
    return OutlinedButton(
      onPressed: isDisabled ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: foregroundColor,
        disabledForegroundColor: AppColors.textSecondary,
        side: BorderSide(
          color: isDisabled ? AppColors.border : AppColors.primaryDark,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        padding: padding ?? EdgeInsets.zero,
      ),
      child: _buildButtonContent(foregroundColor),
    );
  }

  /// 构建按钮内容（icon + label 或 loading indicator）
  Widget _buildButtonContent(Color foregroundColor) {
    if (isLoading) {
      return SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppTheme.buttonIconSize),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: textStyle ??
                  TextStyle(
                    fontSize: AppTheme.buttonFontSize,
                    fontWeight: AppTheme.fontWeightMedium,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    return Text(
      label,
      style: textStyle ??
          TextStyle(
            fontSize: AppTheme.buttonFontSize,
            fontWeight: AppTheme.fontWeightMedium,
          ),
    );
  }

  /// 获取背景色
  Color _getBackgroundColor() {
    if (!isPrimary) {
      return Colors.transparent;
    }
    if (isLoading || !isEnabled) {
      return AppColors.border;
    }
    return AppColors.primaryDark;
  }

  /// 获取前景色（文字或图标颜色）
  Color _getForegroundColor() {
    if (isPrimary) {
      return AppColors.white;
    }
    if (isLoading || !isEnabled) {
      return AppColors.textSecondary;
    }
    return AppColors.primaryDark;
  }
}
