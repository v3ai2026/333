# 📘 GitHub Pages Setup Guide

Complete step-by-step guide to enable and configure GitHub Pages for the MagicAI v9.9 project.

---

## 🎯 Overview

GitHub Pages allows you to host static websites directly from your GitHub repository. This guide will help you:

1. ✅ Enable GitHub Pages in your repository
2. ✅ Configure GitHub Actions as the deployment source
3. ✅ Troubleshoot common deployment issues
4. ✅ Understand the automated deployment process

---

## 📋 Prerequisites

- Admin access to the repository `v3ai2026/333`
- Basic understanding of Git and GitHub
- The `.github/workflows/pages.yml` workflow file (already in the repository)

---

## 🚀 Step-by-Step Setup

### Step 1: Enable GitHub Pages

1. **Navigate to Repository Settings**
   - Go to https://github.com/v3ai2026/333
   - Click on **Settings** tab (top navigation bar)
   - You need admin access to see this tab

2. **Access Pages Settings**
   - In the left sidebar, scroll down to find **Pages** under "Code and automation"
   - Click on **Pages**

3. **Configure Build and Deployment Source**
   - Under "Build and deployment" section
   - Find the **Source** dropdown menu
   - Select **GitHub Actions** (NOT "Deploy from a branch")
   
   ```
   Build and deployment
   Source: [GitHub Actions ▼]
   ```

4. **Save Changes**
   - The settings will be saved automatically
   - You should see a message: "GitHub Pages source saved"

### Step 2: Verify Workflow Permissions

1. **Check Actions Permissions**
   - Go to **Settings** → **Actions** → **General**
   - Scroll down to "Workflow permissions"
   - Ensure **Read and write permissions** is selected
   - Check **Allow GitHub Actions to create and approve pull requests** (optional but recommended)
   - Click **Save** if you made changes

### Step 3: Trigger the Deployment

After enabling Pages, the deployment workflow will automatically run when:

- You push to the `main` branch
- You manually trigger it from Actions tab

**To manually trigger:**

1. Go to **Actions** tab
2. Click on **Deploy to GitHub Pages** workflow
3. Click **Run workflow** button
4. Select `main` branch
5. Click **Run workflow**

### Step 4: Monitor Deployment

1. **Check Workflow Status**
   - Go to **Actions** tab
   - You should see the "Deploy to GitHub Pages" workflow running
   - Wait for it to complete (usually 1-2 minutes)

2. **Verify Success**
   - ✅ Green checkmark = successful deployment
   - ❌ Red X = failed deployment (see troubleshooting below)

3. **Access Your Site**
   - Once deployed, your site will be available at:
   - **https://v3ai2026.github.io/333/**
   - It may take 1-2 minutes for changes to appear

---

## 🖼️ Visual Reference

### Settings Location
```
Repository Home → Settings → Pages (left sidebar)
```

### Correct Configuration
```
┌─────────────────────────────────────────┐
│ GitHub Pages                            │
├─────────────────────────────────────────┤
│ Build and deployment                    │
│                                         │
│ Source                                  │
│ ┌─────────────────────────────────────┐ │
│ │ GitHub Actions              ▼       │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ Your site is live at                    │
│ https://v3ai2026.github.io/333/        │
└─────────────────────────────────────────┘
```

---

## 🔧 Troubleshooting

### Issue 1: "Get Pages site failed" Error

**Error Message:**
```
Get Pages site failed. Please verify that the repository has Pages enabled 
and configured to build using GitHub Actions
```

**Solution:**
- ✅ Follow Step 1 above to enable GitHub Pages
- ✅ Ensure you selected "GitHub Actions" as the source (NOT "Deploy from a branch")
- ✅ Wait 1-2 minutes after enabling and re-run the workflow

### Issue 2: Workflow Fails with Permission Error

**Error Message:**
```
Error: Resource not accessible by integration
```

**Solution:**
- Go to **Settings** → **Actions** → **General**
- Set "Workflow permissions" to **Read and write permissions**
- Re-run the failed workflow

### Issue 3: 404 Page Not Found

**Symptoms:**
- Workflow succeeds but site shows 404 error
- `https://v3ai2026.github.io/333/` returns "Page not found"

**Solution:**
- Check that `public/index.html` exists in the repository
- The workflow automatically creates a fallback page if missing
- Verify the workflow completed all steps successfully
- Wait 5-10 minutes for DNS propagation

### Issue 4: Changes Not Appearing on Site

**Symptoms:**
- Pushed changes but site still shows old content

**Solution:**
- Wait 1-2 minutes for deployment to complete
- Hard refresh your browser (Ctrl+F5 or Cmd+Shift+R)
- Check if the workflow run completed successfully
- Verify you pushed to the `main` branch (not another branch)

### Issue 5: Repository is Private

