# GitHub Pages 部署文档

## 🌐 访问地址

您的 MagicAI v9.9 网站已成功部署到 GitHub Pages：

**🔗 https://v3ai2026.github.io/333/**

---

## 📋 部署说明

### 自动部署

本仓库配置了自动 GitHub Pages 部署。每次推送到 `main` 分支时，GitHub Actions 会自动：

1. ✅ 构建静态网站
2. ✅ 部署到 GitHub Pages
3. ✅ 更新线上内容

### 部署 Workflow

部署流程由 `.github/workflows/pages.yml` 控制，包含以下步骤：

```yaml
- 检出代码
- 配置 GitHub Pages
- 构建静态站点（从 public/ 目录）
- 上传构建产物
- 部署到 GitHub Pages
```

---

## 🎨 静态页面说明

GitHub Pages 部署的是位于 `public/index.html` 的静态欢迎页面，展示：

- ✨ MagicAI v9.9 系统介绍
- 🚀 部署方式（Docker、本地开发、生产环境）
- 🔗 相关文档链接
- 📦 功能特性展示

**重要提示：** 由于 MagicAI 是基于 PHP Laravel 的完整应用，GitHub Pages 只能展示静态信息页面。要运行完整功能，请按照下方部署说明进行本地或服务器部署。

---

## 🚀 完整应用部署

要运行完整的 MagicAI 应用（而非静态展示页面），请使用以下方式之一：

### 方式 1: Docker 快速部署（推荐）

```bash
# 克隆仓库
git clone https://github.com/v3ai2026/333.git
cd 333

# 配置环境变量
cp .env.example .env

# 使用 Docker Compose 启动
docker-compose up -d

# 访问应用
# Web 应用: http://localhost:8000
# Python 后端: http://localhost:8080
```

### 方式 2: 本地开发部署

```bash
# 安装 PHP 依赖
composer install

# 安装前端依赖
npm install

# 配置环境
cp .env.example .env
php artisan key:generate

# 运行迁移
php artisan migrate

# 启动 Laravel 开发服务器
php artisan serve

# 启动 Python 后端（另一个终端）
cd backend-service
pip install -r requirements.txt
python app.py
```

### 方式 3: 生产环境部署

完整的生产环境部署指南，请参考：

- [DEPLOYMENT.md](./DEPLOYMENT.md) - 完整部署文档
- [DOCKER-COMPOSE-GUIDE.md](./DOCKER-COMPOSE-GUIDE.md) - Docker 配置指南
- [QUICKSTART.md](./QUICKSTART.md) - 快速开始指南

---

## 🔧 GitHub Pages 配置

### 仓库设置

确保在 GitHub 仓库设置中启用了 GitHub Pages：

1. 进入仓库 **Settings** → **Pages**
2. **Source** 设置为: `GitHub Actions`
3. 保存设置

### 自定义域名（可选）

如果要使用自定义域名：

1. 在仓库 Settings → Pages 中添加自定义域名
2. 在 DNS 提供商处添加 CNAME 记录指向 `v3ai2026.github.io`
3. 在 `public/` 目录创建 `CNAME` 文件，内容为您的域名

```bash
echo "your-domain.com" > public/CNAME
```

---

## 📊 部署状态检查

### 查看部署状态

访问 [Actions 页面](https://github.com/v3ai2026/333/actions) 查看部署历史和状态。

### 部署失败排查

如果部署失败，请检查：

1. ✅ `public/index.html` 文件是否存在
2. ✅ `.github/workflows/pages.yml` 配置是否正确
3. ✅ GitHub Pages 是否在仓库设置中启用
4. ✅ 仓库是否有 `pages: write` 权限

### 手动触发部署

可以在 Actions 页面手动触发部署：

1. 访问 [Actions](https://github.com/v3ai2026/333/actions)
2. 选择 "Deploy to GitHub Pages" workflow
3. 点击 "Run workflow" 按钮

---

## 📁 文件结构

```
333/
├── public/                    # GitHub Pages 静态文件
│   └── index.html            # 主页面
├── .github/
│   └── workflows/
│       ├── deploy.yml        # 主 CI/CD workflow
│       └── pages.yml         # GitHub Pages 部署 workflow
├── GITHUB_PAGES_DEPLOY.md   # 本文档
├── DEPLOYMENT.md             # 完整部署文档
└── ...
```

---

## 🔗 相关链接

- 🌐 **GitHub Pages 网站**: https://v3ai2026.github.io/333/
- 📂 **GitHub 仓库**: https://github.com/v3ai2026/333
- 📖 **项目文档**: https://github.com/v3ai2026/333/blob/main/README.md
- 🚀 **Actions 面板**: https://github.com/v3ai2026/333/actions
- 💬 **问题反馈**: https://github.com/v3ai2026/333/issues

---

## ⚙️ 技术栈

### GitHub Pages 静态网站
- HTML5 + CSS3 + JavaScript
- 响应式设计
- 无需服务器运行

### 完整应用技术栈
- **后端**: PHP Laravel 框架
- **Python 服务**: Flask/FastAPI
- **数据库**: MySQL 8.0
- **缓存**: Redis 7
- **容器化**: Docker + Docker Compose
- **AI 集成**: Google Vertex AI

---

## 📝 更新内容

要更新 GitHub Pages 网站内容：

1. 编辑 `public/index.html` 文件
2. 提交并推送到 `main` 分支
3. GitHub Actions 会自动重新部署
4. 等待 1-2 分钟后刷新页面查看更新

```bash
git add public/index.html
git commit -m "Update GitHub Pages content"
git push origin main
```

---

## ❓ 常见问题

### Q: 为什么访问网站只看到静态页面？
A: GitHub Pages 只能托管静态文件（HTML/CSS/JS），不支持运行 PHP 或数据库。要运行完整的 MagicAI 应用，请使用 Docker 在本地或服务器上部署。

### Q: 如何更新页面内容？
A: 编辑 `public/index.html`，然后推送到 main 分支，GitHub Actions 会自动部署。

### Q: 部署需要多长时间？
A: 通常 1-3 分钟。可以在 Actions 页面查看部署进度。

### Q: 可以部署完整的 Laravel 应用吗？
A: 不能。GitHub Pages 只支持静态文件。Laravel 应用需要 PHP 运行时、数据库等，必须部署到支持 PHP 的服务器上。

---

## 📞 获取帮助

如有问题或需要帮助：

1. 查看 [部署文档](./DEPLOYMENT.md)
2. 查看 [GitHub Issues](https://github.com/v3ai2026/333/issues)
3. 创建新的 Issue 描述您的问题

---

**最后更新**: 2024-01-11  
**版本**: MagicAI v9.9  
**维护者**: v3ai2026
