# 文档导航

本文件是控制面受管理文件的入口。冷启动读完 `AGENTS.md` 和 `project_cursor.yml` 后来这里，不要通读所有 md。

机器目录：`modules.yml`。当前任务：`project_cursor.yml`。模块边界：`profiles/*.yml`。

## 读取顺序

1. `AGENTS.md`（已注入则跳过）
2. `project_cursor.yml` — `active_module` 决定下一步
3. `modules.yml` — 只在找模块或新加系统时
4. `profiles/<id>.yml` + `docs/<id>/_index.md`
5. 索引表里的那一个知识文件
6. 跨模块：先 `docs/world/foundation.md`（改地基时），目录/加载加 `docs/world/assets.md`，再 `docs/world/connections.yml`
7. 新建控制面文档：`global_rules/md_governance.md`
8. 写 C#/HLSL：`global_rules/code_governance.md`
9. 超规：`global_rules/violation.md`（按表改，收工再报；做不到才 `blocked`）

`active_module` 为 `none` 时允许只读；改源码前先把游标写成对应模块。

## 根文件与一级目录

| 文件 | 用途 |
|---|---|
| `AGENTS.md` | 全局硬约束 |
| `project_cursor.yml` | 当前模块 |
| `modules.yml` | 模块目录 |
| `profiles/` | 可写路径 |
| `global_rules/` | 文档法、源码地板、超规处置 |
| `standards/source_code_map.md` | 关键词 → 模块 |
| `docs/` | 模块知识 |
| `docs/world/vcs.yml` | 仓库边界与提交名单 |
| `tools/git_guard.ps1` | 控制面提交门卫 |
| `active.code-workspace` | 只挂控制面 |

## 模块

| id | 索引 | 状态 |
|---|---|---|
| ocean | `docs/ocean/_index.md` | active |
| grass | `docs/grass/_index.md` | active |
| sky | `docs/sky/_index.md` | planned |
| world | `docs/world/_index.md` | active |

每个模块目录必须有 `_index.md`。知识用 md；路径、状态、接线用 yml。
