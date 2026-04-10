import 'package:flutter/material.dart';

/// 应用颜色定义
class AppColors {
  // 主色系
  static const Color primary = Color(0xFF27AE60);
  static const Color primaryDark = Color(0xFF1E8449);
  static const Color primaryLight = Color(0xFF52BE80);

  // 辅助色系
  static const Color secondary = Color(0xFF3498DB);
  static const Color secondaryLight = Color(0xFF5DADE2);

  // 错误色
  static const Color error = Color(0xFFE74C3C);
  static const Color errorLight = Color(0xFFF5B7B1);

  // 成功色
  static const Color success = Color(0xFF27AE60);

  // 警告色
  static const Color warning = Color(0xFFF39C12);

  // 灰色系
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF7F8C8D);
  static const Color textHint = Color(0xFFBDC3C7);
  static const Color border = Color(0xFFECF0F1);
  static const Color borderDark = Color(0xFFD5DBDB);
  static const Color background = Color(0xFFFAFAFA);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // 透明色
  static const Color transparent = Color(0x00000000);

  // 阴影色
  static const Color shadowColor = Color(0x1A000000); // Black with 0.1 opacity
}

/// 应用主题
class AppTheme {
  // 按钮尺寸
  static const double buttonHeight = 56.0;
  static const double buttonBorderRadius = 12.0;
  static const double buttonIconSize = 20.0;
  static const double buttonFontSize = 16.0;

  // 输入框尺寸
  static const double textFieldHeight = 56.0;
  static const double textFieldBorderRadius = 12.0;
  static const double textFieldBorderWidth = 1.0;
  static const double textFieldFocusBorderWidth = 2.0;
  static const double textFieldFontSize = 14.0;

  // 卡片尺寸
  static const double cardBorderRadius = 12.0;
  static const double cardBorderWidth = 1.0;
  static const double cardElevation = 0.5;
  static const double cardPaddingHorizontal = 16.0;
  static const double cardPaddingVertical = 12.0;

  // 间距
  static const double paddingXSmall = 4.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  // 圆角
  static const double radiusSmall = 4.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 12.0;
  static const double radiusXLarge = 16.0;

  // 字体大小
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 14.0;
  static const double fontSizeLarge = 16.0;
  static const double fontSizeXLarge = 18.0;
  static const double fontSizeTitle = 20.0;

  // 字重
  static const FontWeight fontWeightLight = FontWeight.w300;
  static const FontWeight fontWeightNormal = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightSemiBold = FontWeight.w600;
  static const FontWeight fontWeightBold = FontWeight.w700;
}
