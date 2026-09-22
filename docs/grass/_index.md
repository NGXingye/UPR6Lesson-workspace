# 草地模块索引

状态：active。配置：`profiles/grass.yml`。散布同属本模块。跨系统：`docs/world/_index.md`。

冷启动只扫本表，再打开对应文件。

| 何时打开 | 文件 |
|---|---|
| stride / dispatch 顺序 / 绘制 Request | `contract.md` |
| 生成、瓦片缓存、地形表面、Builder | `generation.md` |
| grass.shader、间接绘制、调试 | `rendering.md` |
| Interactor / Trample | `interaction.md` |
| 职责边界、加参数、Odin | `system.md` |
| Scatter / GPUScatter | `scatter.md` |
| 未完成项 | `roadmap.md` |

## 源码（相对 UPR6Lesson，前缀 `Assets/_TA_Battlefield/`）

| 关键词 | 优先打开 | 通常不要动 |
|---|---|---|
| 草场入口 | `Art/Script/Runtime/Grass/GrassFieldDriver.cs` | 每帧 new Buffer |
| 单草种 | `Art/Script/Runtime/Grass/GrassSpeciesContext.cs` | — |
| 生成 compute | `Art/shader/Grass/GrassCS.compute` | 硬编码 kernel 0 |
| 草 shader | `Art/shader/Grass/grass.shader`、`GrassCommon.hlsl` | 普通 URP Lit |
| 叶结构 | `Art/shader/Grass/GrassBladeStruct.hlsl` | 只改 C# stride |
| Stream / Renderer | `Art/Script/Share/GeneratedInstanceStream.cs`、`ScatterInstanceRenderer.cs` | Renderer 拥有生成 Buffer |
| Scatter 入口 | `Art/Script/Runtime/Scatter/ScatterFieldDriver.cs` | Domain 写进 Renderer |
| 曲线 PCG | `Art/Script/Runtime/GPUScatter/` | 并进 GrassFieldDriver |
