# 订单创建功能设计文档

**日期**: 2026-04-13
**功能**: 订单创建功能（OrderCreateScreen）
**优先级**: High
**状态**: 设计已批准

---

## 1. 功能概述

允许用户创建新的农产品订单（供应单或需求单）。用户可以在首页和订单列表页快速访问发布订单功能，通过单页表单填写订单信息，表单验证后提交到后端，成功后显示确认屏幕。

### 核心流程
```
首页/列表页 → 发布订单按钮
    ↓
OrderCreateScreen（单页分组卡片表单）
    ↓
前端表单验证 & 后端提交
    ↓
OrderCreateSuccessScreen（成功确认）
    ↓
用户选择：返回列表 或 查看详情
```

---

## 2. 用户需求与约束

### 需求
- 用户根据身份创建默认订单类型（农户默认供应单/sell，买家默认需求单/buy），但可修改
- 收集订单基本信息：产品名、数量、单位、单价、品质等级、交货时间、配送方式、备注
- 表单中自动计算订单总金额
- 创建成功后显示确认屏幕，用户可选择返回列表或查看详情

### 约束
- 表单验证采用简单提示方式（错误弹窗）
- 所有字段在单页表单中展现
- 两处页面入口：首页和订单列表页

---

## 3. 页面设计

### 3.1 OrderCreateScreen（订单创建页面）

**页面流程**:
```
Scaffold
├── AppBar
│   ├── 标题: "发布订单"
│   └── 返回按钮
├── SingleChildScrollView（表单内容）
│   └── 分组卡片表单
│       ├── 📋 基本信息卡片
│       ├── 📦 产品与价格卡片
│       ├── ⭐ 品质与配送卡片
│       └── 💬 其他信息卡片
└── 底部操作区
    └── "发布订单"按钮 + 加载状态指示
```

#### 3.1.1 基本信息卡片
- **标题**: "基本信息"
- **内容**:
  - 订单类型选择（SegmentedButton）：
    - 选项1: "供应单" (value: "sell")
    - 选项2: "需求单" (value: "buy")
    - 默认值：根据用户身份自动选中（农户 → sell，买家 → buy）

#### 3.1.2 产品与价格卡片
- **标题**: "产品与价格"
- **字段**:
  1. **产品名称** (TextField)
     - 必填
     - 验证：2-50字符
     - 错误提示: "请输入产品名称（2-50字符）"
     - 占位符: "输入产品名称，如：苹果、大米等"

  2. **数量** (TextField - 数字输入)
     - 必填
     - 验证：必须 > 0
     - 错误提示: "数量必须大于0"
     - inputFormatters: [FilteringTextInputFormatter.digitsOnly]

  3. **计量单位** (DropdownButton)
     - 必填
     - 选项列表: ["kg", "t", "斤", "箱", "件", "束", "盒"]
     - 错误提示: "请选择计量单位"

  4. **单价** (TextField - 数字输入)
     - 必填
     - 验证：必须 > 0，支持小数（2位）
     - 错误提示: "单价必须大于0"
     - inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))]

  5. **预计总金额** (只读显示)
     - 自动计算：quantity × pricePerUnit
     - 样式：灰色背景，不可编辑
     - 格式：保留2位小数

#### 3.1.3 品质与配送卡片
- **标题**: "品质与配送"
- **字段**:
  1. **品质等级** (DropdownButton)
     - 必填
     - 选项: ["特级", "一级", "二级"]
     - 默认: "一级"
     - 错误提示: "请选择品质等级"

  2. **预计交货时间** (DatePicker)
     - 可选
     - 约束：不能早于今天
     - 错误提示: "交货时间不能早于今天"
     - 显示格式: "yyyy-MM-dd"

  3. **配送方式** (DropdownButton)
     - 可选
     - 选项: ["自提", "物流配送", "双方协商"]
     - 默认: 空

#### 3.1.4 其他信息卡片
- **标题**: "其他信息"
- **字段**:
  1. **备注** (TextField - 多行)
     - 可选
     - maxLines: 4
     - 验证：≤500字符
     - 错误提示: "备注不超过500字符"
     - 占位符: "输入任何其他信息..."

#### 3.1.5 底部操作区
- 固定在屏幕底部
- 包含 "发布订单" 按钮：
  - 宽度：填充父容器
  - 颜色：蓝色（AppConfig.primaryColor）
  - 加载状态：显示 CircularProgressIndicator
  - 禁用状态：当 isLoading = true

---

### 3.2 OrderCreateSuccessScreen（成功确认页面）

