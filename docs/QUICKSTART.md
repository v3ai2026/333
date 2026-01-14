# moda.STUDIO 快速启动指南

## 🚀 三种启动方式（选择一种）

### 方式 1️⃣ : Docker（最简单 ⭐ 推荐）

```bash
# 一键启动全部 5 个端点
docker-compose -f docker-compose.prod.yml up -d

# 查看日志
docker-compose -f docker-compose.prod.yml logs -f

# 停止服务
docker-compose -f docker-compose.prod.yml down
```

**端点：**
- 🌐 Web: http://localhost:8000
- 🤖 API: http://localhost:8000/api
- 📊 Dashboard: http://localhost:8000/admin
- 🐍 Python: http://localhost:8080
- 💾 MySQL: localhost:3306
- 🔴 Redis: localhost:6379

---

### 方式 2️⃣ : 原生脚本（Windows/Linux/Mac）

**Windows:**
```bash
startup.bat
```

**Linux/Mac:**
```bash
chmod +x startup.sh
./startup.sh
```

---

### 方式 3️⃣ : 手动启动（逐个端点）

#### 端点 1: 数据库 (MySQL)
```bash
# 启动 MySQL 服务
# Windows: net start MySQL80
# Mac/Linux: brew services start mysql

# 导入数据库
mysql -u root -p < magicai.sql
```

#### 端点 2: Laravel Web (8000)
```bash
cd server
composer install
npm install
cp .env.example .env
php artisan key:generate
php artisan migrate --seed
php artisan serve
# 访问: http://localhost:8000
```

#### 端点 3: Python Backend (8080)
```bash
cd backend-service
python3 -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
python app.py
# 访问: http://localhost:8080
```

#### 端点 4: Redis Cache (6379) [可选]
```bash
# Mac: brew install redis && brew services start redis
# Linux: sudo apt-get install redis-server && sudo systemctl start redis
# Windows: WSL 或使用 Docker
```

#### 端点 5: Extensions/Themes [自动加载]
- 扩展自动从 `extensions/` 目录加载
- 主题自动从 `themes/` 目录加载

---

## 🔧 配置环境变量

### Laravel (.env)
```env
APP_NAME="moda.STUDIO"
APP_DEBUG=true
DB_HOST=localhost
DB_DATABASE=modastudio
DB_USERNAME=root
DB_PASSWORD=root

# AI 提供商
OPENAI_API_KEY=sk-...
ANTHROPIC_API_KEY=ant-...
AZURE_OPENAI_KEY=...

# Python 后端连接
VERTEX_AI_BACKEND_URL=http://localhost:8080
```

### Python (backend-service/.env 或环境变量)
```env
GCP_PROJECT_ID=gen-lang-client-0654563230
GCP_REGION=us-central1
MODEL_ID=gemini-2.0-flash
PORT=8080
```

---

## 📋 首次运行检查清单

- [ ] PHP 8.1+ 已安装
- [ ] Node.js 18+ 已安装
- [ ] Python 3.9+ 已安装
- [ ] MySQL 8.0+ 运行中
- [ ] Redis 已安装（可选）
- [ ] Docker 已安装（推荐使用 Docker 方式）
- [ ] Git 配置正确（`git config core.longpaths true`）

---

## 🧪 测试 API

### 1. 获取所有 AI 工具
```bash
curl http://localhost:8000/api/ai-tools
```

### 2. 执行 AI 工具
```bash
curl -X POST http://localhost:8000/api/ai-tools/ai-article-writer/execute \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "parameters": {
      "topic": "人工智能的未来",
      "length": "long"
    }
  }'
```

### 3. Python 后端健康检查
```bash
curl http://localhost:8080/health
```

---

## 🐛 故障排除

### 端口已占用
```bash
# 查找占用端口的进程
lsof -i :8000  # macOS/Linux
netstat -ano | findstr :8000  # Windows

# 杀死进程
kill -9 <PID>  # macOS/Linux
taskkill /PID <PID> /F  # Windows
```

### 数据库连接失败
```bash
# 检查 MySQL 运行状态
mysql -u root -p -h 127.0.0.1 -e "SELECT 1"

# 如果使用 Docker，重建容器
docker-compose -f docker-compose.prod.yml down -v
docker-compose -f docker-compose.prod.yml up -d
```

### 文件权限问题（Linux/Mac）
```bash
chmod -R 775 server/storage
chmod -R 775 server/bootstrap/cache
```

---

## 🔐 安全建议

- [ ] 生产环境设置 `APP_DEBUG=false`
- [ ] 使用强密码和密钥
- [ ] 配置 HTTPS/SSL
- [ ] 定期备份数据库
- [ ] 设置 API 速率限制
- [ ] 启用 CORS 白名单

---

## 📈 性能优化

```bash
# Laravel 缓存配置
php artisan config:cache
php artisan route:cache
php artisan view:cache

# 清除缓存
php artisan cache:clear
php artisan config:clear
php artisan route:clear
```

---

## 🎯 下一步

1. **部署**: 选择云服务商（AWS、Azure、Google Cloud）
2. **监控**: 设置 UptimeRobot、New Relic 等监控
3. **日志**: 配置 Sentry、LogRocket 等日志服务
4. **备份**: 设置自动化数据库备份
5. **CI/CD**: 使用 GitHub Actions 自动化部署

---

## 📞 支持

- 📖 完整文档: [server/.github/copilot-instructions.md](server/.github/copilot-instructions.md)
- 🔗 API 文档: [AI_TOOLS_INTEGRATION.md](AI_TOOLS_INTEGRATION.md)
- 🐳 Docker 配置: [docker-compose.yml](docker-compose.yml)
- 🚀 部署指南: [server/DEPLOY.md](server/DEPLOY.md)

---

**moda.STUDIO v9.9 - 您的下一代 AI SaaS 平台** 🚀
