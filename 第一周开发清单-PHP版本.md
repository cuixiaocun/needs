# 🚀 第一周开发清单（v4.1 PHP 版本）

> 目标：Laravel 框架搭建 + 数据库 + 核心模块骨架就绪

---

## 一、环境要求

### 1.1 系统要求
```
PHP 8.1+ (推荐 8.2 / 8.3)
Composer 2.0+
MySQL 8.0+
Redis 5.0+（可选，建议装）
```

### 1.2 检查环境
```bash
php -v          # PHP 版本
composer -v     # Composer 版本
mysql --version # MySQL 版本
redis-cli --version  # Redis 版本（可选）
```

---

## 二、Laravel 项目初始化（Day 1）

### 2.1 创建 Laravel 项目
```bash
# 方案 A：用 Laravel Installer
composer global require laravel/installer
laravel new needs-api

# 或方案 B：用 Composer
composer create-project laravel/laravel needs-api

cd needs-api
```

### 2.2 安装核心扩展包
```bash
composer require:
  # API 响应
  laravel/sanctum                 # JWT 认证

  # 数据库
  doctrine/dbal                   # 数据库迁移支持

  # 第三方 API
  alipay/easysdk                  # 支付宝官方 SDK
  guzzlehttp/guzzle              # HTTP 客户端（货拉拉、阿里云）
  aliyun-php-sdk                  # 阿里云官方 SDK

  # 工具
  laravel/horizon                 # Redis 队列管理
  laravel-notification/queueable  # 异步通知
```

### 2.3 项目结构
```
needs-api/
├── app/
│   ├── Http/
│   │   ├── Controllers/
│   │   │   ├── Auth/              (认证)
│   │   │   ├── Order/             (订单)
│   │   │   ├── Market/            (市场)
│   │   │   ├── Settlement/        (结算)
│   │   │   └── Dispatch/          (紧急调货)
│   │   ├── Requests/              (表单验证)
│   │   └── Resources/             (API 响应格式)
│   ├── Models/
│   │   ├── User.php
│   │   ├── Order.php
│   │   ├── FarmerDeposit.php
│   │   ├── EmergencyDispatch.php
│   │   ├── MarketReceiving.php
│   │   └── ... (8 个新模型)
│   ├── Services/
│   │   ├── AuthService.php
│   │   ├── MatchingService.php    (撮合引擎)
│   │   ├── SettlementService.php
│   │   ├── DispatchService.php    (紧急调货)
│   │   └── ...
│   ├── Integrations/
│   │   ├── AlipayIntegration.php
│   │   ├── HuolalaIntegration.php
│   │   └── AliyunIntegration.php
│   ├── Jobs/                      (异步任务队列)
│   │   ├── SettlementJob.php
│   │   └── DispatchJob.php
│   └── Exceptions/
│
├── database/
│   ├── migrations/                (数据库迁移文件)
│   │   ├── 2024_04_10_create_farmer_deposits_table.php
│   │   ├── 2024_04_10_create_emergency_dispatch_logs_table.php
│   │   └── ... (8 个新表的迁移)
│   └── factories/                 (测试数据工厂)
│
├── routes/
│   ├── api.php                    (API 路由)
│   └── web.php                    (Web 路由，不用)
│
├── tests/
│   ├── Feature/
│   │   ├── AuthTest.php
│   │   ├── OrderTest.php
│   │   └── ...
│   └── Unit/
│
├── config/
│   ├── alipay.php                 (支付宝配置)
│   ├── huolala.php                (货拉拉配置)
│   └── services.php               (第三方服务配置)
│
├── .env                           (环境变量)
├── .env.example                   (环境变量模板)
├── composer.json
└── artisan                        (命令行工具)
```

### 2.4 配置文件 (.env)
```
# 应用
APP_NAME="Needs-Platform"
APP_ENV=local
APP_DEBUG=true
APP_URL=http://localhost:8000

# 数据库
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=needs_db
DB_USERNAME=root
DB_PASSWORD=

# Redis
REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379

# 队列（异步任务）
QUEUE_CONNECTION=redis

# 支付宝沙箱
ALIPAY_APP_ID=xxxx
ALIPAY_PRIVATE_KEY=xxxx
ALIPAY_PUBLIC_KEY=xxxx
ALIPAY_SANDBOX=true

# 货拉拉
HUOLALA_API_KEY=xxxx
HUOLALA_SANDBOX=true

# 阿里云
ALIYUN_ACCESS_KEY=xxxx
ALIYUN_SECRET_KEY=xxxx
ALIYUN_REGION=cn-shanghai

# JWT
JWT_SECRET=your_secret_key_here
JWT_ALGORITHM=HS256
```

