# 🚀 Vercel 部署指南 - MagicAI v9.9

## 前置条件

✅ 已有 Vercel 账户（[vercel.com](https://vercel.com)）  
✅ GitHub/GitLab 仓库已配置  
✅ 已生成 Laravel `APP_KEY`  
✅ 有可用的数据库（MySQL/MariaDB）和 Redis 实例  

---

## 📋 第一步：准备 Vercel 环境变量

### 1. 在 Vercel 控制面板中设置

打开 Vercel 项目 → Settings → Environment Variables，添加以下变量：

| 变量名 | 值 | 说明 |
|--------|------|------|
| `APP_KEY` | `base64:xxx...` | 运行 `php artisan key:generate --show` 获取 |
| `APP_URL` | `https://modamoda.shop` | 您的生产域名 |
| `SESSION_DOMAIN` | `.modamoda.shop` | 设置域名 cookie |
| `SANCTUM_STATEFUL_DOMAINS` | `modamoda.shop` | CSRF 保护 |
| `DB_CONNECTION` | `mysql` | 数据库类型 |
| `DB_HOST` | 您的 MySQL 主机 | 例：`db.example.com` |
| `DB_PORT` | `3306` | MySQL 端口 |
| `DB_DATABASE` | `magicai` | 数据库名 |
| `DB_USERNAME` | `magicai_user` | 数据库用户 |
| `DB_PASSWORD` | `your-secure-password` | **安全密码** ⚠️ |
| `REDIS_HOST` | Redis 主机 | 可选（缓存/队列） |
| `REDIS_PORT` | `6379` | Redis 端口 |
| `MAIL_DRIVER` | `smtp` | 邮件驱动 |
| `MAIL_HOST` | SMTP 主机 | 例：`smtp.gmail.com` |
| `MAIL_PORT` | `587` | SMTP 端口 |
| `MAIL_USERNAME` | 您的邮箱 | 例：`noreply@modamoda.shop` |
| `MAIL_PASSWORD` | 邮箱密码/令牌 | **安全存储** ⚠️ |

---

## 📝 第二步：Vercel 配置文件

### 根目录 `vercel.json` 已配置

- ✅ PHP 8.2 运行时
- ✅ Node.js 构建（Vite 编译）
- ✅ 自动路由到 Laravel public/index.php
- ✅ 生产优化（Composer --no-dev）

**无需额外修改。**

---

## 🔗 第三步：连接 Git 和部署

### 方式 A：Vercel Web 控制面板（推荐）

```bash
1. 登录 Vercel.com
2. 点击 "Add New..." → "Project"
3. 选择您的 GitHub/GitLab 仓库
4. 框架预设：选择 "Laravel"（或手动选择 "Other"）
5. Root Directory：留空（自动检测）
6. Build Command：`cd server && composer install && npm install && npm run build`
7. Output Directory：`server/public`
8. 输入所有环境变量（见第一步）
9. 点击 "Deploy"
```

### 方式 B：Vercel CLI（自动化）

```bash
# 安装 Vercel CLI
npm install -g vercel

# 在项目根目录运行
vercel --prod

# 首次运行会提示：
# - 关联 Vercel 项目
# - 覆盖 vercel.json 配置（选择 "No"）
# - 输入环境变量

# 部署完成后，访问 Vercel 给出的 URL
```

---

## ✅ 第四步：数据库初始化

部署后，需要初始化数据库：

### 方式 A：远程执行 larvae 命令

```bash
# 使用 Vercel 的 CLI 运行远程命令（需权限）
vercel env pull  # 拉取环境变量到本地 .env
php artisan migrate --force  # 或导入 magicai.sql

# 或者 SSH 到 Vercel 后端服务器（如果支持）
```

### 方式 B：本地运行，连接远程数据库

```bash
# 在您的本地机器上
1. 编辑 .env，设置远程数据库凭证
2. 确保远程 MySQL 允许您的 IP 访问

php artisan migrate --force
# 或
mysql -h <DB_HOST> -u <DB_USERNAME> -p < magicai.sql
```

### 方式 C：通过 Laravel Tinker（推荐）

```bash
# 使用 Vercel 的临时执行环境
vercel env pull
php artisan tinker

>>> Artisan::call('migrate', ['--force' => true]);
>>> // 数据库初始化完成
>>> exit
```

---

## 🔐 第五步：配置域名 DNS

### 将 `mdio.shop` 指向 Vercel

1. 在您的域名注册商（GoDaddy、Namecheap 等）中：
2. 添加 CNAME 记录：

   ```
   主机名：@（或 mdio.shop）
   类型：CNAME
   值：cname.vercel-dns.com
   ```

3. 添加 A 记录（备用）：

   ```
   主机名：@
   类型：A
   值：76.76.19.132
   ```

4. 在 Vercel 项目中验证域名：
   - Settings → Domains
   - 添加 `mdio.shop`
   - 等待 DNS 传播（最长 48 小时）

---

## 🧪 第六步：验证部署

### 检查清单

```bash
# 1. 访问网站
curl -I https://mdio.shop
# 预期：HTTP 200 或 302（重定向）

# 2. 检查 API 健康
curl https://mdio.shop/api/health
# 预期：JSON 响应

# 3. 查看 Vercel 日志
vercel logs <project-url> --prod

# 4. 测试数据库连接
# 访问登录页面，尝试用默认账号登录
# 用户名：daka@modamoda.shop
# 密码：daka123456
```

---

## 🚨 故障排除

### ❌ 构建失败 - "npm install 超时"

**解决方案**：

```json
// vercel.json 中增加
"buildCommand": "cd server && npm install --prefer-offline && composer install --optimize-autoloader --no-dev && npm run build"
```

### ❌ 502 Bad Gateway

**排查**：

1. 检查 Vercel 日志：`vercel logs <url> --prod`
2. 确认 APP_KEY 已设置：`echo $APP_KEY`
3. 检查数据库连接：日志中会显示 "Connection refused"

### ❌ 数据库连接失败

**解决方案**：

```bash
# 确认您的 MySQL 允许 Vercel IP 访问
# Vercel IP 范围：查看 https://vercel.com/docs/concepts/edge-network/regions

# 或使用 SSH 隧道（推荐）：
ssh -R 3306:localhost:3306 user@your-server.com
```

### ❌ 静态资源 404（CSS/JS 不加载）

**解决方案**：

```bash
cd server && npm run build
php artisan storage:link
```

---

## 📊 环境对比

| 特性 | 开发 | Vercel 生产 |
|------|------|-----------|
| URL | `localhost:8000` | `https://mdio.shop` |
| 数据库 | 本地 MySQL | 远程 MySQL |
| 文件存储 | 本地 `/storage` | ⚠️ Vercel 临时（需配置 S3） |
| 日志 | `storage/logs/laravel.log` | Vercel 控制面板 |
| 缓存驱动 | `file` | Redis（推荐） |
| 队列驱动 | `sync` | Redis（推荐） |

---

## 📌 重要提示

⚠️ **Vercel 无状态特性**：

- 每次部署后，`/storage` 文件会清除
- **解决方案**：使用 AWS S3、阿里云 OSS 等云存储

⚠️ **Vercel 最大执行时间**：

- 最长 900 秒（15 分钟）
- 长时间任务（爬虫、大型报表）需用 Background Jobs

⚠️ **冷启动**：

- 首次请求会较慢（PHP 初始化）
- 使用 Vercel Pro 减少冷启动

---

## 🎉 部署完成

部署成功后：

1. ✅ 访问 `https://mdio.shop` 查看网站
2. ✅ 使用默认账号登录测试功能
3. ✅ 配置 S3 存储（文件上传功能）
4. ✅ 设置邮件服务（密码重置、通知）
5. ✅ 监控 Vercel 仪表板（性能、错误）

---

## 🤖 第七步：配置自动部署（GitHub Actions）

### 前置条件

1. 代码已提交到 GitHub：`v3ai2026/magicai`
2. 在 Vercel 获取三个密钥：
   - `VERCEL_TOKEN`：Vercel 账户 → Settings → Tokens
   - `VERCEL_ORG_ID`：Vercel 组织 ID（查看 vercel.json）
   - `VERCEL_PROJECT_ID`：Vercel 项目 ID（查看 .vercel/project.json）

### 设置 GitHub Secrets

```bash
# 在 GitHub 仓库中：
# 1. Settings → Secrets and variables → Actions
# 2. 添加三个 secrets：
#    - VERCEL_TOKEN=<从 Vercel 复制>
#    - VERCEL_ORG_ID=<从 Vercel 复制>
#    - VERCEL_PROJECT_ID=<从 Vercel 复制>
```

### 自动部署规则

| 分支 | 事件 | 目标环境 |
|------|------|---------|
| `main` | push | 生产环境（自动部署） |
| `develop` | push | 预览环境 |
| PR | pull_request | 预览环境 + PR 评论 |

### 工作流文件

自动部署工作流已配置在 `.github/workflows/vercel-deploy.yml`：

- 📌 **生产部署**：推送到 `main` 分支自动部署到生产环境
- 🔄 **预览部署**：PR 或其他分支自动创建预览环境
- 💬 **PR 评论**：自动在 PR 中评论预览 URL

### 监控部署

```bash
# 查看部署历史
# GitHub: Actions 标签 → Workflow runs

# 查看 Vercel 日志
vercel logs <project-url> --prod

# 手动触发部署（如需要）
git push origin main
```

---

## 📞 需要帮助？

- Vercel 文档：<https://vercel.com/docs/frameworks/laravel>
- GitHub Actions：<https://docs.github.com/actions>
- Laravel 文档：<https://laravel.com/docs/10.x>
- 项目文档：查看 `DEPLOY.md`、`README.md`
