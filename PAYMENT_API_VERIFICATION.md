# 支付 API 验证清单

## 验证项目

### 1. 后端路由验证

✅ 已确认的路由：
- `POST /api/payment/alipay` - 创建支付链接
- `POST /api/payment/alipay/notify` - 支付宝回调
- `GET /api/delivery/fee` - 获取交货费用（新增）
- `GET /api/ai/status/{orderId}` - 获取订单状态

### 2. 支付宝配置验证

需要在 `needs-api/.env` 中确认以下配置：

```
ALIPAY_APP_ID=xxxxx
ALIPAY_PRIVATE_KEY=xxxxx
ALIPAY_PUBLIC_KEY=xxxxx
```

**检查方法**：
```bash
cd needs-api
grep "ALIPAY" .env
```

### 3. 支付链接生成测试

**测试命令**（需要有效的认证 token）：

```bash
curl -X POST http://localhost:8000/api/payment/alipay \
  -H "Authorization: Bearer YOUR_AUTH_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"order_id": 1}'
```

**预期响应**：
```json
{
  "success": true,
  "payment_url": "https://payment.alipay.com/..."
}
```

### 4. 交货费用 API 测试

**测试命令**：

```bash
curl -X GET http://localhost:8000/api/delivery/fee \
  -H "Authorization: Bearer YOUR_AUTH_TOKEN"
```

**预期响应**：
```json
{
  "success": true,
  "data": {
    "location": "集散市场中转",
    "fee": 80,
    "description": "标准物流运费"
  }
}
```

### 5. 订单更新 API 验证

确保 OrderController 支持 PATCH 方法：

**检查方法**：
```bash
cd needs-api
php artisan route:list | grep "PATCH.*orders"
```

如果不存在，需要在 OrderController 中添加 update() 方法。

### 6. 前端 HTTP 拦截器验证

确认 Dio 拦截器正确添加了 Authorization header：

```dart
_dio.interceptors.add(InterceptorsWrapper(
  onRequest: (options, handler) {
    final token = _storageService.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  },
));
```

## 集成测试流程

### 前置条件
- ✅ 后端服务运行在 http://localhost:8000
- ✅ 前端已配置正确的 AppConfig.currentApiBaseUrl
- ✅ 用户已登录

### 测试步骤

1. **进入订单详情页**
   - 登录 app
   - 进入"我的订单"
   - 点击一个待匹配的订单

2. **点击支付按钮**
   - 点击"立即支付"
   - 验证交货确认对话框显示
   - 点击"确认并支付"

3. **验证支付弹窗**
   - 验证显示正确的订单金额
   - 验证显示正确的运费（¥80）
   - 验证显示正确的合计金额

4. **测试支付链接生成**
   - 点击"跳转支付宝"
   - 验证浏览器打开支付宝链接
   - 验证链接格式正确

5. **验证支付回调**
   - 完成支付宝支付（可使用沙箱环境）
   - 验证后端接收到 alipayNotify 回调
   - 验证订单状态更新为 confirmed

6. **验证状态轮询**
   - 支付完成后，弹窗应自动轮询订单状态
   - 验证显示"支付成功"提示
   - 验证订单详情页刷新

## 常见问题排查

### 问题 1: 支付链接生成失败

**原因可能**：
- 支付宝配置不完整
- 认证 token 无效
- 订单 ID 不存在

**解决方案**：
- 检查 .env 中的支付宝配置
- 确认用户已登录
- 确认订单 ID 有效

### 问题 2: 支付宝回调失败

**原因可能**：
- 回调 URL 配置错误
- 签名验证失败
- 支付宝没有正确的回调 token

**解决方案**：
- 验证 PaymentController 中的回调 URL 配置
- 检查 AlipayIntegration 中的签名验证逻辑
- 查看日志文件获取详细错误信息

### 问题 3: 轮询超时

**原因可能**：
- 后端处理支付回调缓慢
- 数据库连接问题
- 订单查询失败

**解决方案**：
- 检查后端日志
- 验证数据库连接
- 增加轮询超时时间

## 验证完成标准

完成以下所有验证后，支付功能可认为集成成功：

- ✅ 后端所有必需的 API 都能正确响应
- ✅ 前端能正确生成支付链接
- ✅ 支付宝支付流程可完整执行
- ✅ 支付回调能正确更新订单状态
- ✅ 前端能正确显示支付结果
