# 草地交互

形变影响源，不是带积分的物理力。

## 谁拥有

每个 Field 一份 `GrassInteractionRuntime`：Interactor Buffer、Trample 双 RT、材质。输出只读 RenderState，由 `GrassRenderParameterBinder.ApplyInteraction` 绑到本 Field 材质。禁止全局 Shader 属性。

`GrassInteractor` + `GrassInteractorRegistry` 只负责自注册。上传由 Runtime 做。

## 两套效果

| 模式 | 状态 | 离开后 |
|---|---|---|
| 未开 Trample | 顶点按当前 Interactor 求值 | 立即恢复 |
| 开 Trample | 历史在二维 RT，衰减 | 区域场，不是每根草 State |

风每帧由 `_Time + rootWorldPos + 风参数` 重算，没有每叶速度。

默认零开销：`_GrassInteractorCount=0`、`_GrassTrampleEnabled=0` 时不跑对应路径。

## 已知坑

Trample 用 `TransformObjectToHClip` + `Graphics.Blit`。踩痕错位先查 y 翻转/未铺满屏。

## 不要做的

- 把摇摆/推开/踩弯写回 `GrassBlade` Append Buffer
- 把草交互和 Scatter 的 per-instance Simulation 混成一套
- 草被拔起、断裂、独立碰撞时，应进独立 Simulation，而不是加到顶点偏移里
