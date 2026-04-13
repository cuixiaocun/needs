# 订单支付和交货流程实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 实现完整的订单支付和交货流程，包括订单详情支付、AI 匹配卡片支付，以及支付宝集成。

**Architecture:**
- 后端提供交货费用 API 和支付状态查询
- 前端用模态框实现支付流程（交货确认 → 支付弹窗）
- 三个独立的对话框组件分别处理不同场景（订单支付、交货确认、成交确认）
- 支付弹窗统一处理支付宝链接生成和状态轮询

**Tech Stack:**
- 后端：Laravel, PHP 8.1+
- 前端：Flutter, GetX 状态管理, Dio HTTP 客户端
- 支付：支付宝官方 SDK（已集成）

---

## 文件结构映射

### 后端文件
- 新建：`app/Services/DeliveryService.php` - 交货费用和地点服务
- 新建：`app/Http/Controllers/DeliveryController.php` - 交货 API 端点
- 修改：`routes/api.php` - 添加交货 API 路由
- 修改：`app/Models/Order.php` - 添加关联关系（可选）

### 前端文件
- 新建：`lib/widgets/dialogs/delivery_confirm_dialog.dart` - 交货确认对话框
- 新建：`lib/widgets/bottom_sheets/payment_bottom_sheet.dart` - 支付弹窗
- 新建：`lib/widgets/dialogs/confirm_trade_dialog.dart` - 成交确认对话框
- 新建：`lib/services/payment_service.dart` - 支付服务
- 新建：`lib/services/delivery_service.dart` - 交货费用服务
- 修改：`lib/screens/order/order_detail_screen.dart` - 集成支付流程
- 修改：`lib/screens/dispatch/ai_chat_screen.dart` - 集成匹配卡片支付
- 修改：`lib/services/order_service.dart` - 添加订单更新 API

---

## 任务清单

### Task 1: 后端 - 创建交货服务 (DeliveryService)

**Files:**
- Create: `needs-api/app/Services/DeliveryService.php`

- [ ] **Step 1: 创建 DeliveryService 类**

编辑 `needs-api/app/Services/DeliveryService.php`：

```php
<?php

namespace App\Services;

/**
 * 交货信息服务
 */
class DeliveryService
{
    /**
     * 默认交货地点
     */
    const DEFAULT_LOCATION = '集散市场中转';

    /**
     * 默认运费（单位：元）
     */
    const DEFAULT_FEE = 80;

    /**
     * 获取交货信息
     *
     * @return array
     */
    public function getDeliveryInfo()
    {
        return [
            'location' => self::DEFAULT_LOCATION,
            'fee' => self::DEFAULT_FEE,
            'description' => '标准物流运费'
        ];
    }

    /**
     * 获取交货费用
     *
     * @return int
     */
    public function getDeliveryFee()
    {
        return self::DEFAULT_FEE;
    }

    /**
     * 获取交货地点
     *
     * @return string
     */
    public function getDeliveryLocation()
    {
        return self::DEFAULT_LOCATION;
    }
}
```

- [ ] **Step 2: 提交**

```bash
git add needs-api/app/Services/DeliveryService.php
git commit -m "feat: 创建交货费用服务"
```

---

### Task 2: 后端 - 创建交货 API 控制器 (DeliveryController)

**Files:**
- Create: `needs-api/app/Http/Controllers/DeliveryController.php`

- [ ] **Step 1: 创建 DeliveryController 类**

编辑 `needs-api/app/Http/Controllers/DeliveryController.php`：

```php
<?php

namespace App\Http\Controllers;

use App\Services\DeliveryService;

/**
 * 交货信息控制器
 */
class DeliveryController extends Controller
{
    private DeliveryService $deliveryService;

    public function __construct(DeliveryService $deliveryService)
    {
        $this->deliveryService = $deliveryService;
    }

    /**
     * 获取交货信息和费用
     *
     * GET /api/delivery/fee
     */
    public function getFee()
    {
        $info = $this->deliveryService->getDeliveryInfo();

        return response()->json([
            'success' => true,
            'data' => $info
        ]);
    }
}
```

