# 核⼼功能概述

Focus便携脑电设备，采用前额两点电势差的设计，通过信号采集分析处理后能稳定输出脑波频域数据，注意力，冥想，社交活跃度等数据，
可用于多种应用场景，如神经反馈训练，专注力，正念冥想，多动症，自闭症康复等。

## EEG脑电数据

在用户佩戴Focus便携脑电设备，且电极与皮肤接触良好的稳定状态下，其和GTek脑电设备生成的信号具有90%以上的强相关性

| EEG脑电数据 | 前额Fp1和Fp2的电势差 |
|  ----  | ----  |
| 稳定信号区间  | -120~120μV，叠加眼电和运动信号后在-150~150μV |
| 采样率 | 256HZ |

## EEG脑电频域能量分布

- 根据EEG脑电数据，生成频域能量分布平均幅值

| EEG脑电频域 | 单位 μV/Hz |
|  ----  | ----  |
| Gamma | [32~56] |
| HighBeta | [22~32] |
| LowBeta | [12~22] |
| Theta | [4~8] |
| Delta | [0.5~4] |

## 应用场景量化指数

- 注意力数值由由NASA注意⼒算法及BrainCo私有AI算法⽣成，可以利⽤这个数据制作与注意⼒相关的应用，例如，当用户注意⼒数值达到一个状态，给予其正向或负向反馈等
- 冥想指数是基于专业的冥想训练者脑波数据⽣成，可以用于评估⽤户当前的冥想状态
- 社交指数是基于不同社交活跃人群脑波数据⽣成，可以用于评估⽤户当前的社交活跃状态

| 场景量化指数 | 说明 |
|  ----  | ----  |
| 注意力指数区间 | [0~100]，数值越大越专注 |
| 冥想指数区间 | [0~100]，数值越大越放松 |
| 社交活跃指数区间 | [0~100]，数值越大越活跃 |

::: tip
如果您想了解BrainCo相关产品，请参考[官方网站](https://www.brainco-hz.com)

如果您有其他科研实验或具体场景，欢迎与我们联系
:::