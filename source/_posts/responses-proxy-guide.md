---
title: responses-proxy：用 Python 搭建 OpenAI 兼容代理服务
date: 2025-05-09 18:00:00
tags:
  - python
  - openai
  - api
  - proxy
categories:
  - 技术笔记
toc: true
comments: true
---

## 背景：为什么需要代理

OpenAI 推出了 Responses API，它是 Chat Completions API 的下一代接口，支持更复杂的交互模式——多轮 tool call、reasoning 内容输出、多模态输入等。但问题来了：

1. **工具链滞后**：Codex CLI、Cursor 等工具已经对接了 Responses API，但很多国产模型（MiMo、DeepSeek、Qwen）只提供 Chat Completions 接口。
2. **接口不兼容**：Responses API 和 Chat Completions API 的请求/响应格式完全不同，直接替换行不通。
3. **多 provider 管理混乱**：不同模型散落在不同平台，每个平台一套 API key、一个 endpoint，切换成本高。

responses-proxy 就是为了解决这三个问题：它是一个 FastAPI 代理服务，接收 Responses API 请求，自动转换为 Chat Completions API 转发给后端 provider，再把响应转换回来。对上游工具来说，它就是一个标准的 Responses API 端点。

<!-- more -->

## 项目简介

### 架构总览

```
┌─────────────────┐         ┌──────────────────────┐         ┌─────────────────┐
│                 │  HTTP   │                      │  HTTP   │                 │
│   Codex CLI /   │────────▶│   responses-proxy    │────────▶│  LLM Providers  │
│   任意客户端     │◀────────│   (FastAPI)          │◀────────│                 │
│                 │         │                      │         │  - MiMo         │
└─────────────────┘         │  Responses API       │         │  - DeepSeek     │
                            │  ⇄ Chat Completions  │         │  - Qwen         │
                            │                      │         │  - OpenAI       │
                            │  ┌──────────────┐    │         │  - ...          │
                            │  │ Web 管理界面  │    │         │                 │
                            │  └──────────────┘    │         └─────────────────┘
                            └──────────────────────┘
```

### 工作流程

1. 客户端发送 Responses API 格式的请求到 proxy
2. proxy 根据路由规则选择目标 provider
3. 将请求从 Responses API 格式转换为 Chat Completions API 格式
4. 转发到对应的 provider endpoint
5. 接收 Chat Completions 响应，转换回 Responses API 格式
6. 返回给客户端

整个过程对客户端透明——它只看到一个标准的 Responses API 服务。

## 快速上手

### 环境要求

- Python 3.10+
- pip 或 uv

### 安装依赖

```bash
git clone https://github.com/zeng-gui/responses-proxy.git
cd responses-proxy
pip install -r requirements.txt
```

### 配置

复制示例配置并填入你的 API Key：

```bash
cp providers.json.example providers.json
```

编辑 `providers.json`：

```json
{
  "providers": [
    {
      "base_url": "https://api.deepseek.com/v1",
      "api_key": "sk-your-deepseek-key",
      "models": ["deepseek-chat", "deepseek-reasoner"]
    },
    {
      "base_url": "https://coding.dashscope.aliyuncs.com/v1",
      "api_key": "sk-your-qwen-key",
      "models": ["qwen3.6-plus"]
    },
    {
      "base_url": "https://token-plan-cn.xiaomimimo.com/v1",
      "api_key": "sk-your-mimo-key",
      "models": ["mimo-v2.5-pro", "mimo-v2.5"]
    }
  ]
}
```

### 启动服务

```bash
python proxy.py
```

启动后终端会显示：

```
INFO:     Uvicorn running on http://127.0.0.1:8000
```

然后浏览器访问 `http://127.0.0.1:8000` 即可打开 Web 配置管理界面，无需手动编辑 JSON。

服务默认监听 `http://localhost:8000`，你可以用 curl 快速验证：

```bash
curl http://localhost:8000/v1/responses \
  -H "Content-Type: application/json" \
  -d '{
    "model": "deepseek-chat",
    "input": "你好，请用一句话介绍自己"
  }'
```

