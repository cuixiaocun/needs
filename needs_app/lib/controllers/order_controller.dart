import 'package:get/get.dart';
import '../services/order_service.dart';

class OrderController extends GetxController {
  final OrderService _orderService;

  // 订单列表
  final RxList<Map<String, dynamic>> orders = RxList([]);

  // 加载状态
  final RxBool isLoading = RxBool(false);
  final RxBool isLoadingMore = RxBool(false);
  final RxString errorMessage = RxString('');

  // 筛选状态
  final RxString selectedStatus = RxString('all');
  final RxString selectedType = RxString('all');

  // 分页信息
  final RxInt currentPage = RxInt(1);
  final RxInt lastPage = RxInt(1);
  final RxInt totalOrders = RxInt(0);
  final RxBool hasMorePages = RxBool(false);

  // 状态标签映射
  static const Map<String, String> statusLabels = {
    'pending': '待匹配',
    'confirmed': '已确认',
    'receiving': '收货中',
    'received': '已收货',
    'dispatched': '已发货',
    'completed': '已完成',
    'cancelled': '已取消',
  };

  // 类型标签映射
  static const Map<String, String> typeLabels = {
    'buy': '买单',
    'sell': '卖单',
  };

  OrderController({OrderService? orderService})
      : _orderService = orderService ?? OrderService() {
    _setupStatusFilters();
  }

  void _setupStatusFilters() {
    // 监听状态变化，自动重新加载数据
    ever(selectedStatus, (_) => refresh());
    ever(selectedType, (_) => refresh());
  }

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  /// 初始加载订单列表（第1页）
  Future<void> loadOrders() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      currentPage.value = 1;

      final result = await _orderService.getOrders(
        page: 1,
        status: selectedStatus.value != 'all' ? selectedStatus.value : null,
        type: selectedType.value != 'all' ? selectedType.value : null,
      );

      if (result['success'] == true) {
        orders.value = List<Map<String, dynamic>>.from(result['data'] ?? []);

        final pagination = result['pagination'] as Map<String, dynamic>;
        currentPage.value = pagination['current_page'] ?? 1;
        lastPage.value = pagination['last_page'] ?? 1;
        totalOrders.value = pagination['total'] ?? 0;
        hasMorePages.value = currentPage.value < lastPage.value;

        errorMessage.value = '';
      } else {
        orders.value = [];
        errorMessage.value = result['message'] ?? '加载订单失败';
      }
    } catch (e) {
      errorMessage.value = '加载失败：${e.toString()}';
      orders.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  /// 加载下一页（上拉加载更多）
  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMorePages.value) return;

    try {
      isLoadingMore.value = true;

      final nextPage = currentPage.value + 1;
      final result = await _orderService.getOrders(
        page: nextPage,
        status: selectedStatus.value != 'all' ? selectedStatus.value : null,
        type: selectedType.value != 'all' ? selectedType.value : null,
      );

      if (result['success'] == true) {
        final newOrders = List<Map<String, dynamic>>.from(result['data'] ?? []);
        orders.addAll(newOrders);

        final pagination = result['pagination'] as Map<String, dynamic>;
        currentPage.value = pagination['current_page'] ?? nextPage;
        lastPage.value = pagination['last_page'] ?? 1;
        hasMorePages.value = currentPage.value < lastPage.value;

        errorMessage.value = '';
      } else {
        errorMessage.value = result['message'] ?? '加载更多失败';
      }
    } catch (e) {
      errorMessage.value = '加载更多失败：${e.toString()}';
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// 下拉刷新（重新加载第1页）
  Future<void> refresh() async {
    await loadOrders();
  }

  /// 更新筛选状态并重新加载
  void filterByStatus(String status) {
    selectedStatus.value = status;
  }

  /// 获取状态标签
  String getStatusLabel(String? status) {
    return statusLabels[status] ?? status ?? '未知';
  }

  /// 获取类型标签
  String getTypeLabel(String? type) {
    return typeLabels[type] ?? type ?? '未知';
  }

  /// 获取状态颜色
  String getStatusColor(String? status) {
    switch (status) {
      case 'pending':
        return '#FF9800'; // 橙色
      case 'confirmed':
      case 'receiving':
      case 'received':
        return '#2196F3'; // 蓝色
      case 'dispatched':
        return '#9C27B0'; // 紫色
      case 'completed':
        return '#4CAF50'; // 绿色
      case 'cancelled':
        return '#9E9E9E'; // 灰色
      default:
        return '#757575';
    }
  }

  /// 获取类型颜色
  String getTypeColor(String? type) {
    switch (type) {
      case 'sell':
        return '#FF9800'; // 橙色
      case 'buy':
        return '#2196F3'; // 蓝色
      default:
        return '#757575';
    }
  }
}
