# 模拟（物理模型）

Tessendorf FFT：JONSWAP 生成 H0，时间演化后 IFFT，组装成位移/斜率/浮力。数据布局见 `gpu_contract.md`。

## 每帧

```text
Config / Revision 变化 → 重建 H0 + 共轭打包
UpdateSpectrum → Horizontal IFFT → Vertical IFFT → AssembleTextures
```

`OceanSimulationDriver` 的 `DefaultExecutionOrder(-100)` 保证 Compute 先于 Renderer 绑 MPB。没有 CPU 回读。

生命周期：`Start/TryInitialize` 建 7 张 RT 和 Buffer；`OnDestroy` 释放。外部只读 `Outputs`。

## 参数从哪来

```text
OceanShapePreset / OceanShapeSettings
  → OceanShapeBuilder
  → JonswapParam[8] + CutOffs + WaveSharp + CascadeWeights
  → Driver Dispatch
  → OceanSimulationOutputs
```

Driver 只挂 `OceanSimulationConfig`。形态、Cascade、动画、白沫都在 Config。Play 中改 Config 会加 `Revision`，下一帧重建 H0，不必退出 Play。

四级 Cascade 按波长连续分工：`L0~L1`、`L1~L2`、`L2~L3`、`L3~最短细节`。默认长度约 1000 / 250 / 60 / 15 米。CutOff 由 Builder 生成，不要再加全局手调 CutOff。

频散与 TMA 浅水修正用 Config `depth`。这是模拟水深，不是摄像机看到的水体厚度。

## 形态层（短表）

默认不要手调 8 组 JONSWAP。预设：镜面海、细浪、中浪、大浪、巨浪、极端狂暴海。

| 视觉参数 | 主要派生 |
|---|---|
| 显著浪高 | 谱能量 |
| 主波长 | `peakOmega` |
| 浪尖锐度 | `_WaveSharp`（内部限幅） |
| 方向性 / 长涌浪 / 交叉浪 / 混乱度 | 方向谱与第二组 JONSWAP |
| 短波细节 | 短波衰减 + Cascade 2/3 权重 |
| 运动速度 | `timeScale` |

`repeatTime`（默认 200s）把 ω 量化到 `2π/repeatTime` 的整数倍，用来无缝循环。`_DisplacementScale` 是材质总位移微调，不参与物理派生。

## 已知坑

- 首帧白沫 alpha 可能是未清零 garbage，几帧后衰减收敛；几何 xyz 不受影响。
- `_VariationMask` 目前原样写回，不能当有效输出。
- `OceanShapeBuilder` 与 MathLib 的方向谱约定以源码为准。