---

## 三、数据库初始化（Day 1）

### 3.1 创建数据库
```bash
mysql -u root -p
mysql> CREATE DATABASE needs_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
mysql> EXIT;
```

### 3.2 配置数据库连接
编辑 `.env`：
```
DB_HOST=127.0.0.1
DB_DATABASE=needs_db
DB_USERNAME=root
DB_PASSWORD=
```

### 3.3 执行迁移（创建表）
```bash
php artisan migrate

# 验证表创建成功
mysql -u root needs_db
mysql> SHOW TABLES;  # 应该看到 8 个新表 + 11 个默认表
```

### 3.4 生成数据库迁移文件
```bash
# 为 8 个新表生成迁移文件
php artisan make:migration create_farmer_deposits_table
php artisan make:migration create_farmer_deposit_logs_table
php artisan make:migration create_emergency_dispatch_logs_table
php artisan make:migration create_agent_call_records_table
php artisan make:migration create_market_receiving_records_table
php artisan make:migration create_market_dispatch_records_table
php artisan make:migration create_farmer_settlements_table
php artisan make:migration create_settlement_items_table

# 填写迁移文件内容（见下文 3.5）
```

### 3.5 迁移文件模板（Laravel 方式）
```php
// database/migrations/2024_04_10_create_farmer_deposits_table.php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('farmer_deposits', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('farmer_id')->unique();
            $table->decimal('total_deposit', 12, 2)->default(0)->comment('充值总额');
            $table->decimal('available', 12, 2)->default(0)->comment('可用余额');
            $table->decimal('frozen', 12, 2)->default(0)->comment('已冻结');
            $table->decimal('deducted', 12, 2)->default(0)->comment('已扣除');
            $table->decimal('leverage_amount', 15, 2)->default(0)->comment('10倍杠杆额度');
            $table->timestamps();

            $table->foreign('farmer_id')->references('id')->on('users');
            $table->index('created_at');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('farmer_deposits');
    }
};
```

---

## 四、核心模块 Skeleton（Day 2-3）

### 4.1 创建 Models
```bash
php artisan make:model FarmerDeposit
php artisan make:model FarmerDepositLog
php artisan make:model EmergencyDispatchLog
php artisan make:model AgentCallRecord
php artisan make:model MarketReceivingRecord
php artisan make:model MarketDispatchRecord
php artisan make:model FarmerSettlement
php artisan make:model SettlementItem

# 自动创建对应的迁移文件
php artisan make:model Order -m
```

### 4.2 创建 Services（业务逻辑）
```bash
# 认证
php artisan make:provider AuthServiceProvider

# 撮合引擎
mkdir app/Services
# 手动创建 MatchingService.php

# 结算
# 手动创建 SettlementService.php

# 紧急调货
# 手动创建 DispatchService.php
```

### 4.3 创建 Controllers
```bash
php artisan make:controller Api/Auth/RegisterController
php artisan make:controller Api/Auth/LoginController
php artisan make:controller Api/Order/OrderController
php artisan make:controller Api/Market/ReceivingController
php artisan make:controller Api/Settlement/SettlementController
php artisan make:controller Api/Dispatch/DispatchController
```

### 4.4 创建 API Routes
编辑 `routes/api.php`：
```php
use Illuminate\Support\Facades\Route;

Route::middleware('api')->group(function () {
    // 认证
    Route::post('/auth/register', 'Api\Auth\RegisterController@register');
    Route::post('/auth/login', 'Api\Auth\LoginController@login');
    Route::post('/auth/logout', 'Api\Auth\LoginController@logout')->middleware('auth:sanctum');

    // 受保护的路由
    Route::middleware('auth:sanctum')->group(function () {
        // 农户订单
        Route::post('/orders/create', 'Api\Order\OrderController@create');
        Route::get('/orders', 'Api\Order\OrderController@list');

        // 市场收货
        Route::post('/market/receive', 'Api\Market\ReceivingController@receive');

        // 紧急调货
        Route::post('/dispatch/emergency', 'Api\Dispatch\DispatchController@emergency');
    });
});
```

