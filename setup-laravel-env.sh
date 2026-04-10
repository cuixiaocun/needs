#!/bin/bash

# ====================================================
# 🚀 需求平台 v4.1 Laravel 开发环境一键初始化脚本
# ====================================================

set -e

echo "=========================================="
echo "需求平台 v4.1 Laravel 开发环境初始化"
echo "=========================================="

# 1. 检查前置条件
echo ""
echo "[检查] PHP 环境..."
if ! command -v php &> /dev/null; then
    echo "❌ 未找到 PHP，请先安装 PHP 8.1+"
    exit 1
fi
PHP_VERSION=$(php -v | head -n 1)
echo "✅ $PHP_VERSION"

echo ""
echo "[检查] Composer 环境..."
if ! command -v composer &> /dev/null; then
    echo "❌ 未找到 Composer，请先安装 Composer"
    exit 1
fi
echo "✅ $(composer -v | head -n 1)"

echo ""
echo "[检查] MySQL 环境..."
if ! command -v mysql &> /dev/null; then
    echo "❌ 未找到 MySQL，请先安装 MySQL 8.0+"
    exit 1
fi
echo "✅ MySQL found"

echo ""
echo "[检查] Redis（可选但建议）..."
if command -v redis-cli &> /dev/null; then
    echo "✅ Redis found"
else
    echo "⚠️  未找到 Redis（可选）"
fi

# 2. 创建项目目录
echo ""
echo "[创建] Laravel 项目..."
if [ ! -d "needs-api" ]; then
    composer create-project laravel/laravel needs-api
    cd needs-api
else
    echo "⚠️  needs-api 目录已存在，跳过项目创建"
    cd needs-api
fi

echo "✅ 在 $(pwd) 初始化"

# 3. 安装核心依赖
echo ""
echo "[安装] Composer 依赖..."

# 基础依赖
composer require \
    laravel/sanctum \
    guzzlehttp/guzzle \
    doctrine/dbal

# 支付宝 SDK
echo "[安装] 支付宝 SDK..."
composer require alipay/easysdk 2>/dev/null || echo "⚠️  支付宝 SDK 可能需要手动配置"

# 阿里云 SDK
echo "[安装] 阿里云 SDK..."
composer require aliyun/sdk 2>/dev/null || echo "⚠️  阿里云 SDK 可能需要手动配置"

echo "✅ 依赖安装完成"

# 4. 创建数据库
echo ""
echo "[数据库] 创建数据库..."
read -p "请输入 MySQL root 密码（按 Enter 跳过，默认空）: " mysql_password

if [ -z "$mysql_password" ]; then
    mysql_cmd="mysql -u root"
else
    mysql_cmd="mysql -u root -p$mysql_password"
fi

# 创建数据库
$mysql_cmd -e "CREATE DATABASE IF NOT EXISTS needs_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
echo "✅ 数据库 needs_db 已创建"

# 5. 配置 .env 文件
echo ""
echo "[配置] 创建 .env 文件..."

# 复制 .env.example 到 .env
cp .env.example .env

# 生成应用 key
php artisan key:generate

# 更新数据库配置
sed -i '' "s/DB_DATABASE=laravel/DB_DATABASE=needs_db/" .env
sed -i '' "s/DB_USERNAME=root/DB_USERNAME=root/" .env
sed -i '' "s/DB_PASSWORD=/DB_PASSWORD=/" .env

# 配置队列
sed -i '' "s/QUEUE_CONNECTION=sync/QUEUE_CONNECTION=redis/" .env

cat >> .env << 'EOF'

# ========== v4.1 配置 ==========

# 支付宝沙箱
ALIPAY_APP_ID=your_app_id
ALIPAY_PRIVATE_KEY=your_private_key
ALIPAY_PUBLIC_KEY=your_public_key
ALIPAY_SANDBOX=true

# 货拉拉
HUOLALA_API_KEY=your_api_key
HUOLALA_SANDBOX=true

# 阿里云
ALIYUN_ACCESS_KEY=your_access_key
ALIYUN_SECRET_KEY=your_secret_key
ALIYUN_REGION=cn-shanghai

# JWT
JWT_SECRET=your_jwt_secret_key
JWT_ALGORITHM=HS256
EOF

echo "✅ .env 文件已创建（请手动填写 API keys）"

