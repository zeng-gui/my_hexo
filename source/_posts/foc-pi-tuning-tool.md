---
title: FOC PI 参数整定工具：从理论到代码的一站式调参助手
date: 2026-05-10 10:00:00
tags:
  - python
  - FOC
  - 电机控制
  - PI调参
  - 嵌入式
categories:
  - 实战项目
toc: true
comments: true
---

## 背景：调参的痛点

做 FOC（Field-Oriented Control）电机控制的工程师，一定对 PI 参数整定不陌生。电流环的 Kp、Ki 怎么算？速度环的带宽取多少合适？拿到一台新电机，光是把电流环调到能用，往往就要花半天时间。

更麻烦的是，不同电机参数差异巨大——小功率伺服电机的电阻可能只有几十毫欧，而大功率电机的电阻可能有好几欧姆。用同一套经验值去套，效果天差地别。

motor_para 就是为了解决这个问题：输入电机参数，自动计算出一组可用的 PI 增益，还能直接生成 STM32、GD32、TI C2000 平台的 C 代码。

<!-- more -->

## 项目简介

motor_para 是一个 FOC PI 参数整定辅助工具，支持三种调参算法、AI 辅助分析、多平台代码生成。技术栈是 Python + FastAPI，提供 Web UI 和 CLI 两种使用方式。

核心能力：

- **离线调参**：输入电机参数（电阻、电感、磁链、转动惯量、极对数），自动计算 d 轴/q 轴电流环和速度环的 Kp/Ki
- **AI 辅助**：接入 DeepSeek 等大模型，提供参数估算、波形分析、故障诊断
- **代码生成**：一键生成 STM32/GD32/TI C2000 平台的 PI 控制器 C 代码，支持浮点和定点（Q15/Q24/IQ）

## 三种调参算法

### 带宽法（Bandwidth Method）

最常用的方法。核心思想是把电流环当作一阶系统，设定目标带宽 omega_c，直接算出增益：

```
Kp = omega_c * L
Ki = omega_c * R
```

速度环用二阶系统模型，设定自然频率 omega_n 和阻尼比 zeta：

```
Kp = 2 * zeta * omega_n * J / Kt
Ki = omega_n^2 * J / Kt
```

优点是直观，缺点是忽略了电阻的影响（对低阻抗电机误差小，高阻抗电机误差大）。

### 极点配置法（Pole Placement）

把闭环极点放在期望位置，数学上更严谨：

```
Kp = 2 * pole * L - R
Ki = pole^2 * L
```

相比带宽法，多了 `-R` 项来补偿电阻。当电机电阻大于 1 欧姆时，工具会自动切换到这个方法。

### Ziegler-Nichols 法

基于系统时间常数的经典方法：

```
tau = L / R
Kp = 0.9 * R
Ki = Kp / (3.33 * tau)
```

适合快速估算，但精度不如前两种。

## 自动算法选择

工具支持 AUTO 模式，根据电机电阻自动选择算法：

```python
if Rs > 1.0:
    # 高阻抗电机，用极点配置法补偿电阻
    algorithm = PolePlacement()
else:
    # 低阻抗电机，带宽法足够精确
    algorithm = BandwidthMethod()
```

这个设计很实用——实际工程中，不同功率等级的电机确实需要不同的处理方式。

## 参数校验

不只是算数，还会帮你检查参数是否合理：

- **范围校验**：每个参数都有 min/max 边界（比如 Rs: 0.001~100 欧姆）
- **一致性检查**：IPM 电机的 Ld 应该小于 Lq，如果不满足会报警
- **缺失参数提示**：如果没填磁链 Psi_f，会告诉你"可以用反电动势常数 Ke 估算，Psi_f = Ke / (sqrt(3) * 2 * pi * fe)"

## AI 辅助调参

接入 DeepSeek 等大模型后，可以做四件事：

1. **智能参数估算**：给部分参数，AI 估算缺失值并给出置信度
2. **波形分析**：输入响应数据（上升时间、超调、纹波），诊断控制性能
3. **故障诊断**：描述故障现象（过流、振荡、堵转），给出排查步骤
4. **调参建议**：分析当前 PI 增益，提出优化方向

