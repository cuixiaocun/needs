import 'package:flutter/material.dart';
import 'package:needs_app/config/colors.dart';

/// 自定义文本输入框组件
/// 支持标签、前缀图标、后缀图标、验证器
/// 焦点状态显示深绿边框，错误状态显示红色边框
class CustomTextField extends StatefulWidget {
  final String? label;
  final String? hintText;
  final String? initialValue;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final int maxLines;
  final int minLines;
  final int? maxLength;
  final bool showCounterText;
  final String? errorText;
  final bool isPassword;
  final double height;
  final double borderRadius;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final TextStyle? textStyle;

  const CustomTextField({
    super.key,
    this.label,
    this.hintText,
    this.initialValue,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.maxLines = 1,
    this.minLines = 1,
    this.maxLength,
    this.showCounterText = false,
    this.errorText,
    this.isPassword = false,
    this.height = AppTheme.textFieldHeight,
    this.borderRadius = AppTheme.textFieldBorderRadius,
    this.labelStyle,
    this.hintStyle,
    this.textStyle,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late FocusNode _focusNode;
  late TextEditingController _controller;
  late bool _obscureText;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _controller = widget.controller ?? TextEditingController();
    _obscureText = widget.obscureText;
    _errorText = widget.errorText;

    if (widget.initialValue != null && widget.controller == null) {
      _controller.text = widget.initialValue!;
    }
  }

  @override
  void didUpdateWidget(CustomTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.errorText != oldWidget.errorText) {
      setState(() {
        _errorText = widget.errorText;
      });
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  /// 切换密码显示/隐藏
  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  /// 验证输入
  String? _validate(String? value) {
    // 首先检查外部设置的 errorText
    if (_errorText != null && _errorText!.isNotEmpty) {
      return _errorText;
    }
    // 然后运行验证器
    if (widget.validator != null) {
      return widget.validator!(value);
    }
    return null;
  }

  /// 获取边框颜色
  Color _getBorderColor(bool hasError) {
    if (hasError) {
      return AppColors.error;
    }
    if (_focusNode.hasFocus) {
      return AppColors.primaryDark;
    }
    return AppColors.border;
  }

  /// 获取边框宽度
  double _getBorderWidth(bool hasError) {
    if (hasError || _focusNode.hasFocus) {
      return AppTheme.textFieldFocusBorderWidth;
    }
    return AppTheme.textFieldBorderWidth;
  }

  @override
  Widget build(BuildContext context) {
    final errorText = _validate(_controller.text);
    final hasError = errorText != null && errorText.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标签
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              widget.label!,
              style: widget.labelStyle ??
                  const TextStyle(
                    fontSize: AppTheme.fontSizeMedium,
                    fontWeight: AppTheme.fontWeightMedium,
                    color: AppColors.textPrimary,
                  ),
            ),
          ),
        // 输入框
        SizedBox(
          height: widget.maxLines == 1 ? widget.height : null,
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            keyboardType: widget.keyboardType,
            obscureText: _obscureText,
            maxLines: widget.maxLines,
            minLines: widget.minLines,
            maxLength: widget.maxLength,
            onChanged: (value) {
              setState(() {
                _errorText = null; // 清除外部设置的错误
              });
              widget.onChanged?.call(value);
            },
            onSubmitted: widget.onSubmitted,
            style: widget.textStyle ??
                const TextStyle(
                  fontSize: AppTheme.fontSizeMedium,
                  color: AppColors.textPrimary,
                ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: widget.hintStyle ??
                  const TextStyle(
                    fontSize: AppTheme.fontSizeMedium,
                    color: AppColors.textHint,
                  ),
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                      widget.prefixIcon,
                      color: _focusNode.hasFocus
                          ? AppColors.primaryDark
                          : AppColors.textSecondary,
                    )
                  : null,
              suffixIcon: widget.isPassword
                  ? _buildPasswordToggleIcon()
                  : (widget.suffixIcon != null
                      ? Icon(
                          widget.suffixIcon,
                          color: AppColors.textSecondary,
                        )
                      : null),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                borderSide: BorderSide(
                  color: _getBorderColor(hasError),
                  width: _getBorderWidth(hasError),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                borderSide: BorderSide(
                  color: _getBorderColor(hasError),
                  width: _getBorderWidth(hasError),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                borderSide: BorderSide(
                  color: _getBorderColor(hasError),
                  width: _getBorderWidth(hasError),
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                borderSide: BorderSide(
                  color: AppColors.error,
                  width: AppTheme.textFieldFocusBorderWidth,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                borderSide: BorderSide(
                  color: AppColors.error,
                  width: AppTheme.textFieldFocusBorderWidth,
                ),
              ),
              counterText: widget.showCounterText ? null : '',
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              filled: true,
              fillColor: AppColors.white,
              errorText: hasError ? errorText : null,
              errorStyle: const TextStyle(
                fontSize: AppTheme.fontSizeSmall,
                color: AppColors.error,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 构建密码显示/隐藏按钮
  Widget _buildPasswordToggleIcon() {
    return IconButton(
      icon: Icon(
        _obscureText ? Icons.visibility_off : Icons.visibility,
        color: AppColors.textSecondary,
      ),
      onPressed: _togglePasswordVisibility,
      tooltip: _obscureText ? '显示密码' : '隐藏密码',
    );
  }
}
