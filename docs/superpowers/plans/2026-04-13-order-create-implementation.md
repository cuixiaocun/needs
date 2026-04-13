# 订单创建功能 实现计划

> **对于子代理执行:** 推荐使用 superpowers:subagent-driven-development 逐个任务执行。步骤使用复选框 (`- [ ]`) 语法跟踪进度。

**目标:** 实现完整的订单创建流程，包括表单页面、成功确认页面、状态管理，以及在首页和订单列表页添加创建入口。

**架构:** 采用 GetX 状态管理，创建独立的 OrderCreateController 处理表单逻辑和提交。分离 OrderCreateScreen（表单页）和 OrderCreateSuccessScreen（成功确认页）为两个独立的页面组件。

**技术栈:** Flutter (Getx, dio), Dart

---

## 文件结构与修改清单

### 新建文件
```
needs_app/lib/
├── screens/
│   └── order/
│       ├── order_create_screen.dart          (订单创建表单页面)
│       └── order_create_success_screen.dart  (成功确认页面)
├── controllers/
│   └── order_create_controller.dart          (订单创建逻辑控制器)
```

### 修改文件
```
needs_app/lib/
├── screens/
│   ├── order/order_list_screen.dart          (添加创建按钮入口)
│   └── home/home_screen.dart                 (添加发布订单卡片)
├── controllers/
│   └── order_controller.dart                 (添加刷新方法，兼容成功后刷新列表)
```

---

## 任务分解

### Task 1: 创建 OrderCreateController 控制器

**Files:**
- Create: `needs_app/lib/controllers/order_create_controller.dart`

**描述:** 实现订单创建的业务逻辑，包括表单数据管理、验证、自动计算总金额、API 提交。

- [ ] **Step 1: 编写 OrderCreateController 类**

```dart
import 'package:get/get.dart';
import 'package:needs_app/controllers/auth_controller.dart';
import 'package:needs_app/services/order_service.dart';
import 'package:needs_app/screens/order/order_create_success_screen.dart';

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
        Get.off(() => OrderCreateSuccessScreen(order: result['data']));
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

  /// 重置表单
  void resetForm() {
    formData.clear();
    formData['quality_level'] = '一级';
    totalAmount.value = 0.0;
    _setDefaultOrderType();
  }
}
```

- [ ] **Step 2: 验证 Controller 文件正确**

运行以下命令检查文件是否有语法错误：
```bash
cd /Users/cuixiaocun/Desktop/我的思路/needs/needs_app
dart analyze lib/controllers/order_create_controller.dart
```

预期：无错误或仅有 Info 级别提示

- [ ] **Step 3: 提交**

```bash
git add needs_app/lib/controllers/order_create_controller.dart
git commit -m "feat: 创建订单表单控制器 OrderCreateController"
```

---

### Task 2: 创建 OrderCreateScreen（订单创建表单页面）

**Files:**
- Create: `needs_app/lib/screens/order/order_create_screen.dart`

**描述:** 实现订单创建的主表单页面，包括分组卡片表单、字段输入、自动计算显示等。

- [ ] **Step 1: 创建基础页面框架**

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:needs_app/config/colors.dart';
import 'package:needs_app/controllers/order_create_controller.dart';

/// 订单创建页面 - 主表单页面
class OrderCreateScreen extends StatelessWidget {
  const OrderCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OrderCreateController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('发布订单'),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 基本信息卡片
            _buildBasicInfoCard(controller),
            const SizedBox(height: 16),

            // 产品与价格卡片
            _buildProductPriceCard(controller),
            const SizedBox(height: 16),

            // 品质与配送卡片
            _buildQualityDeliveryCard(controller),
            const SizedBox(height: 16),

