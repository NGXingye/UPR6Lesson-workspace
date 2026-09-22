# 草地渲染

生成结果经间接绘制提交。Renderer 不负责 Domain/Placement。

## 草

`grass.shader` 只 include `GrassCommon.hlsl`，后者按序：

| 文件 | 内容 |
|---|---|
| `GrassData.hlsl` | CBUFFER、`GrassBlade`、buffer/贴图声明 |
| `GrassMath.hlsl` | 贝塞尔、罗德里格斯、HSV |
| `GrassWind.hlsl` | 全局风 |
| `GrassInteraction.hlsl` | Interactor + trample 采样 |

shader 必须先 include URP Core/Lighting/Shadows，再 include `GrassCommon`。

公共着色唯一来源：`GrassSharedShadingProfile`（风、云影、SSS、高光、Contact AO、阴影）。源材质同名属性运行时会被 Binder 覆盖。Albedo/Alpha/Normal/ARM 留在源材质面板，不要复制进 SO。

颜色覆盖顺序：Shared → Species → Variant。

A/B 目前在顶点里 `if (_UseRigidMeshInstance)` 分支，未拆 shader_feature。

`GrassZPrepassFeature` 与 Forward 共用同一 Request。Unity 6 的 `DrawProceduralIndirect` 已弃用，功能仍可用，迁移见 `roadmap.md`。

不能把草材质直接换成普通 URP Lit：没有 `_Triangles/_Positions/_RenderBuffer` 契约。

## 调试

`GrassDebugOverlay` 只读 Contexts，切可视化模式。不要把 debug 写进 Driver 热路径。`DebugBufferCount` 禁止每帧 new/release ComputeBuffer。
