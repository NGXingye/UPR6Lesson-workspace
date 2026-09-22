# GPU / 双端契约

改频谱、IFFT、纹理格式或打包前必读。渲染/交互只消费最终输出，不要改这里的中间布局。

## 固定规模

| 契约 | 当前值 | 同步点 |
|---|---:|---|
| FFT 分辨率 | 1024 | C# `OceanSpectrumConstants.FftSize`；Config `Resolution` 只读转发；compute `SIZE` |
| `LOG_SIZE` | 10 | `log2(1024)`，与 groupshared 数组一起改 |
| Cascade | 4 | 初始频谱、位移、斜率层数；shader 里 `for (i < 4)` |
| JONSWAP 组数 | 8 | 每级风浪 + 涌浪；`params[2i]` / `params[2i+1]`，涌浪 `scale <= 0` 跳过 |
| JONSWAP stride | 32 bytes | 8 个 float，C#/HLSL 字段顺序必须一致 |

IFFT 维持固定 1024。多分辨率是独立优化阶段，见 `optimization.md`。

C# 字段名 `angleRad` 对应 HLSL `angle`。对契约的是**顺序和类型**，不是拼写。

## Kernel 顺序

初始化：`CS_InitializeSpectrum` → `CS_PackSpectrumConjugate`  
每帧：`CS_UpdateSpectrum` → `CS_HorizontalIFFT` → `CS_VerticalIFFT` → `CS_AssembleTextures`

IFFT 在 `spectrumRT` 上原地执行，不要额外复制一份 Fourier 目标。`fourierExtraRT` 只是 kernel 绑定占位。

| Kernel | 线程组 | Dispatch（1024 时） |
|---|---|---|
| 初始化 / 更新 / 组装 | `(8,8,1)` | `128,128,1` |
| Horizontal IFFT | `(SIZE,1,1)` | `1,1024,1` |
| Vertical IFFT | `(SIZE,1,1)` | `1,1024,1`；用 `id.yx` 转置访问 |

IFFT **不要**额外 `/SIZE`。H0 初始化已乘 `deltaK`，单独改归一化会破坏幅度。

## 纹理

全部 Linear、Random Write、Repeat、Bilinear、无 Mip。

| 资源 | 形状 | 格式 | 内容 |
|---|---|---|---|
| `initialSpectrumRT` | Tex2DArray / 4 | ARGBFloat | 打包后 `xy=H0(k)`，`zw=conj(H0(-k))` |
| `spectrumRT` | Tex2DArray / 8 | ARGBFloat | 位移/斜率频域，随后原地 IFFT |
| `displacementTextureRT` | Tex2DArray / 4 | ARGBFloat | xyz 位移 + a 白沫历史 |
| `slopeTextureRT` | Tex2DArray / 4 | RGFloat | xz 斜率 |
| `buoyancyDataRT` | Tex2D / 1 | RHalf | Cascade 0 高度 |
| `variationMaskRT` | Tex2D / 1 | ARGBFloat | 当前自读自写，不是可靠输出 |
| `fourierExtraRT` | Tex2D / 1 | ARGBFloat | IFFT 占位 |

手册估算 1024 未压缩约 322 MiB，未在本仓库重算。

## 打包

每级 cascade 占 `spectrumRT` 两层（`i*2`、`i*2+1`）。`CS_UpdateSpectrum` 把两组复数融合成 float4。改打包必须同步改 `CS_AssembleTextures` 解包，以及任何未来直接采样 `spectrumRT` 的材质。

## 改动检查

- 新 RT：创建、绑 kernel、Release 三件套
- 新 Shader 属性：HLSL 声明 → `OceanShaderIDs` → C# `SetXxx`
- `waveSharp` 与 Foam Bias/Decay 属于 Assemble（模拟 Config），不是 Surface 外观
