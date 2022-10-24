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
// Start Scan Crimson Devices
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
// Stop Scan Crimson Devices
await HeadbandManager.stopScan();
```

```dart
// Scanned Devices
HeadbandManager.scanner.onFoundDevices.map((event) => event as List<ScanResult>)
```

## Pair

[FAQ](zh/faq.md)

```dart
try {
    await HeadbandManager.stopScan();
    await EasyLoading.show(status: 'pairing...');
    await HeadbandManager.bindCrimson(result);
    await EasyLoading.showSuccess('pair success');
} catch (e, _) {
    loggerExample.i('$e');
    await EasyLoading.showError('pair failed !!');
    await HeadbandManager.startScan(); //restart scan
}
```

## Device State & Stream

```dart
HeadbandProxy.instance.id
HeadbandProxy.instance.name
HeadbandProxy.instance.state
enum HeadbandState {
  /// 
  disconnected,

  /// 
  connecting,

  /// 已连接
  connected,

  /// device adjust fit
  contacting,

  /// device wear upsideDown 
  contactUpsideDown,

  /// AFE contact well and device wear normal
  contacted,

  /// attention & meditation analyzed
  analyzed
}
HeadbandProxy.instance.onStateChanged

// voltage difference between Fp1 and Fp2, sample rate 250HZ, about return five times per second, every array contains 50 elements 
HeadbandProxy.instance.onEEGData
// Band power values
// delta: [0.5~4],
// theta: [4~8],
// alpha:[8~12]
// lowBeta:[12~22]
// highBeta:[22-32]
// gamma[32-56]
HeadbandProxy.instance.onBrainWave

HeadbandProxy.instance.onAttention
HeadbandProxy.instance.onMeditation
```
