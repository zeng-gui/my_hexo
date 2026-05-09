# CLAUDE.md — My Hexo Blog 项目上下文

## 项目概述

个人技术博客，基于 Hexo 8.x + NexT 主题，托管在 GitHub Pages。
目标：零运维、写作优先、版本可控、中文友好。

## 技术栈

| 层级 | 选型 | 说明 |
|------|------|------|
| 框架 | Hexo 8.x | 静态站点生成，Markdown 驱动 |
| 主题 | NexT | 中文文档完善，配置丰富 |
| 样式 | Stylus | Hexo 原生支持 |
| 托管 | GitHub Pages | 免费 HTTPS + CDN |
| CI/CD | GitHub Actions | push main 自动构建部署 |
| 评论 | Giscus | 基于 GitHub Discussions |

## 项目结构

```
my_hexo/
├── _config.yml                 # Hexo 站点主配置
├── _config.next.yml            # NexT 主题配置（需创建）
├── package.json
├── .github/workflows/          # CI/CD
├── source/
│   ├── _posts/                 # 文章（按年月分子目录）
│   ├── _drafts/                # 草稿（线上不可见）
│   ├── about/                  # 关于页面
│   └── images/                 # 图片资源
├── themes/                     # NexT 主题（npm 安装）
└── .claude/                    # Claude Code 项目配置
```

## 关键配置状态

- [x] Hexo 项目初始化，Hexo 8.x
- [x] GitHub Actions 自动部署 workflow 已配置
- [x] 首篇示例文章已创建
- [ ] NexT 主题未安装（当前用 landscape）
- [ ] _config.next.yml 未创建
- [ ] url 为占位符（需要填真实 GitHub Pages URL）
- [ ] post_asset_folder: false（建议改为 true）
- [ ] highlight auto_detect: false（建议改为 true）

## 常用命令

```bash
# 本地开发
npx hexo server                 # http://localhost:4000
npx hexo server --draft         # 包含草稿

# 新建文章
npx hexo new "文章标题"          # 正式文章
npx hexo new draft "草稿标题"    # 草稿

# 构建
npx hexo clean                  # 清理缓存
npx hexo generate               # 生成静态文件

# 草稿转正式
npx hexo publish "草稿标题"
```

## 文章 Front Matter 规范

```yaml
---
title: 文章标题              # 必填
date: 2025-05-09 15:00:00   # 必填，发布日期
updated: 2025-05-09 16:00:00  # 可选，最后更新日期
tags:
  - 标签1
  - 标签2
categories:
  - 分类1
  - [分类1, 子分类]         # 多级分类
sticky: 1                    # 可选，置顶权重
toc: true                    # 可选，显示目录
mathjax: false               # 可选，数学公式
comments: true               # 可选，评论开关
---
```

## 分类体系

一级分类（不超过 7 个）：
- 技术笔记 — 语言、框架、工具的使用记录
- 实战项目 — 完整项目从 0 到 1
- 环境搭建 — 开发环境、服务器、CI/CD
- 问题排查 — 踩坑记录、报错解决
- 学习资源 — 书单、课程、文档整理
- 随笔 — 非技术类

## Git 提交规范

```
feat: 新增文章《XXX》
fix: 修复 XXX 问题
style: 调整主题样式
config: 配置变更
chore: 更新依赖 / 脚本
docs: 文档变更
```

## 设计文档

项目设计文档在 `docs/dev/` 目录（.gitignore 中排除，不入库）：
- 00-project-overview.md — 项目总览
- 01-architecture.md — 架构设计
- 02-theme-ui.md — 主题与 UI 设计
- 03-content-strategy.md — 内容策略
- 04-deployment-devops.md — 部署与 DevOps
- 05-features-roadmap.md — 功能路线图
- 06-dev-conventions.md — 开发规范

## 注意事项

- 中英文之间加空格
- 代码块必须标注语言标识
- 外部链接使用完整 URL
- 专有名词保持官方大小写（GitHub、JavaScript）
- 图片放 source/images/ 目录
- 新文章文件名用小写英文短横线