- [ ] **Step 2: 提交**

```bash
git add needs-api/app/Http/Controllers/DeliveryController.php
git commit -m "feat: 创建交货 API 控制器"
```

---

### Task 3: 后端 - 添加交货 API 路由

**Files:**
- Modify: `needs-api/routes/api.php`

- [ ] **Step 1: 在路由文件中添加交货路由**

找到 `needs-api/routes/api.php`，在 API 路由组中添加：

```php
// 交货费用
Route::get('/delivery/fee', [\App\Http\Controllers\DeliveryController::class, 'getFee']);
```

完整的位置应该类似于：

```php
Route::middleware('auth:sanctum')->group(function () {
    // ... 其他路由 ...

    // 交货费用
    Route::get('/delivery/fee', [\App\Http\Controllers\DeliveryController::class, 'getFee']);
});
```

- [ ] **Step 2: 验证路由**

运行：
```bash
cd needs-api && php artisan route:list | grep delivery
```

预期输出应显示：
```
GET       /api/delivery/fee
```

- [ ] **Step 3: 提交**

```bash
git add needs-api/routes/api.php
git commit -m "feat: 添加交货 API 路由"
```

---

### Task 4: 前端 - 创建交货确认对话框

**Files:**
- Create: `needs_app/lib/widgets/dialogs/delivery_confirm_dialog.dart`

- [ ] **Step 1: 创建目录和文件**

```bash
mkdir -p needs_app/lib/widgets/dialogs
touch needs_app/lib/widgets/dialogs/delivery_confirm_dialog.dart
```

- [ ] **Step 2: 编写 DeliveryConfirmDialog 组件**

编辑 `needs_app/lib/widgets/dialogs/delivery_confirm_dialog.dart`：

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/colors.dart';

/// 交货确认对话框
/// 显示交货地点和运费，用户确认后将触发支付流程
class DeliveryConfirmDialog extends StatelessWidget {
  final int orderId;
  final double orderAmount;
  final double deliveryFee;
  final VoidCallback onConfirmed;

  const DeliveryConfirmDialog({
    super.key,
    required this.orderId,
    required this.orderAmount,
    required this.deliveryFee,
    required this.onConfirmed,
  });

