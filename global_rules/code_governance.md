# 源码地板

写 C# / HLSL / compute 时的共同习惯。架构看 `docs/world/foundation.md`。打包、stride、Dispatch 看当前模块契约，不要抄到这里。

**从新文件、以及这次改到的文件生效。** 不为贴合本文件去重构未打开的海洋/草地。

## 命名

- 类型、方法、属性、常量：PascalCase。序列化字段：camelCase。局部变量：camelCase。
- Shader / 材质属性：`_UnderscoreName`，C# 侧只通过该模块 `*ShaderIDs` 的 `PropertyToID`。
- 标识符英文。禁止拼音混拼。Inspector 中文用 Odin `LabelText`，不要靠把字段改成中文名。
- 命名空间跟模块：海洋 `FFTOcean`；草地新代码用模块名（如 `Battlefield.Grass`），禁止再开 `OceanQuest` 这类第三套。
- 一类一文件，文件名等于主类型名。partial：`ClassName.cs` 管生命周期，`ClassName.Feature.cs` 禁止写 `Awake/Update/OnDestroy`。

## 权威源与数据驱动

- 可调参数进 ScriptableObject。组件只挂 Config 引用和生命周期。禁止模拟过程改 SO 内数组。
- 缺 Config 就报错停止，不要暗默第二套默认值。
- 契约数字（分辨率、stride、Cascade 数）进共享常量或 Config，禁止在 Driver 里再写一份。
- 新 GPU 属性：HLSL 声明 → 模块 `*ShaderIDs` → Binder。禁止散写 `"_Xxx"`。
- 谁 `new` RT/Buffer，谁释放。跨模块只走 `OceanSimulationOutputs` / 草 Stream 这类只读句柄，禁止 `Shader.SetGlobal` 当总线。
- Odin 只做 Inspector。运行时算法不得调 Odin API；草种 SO 禁止 `SerializedScriptableObject`。

硬编码：契约写死（如 IFFT 1024）合法，但只能有一处定义。非法的是同一数字在 C#、HLSL、材质面板不一致。

## 注释

中文只写为什么、契约、坑。禁止给 `DisplacementTexture` 再加 `//位移纹理` 这种翻译。公开类型用短 `/// <summary>`。不要注释掉整段作废代码。

## 文件体量

只要软上限，不要下限。接口、IDs、结构体本来就短。

| 种类 | 软顶 | 硬顶 | 超出时 |
|---|---:|---:|---|
| Runtime `.cs` | 400 | 600 | 按 Feature partial 拆 |
| Editor `.cs` | 400 | 600 | 同上 |
| `*ShaderIDs` / 常量 / MathLib | — | — | 不按业务文件卡 |
| `.compute` / 大 HLSL | — | — | 按模块契约拆 kernel/include，不按行数硬切 |

## 超规

按 [`violation.md`](./violation.md) 改，收工再报。正在改的文件按 Feature partial 收口；未点名遗留只记 roadmap。禁止抬硬顶、复制一份类过关。

## 不要做

- 不要在本文件展开 SOLID/DDD。
- 不要为「每文件必须够长」去合并小文件。
- 不要把玩法参数写进环境 Shader；玩法只消费 Outputs / 世界服务。
