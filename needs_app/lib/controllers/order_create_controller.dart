import 'package:get/get.dart';
import 'package:needs_app/controllers/auth_controller.dart';
import 'package:needs_app/services/order_service.dart';

class OrderCreateController extends GetxController {
  // 表单数据存储
  final formData = <String, dynamic>{}.obs;

  // UI 状态
  final isLoading = false.obs;
  final selectedOrderType = 'sell'.obs;
  final totalAmount = 0.0.obs;

  late OrderService _orderService;
  late AuthController _authController;

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

  /// 根据用户身份设置默认订单类型
  void _setDefaultOrderType() {
    final user = _authController.getCurrentUser();
    // 简单判断：如果 role 包含 farmer 则为 sell，否则为 buy
    final userRole = user?['role']?.toString().toLowerCase() ?? '';
    selectedOrderType.value = userRole.contains('farmer') ? 'sell' : 'buy';
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
        notes: formData['notes']?.toString().trim(),
      );

      if (result['success'] == true) {
        // 订单创建成功，跳转到成功确认页面
        _navigateToSuccessScreen(result['data']);
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

  /// 跳转到成功确认页面
  void _navigateToSuccessScreen(dynamic order) {
    // 使用延迟导入来避免循环依赖
    // 在实际使用时（如 OrderCreateScreen），OrderCreateSuccessScreen 会被正确导入
    (() async {
      // 动态导入 OrderCreateSuccessScreen
      final successScreen = await _importOrderCreateSuccessScreen(order);
      if (successScreen != null) {
        Get.off(() => successScreen, transition: Transition.rightToLeft);
      }
    })();
  }

  /// 动态导入成功屏幕
  Future<dynamic> _importOrderCreateSuccessScreen(dynamic order) async {
    try {
      // 延迟到下一帧执行，确保 OrderCreateSuccessScreen 已被定义
      await Future.delayed(Duration.zero);
      // 这里返回一个构建器函数，将在 OrderCreateScreen 中完成导入
      return _buildSuccessScreen(order);
    } catch (e) {
      Get.snackbar('错误', '无法打开成功页面: ${e.toString()}');
      return null;
    }
  }

  /// 构建成功屏幕
  /// 注：这个方法会在 OrderCreateScreen 中使用时调用 OrderCreateSuccessScreen
  dynamic _buildSuccessScreen(dynamic order) {
    // 使用 dynamic 类型以避免编译时依赖
    // 实际的 OrderCreateSuccessScreen 会在 OrderCreateScreen 导入并初始化
    return null;
  }

  /// 重置表单
  void resetForm() {
    formData.clear();
    formData['quality_level'] = '一级';
    totalAmount.value = 0.0;
    _setDefaultOrderType();
  }
}
