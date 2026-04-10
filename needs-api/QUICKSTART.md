# 🚀 快速启动指南（5 分钟）

## 一、本地运行（开发环境）

### 1. 启动应用（3 个终端窗口）

**终端 1 - 主应用**
```bash
cd /Users/cuixiaocun/Desktop/needs/needs-api
php artisan serve
# 访问：http://localhost:8000/api/health ✅
```

**终端 2 - 队列监听（异步任务）**
```bash
cd /Users/cuixiaocun/Desktop/needs/needs-api
php artisan queue:work
```

**终端 3 - 定时任务（可选）**
```bash
cd /Users/cuixiaocun/Desktop/needs/needs-api
php artisan schedule:work
```

---

## 二、快速测试 API

### 1. 用户注册
```bash
curl -X POST http://localhost:8000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "张三",
    "email": "zhangsan@example.com",
    "password": "password123",
    "phone": "13800138000",
    "role": "farmer"
  }'

# 返回中获取 token，后续使用
```

### 2. 用户登录
```bash
curl -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "zhangsan@example.com",
    "password": "password123"
  }'
```

### 3. 创建订单（需要 token）
```bash
curl -X POST http://localhost:8000/api/orders \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "product_name": "新鲜番茄",
    "quantity": 100,
    "unit": "斤",
    "price_per_unit": 5.5,
    "scheduled_delivery_time": "2026-04-15 10:00:00",
    "notes": "需冷链配送"
  }'
```

### 4. 查看保证金
```bash
curl -X GET http://localhost:8000/api/deposit \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

### 5. 充值保证金
```bash
curl -X POST http://localhost:8000/api/deposit/recharge \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "amount": 1000
  }'
```

---

## 三、Postman 导入

创建 `postman_collection.json` 并导入到 Postman：

```json
{
  "info": {
    "name": "Needs Platform API",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  "item": [
    {
      "name": "Auth",
      "item": [
        {
          "name": "Register",
          "request": {
            "method": "POST",
            "url": "{{base_url}}/auth/register"
          }
        },
        {
          "name": "Login",
          "request": {
            "method": "POST",
            "url": "{{base_url}}/auth/login"
          }
        }
      ]
    },
    {
      "name": "Orders",
      "item": [
        {
          "name": "Create Order",
          "request": {
            "method": "POST",
            "url": "{{base_url}}/orders",
            "header": [
              {
                "key": "Authorization",
                "value": "Bearer {{token}}"
              }
            ]
          }
        }
      ]
    }
  ],
  "variable": [
    {
      "key": "base_url",
      "value": "http://localhost:8000/api"
    },
    {
      "key": "token",
      "value": ""
    }
  ]
}
```

---

## 四、数据库查看

### 查看所有表
```bash
mysql -u root needs_db -e "SHOW TABLES;"
```

### 查看用户数据
```bash
mysql -u root needs_db -e "SELECT id, name, email, role, credit_score FROM users;"
```

### 查看订单数据
```bash
mysql -u root needs_db -e "SELECT id, farmer_id, buyer_id, product_name, status FROM orders;"
```

### 查看保证金
```bash
mysql -u root needs_db -e "SELECT farmer_id, total_deposit, available, frozen FROM farmer_deposits;"
```

---

## 五、日志查看

### 实时查看应用日志
```bash
tail -f storage/logs/laravel.log | grep -E "(ERROR|WARNING|INFO)"
```

### 查看特定操作的日志
```bash
tail -100 storage/logs/laravel.log | grep "订单撮合"
tail -100 storage/logs/laravel.log | grep "紧急调货"
tail -100 storage/logs/laravel.log | grep "保证金"
```

---

## 六、完整业务流程演示

### 场景：农户发布订单，买家购买，支付，交货，结算

**Step 1: 农户注册并创建订单**
```bash
# 农户注册
curl -X POST http://localhost:8000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "李四",
    "email": "lisi@example.com",
    "password": "pass123",
    "role": "farmer"
  }'
# 获取 FARMER_TOKEN

# 农户充值保证金
curl -X POST http://localhost:8000/api/deposit/recharge \
  -H "Authorization: Bearer $FARMER_TOKEN" \
  -d '{"amount": 5000}'

# 农户创建订单
curl -X POST http://localhost:8000/api/orders \
  -H "Authorization: Bearer $FARMER_TOKEN" \
  -d '{
    "product_name": "新鲜番茄",
    "quantity": 100,
    "unit": "斤",
    "price_per_unit": 5.5,
    "scheduled_delivery_time": "2026-04-15 10:00:00"
  }'
