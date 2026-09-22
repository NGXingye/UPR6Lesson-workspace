# 大世界地基

长期项目的冻结层。改本文件或改 `connections.yml` 的 owner / `do_not_merge` / 管线后端，等于改地基，必须显式讨论。

视觉北星是开放世界合成图：大气、岸线、水面、散布、太阳方向一致。那不是单模块画质，也不是自研 SRP 才能达到。

## 分层（下稳上开）

对齐引擎分层。渲染不是第四层玩法，而是横切：每层都可以有渲染，但**玩法不能拥有渲染状态**。

| 层 | 本工程落点 | 开放度 | 允许改什么 |
|---|---|---|---|
| 平台 | Unity 6 + URP Forward+（`Assets/Settings/PC_Renderer.asset`） | 冻结 | 升级 Unity/URP；禁止 fork 包、禁止自研 SRP |
| 核心 | GPU 契约、ShaderIDs、RT 寿命、数学库、只读 Outputs | 契约冻结 | 实现可换；布局变更走模块 `gpu_contract` / `contract` |
| 资源 | `Scripts` / `Art` / `Content` 分离与加载（`assets.md`） | 中 | 加资源与预设；Config 不持有运行时 RT；无 git 不大搬家；不用 `Resources/` |
| 渲染功能 | `sky` / `ocean` / `grass` / 地形 | 契约冻结，画质开放 | 模块内迭代着色；跨模块只改 `connections.yml` |
| 玩法功能 | 角色、船、任务、规则 | 开放，后做 | 只消费世界服务，不写 FFT Buffer / 草生成 Buffer |
| 工具 | Odin Inspector、调试视图、Editor | 最开 | 不能成为运行时真相来源 |

自定义管线 = **URP 上的模块 Pass / Renderer Feature**。不是换后端，不是 HDRP 寄生。

## 先冻契约，再渲染，再玩法

顺序是契约 → 渲染 → 逻辑，不是「渲染全部做完才允许玩法」。

1. **现在锁死**：谁拥有相机、时间、风、高度、环境光；Pass 顺序；禁止合并项。权威文件：本文件 + `connections.yml`。
2. **第一期渲染**：补 `sky`（太阳、大气、雾、环境辐照），再改海洋介质与岸线共用高度。参考图里 70% 观感来自大气和太阳，不是海面 GGX。
3. **第二期逻辑**：浮力、踩草、船、任务读同一套 Viewer / 高度 / 风。玩法代码不准直接改 Shader 全局或模拟 RT。

单模块任务不要把玩法参数塞进环境 Shader。跨模块先改 `connections.yml`。

## 渲染功能怎么拆

每个环境系统内部再分成三截，禁止混成一个上帝 Shader：

```text
Simulation（可离屏）→ Surface data（全分辨率）→ Lighting / Volume（可降分）→ Composite（全分辨率）
```

| 系统 | Simulation | Surface | Lighting / Composite |
|---|---|---|---|
| ocean | FFT Driver → `OceanSimulationOutputs` | Clipmap + 法线/泡沫 | 介质 + Fresnel + 折射；大气只采样 sky |
| grass | 生成 Compute / Scatter | 实例 Buffer | 草 Shader；云影只采样 sky |
| sky | 时间 / 大气参数 | 天空几何或 LUT | 大气/体积云/雾；输出给海和草 |

海洋光学以后若加半分辨率体积 Pass，只换 Lighting 实现，不改 FFT 契约，不改 URP 后端。

## Pass 顺序（冻结）

CPU 与 GPU 都按这个因果，新系统插入时登记 `connections.yml`：

```text
Viewer / Time / Wind
  → Ocean FFT、Grass 生成
  → Opaque：地形、草、建筑
  → Sky / 大气 / 雾        （planned，透明水之前）
  → Copy Depth + Opaque Color
  → Ocean 表面（折射、反射、介质）
  → Overlay / UI
```

禁止：海面先画再让天空读海面当大气；草 Shader 内做体积云；海洋 Shader 内做第二套大气。

## 世界服务所有权（冻结）

与 `connections.yml` 一致。未实现也先占位，禁止临时另立 Owner。

| 服务 | Owner | 消费者 | 未实现时 |
|---|---|---|---|
| Viewer / Camera | world | ocean Clipmap、grass 瓦片 | 禁止新系统再猜 MainCamera |
| Time of day / 太阳 | sky | ocean 反射、grass SSS | 本地方向灯可暂用，禁止海/草各自做太阳盘 |
| Wind | world | grass 顶点风、ocean JONSWAP | 本地参数可暂用，禁止草风写入 FFT Buffer |
| Terrain height | world | 岸线、草权重、Bathymetry | 两套高度必须标冲突，不能假装已统一 |
| Lighting environment | sky | ocean 反射、grass 云影 | 探针/主光可暂用 |
| Interaction | 各模块 Outputs | 玩法 | 草 Interactor 与海浮力只发布，不互相调用内部 |

## 视觉北星怎么落到模块

参考图不是海洋任务，是合成验收：

| 图中现象 | 负责模块 | 不负责 |
|---|---|---|
| 太阳、体积雾、霞光、天空反射源 | sky | ocean 里写大气 |
| 平静水面、长镜面、岸线湿沙 | ocean + 共用高度 | 为平静水面另做一套 FFT |
| 花田 / 树 / 地被 | grass / Scatter | 把花做成海洋泡沫 |
| 山体、海岸线形状 | world 地形 | Bathymetry 当碰撞 |
| 全图光照一致 | sky → 各消费者 | 每个 Shader 自己调一张黄昏色 |

海况是 Config（风暴 / 近岸 / 湖泊），不是新模块。

## 门禁

- 新环境系统：先 `modules.yml` + `profiles/<id>.yml` + `docs/<id>/_index.md`，再写代码。
- 跨模块数据：只经 `connections.yml`。禁止 Shader.SetGlobal 当多系统总线。
- 改 compute/shader 前备份；本工程无 git。
- 改平台后端（URP → HDRP / 自研 SRP / 全工程 Deferred）必须先改本文件，再改 `Assets/Settings`。
- 玩法层需要高度、风、浮力时，加 consumer，不抄一份模拟。
- 新文件落 `docs/world/assets.md` 的 `Scripts` / `Art` / `Content` / `Shaders`。加载后端未到 P2 时禁止自写调度器与 Unity `Resources/` 总线。
