# MagicAI

[![GitHub Pages](https://github.com/v3ai2026/333/actions/workflows/pages.yml/badge.svg)](https://github.com/v3ai2026/333/actions/workflows/pages.yml)
[![CI/CD Pipeline](https://github.com/v3ai2026/333/actions/workflows/deploy.yml/badge.svg)](https://github.com/v3ai2026/333/actions/workflows/deploy.yml)

An advanced AI-powered application built with Laravel framework.

## 🚀 部署状态

- **GitHub Pages**: [https://v3ai2026.github.io/333/](https://v3ai2026.github.io/333/) - 静态网站演示
- **CI/CD**: 自动化构建和部署流程

### 重要提示

如果 GitHub Pages 工作流失败，请确保已在仓库设置中启用 GitHub Pages：
1. 进入 **Settings** → **Pages**
2. 在 **Source** 下选择 **GitHub Actions**
3. 查看详细设置指南：[docs/GITHUB_PAGES_SETUP.md](docs/GITHUB_PAGES_SETUP.md)

## 📁 Project Structure

```
├── app/                    # Application source code
│   ├── Actions/           # Action classes
│   ├── Console/           # Console commands
│   ├── Events/            # Event classes
│   ├── Exceptions/        # Custom exceptions
│   ├── Helpers/           # Helper functions and classes
│   ├── Http/              # HTTP layer (Controllers, Middleware, Requests)
│   ├── Providers/         # Service providers
│   ├── Services/          # Business logic services
│   └── View/              # View components
├── config/                # Configuration files
├── docs/                  # Documentation files
├── public/                # Public assets
├── routes/                # Route definitions
├── scripts/               # Deployment and utility scripts
├── storage/               # Application storage
└── tests/                 # Test files
```

## 📚 Documentation

All documentation has been organized in the `docs/` directory:

- **部署与配置**
  - [GITHUB_PAGES_SETUP.md](docs/GITHUB_PAGES_SETUP.md) - GitHub Pages 设置指南 ⭐
  - [DEPLOYMENT_GUIDE.md](docs/DEPLOYMENT_GUIDE.md) - 完整部署指南 ⭐
  - [DEPLOYMENT.md](docs/DEPLOYMENT.md) - Deployment guide
  - [DOCKER-COMPOSE-GUIDE.md](docs/DOCKER-COMPOSE-GUIDE.md) - Docker setup
  - [VERCEL_DEPLOY.md](docs/VERCEL_DEPLOY.md) - Vercel deployment

- **Quick Start Guides**
  - [QUICK_START.md](docs/QUICK_START.md) - Quick start guide
  - [QUICKSTART.md](docs/QUICKSTART.md) - Alternative quick start
  - [QUICKSTART-AUTOMATED.md](docs/QUICKSTART-AUTOMATED.md) - Automated setup guide
  - [START-HERE.txt](docs/START-HERE.txt) - Getting started instructions

- **Architecture & Integration**
  - [ARCHITECTURE.md](docs/ARCHITECTURE.md) - System architecture
  - [BACKEND_ARCHITECTURE.md](docs/BACKEND_ARCHITECTURE.md) - Backend details
  - [INTEGRATION_GUIDE.md](docs/INTEGRATION_GUIDE.md) - Integration documentation
  - [API_DOCUMENTATION.md](docs/API_DOCUMENTATION.md) - API reference

- **Features & Tools**
  - [COMPLETE_FEATURES.md](docs/COMPLETE_FEATURES.md) - Feature list
  - [AI_TOOLS_INTEGRATION.md](docs/AI_TOOLS_INTEGRATION.md) - AI tools
  - [BRAIN_ENGINE_INTEGRATION.md](docs/BRAIN_ENGINE_INTEGRATION.md) - Brain engine

- **GitHub Actions**
  - [.github/workflows/README.md](.github/workflows/README.md) - 工作流详细说明 ⭐

See the [docs/](docs/) directory for complete documentation.

## 🚀 Quick Start

1. **Install Dependencies**
   ```bash
   composer install
   npm install
   ```

2. **Environment Setup**
   ```bash
   cp .env.example .env
   php artisan key:generate
   ```

3. **Database Setup**
   ```bash
   php artisan migrate
   ```

4. **Run Development Server**
   ```bash
   php artisan serve
   ```

## 🛠 Utility Scripts

Deployment and utility scripts are located in the `scripts/` directory:

- `deploy.sh` / `deploy.bat` - Deployment scripts
- `startup.sh` / `startup.bat` - Application startup
- `verify-bots.sh` / `verify-bots.bat` - Bot verification
- `monitor-bots.sh` - Bot monitoring

## 📝 License

See [LICENSE](LICENSE) file for details.

## 🔒 Security

<!-- Security scan triggered at 2025-09-01 20:14:35 -->
<!-- Security scan triggered at 2025-09-09 05:52:47 -->
<!-- Security scan triggered at 2025-09-28 16:02:18 -->