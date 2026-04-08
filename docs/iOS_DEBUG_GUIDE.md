# iOS 调试指南

## 前置要求

- macOS 开发环境 (Xcode 15+)
- Apple Developer 账号（免费或付费）
- iOS 真机或模拟器
- CocoaPods (`sudo gem install cocoapods`)
- Flutter SDK 3.0+

## 1. 环境配置

### 安装依赖
```bash
cd ios
pod install
cd ..
```

### 检查 Xcode 版本
```bash
xcodebuild -version
# 需要 Xcode 15.0+
```

### 检查签名配置
```bash
cd ios
xcodebuild -showBuildSettings -project Runner.xcodeproj -scheme Runner
```

## 2. 开发者证书配置

### 免费开发者账号 (Personal Team)

1. 打开 Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```

2. 在 Xcode 中选择 `Runner` target → `Signing & Capabilities`

3. 勾选 `Automatically manage signing`

4. Team 选择你的 Apple ID (Personal Team)

5. Bundle Identifier 保持默认或修改为唯一值:
   ```
   com.yourname.raceWordGame
   ```

### 付费开发者账号 (Company/Organization Team)

1. 在 [Apple Developer Portal](https://developer.apple.com) 创建 App ID
2. 配置 Push Notifications capability (如需通知功能)
3. 创建 Development Provisioning Profile
4. 在 Xcode 中选择对应的 Team 和 Profile

## 3. 真机调试流程

### 步骤 1: 连接设备
```bash
# 确认设备已连接
flutter devices
```

### 步骤 2: 信任开发者证书
首次在设备上运行时:
1. 打开 iOS 设备 `设置` → `通用` → `VPN与设备管理`
2. 找到你的开发者证书
3. 点击 `信任`

### 步骤 3: 运行调试
```bash
# 在真机上运行
flutter run -d <device-id>

# 或指定所有已连接的 iOS 设备
flutter run -d ios

# Release 模式测试性能
flutter run --release -d <device-id>

# Profile 模式分析性能
flutter run --profile -d <device-id>
```

### 步骤 4: 查看日志
```bash
# Flutter 日志
flutter logs

# 系统日志
idevicesyslog | grep Runner
```

## 4. 模拟器调试

### 启动模拟器
```bash
# 列出可用模拟器
flutter emulators

# 启动指定模拟器
flutter emulators --launch apple_ios_simulator

# 运行
flutter run -d <simulator-id>
```

### 常用模拟器操作
```bash
# 截屏
xcrun simctl io booted screenshot screenshot.png

# 录屏
xcrun simctl io booted recordVideo video.mp4

# 打开 Safari 调试 WebView
open -a Simulator
```

## 5. 权限配置

### Info.plist 权限声明

在 `ios/Runner/Info.plist` 中添加以下权限:

```xml
<!-- 相机权限 (拍照添加卡片) -->
<key>NSCameraUsageDescription</key>
<string>需要访问相机来拍照创建单词卡片</string>

<!-- 麦克风权限 (语音识别) -->
<key>NSMicrophoneUsageDescription</key>
<string>需要麦克风权限来识别你的发音</string>

<!-- 语音识别权限 -->
<key>NSSpeechRecognitionUsageDescription</key>
<string>需要语音识别权限来评估你的英语发音</string>

<!-- 通知权限 -->
<key>UIBackgroundModes</key>
<array>
  <string>fetch</string>
  <string>processing</string>
</array>
```

### AR 配置 (如需 AR 功能)

在 Info.plist 中添加:
```xml
<key>ARConfigurationSupported</key>
<true/>
```

## 6. 调试技巧

### Xcode 调试
1. `flutter run` 启动后在终端按 `o` 打开 Xcode 调试器
2. 在 Xcode 中设置断点调试原生代码
3. 使用 Instruments 分析性能 (Memory, Time Profiler)

### Flutter DevTools
```bash
# 启动 DevTools
flutter pub global activate devtools
flutter pub global run devtools
```

### 常见问题

#### 1. Pod install 失败
```bash
cd ios
rm -rf Pods Podfile.lock
pod install --repo-update
```

#### 2. 签名错误
- 确保在 Xcode 中正确配置 Team
- 检查 Bundle Identifier 唯一性
- 免费账号每 7 天需要重新签名

#### 3. 真机无法连接
```bash
# 重启 usbmuxd
sudo killall usbmuxd
sudo usbmuxd -f -v
```

#### 4. 架构不匹配 (M1 Mac)
```bash
# 确保运行在 Rosetta 或原生架构
arch -x86_64 pod install
# 或
arch -arm64 pod install
```

## 7. 性能优化建议

### 1. 减少重建
- 使用 `const` 构造函数
- 避免在 `build()` 中创建新对象

### 2. 图片优化
- 使用 `cached_network_image` 缓存网络图片
- 适当压缩上传图片尺寸

### 3. 列表优化
- 使用 `ListView.builder` 而非 `Column` + `SingleChildScrollView`
- 设置合理的 `itemExtent`

### 4. 动画优化
- 使用 `AnimatedBuilder` 而非 `setState`
- 复杂动画使用 `RepaintBoundary` 隔离

## 8. 发布前检查

```bash
# 1. 运行所有测试
flutter test

# 2. iOS 静态分析
cd ios
xcodebuild analyze -project Runner.xcodeproj -scheme Runner

# 3. 构建检查
flutter build ios --release

# 4. Archive
flutter build ipa
```

## 9. CI/CD 集成

### GitHub Actions 示例

```yaml
name: iOS Build
on: [push, pull_request]
jobs:
  build:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
      - run: flutter pub get
      - run: flutter test
      - run: flutter build ios --release --no-codesign
```

## 10. 有用链接

- [Flutter iOS 部署文档](https://docs.flutter.dev/deployment/ios)
- [Apple Developer Portal](https://developer.apple.com)
- [Xcode 下载](https://developer.apple.com/xcode/)
- [CocoaPods 文档](https://guides.cocoapods.org)