---

## 五、API 对接集成（Day 2-3）

### 5.1 支付宝集成
```bash
composer require alipay/easysdk
```

创建 `app/Integrations/AlipayIntegration.php`：
```php
<?php

namespace App\Integrations;

use Alipay\EasySDK\Core\Config;
use Alipay\EasySDK\Payment\Common\Models\Amount;
use Alipay\EasySDK\Payment\Page\Models\GoodsDetail;

class AlipayIntegration
{
    public function __construct()
    {
        // 初始化配置
        Config::setOptions([
            'protocol' => 'https',
            'gatewayHost' => config('alipay.sandbox') ?
                'openapi.alipaydev.com' : 'openapi.alipay.com',
            'signType' => 'RSA2',
            'appId' => config('alipay.app_id'),
            'merchantPrivateKey' => config('alipay.private_key'),
            'alipayCertPath' => storage_path('cert/alipayCert.crt'),
            'alipayRootCertPath' => storage_path('cert/alipayRootCert.crt'),
            'merchantCertPath' => storage_path('cert/merchantCert.crt'),
        ]);
    }

    /**
     * 创建支付链接
     */
    public function createPayment($order)
    {
        try {
            $result = \Alipay\EasySDK\Payment\Page\Client::pageExecute(
                (new PagePayRequestBuilder())
                    ->setSubject("订单 #{$order->id}")
                    ->setTotalAmount((string)$order->total_amount)
                    ->setOutTradeNo((string)$order->id)
                    ->setReturnUrl(config('app.url') . '/payment/return')
                    ->setNotifyUrl(config('app.url') . '/api/payment/notify')
                    ->build()
            );

            return $result->body ?? null;
        } catch (\Exception $e) {
            \Log::error('支付宝支付失败: ' . $e->getMessage());
            return null;
        }
    }

    /**
     * 验证支付回调
     */
    public function verifyNotify($data)
    {
        // 验证签名
        $publicKey = config('alipay.public_key');
        // 使用支付宝官方验签逻辑
        return \Alipay\EasySDK\Core\Signer::rsaCheck($data, $publicKey);
    }
}
```

### 5.2 货拉拉集成
```php
// app/Integrations/HuolalaIntegration.php

namespace App\Integrations;

use GuzzleHttp\Client;

class HuolalaIntegration
{
    protected $client;
    protected $apiKey;

    public function __construct()
    {
        $this->client = new Client([
            'base_uri' => config('huolala.sandbox') ?
                'https://sandbox-api.huolala.cn' :
                'https://openapi.huolala.cn',
            'timeout' => 30,
        ]);
        $this->apiKey = config('huolala.api_key');
    }

    /**
     * 获取运费预估
     */
    public function estimatePrice($params)
    {
        try {
            $response = $this->client->post('/api/carpool/order/estimatedPrice', [
                'headers' => [
                    'Authorization' => "Bearer {$this->apiKey}",
                    'Content-Type' => 'application/json',
                ],
                'json' => $params,
            ]);

            return json_decode($response->getBody(), true);
        } catch (\Exception $e) {
            \Log::error('货拉拉预估失败: ' . $e->getMessage());
            return null;
        }
    }

    /**
     * 创建运输订单
     */
    public function createOrder($params)
    {
        try {
            $response = $this->client->post('/api/carpool/order/createOrder', [
                'headers' => [
                    'Authorization' => "Bearer {$this->apiKey}",
                    'Content-Type' => 'application/json',
                ],
                'json' => $params,
            ]);

            return json_decode($response->getBody(), true);
        } catch (\Exception $e) {
            \Log::error('货拉拉下单失败: ' . $e->getMessage());
            return null;
        }
    }
}
```

