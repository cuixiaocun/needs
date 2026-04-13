# 订单支付和交货流程设计规范

**日期**: 2026-04-13
**项目**: 农产品供需撮合平台
**功能**: 订单支付集成 + 交货流程
**版本**: 1.0

---

## 1. 需求概述

实现完整的订单支付和交货流程，包括三个核心路径：
1. **订单详情页支付** — 用户在订单详情页直接发起支付
2. **交货流程** — 支付前确认交货地点和运费
3. **AI 匹配卡片支付** — AI 挂单系统中的成交支付

### 方案选择
- **支付方式**: 支付宝集成（后端已有 PaymentController）
- **UI 交互**: 模态框弹出（支付弹窗）
- **交货地点**: 固定预设（集散市场中转，运费固定）
- **用户确认**: 支付前必须确认交货信息

---

## 2. 系统架构

### 2.1 架构图

```
前端 (Flutter)
├── OrderDetailScreen
│   ├── [立即支付] 按钮
│   ├── DeliveryConfirmDialog（交货确认）
│   └── PaymentBottomSheet（支付弹窗）
├── AiChatScreen
│   ├── MatchCard（匹配卡片显示）
│   ├── ConfirmTradeDialog（成交确认）
│   └── PaymentBottomSheet（支付弹窗）
└── 共享组件
    └── PaymentBottomSheet

后端 (Laravel)
├── PaymentController (现有)
│   ├── createAlipayment(order_id) → payment_url
│   └── alipayNotify() → 订单状态更新
├── OrderController (现有)
│   ├── index() → 订单列表
│   └── show(id) → 订单详情
├── AiChatController (现有)
│   └── getStatus(orderId) → 订单状态
└── DeliveryService (新增)
    └── getDeliveryInfo() → 固定地点和运费
```

### 2.2 核心数据流

**订单状态机**:
```
pending (待匹配/待支付)
  ↓
confirmed (已支付，待交货)
  ↓
receiving (收货中)
  ↓
received (已收货)
  ↓
completed (完成)
```

---

## 3. 前端设计

### 3.1 组件清单

#### PaymentBottomSheet（支付弹窗 - 可复用）
**职责**: 显示支付信息和支付宝链接

**输入参数**:
- `orderId`: int - 订单 ID
- `orderAmount`: double - 订单金额
- `deliveryFee`: double - 运费（默认 80）
- `onPaymentSuccess`: VoidCallback - 支付成功回调

**状态**:
- `isLoading`: 正在生成支付链接
- `paymentUrl`: 支付宝链接
- `errorMessage`: 错误信息
- `isCheckingStatus`: 轮询中

**UI 流程**:
```
1. 显示费用明细
   - 订单金额
   - 运费
   - 合计（红色强调）

2. "跳转支付宝" 按钮
   - 调用 PaymentController::createAlipayment()
   - 生成支付链接 → 跳转浏览器

3. 支付后自动轮询
   - 调用 AiChatController::getStatus()
   - 检查 order.status 是否为 confirmed
   - 成功显示"支付成功，订单已确认"
   - 失败允许用户关闭弹窗
```

#### DeliveryConfirmDialog（交货确认对话框）
**职责**: 显示并确认交货信息

**输入参数**:
- `orderId`: int
- `orderAmount`: double

**显示内容**:
- 📍 地点：集散市场中转
- 📦 运费：¥80（可配置）
- 合计：orderAmount + 运费

**按钮**:
- "确认并支付" → 打开 PaymentBottomSheet
- "返回" → 关闭对话框

#### ConfirmTradeDialog（成交确认对话框 - AI 匹配专用）
**职责**: 确认与对方成交

**输入参数**:
- `userOrder`: Order - 用户自己的订单
- `matchedOrder`: Order - 匹配到的订单
- `counterpartyUser`: User - 对方用户信息

**显示内容**:
```
确认与 [对方名字] 成交

商品: [产品名]
数量: [用户数量] 斤
单价: ¥[单价]/斤

合计: ¥[总额]
```

**按钮**:
- "确认成交" → 更新订单 → 打开 PaymentBottomSheet
- "返回" → 关闭对话框

### 3.2 UI 更新项

**OrderDetailScreen**:
- 修改"查看交货流程"按钮 → 改为"立即支付"
- 点击"立即支付" → 打开 DeliveryConfirmDialog

**AiChatScreen**:
- MatchCard 增加"确认成交"按钮
- 点击"确认成交" → 打开 ConfirmTradeDialog

---

## 4. 后端 API 设计

