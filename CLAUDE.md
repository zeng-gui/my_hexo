# CLAUDE.md — My Hexo Blog 项目上下文

## 项目概述

个人技术博客，基于 Hexo 8.x + NexT 主题，托管在 GitHub Pages。
目标：零运维、写作优先、版本可控、中文友好。

站点地址：https://zeng-gui.github.io/
仓库名：zeng-gui.github.io（用户级 Pages，根路径托管）

## 技术栈

| 层级 | 选型 | 说明 |
|------|------|------|
| 框架 | Hexo 8.x | 静态站点生成，Markdown 驱动 |
| 主题 | NexT 8.27.0 | Gemini 方案，双栏 + 阴影 |
| 样式 | Stylus | Hexo 原生支持 |
| 托管 | GitHub Pages | 免费 HTTPS + CDN |
| CI/CD | GitHub Actions | push main 自动构建部署 |
| 字体 | Noto Sans SC + JetBrains Mono | 中文 + 代码 |

## 项目结构

```
my_hexo/
├── _config.yml                 # Hexo 站点主配置
├── _config.next.yml            # NexT 主题配置
├── package.json
├── .github/workflows/          # CI/CD
├── source/
│   ├── _posts/                 # 文章
│   ├── _drafts/                # 草稿（线上不可见）
│   ├── _data/                  # 自定义模板和样式
│   │   ├── head.swig           # 自定义 head（字体引入）
│   │   └── styles.styl         # 自定义 Stylus 样式
│   ├── about/                  # 关于页面
│   └── images/                 # 图片资源
├── themes/                     # NexT 主题（npm 安装）
├── .claude/                    # Claude Code 项目配置
│   ├── settings.json           # 权限和 hooks
│   ├── commands/hexo/          # Hexo 命令（new/deploy/build）
│   ├── agents/                 # 自定义 agent
│   ├── hooks/                  # 构建检查 hooks
│   └── rules/                  # 项目规则
└── docs/dev/                   # 设计文档（不入库）
```

## 关键配置状态

- [x] Hexo 8.x 项目初始化
- [x] NexT 8.27.0 主题安装（npm），Gemini 方案
- [x] _config.next.yml 已创建，含自定义样式
- [x] GitHub Actions 自动部署 workflow 已配置
- [x] url 配置正确：https://zeng-gui.github.io
- [x] 仓库名为 zeng-gui.github.io（用户级 Pages）
- [x] 自定义字体：Noto Sans SC + JetBrains Mono
- [x] 自定义样式：source/_data/styles.styl

## 踩坑记录

### NexT 字体配置用 em 不是 px

```yaml
# 正确
font:
  global:
    size: 1        # 1em = 16px

# 错误 - 字体会变成 256px
font:
  global:
    size: 16       # 变成 16em！
```

### 首页显示全文

文章必须加 `<!-- more -->` 标签，否则首页会显示整篇文章。

### 仓库名影响 URL

仓库名 `my_hexo` → URL 是 `/my_hexo/`
仓库名 `zeng-gui.github.io` → URL 是 `/`（根路径）

改仓库名后必须同步更新 `_config.yml` 的 `url`。

### 自定义样式注入点

NexT 的 `custom_file_path` 支持的 key：
- Views: head, header, sidebar, postMeta, postBodyStart, postBodyEnd, footer, bodyEnd, comment
- Styles: variable, mixin, style

## 常用命令

```bash
npx hexo server              # http://localhost:4000
npx hexo server --draft      # 包含草稿
npx hexo new "标题"           # 新建文章
npx hexo new draft "标题"     # 新建草稿
npx hexo clean               # 清理缓存
npx hexo generate            # 生成静态文件
```

## 文章规范

- 文件名：小写英文短横线（`my-post.md`）
- 必须有 `<!-- more -->` 标签
- Front Matter 必填：title, date, tags, categories
- 分类不超过 7 个一级分类
- 中英文之间加空格
- 代码块必须标注语言

## 分类体系

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
