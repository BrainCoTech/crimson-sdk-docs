# Android

## 下载

[下载示例](https://app.brainco.cn/universal/crimson-sdk-prebuild/android/1.3.0/android_example.zip)

[演示视频](https://app.brainco.cn/universal/crimson-sdk-prebuild/android/example.mp4)

## 系统要求

Android 6.0 or later

## 集成说明

```groovy
// build.gradle

android {
    compileSdk 34

    defaultConfig {
        minSdk 21
        targetSdk 34
    }
}

repositories {
    maven {
        credentials {
            username 'maven-read'
            password 'yC2bCzx3UoaBTIC8'
        }
        url = "https://nexus.ci.brainco.cn/repository/maven-public"
    }
}

dependencies {
    // import crimson-sdk from maven
    api 'tech.brainco:crimsonsdk:1.4.5'
}

// manifest
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
  package="com.xxx.xxx">
    <uses-permission android:name="android.permission.BLUETOOTH" android:maxSdkVersion="30" />
    <uses-permission android:name="android.permission.BLUETOOTH_ADMIN" android:maxSdkVersion="30" />
    // 扫描蓝牙设备需要精确位置权限
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    // 安卓12新增蓝牙权限
    <uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
    <uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
</manifest>

// proguard-rules.pro
-dontwarn java.awt.*
-keep class no.nordicsemi.android.dfu.** { *; }
-keep class com.sun.jna.* { *; }
-keepclassmembers class * extends com.sun.jna.* { public *; }
```

## 示例

### 开启扫描

扫描不到设备，查看[设备使用说明](faq.html)

```java
// Permissions check
if (!CrimsonPermissions.checkBluetoothFeature(this)) {
    showMessage("BLE not supported");
    return;
}

BluetoothAdapter adapter = ((BluetoothManager)this.getSystemService(Context.BLUETOOTH_SERVICE)).getAdapter();
if (adapter == null || !adapter.isEnabled()) {
    CrimsonPermissions.enableBluetooth(this);
    return;
}

// location Permission
if (!CrimsonPermissions.checkPermissions(this)) {
    CrimsonPermissions.requestPermissions(this);
    return;
}
```

```java
// 蓝牙状态监听
public class ScanActivity extends BaseActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        CrimsonSDK.setLogLevel(CrimsonSDK.LogLevel.INFO);
        CrimsonSDK.registerBLEStateReceiver(this); //注册蓝牙状态监听
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();

        CrimsonSDK.unregisterBLEStateReceiver(this);//移除注册蓝牙状态监听
    }
}

// startScan 开启扫描
showLoadingDialog();
CrimsonSDK.startScan(new CrimsonDeviceScanListener() {
    /*
    param: state
    BluetoothAdapter.STATE_OFF:
    @IntDef(prefix = { "STATE_" }, value = {
            STATE_OFF,
            STATE_TURNING_ON,
            STATE_ON,
            STATE_TURNING_OFF,
            STATE_BLE_TURNING_ON,
            STATE_BLE_ON,
            STATE_BLE_TURNING_OFF
    })
    */
    @Override
    public void onBluetoothAdapterStateChange(int state) {
                Log.i(TAG, "BluetoothAdapter state=" + state);
                switch (state) {
                    case BluetoothAdapter.STATE_ON:
                        // restart scan
                        scanDevices();
                        break;
                    case BluetoothAdapter.STATE_OFF:
                        CrimsonSDK.stopScan();
                        break;
                    default:
                        break;
                }
            }

    @Override
    public void onFoundDevices(List<CrimsonDevice> results) {
        if (!results.isEmpty()) dismissLoadingDialog();
        devices = results;
        deviceListAdapter.notifyDataSetChanged();
    }

    @Override
    public void onError(CrimsonError error) {
        dismissLoadingDialog();
        showMessage(error.getMessage());
    }
}, null);

// scanFilters
final ArrayList<ScanFilter> scanFilters = new ArrayList<>();
scanFilters.add(new ScanFilter.Builder().setDeviceAddress("xxx-xxx").build());

// NOTE: 开启扫描与停止扫描成对出现
CrimsonSDK.stopScan();
```

### 连接

```java
listener = new DeviceListener();
device.setListener(listener);
device.connect(this);

// CrimsonDeviceListener
public abstract class CrimsonDeviceListener {
    // class CrimsonError
    public void onError(CrimsonError error){}
    public void onDeviceInfoReady(DeviceInfo info){} //蓝牙设备信息
    // batteryLevel 区间在0~100, -1表示未知
    public void onBatteryLevelChange(int batteryLevel){} //电量
    // Enum Connectivity
    public void onConnectivityChange(int connectivity){} //连接状态

    //******************** NOTE: invoked after startEEG *******************
    // Enum ContactState
    public void onContactStateChange(int state){} //佩戴状态
    // Enum Orientation, NOTE: invoked after startIMU
    public void onOrientationChange(int orientation){} // 佩戴方向
    public void onIMUData(IMU data){} // 陀螺仪数据
    public void onEEGData(EEG data){} // 脑电EEG数据
    public void onRawEEGData(EEG data){} // 脑电EEG数据，未去除噪声
    public void onBrainWave(BrainWave wave){}    //脑电频域波段数据
    public void onAttention(float attention){}   //注意力指数
    public void onMeditation(float meditation){} //冥想指数
    public void onBlink(){} // 眨眼事件
}
```

### 配对/校验配对信息

配对/校验配对信息出错，查看[设备使用说明](faq.html)

```java
void onConnectivityChange(int connectivity) {
    if (connectivity == Connectivity.CONNECTED) {
        pair()
    }
}

func pair() {
    pairing = true;
    devicePairButton.setText("Pairing");

    if (device.isInPairingMode()) {
        device.pair(error -> {
            pairing = false;
            if (error == null) {
                paired = true;
                devicePairButton.setText("Paired");
            } else {
                Toast.makeText(this, "Pair failed " + error.getMessage(), Toast.LENGTH_SHORT).show();
                devicePairButton.setText("Pair");
                if (error.getCode() == 3) {
                    // TODO: 配对失败
                }
            }
        });
    } else if (device.isInNormalMode()) {
        device.validatePairInfo(error -> {
            pairing = false;
            if (error == null) {
                paired = true;
                devicePairButton.setText("Paired");
            } else {
                Toast.makeText(this, "Validate pair info failed " + error.getMessage(), Toast.LENGTH_SHORT).show();
                devicePairButton.setText("Pair");
                if (error.getCode() == 4) {
                    // TODO: 检验配对信息失败，去重新配对
                }
            }
        });
    }
}
```

### 结构体、枚举

```java
// 设备连接状态
public class Connectivity {
    public static final int CONNECTING = 0;
    public static final int CONNECTED = 1;
    public static final int DISCONNECTING = 2;
    public static final int DISCONNECTED = 3;
}
// 佩戴状态，电极与皮肤接触良好
public class ContactState {
    public static final int UNKNOWN = 0;
    public static final int CONTACT = 1;   //佩戴好
    public static final int NO_CONTACT = 2;//未戴好
}
// 佩戴方向，检测是否佩戴反
public class Orientation {
    public static final int UNKNOWN = 0;
    public static final int UPWARD = 1;   //设备戴正
    public static final int DOWNWARD = 2; //设备戴反
}
// EEG, 默认为每秒回调5次
public class EEG {
    private final int sequenceNumber;
    private final double sampleRate;
    private final float[] eegData;
}
// 脑电频域波段能量分布
public class BrainWave {
    private final double delta;
    private final double theta;
    private final double alpha;
    private final double lowBeta;
    private final double highBeta;
    private final double gamma;
}

public class CrimsonError {
    public static final int ERROR_NONE = 0;
    public static final int ERROR_UNKNOWN = -1;
    public static final int ERROR_SCAN_FAILED_INTERNAL = -64;
    public static final int ERROR_SCAN_FEATURE_UNSUPPORTED = -65;
    public static final int ERROR_PERMISSION_DENIED = -128;
    public static final int ERROR_DEVICE_NOT_CONNECTED = -160;
    public static final int ERROR_RESPONSE_TIMEOUT = -1001;

    private int code;
    private String message;

    CrimsonError(int code) {
        this.code = code;
        switch(code) {
            case ERROR_NONE:
                message = "Success";
                break;
            case ERROR_UNKNOWN:
                message = "Unknown error"; //未知错误
                break;
            case ERROR_SCAN_FAILED_INTERNAL:
                message = "Bluetooth LE scan failed internally"; //开启扫描失败
                break;
            case ERROR_SCAN_FEATURE_UNSUPPORTED:
                message = "Bluetooth LE scan feature is not supported for this device"; //开启扫描失败
                break;
            case ERROR_PERMISSION_DENIED:
                message = "Bluetooth or location permissions could have been denied"; //蓝牙或定位权限未打开
                break;
            case ERROR_DEVICE_NOT_CONNECTED:
                message = "Device not connected"; //设备不可用
                break;
            case ERROR_RESPONSE_TIMEOUT:
                message = "response timeout"; //响应超时
                break;
            default:
                message = "Unknown error:" + code; //未知code
        }
    }
}
```

### 开启监测EEG数据

```java
device.startEEGStream(error -> {
    if (error != null) {
        Log.i(TAG,"startEEGStream:" + error.getCode() + ", message=" + error.getMessage());
    } else {
        Log.i(TAG,"startEEGStream success");
    }
});
```

### 开启监测IMU数据

```java
// IMU SampleRate 采样频率
public class IMUSampleRate {
    public final static int UNUSED = 0; // stop imu stream
    public final static int SR12_5 = 0x10; // 默认使用
}
```

```java
device.startIMU(error -> {
    if (error != null) {
        Log.i("startIMU:" + error.getCode(), error.getMessage());
    }
});
```

### 更多设置

```java
// 设置日志级别，默认为INFO
CrimsonSDK.setLogLevel(CrimsonSDK.LogLevel.ERROR);
public static void setLogLevel(int level)

public void connect(@NonNull Context context)
public void disconnect()
public void pair(CrimsonResponseCallback callback)
public void validatePairInfo(CrimsonResponseCallback callback)

public int startDataStream(CrimsonResponseCallback callback)
public int stopDataStream(CrimsonResponseCallback callback)
public int startIMU(int sampleRate, CrimsonResponseCallback callback)
public int stopIMU(CrimsonResponseCallback callback)

// @param name length should be 4 ~ 18, 修改设备名称成功之后，固件会断开连接
public int setDeviceName(String name, CrimsonResponseCallback callback)

/*
 * @param red     0-255
 * @param green   0-255
 * @param blue    0-255
 */
public int setLEDColor(int red, int green, int blue, CrimsonResponseCallback callback)

// @param timeSec => seconds to put device into sleep mode, 0 for no sleep
public int setSleepIdleTime(int timeSec, CrimsonResponseCallback callback)

// @param intensity => vibration intensity, 0 ~ 100
public int setVibrationIntensity(int intensity, CrimsonResponseCallback callback)
```

### 升级固件

```java
public class CrimsonOTA {
    public static String latestVersion;
    public static String url;
    public static String desc;
    public static String descEN;
}

boolean ret = device.isNewFirmwareAvailable();
Log.i(TAG, "isNewFirmwareAvailable=" + ret);
Log.i(TAG, "latestVersion=" + CrimsonOTA.latestVersion);
Log.i(TAG, "desc=" + CrimsonOTA.desc);

device.startDfu(this, new DFUCallback() {
    @Override
    public void onSuccess() {
        Log.i(TAG, "onSuccess");
    }

    @Override
    public void onFailure(Exception e) {
        Log.i(TAG, e.getMessage());
    }

    @Override
    public void onProgress(int progress) {
        Log.i(TAG, "progress=" + progress);
    }
});
```
