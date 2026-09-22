# 草地路线图

只列未完成项。

## 渲染 / 系统

- Unity 6：`DrawProceduralIndirect` → `RenderPrimitivesIndirect` / `RenderMeshIndirect`（现仅告警）
- A/B 顶点运行时分支可改为 `#pragma shader_feature _RIGID_MODEL`（独立、有风险）
- 无 asmdef：要做插件时再加，Runtime 零 Odin
- 材质池：Profiler 证明材质数是瓶颈前不要扩散 Renderer 改动
- `NeedsRegenerate` 里 `new HashSet<Vector2Int>` 仅相机移动时，量小

## 交互

- 修 Trample Blit 坐标（y 翻转/未满屏）
- 可补 trample 窗口 gizmo、密度热力图、非 Play 预估实例数

## 优化

- 生成缓存已按相机阈值；不要把时变量烤回 compute
- 容量按 Tile × 密度，不要回到巨型 `tileRes²×96×18`

## Scatter

- 横向新 Domain 前先保持 Renderer/Stream 边界干净
- B 类曲线模块独立演进
- C 类（FFT/体积云）不进本框架
