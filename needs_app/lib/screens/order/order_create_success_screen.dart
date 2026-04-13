import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:needs_app/config/colors.dart';
import 'package:needs_app/screens/order/order_detail_screen.dart';
import 'package:needs_app/screens/order/order_list_screen.dart';

/// 订单创建成功确认页面
/// 显示订单发布成功的确认信息，以及订单摘要信息
class OrderCreateSuccessScreen extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderCreateSuccessScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('发布成功'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 成功图标
              Icon(
                Icons.check_circle,
                size: 80,
                color: Colors.green,
              ),
              const SizedBox(height: 24),

              // 标题
              const Text(
                '订单发布成功！',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),

              // 副标题
              Text(
                _getSubtitle(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // 订单摘要卡片
              _buildOrderSummaryCard(),
              const SizedBox(height: 32),

              // 操作按钮
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.offAll(() => const OrderListScreen()),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        '返回订单列表',
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.off(
                        () => OrderDetailScreen(
                          orderId: order['id'] as int,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('查看订单详情'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 获取副标题文本
  String _getSubtitle() {
    final type = order['type'] as String?;
    if (type == 'sell') {
      return '您的供应单已成功发布，等待买家联系';
    } else {
      return '您的需求单已成功发布，等待卖家联系';
    }
  }

  /// 构建订单摘要卡片
  Widget _buildOrderSummaryCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(
          color: Color(0xFFECF0F1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '订单摘要',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            _buildSummaryRow('产品', order['product_name'] as String?),
            const SizedBox(height: 8),
            _buildSummaryRow(
              '数量',
              '${order['quantity']} ${order['unit']}',
            ),
            const SizedBox(height: 8),
            _buildSummaryRow(
              '单价',
              '¥${order['price_per_unit']}',
            ),
            const SizedBox(height: 8),
            _buildSummaryRow(
              '品质等级',
              order['quality_level'] as String?,
            ),
            const SizedBox(height: 12),
            Divider(
              height: 1,
              color: AppColors.border,
            ),
            const SizedBox(height: 12),
            _buildSummaryRow(
              '总金额',
              _calculateTotalAmount(),
              highlight: true,
            ),
          ],
        ),
      ),
    );
  }

  /// 计算总金额
  String _calculateTotalAmount() {
    final quantity = double.parse(order['quantity'].toString());
    final pricePerUnit = double.parse(order['price_per_unit'].toString());
    final total = quantity * pricePerUnit;
    return '¥${total.toStringAsFixed(2)}';
  }

  /// 构建摘要行
  Widget _buildSummaryRow(
    String label,
    String? value, {
    bool highlight = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value ?? '-',
          style: TextStyle(
            fontSize: 14,
            fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
            color: highlight ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
