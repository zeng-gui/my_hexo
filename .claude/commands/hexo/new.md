---
description: 新建 Hexo 文章（输入标题自动创建）
argument-hint: 文章标题
allowed-tools: ["Read", "Write", "Bash", "Edit"]
---

# 新建 Hexo 文章

根据用户提供的标题 `$ARGUMENTS`，完成以下操作：

## 步骤

1. **创建文章**：
   ```bash
   cd /home/zg/projects/my_hexo && npx hexo new "$ARGUMENTS"
   ```

2. **完善 Front Matter**：
   - 日期设为当前时间
   - 添加 `categories`（根据内容判断分类）
   - 添加 2-5 个相关 `tags`
   - `toc: true`
   - `comments: true`

3. **创建文章骨架**：
   - 用中文写作，中英文之间加空格
   - 代码块必须标注语言
   - 标题层级从 `##` 开始
   - 在适当位置插入 `<!-- more -->` 标记摘要截断点

4. **文件名**：确保 slug 为小写英文短横线格式
