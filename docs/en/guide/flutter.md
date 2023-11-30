# Flutter

## Download

[Apk](https://app.brainco.cn/zen/android/apk/oxyzen-demo-0.0.2-profile.apk)

[Example](<https://github.com/BrainCoTech/bci_device_sdk_example>)

## Requirements

- BLE 5.0
- iOS 12.0+
- Android 5.0+
- Mac 10.15+
- Windows 10 build 10.0.15063 or later

## Installation

```yaml
# login with Gitlab, account: external, pwd: 9dHmY1BvV&CW%K%Q
libcmsn:
  version: ^1.15.0
  hosted:
    name: libcmsn
    url: https://dart-pub.brainco.cn 
```

[pub-token](<https://dart.dev/tools/pub/cmd/pub-token>)

```shell
dart pu

## Init

```dart
BciDevicePluginRegistry.register(CrimsonPluginRegistry());
await AppLogger.init(level: Level.INFO);
loggerApp.i('------------------initBCIDeviceSdk, init------------------');
loggerApp.i('-----crimson version=${CrimsonFFI.sdkVersion}-----');
BciDeviceConfig.setAvailableModes({
  BciDeviceDataMode.attention,
  BciDeviceDataMode.meditation,
});
await BciDeviceManager.init();
```

## Scan

if the device cannot be scanned, or pair failed, please check [Instructions](./faq.html)

```dart
// Start Scan Crimson Devices
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
// Stop Scan Crimson Devices
await BleScanner.instance.stopScan();
```

```dart
// Scanned Devices
BleScanner.instance.onFoundDevices
```

## Pair

if the device cannot be scanned, or pair failed, please check [Instructions](./faq.html)

```dart
try {
    await EasyLoading.show(status: 'pairing...');
    await BciDeviceManager.bindBleScanResult(result);
    await EasyLoading.showSuccess('pair success');
} catch (e, _) {
    loggerExample.i('$e');
    await EasyLoading.showError('pair failed !!');
    await BleScanner.instance.startScan();; //restart scan
}
```

## Device State & Stream

```dart
BciDeviceProxy.instance.id
BciDeviceProxy.instance.name
BciDeviceProxy.instance.state
BciDeviceProxy.instance.attention
BciDeviceProxy.instance.meditation

BciDeviceProxy.instance.onBatteryLevelChanged
BciDeviceProxy.instance.onDeviceInfo
BciDeviceProxy.instance.onStateChanged
// EEG Data, voltage difference between Fp1 and Fp2, uV, sample rate is 250Hz, five times callback usually per second, per callback contains 50 elements 
BciDeviceProxy.instance.onEEGData
// EEG Data - without filter
BciDeviceProxy.instance.onRawEEGData
// Band power values, uV/Hz
BciDeviceProxy.instance.onBrainWave
// Attention Index
BciDeviceProxy.instance.onAttention
// Meditation Index
BciDeviceProxy.instance.onMeditation

class BciDeviceInfo {
  String sn = '';
  String firmwareVersion = '';
}

enum BciDeviceConnectivity {
  disconnected,
  connecting,
  connected, // ble device state is connected & pair success
  disconnecting
}

// EEG metal electrode contact well with skin
enum BciDeviceContactState { unknown, contact, noContact }

// device state
enum BciDeviceState {
  disconnected,

  connecting,

  //ble device state is connected & pair success
  connected,

  // device adjust fit
  contacting,

  // device orientation upsideDown
  contactUpsideDown,

  // EEG metal electrode contact well with skin and device orientation is normal 
  contacted,

  // in working, output attention & meditation 
  analyzed
}

enum BciDeviceOrientation { unknown, normal, upsideDown }

class EEGModel {
  final int seqNum;
  final List<double> eeg;
}

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

### DFU

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
