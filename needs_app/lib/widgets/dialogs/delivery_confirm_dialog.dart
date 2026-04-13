import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/colors.dart';

/// 交货确认对话框
/// 显示交货地点和运费，用户确认后将触发支付流程
class DeliveryConfirmDialog extends StatelessWidget {
  final int orderId;
  final double orderAmount;
  final double deliveryFee;
  final VoidCallback onConfirmed;

  const DeliveryConfirmDialog({
    super.key,
    required this.orderId,
    required this.orderAmount,
    required this.deliveryFee,
    required this.onConfirmed,
  });

  @override
  Widget build(BuildContext context) {
    final totalAmount = orderAmount + deliveryFee;

    return AlertDialog(
      title: const Text('确认交货信息'),
      contentPadding: const EdgeInsets.all(24),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('📍 交货地点', '集散市场中转'),
            const SizedBox(height: 16),
            _buildInfoRow('📦 运费', '¥${deliveryFee.toStringAsFixed(2)}'),
            const Divider(height: 24),
            _buildTotalRow('合计金额', totalAmount),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('返回'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirmed();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: const Text('确认并支付'),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildTotalRow(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text(
          '¥${amount.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
      ],
    );
  }
}
