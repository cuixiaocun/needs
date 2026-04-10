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
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late GlobalKey<FormState> _formKey;

  String? _emailError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    _authController = Get.find<AuthController>();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _formKey = GlobalKey<FormState>();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// 验证邮箱格式
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return '邮箱不能为空';
    }
    // 基本的邮箱格式检查
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(value)) {
      return '邮箱格式不正确';
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
      _emailError = null;
      _passwordError = null;
    });

    // 验证表单
    final emailValidation = _validateEmail(_emailController.text);
    final passwordValidation = _validatePassword(_passwordController.text);

    if (emailValidation != null || passwordValidation != null) {
      setState(() {
        _emailError = emailValidation;
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
        email: _emailController.text.trim(),
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
                  : '登录失败，请检查邮箱和密码后重试',
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
                  '输入邮箱和密码以继续',
                  style: TextStyle(
                    fontSize: AppTheme.fontSizeMedium,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),

                // 邮箱输入框
                CustomTextField(
                  label: '邮箱地址',
                  hintText: '请输入邮箱',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  errorText: _emailError,
                  onChanged: (value) {
                    setState(() {
                      _emailError = null;
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
