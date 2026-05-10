# 部署规则

## 部署方式

本项目通过 **GitHub Actions** 自动部署到 GitHub Pages。**禁止**本地 `hexo deploy`。

- 推送到 `main` 分支自动触发构建和部署
- GitHub Pages 源设置为 `GitHub Actions`
- 仓库名：`zeng-gui.github.io`（用户级 Pages，根路径托管）

## 部署前检查清单

1. `npx hexo clean && npx hexo generate` 构建成功
2. 检查 `public/` 目录生成了 HTML 文件
3. 检查 URL 中不含错误的子路径（如 `/my_hexo/`）
4. 新文章有 `<!-- more -->` 标签

## URL 配置

`_config.yml` 中的 `url` 必须与 GitHub Pages 地址一致：

```yaml
url: https://zeng-gui.github.io
```

如果仓库名变更，url 也要同步更新。

## Git 提交规范

```
feat: 新增文章《XXX》
fix: 修复 XXX 问题
style: 调整主题样式
config: 配置变更
chore: 更新依赖 / 脚本
docs: 文档变更
```

## 远程仓库

token 在 remote URL 中，推送时自动认证。注意 token 可能过期需要更新。