**Symptoms:**
- Can't access the Pages URL
- Gets authentication prompt

**Solution:**
- GitHub Pages for private repositories requires GitHub Pro/Team/Enterprise
- Either:
  - Upgrade to a paid plan, OR
  - Make the repository public (Settings → General → Danger Zone → Change visibility)

---

## 📚 Understanding the Deployment Process

### What Happens When You Push to `main`?

1. **Workflow Triggers**
   - `.github/workflows/pages.yml` detects push to main
   
2. **Checkout Code**
   - GitHub Actions checks out your repository

3. **Build Static Site**
   - Copies contents from `public/` directory
   - Creates fallback `index.html` if none exists
   - Adds `.nojekyll` file (disables Jekyll processing)

4. **Upload Artifact**
   - Packages the `_site` directory
   - Uploads as a GitHub Pages artifact

5. **Deploy**
   - GitHub Pages deploys the artifact
   - Site becomes live at `https://v3ai2026.github.io/333/`

### Workflow File Location
```
.github/workflows/pages.yml
```

### Key Workflow Features
- ✅ Automatic deployment on push to `main`
- ✅ Manual deployment via workflow dispatch
- ✅ Fallback page creation if no index.html
- ✅ Clear error messages and logs
- ✅ Deployment URL output

---

## 🔗 Important URLs

- **Live Site**: https://v3ai2026.github.io/333/
- **Repository**: https://github.com/v3ai2026/333
- **Actions**: https://github.com/v3ai2026/333/actions
- **Settings**: https://github.com/v3ai2026/333/settings/pages
- **Workflow File**: https://github.com/v3ai2026/333/blob/main/.github/workflows/pages.yml

---

## 📖 Additional Resources

### Official Documentation
- [GitHub Pages Official Docs](https://docs.github.com/en/pages)
- [GitHub Actions for Pages](https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site#publishing-with-a-custom-github-actions-workflow)
- [Configuring Pages](https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site)

### Related Project Documentation
- [Deployment Guide](./DEPLOYMENT_GUIDE.md) - All deployment options
- [Workflow Documentation](../.github/workflows/README.md) - Understanding workflows
- [Main README](../README.md) - Project overview

---

## ❓ FAQ

### Q: Can I use a custom domain?

**A:** Yes! After enabling Pages:
1. Add your domain in Settings → Pages → Custom domain
2. Configure DNS with your domain provider:
   - For apex domain (example.com): Add A records
   - For subdomain (www.example.com): Add CNAME record pointing to `v3ai2026.github.io`
3. Wait for DNS propagation (up to 24 hours)

### Q: How do I update the site content?

**A:** Simply push changes to the `main` branch:
```bash
# Make changes to files in public/ directory
git add public/
git commit -m "Update site content"
git push origin main
```
The workflow will automatically redeploy.

### Q: Can I deploy a different branch?

**A:** By default, only `main` branch triggers deployment. To deploy other branches:
1. Edit `.github/workflows/pages.yml`
2. Modify the `branches:` section under `on: push:`
3. Push your changes

### Q: What files are deployed?

**A:** The workflow deploys:
- All files from `public/` directory
- A fallback `index.html` (if none exists)
- `.nojekyll` file (prevents Jekyll processing)

### Q: Is this the full Laravel application?

**A:** No. GitHub Pages only hosts static files (HTML/CSS/JS). For the full MagicAI Laravel application with backend functionality, use:
- Docker deployment (see [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md))
- Traditional web hosting with PHP support
- Vercel/Railway for full-stack deployment

---

## 🆘 Getting Help

If you're still experiencing issues:

1. **Check Workflow Logs**
   - Go to Actions → Click on failed run → View logs

2. **Verify Prerequisites**
   - Admin access to repository
   - Pages enabled with "GitHub Actions" source
   - Correct workflow permissions

3. **Create an Issue**
   - Go to https://github.com/v3ai2026/333/issues
   - Click "New Issue"
   - Describe your problem with:
     - Steps you've taken
     - Error messages (include screenshots)
     - Workflow run URL

4. **Check GitHub Status**
   - Visit https://www.githubstatus.com/
   - Verify GitHub Pages/Actions are operational

---

## ✅ Quick Checklist

Before asking for help, verify you've completed:

- [ ] I have admin access to the repository
- [ ] I enabled Pages in Settings → Pages
- [ ] I selected "GitHub Actions" as the source
- [ ] I set workflow permissions to "Read and write"
- [ ] I triggered the workflow (push or manual)
- [ ] I waited 2-5 minutes after enabling Pages
- [ ] I checked the Actions tab for workflow status
- [ ] I tried accessing the site in an incognito/private browser window

---

**Last Updated**: 2026-01-14  
**Version**: MagicAI v9.9  
**Maintained by**: v3ai2026
