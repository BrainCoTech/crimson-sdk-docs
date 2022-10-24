# Flutter

## Installation

```yaml
headband_sdk:
  version: 3.0.2
  hosted:
    name: headband_sdk
    url: https://dart-pub.brainco.cn
```

## Init

```dart
HeadbandConfig.logLevel = Level.INFO;
HeadbandConfig.availableType = HeadbandAvailableType.crimson;
await HeadbandManager.init();
```

## Scan-扫描

[FAQ](zh/faq.md)

```dart
//开始扫描设备
await HeadbandManager.setScanMode(HeadbandScanMode.crimson);
final deviceInfoPlugin = DeviceInfoPlugin();
if (Platform.isAndroid) {
    final androidInfo = await deviceInfoPlugin.androidInfo;
    if (androidInfo.version.sdkInt >= 31) {
    loggerExample.i('request Permission.bluetoothScan & bluetoothConnect');
    await [
        Permission.locationWhenInUse,
        Permission.bluetoothScan,
        Permission.bluetoothConnect
    ].request();
    } else {
    await [Permission.locationWhenInUse].request();
    }
} else if (Platform.isIOS) {
    await [Permission.bluetooth].request();
}
await HeadbandManager.startScan();
```

```dart
//停止扫描设备
await HeadbandManager.stopScan();
```

```dart
//扫描结果
HeadbandManager.scanner.onFoundDevices.map((event) => event as List<ScanResult>)
```

## Pair-配对

[FAQ](zh/faq.md)

```dart
try {
    await HeadbandManager.stopScan();
    await EasyLoading.show(status: '配对中...');
    await HeadbandManager.bindCrimson(result);
    await EasyLoading.showSuccess('配对成功!');
} catch (e, _) {
    loggerExample.i('$e');
    await EasyLoading.showError('配对失败');
    await HeadbandManager.startScan(); //restart scan
}
```

## 设备状态、脑电原始数据、脑波频域数据、注意力、冥想指数

```dart
HeadbandProxy.instance.id
HeadbandProxy.instance.name
HeadbandProxy.instance.state
HeadbandProxy.instance.attention 
HeadbandProxy.instance.meditation

HeadbandProxy.instance.onStateChanged
HeadbandProxy.instance.onEEGData
HeadbandProxy.instance.onBrainWave
HeadbandProxy.instance.onAttention
HeadbandProxy.instance.onMeditation

enum HeadbandState {
  /// 未连接
  disconnected,

  /// 连接中
  connecting,

  /// 已连接
  connected,

  /// 佩戴检测中 -> 先检测电极与皮肤是否接触良好，然后检测是否戴正
  contacting,

  /// 佩戴反
  contactUpsideDown,

  /// 佩戴检测通过 -> 佩戴良好 & 佩戴方向正确
  contacted,

  /// 工作中，正常输出注意力、冥想指数
  analyzed
}

// 已连接
state.isConnected
// 已佩戴好
state.isContacted
// 工作中，正常输出注意力、冥想指数
state.isAnalyzed
```

## OTA

```dart
bool _otaRunning = false;
Future startDFU() async {
  if (_otaRunning) return;
  if (!(HeadbandManager.headband is CrimsonHeadband)) return;
  _otaRunning = true;
  final headband = HeadbandManager.headband as CrimsonHeadband;
  try {
    final url = 'https://oss.brainco.cn/crimson-firmware/updates/FW_DFU_Crimson_V1.1.6.zip';
    final storageDir = await getApplicationSupportDirectory();
    final dstPath = storageDir.path + '/rom.zip';
    await NetworkService.rest.download(url, dstPath,
        onReceiveProgress: (count, total) async {
      final progress = (count * 100.0 / total).toStringAsFixed(1);
      loggerExample.i('download firmware progress = $progress');
      if (count == total) {
        headband.startDfu(
            dstPath,
            DefaultDfuProgressListenerAdapter(
                onDfuCompletedHandle: (String deviceAddress) async {
                loggerExample.i('[$deviceAddress] DFU completed ');
                await HeadbandManager.onOTADone();
                _otaRunning = false;
            }, onDfuAbortedHandle: (String deviceAddress) async {
                loggerExample.i('[$deviceAddress] DFU aborted ');
                await HeadbandManager.onOTADone();
                _otaRunning = false;
            }, onErrorHandle: (String deviceAddress, int error, int errorType,
                    String message) {
                loggerExample.w('[$deviceAddress] DFU error = $message');
            }, onProgressChangedHandle: (
                deviceAddress,
                percent,
                speed,
                avgSpeed,
                currentPart,
                artsTotal,
            ) {
                loggerExample
                    .i('[$deviceAddress] DFU progress = $percent, speed=$speed');
            })
        );
      }
    });
  } catch (e) {
    loggerExample.e('download firmware error, $e');
    _otaRunning = false;
  }
}
```
