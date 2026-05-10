#!/bin/bash
# Hook: 新建文章后提醒添加 <!-- more --> 标签
input="$1"
if echo "$input" | grep -qE 'hexo\s+new\s+["\x27]?[^"\x27]'; then
  echo '{"decision":"approve","reason":"提醒：新文章记得在适当位置添加 <!-- more --> 标签，否则首页会显示全文。"}'
  exit 0
fi
exit 0
