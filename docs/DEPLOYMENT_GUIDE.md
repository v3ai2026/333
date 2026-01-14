# MagicAI v9.9 部署指南

本指南提供 MagicAI v9.9 的完整部署选项，包括本地开发、Docker 部署和 CI/CD 流程。

## 📑 目录

- [本地开发环境](#本地开发环境)
- [Docker 部署](#docker-部署)
- [GitHub Actions CI/CD](#github-actions-cicd)
- [环境变量配置](#环境变量配置)
- [故障排查](#故障排查)

---

## 🖥️ 本地开发环境

### 前提条件

- **PHP**: >= 8.1
- **Composer**: 最新版本
- **Node.js**: >= 16.x
- **npm** 或 **yarn**
- **MySQL**: >= 5.7 或 **MariaDB**: >= 10.3
- **Redis**: >= 5.0（可选，用于缓存和队列）

### Laravel 应用设置

#### 1. 克隆仓库

```bash
git clone https://github.com/v3ai2026/333.git magicai
cd magicai
```

#### 2. 安装 PHP 依赖

```bash
composer install
```

#### 3. 安装 Node.js 依赖

```bash
npm install
# 或使用 yarn
yarn install
```

#### 4. 环境配置

```bash
# 复制环境配置文件
cp .env.example .env

# 生成应用密钥
php artisan key:generate
```

#### 5. 配置数据库

编辑 `.env` 文件，设置数据库连接：

```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=magicai
DB_USERNAME=your_username
DB_PASSWORD=your_password
```

#### 6. 运行数据库迁移

```bash
php artisan migrate
```

#### 7. 编译前端资源

```bash
# 开发环境
npm run dev

# 生产环境
npm run build
```

#### 8. 启动开发服务器

```bash
php artisan serve
```

应用将在 `http://localhost:8000` 运行。

### Backend Service 设置

#### 1. 进入 backend-service 目录

```bash
cd backend-service
```

#### 2. 创建虚拟环境（推荐）

```bash
python3 -m venv venv
source venv/bin/activate  # Linux/Mac
# 或
venv\Scripts\activate     # Windows
```

#### 3. 安装 Python 依赖

```bash
pip install -r requirements.txt
```

#### 4. 配置环境变量

```bash
# 复制环境配置文件
cp .env.example .env

# 编辑 .env 文件，设置必要的配置
```

#### 5. 启动后端服务

```bash
python app.py
# 或使用 uvicorn
uvicorn app:app --reload --port 8080
```

服务将在 `http://localhost:8080` 运行。

---

## 🐋 Docker 部署

MagicAI v9.9 提供多个 Docker Compose 配置文件，适用于不同的部署场景。

### 快速开始（推荐）

使用默认的 `docker-compose.yml`：

```bash
# 构建并启动服务
docker compose up -d

# 查看日志
docker compose logs -f

# 停止服务
docker compose down
```

### 可用的 Docker Compose 配置

| 文件 | 用途 | 说明 |
|------|------|------|
| `docker-compose.yml` | 标准部署 | 包含 web、database、redis 和 backend 服务 |
| `docker-compose.simple.yml` | 简单部署 | 最小化配置，适合快速测试 |
| `docker-compose.local.yml` | 本地开发 | 包含开发工具和热重载 |
| `docker-compose.prod.yml` | 生产环境 | 优化的生产配置 |
| `docker-compose.full.yml` | 完整栈 | 包含所有服务和工具 |
| `docker-compose.full-stack.yml` | 全栈部署 | 完整的应用栈 |
| `compose.llamaspider.yml` | Llama Spider | Web 爬虫服务 |

### 使用特定配置文件

```bash
# 使用生产配置
docker compose -f docker-compose.prod.yml up -d

# 使用完整栈配置
docker compose -f docker-compose.full-stack.yml up -d

# 使用多个配置文件
docker compose -f docker-compose.yml -f docker-compose.local.yml up -d
```

### Docker 部署步骤

#### 1. 准备环境变量

```bash
# 确保 .env 文件存在
cp .env.example .env

# 编辑 .env，设置必要的配置
nano .env
```

#### 2. 构建镜像

```bash
docker compose build
```

#### 3. 启动服务

```bash
docker compose up -d
```

#### 4. 运行数据库迁移

```bash
docker compose exec web php artisan migrate --force
```

#### 5. 访问应用

- **Web 应用**: http://localhost:8000
- **API 文档**: http://localhost:8000/api/documentation
- **Backend API**: http://localhost:8080
- **Backend 健康检查**: http://localhost:8080/health

#### 6. 查看服务状态

```bash
# 查看运行中的容器
docker compose ps

# 查看日志
docker compose logs -f

# 查看特定服务的日志
docker compose logs -f web
docker compose logs -f python-backend
```

---

## 🔄 GitHub Actions CI/CD

MagicAI v9.9 使用 GitHub Actions 进行自动化 CI/CD。

### 工作流文件

#### 1. `pages.yml` - GitHub Pages 部署

**触发条件**:
- 推送到 `main` 分支
- 手动触发

**功能**:
- 构建静态网站
- 部署到 GitHub Pages
- 自动创建 fallback 页面

**访问地址**: https://v3ai2026.github.io/333/

**设置说明**: 请参考 [GITHUB_PAGES_SETUP.md](GITHUB_PAGES_SETUP.md)

#### 2. `deploy.yml` - Docker CI/CD Pipeline

**触发条件**:
- 推送到 `develop` 或 `staging` 分支
- 手动触发

**阶段**:

1. **代码检查 (check)**
   - Python 语法检查 (flake8)
   - 依赖验证
   - Docker 文件验证

2. **构建 (build)**
   - 构建 backend-service Docker 镜像
   - 构建 web application 镜像（如果存在）
   - Docker 层缓存优化

3. **部署 (deploy)**
   - 创建环境配置
   - 启动 Docker 容器
   - 运行数据库迁移
   - 清除应用缓存

4. **验证 (verify)**
   - 检查容器状态
   - 测试 Web 应用响应
   - 测试 Backend API 健康
   - 测试数据库连接
   - 测试 Redis 连接

5. **通知 (notify)**
   - 部署摘要
   - 服务访问 URL
   - 失败通知

### 分支策略

- **`main`**: 生产环境，触发 GitHub Pages 部署
- **`develop`**: 开发环境，触发 Docker CI/CD
- **`staging`**: 预发布环境，触发 Docker CI/CD

### 手动触发工作流

1. 进入 GitHub 仓库的 **Actions** 标签
2. 选择要运行的工作流
3. 点击 **Run workflow** 按钮
4. 选择分支
5. 点击 **Run workflow**

---

## ⚙️ 环境变量配置

### Laravel 应用 (`.env`)

#### 必需配置

```env
# 应用基础配置
APP_NAME=MagicAI
APP_ENV=production
APP_KEY=base64:your-app-key-here
APP_DEBUG=false
APP_URL=http://your-domain.com

# 数据库配置
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=magicai
DB_USERNAME=your_username
DB_PASSWORD=your_password

# Redis 配置
REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379

# 缓存配置
CACHE_DRIVER=redis
QUEUE_CONNECTION=redis
SESSION_DRIVER=redis
```

#### 可选配置

```env
# 邮件配置
MAIL_MAILER=smtp
MAIL_HOST=smtp.mailtrap.io
MAIL_PORT=2525
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_ENCRYPTION=null
MAIL_FROM_ADDRESS="hello@example.com"
MAIL_FROM_NAME="${APP_NAME}"

# AI 服务配置
OPENAI_API_KEY=your-openai-api-key
ANTHROPIC_API_KEY=your-anthropic-api-key
GEMINI_API_KEY=your-gemini-api-key

# 日志配置
LOG_CHANNEL=stack
LOG_LEVEL=debug
```

### Backend Service (`backend-service/.env`)

```env
# 服务配置
APP_ENV=production
DEBUG=False
HOST=0.0.0.0
PORT=8080

# 数据库连接（如果需要）
DATABASE_URL=postgresql://user:password@localhost:5432/dbname

# API 密钥
OPENAI_API_KEY=your-openai-api-key
ANTHROPIC_API_KEY=your-anthropic-api-key

# 日志配置
LOG_LEVEL=INFO
```

### Docker 环境变量

在 `docker-compose.yml` 中可以覆盖环境变量：

```yaml
services:
  web:
    environment:
      - APP_ENV=production
      - APP_DEBUG=false
      - DB_HOST=db
      
  python-backend:
    environment:
      - APP_ENV=production
      - DEBUG=False
```

---

## 🔧 故障排查

### Laravel 应用问题

#### 1. "Permission denied" 错误

```bash
# 设置正确的权限
chmod -R 775 storage bootstrap/cache
chown -R www-data:www-data storage bootstrap/cache
```

#### 2. "Class not found" 错误

```bash
# 清除并重新生成 autoload
composer dump-autoload
php artisan config:clear
php artisan cache:clear
```

#### 3. 数据库连接失败

- 检查 `.env` 中的数据库配置
- 确认数据库服务正在运行
- 验证用户名和密码
- 测试连接：
  ```bash
  php artisan tinker
  >>> DB::connection()->getPdo();
  ```

### Docker 部署问题

#### 1. 容器无法启动

```bash
# 查看详细日志
docker compose logs

# 检查容器状态
docker compose ps

# 重新构建镜像
docker compose build --no-cache
```

#### 2. 端口冲突

```bash
# 查看端口占用
sudo netstat -tulpn | grep :8000

# 修改 docker-compose.yml 中的端口映射
ports:
  - "8001:8000"  # 使用不同的主机端口
```

#### 3. 数据持久化问题

```bash
# 查看卷
docker volume ls

# 备份数据
docker compose exec db mysqldump -u root -p magicai > backup.sql

# 恢复数据
docker compose exec -T db mysql -u root -p magicai < backup.sql
```

### GitHub Actions 问题

#### 1. 工作流权限错误

**解决方案**:
1. 进入 **Settings** → **Actions** → **General**
2. 设置 **Workflow permissions** 为 "Read and write permissions"

#### 2. 构建超时

**解决方案**:
- 使用 Docker 层缓存
- 减少构建步骤
- 增加 `timeout-minutes`

#### 3. 部署失败

**检查清单**:
- ✅ 环境变量是否正确设置
- ✅ Secrets 是否配置
- ✅ Docker 配置是否有效
- ✅ 查看详细的工作流日志

---

## 📚 相关文档

- [GitHub Pages 设置](GITHUB_PAGES_SETUP.md) - Pages 配置详细指南
- [工作流说明](../.github/workflows/README.md) - GitHub Actions 工作流文档
- [README.md](../README.md) - 项目主文档

## 🎯 最佳实践

### 开发环境

1. **使用 Docker 进行一致的开发环境**
   ```bash
   docker compose -f docker-compose.local.yml up -d
   ```

2. **使用版本控制忽略敏感文件**
   - 确保 `.env` 在 `.gitignore` 中
   - 不要提交 API 密钥和密码

3. **定期更新依赖**
   ```bash
   composer update
   npm update
   pip install --upgrade -r requirements.txt
   ```

### 生产环境

1. **使用环境变量管理敏感信息**
   - 不要在代码中硬编码密钥
   - 使用 GitHub Secrets 进行 CI/CD

2. **启用缓存和优化**
   ```bash
   php artisan config:cache
   php artisan route:cache
   php artisan view:cache
   ```

3. **监控和日志**
   - 配置日志聚合
   - 设置性能监控
   - 启用错误跟踪

4. **备份策略**
   - 定期备份数据库
   - 备份上传的文件
   - 测试恢复流程

---

**需要帮助？**
- 查看 [GitHub Issues](https://github.com/v3ai2026/333/issues)
- 查看 [GitHub Actions 日志](https://github.com/v3ai2026/333/actions)
- 参考 [Laravel 文档](https://laravel.com/docs)
- 参考 [Docker 文档](https://docs.docker.com/)
