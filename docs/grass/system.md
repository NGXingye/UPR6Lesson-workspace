# 草地系统边界

代码在 `Assets/_TA_Battlefield/Art/Script/` 与 `Art/shader/`。目前无独立 asmdef；命名空间已按模块分。打包成插件时再加 asmdef，并保证运行时零 Odin API。

## 职责

| 模块 | 做 | 不做 |
|---|---|---|
| `GrassFieldDriver` | 地形、瓦片、缓存、编排 | 单草种 buffer 细节 |
| `GrassSpeciesContext` | Stream、Renderer、DrawRequest | 帧全局状态 |
| `GrassGenerationParameterBinder` | Compute 参数 + Dispatch | Buffer 生命周期 |
| `GrassRenderParameterBinder` | Shared/Color/Interaction → runtimeMaterial | 创建材质、生成实例 |
| `GeneratedInstanceStream` | Append + Args + CopyCount | Mesh、材质、Draw |
| `ScatterInstanceRenderer` | 模板 Buffer、间接绘制 | 生成、CopyCount、业务规则 |
| `IGrassSurface` | 高度图 + 权重图 | 瓦片/dispatch |
| Config / Species / ShadingProfile SO | 纯数据 | GPU 生命周期 |

谁 `new` ComputeBuffer，谁 `Release`。Context.Dispose：先 Renderer，再 Stream。Interactor/Trample 在 Driver.OnDisable 释放。

## 加参数

- 生成参数：`GrassSpeciesAsset` → `ShaderIDs` → `ApplySpecies` → compute
- 公共着色：`GrassSharedShadingProfile` → `ShaderIDs` → `ApplyShared` → shader
- 草种颜色：`GrassSpeciesAppearance`，Shared → Species → Variant
- 每叶属性：改 Stride 两处 + compute Append + 顶点读取
- 动态效果：Field Runtime/Texture → Render Binder 每帧绑 → 顶点；不进静态 buffer，不用 Shader Global

## Odin

Inspector 可用，且用 `#if ODIN_INSPECTOR`。运行时 SO 不要 `SerializedScriptableObject`。Unity 6 上避免 `[InlineEditor]`（`FitWindowRectToScreen` 崩溃）。
