# Overview

Crimson portable EEG equipment adopts the design of Fp1 and Fp2 voltage difference on the forehead. After EEG signal collection, analysis and processing, it can stably output brain wave frequency domain data, attention, meditation, social engagement etc.
Can be used in a variety of scenarios, such as neurofeedback training, focus, mindfulness meditation, ADHD, autism rehabilitation, etc.

## EEG Data

when the user wears the Crimson portable EEG device and the electrodes are in good contact with the skin, there is a strong correlation of more than 90% between it and the signal generated by the GTek EEG device

| EEG data | Voltage difference between forehead Fp1 and Fp2 |
| ---- | ---- |
| Value range | -120~120μV, influence by EOG and motion signals, value range will at -150~150μV |
| SampleRate | 250HZ |

## EEG BrainWave

- According to the EEG EEG data, generate the average amplitude of the distribution in the frequency domain

| EEG frequency domain | Unit μV/Hz |
| ---- | ---- |
| Gamma | [32~56] |
| HighBeta | [22~32] |
| LowBeta | [12~22] |
| Theta | [4~8] |
| Delta | [0.5~4] |

## Attention, Meditation

- The attention value is generated by NASA's attention algorithm and BrainCo's private AI algorithm. This data can be used to make attention-related applications. For example, when the user's attention value reaches a certain state, give it positive or negative feedback wait
- The meditation index is generated based on the brainwave data of professional meditation trainers and can be used to evaluate the user's current meditation state

| Scenario quantization index | Description |
| ---- | ---- |
| Attention | [0~100], the larger the value, the more focused |
| Meditation | [0~100], the larger the value, the more relaxed |

::: tip
If you want to know about BrainCo related products, please refer to [Official Website](https://www.brainco.tech)

If you have other scientific research experiments or specific scenarios, please contact us
:::
