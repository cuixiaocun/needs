#!/bin/bash

# ====================================================
# 🚀 需求平台 v4.1 开发环境一键初始化脚本
# ====================================================

set -e  # 错误时停止

echo "=========================================="
echo "需求平台 v4.1 开发环境初始化"
echo "=========================================="

# 1. 检查前置条件
echo ""
echo "[检查] Node.js 环境..."
if ! command -v node &> /dev/null; then
    echo "❌ 未找到 Node.js，请先安装 Node.js 16.x+"
    exit 1
fi
echo "✅ Node.js $(node -v)"

echo ""
echo "[检查] MySQL 环境..."
if ! command -v mysql &> /dev/null; then
    echo "❌ 未找到 MySQL，请先安装 MySQL 8.0+"
    exit 1
fi
echo "✅ MySQL found"

echo ""
echo "[检查] Redis 环境..."
if ! command -v redis-cli &> /dev/null; then
    echo "⚠️  未找到 Redis，可选但建议安装"
fi

# 2. 创建项目目录
echo ""
echo "[创建] 项目目录..."
if [ ! -d "needs-platform" ]; then
    mkdir -p needs-platform
    cd needs-platform
else
    cd needs-platform
fi
echo "✅ 在 $(pwd) 初始化"

# 3. 初始化 NestJS 项目
echo ""
echo "[初始化] NestJS 项目..."
if [ ! -d "api" ]; then
    npx @nestjs/cli@latest new api --package-manager npm
    cd api

    # 安装额外依赖
    echo "[安装] 核心依赖..."
    npm install mysql2 typeorm redis ioredis amqplib axios joi class-validator class-transformer
    npm install --save-dev @types/node

    cd ..
else
    echo "⚠️  api 目录已存在，跳过 NestJS 初始化"
fi

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

# 5. 导入表结构
echo ""
echo "[数据库] 初始化表结构..."
if [ -f "db_schema.sql" ]; then
    $mysql_cmd needs_db < db_schema.sql
    echo "✅ 表结构已导入"
else
    echo "❌ 未找到 db_schema.sql"
fi

# 6. 创建 .env 配置文件
echo ""
echo "[配置] 创建 .env 文件..."
cat > api/.env << 'EOF'
# Database
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=
DB_NAME=needs_db

# Redis
REDIS_HOST=localhost
REDIS_PORT=6379

# API Keys (需要手动填写)
ALIPAY_APP_ID=your_app_id
ALIPAY_PRIVATE_KEY=your_key
ALIPAY_PUBLIC_KEY=your_key

HUOLALA_API_KEY=your_key
HUOLALA_API_ENDPOINT=https://openapi.huolala.cn

ALIYUN_ACCESS_KEY=your_key
ALIYUN_SECRET_KEY=your_key
ALIYUN_REGION_ID=cn-shanghai

# Server
PORT=3000
NODE_ENV=development
JWT_SECRET=your_jwt_secret_key_here
EOF
echo "✅ .env 文件已创建（请手动填写 API keys）"

# 7. 创建 git 仓库
echo ""
echo "[Git] 初始化 Git 仓库..."
if [ ! -d ".git" ]; then
    git init

    cat > .gitignore << 'EOF'
# Dependencies
node_modules/
dist/

# Environment
.env
.env.local
.env.*.local

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db

# Logs
*.log
logs/
EOF

    git add .
    git commit -m "chore: initial commit v4.1 setup" 2>/dev/null || true
    echo "✅ Git 仓库已初始化"
else
    echo "⚠️  Git 仓库已存在"
fi

# 8. 总结
echo ""
echo "=========================================="
echo "✅ 开发环境初始化完成！"
echo "=========================================="
echo ""
echo "📋 后续步骤："
echo "1. 手动编辑 api/.env 文件，填入 API keys："
echo "   - ALIPAY_APP_ID / ALIPAY_PRIVATE_KEY"
echo "   - HUOLALA_API_KEY"
echo "   - ALIYUN_ACCESS_KEY / ALIYUN_SECRET_KEY"
echo ""
echo "2. 启动开发服务器："
echo "   cd api"
echo "   npm run start:dev"
echo ""
echo "3. 访问 API 文档："
echo "   http://localhost:3000/api"
echo ""
echo "4. 数据库连接信息："
echo "   Host: localhost"
echo "   Port: 3306"
echo "   Database: needs_db"
echo "   User: root"
echo ""
echo "📚 参考文档："
echo "   - 第一周开发清单: 第一周开发清单.md"
echo "   - 需求文档 v4.1: 农产品供需撮合平台-需求文档v4.1.md"
echo ""
echo "=========================================="
