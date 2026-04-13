import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:needs_app/config/colors.dart';
import 'package:needs_app/controllers/auth_controller.dart';
import 'package:needs_app/screens/home/home_controller.dart';
import 'package:needs_app/screens/order/order_list_screen.dart';
import 'package:needs_app/screens/order/order_create_screen.dart';
import 'package:needs_app/screens/wallet/wallet_screen.dart';
import 'package:needs_app/screens/profile/profile_screen.dart';
import 'package:needs_app/widgets/common/custom_card.dart';

/// 首页 - 主应用屏幕
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.put(HomeController());
    final authController = Get.find<AuthController>();

    // 四个 Tab 页面
    final List<Widget> pages = [
      _buildHomePage(authController),
      const OrderListScreen(),
      const WalletScreen(),
      const ProfileScreen(),
    ];

    return Obx(
      () => Scaffold(
        body: pages[homeController.currentTabIndex.value],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: homeController.currentTabIndex.value,
          onTap: homeController.changeTab,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: '首页',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_outlined),
              activeIcon: Icon(Icons.shopping_bag),
              label: '订单',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_outlined),
              activeIcon: Icon(Icons.account_balance_wallet),
              label: '钱包',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outlined),
              activeIcon: Icon(Icons.person),
              label: '我的',
            ),
          ],
        ),
      ),
    );
  }

  /// 构建首页内容
  Widget _buildHomePage(AuthController authController) {
    return Obx(
      () {
        final user = authController.getCurrentUser();
        final userName = user?['name'] ?? '用户';
        final greeting = _getGreeting();

        return Scaffold(
          appBar: AppBar(
            title: const Text('农产品供需撮合平台'),
            elevation: 0,
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 欢迎区域
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '欢迎，$userName',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$greeting，祝你有美好的一天',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 发布订单卡片
                InkWell(
                  onTap: () => Get.to(() => const OrderCreateScreen()),
                  child: Card(
                    color: Colors.blue[50],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.blue[200]!),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.add_circle, size: 32, color: Colors.blue[700]),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('发布订单', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text('发布供应单或需求单，快速找到你的交易伙伴', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward, color: Colors.blue[700]),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 快捷操作按钮
                const Text(
                  '快速操作',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: [
                    _buildQuickActionButton(
                      icon: Icons.add_circle_outline,
                      label: '发布订单',
                      onTap: () {
                        Get.snackbar('提示', '发布订单功能开发中');
                      },
                    ),
                    _buildQuickActionButton(
                      icon: Icons.list_alt,
                      label: '我的订单',
                      onTap: () {
                        // 切换到订单 Tab
                        Get.find<HomeController>().changeTab(1);
                      },
                    ),
                    _buildQuickActionButton(
                      icon: Icons.security,
                      label: '保证金',
                      onTap: () {
                        Get.snackbar('提示', '保证金管理功能开发中');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 数据统计
                const Text(
                  '我的统计',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: CustomCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '待匹配订单',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '0',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '本周收入',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '¥ 0.00',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 构建快捷操作按钮
  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return CustomCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 32,
            color: AppColors.primary,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  /// 获取时间问候
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return '上午好';
    } else if (hour < 18) {
      return '下午好';
    } else {
      return '晚上好';
    }
  }
}
