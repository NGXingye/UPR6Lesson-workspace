# 草地契约

改 `GrassBlade`、dispatch 顺序、交互结构或 Scatter payload 前必读。海洋 FFT 与本系统无关，不要塞进散布框架。

路径前缀：`Assets/_TA_Battlefield/Art/`。

## 草叶 Stride

| 结构 | 大小 | 必须同步 |
|---|---|---|
| `GrassBlade` | 18 floats = 72B | `shader/Grass/GrassBladeStruct.hlsl` 与 `GrassSpeciesContext.BladeStride` |
| Clump | 10 floats | compute 与 C# clump buffer |
| Interactor | 5 floats = 20B | `GrassInteraction.hlsl` **和** `GrassTrample.shader`（两边各有一份） |
| Indirect args | 4 ints | Stream |
| ScatterInstance | 16 floats = 64B | `shader/Scatter/ScatterInstance.hlsl`、`AABBScatter.compute`、`ScatterDemo.shader`、`ScatterModelAsset.ScatterInstanceStride` |

漏改任一处会错位或崩溃。

## 生成 Dispatch 顺序

`DispatchAll` 必须：

```text
ApplyFrame(相机/VP)          # Field，一次
for each 草种:
    EnsureGenerationCapacity
    ResetCounter             # 该草种任何 Dispatch 之前
    ApplySpecies
    for each 可见 tile:
        DispatchTile
```

Compute 参数写在同一份 ComputeShader 可变态上，所以必须草种外层循环，否则互相覆盖。Kernel 按名称缓存 `CSMain`，不要写死 kernel 0。

共享着色和交互在 `UpdateRenderState()`，位于 `NeedsRegenerate()` 之外。生成缓存可以跳过 Compute，但不能跳过风、颜色、交互刷新。

## 静态生成 vs 顶点动态

```text
GrassCS.compute（按需）→ Append GrassBlade（根位置/形态/朝向）保持不变
每帧 Draw → grass.shader 顶点用 _Time / 风 / Interactor / Trample 算最终位置
顶点不回写 GrassBlade
```

会动的效果必须放顶点或场 Texture。需要每实例速度/寿命/碰撞才进独立 Simulation Compute。

## 绘制

同一 `InstanceDrawRequest` 供 Forward、ZPrepass、ShadowCaster。`_RenderBuffer` 走 MPB。禁止某一 Pass 另拿一份 Buffer。

`ScatterInstanceRenderer` 只借 Request，不拥有生成 Buffer，不做 CopyCount，不懂地形/SDF 规则。

## 运行时禁令

- 多个 Field 禁止 `Shader.SetGlobal` 抢写 Interactor/Trample。
- 编辑器 `OnEnable` 仅 `isPlaying` 时分配 GPU。
- 热路径不 `new`。`runtimeMaterial` 是 `new Material(source)`，Dispose 时 Destroy。
- 草种 SO 用普通 `ScriptableObject`，禁止 Odin `SerializedScriptableObject`。
- 模板 Mesh 必须 `Read/Write Enabled`；指定了 Mesh 却不可读时要报错停建，禁止静默变 Cube。
