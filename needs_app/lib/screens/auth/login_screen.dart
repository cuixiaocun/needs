import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:needs_app/config/colors.dart';
import 'package:needs_app/controllers/auth_controller.dart';
import 'package:needs_app/routes/app_routes.dart';
import 'package:needs_app/widgets/common/custom_button.dart';
import 'package:needs_app/widgets/common/custom_text_field.dart';
import 'package:needs_app/widgets/common/loading_dialog.dart';
import 'package:needs_app/widgets/common/error_dialog.dart';

/// 登录页面
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late AuthController _authController;
  late TextEditingController _phoneController;
  late TextEditingController _passwordController;
  late GlobalKey<FormState> _formKey;

  String? _phoneError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    _authController = Get.find<AuthController>();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
    _formKey = GlobalKey<FormState>();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// 验证手机号格式
  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return '手机号不能为空';
    }
    // 中国手机号格式检查
    final phoneRegex = RegExp(r'^1[3-9]\d{9}$');
    if (!phoneRegex.hasMatch(value)) {
      return '手机号格式不正确';
    }
    return null;
  }

  /// 验证密码
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '密码不能为空';
    }
    if (value.length < 6) {
      return '密码至少需要 6 个字符';
    }
    return null;
  }

  /// 执行登录
  Future<void> _performLogin() async {
    // 清除之前的错误信息
    setState(() {
      _phoneError = null;
      _passwordError = null;
    });

    // 验证表单
    final phoneValidation = _validatePhone(_phoneController.text);
    final passwordValidation = _validatePassword(_passwordController.text);

    if (phoneValidation != null || passwordValidation != null) {
      setState(() {
        _phoneError = phoneValidation;
        _passwordError = passwordValidation;
      });
      return;
    }

    // 显示加载对话框
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const LoadingDialog(message: '登录中...'),
    );

    try {
      // 调用登录方法
      final success = await _authController.login(
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        // 关闭加载对话框
        Navigator.of(context).pop();

        if (success) {
          // 登录成功，跳转到首页
          Get.offNamed(Routes.home);
        } else {
          // 登录失败，显示错误对话框
          showDialog(
            context: context,
            builder: (context) => ErrorDialog(
              title: '登录失败',
              message: _authController.errorMessage.value.isNotEmpty
                  ? _authController.errorMessage.value
                  : '登录失败，请检查手机号和密码后重试',
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        // 关闭加载对话框
        Navigator.of(context).pop();

        // 显示错误对话框
        showDialog(
          context: context,
          builder: (context) => ErrorDialog(
            title: '登录失败',
            message: '发生了一个错误: ${e.toString()}',
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题
                Text(
                  '欢迎登录',
                  style: const TextStyle(
                    fontSize: AppTheme.fontSizeTitle,
                    fontWeight: AppTheme.fontWeightBold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                // 副标题
                Text(
                  '输入手机号和密码以继续',
                  style: TextStyle(
                    fontSize: AppTheme.fontSizeMedium,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),

                // 手机号输入框
                CustomTextField(
                  label: '手机号码',
                  hintText: '请输入手机号',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_outlined,
                  errorText: _phoneError,
                  onChanged: (value) {
                    setState(() {
                      _phoneError = null;
                    });
                  },
                ),
                const SizedBox(height: 20),

                // 密码输入框
                CustomTextField(
                  label: '密码',
                  hintText: '请输入密码',
                  controller: _passwordController,
                  obscureText: true,
                  isPassword: true,
                  prefixIcon: Icons.lock_outline,
                  errorText: _passwordError,
                  onChanged: (value) {
                    setState(() {
                      _passwordError = null;
                    });
                  },
                ),
                const SizedBox(height: 28),

                // 登录按钮
                SizedBox(
                  width: double.infinity,
                  child: Obx(() {
                    return CustomButton(
                      label: '登录',
                      icon: Icons.login,
                      isPrimary: true,
                      isLoading: _authController.isLoading.value,
                      isEnabled: !_authController.isLoading.value,
                      onPressed: _performLogin,
                    );
                  }),
                ),
                const SizedBox(height: 20),

                // 注册链接
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '还没有账号？',
                      style: TextStyle(
                        fontSize: AppTheme.fontSizeMedium,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => Get.toNamed(Routes.register),
                      child: Text(
                        '立即注册',
                        style: const TextStyle(
                          fontSize: AppTheme.fontSizeMedium,
                          fontWeight: AppTheme.fontWeightMedium,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
