# 交互

GPU 已写出高度，CPU 浮力还没接到同一份数据上。

## 已有输出

`OceanSimulationOutputs.BuoyancyTexture`：RHalf，Cascade 0 的 `finalDisplace.y`。Owner 是 Driver，交互代码只拿 Outputs 句柄。

Outputs 注释期望查询用 Point 采样。当前 Driver 创建该 RT 时是 **Bilinear + Repeat**，与注释不一致。做高度查询前先定过滤模式，不要默认为 Point。

没有 CPU 回读。船只/漂浮物需要自己做 GPU 查询或显式 Readback，方案未定。

## 现成组件（未接线）

`Buoyancy.cs` / `BuoyancyPreset.cs` 在命名空间 `OceanQuest`，体素阿基米德浮力，**不引用** `FFTOcean` 或 `OceanSimulationOutputs`。不能当成已经吃 FFT 高度场。

接入时：采样 Outputs 高度，保持 Config 不持有刚体状态，查询失败要有限回退。

## 接触

岸线白沫可用 Bathymetry 或场景厚度做静态海岸带，不是任意物体相交泡沫。动态接触（船体、角色）应走场景深度或专用交互深度，不要把 Bathymetry 当碰撞。

涟漪按独立 Simulation/Outputs 做，不写进 `OceanSurfaceConfig`。
