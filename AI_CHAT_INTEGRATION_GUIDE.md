# AI 聊天页面支付集成指南

## 概述

本文档说明如何在现有的 `AiChatScreen` 中集成成交确认对话框和支付流程。

## 所需修改

### 1. 导入新组件

在 `lib/screens/dispatch/ai_chat_screen.dart` 顶部添加：

```dart
import 'package:needs_app/widgets/dialogs/confirm_trade_dialog.dart';
import 'package:needs_app/widgets/bottom_sheets/payment_bottom_sheet.dart';
import 'package:needs_app/services/order_service.dart';
import 'package:needs_app/services/delivery_service.dart';
```

### 2. 在 State 类中添加成员变量

在 `_AiChatScreenState` 类中添加：

```dart
final DeliveryService _deliveryService = DeliveryService();
final OrderService _orderService = OrderService();
double _deliveryFee = 80;
```

### 3. 修改 MatchCard 点击处理

在显示匹配卡片的代码中，为"确认成交"按钮添加点击处理：

```dart
// 当渲染 MatchCard 时，添加点击处理
onConfirmTradePressed: (matchedOrder, userOrder) async {
  _showTradeConfirmDialog(matchedOrder, userOrder);
}
```

### 4. 添加成交确认方法

在 `_AiChatScreenState` 类中添加以下方法：

```dart
/// 显示成交确认对话框
void _showTradeConfirmDialog(
  Map<String, dynamic> matchedOrder,
  Map<String, dynamic> userOrder,
) {
  final counterpartyName = matchedOrder['farmer']?['name'] ??
                           matchedOrder['buyer']?['name'] ??
                           '未知用户';
  final productName = matchedOrder['product_name'] ?? '未知商品';
  final quantity = (matchedOrder['quantity'] as num?)?.toDouble() ?? 0.0;
  final unit = matchedOrder['unit'] ?? '斤';
  final pricePerUnit = (matchedOrder['price_per_unit'] as num?)?.toDouble() ?? 0.0;

  showDialog(
    context: context,
    builder: (context) => ConfirmTradeDialog(
      counterpartyName: counterpartyName,
      productName: productName,
      quantity: quantity,
      unit: unit,
      pricePerUnit: pricePerUnit,
      onConfirmed: () async {
        // 确认配对
        final updateResult = await _orderService.updateOrder(
          userOrder['id'],
          matchedOrderId: matchedOrder['id'],
        );

        if (updateResult['success']) {
          // 显示支付弹窗
          final orderAmount = ((userOrder['total_amount'] as num?)?.toDouble() ?? 0.0);
          _showPaymentBottomSheet(userOrder['id'], orderAmount);
        } else {
          Get.snackbar('错误', updateResult['message'] ?? '确认成交失败');
        }
      },
      onCancel: () {},
    ),
  );
}

/// 显示支付弹窗
void _showPaymentBottomSheet(int orderId, double orderAmount) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => PaymentBottomSheet(
      orderId: orderId,
      orderAmount: orderAmount,
      deliveryFee: _deliveryFee,
      onPaymentSuccess: () {
        Get.back(); // 关闭支付弹窗
        Get.snackbar('成功', '支付完成，成交已生效');
        // 可选：刷新聊天内容
      },
    ),
  );
}
```

## 实现步骤

1. 在 `AiChatScreen` 中复制上述导入和成员变量
2. 在显示 MatchCard 的地方集成点击处理
3. 添加上述两个方法到 State 类
4. 测试完整的支付流程

## 注意事项

- MatchCard 组件需要支持 `onConfirmTradePressed` 回调（可能需要修改 MatchCard 组件）
- 确保 OrderService 的 updateOrder 方法能被正确调用
- 支付流程会自动处理弹窗关闭和状态检查

## 后续测试

1. 在 AI 聊天中生成匹配卡片
2. 点击"确认成交"按钮
3. 确认成交信息对话框显示正确
4. 点击"确认成交"进入支付流程
5. 验证支付弹窗显示正确的总额
