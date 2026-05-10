#!/bin/bash
# Hook: 检查是否执行了被禁止的部署命令
input="$1"
if echo "$input" | grep -qE 'hexo\s+deploy|hexo\s+generate\s+--deploy'; then
  echo '{"decision":"block","reason":"本项目通过 GitHub Actions 自动部署，禁止本地 hexo deploy。请使用 npx hexo generate 检查构建，然后 git push 触发 CI 部署。"}'
  exit 0
fi
exit 0
