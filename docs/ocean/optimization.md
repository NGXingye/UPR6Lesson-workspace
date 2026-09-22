# 优化

独立阶段。不要把可调分辨率或减 Cascade 混进功能修复。

## 现状

- IFFT `SIZE` 写死 1024，C# `FftSize` 同步写死。groupshared `fftGroupBuffer[2][SIZE]`，线程组 `(SIZE,1,1)`。
- Cascade 写死 4，JONSWAP 写死 8。改 N 级要全文搜这两处常量。
- 手册估算 1024 全套 RT 约 322 MiB（未压缩像素，不含对齐和临时）。改分辨率先重算显存。
- 1024 单组线程是 GPU 占用边界；换平台先验证 Compute 支持。

## 以后若要可调分辨率

必须一起改：`FftSize`、`SIZE`、`LOG_SIZE`、groupshared、Dispatch、C# 校验。只改 Config 上的数字会和 IFFT kernel 对不上。

可选方向（未做）：降到 512 做预览、按 Cascade 拆不同分辨率、IFFT 外提中间缓冲避免原地限制。每条都要重验打包契约。

## 相关但别混进来

- 远距 Cascade 淡出必须位移与斜率同一权重，否则几何和法线失配（渲染正确性，不是微优化）。
- `_VariationMask` 仍是 no-op，补生成是质量项。
- 平面反射 RT 不要继续用 `Screen.width/height`；要跟相机 descriptor / 动态分辨率（功能债）。
