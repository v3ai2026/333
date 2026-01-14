# GitHub Actions 工作流说明

本目录包含 MagicAI v9.9 项目的 GitHub Actions 自动化工作流。

## 📑 目录

- [工作流概览](#工作流概览)
- [pages.yml - GitHub Pages 部署](#pagesyml---github-pages-部署)
- [deploy.yml - Docker CI/CD Pipeline](#deployyml---docker-cicd-pipeline)
- [使用指南](#使用指南)
- [故障排查](#故障排查)

---

## 🔄 工作流概览

| 工作流 | 文件 | 触发分支 | 用途 | 状态 |
|--------|------|----------|------|------|
| GitHub Pages | `pages.yml` | `main` | 部署静态网站到 GitHub Pages | [![pages](https://github.com/v3ai2026/333/actions/workflows/pages.yml/badge.svg)](https://github.com/v3ai2026/333/actions/workflows/pages.yml) |
| CI/CD Pipeline | `deploy.yml` | `develop`, `staging` | Docker 容器化应用部署 | [![deploy](https://github.com/v3ai2026/333/actions/workflows/deploy.yml/badge.svg)](https://github.com/v3ai2026/333/actions/workflows/deploy.yml) |

---

## 📄 pages.yml - GitHub Pages 部署

### 用途

将项目的静态内容部署到 GitHub Pages，提供公开访问的演示网站。

### 触发条件

- ✅ **自动触发**: 推送到 `main` 分支
- ✅ **手动触发**: 通过 Actions 界面手动运行

```yaml
on:
  push:
    branches:
      - main
  workflow_dispatch:
```

### 工作流步骤

1. **📥 检出代码**
   - 使用 `actions/checkout@v4` 获取最新代码

2. **📦 配置 Pages**
   - 使用 `actions/configure-pages@v4` 设置 Pages 环境
   - **重要**: 需要在仓库设置中启用 GitHub Pages

3. **🔨 构建静态站点**
   - 创建 `_site` 目录
   - 复制 `public/` 目录内容（如果存在）
   - 创建 `.nojekyll` 文件（禁用 Jekyll 处理）
   - 如果缺少 `index.html`，创建默认页面

4. **📤 上传构建产物**
   - 使用 `actions/upload-pages-artifact@v3` 上传 `_site` 目录

5. **🚀 部署到 Pages**
   - 使用 `actions/deploy-pages@v4` 发布到 GitHub Pages

6. **✅ 完成通知**
   - 显示网站 URL 和部署信息

### 必需的权限

```yaml
permissions:
  contents: read      # 读取仓库内容
  pages: write        # 写入 Pages
  id-token: write     # 用于认证
```

### 部署地址

- **网站 URL**: https://v3ai2026.github.io/333/

### 设置说明

在使用此工作流之前，**必须**先启用 GitHub Pages：

1. 进入仓库 **Settings** → **Pages**
2. 在 **Source** 下选择 **GitHub Actions**
3. 保存设置

详细设置步骤请参考: [GITHUB_PAGES_SETUP.md](../../docs/GITHUB_PAGES_SETUP.md)

### 常见错误

#### ❌ "Get Pages site failed"

**错误消息**: 
```
Get Pages site failed. Please verify that the repository has Pages enabled
```

**原因**: GitHub Pages 未在仓库设置中启用

**解决方案**: 
1. 按照上述设置说明启用 Pages
2. 等待几分钟让 GitHub 初始化 Pages 环境
3. 重新运行工作流

---

## 🐋 deploy.yml - Docker CI/CD Pipeline

### 用途

完整的 CI/CD 流程，用于构建、测试和部署 Docker 容器化的应用。

### 触发条件

- ✅ **自动触发**: 推送到 `develop` 或 `staging` 分支
- ✅ **手动触发**: 通过 Actions 界面手动运行

```yaml
on:
  push:
    branches:
      - develop
      - staging
  workflow_dispatch:
```

### 工作流阶段

#### 阶段 1: 代码检查 (check)

**目的**: 验证代码质量和配置有效性

**步骤**:
1. **Python 语法检查**
   - 使用 flake8 检查 `backend-service/app.py`
   - 检查严重语法错误 (E9, F63, F7, F82)
   - 检查代码复杂度和行长度

2. **依赖验证**
   - 验证 `requirements.txt` 中的 Python 依赖
   - 使用 `pip check` 确保依赖兼容性

3. **Docker 配置验证**
   - 验证 `docker-compose.yml` 语法
   - 使用 Hadolint 检查 `backend-service/Dockerfile`

#### 阶段 2: 构建镜像 (build)

**目的**: 构建 Docker 镜像并优化缓存

**步骤**:
1. **设置 Docker Buildx**
   - 支持多平台构建
   - 启用高级构建特性

2. **配置 Docker 缓存**
   - 使用 GitHub Actions 缓存
   - 大幅减少构建时间

3. **构建 Backend Service 镜像**
   ```bash
   cd backend-service
   docker build -t magicai-backend:latest .
   ```

4. **构建 Web Application 镜像**（可选）
   ```bash
   cd Magicai-Server-Files
   docker build -t magicai-web:latest .
   ```

5. **保存构建日志**
   - 上传为构建产物
   - 保留 7 天

#### 阶段 3: 部署服务 (deploy)

**目的**: 部署 Docker 容器并运行初始化任务

**步骤**:
1. **创建环境配置**
   - 从 `.env.example` 创建 `.env`
   - 生成 Laravel APP_KEY
   - 创建 backend-service 配置

2. **停止现有容器**
   ```bash
   docker compose down --remove-orphans
   ```

3. **启动新容器**
   ```bash
   docker compose up -d
   ```

4. **等待数据库就绪**
   - 最多等待 30 秒
   - 使用 `mysqladmin ping` 检查

5. **运行数据库迁移**
   ```bash
   docker compose exec -T web php artisan migrate --force
   ```

6. **清除应用缓存**
   ```bash
   docker compose exec -T web php artisan cache:clear
   docker compose exec -T web php artisan config:cache
   ```

#### 阶段 4: 验证部署 (verify)

**目的**: 确保所有服务正常运行

**检查项**:
1. **容器状态检查**
   - 验证所有容器都在运行
   - 显示容器列表

2. **Web 应用健康检查**
   - 测试 `http://localhost:8000`
   - 最多尝试 10 次，每次间隔 3 秒
   - 显示响应内容（前 20 行）

3. **Python Backend 健康检查**
   - 测试 `http://localhost:8080/health`
   - 验证健康端点响应
   - 解析 JSON 响应

4. **数据库连接测试**
   - 使用 `mysqladmin ping` 测试连接
   - 尝试执行简单查询

5. **Redis 连接测试**
   - 使用 `redis-cli ping` 测试连接

6. **服务日志收集**
   - 收集所有服务的最后 50 行日志
   - 便于故障排查

#### 阶段 5: 部署通知 (notify)

**目的**: 提供部署结果摘要

**输出信息**:
- 各阶段状态（成功/失败）
- 服务访问 URL
- 常用命令提示
- 故障排查建议（如果失败）

#### 阶段 6: 失败回滚 (rollback)

**触发条件**: deploy 或 verify 阶段失败时

**操作**:
- 停止所有容器
- 清理失败的部署
- 提示需要手动干预

### 环境和权限

```yaml
env:
  DOCKER_BUILDKIT: 1           # 启用 Docker BuildKit
  COMPOSE_DOCKER_CLI_BUILD: 1  # 使用 Docker Compose CLI

permissions:
  contents: read               # 读取仓库内容
```

### 服务端口

部署后的服务端口映射：

| 服务 | 端口 | 说明 |
|------|------|------|
| Web Application | 8000 | Laravel 主应用 |
| Backend API | 8080 | Python FastAPI 服务 |
| MySQL | 3306 | 数据库 |
| Redis | 6379 | 缓存和队列 |

### 访问部署的应用

```bash
# Web 应用
curl http://localhost:8000

# API 文档
curl http://localhost:8000/api/documentation

# Backend 状态
curl http://localhost:8080/status

# Backend 健康检查
curl http://localhost:8080/health
```

### Docker Compose 管理命令

```bash
# 查看容器状态
docker compose ps

# 查看日志
docker compose logs -f

# 查看特定服务日志
docker compose logs -f web
docker compose logs -f python-backend

# 重启服务
docker compose restart

# 停止服务
docker compose down

# 完全清理
docker compose down -v --remove-orphans
```

---

## 📖 使用指南

### 手动触发工作流

1. 进入仓库的 **Actions** 标签
2. 选择要运行的工作流：
   - **Deploy to GitHub Pages** (pages.yml)
   - **MagicAI v9.9 CI/CD Pipeline** (deploy.yml)
3. 点击 **Run workflow** 按钮
4. 选择要运行的分支
5. 点击绿色的 **Run workflow** 按钮确认

### 查看工作流运行

1. 进入 **Actions** 标签
2. 点击工作流运行记录
3. 查看各个步骤的详细日志
4. 下载构建产物（如果有）

### 调试工作流

如果工作流失败：

1. **查看详细日志**
   - 点击失败的步骤查看完整日志
   - 注意红色的错误消息

2. **检查常见问题**
   - 权限配置
   - 环境变量
   - Docker 配置
   - 依赖版本

3. **本地复现**
   ```bash
   # 本地运行相同的命令
   docker compose build
   docker compose up -d
   ```

---

## 🔧 故障排查

### Pages 工作流问题

#### 问题 1: Pages 未启用

**错误**: `Get Pages site failed`

**解决方案**: 
1. 参考 [GITHUB_PAGES_SETUP.md](../../docs/GITHUB_PAGES_SETUP.md)
2. 在仓库设置中启用 GitHub Pages
3. 选择 "GitHub Actions" 作为源

#### 问题 2: 构建成功但网站无法访问

**可能原因**:
- CDN 缓存延迟（等待 5-10 分钟）
- `_site` 目录缺少 `index.html`

**解决方案**:
1. 检查工作流日志中的构建步骤
2. 确认 `public` 目录包含有效内容
3. 清除浏览器缓存并重新访问

### Deploy 工作流问题

#### 问题 1: Docker 构建失败

**常见原因**:
- Dockerfile 语法错误
- 依赖下载失败
- 基础镜像不可用

**解决方案**:
1. 本地测试构建：`docker build -t test .`
2. 检查 Dockerfile 语法
3. 验证依赖版本

#### 问题 2: 数据库迁移失败

**常见原因**:
- 数据库未就绪
- 连接配置错误
- 迁移文件问题

**解决方案**:
1. 检查数据库容器状态
2. 验证 `.env` 配置
3. 手动运行迁移：
   ```bash
   docker compose exec web php artisan migrate
   ```

#### 问题 3: 容器无法启动

**排查步骤**:
1. 检查端口是否被占用
2. 查看容器日志：`docker compose logs`
3. 验证 docker-compose.yml 配置
4. 检查资源限制（内存、CPU）

### 权限问题

如果遇到权限错误：

1. **检查工作流权限**
   - Settings → Actions → General
   - Workflow permissions: "Read and write permissions"

2. **检查 Secrets**
   - Settings → Secrets and variables → Actions
   - 确保所有必需的 secrets 已配置

---

## 📚 相关文档

- [GitHub Pages 设置指南](../../docs/GITHUB_PAGES_SETUP.md)
- [完整部署指南](../../docs/DEPLOYMENT_GUIDE.md)
- [项目 README](../../README.md)

## 🌟 最佳实践

1. **分支策略**
   - `main`: 用于生产环境和 Pages 部署
   - `develop`: 用于开发环境测试
   - `staging`: 用于预发布测试

2. **提交消息**
   - 使用清晰的提交消息
   - 说明更改的内容和原因

3. **环境隔离**
   - 不同分支使用不同的环境配置
   - 使用 GitHub Secrets 管理敏感信息

4. **监控和通知**
   - 关注工作流失败通知
   - 定期检查 Actions 运行历史

5. **资源优化**
   - 使用 Docker 缓存减少构建时间
   - 清理旧的工作流运行记录

---

**更新时间**: 2026-01-14  
**维护者**: MagicAI Team

需要帮助？查看 [GitHub Actions 文档](https://docs.github.com/en/actions) 或 [提交 Issue](https://github.com/v3ai2026/333/issues)
