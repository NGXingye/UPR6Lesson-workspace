# 海洋模块索引

状态：active。配置：`profiles/ocean.yml`。跨系统：`docs/world/_index.md`。

冷启动只扫本表，再打开对应文件。不要通读本目录。

| 何时打开 | 文件 |
|---|---|
| 改频谱 / IFFT / 纹理打包 | `gpu_contract.md` |
| 改 Driver、形态、JONSWAP 派生 | `simulation.md` |
| 改 Clipmap、水面、光学、反射 | `rendering.md` |
| 浮力 / 高度查询 | `interaction.md` |
| Config / Outputs / asmdef / Odin | `system.md` |
| 分辨率、显存、Cascade 数量 | `optimization.md` |
| 未完成项 | `roadmap.md` |

## 源码（相对 UPR6Lesson）

| 关键词 | 优先打开 | 通常不要动 |
|---|---|---|
| FFT 驱动 | `Assets/FFTOcean/script/Runtime/Simulation/OceanSimulationDriver.cs` | 私有 RT |
| 频谱常量 / JONSWAP | `Assets/FFTOcean/script/Share/OceanSpectrumTypes.cs` | 预设数值表 |
| Compute | `Assets/FFTOcean/shader/FFTOceanCompute.compute` | — |
| 数学库 | `Assets/FFTOcean/shader/FFTOceanMathLib.hlsl` | — |
| Clipmap | `Assets/FFTOcean/script/Runtime/Rendering/OceanClipmapRenderer.cs` | 功能 partial 写生命周期 |
| 水面 | `Assets/FFTOcean/shader/OceanSurface.shader` | 已删除的 OceanWater |
| 输出 | `Assets/FFTOcean/script/Runtime/Simulation/OceanSimulationOutputs.cs` | Driver Release |
| 属性 ID | `Assets/FFTOcean/script/Share/OceanShaderIDs.cs` | 散写字符串 |

完整路由表按上面文件拆开，不在本索引重复。
