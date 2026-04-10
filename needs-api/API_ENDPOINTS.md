# 需求平台 API 完整接口文档

**基础 URL:** `http://localhost:8000/api`
**认证方式:** Bearer Token (Sanctum)

---

## 一、认证相关

### 1.1 用户注册
```
POST /auth/register
Content-Type: application/json

{
  "name": "张三",
  "email": "zhangsan@example.com",
  "password": "password123",
  "phone": "13800138000",
  "role": "farmer"  // farmer, buyer, agent, market_worker
}

Response 201:
{
  "success": true,
  "data": {
    "user": { ... },
    "token": "1|abc..."
  }
}
```

### 1.2 用户登录
```
POST /auth/login
Content-Type: application/json

{
  "email": "zhangsan@example.com",
  "password": "password123"
}

Response 200:
{
  "success": true,
  "data": {
    "user": { ... },
    "token": "1|abc..."
  }
}
```

### 1.3 用户登出（需令牌）
```
POST /auth/logout
Authorization: Bearer {token}

Response 200:
{
  "success": true,
  "message": "Logged out successfully"
}
```

### 1.4 获取当前用户（需令牌）
```
GET /user
Authorization: Bearer {token}

Response 200:
{
  "id": 1,
  "name": "张三",
  "email": "zhangsan@example.com",
  "role": "farmer",
  "credit_score": 100
}
```

---

## 二、订单相关

### 2.1 创建订单
```
POST /orders
Authorization: Bearer {token}
Content-Type: application/json

{
  "product_name": "新鲜番茄",
  "quantity": 100,
  "unit": "斤",
  "price_per_unit": 5.5,
  "scheduled_delivery_time": "2026-04-15 10:00:00",
  "notes": "需冷链配送"
}

Response 201:
{
  "success": true,
  "data": { ... }
}
```

### 2.2 获取订单列表（需令牌）
```
GET /orders?page=1
Authorization: Bearer {token}

Response 200:
{
  "success": true,
  "data": {
    "data": [ ... ],
    "current_page": 1,
    "total": 10
  }
}
```

### 2.3 获取订单详情
```
GET /orders/{orderId}
Authorization: Bearer {token}

Response 200:
{
  "success": true,
  "data": { ... }
}
```

---

## 三、订单撮合

### 3.1 获取推荐匹配列表
```
GET /orders/{orderId}/recommendations
Authorization: Bearer {token}

Response 200:
{
  "success": true,
  "data": [
    {
      "id": 2,
      "farmer_name": "李四",
      "product": "番茄",
      "quantity": 100,
      "price_per_unit": 5.3,
      "score": 95.5
    }
  ]
}
```

### 3.2 手动撮合两个订单
```
POST /orders/match
Authorization: Bearer {token}
Content-Type: application/json

{
  "buyer_order_id": 1,
  "farmer_order_id": 2
}

Response 200:
{
  "success": true,
  "message": "配对成功"
}
```

### 3.3 自动撮合订单
```
POST /orders/{orderId}/auto-match
Authorization: Bearer {token}

Response 200:
{
  "success": true,
  "type": "exact_match" or "fuzzy_match",
  "matched_order": { ... },
  "candidates": [ ... ]
}
```

---

## 四、订单取消

### 4.1 查看取消状态
```
GET /orders/{orderId}/cancel-status
Authorization: Bearer {token}

Response 200:
{
  "success": true,
  "data": {
    "can_cancel": true,
    "hours_until_locked": 2.5,
    "reason": "可取消（距离交货 5 小时以上）"
  }
}
```

### 4.2 农户取消订单
```
POST /orders/{orderId}/cancel/farmer
Authorization: Bearer {token}
Content-Type: application/json

{
  "reason": "供应不足"
}

Response 200:
{
  "success": true,
  "message": "订单已取消，保证金已冻结，等待紧急调货处理",
  "credit_score": 80
}
```