# 获取 ORDER_ID
```

**Step 2: 买家创建采购订单并撮合**
```bash
# 买家注册
curl -X POST http://localhost:8000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "王五",
    "email": "wangwu@example.com",
    "password": "pass123",
    "role": "buyer"
  }'
# 获取 BUYER_TOKEN

# 买家查看推荐
curl -X GET "http://localhost:8000/api/orders/$ORDER_ID/recommendations" \
  -H "Authorization: Bearer $BUYER_TOKEN"

# 买家手动撮合
curl -X POST http://localhost:8000/api/orders/match \
  -H "Authorization: Bearer $BUYER_TOKEN" \
  -d '{
    "buyer_order_id": 2,
    "farmer_order_id": 1
  }'
```

**Step 3: 支付**
```bash
# 生成支付链接
curl -X POST http://localhost:8000/api/payment/alipay/create \
  -H "Authorization: Bearer $BUYER_TOKEN" \
  -d '{"order_id": 2}'
# 获取 payment_url，在浏览器中打开（沙箱环境）
```

**Step 4: 订单状态变更（通过数据库模拟）**
```bash
# 模拟市场收货
mysql -u root needs_db -e \
  "UPDATE orders SET status='receiving' WHERE id=1; \
   UPDATE orders SET status='receiving' WHERE id=2;"

# 模拟订单完成
mysql -u root needs_db -e \
  "UPDATE orders SET status='completed' WHERE id=1; \
   UPDATE orders SET status='completed' WHERE id=2;"
```

**Step 5: 每周一执行结算**
```bash
# 手动触发结算任务（通常自动执行）
php artisan tinker
>>> dispatch(new App\Jobs\SettlementJob());
>>> exit

# 查看结算记录
mysql -u root needs_db -e \
  "SELECT * FROM farmer_settlements;"
```

---

## 七、测试异常流程

### 取消订单测试
```bash
# 查看取消状态
curl -X GET http://localhost:8000/api/orders/1/cancel-status \
  -H "Authorization: Bearer $FARMER_TOKEN"

# 农户取消
curl -X POST http://localhost:8000/api/orders/1/cancel/farmer \
  -H "Authorization: Bearer $FARMER_TOKEN" \
  -d '{"reason": "供应不足"}'

# 观察日志：应该有冻结保证金和触发紧急调货
tail -f storage/logs/laravel.log | grep "调货"
```

### 保证金不足测试
```bash
# 尝试提现超过余额
curl -X POST http://localhost:8000/api/deposit/withdraw \
  -H "Authorization: Bearer $FARMER_TOKEN" \
  -d '{"amount": 100000}'
# 预期返回：可用余额不足
```

---

## 八、关键命令速查

```bash
# 数据库操作
php artisan migrate              # 执行迁移
php artisan migrate:rollback     # 回滚迁移
php artisan tinker              # 交互式 Shell

# 队列和定时任务
php artisan queue:work          # 启动队列监听
php artisan queue:failed        # 查看失败任务
php artisan schedule:work       # 启动定时任务

# 缓存和优化
php artisan cache:clear         # 清空缓存
php artisan config:cache        # 缓存配置
php artisan route:cache         # 缓存路由

# 日志查看
tail -f storage/logs/laravel.log    # 实时日志
grep "ERROR" storage/logs/laravel.log
```

---

## 九、常见问题

### Q: API 返回 401 Unauthorized
**A:** Token 已过期或无效，需要重新登录获取新 token

### Q: 订单无法撮合
**A:** 检查：1) 产品名称是否相同 2) 数量和价格是否匹配 3) 订单状态是否为 pending

### Q: 支付宝支付链接返回 FAIL
**A:** 检查：1) App ID 是否正确 2) 私钥格式是否为 PKCS8 3) 金额是否 >= 0.01

### Q: 队列任务不执行
**A:** 检查：1) `php artisan queue:work` 是否在运行 2) 数据库连接是否正常 3) 查看失败任务 `php artisan queue:failed`

---

## 十、下一步

- 📖 阅读 `API_ENDPOINTS.md` 了解完整的 API
- 🔧 阅读 `THIRD_PARTY_INTEGRATION.md` 配置真实的支付宝等服务
- 🚀 阅读 `DEPLOYMENT_GUIDE.md` 了解生产环境部署
- 💡 查看 `needs-api/app/Services/` 了解核心业务逻辑

---

**现在可以开始开发了！快乐编码！🎉**
