# MagicAI v9.9 部署准备清单

完整的部署前准备和启动步骤。

## ✅ 已完成的部分

### 基础设施

- ✅ Docker Compose 配置 (3 个容器：MySQL、Redis、Laravel、Python后端)
- ✅ Python Flask 后端完整实现（健康检查、AI端点、异步工作支持）
- ✅ Laravel 应用结构完整
- ✅ Nginx 反向代理配置模板

### 配置文件

- ✅ `.env.example` - 完整的环境变量模板
- ✅ `backend-service/.env.example` - Python 后端配置
- ✅ `docker-compose.yml` - 生产级配置（健康检查、资源限制）

### 部署工具

- ✅ `deploy.sh` - Linux/macOS 一键部署脚本
- ✅ `deploy.bat` - Windows 一键部署脚本
- ✅ `DEPLOYMENT.md` - 完整部署指南

### 文档

- ✅ `.github/copilot-instructions.md` - AI 编码代理指南

---

## 🚀 立即启动应用

### 方案 1：本地快速启动（推荐）

#### Windows 用户

```bash
# 双击运行
deploy.bat

# 或在命令行运行
cd "MagicAI v9.9"
deploy.bat
```

#### macOS/Linux 用户

```bash
cd "MagicAI v9.9"
chmod +x deploy.sh
bash deploy.sh
```

**预期输出**：

```
✓ Docker 已安装
✓ 创建 .env 文件
✓ 镜像构建完成
✓ 容器已启动
✓ 数据库已就绪
✓ 迁移完成
✓ 前端资源编译完成
✓ 部署完成！

📍 访问地址:
   🌐 Web 应用: http://localhost:8000
   📚 API 文档: http://localhost:8000/api/documentation
   🔧 后端 API: http://localhost:8080/status
```

---

## 📋 部署前核实清单

部署前，请确保以下条件已满足：

### 本地开发

- [ ] Docker Desktop 已安装（Windows/macOS）或 Docker Engine（Linux）
- [ ] Docker Compose 2.0+
- [ ] Git 已安装
- [ ] 8GB+ 可用 RAM

### 生产部署

- [ ] 购买域名或配置 DNS
- [ ] 服务器已准备（Ubuntu 22.04 LTS 推荐）
- [ ] SSL 证书（Let's Encrypt 或商用证书）
- [ ] GCP 账户（带 Vertex AI 访问权限）
- [ ] 支付网关账户（Stripe/PayPal）

### GCP 配置（生产必需）

- [ ] 创建 GCP 项目
- [ ] 启用 Vertex AI API
- [ ] 创建服务账户
- [ ] 下载服务账户 JSON 密钥
- [ ] 设置 `GOOGLE_APPLICATION_CREDENTIALS` 环境变量

---

## 🔧 启动后的关键操作

### 1. 访问应用

```
Web: http://localhost:8000
API: http://localhost:8080/status
```

### 2. 查看日志

```bash
# 所有服务
docker-compose logs -f

# 特定服务
docker-compose logs -f web          # Laravel
docker-compose logs -f python-backend  # Python
docker-compose logs -f db           # MySQL
docker-compose logs -f redis        # Redis
```

### 3. 进入容器调试

```bash
# Laravel 容器
docker-compose exec web bash
php artisan tinker

# Python 容器
docker-compose exec python-backend bash
python -c "from app import app; print(app.url_map)"

# MySQL 容器
docker-compose exec db bash
mysql -umagicai -p
```

### 4. 管理数据库

```bash
# 运行迁移
docker-compose exec web php artisan migrate

# 创建演示数据
docker-compose exec web php artisan db:seed

# 回滚迁移
docker-compose exec web php artisan migrate:rollback
```

---

## 📦 服务信息

| 服务 | URL | 用户名 | 密码 | 端口 |
|------|-----|--------|------|------|
| Laravel Web | <http://localhost:8000> | - | - | 8000 |
| Python API | <http://localhost:8080> | - | - | 8080 |
| MySQL | localhost | magicai | password | 3306 |
| Redis | localhost | - | - | 6379 |

---

## 🔐 生产环境前的关键配置

编辑 `.env` 文件并更新以下内容：

```bash
# 应用
APP_ENV=production
APP_DEBUG=false
APP_URL=https://yourdomain.com
APP_KEY=base64:generated_key  # 自动生成

# 数据库
MYSQL_PASSWORD=强密码必须修改
DB_PASSWORD=强密码必须修改

# Redis
REDIS_PASSWORD=强密码必须修改

# GCP
GCP_PROJECT_ID=your-actual-project-id
GOOGLE_APPLICATION_CREDENTIALS=/path/to/credentials.json

# 支付网关
STRIPE_SECRET_KEY=sk_live_...
PAYPAL_SECRET=...

# 邮件
MAIL_FROM_ADDRESS=noreply@yourdomain.com
MAIL_USERNAME=your-email@gmail.com
MAIL_PASSWORD=your-app-password

# SSL
SANCTUM_STATEFUL_DOMAINS=yourdomain.com
SESSION_DOMAIN=.yourdomain.com
```

---

## 🌐 生产部署选项

### 选项 1：自托管服务器（推荐小到中等规模）

- 成本最低
- 完全控制
- 需要自己管理服务器
- 参考：[DEPLOYMENT.md](DEPLOYMENT.md) 中的"服务器部署"部分

### 选项 2：GCP Cloud Run

- 完全托管
- 自动扩展
- 按使用付费
- 参考：[DEPLOYMENT.md](DEPLOYMENT.md) 中的"GCP Cloud Run"部分

### 选项 3：Kubernetes

- 企业级
- 复杂设置
- 高可用性
- 参考：[DEPLOYMENT.md](DEPLOYMENT.md) 中的"Kubernetes"部分

---

## 📞 故障排查

### 容器无法启动

```bash
# 检查日志
docker-compose logs

# 重建并启动
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### 数据库连接失败

```bash
# 检查 MySQL 状态
docker-compose logs db

# 重置数据库
docker-compose down -v
docker-compose up -d db
```

### Python 后端无法启动

```bash
# 检查日志
docker-compose logs python-backend

# 验证依赖
docker-compose exec python-backend pip list
```

### Web 应用无法访问

```bash
# 检查 Laravel 日志
docker-compose exec web tail -f storage/logs/laravel.log

# 检查权限
docker-compose exec web chown -R www-data:www-data /var/www/html/storage
```

---

## 📖 更多文档

- [部署指南](DEPLOYMENT.md) - 详细的部署步骤
- [AI 编码指南](.github/copilot-instructions.md) - 开发指南
- [Docker Compose 配置](docker-compose.yml) - 容器配置
- [环境变量模板](.env.example) - 所有可用配置

---

## 🎯 下一步

1. **本地测试** - 运行 `deploy.sh` 或 `deploy.bat`
2. **验证功能** - 检查 Web 和 API 端点
3. **配置生产** - 编辑 `.env` 文件
4. **部署上线** - 按照 DEPLOYMENT.md 中的步骤
5. **监控和维护** - 查看日志、备份数据、定期更新

---

**最后更新**: 2026-01-10  
**版本**: 9.9.0  
**状态**: ✅ 准备部署
