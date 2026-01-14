# GitHub Pages 设置指南

本指南将帮助您启用和配置 GitHub Pages，以便部署 MagicAI v9.9 项目的静态网站。

## 📋 前提条件

- 您必须是仓库的管理员或拥有者
- 仓库必须是公开的（或者使用 GitHub Pro/Enterprise）
- 已经有 `.github/workflows/pages.yml` 工作流文件

## 🚀 启用 GitHub Pages

### 步骤 1: 进入仓库设置

1. 打开您的 GitHub 仓库 `v3ai2026/333`
2. 点击顶部导航栏的 **Settings**（设置）选项卡
3. 在左侧边栏中找到 **Pages** 选项

### 步骤 2: 配置 Pages 源

在 Pages 设置页面中：

1. 找到 **Source**（源）部分
2. 从下拉菜单中选择 **GitHub Actions**
   
   ```
   Source: GitHub Actions
   ```

3. 保存设置（如果有保存按钮的话）

### 步骤 3: 验证设置

配置完成后，您应该看到：

- ✅ GitHub Pages 已启用
- ✅ 源设置为 GitHub Actions
- 📝 一个提示说明您的网站将从 GitHub Actions 工作流部署

## 🔄 工作流说明

### 自动部署触发

一旦 GitHub Pages 启用，`.github/workflows/pages.yml` 工作流将在以下情况下自动触发：

- 🔹 每次推送到 `main` 分支
- 🔹 手动触发（通过 Actions 界面）

### 工作流步骤

1. **检出代码**: 获取最新的代码
2. **配置 Pages**: 设置 GitHub Pages 环境
3. **构建静态站点**: 
   - 复制 `public` 目录内容到 `_site`
   - 创建 `.nojekyll` 文件（禁用 Jekyll 处理）
   - 如果没有 `index.html`，创建默认页面
4. **上传构建产物**: 将 `_site` 目录上传
5. **部署到 Pages**: 发布到 GitHub Pages

## 📍 访问您的网站

部署成功后，您的网站将在以下地址可用：

```
https://v3ai2026.github.io/333/
```

**注意**: 首次部署或更新后，可能需要几分钟才能在实际网站上看到更改。

## 🔧 故障排查

### 问题 1: "Get Pages site failed" 错误

**症状**: 工作流在 "📦 Setup Pages" 步骤失败，错误消息：
```
Get Pages site failed. Please verify that the repository has Pages enabled
```

**解决方案**:
1. 确认 GitHub Pages 已在仓库设置中启用
2. 确认源设置为 "GitHub Actions" 而不是分支
3. 等待几分钟，GitHub 可能需要时间来初始化 Pages 环境
4. 尝试手动重新运行工作流

### 问题 2: 工作流运行但网站显示 404

**可能原因**:
- 部署正在进行中，请等待几分钟
- `_site` 目录中缺少 `index.html`

**解决方案**:
1. 检查工作流日志，确认构建步骤成功
2. 验证 `public` 目录包含有效的 HTML 文件
3. 等待 5-10 分钟让 CDN 缓存更新

### 问题 3: 更改未显示在网站上

**可能原因**:
- CDN 缓存延迟
- 浏览器缓存

**解决方案**:
1. 清除浏览器缓存（Ctrl+Shift+R 或 Cmd+Shift+R）
2. 使用无痕模式访问网站
3. 等待 10-15 分钟让 GitHub Pages CDN 更新

### 问题 4: 权限错误

**症状**: 工作流失败，提示权限不足

**解决方案**:
1. 进入仓库 **Settings** → **Actions** → **General**
2. 向下滚动到 **Workflow permissions**
3. 确保选择 "Read and write permissions"
4. 保存更改并重新运行工作流

## 📚 更多资源

### 官方文档

- [GitHub Pages 文档](https://docs.github.com/en/pages)
- [使用 GitHub Actions 部署](https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site#publishing-with-a-custom-github-actions-workflow)
- [GitHub Actions 文档](https://docs.github.com/en/actions)

### 相关文件

- [工作流配置](.github/workflows/pages.yml) - Pages 部署工作流
- [部署指南](DEPLOYMENT_GUIDE.md) - 完整部署文档
- [工作流说明](.github/workflows/README.md) - 所有工作流的说明

## 💡 提示

1. **首次设置**: 首次启用 Pages 后，运行一次工作流可能会失败。稍等几分钟后重新运行即可。

2. **自定义域名**: 如果您想使用自定义域名，可以在 Pages 设置中配置 CNAME。

3. **HTTPS**: GitHub Pages 自动为您的网站启用 HTTPS。

4. **构建时间**: 通常部署需要 30 秒到 2 分钟。大型站点可能需要更长时间。

## 🎉 完成！

完成以上步骤后，您的 MagicAI v9.9 静态网站应该已经在 GitHub Pages 上运行了。每次推送到 `main` 分支时，网站都会自动更新。

---

**需要帮助？** 
- 查看 [GitHub Actions 运行日志](../../actions) 了解详细信息
- 参考 [故障排查](#故障排查) 部分
- 查看 [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) 了解更多部署选项
