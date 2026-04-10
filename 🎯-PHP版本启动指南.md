# 🎯 需求平台 v4.1 PHP 版本启动指南

> 技术栈已调整为 **PHP 8.1+ + Laravel 11**
>
> 更新日期：2026-04-10

---

## 📊 更新后的完整技术栈

```
┌──────────────────────────────────────────┐
│        需求平台 v4.1 技术栈              │
├──────────────────────────────────────────┤
│ 📱 农户/买家 App        → Flutter        │
│ 📱 市场工作人员 App     → Flutter / PWA   │
│ 🖥️  代理人后台          → Vue 3 + Element │
│ 🖥️  管理员后台          → Vue 3 + Element │
│                                          │
│ 🔧 后端 API  ⭐ 已改为:                 │
│    PHP 8.1+ + Laravel 11                │
│    + Composer 包管理                     │
│    + Sanctum (JWT 认证)                 │
│    + Guzzle HTTP 客户端                 │
│                                          │
│ 💾 数据库               → MySQL 8.0+     │
│ 🗂️  缓存                → Redis 5.0+     │
│ 📨 消息队列            → Redis Queue     │
│ 🤖 AI 对话             → DeepSeek API   │
│ 💳 支付                → 支付宝 + Easysdk│
│ 🆔 实名认证            → 阿里云 SDK      │
│ 🚚 物流 API            → 货拉拉 + Guzzle │
│ 📲 短信                → 阿里云 SDK      │
│ 🔔 推送                → 极光推送        │
└──────────────────────────────────────────┘
```

---

## 📂 可用开发材料

| 文件名 | 大小 | 用途 | 说明 |
|-------|------|------|------|
| **农产品供需撮合平台-需求文档v4.1.md** | 55KB | 完整需求文档 | 不变，仍然适用 |
| **第一周开发清单-PHP版本.md** | 16KB | 分日执行清单 | PHP/Laravel 专版 |
| **setup-laravel-env.sh** | 6.8KB | 一键初始化脚本 | 自动建库建表建项目 |
| **Laravel迁移文件模板.php** | 16KB | 数据库迁移代码 | 8 张表的完整迁移文件 |
| **db_schema.sql** | 15KB | SQL 建表脚本 | 备用方案（不用迁移也可直接 SQL） |

---

## 🚀 快速启动（3 步，5 分钟）

### Step 1：运行初始化脚本
```bash
cd /Users/cuixiaocun/Desktop/needs
bash setup-laravel-env.sh

# 脚本会自动：
# ✅ 检查 PHP 8.1+ / Composer / MySQL / Redis
# ✅ 创建 Laravel 项目
# ✅ 安装所有依赖包
# ✅ 创建 needs_db 数据库
# ✅ 生成 8 个迁移文件
# ✅ 生成 8 个 Model 类
# ✅ 初始化目录结构
# ✅ 初始化 Git 仓库（develop 分支）
```

### Step 2：编写迁移文件并执行
```bash
cd needs-api

# 编辑 8 个迁移文件
# 可复制 Laravel迁移文件模板.php 中的代码到：
# database/migrations/2024_04_10_create_farmer_deposits_table.php
# ... (其他 7 个)

# 执行迁移，创建数据库表
php artisan migrate

# 验证表创建成功
mysql -u root needs_db
mysql> SHOW TABLES;  # 应该看到 8 个新表
```

### Step 3：配置 API 密钥并启动
```bash
# 编辑 .env，填写 API 密钥
# ALIPAY_APP_ID=xxx
# HUOLALA_API_KEY=xxx
# 等等

# 启动开发服务器
php artisan serve

# 访问 http://localhost:8000
```

---

## 📋 第一周任务分解

### Day 1（今天）
- [ ] 运行 `bash setup-laravel-env.sh` 初始化
- [ ] 复制迁移文件代码
- [ ] 执行 `php artisan migrate` 验证 8 个表创建成功

### Day 2
- [ ] 编写 8 个 Service 类（业务逻辑）
  - `AuthService.php` - 认证
  - `MatchingService.php` - 撮合引擎
  - `SettlementService.php` - 结算
  - `DispatchService.php` - 紧急调货
  - ...等其他 4 个

- [ ] 编写 API 控制器
  - `Auth/RegisterController`
  - `Auth/LoginController`
  - `Order/OrderController`
  - ...等其他

### Day 3
- [ ] 实现认证模块完整测试
- [ ] 支付宝沙箱测试通过
- [ ] 货拉拉 API 测试通过

### Day 4-5
- [ ] 撮合引擎核心算法（精确匹配）
- [ ] 市场收货流程
- [ ] 紧急调货逻辑

### Day 6-7
- [ ] 集成测试
- [ ] Bug 修复
- [ ] 灰度准备

---

## 🔌 关键 API 对接清单

### 支付宝集成
```php
// app/Integrations/AlipayIntegration.php
composer require alipay/easysdk

// 使用支付宝官方 SDK
// 沙箱环境测试：https://open.alipay.com/develop/sandbox
```

