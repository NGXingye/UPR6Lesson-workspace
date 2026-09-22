# 草地生成

GPU 在显存里生成实例，CPU 不回读每根草的坐标。布局见 `contract.md`。

## 入口

`GrassFieldDriver`：收地形、切瓦片、视锥、生成缓存、逐草种编排。  
`GrassSpeciesContext`：每草种/变体持有 Stream、模板 Renderer、clump/voronoi，提交 DrawRequest。  
`GrassGenerationParameterBinder`：写 Compute 参数并 Dispatch。

```text
Update:
  Interaction → UpdateRenderState
  if NeedsRegenerate: UpdateTiles + DispatchAll

LateUpdate:
  每草种 Render → CopyCount → DrawProceduralIndirect
```

生成只在相机跨位移/转角阈值（或配置/地形变更）时重跑。

## 两类模板

- **A**：贝塞尔程序草，`GrassMesh.CreateGrassMesh`，`_UseRigidMeshInstance=0`
- **B**：外部模型刚性实例，`_UseRigidMeshInstance=1`；Y-up 修正、贴地、上半部分风摆

同草种多变体共用 seed，摆放一致、CDF 不重叠。B 类缺 voronoi 用白贴图均匀散布，不是错误。

## 地形表面

`IGrassSurface` 向 compute 提供世界范围 + 高度图 + 权重图。现有 `UnityTerrainSurface` 与 `MeshTerrainSurface`。新地形类型只加接口实现，不要改 Driver/Context 编排。

权重层与草种解耦：每草种绑 map + 通道 + 值域。重叠区域混合生长；要互斥就画不重叠通道。

## 容量

候选容量按可见 Tile 估算，受 `GrassSpeciesAsset.maxInstanceCapacity` 限制。GPU `acceptedCounterBuffer` 原子截断。超预算应改密度/上限，不要放大 stride 公式。

## 作者工具

`Procedural/GrassTerrainBuilder.cs`：噪声或已有高度图 → 预览 → 写 Unity Terrain 或位移网格 + `GrassMeshTerrain`。网格无高度图时用 `GrassMeshTerrain` 烘焙，不经过 Builder。
