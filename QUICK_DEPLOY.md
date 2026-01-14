# 🚀 MagicAI v9.9 快速部署指南 | Quick Deployment Guide

**最快 5 分钟完成部署 | Deploy in 5 minutes**

---

## ⚡ 方式 1: Docker 部署（推荐）| Method 1: Docker (Recommended)

### 前置要求 | Prerequisites
- **Docker** 20.10+ ([Install Docker](https://docs.docker.com/get-docker/))
- **Docker Compose** 2.0+ (included with Docker Desktop)
- **Git** (to clone repository)

### 一键部署 | One-Click Deploy

```bash
# 1. 克隆仓库 | Clone repository
git clone https://github.com/v3ai2026/333.git
cd 333

# 2. 运行部署脚本 | Run deployment script
chmod +x scripts/deploy-docker.sh
./scripts/deploy-docker.sh
```

**That's it! 就这么简单！** 🎉

### 访问应用 | Access Application

部署完成后，您可以访问：| After deployment, access:

- **🌐 API Backend**: http://localhost:8080
- **🩺 Health Check**: http://localhost:8080/health  
- **💾 MySQL Database**: `localhost:3306` (user: `magicai`, password: `password`)
- **🔴 Redis Cache**: `localhost:6379`

---

## 📝 方式 2: 传统 Laravel 部署 | Method 2: Traditional Laravel Deployment

### 前置要求 | Prerequisites
- PHP 8.2+
- Composer
- MySQL 8.0+
- Redis
- Node.js 18+

### 部署步骤 | Deployment Steps

```bash
# 1. 安装依赖 | Install dependencies
composer install
npm install

# 2. 环境配置 | Environment setup
cp .env.example .env
php artisan key:generate

# 3. 配置数据库 | Configure database
# Edit .env with your database credentials
nano .env

# 4. 运行迁移 | Run migrations
php artisan migrate

# 5. 编译资源 | Build assets
npm run build

# 6. 启动服务器 | Start server
php artisan serve
```

应用将运行在 | Application will run at: http://localhost:8000

---

## 🐋 Docker 进阶命令 | Advanced Docker Commands

### 查看日志 | View Logs
```bash
# 所有服务日志 | All service logs
docker compose logs -f

# 特定服务 | Specific service
docker compose logs -f python-backend
docker compose logs -f db
docker compose logs -f redis
```

### 容器管理 | Container Management
```bash
# 查看状态 | Check status
docker compose ps

# 停止服务 | Stop services
docker compose down

# 重启服务 | Restart services
docker compose restart

# 重新构建 | Rebuild
docker compose build --no-cache
docker compose up -d
```

### 进入容器 | Enter Container
```bash
# 进入后端容器 | Enter backend container
docker compose exec python-backend bash

# 进入数据库 | Enter database
docker compose exec db mysql -umagicai -ppassword magicai
```

---

## 🔧 故障排查 | Troubleshooting

### 问题 1: 端口被占用 | Port Already in Use

**症状**: Error: `bind: address already in use`

**解决方案**:

```bash
# 查看占用端口的进程 | Check which process uses the port
# Linux/macOS:
lsof -i :8080
lsof -i :3306
lsof -i :6379

# Windows (PowerShell):
netstat -ano | findstr :8080

# 停止占用进程或修改端口 | Stop process or change port
# Edit docker-compose.yml:
services:
  python-backend:
    ports:
      - "8081:8080"  # 改为 8081 | Change to 8081
```

### 问题 2: Docker 构建失败 | Docker Build Failed

**症状**: Build error during `docker compose build`

**解决方案**:

```bash
# 清理 Docker 缓存 | Clear Docker cache
docker system prune -a

# 重新构建（无缓存）| Rebuild without cache
docker compose build --no-cache

# 查看详细日志 | View detailed logs
docker compose build --progress=plain
```

### 问题 3: 服务无响应 | Service Not Responding

**症状**: Health check fails, service not accessible

**解决方案**:

```bash
# 1. 检查容器状态 | Check container status
docker compose ps

# 2. 查看日志找出错误 | View logs for errors
docker compose logs python-backend

# 3. 重启服务 | Restart service
docker compose restart python-backend

# 4. 如果持续失败，完全重启 | If still failing, full restart
docker compose down
docker compose up -d
```

### 问题 4: 数据库连接失败 | Database Connection Failed

**症状**: Can't connect to MySQL

**解决方案**:

```bash
# 1. 检查数据库是否运行 | Check if database is running
docker compose exec db mysqladmin ping

# 2. 测试数据库登录 | Test database login
docker compose exec db mysql -umagicai -ppassword

# 3. 检查环境变量 | Check environment variables
docker compose exec python-backend env | grep DB

# 4. 等待数据库初始化完成 | Wait for database initialization
# First startup takes 30-60 seconds
```

### 问题 5: Python 后端启动失败 | Python Backend Fails to Start

**症状**: Backend container keeps restarting

**解决方案**:

```bash
# 1. 查看后端日志 | View backend logs
docker compose logs python-backend

# 2. 检查依赖是否安装 | Check if dependencies installed
docker compose exec python-backend pip list

# 3. 手动运行查看错误 | Manually run to see errors
docker compose exec python-backend python app.py

# 4. 重新构建后端镜像 | Rebuild backend image
docker compose build --no-cache python-backend
docker compose up -d python-backend
```

---

## 🔒 安全配置 | Security Configuration

### 生产环境部署前 | Before Production Deployment

1. **修改默认密码** | Change default passwords:
   ```bash
   # Edit .env
   MYSQL_ROOT_PASSWORD=your_secure_password
   MYSQL_PASSWORD=your_secure_password
   ```

2. **生成新的 APP_KEY** | Generate new APP_KEY:
   ```bash
   php artisan key:generate
   ```

3. **配置防火墙** | Configure firewall:
   - Only expose necessary ports
   - Use nginx/Apache as reverse proxy
   - Enable HTTPS with SSL certificate

4. **环境变量** | Environment variables:
   ```bash
   APP_ENV=production
   APP_DEBUG=false
   ```

---

## 🌐 生产环境部署 | Production Deployment

### 使用 Docker 生产部署 | Docker Production Deployment

```bash
# 1. 使用生产配置 | Use production configuration
cp .env.example .env
# Edit .env for production settings

# 2. 构建优化镜像 | Build optimized images
docker compose -f docker-compose.prod.yml build

# 3. 启动生产服务 | Start production services
docker compose -f docker-compose.prod.yml up -d

# 4. 设置开机自启 | Set auto-start on boot
sudo systemctl enable docker
```

### 推荐的生产环境栈 | Recommended Production Stack

- **反向代理** | Reverse Proxy: Nginx / Traefik
- **SSL证书** | SSL Certificate: Let's Encrypt
- **监控** | Monitoring: Prometheus + Grafana
- **日志** | Logging: ELK Stack / Loki
- **备份** | Backup: Automated MySQL backups

---

## ⚙️ 环境变量配置 | Environment Variables

### 必需的环境变量 | Required Variables

```bash
# .env file
APP_KEY=base64:xxxxxxxxxxxxx  # Generated automatically
APP_ENV=local                  # local | production
APP_DEBUG=true                 # true | false

# Database
DB_CONNECTION=mysql
DB_HOST=db                     # Use 'db' for Docker
DB_PORT=3306
DB_DATABASE=magicai
DB_USERNAME=magicai
DB_PASSWORD=password

# Redis
REDIS_HOST=redis               # Use 'redis' for Docker
REDIS_PORT=6379

# Backend
VERTEX_AI_BACKEND_URL=http://python-backend:8080
```

### Python 后端环境变量 | Python Backend Variables

```bash
# backend-service/.env
PORT=8080
GCP_PROJECT_ID=your-gcp-project-id
GCP_REGION=us-central1
```

---

## 📊 性能优化 | Performance Optimization

### Docker 性能优化 | Docker Performance

1. **资源限制** | Resource limits:
   ```yaml
   # docker-compose.yml
   services:
     python-backend:
       deploy:
         resources:
           limits:
             cpus: '2'
             memory: 2G
   ```

2. **使用 BuildKit** | Use BuildKit:
   ```bash
   export DOCKER_BUILDKIT=1
   docker compose build
   ```

3. **多阶段构建** | Multi-stage builds:
   - Already implemented in Dockerfiles
   - Reduces image size

---

## 📚 其他资源 | Additional Resources

- **完整文档** | Full Documentation: [docs/](./docs/)
- **架构说明** | Architecture: [docs/ARCHITECTURE.md](./docs/ARCHITECTURE.md)
- **API 文档** | API Docs: [docs/API_DOCUMENTATION.md](./docs/API_DOCUMENTATION.md)
- **GitHub Issues**: https://github.com/v3ai2026/333/issues

---

## 🆘 需要帮助？ | Need Help?

1. **查看文档** | Check documentation in `docs/` folder
2. **搜索 Issues** | Search existing GitHub Issues
3. **创建新 Issue** | Create new Issue with:
   - Operating system
   - Docker version
   - Error logs
   - Steps to reproduce

---

## ✅ 部署检查清单 | Deployment Checklist

- [ ] Docker 和 Docker Compose 已安装 | Docker & Docker Compose installed
- [ ] 克隆仓库 | Repository cloned
- [ ] 运行 `./scripts/deploy-docker.sh` | Run deployment script
- [ ] 等待所有服务启动 (2-3 分钟) | Wait for services to start (2-3 min)
- [ ] 访问 http://localhost:8080/health | Access health check
- [ ] 检查所有服务状态 `docker compose ps` | Check services status
- [ ] 查看日志确认无错误 | Check logs for errors

**预计部署时间**: 5-10 分钟（首次）| **Estimated time**: 5-10 minutes (first time)

---

**🎉 恭喜！您的 MagicAI v9.9 已经部署成功！**

**🎉 Congratulations! Your MagicAI v9.9 is now deployed!**