### 5.3 阿里云集成
```php
// app/Integrations/AliyunIntegration.php

namespace App\Integrations;

use Aliyun\Core\DefaultAcsClient;
use Aliyun\Core\Profile\DefaultProfile;

class AliyunIntegration
{
    protected $client;

    public function __construct()
    {
        // 初始化阿里云客户端
        $profile = DefaultProfile::getProfile(
            config('aliyun.region'),
            config('aliyun.access_key'),
            config('aliyun.secret_key')
        );

        $this->client = new DefaultAcsClient($profile);
    }

    /**
     * 实名认证
     */
    public function verifyRealname($idNumber, $name)
    {
        // 实现阿里云实名认证 API 调用
        // ...
    }

    /**
     * 发送短信
     */
    public function sendSms($phone, $template, $params)
    {
        // 实现阿里云短信 API 调用
        // ...
    }
}
```

---

## 六、异步任务队列（Day 3）

### 6.1 配置 Redis 队列
编辑 `.env`：
```
QUEUE_CONNECTION=redis
```

### 6.2 创建异步任务
```bash
# 周一结算任务
php artisan make:job SettlementJob

# 紧急调货任务
php artisan make:job DispatchJob
```

### 6.3 定时任务（Scheduler）
编辑 `app/Console/Kernel.php`：
```php
protected function schedule(Schedule $schedule)
{
    // 每周一 00:05 执行结算
    $schedule->job(new SettlementJob())
        ->weekly()
        ->mondays()
        ->at('00:05');

    // 每小时检查紧急调货超时
    $schedule->job(new DispatchJob())
        ->hourly();
}
```

---

## 七、测试（Day 4）

### 7.1 单元测试
```bash
php artisan make:test OrderTest
php artisan make:test AuthTest
php artisan make:test DispatchTest
```

### 7.2 运行测试
```bash
php artisan test

# 或指定文件
php artisan test tests/Feature/AuthTest.php
```

---

## 八、开发流程

### Day 1
- [x] Laravel 项目初始化 + 依赖安装
- [ ] 数据库创建 + 迁移文件编写
- [ ] 执行迁移，验证 8 个表创建成功

### Day 2
- [ ] 创建 Models（8 个新表对应的 Model）
- [ ] 创建 Service 类（撮合、结算、调货）
- [ ] 创建 API Routes

### Day 3
- [ ] 实现认证模块（register / login）
- [ ] 支付宝沙箱测试通过
- [ ] 货拉拉 API 对接测试
- [ ] 创建异步任务

### Day 4-5
- [ ] 撮合引擎实现
- [ ] 市场收货流程
- [ ] 紧急调货逻辑

### Day 6-7
- [ ] 集成测试
- [ ] Bug 修复
- [ ] 灰度准备

---

## 九、常用 Laravel 命令

```bash
# 启动开发服务器
php artisan serve                          # 访问 http://localhost:8000

# 数据库操作
php artisan migrate                        # 执行迁移
php artisan migrate:rollback              # 回滚迁移
php artisan tinker                         # 交互式 Shell

# 生成代码
php artisan make:model Order -m            # 创建 Model + 迁移
php artisan make:controller OrderController # 创建 Controller
php artisan make:migration create_orders_table

# 队列
php artisan queue:work                     # 启动队列监听
php artisan queue:failed                   # 查看失败的任务

# 缓存
php artisan cache:clear                    # 清空缓存
php artisan route:cache                    # 路由缓存

# 测试
php artisan test                           # 运行全部测试
php artisan test --filter=AuthTest        # 运行指定测试
```

---

## 十、Git 分支策略

```bash
git init
git checkout -b develop

# 每个功能创建分支
git checkout -b feature/auth
git checkout -b feature/matching-engine
git checkout -b feature/settlement
git checkout -b feature/emergency-dispatch
```

---

## 十一、第一周交付物

- [ ] Laravel 项目框架完整搭建
- [ ] 8 个数据库迁移文件 + 表创建验证
- [ ] 8 个核心 Model
- [ ] 认证模块（register / login / logout）
- [ ] 撮合引擎基础算法（精确匹配）
- [ ] 支付宝、货拉拉、阿里云三个 API 对接测试通过
- [ ] 基础的异步任务框架就绪
- [ ] 所有代码 commit 到 develop 分支

---

> 💡 **建议**：每天 standup 检查清单进度，遇到问题立即反馈。
