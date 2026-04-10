import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:needs_app/controllers/auth_controller.dart';
import 'package:needs_app/config/colors.dart';

/// 个人资料页面
/// 显示用户的基本信息和设置选项
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('个人资料'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Obx(
        () {
          final user = authController.getCurrentUser();
          if (user == null) {
            return Center(
              child: Text(
                '未登录',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // 用户头像和基本信息
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                      ),
                      child: Center(
                        child: Text(
                          (user['name'] as String).isNotEmpty
                              ? (user['name'] as String)[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user['name'] ?? '未知用户',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user['email'] ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // 用户信息项
              _buildInfoItem('角色', user['role'] ?? '未知'),
              if (user['phone'] != null)
                _buildInfoItem('手机', user['phone'] ?? ''),
              _buildInfoItem('账户状态', '活跃'),

              const SizedBox(height: 32),

              // 登出按钮
              ElevatedButton.icon(
                onPressed: () {
                  Get.defaultDialog(
                    title: '确认登出',
                    middleText: '您确定要登出吗？',
                    confirm: ElevatedButton(
                      onPressed: () {
                        authController.logout();
                        Get.back();
                      },
                      child: const Text('确定'),
                    ),
                    cancel: TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('取消'),
                    ),
                  );
                },
                icon: const Icon(Icons.logout),
                label: const Text('登出'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// 构建信息项
  Widget _buildInfoItem(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
