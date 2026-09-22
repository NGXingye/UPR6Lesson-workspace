# 文档法

控制面怎么写文件。不保存任务状态，不含 C# 细规。

## 两种格式

| 格式 | 写什么 | 例子 |
|---|---|---|
| YAML | 状态、路径、接线、可写范围 | `modules.yml`、`profiles/*.yml`、`project_cursor.yml`、`connections.yml` |
| Markdown | 因果、契约说明、索引 | `AGENTS.md`、`*_index.md`、`docs/**`、本文件 |

禁止再引入 JSON 清单。同一事实禁止 YAML 与 Markdown 各抄一份；目录以 `modules.yml` 为准，边界以 `profiles/<id>.yml` 为准。

## 文类

| 文类 | 路径 | 职责 |
|---|---|---|
| 硬约束 | `AGENTS.md` | 短禁令 |
| 导航 | `project_index.md`、`*/_index.md` | 路径与读取时机 |
| 文档法 | 本文件 | 如何建文档 |
| 源码地板 | `code_governance.md` | 如何写代码 |
| 游标 / 配置 | `project_cursor.yml`、`profiles/`、`modules.yml` | 现在 / 模块边界 |
| 架构 | `docs/world/foundation.md` | 分层与 Pass |
| 接线 | `docs/world/connections.yml` | owner / consumer |
| 模块知识 | `docs/<module>/` | 该系统契约与路线 |

创建前选唯一文类。跨文类只链接。

## 建文件五问

不明则不建。同批完成文件、索引登记、`modules.yml`/`profiles`（若是新模块）。

1. 唯一职责是什么？
2. 谁在什么时机读？
3. 为什么不能并进已有文件？
4. 属于上表哪一文类？
5. 登记到哪一份 `_index.md`？

## 读取

打开 md：先扫一级标题，再读相关节，禁止默认通读目录。冷启动走 `project_index.md`。每个受管理目录必须有 `_index.md`，只登记直接子级。

## 超规

按 [`violation.md`](./violation.md) 改，收工再报。禁止临时 md、抬上限。

## 防爆炸

- 不写日报、任务副本、`v2`/`final` 文件名。
- 不设四行版头和版本历史仪式。
- 知识文件偏长时拆到模块内并在 `_index` 挂链接，禁止把 L0（`AGENTS.md`、冷启动 rule）写长来换说明。
- 架构不抄进模块文档；模块不把 Pass 顺序再写一遍。
