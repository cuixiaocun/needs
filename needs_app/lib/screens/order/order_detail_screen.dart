import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:needs_app/config/colors.dart';
import 'package:needs_app/services/order_service.dart';
import 'package:needs_app/widgets/common/custom_card.dart';
import 'package:needs_app/widgets/dialogs/delivery_confirm_dialog.dart';
import 'package:needs_app/widgets/bottom_sheets/payment_bottom_sheet.dart';
import 'package:needs_app/services/delivery_service.dart';

/// 订单详情页
class OrderDetailScreen extends StatefulWidget {
  final int? orderId;
  final Map<String, dynamic>? order;

  const OrderDetailScreen({super.key, this.orderId, this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final OrderService _orderService = OrderService();
  final DeliveryService _deliveryService = DeliveryService();
  bool _isLoading = true;
  Map<String, dynamic>? _order;
  String? _errorMessage;
  double _deliveryFee = 80; // 默认运费

  @override
  void initState() {
    super.initState();
    if (widget.order != null) {
      // 使用传入的 order 数据
      setState(() {
        _order = widget.order;
        _isLoading = false;
      });
    } else if (widget.orderId != null) {
      // 从 API 加载订单
      _loadOrderDetail();
    }
  }

  Future<void> _loadOrderDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _orderService.getOrderDetail(widget.orderId!);
      if (mounted) {
        if (result['success']) {
          setState(() {
            _order = result['data'];
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = result['message'];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('订单详情'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('加载失败: $_errorMessage', style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadOrderDetail,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    if (_order == null) {
      return const Center(child: Text('未找到订单信息'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildStatusCard(),
          const SizedBox(height: 12),
          _buildProductCard(),
          const SizedBox(height: 12),
          _buildDeliveryCard(),
          const SizedBox(height: 12),
          _buildPartyCard(),
          const SizedBox(height: 24),
          _buildActionButtons(),
        ],
      ),
    );
  }

  /// 1. 状态卡片
  Widget _buildStatusCard() {
    final status = _order!['status'] ?? 'pending';
    final type = _order!['type'] ?? 'sell';

    return CustomCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getStatusText(status),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _getStatusColor(status),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '单号: #${_order!['id']}',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: type == 'sell' ? Colors.orange.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              type == 'sell' ? '供应单' : '需求单',
              style: TextStyle(
                color: type == 'sell' ? Colors.orange : Colors.blue,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 2. 商品信息卡片
  Widget _buildProductCard() {
    return CustomCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('商品详情', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const Divider(height: 24),
          _buildInfoRow('产品名称', _order!['product_name'] ?? '-'),
          _buildInfoRow('品质等级', _order!['quality_level'] ?? '一级'),
          _buildInfoRow('订单数量', '${_order!['quantity']} ${_order!['unit']}'),
          _buildInfoRow('单位价格', '¥${_order!['price_per_unit']}/${_order!['unit']}'),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('合计总额', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                '¥${_order!['total_amount']}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 3. 交货信息
  Widget _buildDeliveryCard() {
    final time = _order!['scheduled_delivery_time'];
    final timeStr = time != null ? time.toString().substring(0, 16) : '暂未约定';

    return CustomCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('交货信息', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const Divider(height: 24),
          _buildInfoRow('交货时间', timeStr, icon: Icons.access_time),
          _buildInfoRow('交货方式', '集散市场中转', icon: Icons.warehouse),
          if (_order!['notes'] != null && _order!['notes'].toString().isNotEmpty)
            _buildInfoRow('备注信息', _order!['notes'], icon: Icons.note_outlined),
        ],
      ),
    );
  }

  /// 4. 交易方信息
  Widget _buildPartyCard() {
    final isSell = _order!['type'] == 'sell';
    final otherParty = isSell ? _order!['buyer'] : _order!['farmer'];
    final roleName = isSell ? '买家' : '卖家';

    if (otherParty == null) {
      return CustomCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.person_outline, color: AppColors.textHint),
            const SizedBox(width: 12),
            Text('对方信息：等待平台匹配中...', style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return CustomCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$roleName信息', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const Divider(height: 24),
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  (otherParty['name'] ?? '?').toString().substring(0, 1),
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(otherParty['name'] ?? '未知用户', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(otherParty['phone'] ?? '-', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.phone_in_talk, color: AppColors.primary),
                onPressed: () => Get.snackbar('拨号', '正在拨打对方电话...'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 5. 操作按钮
  Widget _buildActionButtons() {
    final status = _order!['status'];

    if (status == 'completed' || status == 'cancelled') {
      return const SizedBox.shrink();
    }

    if (status == 'pending') {
      // 待匹配状态：显示支付按钮和联系平台按钮
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Get.snackbar('在线客服', '正在连接平台经纪人...'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('联系平台', style: TextStyle(color: AppColors.primary)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _showPaymentFlow,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('立即支付'),
            ),
          ),
        ],
      );
    }

    // 已成交状态
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Get.snackbar('在线客服', '正在连接平台经纪人...'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('联系平台', style: TextStyle(color: AppColors.primary)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () => Get.snackbar('提示', '请按约定时间送达集散市场'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('查看交货流程'),
          ),
        ),
      ],
    );
  }

  /// 显示支付流程
  void _showPaymentFlow() {
    if (_order == null) return;

    final orderAmount = (_order!['total_amount'] as num?)?.toDouble() ?? 0.0;

    // 显示交货确认对话框
    showDialog(
      context: context,
      builder: (context) => DeliveryConfirmDialog(
        orderId: _order!['id'],
        orderAmount: orderAmount,
        deliveryFee: _deliveryFee,
        onConfirmed: () => _showPaymentBottomSheet(orderAmount),
      ),
    );
  }

  /// 显示支付弹窗
  void _showPaymentBottomSheet(double orderAmount) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => PaymentBottomSheet(
        orderId: _order!['id'],
        orderAmount: orderAmount,
        deliveryFee: _deliveryFee,
        onPaymentSuccess: () {
          Get.back(); // 关闭支付弹窗
          _loadOrderDetail(); // 刷新订单详情
          Get.snackbar('成功', '支付完成，订单已确认');
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: AppColors.textHint),
            const SizedBox(width: 8),
          ],
          Text(label, style: TextStyle(color: AppColors.textSecondary)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'confirmed':
      case 'receiving':
      case 'received': return Colors.blue;
      case 'dispatched': return Colors.purple;
      case 'completed': return AppColors.primary;
      case 'cancelled': return Colors.grey;
      default: return AppColors.textSecondary;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending': return '待撮合';
      case 'confirmed': return '已成交';
      case 'receiving': return '收货中';
      case 'received': return '已入库';
      case 'dispatched': return '待配送';
      case 'completed': return '已完成';
      case 'cancelled': return '已取消';
      default: return '未知状态';
    }
  }
}
