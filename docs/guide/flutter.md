# Flutter

## 下载

[示例Apk](https://app.brainco.cn/zen/android/apk/oxyzen-demo-0.0.2-profile.apk)

[Example](<https://github.com/BrainCoTech/bci_device_sdk_example>)

## 系统要求

- BLE 5.0
- iOS 12.0+
- Android 5.0+
- Mac 10.15+
- Windows 10 build 10.0.15063 or later
- Dart 3.0+

## 安装依赖

```yaml
# login with Gitlab, account: external, pwd: 9dHmY1BvV&CW%K%Q
libcmsn:
  version: 1.22.19
  hosted:
    name: libcmsn
    url: https://dart-pub.brainco.cn 
```

```shell
# 1. login with Gitlab(<https://dart-pub.brainco.cn>), account: external, pwd: 9dHmY1BvV&CW%K%Q
# 2. copyToken to env TOKEN_PUB
dart pub token add https://dart-pub.brainco.cn --env-var TOKEN_PUB
# see <https://dart.dev/tools/pub/cmd/pub-token>
```

## 示例代码

### 初始化

```dart
await AppLogger.init(level: Level.INFO);
await BciDevicePluginRegistry.init({CrimsonPluginRegistry()});
loggerApp.i('-----Crimson sdkVersion=${CrimsonFFI.sdkVersion}-----');
BciDeviceConfig.setAvailableModes({
  BciDeviceDataMode.attention,
  BciDeviceDataMode.meditation,
});
await BciDeviceManager.init();
```

### 开启扫描

扫描不到设备，查看[设备使用说明](faq.html)

```dart
//开始扫描设备
final deviceInfoPlugin = DeviceInfoPlugin();
if (Platform.isAndroid) {
  final androidInfo = await deviceInfoPlugin.androidInfo;
  if (androidInfo.version.sdkInt >= 31) {
    loggerApp.i('request Permission.bluetoothScan & bluetoothConnect');
    await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect
    ].request();
  } else {
    await [Permission.locationWhenInUse].request();
  }
} else if (Platform.isIOS || Platform.isWindows) {
  await [Permission.bluetooth].request();
}
await BleScanner.instance.startScan();
```

```dart
// NOTE: 开启扫描与停止扫描成对出现
await BleScanner.instance.stopScan();
```

```dart
//扫描结果
BleScanner.instance.onFoundDevices
```

### 配对/校验配对信息

配对/校验配对信息出错，查看[设备使用说明](faq.html)

```dart
try {
    await EasyLoading.show(status: '配对中...');
    await BleDeviceManager.bindScanResult(result);
    await EasyLoading.showSuccess('配对成功!');
} catch (e, _) {
    loggerExample.i('$e');
    await EasyLoading.showError('配对失败');
    await BleScanner.instance.startScan(); //restart scan
}
```

### 设备状态及数据

```dart
// 设备ID
BciDeviceProxy.instance.id
// 设备名称
BciDeviceProxy.instance.name
// 设备状态
BciDeviceProxy.instance.state
// 注意力指数
BciDeviceProxy.instance.attention
// 冥想正念指数
BciDeviceProxy.instance.meditation

// 电量
BciDeviceProxy.instance.onBatteryLevelChanged
// 设备信息
BciDeviceProxy.instance.onDeviceInfo
// 设备状态
BciDeviceProxy.instance.onStateChanged
// EEG数据
BciDeviceProxy.instance.onEEGData
// EEG数据 - 未滤波
BciDeviceProxy.instance.onRawEEGData
// EEG频域数据
BciDeviceProxy.instance.onBrainWave
// 注意力指数
BciDeviceProxy.instance.onAttention
// 冥想正念指数
BciDeviceProxy.instance.onMeditation

class BciDeviceInfo {
  String sn = '';
  String firmwareVersion = '';
}

// 设备连接状态
enum BciDeviceConnectivity {
  disconnected,
  connecting,
  connected, // 已连接, 配对通过
  disconnecting
}

// EEG佩戴状态
enum BciDeviceContactState { unknown, contact, noContact }

// 设备状态-合并连接及佩戴状态
enum BciDeviceState {
  ///未连接
  disconnected,

  ///连接中
  connecting,

  ///已连接, 配对通过
  connected,

  ///佩戴检测中 -> 先检测电极与皮肤是否接触良好，然后检测是否戴反
  contacting,

  ///佩戴反
  contactUpsideDown,

  ///佩戴检测通过 -> 佩戴良好 & 佩戴方向正确
  contacted,

  ///工作中，正常输出注意力、冥想指数等
  analyzed
}

/// IMU
enum BciDeviceOrientation { unknown, normal, upsideDown }

// EEG数据
class EEGModel {
  final int seqNum;
  final List<double> eeg;
}

// EEG频域数据, uV/Hz
// delta: [0.5~4],
// theta: [4~8],
// alpha:[8~12]
// lowBeta:[12~22]
// highBeta:[22-32]
// gamma[32-56]
class BrainWaveModel {
  late double gamma;
  late double highBeta;
  late double lowBeta;
  late double alpha;
  late double theta;
  late double delta;
}
```

### 升级固件

```dart
Future _startDfu(CrimsonDevice device, String zipFilePath) async {
  clearOtaSubscriptions();

  device.dfuProgressStream.listen((value) {
    final percent = value ~/ 10; // 0~100
  }).addToList(_otaSubscriptions);

  device.dfuStateStream.listen((status) {
    switch (status) {
      case OtaStatus.success:
      case OtaStatus.failed:
        _otaRunning = false;
        break;
      default:
        break;
    }
  }).addToList(_otaSubscriptions);

  final ret = device.startDfu(zipFilePath);
  if (!ret) _clearOtaSubscriptions();
}

void clearOtaSubscriptions() {
  for (var subscription in _otaSubscriptions) {
    subscription.cancel();
  }
  _otaSubscriptions.clear();
}
```
