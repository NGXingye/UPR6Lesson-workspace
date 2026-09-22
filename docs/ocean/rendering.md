# 渲染

几何只来自 `OceanSimulationOutputs` 的四级 FFT 位移和斜率。旧 Gerstner/FBM、`OceanWater` 参考栈已从工程移除，不要再加回来。

## 数据流

```text
Driver.Dispatch
  → Outputs（只读纹理句柄 + IsReady）
  → OceanClipmapRenderer.MaterialBinding
  → MaterialPropertyBlock
  → OceanSurface.shader
```

顶点：世界 XZ 除以四级 `CascadeLengths` 得周期 UV，采样 slice 0~3 位移后求和，再 `TransformWorldToHClip`。`OceanClipmapConfig.displacementBoundsPadding` 扩大 CPU Bounds，避免顶点被 Shader 推走后被裁掉。

调试四色开启时走同一 Surface Shader 的 BaseColor；关闭后用 `OceanSurfaceConfig.surfaceMaterial`。

## HLSL 边界

| 文件 | 只负责 |
|---|---|
| `OceanSurface.shader` | URP Pass 入口与最终合成 |
| `OceanSurfaceSampling.hlsl` | 四级位移/斜率采样，不处理颜色 |
| `OceanBathymetry.hlsl` | 世界→深度图 UV、解码、有限值 |
| `OceanOptics.hlsl` | 统一厚度、吸收、散射、背景透射 |
| `OceanLighting.hlsl` | BRDF、主光、探针、浪尖透光 |

不要再做一个同时声明模拟纹理、场景纹理和全套光照的综合 include。白沫/反射正式拆分前，新逻辑仍按上表归类，不要塞进 Sampling。

## 三种深度

| 名称 | 来源 | 用途 |
|---|---|---|
| 模拟水深 | `OceanSimulationConfig.depth` | 只影响波速和频谱 |
| 场景厚度 | `_CameraDepthTexture` 减水面眼深 | 动态遮挡、吸收、岸线 |
| 海床代理 | Bathymetry 灰度图 | 静态大范围深浅；覆盖区外无效，不 Clamp 到边 |

正式厚度：两者有效取较小值；只有一个用该值；都无效回退 `maxOpticalDepth`。光学、岸线白沫必须用同一 `OceanOpticsData.thickness`。Bathymetry 不是角色/船体接触深度。

URP Renderer 的 Copy Depth 必须在透明前（`AfterOpaques`）。只开 `requiresDepthTexture` 不够。天空无深度时厚度回退最大光学深度。

## 当前介质与法线（终态）

吸收与散射分开：

```text
sigmaA = RGB吸收 × 背景吸收强度
sigmaS = 散射强度 × 2 / 最大光学深度
sigmaT = sigmaA + sigmaS
T = exp(-sigmaT × thickness)
scatteringAlbedo = sigmaS / sigmaT
transmittedScene = sceneColor × T
inScattering = LUT × scatteringAlbedo × (1 - T)
```

散射颜色唯一来源是 `scatteringDepthGradient` → 256×1 RGBAHalf LUT。旧浅/深双色不参与运行时。

法线分域：`macroNormalWS` 只来自 FFT 斜率（体散射）；`surfaceNormalWS` = 宏观 + 双层细节（Fresnel/GGX/反射）。细节经水面 TBN 转到世界空间，不要把 tangent XY 直接加到 slope。

体积项乘 `(1 - Fresnel)` 后再加直接高光与环境反射。浪尖遮罩只用正位移：`saturate(max(height,0) * scale)`，平坦水面不应整片透光。

水面约在 `Transparent-100`，当前 `ZWrite On`、`Blend One Zero`，自己合成背景。Clipmap 调试用 `_OceanOpticsEnabled = 0` 绕过光学。

## 平面反射

`OceanPlanarReflection.cs` 仍是原型：全局 `_ReflectionTex`、缺有效标记、可能画到海面自己。正式方案见 `roadmap.md`，不要再加无 Owner 的全局纹理。

## URP 输入

Renderer/Camera 需要 Depth Texture 与 Opaque Texture。雾应走 `MixFog`，与场景远景一致。