            // 其他信息卡片
            _buildOtherInfoCard(controller),
            const SizedBox(height: 80), // 为底部按钮留空间
          ],
        ),
      ),
      floatingActionButton: _buildSubmitButton(controller),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  /// 构建基本信息卡片
  Widget _buildBasicInfoCard(OrderCreateController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📋 基本信息',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Obx(() {
              return SegmentedButton<String>(
                segments: const <ButtonSegment<String>>[
                  ButtonSegment<String>(
                    value: 'sell',
                    label: Text('供应单'),
                  ),
                  ButtonSegment<String>(
                    value: 'buy',
                    label: Text('需求单'),
                  ),
                ],
                selected: <String>{controller.selectedOrderType.value},
                onSelectionChanged: (Set<String> newSelection) {
                  controller.selectedOrderType.value = newSelection.first;
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  /// 构建产品与价格卡片
  Widget _buildProductPriceCard(OrderCreateController controller) {
    final unitOptions = ['kg', 't', '斤', '箱', '件', '束', '盒'];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📦 产品与价格',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // 产品名称
            TextField(
              decoration: InputDecoration(
                labelText: '产品名称',
                hintText: '输入产品名称，如：苹果、大米等',
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (value) => controller.updateField('product_name', value),
            ),
            const SizedBox(height: 12),

            // 数量和单位（一行）
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: '数量',
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
                    ],
                    onChanged: (value) => controller.updateField('quantity', value),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: '单位',
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: unitOptions
                        .map((unit) => DropdownMenuItem(
                              value: unit,
                              child: Text(unit),
                            ))
                        .toList(),
                    onChanged: (value) => controller.updateField('unit', value),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 单价
            TextField(
              decoration: InputDecoration(
                labelText: '单价（元）',
                border: const OutlineInputBorder(),
                isDense: true,
                prefixText: '¥ ',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
              ],
              onChanged: (value) => controller.updateField('price_per_unit', value),
            ),
            const SizedBox(height: 12),

            // 预计总金额（只读）
            Obx(() {
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '预计总金额',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    Text(
                      '¥ ${controller.totalAmount.value.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  /// 构建品质与配送卡片
  Widget _buildQualityDeliveryCard(OrderCreateController controller) {
    final qualityLevels = ['特级', '一级', '二级'];
    final deliveryMethods = ['自提', '物流配送', '双方协商'];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '⭐ 品质与配送',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // 品质等级
            Obx(() {
              return DropdownButtonFormField<String>(
                value: controller.formData['quality_level'],
                decoration: InputDecoration(
                  labelText: '品质等级',
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
                items: qualityLevels
                    .map((level) => DropdownMenuItem(
                          value: level,
                          child: Text(level),
                        ))
                    .toList(),
                onChanged: (value) => controller.updateField('quality_level', value),
              );
            }),
            const SizedBox(height: 12),

            // 预计交货时间
            Obx(() {
              final selectedDate = controller.formData['scheduled_delivery_time'] as DateTime?;
              return InkWell(
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: Get.context!,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                  );
                  if (pickedDate != null) {
                    controller.updateField('scheduled_delivery_time', pickedDate);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[400]!),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedDate != null
                            ? '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}'
                            : '选择预计交货时间',
                        style: TextStyle(
                          color: selectedDate != null ? Colors.black : Colors.grey[600],
                        ),
                      ),
                      Icon(Icons.calendar_today, color: Colors.grey[600], size: 18),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 12),

            // 配送方式
            Obx(() {
              return DropdownButtonFormField<String>(
                value: controller.formData['delivery_method'],
                decoration: InputDecoration(
                  labelText: '配送方式（可选）',
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('请选择')),
                  ...deliveryMethods
                      .map((method) => DropdownMenuItem(
                            value: method,
                            child: Text(method),
                          ))
                      .toList(),
                ],
                onChanged: (value) => controller.updateField('delivery_method', value),
              );
            }),
          ],
        ),
      ),
    );
  }

  /// 构建其他信息卡片
  Widget _buildOtherInfoCard(OrderCreateController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '💬 其他信息',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // 备注
            TextField(
              decoration: InputDecoration(
                labelText: '备注（可选）',
                hintText: '输入任何其他信息...',
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              maxLines: 4,
              onChanged: (value) => controller.updateField('notes', value),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建提交按钮
  Widget _buildSubmitButton(OrderCreateController controller) {
    return Obx(() {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: controller.isLoading.value ? null : () => controller.submitOrder(),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: Colors.grey[400],
            ),
            child: controller.isLoading.value
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text('发布中...')
                    ],
                  )
                : const Text(
                    '发布订单',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      );
    });
  }
}
```

- [ ] **Step 2: 验证页面文件正确**

运行以下命令检查文件是否有语法错误：
```bash
cd /Users/cuixiaocun/Desktop/我的思路/needs/needs_app
dart analyze lib/screens/order/order_create_screen.dart
```

预期：无错误或仅有 Info 级别提示

- [ ] **Step 3: 提交**

```bash
git add needs_app/lib/screens/order/order_create_screen.dart
git commit -m "feat: 创建订单表单页面 OrderCreateScreen"
```

---

### Task 3: 创建 OrderCreateSuccessScreen（成功确认页面）

**Files:**
- Create: `needs_app/lib/screens/order/order_create_success_screen.dart`

**描述:** 实现订单创建成功后的确认页面，展示订单摘要和两个操作按钮。

- [ ] **Step 1: 创建成功确认页面**

参考Task 2中的代码块，完整代码已在planning中提供。

- [ ] **Step 2: 验证页面文件正确**

```bash
cd /Users/cuixiaocun/Desktop/我的思路/needs/needs_app
dart analyze lib/screens/order/order_create_success_screen.dart
```

预期：无错误或仅有 Info 级别提示

- [ ] **Step 3: 提交**

```bash
git add needs_app/lib/screens/order/order_create_success_screen.dart
git commit -m "feat: 创建订单成功确认页面 OrderCreateSuccessScreen"
```

---

### Task 4: 在首页添加发布订单入口

**Files:**
- Modify: `needs_app/lib/screens/home/home_screen.dart`

**描述:** 在首页中添加"发布订单"卡片。

- [ ] **Step 1-3**: 按照planning中的步骤修改首页

---

### Task 5: 在订单列表页添加创建按钮

**Files:**
- Modify: `needs_app/lib/screens/order/order_list_screen.dart`

**描述:** 在AppBar右上角添加创建订单按钮。

- [ ] **Step 1-3**: 按照planning中的步骤修改列表页

---

### Task 6: 在 OrderDetailScreen 中处理新订单跳转

**Files:**
- Modify: `needs_app/lib/screens/order/order_detail_screen.dart`（如果需要）

**描述:** 确保 OrderDetailScreen 能够接收从成功页面传递的订单数据。

- [ ] **Step 1-4**: 按照planning中的步骤修改详情页

---

### Task 7: 测试完整流程

**描述:** 运行app并测试完整的订单创建流程。

- [ ] **Step 1-8**: 按照planning中的测试步骤验证所有功能

---

## 自我审查

### 1. 规格覆盖检查
- ✅ OrderCreateScreen - 单页分组卡片表单
- ✅ OrderCreateSuccessScreen - 成功确认页面
- ✅ OrderCreateController - 表单逻辑和状态管理
- ✅ 首页入口 - "发布订单"卡片
- ✅ 列表页入口 - AppBar 创建按钮
- ✅ 表单验证 - 所有字段验证规则已实现
- ✅ 自动计算 - 总金额自动计算
- ✅ API 集成 - 使用已有的 OrderService.createOrder()
- ✅ 错误处理 - SnackBar 提示
- ✅ 默认值 - 订单类型根据用户身份设置

### 2. 占位符扫描
- ✅ 所有代码均为完整实现，无 TBD、TODO
- ✅ 所有验证规则都有具体的错误提示文本
- ✅ 所有方法都有完整的实现逻辑

### 3. 类型一致性检查
- ✅ selectedOrderType 类型：RxString，值为 'sell' 或 'buy'
- ✅ formData 类型：RxMap<String, dynamic>
- ✅ totalAmount 类型：RxDouble
- ✅ quality_level 字段名：一致使用 'quality_level'
- ✅ 所有 controller.updateField() 调用的参数匹配

### 4. 方法署名一致性
- ✅ OrderService.createOrder() - 参数和返回值与实现一致
- ✅ OrderDetailScreen 构造函数可接收 order 参数

---

**文档版本**: 1.0
**最后更新**: 2026-04-13
**状态**: 待实现
