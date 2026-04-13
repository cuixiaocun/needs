import 'package:flutter/material.dart';
import '../../config/colors.dart';

/// 成交确认对话框
/// 用于 AI 匹配卡片中的成交确认
class ConfirmTradeDialog extends StatelessWidget {
  final String counterpartyName;
  final String productName;
  final double quantity;
  final String unit;
  final double pricePerUnit;
  final VoidCallback onConfirmed;
  final VoidCallback onCancel;

  const ConfirmTradeDialog({
    super.key,
    required this.counterpartyName,
    required this.productName,
    required this.quantity,
    required this.unit,
    required this.pricePerUnit,
    required this.onConfirmed,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final totalAmount = quantity * pricePerUnit;

    return AlertDialog(
      title: const Text('确认成交'),
      contentPadding: const EdgeInsets.all(24),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 对方信息
            Text(
              '确认与 $counterpartyName 成交',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // 商品信息
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('商品', productName),
                  const SizedBox(height: 8),
                  _buildInfoRow('数量', '$quantity $unit'),
                  const SizedBox(height: 8),
                  _buildInfoRow('单价', '¥$pricePerUnit/$unit'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 合计
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange, width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '合计金额',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '¥${totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onCancel();
          },
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
          child: const Text('确认成交'),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