没有 API Key 也能用——内置了关键词匹配的兜底回答，覆盖振荡、超调、过流、低速抖动等常见问题。

## 多平台代码生成

这是最实用的功能之一。调完参数，直接生成可用的 C 代码：

### STM32（浮点）

```c
typedef struct {
    float Kp;
    float Ki;
    float integral;
    float output;
    float out_min;
    float out_max;
} PI_Controller;

float PI_Compute(PI_Controller *pi, float error) {
    pi->integral += pi->Ki * error;
    // 积分限幅（抗饱和）
    if (pi->integral > pi->out_max) pi->integral = pi->out_max;
    if (pi->integral < pi->out_min) pi->integral = pi->out_min;

    pi->output = pi->Kp * error + pi->integral;
    // 输出限幅
    if (pi->output > pi->out_max) pi->output = pi->out_max;
    if (pi->output < pi->out_min) pi->output = pi->out_min;

    return pi->output;
}
```

### STM32（Q15 定点）

没有 FPU 的 MCU 用定点数，乘法变成移位：

```c
int16_t PI_Compute_Q15(PI_Controller_Q15 *pi, int16_t error) {
    pi->integral += (int32_t)pi->Ki * error >> 15;
    // 积分限幅
    if (pi->integral > pi->out_max) pi->integral = pi->out_max;
    if (pi->integral < pi->out_min) pi->integral = pi->out_min;

    int32_t output = ((int32_t)pi->Kp * error >> 15) + pi->integral;
    if (output > pi->out_max) output = pi->out_max;
    if (output < pi->out_min) output = pi->out_min;

    return (int16_t)output;
}
```

### TI C2000（IQmath）

```c
_iq PI_Compute_IQ(PICTRL *pi, _iq error) {
    pi->integral += _IQmpy(pi->Ki, error);
    if (pi->integral > pi->out_max) pi->integral = pi->out_max;
    if (pi->integral < pi->out_min) pi->integral = pi->out_min;

    _iq output = _IQmpy(pi->Kp, error) + pi->integral;
    if (output > pi->out_max) output = pi->out_max;
    if (output < pi->out_min) output = pi->out_min;

    return output;
}
```

三种平台的代码都包含积分抗饱和和输出限幅，拿到就能用。

## Web UI

基于 Tailwind CSS + Alpine.js 的单页应用，四个页面：

- **离线调参**：填表单、选算法、看结果（带颜色卡片和 KaTeX 公式渲染）
- **在线调试**：串口通信，实时读写参数（开发中）
- **AI 助手**：聊天界面，支持快捷提问
- **文档**：内置 FOC 理论和公式推导

## 快速上手

```bash
git clone https://github.com/zeng-gui/motor_para.git
cd motor_para
pip install -r requirements.txt
python run_web.py
```

浏览器打开 `http://localhost:8000`，填入电机参数，点击"开始计算"即可。

CLI 模式：

```bash
python -m src.ui.cli
```

## 串口通信协议

工具还支持通过 UART 和实际电机控制器通信，自定义二进制协议：

```
HEAD(0xAA) + LEN(2B) + CMD(1B) + DATA(nB) + CRC16(2B) + TAIL(0x55)
```

支持读写参数、启停波形监控、心跳检测。后台 RX 线程负责帧重组和回调分发。

## 总结

motor_para 解决的是一个很具体的问题：FOC 调参太依赖经验，新手上手慢，老手效率低。它的价值在于：

- **算法可选**：三种方法覆盖不同场景，AUTO 模式自动选择
- **参数校验**：不只是算数，还会帮你检查参数是否合理
- **代码即用**：生成的 C 代码包含抗饱和和限幅，拿到 MCU 上就能跑
- **AI 加持**：没有示波器也能靠 AI 分析波形和诊断故障

项目地址：https://github.com/zeng-gui/motor_para

如果你也在做电机控制，不妨试试。