### 4.3 买家取消订单
```
POST /orders/{orderId}/cancel/buyer
Authorization: Bearer {token}
Content-Type: application/json

{
  "reason": "不需要了"
}

Response 200:
{
  "success": true,
  "message": "订单已取消"
}
```

---

## 五、保证金管理

### 5.1 查看保证金信息
```
GET /deposit
Authorization: Bearer {token}

Response 200:
{
  "success": true,
  "data": {
    "total_deposit": 5000,
    "available": 3000,
    "frozen": 2000,
    "deducted": 0,
    "leverage_amount": 30000,
    "can_leverage": 30000
  }
}
```

### 5.2 保证金充值
```
POST /deposit/recharge
Authorization: Bearer {token}
Content-Type: application/json

{
  "amount": 1000  // 最少 100 元
}

Response 200:
{
  "success": true,
  "message": "充值成功",
  "new_balance": 4000
}
```

### 5.3 保证金提现
```
POST /deposit/withdraw
Authorization: Bearer {token}
Content-Type: application/json

{
  "amount": 500
}

Response 200:
{
  "success": true,
  "message": "提现申请已提交，请稍候",
  "new_balance": 3500
}
```

### 5.4 查看保证金日志
```
GET /deposit/logs?page=1
Authorization: Bearer {token}

Response 200:
{
  "success": true,
  "data": {
    "data": [
      {
        "id": 1,
        "type": "charge",
        "amount": 1000,
        "reason": "充值保证金",
        "created_at": "2026-04-10 10:00:00"
      }
    ]
  }
}
```

---

## 六、支付相关

### 6.1 创建支付宝支付链接
```
POST /payment/alipay/create
Authorization: Bearer {token}
Content-Type: application/json

{
  "order_id": 1
}

Response 200:
{
  "success": true,
  "payment_url": "https://openapi.alipaydev.com/gateway.do?..."
}
```

### 6.2 支付回调（无需认证）
```
POST /payment/alipay/notify

支付宝会发送支付结果到此端点
```

---

## 七、物流相关

### 7.1 运费预估
```
POST /shipping/estimate
Authorization: Bearer {token}
Content-Type: application/json

{
  "from": {"lng": 120.155, "lat": 30.274},
  "to": {"lng": 121.469, "lat": 31.231},
  "weight": 50,
  "volume": 0.5
}

Response 200:
{
  "success": true,
  "data": {
    "estimate_fee": 50,
    "estimated_time": "2小时"
  }
}
```

### 7.2 创建物流订单
```
POST /shipping/create
Authorization: Bearer {token}
Content-Type: application/json

{
  "order_id": 1,
  "from": {"lng": 120.155, "lat": 30.274},
  "to": {"lng": 121.469, "lat": 31.231},
  "weight": 50,
  "volume": 0.5,
  "remark": "新鲜蔬菜，需冷链配送"
}

Response 200:
{
  "success": true,
  "logistics_id": "HL123456789",
  "data": { ... }
}
```

---

## 八、HTTP 状态码

| 状态码 | 含义 |
|--------|------|
| 200 | 请求成功 |
| 201 | 创建成功 |
| 400 | 请求参数错误 |
| 401 | 未认证或令牌失效 |
| 403 | 无权限 |
| 404 | 资源不存在 |
| 422 | 业务验证失败 |
| 500 | 服务器错误 |

---

## 九、错误响应示例

```json
{
  "success": false,
  "error": "可用余额不足",
  "details": {
    "available": 100,
    "requested": 200
  }
}
```

---

## 十、限流和配额

| 项目 | 限制 |
|------|------|
| API 请求 | 无限制（本地开发） |
| 保证金充值 | 最少 100 元，最多 100 万 |
| 保证金提现 | 需余额充足 |
| 订单创建 | 无限制 |
| 并发连接 | 推荐 100+ |

---

**最后更新：2026-04-10**
