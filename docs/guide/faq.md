# 设备使用说明

## 设备基本使用

- **开/关**机，**短按**电源键，开机后默认为**普通**模式
- 进入**配对**模式，**长按**电源键直至设备振动两次，此时LED为蓝灯**快速闪烁**

## 设备LED灯光说明

| 颜色 | 说明 |
|  ----  | ----  |
| 蓝灯快速闪烁 | 配对模式 |
| 蓝灯呼吸慢闪 | 普通模式 |
| 白灯常亮 | 配对成功 |
| 红灯闪烁 | 电量低，需要充电 |
| 白灯闪烁 | OTA |
| 黄灯闪烁 | 电池温度异常 |

::: tip
设备配对成功以后，您可以设置设备的LED灯光颜色
:::

## 设备连接配对

1. 连接新终端，切换到**配对**模式，然后开启扫描，连接，配对
2. 连接配对成功过的终端，切换到**普通**模式，然后开启扫描，连接，校验配对信息

::: tip
设备只能同时连接到一个终端，如果设备已经连接到其他终端，那么您将无法扫描连接到该设备
:::

## [在Windows上的使用说明](https://app.brainco.cn/docs/crimson-sdk/%E8%93%9D%E7%89%99%E8%84%91%E7%94%B5%E8%AE%BE%E5%A4%87%E5%9C%A8Windows%E4%B8%8A%E7%9A%84%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E.pdf)

## Windows下无法扫描到设备

检查系统蓝牙设备及驱动是否正常，测试在蓝牙5.0环境下能够正常扫描连接运行
当无法扫描到设备时，可以用微软官方BLE sample辅助验证排查问题
[微软官方BLE sample](<https://github.com/microsoft/Windows-universal-samples/tree/main/Samples/BluetoothAdvertisement>)

sample中的CompanyId需要改一下

```cpp
watcher = new BluetoothLEAdvertisementWatcher();

var manufacturerData = new BluetoothLEManufacturerData();
manufacturerData.CompanyId = 0x5242;

// Finally set the data payload within the manufacturer-specific section
// Here, use a 16-bit UUID: 0x1234 -> {0x34, 0x12} (little-endian)
// var writer = new DataWriter();
// writer.WriteUInt16(0x1234);
```

厂商自定义数据 manufacturer data

利用蓝牙广播"厂商自定义数据"字段【TYPE=0xFF】

配对状态为1处于配对模式，0处于普通模式

每400ms更新一次广播数据，第一个400ms内的数据舍掉

| TYPE | 厂商ID高字节 | 厂商ID低字节 | 电量 | 配对状态 |
|------|--------------|--------------|------|----------|
| 0xFF |     0x42     |     0x52     | 0~100|   1或0   |
