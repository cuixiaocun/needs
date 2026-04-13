import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:needs_app/controllers/auth_controller.dart';
import 'package:needs_app/controllers/order_create_controller.dart';
import 'package:needs_app/services/auth_service.dart';
import 'package:needs_app/services/order_service.dart';

void main() {
  group('订单创建控制器单元测试', () {
    late AuthController authController;
    late OrderCreateController orderCreateController;

    setUp(() {
      Get.reset();

      // 创建模拟的 AuthController（不初始化实际服务）
      authController = AuthController(authService: null);
      authController.user.value = {
        'id': 'test_user_1',
        'name': '测试用户',
        'email': 'test@example.com',
        'role': 'farmer', // 农户身份
      };
      authController.isLoggedIn.value = true;

      Get.put<AuthController>(authController);
    });

    tearDown(() {
      Get.reset();
    });

    // ========== STEP 4.2: 表单字段更新 ==========
    test('STEP 4.2: 产品名称字段更新', () {
      orderCreateController = OrderCreateController();

      orderCreateController.updateField('product_name', '苹果');

      expect(orderCreateController.formData['product_name'], '苹果');

      print('✅ PASS - 产品名称字段可更新');
    });

    // ========== STEP 4.2: 数量和单价 ==========
    test('STEP 4.2: 数量和单价字段更新', () {
      orderCreateController = OrderCreateController();

      orderCreateController.updateField('quantity', '100');
      orderCreateController.updateField('price_per_unit', '5.5');

      expect(orderCreateController.formData['quantity'], '100');
      expect(orderCreateController.formData['price_per_unit'], '5.5');

      print('✅ PASS - 数量和单价字段可更新');
    });

    // ========== STEP 4.2: 单位选择 ==========
    test('STEP 4.2: 单位字段更新', () {
      orderCreateController = OrderCreateController();

      orderCreateController.updateField('unit', 'kg');

      expect(orderCreateController.formData['unit'], 'kg');

      print('✅ PASS - 单位字段可选择');
    });

    // ========== STEP 4.2: 总金额自动计算 ==========
    test('STEP 4.2: 总金额自动计算 - 基本计算', () {
      orderCreateController = OrderCreateController();

      orderCreateController.updateField('quantity', '100');
      orderCreateController.updateField('price_per_unit', '5.5');

      expect(orderCreateController.totalAmount.value, 550.0);

      print('✅ PASS - 总金额计算正确（100 * 5.5 = 550）');
    });

    // ========== STEP 4.2: 总金额重新计算 ==========
    test('STEP 4.2: 总金额自动计算 - 修改数量后重新计算', () {
      orderCreateController = OrderCreateController();

      orderCreateController.updateField('quantity', '100');
      orderCreateController.updateField('price_per_unit', '5.5');
      expect(orderCreateController.totalAmount.value, 550.0);

      // 修改数量
      orderCreateController.updateField('quantity', '50');
      expect(orderCreateController.totalAmount.value, 275.0);

      print('✅ PASS - 修改数量后总金额正确重新计算');
    });

    // ========== STEP 4.2: 小数点计算 ==========
    test('STEP 4.2: 总金额自动计算 - 小数点计算', () {
      orderCreateController = OrderCreateController();

      orderCreateController.updateField('quantity', '10.5');
      orderCreateController.updateField('price_per_unit', '3.2');

      expect(orderCreateController.totalAmount.value, 33.6);

      print('✅ PASS - 小数点计算正确');
    });

    // ========== STEP 4.3: 品质等级默认值 ==========
    test('STEP 4.3: 品质等级默认值为"一级"', () {
      orderCreateController = OrderCreateController();

      expect(orderCreateController.formData['quality_level'], '一级');

      print('✅ PASS - 品质等级默认值正确');
    });

    // ========== STEP 4: 基本信息 - 默认订单类型 ==========
    test('STEP 4: 根据用户身份设置默认订单类型 - 农户选择供应单', () {
      orderCreateController = OrderCreateController();

      // 农户应该默认选择"供应单"
      expect(orderCreateController.selectedOrderType.value, 'sell');

      print('✅ PASS - 农户默认选择供应单');
    });

    // ========== STEP 4: 订单类型切换 ==========
    test('STEP 4: 订单类型可切换', () {
      orderCreateController = OrderCreateController();

      // 初始为供应单
      expect(orderCreateController.selectedOrderType.value, 'sell');

      // 切换为需求单
      orderCreateController.selectedOrderType.value = 'buy';
      expect(orderCreateController.selectedOrderType.value, 'buy');

      // 切换回供应单
      orderCreateController.selectedOrderType.value = 'sell';
      expect(orderCreateController.selectedOrderType.value, 'sell');

      print('✅ PASS - 订单类型可正确切换');
    });

    // ========== STEP 4.4: 备注字段 ==========
    test('STEP 4.4: 备注字段更新', () {
      orderCreateController = OrderCreateController();

      orderCreateController.updateField('notes', '这是备注信息');

      expect(orderCreateController.formData['notes'], '这是备注信息');

      print('✅ PASS - 备注字段可更新');
    });

    // ========== STEP 4.3: 交货时间设置 ==========
    test('STEP 4.3: 交货时间字段更新', () {
      orderCreateController = OrderCreateController();

      final testDate = DateTime.now().add(const Duration(days: 5));
      orderCreateController.updateField('scheduled_delivery_time', testDate);

      expect(orderCreateController.formData['scheduled_delivery_time'], testDate);

      print('✅ PASS - 交货时间字段可更新');
    });

    // ========== STEP 5: 表单验证 - 空表单 ==========
    test('STEP 5: 表单验证 - 空表单失败', () {
      orderCreateController = OrderCreateController();

      final validationError = orderCreateController.validateForm();

      expect(validationError, isNotNull);
      expect(validationError, contains('产品名称'));

      print('✅ PASS - 空表单验证失败');
    });

    // ========== STEP 5: 表单验证 - 产品名称验证 ==========
    test('STEP 5: 表单验证 - 产品名称为空', () {
      orderCreateController = OrderCreateController();

      orderCreateController.updateField('product_name', '');

      final validationError = orderCreateController.validateForm();
      expect(validationError, isNotNull);
      expect(validationError, contains('产品名称'));

      print('✅ PASS - 产品名称为空验证失败');
    });

    // ========== STEP 5: 表单验证 - 产品名称过短 ==========
    test('STEP 5: 表单验证 - 产品名称过短', () {
      orderCreateController = OrderCreateController();

      orderCreateController.updateField('product_name', 'a');

      final validationError = orderCreateController.validateForm();
      expect(validationError, isNotNull);
      expect(validationError, contains('2-50字符'));

      print('✅ PASS - 产品名称过短验证失败');
    });

    // ========== STEP 5: 表单验证 - 产品名称过长 ==========
    test('STEP 5: 表单验证 - 产品名称过长', () {
      orderCreateController = OrderCreateController();

      final longName = 'a' * 51;
      orderCreateController.updateField('product_name', longName);

      final validationError = orderCreateController.validateForm();
      expect(validationError, isNotNull);
      expect(validationError, contains('2-50字符'));

      print('✅ PASS - 产品名称过长验证失败');
    });

    // ========== STEP 5: 表单验证 - 数量为零 ==========
    test('STEP 5: 表单验证 - 数量为零', () {
      orderCreateController = OrderCreateController();

      orderCreateController.updateField('product_name', '苹果');
      orderCreateController.updateField('quantity', '0');
      orderCreateController.updateField('unit', 'kg');
      orderCreateController.updateField('price_per_unit', '5.5');

      final validationError = orderCreateController.validateForm();
      expect(validationError, isNotNull);
      expect(validationError, contains('数量'));

      print('✅ PASS - 数量为零验证失败');
    });

    // ========== STEP 5: 表单验证 - 数量为负 ==========
    test('STEP 5: 表单验证 - 数量为负', () {
      orderCreateController = OrderCreateController();

      orderCreateController.updateField('product_name', '苹果');
      orderCreateController.updateField('quantity', '-100');
      orderCreateController.updateField('unit', 'kg');
      orderCreateController.updateField('price_per_unit', '5.5');

      final validationError = orderCreateController.validateForm();
      expect(validationError, isNotNull);
      expect(validationError, contains('数量'));

      print('✅ PASS - 负数数量验证失败');
    });

    // ========== STEP 5: 表单验证 - 单位为空 ==========
    test('STEP 5: 表单验证 - 单位未选择', () {
      orderCreateController = OrderCreateController();

      orderCreateController.updateField('product_name', '苹果');
      orderCreateController.updateField('quantity', '100');
      orderCreateController.updateField('price_per_unit', '5.5');

      final validationError = orderCreateController.validateForm();
      expect(validationError, isNotNull);
      expect(validationError, contains('计量单位'));

      print('✅ PASS - 单位未选择验证失败');
    });

    // ========== STEP 5: 表单验证 - 单价为零 ==========
    test('STEP 5: 表单验证 - 单价为零', () {
      orderCreateController = OrderCreateController();

      orderCreateController.updateField('product_name', '苹果');
      orderCreateController.updateField('quantity', '100');
      orderCreateController.updateField('unit', 'kg');
      orderCreateController.updateField('price_per_unit', '0');

      final validationError = orderCreateController.validateForm();
      expect(validationError, isNotNull);
      expect(validationError, contains('单价'));

      print('✅ PASS - 单价为零验证失败');
    });

    // ========== STEP 5: 表单验证 - 单价为负 ==========
    test('STEP 5: 表单验证 - 单价为负', () {
      orderCreateController = OrderCreateController();

      orderCreateController.updateField('product_name', '苹果');
      orderCreateController.updateField('quantity', '100');
      orderCreateController.updateField('unit', 'kg');
      orderCreateController.updateField('price_per_unit', '-5');

      final validationError = orderCreateController.validateForm();
      expect(validationError, isNotNull);
      expect(validationError, contains('单价'));

      print('✅ PASS - 单价为负验证失败');
    });

    // ========== STEP 5: 表单验证 - 备注过长 ==========
    test('STEP 5: 表单验证 - 备注超过500字符', () {
      orderCreateController = OrderCreateController();

      orderCreateController.updateField('product_name', '苹果');
      orderCreateController.updateField('quantity', '100');
      orderCreateController.updateField('unit', 'kg');
      orderCreateController.updateField('price_per_unit', '5.5');
      orderCreateController.updateField('notes', 'a' * 501);

      final validationError = orderCreateController.validateForm();
      expect(validationError, isNotNull);
      expect(validationError, contains('500字符'));

      print('✅ PASS - 备注超长验证失败');
    });

    // ========== STEP 5: 表单验证 - 交货时间早于今天 ==========
    test('STEP 5: 表单验证 - 交货时间早于今天', () {
      orderCreateController = OrderCreateController();

      final yesterday = DateTime.now().subtract(const Duration(days: 1));

      orderCreateController.updateField('product_name', '苹果');
      orderCreateController.updateField('quantity', '100');
      orderCreateController.updateField('unit', 'kg');
      orderCreateController.updateField('price_per_unit', '5.5');
      orderCreateController.updateField('scheduled_delivery_time', yesterday);

      final validationError = orderCreateController.validateForm();
      expect(validationError, isNotNull);
      expect(validationError, contains('不能早于今天'));

      print('✅ PASS - 交货时间早于今天验证失败');
    });

    // ========== STEP 6: 完整表单验证通过 ==========
    test('STEP 6: 完整表单验证通过', () {
      orderCreateController = OrderCreateController();

      orderCreateController.updateField('product_name', '苹果');
      orderCreateController.updateField('quantity', '100');
      orderCreateController.updateField('unit', 'kg');
      orderCreateController.updateField('price_per_unit', '5.5');

      final validationError = orderCreateController.validateForm();
      expect(validationError, isNull);

      print('✅ PASS - 完整表单验证通过');
    });

    // ========== STEP 6: 最小长度产品名称验证通过 ==========
    test('STEP 6: 最小长度产品名称验证通过', () {
      orderCreateController = OrderCreateController();

      orderCreateController.updateField('product_name', '苹');
      orderCreateController.updateField('quantity', '100');
      orderCreateController.updateField('unit', 'kg');
      orderCreateController.updateField('price_per_unit', '5.5');

      final validationError = orderCreateController.validateForm();
      expect(validationError, isNull);

      print('✅ PASS - 单字产品名称验证通过');
    });

    // ========== STEP 6: 最大长度产品名称验证通过 ==========
    test('STEP 6: 最大长度产品名称验证通过', () {
      orderCreateController = OrderCreateController();

      orderCreateController.updateField('product_name', 'a' * 50);
      orderCreateController.updateField('quantity', '100');
      orderCreateController.updateField('unit', 'kg');
      orderCreateController.updateField('price_per_unit', '5.5');

      final validationError = orderCreateController.validateForm();
      expect(validationError, isNull);

      print('✅ PASS - 50字产品名称验证通过');
    });

    // ========== STEP 9: 综合流程 - 完整订单数据 ==========
    test('STEP 9: 综合流程 - 完整订单数据验证', () {
      orderCreateController = OrderCreateController();

      // 填充完整数据
      orderCreateController.updateField('product_name', '葡萄');
      orderCreateController.updateField('quantity', '50');
      orderCreateController.updateField('unit', 't');
      orderCreateController.updateField('price_per_unit', '10.0');
      orderCreateController.updateField('quality_level', '特级');
      orderCreateController.updateField('delivery_method', 'logistics');

      // 验证所有数据
      expect(orderCreateController.formData['product_name'], '葡萄');
      expect(orderCreateController.formData['quantity'], '50');
      expect(orderCreateController.formData['unit'], 't');
      expect(orderCreateController.formData['price_per_unit'], '10.0');
      expect(orderCreateController.formData['quality_level'], '特级');
      expect(orderCreateController.formData['delivery_method'], 'logistics');

      // 验证总金额计算
      expect(orderCreateController.totalAmount.value, 500.0);

      // 验证表单通过验证
      final validationError = orderCreateController.validateForm();
      expect(validationError, isNull);

      print('✅ PASS - 完整订单数据验证通过');
    });

    // ========== STEP 4: 表单重置 ==========
    test('STEP 4: 表单重置功能', () {
      orderCreateController = OrderCreateController();

      // 填充数据
      orderCreateController.updateField('product_name', '苹果');
      orderCreateController.updateField('quantity', '100');
      orderCreateController.updateField('unit', 'kg');
      orderCreateController.updateField('price_per_unit', '5.5');

      expect(orderCreateController.formData.isNotEmpty, true);

      // 重置表单
      orderCreateController.resetForm();

      // 验证表单重置
      expect(orderCreateController.formData['product_name'], null);
      expect(orderCreateController.formData['quantity'], null);
      expect(orderCreateController.formData['unit'], null);
      expect(orderCreateController.formData['price_per_unit'], null);
      expect(orderCreateController.formData['quality_level'], '一级'); // 重置后恢复默认值
      expect(orderCreateController.totalAmount.value, 0.0);

      print('✅ PASS - 表单重置成功');
    });
  });
}
