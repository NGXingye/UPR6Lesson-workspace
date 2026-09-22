# 资源与目录地基

物理落点、命名、加载、美术源与二进制。管线分层见 `foundation.md`。Owner 见 `connections.yml`。

改本文件的目标根或加载后端，等于改地基。**先定约定，禁止无 git 大搬家。**

## 不要用 Unity 的 `Resources/` 当地基

`Assets/**/Resources/` 是引擎保留目录：里面的东西**整包打进包体**，不会按引用剥离，字符串路径也没有依赖分析。这和「方便后面打包」相反。

运行时要加载的东西放 `Content/`，名字不要叫 `Resources`。打包走引用图 → 以后 Addressables 分组，不走 `Resources.Load`。

## 三根轴，不要压成一层文件夹

| 轴 | 先分什么 | 给谁用 |
|---|---|---|
| 工作区 | `Scripts` / `Art` / `Content` / `Shaders` | 人、导入管线、播放器 |
| 寿命 | Static 常驻 / Dynamic 可卸 | 加载器、以后的包分组 |
| 种类 | Config、Textures、Materials、Meshes、Prefabs、Binary | 导入设置、压缩 |
| 模块 | World、Ocean、Grass、Sky、Gameplay | 所有权，最后一层 |

静态/动态不是和贴图并列的「大类」，是寿命。贴图/材质/预制体是种类。FBX 源文件不是运行时种类。

```text
Assets/
  Settings/              平台：URP。不动
  ThirdParty/            第三方。禁止写游戏代码
  Scripts/               全部游戏代码（方便 asmdef 剥离）
    Runtime/             进包
      World/ Ocean/ Grass/ Sky/ Gameplay/
    Editor/              工具、导入、调试窗；玩家包自动剔除
    Debug/               仅 DEVELOPMENT_BUILD，默认不进发行
  Shaders/               着色器与 include；按模块子目录
    Ocean/ Grass/ Sky/ World/
  Art/                   美术源，不给运行时直接 Load
    Incoming/            外部丢进来的 FBX/PSD/原始图
    Processed/           导入处理后的网格/贴图（缩放、轴、LOD、材质拆出）
  Content/               运行时加载的处理结果（子目录全小写，与加载键一致）
    static/              常驻：启动就在，不卸
      config/
      textures/
      materials/
      meshes/            仅独立 .asset；蒙皮网格留在 Processed FBX
      prefabs/
      animations/
      binary/            烘焙数据，不是设计师源
    dynamic/             调度器可加载/卸载
      textures/ materials/ meshes/ prefabs/ animations/ binary/
        world/ ocean/ grass/ sky/ gameplay/
  StreamingAssets/       仅真要绕过 Unity 导入的字节（可选）
```

种类之下再按模块分，避免 `Content/static/textures` 里海洋和草地贴图重名、所有权不清。

## 代码为什么统一进 `Scripts/`

玩家包剔除看的是 **asmdef + Editor**，不是看资源文件夹。脚本集中后：

- `*.Runtime.asmdef` 进包，模块互相引用可见
- `*.Editor.asmdef` 只引用 Runtime，发行包没有
- `Debug` 用独立 asmdef，发行定义里关掉

禁止再把 `.cs` 放进 `Art/`、`Content/`、`Assets/Editor`（无模块）。SO **类型**在 `Scripts/Runtime/<Module>/Data/`（PascalCase）；`.asset` **实例**在 `Content/static/config/<module>/`（小写文件名）。

## 美术源与运行时必须分开

外部 FBX 不是能 Load 的资源。

```text
美术丢入 Art/Incoming/<module>/<static|dynamic>/<name>/
  → 菜单提取（不是默导自动 Postprocessor）
  → Art/Processed/<module>/<static|dynamic>/<name>.fbx
  → Content/<lifetime>/<kind>/<module>/
```

| 放哪 | 什么 | 进玩家包？ |
|---|---|---|
| `Art/Incoming` | 原 FBX/PSD/旁路贴图 | 否。场景和 Prefab 禁止直接引用这里 |
| `Art/Processed` | 处理后的 FBX（网格、骨骼仍在这里） | 仅当 Content Prefab 引用到才进 |
| `Content/**` | 提取出的材质/贴图/预制体 | 按 static/dynamic 分组 |

`Art/` 不是「所有贴图的根」。进包贴图在 `Content/.../Textures`。Incoming 里的 PNG 只是源。

### Incoming 路径就是提取参数

```text
Art/Incoming/<module>/<static|dynamic>/<name>/<name>.fbx
Art/Incoming/<module>/<static|dynamic>/<name>/<name>_d.png   可选旁路贴图
```

- `module`、寿命、`name` 只从路径读，不靠对话框猜。路径必须全小写，不合规直接失败。
- 寿命文件夹只允许 `static` 或 `dynamic`。
- `<name>` 是资源身份本体：`[a-z0-9_]+`，例如 `cliff_full_01`。不加类型前缀。
- 同目录旁路贴图只用槽位后缀（`_d` `_n` `_orm`），提取器拷到 Content 并规范化文件名。
- Incoming 若收到混合大小写，提取器拒绝或只规范化输出到 Content；**不要**在 Content 里保留两种大小写。

