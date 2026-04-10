# 农产品撮合平台 - 部署指南

## 一、本地开发环境启动

### 1.1 基础配置
```bash
# 进入项目目录
cd needs-api

# 安装依赖
composer install

# 生成应用密钥
php artisan key:generate

# 运行迁移
php artisan migrate

# 启动开发服务器
php artisan serve
```

访问：http://localhost:8000/api/health

### 1.2 启动队列监听（异步任务）
```bash
# 新终端窗口
php artisan queue:work
```

### 1.3 启动定时任务（另一终端）
```bash
# 监听计划任务
php artisan schedule:work
```

---

## 二、生产环境部署

### 2.1 服务器要求
```
PHP:          8.1+
MySQL:        8.0+
Redis:        5.0+ （可选，用于队列加速）
Composer:     2.0+
Git:          2.0+
```

### 2.2 部署步骤

#### Step 1: 克隆和配置
```bash
# 克隆项目到生产服务器
git clone <repository-url> /var/www/needs-api
cd /var/www/needs-api

# 安装依赖
composer install --no-dev --optimize-autoloader

# 配置 .env
cp .env.example .env
# 编辑 .env：DB 信息、API 密钥等
nano .env
```

#### Step 2: 数据库初始化
```bash
# 运行迁移
php artisan migrate --force

# 生成测试数据（可选）
php artisan db:seed
```

#### Step 3: 文件权限
```bash
# 设置存储目录权限
chmod -R 755 storage bootstrap/cache
chown -R www-data:www-data storage bootstrap/cache
```

#### Step 4: 配置 Nginx / Apache
**Nginx 配置示例：**
```nginx
server {
    listen 80;
    server_name api.needs-platform.com;
    root /var/www/needs-api/public;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-XSS-Protection "1; mode=block";
    add_header X-Content-Type-Options "nosniff";

    index index.php;

    charset utf-8;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
```

#### Step 5: 配置定时任务
```bash
# 编辑 crontab
crontab -e

# 添加以下行
* * * * * cd /var/www/needs-api && php artisan schedule:run >> /dev/null 2>&1
```

#### Step 6: 配置队列（推荐使用 Supervisor）
**Supervisor 配置 (/etc/supervisor/conf.d/needs-api.conf):**
```ini
[program:needs-queue]
process_name=%(program_name)s_%(process_num)02d
command=php /var/www/needs-api/artisan queue:work redis --sleep=3 --tries=3
autostart=true
autorestart=true
numprocs=4
redirect_stderr=true
stdout_logfile=/var/log/needs-queue.log
```

启动 Supervisor：
```bash
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl start needs-queue:*
```

---

## 三、第三方 API 配置清单

### 3.1 支付宝
- [ ] 获取 App ID
- [ ] 获取商户私钥（PKCS8 格式）
- [ ] 获取支付宝公钥
- [ ] 配置回调 URL
- [ ] 在 .env 中填写配置
- [ ] 沙箱测试通过

### 3.2 货拉拉
- [ ] 获取 API Key
- [ ] 测试运费预估接口
- [ ] 测试订单创建接口
- [ ] 配置 webhook（可选）

### 3.3 阿里云
- [ ] 激活短信服务
- [ ] 创建短信签名（≈1 小时审核）
- [ ] 创建短信模板（≈1 小时审核）
- [ ] 获取 Access Key
- [ ] 在 .env 中配置

### 3.4 DeepSeek AI（紧急调货 AI 对话）
- [ ] 注册 DeepSeek 账户
- [ ] 创建 API Key
- [ ] 在 .env 中配置

---

## 四、监控和日志

### 4.1 日志位置
```bash
# 应用日志
tail -f storage/logs/laravel.log

# 队列日志
tail -f /var/log/needs-queue.log

# 错误日志
tail -f /var/log/nginx/error.log
```

### 4.2 关键监控指标
- [ ] PHP 错误率 (< 0.1%)
- [ ] API 响应时间 (< 500ms)
- [ ] 数据库查询时间 (< 100ms)
- [ ] 队列处理延迟 (< 5min)
- [ ] 磁盘空间 (> 20% 可用)

### 4.3 告警配置
```
重要告警：
- PHP Fatal Error
- Database Connection Failed
- Queue Worker Stopped
- Disk Space Low (< 10%)
```

---

## 五、性能优化

### 5.1 应用优化
```bash
# 缓存配置
php artisan config:cache
php artisan route:cache
php artisan view:cache

# 自动加载优化
composer install --optimize-autoloader
```

### 5.2 数据库优化
- [ ] 添加必要的索引
- [ ] 定期清理日志表
- [ ] 定期备份数据库
- [ ] 配置数据库连接池

### 5.3 Redis 优化（如果使用）
```bash
# 监控 Redis 内存
redis-cli info memory

# 配置 maxmemory policy
redis-cli CONFIG SET maxmemory-policy allkeys-lru
```

---

## 六、备份和恢复

### 6.1 数据库备份
```bash
# 每天自动备份
0 2 * * * mysqldump -u root -p$DB_PASSWORD needs_db > /backup/needs_db_$(date +\%Y\%m\%d).sql
```

### 6.2 恢复数据库
```bash
mysql -u root -p needs_db < /backup/needs_db_20260410.sql
```

---

## 七、安全检查清单

生产环境部署前必须检查：

- [ ] .env 文件中的敏感信息已配置
- [ ] APP_DEBUG=false （生产环境）
- [ ] HTTPS 证书已配置
- [ ] 数据库密码已修改
- [ ] API 密钥已更新（支付宝、货拉拉等）
- [ ] 文件上传目录权限正确
- [ ] 日志文件不可被网络访问
- [ ] 定期检查安全更新
- [ ] 配置 CORS（如需跨域）
- [ ] 配置 Rate Limiting（防止滥用）

---

## 八、常见问题

### Q: 如何更新代码？
```bash
git pull origin main
composer install
php artisan migrate
php artisan cache:clear
```

### Q: 队列堆积怎么办？
```bash
# 查看失败的任务
php artisan queue:failed

# 重试失败的任务
php artisan queue:retry all

# 清空所有失败的任务
php artisan queue:flush
```

### Q: 如何重启应用？
```bash
# 重启 PHP-FPM
sudo systemctl restart php8.2-fpm

# 重启 Nginx
sudo systemctl restart nginx

# 重启队列
sudo supervisorctl restart needs-queue:*
```

---

## 九、灰度发布

### 9.1 蓝绿部署
```bash
# 在新服务器上部署（green）
# 完整测试后，更新负载均衡器指向新服务器
```

### 9.2 金丝雀部署
```bash
# 将 10% 流量切到新版本
# 监控 5 分钟，无问题则全量切换
```

---

## 十、应急响应

### 10.1 应急重启
```bash
# 快速重启应用
sudo systemctl restart php8.2-fpm nginx

# 清空缓存
redis-cli FLUSHDB

# 查看错误
tail -100f storage/logs/laravel.log
```

### 10.2 性能应急
```bash
# 临时关闭非关键任务
php artisan queue:pause

# 增加队列处理数
sudo supervisorctl update needs-queue:*

# 监控数据库连接
mysql -u root -p -e "SHOW PROCESSLIST;"
```

---

**部署完成后，建议进行全面的功能和压力测试。**

**维护周期：**
- 日常：监控日志、检查错误率
- 周度：清理日志、备份数据库
- 月度：性能分析、安全审计
- 季度：依赖更新、大版本评估
