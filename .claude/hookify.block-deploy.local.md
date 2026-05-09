---
name: block-production-deploy
enabled: true
event: bash
pattern: hexo\s+deploy|hexo\s+generate\s+--deploy
action: block
---

🚫 **Production deploy blocked in project**

本项目通过 GitHub Actions 自动部署，不需要本地 `hexo deploy`。
本地只做 `hexo generate` 检查构建结果，push 到 main 分支后 CI 会自动部署。

请使用 `npx hexo generate` 或 `npx hexo server`。