### 对接 Codex CLI

编辑 Codex 配置文件（Linux/Mac: `~/.codex/config.toml`，Windows: `%USERPROFILE%\.codex\config.toml`）：

```toml
model = "mimo-v2.5-pro"

[model_providers.proxy]
name = "proxy"
base_url = "http://127.0.0.1:8000/v1"
wire_api = "responses"
requires_openai_auth = false
```

编辑 `~/.codex/auth.json`（代理侧管理真实密钥，这里可留空）：

```json
{
  "OPENAI_API_KEY": ""
}
```

然后正常使用 codex，所有请求会自动通过 proxy 路由到对应的 provider。

## 核心特性

### 多 Provider 路由

proxy 根据请求中的 `model` 字段自动路由到对应的上游 provider：

```bash
# 路由到 MiMo
curl -X POST http://localhost:8000/v1/responses \
  -H "Content-Type: application/json" \
  -d '{"model": "mimo-v2.5-pro", "input": "你好"}'

# 路由到 DeepSeek
curl -X POST http://localhost:8000/v1/responses \
  -H "Content-Type: application/json" \
  -d '{"model": "deepseek-chat", "input": "用 Python 实现二分查找"}'

# 路由到 Qwen
curl -X POST http://localhost:8000/v1/responses \
  -H "Content-Type: application/json" \
  -d '{"model": "qwen3.6-plus", "input": "解释量子计算"}'
```

每个 provider 独立配置 `base_url` 和 `api_key`，互不干扰。

### 流式与非流式响应

两种模式都完整支持。流式模式下，proxy 会实时将后端的 SSE 事件转换为 Responses API 的流式格式：

```bash
# 非流式（默认）
curl -X POST http://localhost:8000/v1/responses \
  -H "Content-Type: application/json" \
  -d '{
    "model": "deepseek-chat",
    "input": "用 Python 实现二分查找",
    "stream": false
  }'

# 流式
curl -X POST http://localhost:8000/v1/responses \
  -H "Content-Type: application/json" \
  -d '{
    "model": "deepseek-chat",
    "input": "用 Python 实现二分查找",
    "stream": true
  }'
```

流式响应是 SSE 格式，每个事件包含增量内容：

```
event: response.output_text.delta
data: {"delta": "def "}

event: response.output_text.delta
data: {"delta": "binary_search"}

event: response.output_text.delta
data: {"delta": "(arr, target):\n"}
```

### 完整 Tool Call 生命周期

对于支持 function calling 的模型，proxy 完整转换 tool call 的生命周期：

```bash
curl -X POST http://localhost:8000/v1/responses \
  -H "Content-Type: application/json" \
  -d '{
    "model": "deepseek-chat",
    "input": "北京今天天气怎么样？",
    "tools": [
      {
        "type": "function",
        "name": "get_weather",
        "description": "获取指定城市的天气信息",
        "parameters": {
          "type": "object",
          "properties": {
            "city": {"type": "string", "description": "城市名称"}
          },
          "required": ["city"]
        }
      }
    ]
  }'
```

proxy 会：
1. 将 Responses API 的 tool 定义转换为 Chat Completions 格式
2. 接收后端返回的 tool_call
3. 转换回 Responses API 的 function_call 输出格式
4. 处理 tool 结果的回传（后续轮次）

### 多模态输入

支持图片等多模态内容：

```bash
curl -X POST http://localhost:8000/v1/responses \
  -H "Content-Type: application/json" \
  -d '{
    "model": "qwen-vl-plus",
    "input": [
      {
        "type": "message",
        "role": "user",
        "content": [
          {"type": "input_text", "text": "这张图片里有什么？"},
          {"type": "input_image", "image_url": "https://example.com/photo.jpg"}
        ]
      }
    ]
  }'
```

proxy 自动将多模态内容转换为 Chat Completions 的 `content` 数组格式。

### reasoning_content 自动注入