### 货拉拉集成
```php
// app/Integrations/HuolalaIntegration.php
composer require guzzlehttp/guzzle

// 使用 Guzzle HTTP 客户端
// 测试 API：https://openapi.huolala.cn
```

### 阿里云集成
```php
// app/Integrations/AliyunIntegration.php
composer require aliyun/sdk

// 包括：实名认证、短信、人脸识别
```

---

## 💻 关键 Laravel 命令

```bash
# 启动服务
php artisan serve                    # 启动本地服务 :8000

# 数据库
php artisan migrate                  # 执行迁移
php artisan migrate:rollback        # 回滚迁移
php artisan migrate:refresh         # 重建数据库

# 生成代码
php artisan make:model Model        # 创建 Model
php artisan make:controller Controller
php artisan make:migration table_name
php artisan make:job JobName
php artisan make:request FormRequest

# 队列
php artisan queue:work              # 启动队列监听
php artisan queue:failed            # 查看失败任务
php artisan queue:retry all         # 重试失败任务

# Tinker（交互式 Shell）
php artisan tinker

# 测试
php artisan test

# 缓存
php artisan cache:clear
php artisan route:cache
```

---

## 📁 项目结构速查

```
needs-api/
├── app/
│   ├── Http/Controllers/Api/        ← API 控制器
│   ├── Models/                      ← 8 个模型类
│   ├── Services/                    ← 业务逻辑服务
│   ├── Integrations/                ← 第三方 API 对接
│   ├── Jobs/                        ← 异步任务
│   └── Exceptions/                  ← 自定义异常
│
├── database/
│   ├── migrations/                  ← 8 个迁移文件
│   └── factories/                   ← 测试数据工厂
│
├── routes/
│   └── api.php                      ← API 路由定义
│
├── config/
│   ├── alipay.php                   ← 支付宝配置
│   ├── huolala.php                  ← 货拉拉配置
│   └── services.php                 ← 第三方服务配置
│
├── tests/                           ← 测试代码
├── storage/                         ← 日志、文件存储
├── .env                             ← 环境变量（需要填写 API keys）
├── composer.json                    ← 项目依赖清单
└── artisan                          ← 命令行工具
```

---

## ⚠️ PHP 版本常见坑 & 解决

| 坑 | 症状 | 解决 |
|----|------|------|
| Composer 依赖冲突 | `composer update` 失败 | 删除 `composer.lock`，重新 `composer install` |
| 支付宝私钥格式 | 验签失败 | 确保私钥是 PKCS8 格式，不是 PKCS1 |
| Redis 连接失败 | `Connection refused` | 检查 Redis 服务是否启动 (`redis-cli ping`) |
| 迁移文件顺序 | 表创建失败（外键约束） | 迁移文件名带时间戳，自动按时间顺序执行 |
| 异步队列问题 | 任务卡住 | 启动 `php artisan queue:work` 监听，配置 Redis |
| 跨域问题（CORS） | 前端调用 API 被阻止 | 配置 `.env` 或在 `routes/api.php` 添加中间件 |

---

## 📚 重要文档对应表

| 场景 | 参考文档 |
|------|---------|
| 需求详情（功能、流程、参数）| **农产品供需撮合平台-需求文档v4.1.md** |
| 第一周开发计划和执行步骤 | **第一周开发清单-PHP版本.md** |
| 一键初始化 | **setup-laravel-env.sh** |
| 数据库表结构 | **Laravel迁移文件模板.php** |
| 备用方案（直接 SQL） | **db_schema.sql** |

---

## 🎯 第一周核心成果物

完成第一周后应该有：

- ✅ Laravel 项目完整搭建 + 所有依赖安装
- ✅ 8 个数据库表创建成功（8 个迁移文件）
- ✅ 8 个 Model 类 + 关键 Service 类骨架
- ✅ 认证模块完整实现（注册/登录/退出）
- ✅ 支付宝沙箱测试通过（支付链接生成 + 回调验证）
- ✅ 货拉拉 API 对接测试通过（预估运费 + 下单）
- ✅ 阿里云实名认证 API 测试通过
- ✅ 撮合引擎基础算法框架（精确匹配）
- ✅ 异步队列框架就绪（可用 Redis Queue）
- ✅ 代码提交到 Git develop 分支

---

## 🚀 现在就开始！

```bash
# 复制这三行命令，一键启动
cd /Users/cuixiaocun/Desktop/needs
bash setup-laravel-env.sh
# 然后等待脚本完成，按照提示填写 API keys 即可

# 大约 2-3 分钟内，你会有一个完整的 Laravel 项目
# 可以立即开始编写业务逻辑了！
```

---

## 📞 遇到问题？

1. **脚本错误**：检查 PHP / Composer / MySQL 是否都装好了
2. **迁移失败**：检查 `.env` 数据库配置是否正确
3. **依赖冲突**：删除 `composer.lock`，重新 `composer install`
4. **API 对接失败**：检查 API keys 是否填写正确，沙箱环境是否配置

---

> 💡 **提示**：建议每天 standup 同步进度，遇到卡点立即提问，不要单独蛮干！

---

**技术栈已定稿，准备好开始了吗？** 🚀
