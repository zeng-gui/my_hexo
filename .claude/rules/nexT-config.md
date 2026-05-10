# NexT 主题配置规则

## 字体大小单位（踩坑记录）

NexT 的 `font` 配置使用 **em 单位**，不是 px。错误的值会导致字体巨大（如 16em = 256px）。

```yaml
# 正确
font:
  global:
    size: 1        # 1em = 16px
  title:
    size: 1.375    # 约 22px
  headings:
    size: 1.625    # 约 26px
  posts:
    size: 1        # 1em = 16px
  codes:
    size: 0.875    # 约 14px

# 错误 - 会导致字体巨大
font:
  global:
    size: 16       # 变成 16em = 256px！
```

## 自定义样式文件

自定义 CSS 通过 `_config.next.yml` 的 `custom_file_path` 配置：

```yaml
custom_file_path:
  head: source/_data/head.swig      # 引入外部资源（字体等）
  style: source/_data/styles.styl   # 自定义 Stylus 样式
```

可用的注入点（views）：head, header, sidebar, postMeta, postBodyStart, postBodyEnd, footer, bodyEnd, comment
可用的样式注入（styles）：variable, mixin, style

## Scheme 选择

- `Muse`：默认，黑白简洁
- `Mist`：紧凑单栏
- `Pisces`：双栏清新
- `Gemini`：双栏 + 阴影，最精致（推荐）

## 注意事项

- `highlight_theme` 推荐 `night` 或 `night eighties`
- `reading_progress.color` 与主题色保持一致
- 暗色模式下需检查自定义样式的对比度
