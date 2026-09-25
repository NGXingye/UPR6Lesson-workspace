# UPR6Lesson-workspace

单人控制面，用来开发并逐渐接上 3D 大世界：海洋、草地、体积天空。

| 项 | 值 |
|---|---|
| 控制面 | `E:\unity-p\UPR6Lesson-workspace` |
| 源码 | `E:\unity-p\UPR6Lesson` |
| Unity | 6000.3.18f1 |
| 打开 | `active.code-workspace` |

不要把 Unity 工程挂进这个 workspace。结构化状态用 YAML，知识用 Markdown。

## 怎么读

1. `project_cursor.yml` 看当前模块
2. `project_index.md` 或 `modules.yml` 找索引
3. 只打开 `docs/<module>/_index.md` 里点名的那一个文件
4. 跨系统先 `docs/world/foundation.md`（分层），再 `connections.yml`（接线）
5. 写文档读 `global_rules/md_governance.md`；写代码读 `global_rules/code_governance.md`

可写范围在 `profiles/*.yml`。

## 提交

远程是 SSH：`git@github.com:NGXingye/UPR6Lesson-workspace.git`。不要用 HTTPS，不要让 Git Credential Manager 弹 Google。

```powershell
.\tools\git_guard.ps1 -Message "这次改动的原因"
```

只推已有提交：`.\tools\git_guard.ps1 -PushOnly`。私钥在本机 `~\.ssh\upr6_github`。

## 模块

| 模块 | 索引 | 状态 |
|---|---|---|
| ocean | `docs/ocean/_index.md` | 已有源码 |
| grass | `docs/grass/_index.md` | 已有源码 |
| sky | `docs/sky/_index.md` | 未开工 |
| world | `docs/world/_index.md` | 接线契约 |