现有 `FFTOcean/Art/Cliffs` 仍算旧包；新丢的 FBX 必须走 Incoming。

### 提取器契约（尚未写代码）

落点：`Scripts/Editor/World/FbxContentExtractor.cs`，程序集 `World.Editor`。菜单：`UPR6/Art/Extract FBX To Content`。Owner：world。

对选中的 Incoming FBX（或选中文件夹内全部 FBX）做一次、可重复：

1. 校验路径 `incoming/<module>/<static|dynamic>/<name>/`（相对 Art）。
2. 复制 FBX 到 `Art/Processed/<module>/<static|dynamic>/<name>.fbx`；已存在则覆盖网格、**保留 .meta GUID**。
3. 抽出内嵌贴图 + 拷贝旁路贴图 → `Content/<lifetime>/textures/<module>/<module>_<name>_<slot>`。
4. 抽出材质、转 URP、贴上已抽出贴图 → `Content/<lifetime>/materials/<module>/<module>_<name>`。不要把 FBX 内部嵌材质留给运行时。
5. 有动画则抽出 → `Content/<lifetime>/animations/<module>/<module>_<name>_<clip>`。
6. 生成或更新预制体 → `Content/<lifetime>/prefabs/<module>/<module>_<name>.prefab`，引用 Processed FBX 的网格 + Content 材质。这是运行时唯一入口。
7. **默认不把 Mesh 抽成独立 .asset**。只有无骨骼且要拆子物体时才写 `meshes/`。
8. 写完出清单（源路径 → 加载键）。第二次提取覆盖同名产物、不改 GUID、不删未覆盖的旧变体。

禁止：

- `AssetPostprocessor` 默认一导入就提取。
- 场景直接拖 Incoming 或 Processed FBX；只拖 `Content/**/prefabs` 里的预制体。
- 提取器改 `ThirdParty/`、改 Shader 源、改 Config SO。
- 在材质里写死 `Hidden/InternalErrorShader` 还当成功。
- 给文件加 `t_` `m_` `p_` 这类类型前缀。

Importer 在 Processed FBX 上固定：米制、Bake Axis、静态生成 Lightmap UV、默认关 Read/Write；Dynamic 蒙皮才开 Read/Write。材质 Location = External，指向 Content 里那份。

开工写脚本前：`profiles/world.yml` 把 `Scripts/Editor/World` 列入 `allowed_write`，并先有 git。

## 加载目标（寿命优先）

Owner：world。`connections.yml` 的 `content_loading`。

```text
键：{lifetime}/{kind}/{module}/{name}
例：static/config/ocean/ocean_surfaceconfig
    dynamic/prefabs/grass/grass_flowerpatch_a
    static/textures/world/world_cliff_full_01_d
```

键必须全小写。`kind` 用目录名：`config|textures|materials|meshes|prefabs|animations|binary`。`name` 与文件名去扩展名相同。Windows 大小写不敏感，Android/Linux 敏感；混用大小写会在真机丢资源。

| 档 | 后端 | 何时 |
|---|---|---|
| P0 | 序列化引用（Prefab/场景拖 Config） | 现在。Static 几乎全是这个 |
| P1 | 模块内瓦片 residency | 草已有；仍不是世界加载器 |
| P2 | Addressables，**按 Static/Dynamic 分组** | 开始流式场景/地形/角色 |
| P3 | 调度器：Viewer 距离、内存预算、卸载 | 有 P2 且有内存证据 |

加载器认寿命，不认「所有贴图一个包」。Addressables Group 建议：`Static_Config`、`Static_Art`、`Dynamic_<Module>`。种类用标签，方便贴图压缩设置，不单独成为一个 Load 入口。

禁止：

- 游戏内容放进任意 `Resources/` 再用 `Resources.Load`
- Incoming FBX 当运行时路径
- 调度器 `new` 海洋/草模拟 RT
- `Shader.SetGlobal` 当资源总线
- 每个模块自己包一层 Addressables

## 配置与二进制

设计师源用 ScriptableObject（YAML）。**不要**把现有十几份海洋/草 Config 改成二进制当编辑格式。

二进制是 **烘焙产物**，放 `Content/<lifetime>/binary/<module>/`：

| 值得打二进制 | 不值得 |
|---|---|
| 高度/权重大表、散布实例表、导航、探针、流式区块 | `OceanSurfaceConfig`、草种 SO、LUT 渐变 |
| 要按 Viewer 进出的大块只读数据 | 每帧 GPU 自己生成的 RT/Buffer |

工程里已有 MemoryPack：P2 起给 Binary 用，Editor 下 SO → 烘焙 `.bytes`。运行时只读 Binary，不把 SO 当热路径。缺烘焙就当缺 Config：报错停，不准静默回退。

`StreamingAssets` 只留给必须绕过 Unity 导入的字节；能进 Addressables 的 Binary 不要改走 StreamingAssets。

## 命名