**页面结构**:
```
Scaffold
├── AppBar（无返回按钮，仅标题）
├── Center
│   └── Column
│       ├── 大成功图标（Icon）
│       ├── "订单发布成功！"（标题）
│       ├── "您的订单已成功发布..."（副标题）
│       ├── 订单摘要卡片
│       │   └── 显示：产品名 | 数量 | 单价 | 品质等级
│       └── 两个操作按钮
│           ├── "返回订单列表"
│           └── "查看订单详情"
└── [End]
```

**具体内容**:
- **成功图标**: `Icon(Icons.check_circle, size: 80, color: Colors.green)`
- **标题**: `Text("订单发布成功！", style: 大号加粗)`
- **副标题**: `Text("您的订单已成功发布，等待买家/卖家联系", style: 中号灰色)`
- **摘要卡片**:
  - 背景：浅灰色卡片
  - 内容：
    - 产品名：`"${order['product_name']}"`
    - 数量：`"${order['quantity']} ${order['unit']}"`
    - 单价：`"¥${order['price_per_unit']}"`
    - 品质：`"品质等级: ${order['quality_level']}"`
- **操作按钮**:
  - Row 布局，两个按钮并排
  - 左按钮（"返回订单列表"）：白色背景，黑色文字，onPressed → Get.back() 到 OrderListScreen
  - 右按钮（"查看订单详情"）：蓝色背景，白色文字，onPressed → Get.to(() => OrderDetailScreen(order: order))

---

## 4. 状态管理（GetX 架构）

### 4.1 OrderCreateController

```dart
class OrderCreateController extends GetxController {
  // 表单数据
  final formData = <String, dynamic>{}.obs;

  // UI 状态
  final isLoading = false.obs;
  final selectedOrderType = 'sell'.obs;  // 默认供应单
  final totalAmount = 0.0.obs;

  // 初始化：设置用户默认订单类型
  @override
  void onInit() {
    super.onInit();
    // 根据用户身份设置默认订单类型
    final user = Get.find<AuthController>().getCurrentUser();
    selectedOrderType.value = user?['role'] == 'farmer' ? 'sell' : 'buy';
  }

  // 更新表单字段
  void updateField(String key, dynamic value) {
    formData[key] = value;
    if (key == 'quantity' || key == 'price_per_unit') {
      calculateTotal();
    }
  }

  // 自动计算总金额
  void calculateTotal() {
    final quantity = double.tryParse(formData['quantity']?.toString() ?? '0') ?? 0;
    final pricePerUnit = double.tryParse(formData['price_per_unit']?.toString() ?? '0') ?? 0;
    totalAmount.value = quantity * pricePerUnit;
  }

  // 表单验证
  String? validateForm() {
    if ((formData['product_name'] ?? '').length < 2 || (formData['product_name'] ?? '').length > 50) {
      return "请输入产品名称（2-50字符）";
    }
    if ((double.tryParse(formData['quantity']?.toString() ?? '0') ?? 0) <= 0) {
      return "数量必须大于0";
    }
    if (formData['unit'] == null) {
      return "请选择计量单位";
    }
    if ((double.tryParse(formData['price_per_unit']?.toString() ?? '0') ?? 0) <= 0) {
      return "单价必须大于0";
    }
    if (formData['quality_level'] == null) {
      return "请选择品质等级";
    }
    if ((formData['notes'] ?? '').length > 500) {
      return "备注不超过500字符";
    }
    return null;
  }

  // 提交订单
  Future<void> submitOrder() async {
    final error = validateForm();
    if (error != null) {
      Get.snackbar('验证失败', error);
      return;
    }

    isLoading.value = true;
    try {
      final orderService = Get.find<OrderService>();
      final result = await orderService.createOrder(
        productName: formData['product_name'],
        quantity: double.parse(formData['quantity'].toString()),
        unit: formData['unit'],
        pricePerUnit: double.parse(formData['price_per_unit'].toString()),
        type: selectedOrderType.value,
        qualityLevel: formData['quality_level'],
        scheduledDeliveryTime: formData['scheduled_delivery_time']?.toString(),
        notes: formData['notes'],
      );

      if (result['success'] == true) {
        // 成功：跳转到成功确认页面，传递订单信息
        Get.to(() => OrderCreateSuccessScreen(order: result['data']));
      } else {
        Get.snackbar('创建失败', result['message'] ?? '未知错误');
      }
    } catch (e) {
      Get.snackbar('错误', '网络错误：${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
}
```

---

## 5. 页面入口设计