# 6. 生成迁移文件
echo ""
echo "[数据库] 生成迁移文件..."

php artisan make:migration create_farmer_deposits_table
php artisan make:migration create_farmer_deposit_logs_table
php artisan make:migration create_emergency_dispatch_logs_table
php artisan make:migration create_agent_call_records_table
php artisan make:migration create_market_receiving_records_table
php artisan make:migration create_market_dispatch_records_table
php artisan make:migration create_farmer_settlements_table
php artisan make:migration create_settlement_items_table

echo "✅ 迁移文件已生成（database/migrations/）"

# 7. 创建 Models
echo ""
echo "[模型] 生成 Model 文件..."

php artisan make:model FarmerDeposit
php artisan make:model FarmerDepositLog
php artisan make:model EmergencyDispatchLog
php artisan make:model AgentCallRecord
php artisan make:model MarketReceivingRecord
php artisan make:model MarketDispatchRecord
php artisan make:model FarmerSettlement
php artisan make:model SettlementItem

echo "✅ Model 文件已生成（app/Models/）"

# 8. 创建目录结构
echo ""
echo "[目录] 创建应用目录..."

mkdir -p app/Services
mkdir -p app/Http/Controllers/Api/Auth
mkdir -p app/Http/Controllers/Api/Order
mkdir -p app/Http/Controllers/Api/Market
mkdir -p app/Http/Controllers/Api/Settlement
mkdir -p app/Http/Controllers/Api/Dispatch
mkdir -p app/Integrations
mkdir -p storage/cert

echo "✅ 目录结构已创建"

# 9. 初始化 Git 仓库
echo ""
echo "[Git] 初始化 Git 仓库..."

git init
git checkout -b develop

cat > .gitignore << 'EOF'
/node_modules
/public/hot
/public/storage
/storage/*.key
/vendor
.env
.env.backup
.env.production
.phpunit.result.cache
Homestead.json
Homestead.yaml
auth.json
.idea
.vscode
*.swp
*.swo
*~
.DS_Store
Thumbs.db
EOF

git add .
git commit -m "chore: initial Laravel v4.1 setup" 2>/dev/null || echo "⚠️  Git 初始化可能有问题"

echo "✅ Git 仓库已初始化（develop 分支）"

# 10. 总结
echo ""
echo "=========================================="
echo "✅ Laravel 开发环境初始化完成！"
echo "=========================================="
echo ""
echo "📋 后续步骤："
echo ""
echo "1️⃣  编辑 .env 文件，填入 API keys："
echo "   nano .env"
echo "   或"
echo "   vi .env"
echo ""
echo "   需要填写的项："
echo "   - ALIPAY_APP_ID / ALIPAY_PRIVATE_KEY"
echo "   - HUOLALA_API_KEY"
echo "   - ALIYUN_ACCESS_KEY / ALIYUN_SECRET_KEY"
echo ""
echo "2️⃣  编写 8 个迁移文件的表结构"
echo "   编辑 database/migrations/ 下的文件"
echo ""
echo "3️⃣  执行数据库迁移："
echo "   php artisan migrate"
echo ""
echo "4️⃣  启动开发服务器："
echo "   php artisan serve"
echo ""
echo "5️⃣  访问应用："
echo "   http://localhost:8000"
echo ""
echo "6️⃣  (可选) 启动队列监听："
echo "   php artisan queue:work redis"
echo ""
echo "📚 重要文件："
echo "   - 路由: routes/api.php"
echo "   - Models: app/Models/"
echo "   - Controllers: app/Http/Controllers/Api/"
echo "   - Services: app/Services/"
echo "   - Integrations: app/Integrations/"
echo ""
echo "💾 数据库连接信息："
echo "   Host: 127.0.0.1"
echo "   Port: 3306"
echo "   Database: needs_db"
echo "   User: root"
echo ""
echo "=========================================="
echo ""
echo "🎯 第一周任务："
echo "   Day 1: 项目初始化 + 迁移文件编写 + 数据库执行"
echo "   Day 2: Model + Service 基础框架"
echo "   Day 3: API 对接（支付宝、货拉拉、阿里云）"
echo "   Day 4-5: 核心业务逻辑实现"
echo "   Day 6-7: 测试 + Bug 修复"
echo ""