先定作用，再定格式。代码标识符仍走 `global_rules/code_governance.md`（类型 PascalCase）。这里只管 **Art / Content 磁盘名和加载键**。

### 核心作用

资源名是加载图里的**稳定身份**，只回答「这是哪一件」。

| 要编码进名字的 | 不要编码进名字的 |
|---|---|
| 谁的（module） | 类型（贴图/材质/预制体）→ 目录 + 扩展名 + 键里的 kind |
| 是哪一件（name） | 寿命 static/dynamic → 目录 + 键里的 lifetime |
| 同一件的变体（tropical、lod0） | 压缩格式、是否进包 → Addressables 分组 |
| 同一贴图的槽位（_d / _n / _orm） | |

类型前缀（`t_` `m_` `p_`）在本布局里没有独立信息：`Content/static/prefabs/world/world_cliff_full_01.prefab` 已经说明它是预制体。前缀只在「所有类型摊在同一个文件夹」时有用，我们不是那种结构。

全小写的作用是 **键在 Windows / Android / Linux / 主机上同一**，避免 `Cliff.png` 与 `cliff.png` 在编辑器能找到、真机没有。

### 格式

```text
{module}_{name}[_{variant}][_{slot}][_lod{n}]
```

- 字符集：`[a-z0-9_]`，全小写，无空格、无中文、无 `副本`。
- Incoming / Processed / Content 子目录同样全小写。
- `module` 写入文件名，避免工程搜索时 `water_n` 撞车；目录里的 module 与之一致。
- 同一逻辑件共用 stem：预制体 `world_cliff_full_01`，反照率 `world_cliff_full_01_d`。
- 槽位只出现在 textures：`_d` `_n` `_m` `_r` `_ao` `_orm` `_e` `_h` `_msk`。
- Config 实例：`ocean_surfaceconfig_tropical.asset`。C# 类型名仍是 `OceanSurfaceConfig`。
- Shader 文件在 `Shaders/` 下可保持与类型相关的 PascalCase（编译物，不是 Content 加载键）。

| 产物 | 路径 |
|---|---|
| 崖壁预制体 | `Content/static/prefabs/world/world_cliff_full_01.prefab` |
| 崖壁反照率 | `Content/static/textures/world/world_cliff_full_01_d.png` |
| 水面细节法线 | `Content/static/textures/ocean/ocean_water_detail_n.png` |
| 水面材质 | `Content/static/materials/ocean/ocean_surface.mat` |
| 热带光学配置 | `Content/static/config/ocean/ocean_surfaceconfig_tropical.asset` |
| 花丛动态预制体 | `Content/dynamic/prefabs/grass/grass_flowerpatch_a.prefab` |

加载键 = 从 `Content/` 往下、去掉扩展名：`static/textures/world/world_cliff_full_01_d`。

现有 `Oceansuf.mat` 迁入时改成 `ocean_surface.mat`。崖壁归 world，不归 ocean。

asmdef：`<Module>.Runtime` / `<Module>.Editor`。海洋命名空间仍是 `FFTOcean`，迁 `Scripts` 时再改。

## 第三方

目录目标：`Assets/ThirdParty/`。现在是 `Assets/3Party/Comm/Plugins/`。清单只放控制面 `third_party.yml`，禁止在插件目录里再写一份游戏规范。

规则：第三方只进 `ThirdParty/`；禁止改其源码来接海洋/草地；新插件先登记 yml 再导入。未接线的库（如 MongoDB）不准塞进加载热路径。

## 现状 → 目标（迁，不是装已经在目标）

| 现在 | 目标 |
|---|---|
| `Assets/FFTOcean/script` | `Scripts/Runtime/Ocean` |
| `Assets/FFTOcean/Editor` | `Scripts/Editor/Ocean` |
| `Assets/FFTOcean/shader` | `Shaders/Ocean` |
| `Assets/FFTOcean/Config` | `Content/static/config/ocean` |
| `Assets/FFTOcean/Art`、`Mateial` | Incoming 或 `Content/static/.../ocean` |
| `_TA_Battlefield/Art/Script` | `Scripts/Runtime/Grass` 等 |
| `_TA_Battlefield/Art/shader` | `Shaders/Grass` |
| `_TA_Battlefield/Art/GrassConfig` | `Content/static/config/grass` |
| `_TA_Battlefield/Art/Terrain` 等大体积 | 暂留；引用进 Content 后再说流式 |
| `_TA_Battlefield/Scenes` | 主场景 → `Content/static/scenes/world` 或暂留 |
| `Assets/Editor` | `Scripts/Editor/World` |
| `Assets/3Party` | `ThirdParty` |
| `Assets/Settings` | 不动 |

无 git 只允许**新文件**落目标。一次只迁一个 `modules.yml` 模块，并改 `profiles/<id>.yml` 的 `source` / `allowed_write`。不碰 `Library/`、地形大体积、第三方。sky 开工：先改 yml，再在 `Scripts` / `Shaders` / `Content` 下建 `Sky` 子目录，不要建 `Assets/Sky` 第三套根。
