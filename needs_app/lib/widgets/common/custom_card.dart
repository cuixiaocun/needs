import 'package:flutter/material.dart';
import 'package:needs_app/config/colors.dart';

/// 自定义卡片组件
/// 纯白背景、1dp 浅灰边框、12dp 圆角、0.5dp 阴影
/// 支持 onTap、padding、InkWell 触碰反馈
class CustomCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double borderRadius;
  final double elevation;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;

  const CustomCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.borderRadius = AppTheme.cardBorderRadius,
    this.elevation = AppTheme.cardElevation,
    this.backgroundColor = AppColors.white,
    this.borderColor = AppColors.border,
    this.borderWidth = AppTheme.cardBorderWidth,
  });

  @override
  Widget build(BuildContext context) {
    final cardContent = Container(
      padding: padding ??
          const EdgeInsets.symmetric(
            horizontal: AppTheme.cardPaddingHorizontal,
            vertical: AppTheme.cardPaddingVertical,
          ),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: elevation,
            spreadRadius: 0,
            offset: Offset(0, elevation / 2),
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return Container(
        margin: margin,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(borderRadius),
            child: cardContent,
          ),
        ),
      );
    }

    return Container(
      margin: margin,
      child: cardContent,
    );
  }
}
