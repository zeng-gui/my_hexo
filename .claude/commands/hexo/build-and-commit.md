---
description: 验证构建结果再提交
argument-hint: [可选] commit message
allowed-tools: ["Read", "Glob", "Bash", "Edit"]
---

# Hexo 构建验证 + 提交

在提交前先验证站点能正常构建。

## 步骤

1. **清理并构建**：
   ```bash
   cd /home/zg/projects/my_hexo && npx hexo clean && npx hexo generate
   ```

2. **检查构建输出**：
   - 确认 `public/` 目录生成
   - 检查是否有构建警告或错误
   - 验证 HTML 文件数量合理

3. **列出变更文件**：
   ```bash
   cd /home/zg/projects/my_hexo && git status && git diff --stat
   ```

4. **确认后提交**：
   - 如果 $ARGUMENTS 有内容，用作 commit message
   - 否则根据变更内容生成合适的 commit message（遵循 feat/fix/style/chore 规范）
   - 提交前展示 commit message 让用户确认