### 4.1 现有 API（验证可用性）

#### POST /api/payment/alipay
**已有**，需验证

```php
Request:
{
  "order_id": 123
}

Response:
{
  "success": true,
  "payment_url": "https://payment.alipay.com/..."
}
```

**验证项**:
- ✅ 订单权限检查（farmer_id 或 buyer_id）
- ✅ 订单状态检查（应为 pending）
- ✅ 支付宝集成正常

#### POST /api/payment/notify (支付宝回调)
**已有**，无需改动

```php
Alipay 回调参数处理：
- 验证签名
- 提取 trade_no 和 trade_status
- 更新 Order: status = 'confirmed'
- 记录 trade_no 到订单（可选）
```

#### GET /api/ai/status/{orderId}
**已有**，无需改动

```php
Response:
{
  "success": true,
  "data": {
    "order_id": 123,
    "status": "pending|success|failed",
    "order_status": "pending|confirmed|..."
  }
}
```

### 4.2 新增 API

#### GET /api/delivery/fee
**新增**

```php
Request:
无参数

Response:
{
  "success": true,
  "data": {
    "location": "集散市场中转",
    "fee": 80,
    "description": "标准物流运费"
  }
}
```

**说明**:
- 返回固定的交货地点和运费
- 可在配置中修改费用值
- 前端调用此 API 获取当前运费

#### PATCH /api/orders/{orderId} (可选)
**用于 AI 匹配成交确认**

```php
Request:
{
  "matched_order_id": 456,  // 配对订单 ID
  "status": "pending"  // 保持 pending，等待支付
}

Response:
{
  "success": true,
  "data": { ... order data ... }
}
```

### 4.3 数据库表调整（可选）

**orders 表新增字段**（可选，用于跟踪支付和配对）:
```sql
ALTER TABLE orders ADD COLUMN (
  trade_no VARCHAR(50) NULL,           -- 支付宝交易号
  payment_time TIMESTAMP NULL,          -- 支付时间
  matched_order_id INT NULL,            -- 配对订单 ID
  confirmed_at TIMESTAMP NULL           -- 成交确认时间
);
```

---

## 5. 数据流详解

### 5.1 订单详情页支付流程

```
OrderDetailScreen
  ↓
[立即支付] 按钮点击
  ↓
DeliveryConfirmDialog 弹出
  显示：地点 + 运费 + 合计金额
  ↓
用户点击"确认并支付"
  ↓
PaymentBottomSheet 弹出
  调用 POST /api/payment/alipay
    ↓ 返回 payment_url
  显示支付宝链接
  ↓
用户点击"跳转支付宝"
  → 打开支付宝 web 视图
  ↓
用户完成支付
  → 支付宝回调后端 /api/payment/notify
    (Order.status 更新为 'confirmed')
  → 重定向回 app
  ↓
PaymentBottomSheet 轮询 GET /api/ai/status/{orderId}
  检查 order.status 是否为 'confirmed'
  ↓
成功 → 显示"支付成功，订单已确认"
失败 → 显示错误，允许重试或关闭
```

### 5.2 AI 匹配卡片支付流程

```
AiChatScreen (MatchCard 显示)
  ↓
[确认成交] 按钮点击
  ↓
ConfirmTradeDialog 弹出
  显示：对方信息 + 商品 + 成交额
  ↓
用户点击"确认成交"
  ↓
后端更新订单（PATCH /api/orders/{orderId}）
  matched_order_id = xxx
  confirmed_at = now()
  ↓
PaymentBottomSheet 弹出（同订单详情流程）
  ↓
[后续流程与 5.1 相同]
```

---

## 6. 错误处理

### 6.1 异常场景和处理策略

| 场景 | HTTP 状态码 | 用户提示 | 处理方式 |
|------|-----------|--------|--------|
| 生成支付链接失败 | 500 | "支付服务暂时不可用，请稍后重试" | 显示重试按钮 |
| 订单不存在 | 404 | "订单不存在或已删除" | 返回订单列表 |
| 无订单权限 | 403 | "无权操作此订单" | 返回订单列表 |
| 订单状态异常 | 422 | "订单状态异常，无法支付" | 刷新订单详情 |
| 网络连接失败 | N/A | "网络异常，请检查连接" | 显示重试按钮 |
| 轮询超时（5min） | N/A | "支付状态检查超时，请手动刷新订单" | 关闭弹窗 |
| 用户取消支付 | N/A | "已取消支付，返回订单详情" | 关闭弹窗 |

### 6.2 重试机制

