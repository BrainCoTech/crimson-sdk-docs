# Flutter

## Installation

```yaml
crimson_sdk:
  version: 0.0.1
  hosted:
    name: crimson_sdk
    url: https://dart-pub.brainco.cn
```

## Init

```dart
HeadbandConfig.logLevel = Level.INFO;
await HeadbandManager.init();
```

## Scan

if the device cannot be scanned, or pair failed, please check [Instructions](./faq.html)

```dart
// Start Scan Crimson Devices
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
await HeadbandManager.bleScanner.startScan();
```

```dart
// Stop Scan Crimson Devices
await HeadbandManager.bleScanner.stopScan();
```

```dart
// Scanned Devices
HeadbandManager.bleScanner.onFoundDevices.map((event) => event as List<ScanResult>)
```

## Pair

if the device cannot be scanned, or pair failed, please check [Instructions](./faq.html)

```dart
try {
    await EasyLoading.show(status: 'pairing...');
    await HeadbandManager.bindCrimson(result);
    await EasyLoading.showSuccess('pair success');
} catch (e, _) {
    loggerExample.i('$e');
    await EasyLoading.showError('pair failed !!');
    await HeadbandManager.bleScanner.startScan();; //restart scan
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

  /// device connected
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
