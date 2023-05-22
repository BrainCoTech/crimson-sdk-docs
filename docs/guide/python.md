# Python

## 下载

[下载 SDK 及 Example](https://app.brainco.cn/universal/crimson-sdk-prebuild/python/1.3.0/python-example.zip)

## 系统要求

- BLE 4.2 or later
- Python 3.0 or later
- Mac 10.15 or later
- Windows 10 build 10.0.15063 or later, 推荐系统自带蓝⽛LMP 11.x以上固件版本，或使用USB 5.0蓝牙适配器

## 安装运行

```shell
pip3 install -r requirements.txt
python3 gui.py //or python3 example.py
```

## 示例代码

### 开启扫描

扫描不到设备，或者配对/校验配对信息出错，查看[设备使用说明](faq.html)

```python
CMSNSDK.start_device_scan(on_found_device)
```

### 连接设备

```python
print("Stop scanning for more devices")
# NOTE: 开启扫描与停止扫描成对出现
CMSNSDK.stop_device_scan()

_target_device = device
_target_device.set_listener(DeviceListener())
_target_device.connect()
```

### 断开连接

```python
# disconnect device
_target_device.disconnect()
```

### 设备状态、数据回调

```python
class DeviceListener(CMSNDeviceListener):
    def on_connectivity_change(self, connectivity):
        print("Connectivity:" + connectivity.name)
        if connectivity == Connectivity.connected:
            // 首次配对新设备时，需要先将设备设置为配对模式，然后开始扫描
            _target_device.pair(on_pair_response)
            // 开启EEG数据流
            _target_device.start_eeg_stream()

    //******************** NOTE: invoked after startEEG *******************
    def on_contact_state_change(self, contact_state):
        print("Contact state:" + contact_state.name)

    // NOTE: invoked after startIMU
    def on_orientation_change(self, orientation):
        print("orientation:" + orientation.name)

    def on_imu_data(self, imu_data):
        print("IMU Data:")
        print(imu_data)

    def on_eeg_data(self, eeg_data):
        if eeg_data.signal_type == AFEDataSignalType.lead_off_detection:
            print("Received lead off detection signal, skipping the packet.")
            return
        print("EEG Data:")
        print(eeg_data)

    def on_brain_wave(self, brain_wave):
        print("Alpha:" + str(brain_wave.alpha))

    def on_attention(self, attention):
        print("Attention: " + str(attention))

    def on_meditation(self, meditation):
        print("Meditation: " + str(meditation))
```

### 结构体、枚举

```python
// 设备连接状态
class Connectivity(IntEnum):
    connecting = 0
    connected = 1
    disconnecting = 2
    disconnected = 3

// 佩戴状态，电极与皮肤接触良好
class ContactState(IntEnum):
    unknown = 0
    contact = 1    //佩戴好
    no_contact = 2 //未戴好

// 佩戴方向，检测是否佩戴反
class Orientation(IntEnum):
    unknown = 0
    upward = 1   //设备戴正
    downward = 2 //设备戴反

// EEG
class EEGData:
    sequence_num = None
    sample_rate = None
    eeg_data = None

// 脑电频域波段能量
class BrainWave:
    delta = 0
    theta = 0
    alpha = 0
    low_beta = 0
    high_beta = 0
    gamma = 0

class IMUData:
    acc_data = None
    gyro_data = None
    euler_angle_data = None
    sample_rate = None
```
