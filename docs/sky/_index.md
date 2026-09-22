# 体积天空模块索引

状态：planned。尚未建源码目录。配置：`profiles/sky.yml`。

本模块以后提供大世界的大气、体积云、日夜与环境光。海洋反射、草地 SSS/云影应消费本模块输出，而不是各自做一套天空。

| 何时打开 | 文件 |
|---|---|
| 未开工，只看边界 | 本文 |
| 与海洋/草地如何接线 | `../world/_index.md`、`../world/connections.yml` |

## 预定职责

- 大气散射 / 体积云（raymarch 或等价）
- 太阳/月亮方向、时间、环境辐照
- 给海洋：天空颜色、反射探针或天空立方体
- 给草地：云影方向/强度（现在 GrassSharedShading 里有云影参数，将来应接到本模块）

## 禁令

- 不要把体积云写进 Scatter/Grass 框架（C 类，独立系统）
- 不要在海洋 Shader 里再实现第二套大气
- 开工前先在 `modules.yml` 把 status 改为 `active`，并补 `allowed_write`

源码路径待定，不要在 `Assets/` 里散建天空实验文件夹而不登记 profile。