  @override
  Widget build(BuildContext context) {
    final totalAmount = orderAmount + deliveryFee;

    return AlertDialog(
      title: const Text('确认交货信息'),
      contentPadding: const EdgeInsets.all(24),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('📍 交货地点', '集散市场中转'),
            const SizedBox(height: 16),
            _buildInfoRow('📦 运费', '¥${deliveryFee.toStringAsFixed(2)}'),
            const Divider(height: 24),
            _buildTotalRow('合计金额', totalAmount),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
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
          child: const Text('确认并支付'),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildTotalRow(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text(
          '¥${amount.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 3: 提交**

```bash
git add needs_app/lib/widgets/dialogs/delivery_confirm_dialog.dart
git commit -m "feat: 创建交货确认对话框组件"
```

---

### Task 5: 前端 - 创建支付弹窗组件

**Files:**
- Create: `needs_app/lib/widgets/bottom_sheets/payment_bottom_sheet.dart`

- [ ] **Step 1: 创建目录和文件**

```bash
mkdir -p needs_app/lib/widgets/bottom_sheets
touch needs_app/lib/widgets/bottom_sheets/payment_bottom_sheet.dart
```

- [ ] **Step 2: 编写 PaymentBottomSheet 组件**

编辑 `needs_app/lib/widgets/bottom_sheets/payment_bottom_sheet.dart`：

```dart
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
```

- [ ] **Step 3: 提交**

```bash
git add needs_app/lib/widgets/bottom_sheets/payment_bottom_sheet.dart
git commit -m "feat: 创建支付弹窗组件"
```

---

### Task 6: 前端 - 创建支付服务 (PaymentService)

**Files:**
- Create: `needs_app/lib/services/payment_service.dart`

- [ ] **Step 1: 编写 PaymentService**

编辑 `needs_app/lib/services/payment_service.dart`：

```dart
import 'package:dio/dio.dart';
import '../config/app_config.dart';
import 'storage_service.dart';

class PaymentService {
  final Dio _dio;
  final StorageService _storageService;

  PaymentService({Dio? dio, StorageService? storageService})
      : _dio = dio ?? Dio(),
        _storageService = storageService ?? StorageService() {
    _setupDio();
  }

  void _setupDio() {
    _dio.options = BaseOptions(
      baseUrl: AppConfig.currentApiBaseUrl,
      connectTimeout: Duration(seconds: AppConfig.apiTimeout),
      receiveTimeout: Duration(seconds: AppConfig.apiTimeout),
      sendTimeout: Duration(seconds: AppConfig.apiTimeout),
      validateStatus: (status) => status! < 500,
    );

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = _storageService.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }

  /// 创建支付宝支付链接
  Future<Map<String, dynamic>> createAlipayment(int orderId) async {
    try {
      final response = await _dio.post(
        '/payment/alipay',
        data: {'order_id': orderId},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true) {
          return {
            'success': true,
            'payment_url': data['payment_url'],
          };
        } else {
          return {
            'success': false,
            'message': data['message'] ?? '生成支付链接失败',
          };
        }
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? '支付链接生成失败',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': '错误：${e.toString()}',
      };
    }
  }

  /// 检查订单支付状态
  Future<Map<String, dynamic>> checkPaymentStatus(int orderId) async {
    try {
      final response = await _dio.get('/ai/status/$orderId');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true) {
          return {
            'success': true,
            'status': data['data']['status'],
            'order_status': data['data']['order_status'],
          };
        } else {
          return {
            'success': false,
            'message': data['message'] ?? '获取状态失败',
          };
        }
      } else {
        return {
          'success': false,
          'message': '获取状态失败',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': '错误：${e.toString()}',
      };
    }
  }
}
```

- [ ] **Step 2: 提交**

```bash
git add needs_app/lib/services/payment_service.dart
git commit -m "feat: 创建支付服务"
```

---

### Task 7: 前端 - 创建交货服务 (DeliveryService)

**Files:**
- Create: `needs_app/lib/services/delivery_service.dart`

- [ ] **Step 1: 编写 DeliveryService**

编辑 `needs_app/lib/services/delivery_service.dart`：

```dart
import 'package:dio/dio.dart';
import '../config/app_config.dart';
import 'storage_service.dart';

class DeliveryService {
  final Dio _dio;
  final StorageService _storageService;

  DeliveryService({Dio? dio, StorageService? storageService})
      : _dio = dio ?? Dio(),
        _storageService = storageService ?? StorageService() {
    _setupDio();
  }

  void _setupDio() {
    _dio.options = BaseOptions(
      baseUrl: AppConfig.currentApiBaseUrl,
      connectTimeout: Duration(seconds: AppConfig.apiTimeout),
      receiveTimeout: Duration(seconds: AppConfig.apiTimeout),
      sendTimeout: Duration(seconds: AppConfig.apiTimeout),
      validateStatus: (status) => status! < 500,
    );

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = _storageService.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }

  /// 获取交货费用和地点
  Future<Map<String, dynamic>> getDeliveryFee() async {
    try {
      final response = await _dio.get('/delivery/fee');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true) {
          final deliveryData = data['data'] as Map<String, dynamic>;
          return {
            'success': true,
            'location': deliveryData['location'] ?? '集散市场中转',
            'fee': (deliveryData['fee'] ?? 80).toDouble(),
            'description': deliveryData['description'] ?? '标准物流运费',
          };
        } else {
          return {
            'success': false,
            'message': data['message'] ?? '获取交货信息失败',
          };
        }
      } else {
        return {
          'success': false,
          'message': '获取交货信息失败',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': '错误：${e.toString()}',
      };
    }
  }
}
```

- [ ] **Step 2: 提交**

```bash
git add needs_app/lib/services/delivery_service.dart
git commit -m "feat: 创建交货服务"
```

---

### Task 8: 前端 - 创建成交确认对话框

**Files:**
- Create: `needs_app/lib/widgets/dialogs/confirm_trade_dialog.dart`

- [ ] **Step 1: 编写 ConfirmTradeDialog**

编辑 `needs_app/lib/widgets/dialogs/confirm_trade_dialog.dart`：

```dart
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
```

- [ ] **Step 2: 提交**

```bash
git add needs_app/lib/widgets/dialogs/confirm_trade_dialog.dart
git commit -m "feat: 创建成交确认对话框组件"
```

---

### Task 9: 前端 - 修改订单服务添加更新 API

**Files:**
- Modify: `needs_app/lib/services/order_service.dart`

- [ ] **Step 1: 添加订单更新方法**

在 `needs_app/lib/services/order_service.dart` 的 `OrderService` 类中添加：

```dart
  /// 更新订单（用于确认配对）
  Future<Map<String, dynamic>> updateOrder(
    int orderId, {
    int? matchedOrderId,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (matchedOrderId != null) {
        data['matched_order_id'] = matchedOrderId;
      }

      final response = await _dio.patch(
        '/orders/$orderId',
        data: data,
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData['success'] == true) {
          return {
            'success': true,
            'data': responseData['data'],
          };
        } else {
          return {
            'success': false,
            'message': responseData['message'] ?? '更新订单失败',
          };
        }
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? '更新订单失败',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': '错误：${e.toString()}',
      };
    }
  }
```

- [ ] **Step 2: 提交**

```bash
git add needs_app/lib/services/order_service.dart
git commit -m "feat: 订单服务添加更新接口"
```

---

### Task 10: 前端 - 修改订单详情页集成支付流程

**Files:**
- Modify: `needs_app/lib/screens/order/order_detail_screen.dart`

- [ ] **Step 1: 导入需要的组件和服务**

在文件顶部添加导入：

```dart
import 'package:needs_app/widgets/dialogs/delivery_confirm_dialog.dart';
import 'package:needs_app/widgets/bottom_sheets/payment_bottom_sheet.dart';
import 'package:needs_app/services/delivery_service.dart';
```

- [ ] **Step 2: 修改 _OrderDetailScreenState 添加成员变量**

在 `_OrderDetailScreenState` 类中添加：

```dart
  final DeliveryService _deliveryService = DeliveryService();
  double _deliveryFee = 80; // 默认运费
```

- [ ] **Step 3: 修改 _buildActionButtons 方法**

找到原来的 `_buildActionButtons()` 方法，完全替换为：

```dart
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
```

- [ ] **Step 4: 添加支付流程方法**

在 `_OrderDetailScreenState` 类中添加：

```dart
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
```

- [ ] **Step 5: 提交**

```bash
git add needs_app/lib/screens/order/order_detail_screen.dart
git commit -m "feat: 订单详情页集成支付流程"
```

---

### Task 11: 前端 - 修改 AI 聊天页面集成匹配卡片支付

**Files:**
- Modify: `needs_app/lib/screens/dispatch/ai_chat_screen.dart`

- [ ] **Step 1: 导入需要的组件和服务**

在文件顶部添加导入：

```dart
import 'package:needs_app/widgets/dialogs/confirm_trade_dialog.dart';
import 'package:needs_app/widgets/bottom_sheets/payment_bottom_sheet.dart';
import 'package:needs_app/services/order_service.dart';
import 'package:needs_app/services/delivery_service.dart';
```

- [ ] **Step 2: 在 AI 聊天页面中处理匹配卡片点击**

找到显示匹配卡片的代码（通常在 `_buildChatBubble` 或类似方法中），在匹配卡片的按钮点击处理中添加：

```dart
final deliveryService = DeliveryService();
final orderService = OrderService();

// 当用户点击 MatchCard 中的"确认成交"按钮时
onConfirmTradePressed: (matchedOrder, userOrder) async {
  // 获取交货费用
  final deliveryResult = await deliveryService.getDeliveryFee();
  final deliveryFee = deliveryResult['fee'] ?? 80.0;

  // 显示成交确认对话框
  showDialog(
    context: context,
    builder: (context) => ConfirmTradeDialog(
      counterpartyName: matchedOrder['farmer']?['name'] ?? '未知用户',
      productName: matchedOrder['product_name'] ?? '未知商品',
      quantity: (matchedOrder['quantity'] as num?)?.toDouble() ?? 0.0,
      unit: matchedOrder['unit'] ?? '斤',
      pricePerUnit: (matchedOrder['price_per_unit'] as num?)?.toDouble() ?? 0.0,
      onConfirmed: () async {
        // 确认配对
        final updateResult = await orderService.updateOrder(
          userOrder['id'],
          matchedOrderId: matchedOrder['id'],
        );

        if (updateResult['success']) {
          // 显示支付弹窗
          final totalAmount = ((userOrder['total_amount'] as num?)?.toDouble() ?? 0.0) + deliveryFee;
          _showPaymentBottomSheet(userOrder['id'], userOrder['total_amount'], deliveryFee);
        } else {
          Get.snackbar('错误', updateResult['message'] ?? '确认成交失败');
        }
      },
      onCancel: () {},
    ),
  );
}
```

- [ ] **Step 3: 添加支付弹窗显示方法**

在 AI 聊天页面的 State 类中添加：

```dart
  final DeliveryService _deliveryService = DeliveryService();

  /// 显示支付弹窗
  void _showPaymentBottomSheet(int orderId, double orderAmount, double deliveryFee) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => PaymentBottomSheet(
        orderId: orderId,
        orderAmount: orderAmount,
        deliveryFee: deliveryFee,
        onPaymentSuccess: () {
          Get.back(); // 关闭支付弹窗
          Get.snackbar('成功', '支付完成，成交已生效');
          // 可选：刷新聊天内容
        },
      ),
    );
  }
```

- [ ] **Step 4: 提交**

```bash
git add needs_app/lib/screens/dispatch/ai_chat_screen.dart
git commit -m "feat: AI 聊天页面集成匹配卡片支付流程"
```

---

### Task 12: 后端 - 验证支付 API 正常工作

**Files:**
- Existing: `needs-api/app/Http/Controllers/PaymentController.php`

- [ ] **Step 1: 验证支付宝集成配置**

确认 `config/services.php` 或 `.env` 中有支付宝配置：

```bash
grep -r "alipay\|payment" /Users/cuixiaocun/Desktop/我的思路/needs/needs-api/.env
```

应该包含类似：
```
ALIPAY_APP_ID=xxx
ALIPAY_PRIVATE_KEY=xxx
ALIPAY_PUBLIC_KEY=xxx
```

- [ ] **Step 2: 验证路由**

确保支付 API 路由存在：

```bash
cd /Users/cuixiaocun/Desktop/我的思路/needs/needs-api
php artisan route:list | grep payment
```

预期输出应包含：
```
POST      /api/payment/alipay
POST      /api/payment/notify
```

- [ ] **Step 3: 测试支付链接生成**

使用 Postman 或 curl 测试（需要有效的认证 token）：

```bash
curl -X POST http://localhost:8000/api/payment/alipay \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"order_id": 1}'
```

预期响应：
```json
{
  "success": true,
  "payment_url": "https://payment.alipay.com/..."
}
```

- [ ] **Step 4: 测试订单更新 API (可选)**

确保后端支持 PATCH /api/orders/{id}：

```bash
cd /Users/cuixiaocun/Desktop/我的思路/needs/needs-api
php artisan route:list | grep -E "PATCH|PUT.*orders"
```

如果不存在，在 `OrderController` 中添加 `update()` 方法。

- [ ] **Step 5: 提交**

```bash
git add -A
git commit -m "test: 验证支付 API 配置和路由"
```

---

### Task 13: 测试 - 集成测试订单详情支付流程

**Files:**
- Test: 手动测试

- [ ] **Step 1: 启动后端服务**

```bash
cd /Users/cuixiaocun/Desktop/我的思路/needs/needs-api
php artisan serve
```

- [ ] **Step 2: 启动前端应用**

```bash
cd /Users/cuixiaocun/Desktop/我的思路/needs/needs_app
flutter run
```

- [ ] **Step 3: 执行测试流程**

1. 在 app 中登录
2. 进入"我的订单"
3. 选择一个"待匹配"状态的订单
4. 点击"立即支付"
5. 验证交货确认对话框显示正确的地点和运费
6. 点击"确认并支付"
7. 验证支付弹窗显示正确的总额
8. 验证"跳转支付宝"按钮可点击

- [ ] **Step 4: 记录测试结果**

测试场景：
- ✅ 交货确认对话框正确显示
- ✅ 支付弹窗显示正确金额
- ✅ 支付宝链接生成成功
- ✅ 支付完成后状态更新

- [ ] **Step 5: 提交**

```bash
git add -A
git commit -m "test: 订单详情支付流程集成测试通过"
```

---

### Task 14: 测试 - AI 匹配卡片支付流程

**Files:**
- Test: 手动测试

- [ ] **Step 1: 准备测试数据**

确保有至少两个用户创建的订单，且互相匹配。

- [ ] **Step 2: 执行 AI 匹配流程**

1. 使用用户 A 登录，进入 AI 对话
2. 输入"我要卖 100 斤青菜，12 元一斤"
3. 使用用户 B 登录，输入"我要买 100 斤青菜，12 元一斤"
4. 验证 AI 找到匹配并显示 MatchCard
5. 点击 MatchCard 中的"确认成交"

- [ ] **Step 3: 验证成交确认对话框**

- ✅ 显示对方名字
- ✅ 显示商品信息
- ✅ 显示正确的总额

- [ ] **Step 4: 完成支付**

1. 点击"确认成交"
2. 验证支付弹窗打开
3. 点击"跳转支付宝"
4. 完成支付后验证订单状态更新

- [ ] **Step 5: 提交**

```bash
git add -A
git commit -m "test: AI 匹配卡片支付流程集成测试通过"
```

---

## 验证清单

在声称实现完成前，检查以下内容：

- [ ] 后端 API：GET /api/delivery/fee 返回正确格式
- [ ] 后端 API：POST /api/payment/alipay 返回支付链接
- [ ] 后端 API：POST /api/payment/notify 正确处理回调
- [ ] 后端 API：PATCH /api/orders/{id} 支持更新（如果新增）
- [ ] 前端：订单详情页"立即支付"按钮可点击
- [ ] 前端：交货确认对话框显示地点和运费
- [ ] 前端：支付弹窗显示正确的总额和支付宝链接
- [ ] 前端：支付成功后订单状态更新为 confirmed
- [ ] 前端：AI 匹配卡片"确认成交"按钮可点击
- [ ] 前端：成交确认对话框显示正确信息
- [ ] 数据库：订单状态更新逻辑正确
- [ ] 日志：所有支付操作都有日志记录

---

## 已知限制和后续改进

1. **运费硬编码为 80 元** — 后续可通过配置管理
2. **不支持退款** — 后续可添加退款流程
3. **不支持其他支付方式** — 可扩展支持微信、银行卡等
4. **轮询机制简化** — 每 10 秒检查一次，最多 5 分钟

---

**计划完成日期**: 2026-04-13
**预期完成时间**: 2-3 小时（取决于是否需要调试）
**优先级**: 高
