import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/order_controller.dart';
import '../../widgets/common/custom_card.dart';

/// 订单列表页面
/// 显示用户的所有订单，支持筛选和分页
class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  late OrderController _orderController;
  late ScrollController _scrollController;

  final List<Map<String, String>> statusFilters = [
    {'label': '全部', 'value': 'all'},
    {'label': '待匹配', 'value': 'pending'},
    {'label': '进行中', 'value': 'confirmed'},
    {'label': '已完成', 'value': 'completed'},
    {'label': '已取消', 'value': 'cancelled'},
  ];

  @override
  void initState() {
    super.initState();
    _orderController = Get.put(OrderController());
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >
        _scrollController.position.maxScrollExtent - 500) {
      _orderController.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的订单'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _orderController.refresh(),
          ),
        ],
      ),
      body: Column(
        children: [
          // 筛选栏
          _buildFilterBar(),
          // 订单列表
          Expanded(
            child: Obx(() {
              if (_orderController.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (_orderController.orders.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                onRefresh: () => _orderController.refresh(),
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(12),
                  itemCount: _orderController.orders.length +
                      (_orderController.isLoadingMore.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _orderController.orders.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      );
                    }

                    final order = _orderController.orders[index];
                    return _buildOrderCard(order);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: statusFilters.map((filter) {
            return Obx(() {
              final isSelected =
                  _orderController.selectedStatus.value == filter['value'];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: FilterChip(
                  selected: isSelected,
                  label: Text(filter['label']!),
                  onSelected: (selected) {
                    _orderController.filterByStatus(filter['value']!);
                  },
                  backgroundColor: Colors.transparent,
                  selectedColor: Colors.blue.shade100,
                  side: BorderSide(
                    color: isSelected ? Colors.blue : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                ),
              );
            });
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            '暂无订单',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击右上角刷新或去发布订单',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final type = order['type'] as String?;
    final status = order['status'] as String?;
    final productName = order['product_name'] as String? ?? '未知产品';
    final quantity = order['quantity'] as num?;
    final unit = order['unit'] as String? ?? '';
    final pricePerUnit = order['price_per_unit'] as num?;
    final totalAmount = order['total_amount'] as num?;
    final scheduledTime = order['scheduled_delivery_time'] as String?;
    final qualityLevel = order['quality_level'] as String? ?? '';

    return CustomCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 顶部：类型标签和状态标签
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Chip(
                label: Text(
                  _orderController.getTypeLabel(type),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                backgroundColor: Color(
                  int.parse(
                    '0xFF${_orderController.getTypeColor(type).substring(1)}',
                  ),
                ),
                padding: EdgeInsets.zero,
              ),
              Chip(
                label: Text(
                  _orderController.getStatusLabel(status),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                backgroundColor: Color(
                  int.parse(
                    '0xFF${_orderController.getStatusColor(status).substring(1)}',
                  ),
                ),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 产品信息
          Text(
            productName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                '规格：$qualityLevel',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '数量：${quantity?.toStringAsFixed(2) ?? '0'} $unit',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 价格信息
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '单价',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '¥${pricePerUnit?.toStringAsFixed(2) ?? '0.00'}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '总额',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '¥${totalAmount?.toStringAsFixed(2) ?? '0.00'}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (scheduledTime != null && scheduledTime.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  '交货：${scheduledTime.split(' ').first}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
