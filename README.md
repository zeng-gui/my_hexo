# My Hexo Blog

基于 Hexo 的个人博客，通过 GitHub Pages 免费托管，无需服务器。

## 本地开发

```bash
# 安装依赖
npm install

# 本地预览 (http://localhost:4000)
npx hexo server

# 新建文章
npx hexo new "文章标题"

# 构建静态文件
npx hexo generate
```

## 部署

推送到 GitHub `main` 分支后，GitHub Actions 会自动构建并部署到 GitHub Pages。

```bash
git add .
git commit -m "new post"
git push origin main
```

## 自定义

- `_config.yml` — 站点基础配置（标题、描述、URL 等）
- `source/_posts/` — 文章目录
- `themes/` — 主题目录