### 5.1 首页入口
- 在首页（_buildHomePage）中，在欢迎区域下方添加一个 "发布订单" 卡片
- 样式：蓝色卡片，图标 + 文字，onTap 时 Get.to(() => OrderCreateScreen())

### 5.2 订单列表入口
- 在 OrderListScreen 的 AppBar 右上角添加按钮
- 样式：IconButton 或 FloatingActionButton，onPressed 时 Get.to(() => OrderCreateScreen())

---

## 6. 数据流与 API 集成

### 6.1 与后端 API 对接
使用已修复的 OrderService.createOrder()：

```dart
Future<Map<String, dynamic>> createOrder({
  required String productName,
  required double quantity,
  required String unit,
  required double pricePerUnit,
  required String type,
  required String qualityLevel,
  String? scheduledDeliveryTime,
  String? notes,
}) async { ... }
```

### 6.2 数据流
```
OrderCreateScreen
  ↓ 用户填表单
OrderCreateController.submitOrder()
  ↓ 前端验证
OrderService.createOrder()
  ↓ HTTP POST /orders
后端验证 & 保存
  ↓ 201 Created
OrderCreateSuccessScreen
  ↓ 用户选择
  ├─ 返回列表 → OrderListScreen (自动刷新)
  └─ 查看详情 → OrderDetailScreen
```

---

## 7. 错误处理

| 错误类型 | 处理方式 | 用户提示 |
|---------|---------|---------|
| 表单验证失败 | SnackBar | "字段验证失败：[具体错误信息]" |
| API 提交失败 | AlertDialog | "订单创建失败：[后端错误信息]\n\[重试按钮]\[取消按钮]" |
| 网络超时 | AlertDialog | "网络错误，请检查连接" |
| 未登录 | 自动处理（Dio 拦截器已实现） | 自动跳转到登录页 |

---

## 8. 测试清单

### 功能测试
- [ ] 表单验证：各字段验证规则正确
- [ ] 默认值：根据用户身份正确设置订单类型
- [ ] 总金额计算：自动计算正确
- [ ] 提交成功：订单创建成功，跳转到确认页面
- [ ] 提交失败：显示错误信息，留在表单页面
- [ ] 操作流程：确认页面的两个按钮都能正确跳转

### UI/UX 测试
- [ ] 表单字段分组清晰
- [ ] 移动端表单显示正确（长表单滚动流畅）
- [ ] 输入框焦点管理正常
- [ ] 加载状态视觉反馈清晰

### 集成测试
- [ ] 首页入口可用
- [ ] 列表页入口可用
- [ ] 创建后订单列表自动刷新

---

## 9. 文件清单

需要创建/修改的文件：
```
needs_app/lib/
├── screens/
│   └── order/
│       ├── order_create_screen.dart          (NEW)
│       └── order_create_success_screen.dart  (NEW)
├── controllers/
│   ├── order_controller.dart                 (MODIFY - 添加创建逻辑)
│   └── order_create_controller.dart          (NEW)
├── widgets/
│   └── dialogs/
│       └── [可选] create_order_dialogs.dart  (NEW - 如需额外对话框)
└── services/
    └── order_service.dart                    (已修复)
```

---

## 10. 优先级与迭代计划

### MVP（最小可行产品）- 第一阶段
- [x] OrderCreateScreen 基础表单
- [x] 表单验证与提交
- [x] OrderCreateSuccessScreen
- [x] 两处页面入口

### 后续迭代 - 第二阶段（可选）
- [ ] 表单草稿保存（本地缓存）
- [ ] 上传订单图片
- [ ] 订单模板（快速复制上一次订单）
- [ ] 批量创建订单

---

## 附录：表单字段参考

| 字段名 | 类型 | 必填 | 默认值 | 验证规则 |
|--------|------|------|--------|---------|
| type | Enum | Y | farmer→sell, buyer→buy | in:sell,buy |
| product_name | String | Y | - | 2-50字符 |
| quantity | Double | Y | - | >0 |
| unit | String | Y | - | in:[kg,t,斤,箱,件,束,盒] |
| price_per_unit | Double | Y | - | >0, 2位小数 |
| quality_level | String | Y | 一级 | in:[特级,一级,二级] |
| scheduled_delivery_time | DateTime | N | - | ≥today |
| delivery_method | String | N | - | in:[自提,物流配送,双方协商] |
| notes | String | N | - | ≤500字符 |

---

**文档版本**: 1.0
**最后更新**: 2026-04-13
**状态**: 待实现
