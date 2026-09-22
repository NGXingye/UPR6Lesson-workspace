# 大世界连接索引

状态：active（契约层）。源码尚未做成独立 World 程序集。配置见 `connections.yml`。

改两个以上模块、或加新环境系统时先读这里。单模块任务不要展开本目录。

| 何时打开 | 文件 |
|---|---|
| 分层、管线后端、冻结门禁 | `foundation.md` |
| Assets 目录、FBX 提取、命名 | `assets.md` |
| 第三方插件清单 | `third_party.yml` |
| 两个仓库、提交白名单 | `vcs.yml` |
| 模块如何接线、共享什么 | `connections.yml` |
| 场景 / 相机 / URP 落点 | 本文「当前工程」 |

## 当前工程

| 项 | 路径 |
|---|---|
| 主战场场景 | `Assets/_TA_Battlefield/Scenes/TA_Terrain_Battlefield.unity` |
| 海洋运行时 | `Assets/FFTOcean/` |
| 草地 / Scatter | `Assets/_TA_Battlefield/Art/Script/`、`Art/shader/` |
| URP | `Assets/Settings/` |
| 资源骨架 | `Assets/Scripts` `Art` `Content` `Shaders`；旧代码仍在 `FFTOcean/` 与 `_TA_Battlefield/` |
| 未提取美术 | `Assets/Art/park/` |

## 已连接 / 未连接

| 共享概念 | 现状 | 目标 |
|---|---|---|
| 地形高度 | 草用 `IGrassSurface`；海用 Bathymetry + Camera Depth | 同一套世界高度，岸线与草权重对齐 |
| 风 | 草顶点风；海 `timeScale`/风向 JONSWAP | 世界风场，两套只采样 |
| 时间 / 天空 | 无天空模块 | sky 输出太阳与环境，海/草只读 |
| 相机 | 各模块自己找 Viewer | 统一 Viewer/Camera |
| 交互 | 草 Interactor；海浮力未接线 | 角色同时踩草、吃浮力 |
| 执行顺序 | 海 `-100`；草 Update/LateUpdate | 登记在 `connections.yml`，新系统按序插入 |
