---
description: 构建验证 + 提交 + 推送部署
argument-hint: [可选] commit message
allowed-tools: ["Read", "Glob", "Bash", "Edit"]
---

# Hexo 构建 + 部署

构建验证通过后提交并推送到 GitHub，触发自动部署。

## 步骤

1. **清理并构建**：
   ```bash
   cd /home/zg/projects/my_hexo && npx hexo clean && npx hexo generate
   ```

2. **检查构建输出**：
   - 确认 `public/` 目录生成
   - 检查 HTML 文件数量合理
   - 确认无构建警告或错误

3. **检查文章摘要**：
   - 遍历 `source/_posts/*.md`
   - 检查每篇文章是否有 `<!-- more -->` 标签
   - 如果缺少，提醒用户添加

4. **查看变更**：
   ```bash
   cd /home/zg/projects/my_hexo && git status && git diff --stat
   ```

5. **提交并推送**：
   - 如果 $ARGUMENTS 有内容，用作 commit message
   - 否则根据变更内容生成合适的 commit message
   - 推送到 origin/main 触发 GitHub Actions 部署

6. **验证部署**：
   - 等待 GitHub Actions 完成
   - 检查 https://zeng-gui.github.io/ 可访问
