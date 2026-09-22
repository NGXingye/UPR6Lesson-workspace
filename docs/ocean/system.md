# 系统

资源所有权和配置归属。具体 GPU 布局见 `gpu_contract.md`。

## 程序集

| 程序集 | 路径 | 职责 |
|---|---|---|
| `FFTOcean.Runtime` | `Assets/FFTOcean/script/FFTOcean.Runtime.asmdef` | 根命名空间 `FFTOcean`；引用 URP Runtime 与 Odin Attributes |
| `FFTOcean.Editor` | `Assets/FFTOcean/Editor/FFTOcean.Editor.asmdef` | 只引用 Runtime |

一类一文件。Clipmap 用 partial：主文件管生命周期，功能文件 `ClassName.Feature.cs`，禁止在功能文件写 `Awake/Update/OnDestroy`。平面反射、涟漪、Gizmo 不要并进 Clipmap partial。

## 配置三分

配置是只读输入，不保存运行时 RT/Mesh。JONSWAP 数组要克隆，禁止模拟过程改 SO 内数组。缺 Config 就停止初始化并报错，不要暗默默认值。

| SO | 负责 | 不负责 |
|---|---|---|
| `OceanSimulationConfig` | Compute、频谱、Cascade、动画、Assemble/Foam | 场景 Transform、运行时 RT |
| `OceanClipmapConfig` | 网格尺寸、密度、LOD、裙边、位移 Bounds 填充 | Viewer、运行时 Mesh |
| `OceanSurfaceConfig` | 水面材质、光学、LUT、外观向白沫/细节法线（目标） | `waveSharp` 与 Foam Compute 参数 |

Odin 只用于 Config Inspector（`LabelText` / `TitleGroup` / `MinValue` / `PropertyRange`）。算法和资源生命周期不得调 Odin API。范围安全靠 `OnValidate/Sanitize`，不能只靠面板特性。不要给 Config 再写 CustomEditor。

新增 Shader 参数：HLSL → `OceanShaderIDs` → Binder 走 MPB。不要在材质面板留第二套运行时默认值。

## 输出所有权

Driver 创建并释放全部模拟 RT/Buffer。`OceanSimulationOutputs` 只暴露句柄、`IsReady`、`Version`。Renderer 用 MaterialPropertyBlock，不写无 Owner 的全局 Shader 状态。

反射正式化时同样：`Config` + 只读 `Outputs` + 目标 Renderer 绑定。禁止 `Shader.SetGlobalTexture` 当多海面/多相机的传输。

## 放置

```text
Assets/FFTOcean/script/Data/      Config SO
Assets/FFTOcean/script/Share/     IDs、常量、结构体
Assets/FFTOcean/script/Runtime/Simulation/
Assets/FFTOcean/script/Runtime/Rendering/
Assets/FFTOcean/shader/           Compute + Surface HLSL
Assets/FFTOcean/Editor/
Assets/FFTOcean/Config/           .asset
```

`script/Buoyancy*.cs` 仍在 Runtime 目录外、且命名空间不同，接线时再归位。

不要把已删除的 `OceanWater` / `CustomLighting` / `SamplerTex` 加回 Runtime。
