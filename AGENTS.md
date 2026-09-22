# UPR6Lesson 控制面

源码根：`E:\unity-p\UPR6Lesson`。本仓库只保存规范、模块配置、索引与接线，不复制 Unity 工程文件。

冷启动：`.cursor/rules/upr6-cold-start.mdc`。导航：`project_index.md`。模块目录：`modules.yml`。游标：`project_cursor.yml`。文档法：`global_rules/md_governance.md`。源码地板：`global_rules/code_governance.md`。架构：`docs/world/foundation.md`。

## 硬约束

1. Markdown 只写路径、不变量、门禁。禁止把 Unity 源文件正文贴进文档。结构化状态只用 YAML，禁止再加 JSON 清单。
2. 运行事实以源码、`.asmdef`、`ProjectSettings` 为准。冲突标出来，不要用过期 md 裁决。
3. 禁止扫描 `Library/`、`Temp/`、`Logs/`、`PackageCache/` 和大体积 `Art/`。定位走 `standards/source_code_map.md` → 模块 `_index.md`。
4. 改源码前把 `project_cursor.yml` 的 `active_module` 写成对应模块，遵守 `profiles/<id>.yml` 的 `allowed_write`，并遵循 `code_governance.md`（只约束新文件和本次改到的文件）。
5. 跨模块只通过 `docs/world/connections.yml` 接线。禁止把 FFT 塞进 Scatter，禁止把体积云塞进草地，禁止在海洋 Shader 里再做一套大气。
6. 新环境系统先登记 `modules.yml` + `profiles/<id>.yml` + `docs/<id>/_index.md`，再写代码。
7. 超规按 `global_rules/violation.md`：按表改、收工再报。禁止临时文件/抬上限/假分支。禁止顺手改未点名文件。
8. 控制面用 git（`docs/world/vcs.yml`）。源工程尚未入库；改 compute/shader 前仍先备份。禁止把 `Library/` 和源工程推进控制面仓库。
