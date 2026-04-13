import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/colors.dart';
import '../../services/payment_service.dart';

/// 支付弹窗
/// 显示支付宝链接和支付状态
class PaymentBottomSheet extends StatefulWidget {
  final int orderId;
  final double orderAmount;
  final double deliveryFee;
  final VoidCallback? onPaymentSuccess;

  const PaymentBottomSheet({
    super.key,
    required this.orderId,
    required this.orderAmount,
    required this.deliveryFee,
    this.onPaymentSuccess,
  });

  @override
  State<PaymentBottomSheet> createState() => _PaymentBottomSheetState();
}

class _PaymentBottomSheetState extends State<PaymentBottomSheet> {
  final PaymentService _paymentService = PaymentService();

  bool _isLoading = false;
  bool _isCheckingStatus = false;
  String? _paymentUrl;
  String? _errorMessage;
  bool _paymentSuccess = false;

  @override
  void initState() {
    super.initState();
    _generatePaymentLink();
  }

  Future<void> _generatePaymentLink() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _paymentService.createAlipayment(widget.orderId);
      if (result['success']) {
        setState(() {
          _paymentUrl = result['payment_url'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result['message'] ?? '生成支付链接失败';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '错误：${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _launchPayment() async {
    if (_paymentUrl == null) return;

    if (await canLaunchUrl(Uri.parse(_paymentUrl!))) {
      await launchUrl(Uri.parse(_paymentUrl!), mode: LaunchMode.externalApplication);

      // 启动状态轮询
      _checkPaymentStatus();
    } else {
      Get.snackbar('错误', '无法打开支付链接');
    }
  }

  Future<void> _checkPaymentStatus() async {
    setState(() {
      _isCheckingStatus = true;
    });

    int attempts = 0;
    const maxAttempts = 30; // 5 分钟，每 10 秒检查一次

    while (attempts < maxAttempts) {
      await Future.delayed(const Duration(seconds: 10));

      try {
        final result = await _paymentService.checkPaymentStatus(widget.orderId);

        if (result['success'] && result['order_status'] == 'confirmed') {
          setState(() {
            _paymentSuccess = true;
            _isCheckingStatus = false;
          });
          widget.onPaymentSuccess?.call();
          return;
        }
      } catch (e) {
        // 继续轮询
      }

      attempts++;
    }

    setState(() {
      _isCheckingStatus = false;
      _errorMessage = '支付状态检查超时，请手动检查订单';
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalAmount = widget.orderAmount + widget.deliveryFee;

    return DraggableScrollableSheet(
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题
                  const Text(
                    '确认支付',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),

                  // 成功状态
                  if (_paymentSuccess) ...[
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green, width: 1),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green, size: 48),
                          const SizedBox(height: 12),
                          const Text(
                            '支付成功',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '订单已确认，请等待交货',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(48),
                            ),
                            child: const Text('返回'),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // 费用明细
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          _buildPaymentRow('订单金额', widget.orderAmount),
                          const Divider(height: 16),
                          _buildPaymentRow('运费', widget.deliveryFee),
                          const Divider(height: 16),
                          _buildPaymentRow('合计', totalAmount, isBold: true, isRed: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 错误信息
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red, width: 1),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(color: Colors.red, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // 加载状态
                    if (_isLoading) ...[
                      Container(
                        padding: const EdgeInsets.all(24),
                        child: const CircularProgressIndicator(),
                      ),
                      const SizedBox(height: 16),
                    ] else if (_isCheckingStatus) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            const SizedBox(width: 12),
                            const Text('正在检查支付状态...', style: TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // 支付按钮
                    if (!_isLoading && !_paymentSuccess)
                      ElevatedButton(
                        onPressed: _paymentUrl != null ? _launchPayment : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(48),
                          disabledBackgroundColor: Colors.grey.withOpacity(0.3),
                        ),
                        child: Text(
                          _isCheckingStatus ? '等待支付完成...' : '跳转支付宝',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),

                    const SizedBox(height: 12),

                    // 关闭按钮
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        side: const BorderSide(color: Colors.grey),
                      ),
                      child: const Text('关闭'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentRow(String label, double amount, {bool isBold = false, bool isRed = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: Colors.grey.shade700,
          ),
        ),
        Text(
          '¥${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: isBold ? 18 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isRed ? Colors.red : (isBold ? Colors.black : Colors.grey.shade700),
          ),
        ),
      ],
    );
  }
}
