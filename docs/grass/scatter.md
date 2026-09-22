# Scatter / GPUScatter

与草地共用 Stream/Renderer，换 Domain + Placement。不要把 FFT 海洋或体积云塞进来。

## A 类流程

```text
ScatterFieldConfig
  → Domain 候选
  → Placement 密度/抖动/缩放/朝向
  → Constraint 形状过滤
  → Surface Projection（None / PlaneY / Heightmap）
  → GeneratedInstanceStream
  → 静态：CopyCount → DrawRequest
  → 动态：Spawn → Simulation 更新 State → RenderSource → DrawRequest
```

SDFVolume 是 Domain，不是 Surface Projection。

Driver 是静态 Stream 与 `ScatterSimulationRuntime` 的唯一选择点。动态积分只改 Simulation compute，不改静态 Domain 结果。

## 文件

| 职责 | 路径 |
|---|---|
| 枚举 | `Art/Script/Share/ScatterEnums.cs` |
| Field / SDF / Sim / Model SO | `Art/Script/Data/Scatter*.cs` |
| Driver | `Art/Script/Runtime/Scatter/ScatterFieldDriver*.cs` |
| 动态积分 | `ScatterSimulationRuntime.cs` + `shader/Scatter/ScatterSimulation.compute` |
| Domain 生成 | `shader/Scatter/AABBScatter.compute` |
| 绘制 | `ScatterInstanceRenderer` + `ScatterDemo.shader` |

已落地 Domain：AABB、Mesh 顶点、Mesh 三角、SDF Volume。Placement：Lattice / Random / Normal / BlueNoise。

## B 类（兄弟模块）

沿曲线生成连续 mesh（路/藤蔓/丝带）在 `Runtime/GPUScatter/` + `shader/GPUScatter/`。输出是几何，不是实例复制。保持独立，只共享 compute/间接绘制基建。

## 框架边界

- A 类：换 Domain/Placement，复用 Instance 绘制
- B 类：曲线 PCG，独立模块
- C 类：体积云、FFT 海洋 — 独立系统，不要进本仓库散布核
