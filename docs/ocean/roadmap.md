# 路线图

只列未完成项。已完成的 IFFT 接线、Config 迁移、顶点位移首通、LUT 散射、统一厚度不写在这里。

## 渲染

- P0 可视化：最终色 / FFT 白沫 / 厚度 / 法线 / Fresnel / 反射有效标记。调试只改输出色，不改模拟。
- 散射 LUT 已作为唯一水色来源；若面板切换无变化，查 Binder 是否仍漏提交。
- 位移与斜率 Cascade 淡出必须同一函数。
- 细节法线走 TBN，不要 `slope += detail.xy`。
- 恢复 Fog，再看远景是否仍裂。
- 平面反射：`_PlanarReflectionValid`、排除 Ocean Layer、`try/finally` 恢复 culling、改 MPB/Outputs，去掉全局 `_ReflectionTex`。
- Surface 外观参数迁入 `OceanSurfaceConfig` → IDs → MPB；材质只留 Shader 和贴图。
- 按职责拆 `OceanFoam.hlsl` / `OceanReflection.hlsl`。
- 之后：法线扰动折射、附加光、ShadowCaster/DepthOnly/MotionVectors、水下相机。

## 模拟

- 位移 RT 初始清零，去掉首帧白沫 garbage。
- `VariationMask` 做真实生成，打破平铺。
- Foam Compute 参数留在 `OceanSimulationConfig`。

## 交互

- 用 `Outputs.BuoyancyTexture` 做 GPU 查询或 Readback，接船/漂浮物。
- 现有 `OceanQuest.Buoyancy` 接到 FFT 高度，或替换。
- 动态接触泡沫走场景深度，不把 Bathymetry 当碰撞。
- 涟漪独立 Simulation/Outputs。

## 系统

- 反射 Config/Outputs 与资源所有权收口。
- Gizmo 用 Editor `[DrawGizmo]`，不跨 asmdef partial。
- Player Build 验证 Odin 特性可剥离；运行时路径不调 Odin API。
- 重复启停、关 Domain Reload、非零海平面、Clipmap 接缝、泄漏审计。

## 优化

- 可调分辨率（见 `optimization.md`）。
- 显存与 1024 线程组平台验证。
- Cascade 数量参数化（全文契约，单独做）。

## 验收（任一原型转正）

Game/Scene 同时开、透视/正交、反射启停、Bathymetry 启停、无海床/真海床、主光旋转、远近 Clipmap、配置热改。无 NaN/Inf、无黑旧帧、无整片白沫、无海面自反射。Frame Debugger 能对上 Depth/Opaque、反射 RT、MPB Owner。
