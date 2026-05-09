---
description: Hexo 开发环境操作速查与帮助
allowed-tools: ["Read", "Glob", "Bash"]
---

# Hexo 开发速查

项目：My Hexo Blog (Hexo 8.x + NexT)

## 常用命令

```bash
npx hexo server              # 本地预览 http://localhost:4000
npx hexo server --draft      # 包含草稿
npx hexo new "标题"           # 新建文章
npx hexo new draft "标题"     # 新建草稿
npx hexo publish "标题"       # 草稿转正式
npx hexo clean               # 清理缓存
npx hexo generate            # 构建静态文件
```

## 文件位置

- 文章：source/_posts/
- 草稿：source/_drafts/
- 图片：source/images/
- 站点配置：_config.yml
- 主题配置：_config.next.yml

## 当前状态

检查当前项目配置状态，列出：
1. 当前安装的主题和主题版本
2. 已安装的 npm 包列表
3. _config.yml 中关键配置项的当前值
4. .github/workflows/deploy-pages.yml 是否存在且完整
