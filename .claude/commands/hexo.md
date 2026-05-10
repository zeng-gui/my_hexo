---
description: Hexo 开发环境操作速查与帮助
allowed-tools: ["Read", "Glob", "Bash"]
---

# Hexo 开发速查

项目：zg's Blog (Hexo 8.x + NexT 8.27.0 + Gemini 方案)
地址：https://zeng-gui.github.io/

## 常用命令

```bash
# 本地开发
npx hexo server              # http://localhost:4000
npx hexo server --draft      # 包含草稿

# 新建文章
npx hexo new "标题"           # 正式文章
npx hexo new draft "标题"     # 草稿

# 构建
npx hexo clean               # 清理缓存
npx hexo generate            # 生成静态文件到 public/
```

## 文件位置

| 文件 | 路径 |
|------|------|
| 文章 | `source/_posts/` |
| 草稿 | `source/_drafts/` |
| 图片 | `source/images/` |
| 站点配置 | `_config.yml` |
| 主题配置 | `_config.next.yml` |
| 自定义 head | `source/_data/head.swig` |
| 自定义样式 | `source/_data/styles.styl` |
| 部署 workflow | `.github/workflows/deploy-pages.yml` |

## 部署流程

**禁止** `hexo deploy`。本项目通过 GitHub Actions 自动部署：

1. 本地 `npx hexo generate` 验证构建
2. `git push origin main` 触发 CI
3. GitHub Actions 自动构建并部署到 GitHub Pages

## 常见问题

- **字体巨大**：NexT font.size 用 em 不是 px，写 16 会变成 16em
- **首页显示全文**：文章缺少 `<!-- more -->` 标签
- **URL 有子路径**：检查 `_config.yml` 的 `url` 是否与仓库名匹配
- **自定义样式不生效**：检查 `_config.next.yml` 的 `custom_file_path` 和文件是否存在

## 当前状态

检查当前项目配置状态，列出：
1. 当前安装的主题和主题版本
2. 已安装的 npm 包列表
3. `_config.yml` 和 `_config.next.yml` 中关键配置项
4. `.github/workflows/deploy-pages.yml` 是否存在且完整