DeepSeek-R1、QwQ 等 reasoning 模型会在响应中返回 `reasoning_content`（思考过程）。proxy 会自动将这部分内容注入到 Responses API 的输出中，客户端无需特殊处理：

```json
{
  "output": [
    {
      "type": "reasoning",
      "content": "让我分析一下这个问题..."
    },
    {
      "type": "message",
      "role": "assistant",
      "content": [
        {"type": "output_text", "text": "最终答案是..."}
      ]
    }
  ]
}
```

这样 Codex CLI 等工具就能正确显示推理模型的思考过程了。

### Web 配置管理界面

proxy 内置了一个 Web UI，浏览器访问 `http://127.0.0.1:8000` 即可打开深色主题的配置管理面板：

- 查看当前 provider 列表和状态
- 添加/删除/修改 provider 配置（直接在卡片上编辑）
- 管理模型列表（输入模型名按回车添加）
- 测试连通性（点击「测试」按钮自动 ping 上游 `/v1/models`）
- 修改 Host / Port 等全局设置

所有操作通过界面完成，不需要手动编辑 JSON 文件。

### 配置热重载

在 Web UI 中点击「保存配置」后，proxy 自动热重载，无需重启进程。也可以通过 API 手动触发：

```bash
curl -X POST http://localhost:8000/api/reload
```

整个流程：打开 Web UI → 编辑 Provider → 点击「测试」验证 → 点击「保存」生效。

## 使用场景

### 场景一：Codex CLI 接国产模型

Codex CLI 原生只支持 OpenAI，通过 proxy 可以直接用 MiMo、DeepSeek、Qwen 等模型：

```toml
# ~/.codex/config.toml
model = "mimo-v2.5-pro"

[model_providers.proxy]
name = "proxy"
base_url = "http://127.0.0.1:8000/v1"
wire_api = "responses"
requires_openai_auth = false
```

切换模型只需改 `model` 字段，所有请求自动路由。

### 场景二：统一多 Provider 管理

团队内部有多个 AI 应用，每个应用可能用不同模型。通过 proxy 统一入口：

```python
import openai

client = openai.OpenAI(
    base_url="http://proxy:8000/v1",
    api_key="dummy"  # proxy 侧管理真实密钥
)

# 用 MiMo 做对话
resp = client.chat.completions.create(
    model="mimo-v2.5-pro",
    messages=[{"role": "user", "content": "你好"}]
)

# 切换到 DeepSeek 做推理
resp = client.chat.completions.create(
    model="deepseek-chat",
    messages=[{"role": "user", "content": "分析这个问题..."}]
)
```

### 场景三：本地开发调试

在本地跑一个 proxy，把请求转发到远程 provider，方便调试和日志查看：

```bash
responses-proxy --config config.yaml --log-level debug
```

所有请求和响应都会打印详细日志，排查问题很方便。

### 场景四：API 格式迁移

如果你的项目从 Chat Completions API 迁移到 Responses API，可以用 proxy 做过渡层——先让 proxy 接管流量，客户端逐步切换到新接口，后端暂时不动。

## 总结

responses-proxy 解决了一个很实际的问题：让只支持 Chat Completions API 的模型 provider 能被 Responses API 客户端（如 Codex CLI）直接调用。它的核心价值在于：

- **透明代理**：客户端只看到 Responses API，后端只收到 Chat Completions API，转换逻辑由 proxy 处理
- **多 provider 统一管理**：一个配置文件管理所有 provider，路由规则灵活
- **生产可用**：流式响应、tool call、多模态、配置热重载——该有的都有
- **部署简单**：`pip install` 一行搞定，Python 项目无需额外依赖

如果你正在用 Codex CLI 或其他 Responses API 客户端，想接入更多模型 provider，可以试试这个项目：

GitHub: https://github.com/zeng-gui/responses-proxy

```bash
git clone https://github.com/zeng-gui/responses-proxy.git
cd responses-proxy
pip install -r requirements.txt
python proxy.py
```
