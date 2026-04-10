# 第三方 API 集成指南

本文档说明如何配置和测试支付宝、货拉拉和阿里云服务。

## 一、支付宝集成

### 1.1 申请支付宝沙箱账户

1. 访问 [支付宝开放平台](https://open.alipay.com)
2. 登录或注册开发者账户
3. 进入 **沙箱环境** -> **应用信息** -> **获取应用 ID**
4. 获取以下信息：
   - App ID
   - 商户私钥（PKCS8 格式）
   - 支付宝公钥

### 1.2 配置 .env

```env
ALIPAY_APP_ID=2021000113XXXXX
ALIPAY_PRIVATE_KEY=MIIEvQIBADANBgkqhkiG9w0BAQE...（去除换行符）
ALIPAY_PUBLIC_KEY=MIIBIjANBgkqhkiG9w0BAQE...（去除换行符）
ALIPAY_SANDBOX=true
```

**⚠️ 注意：私钥和公钥需要删除所有空格和换行符**

### 1.3 测试支付链接

```bash
curl -X POST http://localhost:8000/api/payment/alipay/create \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"order_id": 1}'
```

预期返回：
```json
{
  "success": true,
  "payment_url": "https://openapi.alipaydev.com/gateway.do?..."
}
```

### 1.4 回调配置

- 回调地址：`https://your-domain.com/api/payment/alipay/notify`
- 在支付宝后台配置此回调地址

---

## 二、货拉拉集成

### 2.1 申请货拉拉 API 权限

1. 访问 [货拉拉开放平台](https://open.huolala.cn)
2. 注册开发者账户
3. 创建应用，获取 **API Key**
4. 在沙箱环境测试

### 2.2 配置 .env

```env
HUOLALA_API_KEY=your_api_key_here
HUOLALA_SANDBOX=true
```

### 2.3 测试运费预估

```bash
curl -X POST http://localhost:8000/api/shipping/estimate \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "from": {"lng": 120.155, "lat": 30.274},
    "to": {"lng": 121.469, "lat": 31.231},
    "weight": 50,
    "volume": 0.5
  }'
```

### 2.4 创建运输订单

```bash
curl -X POST http://localhost:8000/api/shipping/create \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "order_id": 1,
    "from": {"lng": 120.155, "lat": 30.274},
    "to": {"lng": 121.469, "lat": 31.231},
    "weight": 50,
    "volume": 0.5,
    "remark": "新鲜蔬菜，需冷链配送"
  }'
```

---

## 三、阿里云集成

### 3.1 申请阿里云服务

1. 访问 [阿里云控制台](https://console.aliyun.com)
2. 激活以下服务：
   - **短信服务 (SMS)**
   - **实名认证服务 (IDaaS)**
   - **邮件推送**

3. 获取以下信息：
   - Access Key ID
   - Access Key Secret
   - SMS 签名名称
   - SMS 模板 ID（注册、登录、密码重置）

### 3.2 配置 .env

```env
ALIYUN_ACCESS_KEY=AKIA...
ALIYUN_SECRET_KEY=...
ALIYUN_REGION=cn-shanghai
ALIYUN_SMS_SIGN_NAME=Needs平台
ALIYUN_SMS_TEMPLATE_REGISTER=SMS_123456789
ALIYUN_SMS_TEMPLATE_LOGIN=SMS_123456790
ALIYUN_SMS_TEMPLATE_RESET=SMS_123456791
ALIYUN_EMAIL_ACCOUNT=service@needs.com
```

### 3.3 配置 SMS 模板

在阿里云控制台申请短信模板，模板内容参考：

**注册验证码模板：**
```
您的注册验证码为：${code}，五分钟内有效，请勿泄露。
```

**登录验证码模板：**
```
您的登录验证码为：${code}，五分钟内有效，请勿泄露。
```

**密码重置模板：**
```
您的密码重置验证码为：${code}，五分钟内有效，请勿泄露。
```

### 3.4 测试短信发送

当前代码框架已支持短信发送，需要在 `AliyunIntegration` 中调用：

```php
$aliyun = new \App\Integrations\AliyunIntegration();
$result = $aliyun->sendSms('13800138000', 'register', ['code' => '123456']);
```

---

## 四、DeepSeek AI 集成（紧急调货 AI 对话）

### 4.1 申请 DeepSeek API

1. 访问 [DeepSeek 开放平台](https://platform.deepseek.com)
2. 注册账户，创建 API Key
3. 获取 API Key 和基础 URL

### 4.2 配置 .env

```env
DEEPSEEK_API_KEY=sk-...
DEEPSEEK_BASE_URL=https://api.deepseek.com/v1
```

---

## 五、生产环境部署检查清单

- [ ] 移除沙箱模式标志（ALIPAY_SANDBOX=false 等）
- [ ] 生成真实的支付宝密钥
- [ ] 更新支付宝回调地址为生产域名
- [ ] 配置 SSL/HTTPS 证书
- [ ] 在生产环境验证所有 API 调用
- [ ] 启用日志记录（已在代码中配置）
- [ ] 配置错误告警（邮件/Slack）
- [ ] 备份 API 密钥到安全的地方

---

## 六、常见问题

### Q: 支付宝支付链接返回 `FAIL`

**A:** 检查以下内容：
- App ID 是否正确
- 私钥是否为 PKCS8 格式
- 是否删除了私钥中的空格和换行符
- 金额是否大于 0.01 元

### Q: 货拉拉返回 401 Unauthorized

**A:** 检查以下内容：
- API Key 是否正确
- 是否使用了沙箱模式
- Authorization 头是否正确格式：`Bearer YOUR_API_KEY`

### Q: 阿里云短信发送失败

**A:** 检查以下内容：
- SMS 签名是否已申请并通过审核
- SMS 模板是否已申请并通过审核
- 手机号是否为国内号码
- 账户是否有足够的短信额度

---

## 七、日志查看

所有 API 调用都会记录在日志文件中：

```bash
tail -f storage/logs/laravel.log | grep -E "(支付宝|货拉拉|短信|认证)"
```

---

更新日期：2026-04-10
