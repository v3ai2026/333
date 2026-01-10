# MagicAI v9.9 部署指南

完整的 MagicAI 生产部署步骤。

## 📋 目录

1. [前置条件](#前置条件)
2. [本地快速启动](#本地快速启动)
3. [生产部署](#生产部署)
4. [故障排查](#故障排查)
5. [监控和维护](#监控和维护)

---

## 前置条件

### 系统要求

- Docker 20.10+ 和 Docker Compose 2.0+
- 8GB+ 可用内存
- 20GB+ 磁盘空间

### 需要的账户与密钥

- **GCP 账户** - Vertex AI 和 Cloud Text-to-Speech
- **支付网关** - Stripe/PayPal/Razorpay 密钥（可选）
- **邮件服务** - SMTP 服务器 (Mailtrap/SendGrid)
- **AWS S3** - 文件存储（可选）

---

## 本地快速启动

### 1️⃣ 初始化项目

```bash
# 克隆仓库
git clone https://github.com/v3ai2026/MagicAI-v9.9.git
cd "MagicAI v9.9"

# 创建 .env 文件
cp .env.example .env

# 编辑 .env 配置本地开发参数
nano .env
# 关键字段：
# - APP_ENV=local
# - APP_DEBUG=true
# - MYSQL_PASSWORD=your_secure_password
```

### 2️⃣ 启动容器

```bash
# 构建并启动所有服务
docker-compose up -d

# 查看日志
docker-compose logs -f web python-backend

# 等待数据库初始化（约 10-15 秒）
sleep 15
```

### 3️⃣ 运行迁移和初始化

```bash
# 进入 Laravel 容器
docker-compose exec web bash

# 生成 APP_KEY
php artisan key:generate

# 运行数据库迁移
php artisan migrate

# 创建演示数据（可选）
php artisan db:seed

# 编译资源
npm run build

# 退出容器
exit
```

### 4️⃣ 验证服务

```bash
# Laravel 应用
curl -s http://localhost:8000 | head -20

# Python 后端健康检查
curl http://localhost:8080/health | jq .

# Redis 连接
docker-compose exec redis redis-cli ping

# 数据库连接
docker-compose exec db mysql -umagicai -ppassword -e "SELECT 1"
```

### 5️⃣ 访问应用

- **Web 应用**: <http://localhost:8000>
- **API 文档**: <http://localhost:8000/api/documentation>
- **Backend API**: <http://localhost:8080/status>

---

## 生产部署

### 🚀 方案 1：服务器部署（推荐用于小到中规模）

#### 服务器配置

```yaml
规格:
  OS: Ubuntu 22.04 LTS
  CPU: 4+ cores
  RAM: 16GB+
  Storage: 100GB+ SSD
  Network: 静态 IP、开放 80、443、3306、6379 端口
```

#### 部署步骤

```bash
# 1. SSH 连接到服务器
ssh root@your.server.ip

# 2. 安装 Docker 和 Docker Compose
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# 3. 克隆并配置
cd /opt
git clone https://github.com/v3ai2026/MagicAI-v9.9.git
cd MagicAI\ v9.9

# 4. 生成安全的密钥
echo "APP_KEY=$(php -r 'echo base64_encode(random_bytes(32));')" >> .env

# 5. 配置生产环境变量
cp .env.example .env
# 编辑 .env 设置：
#   APP_ENV=production
#   APP_DEBUG=false
#   APP_URL=https://yourdomain.com
#   MYSQL_PASSWORD=生成强密码
#   GCP_PROJECT_ID=你的项目ID
nano .env

# 6. 启动容器
docker-compose up -d

# 7. 运行迁移
docker-compose exec web php artisan migrate --force

# 8. 设置 SSL（使用 Nginx 反向代理）
# 参考下面的 Nginx 配置
```

#### Nginx 反向代理配置

创建 `/etc/nginx/sites-available/magicai`:

```nginx
upstream laravel {
    server localhost:8000;
}

upstream python_backend {
    server localhost:8080;
}

server {
    listen 80;
    server_name yourdomain.com www.yourdomain.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name yourdomain.com www.yourdomain.com;

    ssl_certificate /etc/letsencrypt/live/yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/yourdomain.com/privkey.pem;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    client_max_body_size 100M;

    # Laravel Web App
    location / {
        proxy_pass http://laravel;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Python Backend API
    location /api/vertex/ {
        proxy_pass http://python_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    # 静态文件缓存
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg|woff|woff2|ttf|eot)$ {
        expires 365d;
        add_header Cache-Control "public, immutable";
    }
}
```

启用网站：

```bash
ln -s /etc/nginx/sites-available/magicai /etc/nginx/sites-enabled/
nginx -t
systemctl restart nginx

# 配置 SSL（Let's Encrypt）
apt install certbot python3-certbot-nginx -y
certbot certonly --nginx -d yourdomain.com -d www.yourdomain.com
```

### 🌐 方案 2：GCP Cloud Run 部署

```bash
# 1. 配置 GCP CLI
gcloud init
gcloud config set project YOUR_PROJECT_ID

# 2. 构建并推送镜像
docker build -t gcr.io/YOUR_PROJECT_ID/magicai-web:latest ./Magicai-Server-Files
docker push gcr.io/YOUR_PROJECT_ID/magicai-web:latest

docker build -t gcr.io/YOUR_PROJECT_ID/magicai-backend:latest ./backend-service
docker push gcr.io/YOUR_PROJECT_ID/magicai-backend:latest

# 3. 创建 Cloud SQL 数据库
gcloud sql instances create magicai-db \
  --database-version=MYSQL_8_0 \
  --tier=db-f1-micro \
  --region=us-central1 \
  --root-password=YOUR_PASSWORD

# 4. 部署 Web 应用
gcloud run deploy magicai-web \
  --image gcr.io/YOUR_PROJECT_ID/magicai-web:latest \
  --platform managed \
  --region us-central1 \
  --set-env-vars="APP_ENV=production,DB_HOST=CLOUD_SQL_IP" \
  --allow-unauthenticated

# 5. 部署 Python 后端
gcloud run deploy magicai-backend \
  --image gcr.io/YOUR_PROJECT_ID/magicai-backend:latest \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated
```

### 🐳 方案 3：Kubernetes 部署

```bash
# 创建命名空间
kubectl create namespace magicai

# 创建 Secret（敏感信息）
kubectl create secret generic magicai-secrets \
  --from-literal=db-password=YOUR_PASSWORD \
  --from-literal=redis-password=YOUR_PASSWORD \
  -n magicai

# 应用 Kubernetes manifests（如果有的话）
kubectl apply -f k8s/ -n magicai

# 验证部署
kubectl get pods -n magicai
kubectl logs -f deployment/magicai-web -n magicai
```

---

## 故障排查

### 数据库连接失败

```bash
# 检查 MySQL 状态
docker-compose logs db

# 进入 MySQL 容器调试
docker-compose exec db bash
mysql -uroot -psecret -e "SHOW DATABASES;"

# 重新初始化数据库
docker-compose down -v
docker-compose up -d db
```

### Redis 连接问题

```bash
# 检查 Redis
docker-compose logs redis

# 测试连接
docker-compose exec redis redis-cli ping

# 清空缓存
docker-compose exec redis redis-cli FLUSHALL
```

### Python 后端无法启动

```bash
# 检查日志
docker-compose logs python-backend

# 验证依赖
docker-compose exec python-backend pip list

# 手动运行
docker-compose exec python-backend python -m app
```

### Laravel 权限问题

```bash
# 修复存储目录权限
docker-compose exec web chown -R www-data:www-data /var/www/html/storage
docker-compose exec web chmod -R 775 /var/www/html/storage
```

---

## 监控和维护

### 定期备份

```bash
# 备份数据库
docker-compose exec db mysqldump -uroot -psecret magicai > backup_$(date +%Y%m%d).sql

# 备份 Redis
docker-compose exec redis redis-cli --rdb /data/backup.rdb

# 备份存储目录
tar -czf storage_backup_$(date +%Y%m%d).tar.gz ./storage
```

### 日志管理

```bash
# 查看实时日志
docker-compose logs -f --tail=100

# 导出日志
docker-compose logs > all_logs_$(date +%Y%m%d).txt

# 清理日志
docker container prune -f
docker image prune -f
```

### 性能监控

```bash
# CPU 和内存使用
docker stats

# 数据库慢查询
docker-compose exec db mysql -uroot -psecret -e "SHOW PROCESSLIST;"

# Redis 内存使用
docker-compose exec redis redis-cli INFO memory
```

### 更新和升级

```bash
# 拉取最新代码
git pull origin main

# 重新构建镜像
docker-compose build --no-cache

# 重新启动服务
docker-compose up -d

# 运行新的迁移
docker-compose exec web php artisan migrate
```

---

## 📞 支持

- **问题和 Bug**: <https://github.com/v3ai2026/MagicAI-v9.9/issues>
- **讨论**: <https://github.com/v3ai2026/MagicAI-v9.9/discussions>
- **文档**: <https://docs.magicai.local>

---

**最后更新**: 2026-01-10 | **版本**: 9.9.0
