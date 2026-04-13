import 'package:get/get.dart';
import 'package:needs_app/controllers/auth_controller.dart';
import 'package:needs_app/services/order_service.dart';

class OrderCreateController extends GetxController {
  // 表单数据存储
  final formData = RxMap<String, dynamic>();

  // UI 状态
  final isLoading = false.obs;
  final selectedOrderType = 'sell'.obs;
  final totalAmount = 0.0.obs;

  late OrderService _orderService;
  late AuthController _authController;

  // 导航回调函数 - 用于处理成功后的导航
  Function(dynamic order)? _onSuccessCallback;

  @override
  void onInit() {
    super.onInit();
    _orderService = Get.find<OrderService>();
    _authController = Get.find<AuthController>();

    // 根据用户身份设置默认订单类型
    _setDefaultOrderType();

    // 初始化品质等级默认值
    formData['quality_level'] = '一级';
  }

  /// 设置成功后的导航回调
  void setOnSuccessCallback(Function(dynamic order) callback) {
    _onSuccessCallback = callback;
  }

  /// 根据用户身份设置默认订单类型
  void _setDefaultOrderType() {
    final user = _authController.getCurrentUser();
    final userRole = user?['role']?.toString() ?? '';
    selectedOrderType.value = userRole == 'farmer' ? 'sell' : 'buy';
  }

  /// 更新表单字段值
  void updateField(String key, dynamic value) {
    formData[key] = value;
    // 当数量或单价改变时，重新计算总金额
    if (key == 'quantity' || key == 'price_per_unit') {
      calculateTotal();
    }
  }

  /// 自动计算订单总金额
  void calculateTotal() {
    try {
      final quantity = double.tryParse(formData['quantity']?.toString() ?? '0') ?? 0;
      final pricePerUnit = double.tryParse(formData['price_per_unit']?.toString() ?? '0') ?? 0;
      totalAmount.value = quantity * pricePerUnit;
    } catch (e) {
      totalAmount.value = 0.0;
    }
  }

  /// 验证表单数据
  String? validateForm() {
    // 产品名称验证
    final productName = formData['product_name']?.toString().trim() ?? '';
    if (productName.isEmpty || productName.length < 2 || productName.length > 50) {
      return '请输入产品名称（2-50字符）';
    }

    // 数量验证
    final quantity = double.tryParse(formData['quantity']?.toString() ?? '0') ?? 0;
    if (quantity <= 0) {
      return '数量必须大于0';
    }

    // 计量单位验证
    if (formData['unit'] == null || (formData['unit'] as String).isEmpty) {
      return '请选择计量单位';
    }

    // 单价验证
    final pricePerUnit = double.tryParse(formData['price_per_unit']?.toString() ?? '0') ?? 0;
    if (pricePerUnit <= 0) {
      return '单价必须大于0';
    }

    // 品质等级验证
    if (formData['quality_level'] == null || (formData['quality_level'] as String).isEmpty) {
      return '请选择品质等级';
    }

    // 备注字符数验证
    final notes = formData['notes']?.toString() ?? '';
    if (notes.length > 500) {
      return '备注不超过500字符';
    }

    // 交货时间验证（如果填写了，不能早于今天）
    if (formData['scheduled_delivery_time'] != null) {
      final selectedDate = formData['scheduled_delivery_time'] as DateTime;
      final today = DateTime.now();
      final todayNoTime = DateTime(today.year, today.month, today.day);
      if (selectedDate.isBefore(todayNoTime)) {
        return '交货时间不能早于今天';
      }
    }

    return null;
  }

  /// 提交订单
  Future<void> submitOrder() async {
    // 执行验证
    final validationError = validateForm();
    if (validationError != null) {
      Get.snackbar(
        '验证失败',
        validationError,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    try {
      final result = await _orderService.createOrder(
        productName: formData['product_name'].toString().trim(),
        quantity: double.parse(formData['quantity'].toString()),
        unit: formData['unit'].toString(),
        pricePerUnit: double.parse(formData['price_per_unit'].toString()),
        type: selectedOrderType.value,
        qualityLevel: formData['quality_level'].toString(),
        scheduledDeliveryTime: formData['scheduled_delivery_time'] != null
            ? (formData['scheduled_delivery_time'] as DateTime).toString().split(' ')[0]
            : null,
        deliveryMethod: formData['delivery_method']?.toString(),
        notes: formData['notes']?.toString().trim(),
      );

      if (result['success'] == true) {
        // 订单创建成功，触发导航回调或直接跳转
        if (_onSuccessCallback != null) {
          _onSuccessCallback!(result['data']);
        } else {
          _navigateToSuccessScreen(result['data']);
        }
      } else {
        Get.snackbar(
          '创建失败',
          result['message'] ?? '未知错误',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        '错误',
        '网络错误: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// 默认的导航方法（会在 OrderCreateScreen 中被覆盖）
  void _navigateToSuccessScreen(dynamic order) {
    // 这是一个回退方案，实际的导航会通过 setOnSuccessCallback 来处理
    Get.snackbar('成功', '订单创建成功！');
  }

  /// 重置表单
  void resetForm() {
    formData.clear();
    formData['quality_level'] = '一级';
    totalAmount.value = 0.0;
    _setDefaultOrderType();
  }
}
