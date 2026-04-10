import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:needs_app/config/colors.dart';
import 'package:needs_app/controllers/auth_controller.dart';
import 'package:needs_app/routes/app_routes.dart';
import 'package:needs_app/widgets/common/custom_button.dart';
import 'package:needs_app/widgets/common/custom_text_field.dart';
import 'package:needs_app/widgets/common/loading_dialog.dart';
import 'package:needs_app/widgets/common/error_dialog.dart';

/// 注册页面
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late AuthController _authController;
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _passwordController;
  late TextEditingController _passwordConfirmController;
  late GlobalKey<FormState> _formKey;

  String? _nameError;
  String? _emailError;
  String? _phoneError;
  String? _passwordError;
  String? _passwordConfirmError;

  String _selectedRole = 'farmer'; // 默认选择农户

  @override
  void initState() {
    super.initState();
    _authController = Get.find<AuthController>();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
    _passwordConfirmController = TextEditingController();
    _formKey = GlobalKey<FormState>();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  /// 验证姓名
  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return '姓名不能为空';
    }
    if (value.length < 2) {
      return '姓名至少需要 2 个字符';
    }
    return null;
  }

  /// 验证邮箱格式（可选）
  String? _validateEmail(String? value) {
    // 邮箱是可选的，但如果填写了就要符合格式
    if (value != null && value.isNotEmpty) {
      final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
      if (!emailRegex.hasMatch(value)) {
        return '邮箱格式不正确';
      }
    }
    return null;
  }

  /// 验证手机号
  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return '手机号不能为空';
    }
    // 中国手机号基本验证
    final phoneRegex = RegExp(r'^1[3-9]\d{9}$');
    if (!phoneRegex.hasMatch(value)) {
      return '请输入有效的手机号';
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

  /// 验证确认密码
  String? _validatePasswordConfirm(String? value) {
    if (value == null || value.isEmpty) {
      return '确认密码不能为空';
    }
    if (value != _passwordController.text) {
      return '两次输入的密码不一致';
    }
    return null;
  }

  /// 执行注册
  Future<void> _performRegister() async {
    // 清除之前的错误信息
    setState(() {
      _nameError = null;
      _emailError = null;
      _phoneError = null;
      _passwordError = null;
      _passwordConfirmError = null;
    });

    // 验证表单
    final nameValidation = _validateName(_nameController.text);
    final phoneValidation = _validatePhone(_phoneController.text);
    final emailValidation = _validateEmail(_emailController.text);
    final passwordValidation = _validatePassword(_passwordController.text);
    final passwordConfirmValidation =
        _validatePasswordConfirm(_passwordConfirmController.text);

    if (nameValidation != null ||
        phoneValidation != null ||
        emailValidation != null ||
        passwordValidation != null ||
        passwordConfirmValidation != null) {
      setState(() {
        _nameError = nameValidation;
        _phoneError = phoneValidation;
        _emailError = emailValidation;
        _passwordError = passwordValidation;
        _passwordConfirmError = passwordConfirmValidation;
      });
      return;
    }

    // 显示加载对话框
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const LoadingDialog(message: '注册中...'),
    );

    try {
      // 调用注册方法
      final success = await _authController.register(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
        passwordConfirmation: _passwordConfirmController.text,
        role: _selectedRole,
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      );

      if (mounted) {
        // 关闭加载对话框
        Navigator.of(context).pop();

        if (success) {
          // 注册成功，跳转到首页
          Get.offNamed(Routes.home);
        } else {
          // 注册失败，显示错误对话框
          showDialog(
            context: context,
            builder: (context) => ErrorDialog(
              title: '注册失败',
              message: _authController.errorMessage.value.isNotEmpty
                  ? _authController.errorMessage.value
                  : '注册失败，请稍后重试',
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
            title: '注册失败',
            message: '发生了一个错误: ${e.toString()}',
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题
                Text(
                  '创建账号',
                  style: const TextStyle(
                    fontSize: AppTheme.fontSizeTitle,
                    fontWeight: AppTheme.fontWeightBold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                // 副标题
                Text(
                  '成为 Needs 平台的一员',
                  style: TextStyle(
                    fontSize: AppTheme.fontSizeMedium,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 28),

                // 姓名输入框
                CustomTextField(
                  label: '姓名',
                  hintText: '请输入您的姓名',
                  controller: _nameController,
                  prefixIcon: Icons.person_outline,
                  errorText: _nameError,
                  onChanged: (value) {
                    setState(() {
                      _nameError = null;
                    });
                  },
                ),
                const SizedBox(height: 18),

                // 手机号输入框（必填）
                CustomTextField(
                  label: '手机号 *',
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
                const SizedBox(height: 18),

                // 邮箱输入框（可选）
                CustomTextField(
                  label: '邮箱地址（选填）',
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
                const SizedBox(height: 18),

                // 身份选择
                Text(
                  '选择身份',
                  style: const TextStyle(
                    fontSize: AppTheme.fontSizeMedium,
                    fontWeight: AppTheme.fontWeightMedium,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildRoleButton('farmer', '农户'),
                    const SizedBox(width: 12),
                    _buildRoleButton('buyer', '买家'),
                    const SizedBox(width: 12),
                    _buildRoleButton('agent', '工作人员'),
                  ],
                ),
                const SizedBox(height: 24),

                // 密码输入框
                CustomTextField(
                  label: '密码',
                  hintText: '至少 6 个字符',
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
                const SizedBox(height: 18),

                // 确认密码输入框
                CustomTextField(
                  label: '确认密码',
                  hintText: '再次输入密码',
                  controller: _passwordConfirmController,
                  obscureText: true,
                  isPassword: true,
                  prefixIcon: Icons.lock_outline,
                  errorText: _passwordConfirmError,
                  onChanged: (value) {
                    setState(() {
                      _passwordConfirmError = null;
                    });
                  },
                ),
                const SizedBox(height: 28),

                // 注册按钮
                SizedBox(
                  width: double.infinity,
                  child: Obx(() {
                    return CustomButton(
                      label: '注册',
                      icon: Icons.app_registration,
                      isPrimary: true,
                      isLoading: _authController.isLoading.value,
                      isEnabled: !_authController.isLoading.value,
                      onPressed: _performRegister,
                    );
                  }),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建身份选择按钮
  Widget _buildRoleButton(String role, String label) {
    final isSelected = _selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedRole = role;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.white,
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppTheme.fontSizeMedium,
              fontWeight: AppTheme.fontWeightMedium,
              color: isSelected ? AppColors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