- **支付链接生成失败**: 允许用户无限重试
- **轮询失败**: 最多轮询 5 分钟，之后提示手动检查
- **网络超时**: 显示"重试"按钮，最多 3 次

---

## 7. 支付流程技术细节

### 7.1 支付宝集成确认事项

**后端需要验证**:
- ✅ 支付宝应用 ID 和密钥配置正确
- ✅ 回调 URL 配置：`/api/payment/notify`
- ✅ 回调签名验证逻辑完整
- ✅ 支付成功后的订单状态更新逻辑

**前端需要处理**:
- ✅ 支付宝链接的打开方式（系统浏览器或 WebView）
- ✅ 支付完成后的重定向检测
- ✅ 轮询状态时的超时和重试逻辑

### 7.2 前端轮询实现

```dart
Future<void> _checkPaymentStatus() async {
  for (int i = 0; i < 30; i++) { // 最多 30 次，每次 10 秒
    await Future.delayed(Duration(seconds: 10));

    final result = await _aiChatService.getOrderStatus(orderId);
    if (result['success'] && result['order_status'] == 'confirmed') {
      // 支付成功
      _showPaymentSuccess();
      break;
    }

    if (i == 29) {
      // 超时
      _showPaymentTimeout();
    }
  }
}
```

---

## 8. 关键业务规则

1. **支付必须成功后才能进行后续交货** — 订单状态必须从 pending → confirmed
2. **交货地点固定** — 所有订单运费相同，地点固定为"集散市场中转"
3. **运费在支付时包含** — 最终金额 = 订单金额 + 运费
4. **AI 匹配订单的特殊性** — 配对信息在支付成功后才生效
5. **权限隔离** — 用户只能支付自己的订单（farmer_id 或 buyer_id 匹配）

---

## 9. 测试清单

### 9.1 前端测试
- [ ] 订单详情页点击支付 → 交货确认对话框正常显示
- [ ] 确认并支付 → 支付弹窗正常显示
- [ ] 支付弹窗显示正确的金额（订单金额 + 运费）
- [ ] 跳转支付宝 → 打开浏览器/WebView 成功
- [ ] 支付完成 → 弹窗自动轮询状态
- [ ] 订单状态更新 → 弹窗显示成功提示
- [ ] AI 匹配卡片点击成交 → 确认对话框正常显示
- [ ] 确认成交 → 支付流程启动

### 9.2 后端测试
- [ ] createAlipayment 返回有效的支付宝链接
- [ ] alipayNotify 正确处理支付回调
- [ ] 订单状态更新为 confirmed
- [ ] 权限验证工作正常
- [ ] 支付宝签名验证正确

### 9.3 集成测试
- [ ] 完整支付流程（点击支付 → 支付宝 → 状态更新）
- [ ] AI 匹配支付流程
- [ ] 错误场景处理（网络异常、支付失败等）
- [ ] 并发支付处理（同一订单多次点击）

---

## 10. 实现优先级

1. **第一阶段**: 订单详情页支付（最高优先）
   - DeliveryConfirmDialog
   - PaymentBottomSheet
   - API 集成测试

2. **第二阶段**: AI 匹配卡片支付
   - ConfirmTradeDialog
   - 订单配对逻辑

3. **第三阶段**: 优化和完善
   - 运费配置化
   - 更多支付方式（微信等）
   - 支付记录查询

---

## 11. 风险和假设

### 11.1 假设
- 支付宝支付集成已正常运行
- 后端回调 URL 已正确配置
- 数据库连接稳定
- 用户网络连接稳定

### 11.2 风险
- **支付宝回调延迟**: 可能导致用户认为支付失败
  - 缓解: 前端轮询机制 + 清晰的超时提示

- **支付金额不符**: 如果运费计算有误
  - 缓解: 在确认对话框中明确显示运费

- **订单权限漏洞**: 如果权限验证不充分
  - 缓解: 后端每次都校验 farmer_id/buyer_id

- **重复支付**: 用户多次点击支付按钮
  - 缓解: 按钮在支付过程中禁用

---

## 12. 后续扩展点

1. **运费动态计算** — 根据重量和距离计算运费
2. **多种支付方式** — 支持微信、银行卡等
3. **分期支付** — 支持订单分期付款
4. **退款处理** — 订单取消时的退款流程
5. **发票功能** — 支付后申请发票
6. **支付记录** — 用户可查看完整的支付历史

---

**设计完成日期**: 2026-04-13
**设计版本**: 1.0
**状态**: 待实现
