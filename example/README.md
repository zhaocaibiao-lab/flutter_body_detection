# 表情包工厂（基于 body_detection 插件改造）

本 App 是在 [0x48lab/flutter_body_detection](https://github.com/0x48lab/flutter_body_detection)
（Flutter 插件，iOS/Android 双端，使用 Google MLKit 的 **Selfie Segmentation** 端侧去背）的
`example/` 示例基础上改造而来，目标是做一个**功能单一的表情包工具**，三个核心功能：

| 功能 | 入口 Tab | 说明 |
| --- | --- | --- |
| 1. 截图表情 | 截图 | 选一张截图 → 端侧去背 → 透明 PNG → 分享/保存 |
| 2. 动态表情 | 动态 | 选一段 GIF → 逐帧去背 → 透明动态 GIF → 分享/保存 |
| 3. 我的照片 | 照片 | 从相册选自己的照片 → 端侧去背 → 透明 PNG → 分享/保存 |

> 去背**完全在手机本地完成**（MLKit Selfie Segmentation，不上传任何服务器），零后端成本、隐私友好。

## 改造了什么

- `lib/core/cutout_service.dart`（新增）：把 `BodyDetection.detectBodyMask` 返回的人像置信度
  buffer 当作 alpha 通道合成原图，得到透明 PNG（静态）/ 透明 GIF（动态逐帧）。
- `lib/widgets/transparent_preview.dart`（新增）：棋盘格透明预览，方便确认抠图是否干净。
- `lib/features/*_sticker_screen.dart`（新增 3 个页面）：对应三个功能。
- `lib/main.dart`（改造）：三个 Tab 的底部导航，替代原示例的 Image/Camera 双 Tab。
- `pubspec.yaml`：新增 `image`（逐像素合成/GIF 编解码）、`path_provider`（导出）、`share_plus`（分享到微信/QQ）。
- `AndroidManifest.xml` / `Info.plist`：补充相册读取/保存权限。

## 运行（在你自己的 Mac / 安卓环境）

```bash
# 1. 进入插件目录初始化（生成 android/ios 原生壳，仅首次）
cd flutter_body_detection
flutter pub get

# 2. 运行改造后的示例 App（含三个功能页）
cd example
flutter pub get
flutter run          # 连上 iOS 模拟器/真机 或 安卓设备
```

- **iOS**：需 Mac + Xcode + 苹果开发者账号。`flutter run` 后自签或真机调试即可。
- **安卓**：需 Android SDK（minSdk 21+）。`flutter run` 装到真机/模拟器。

## 关键说明与局限

1. **透明表情包**输出 PNG/GIF。微信/QQ 添加表情时：PNG 透明可被识别；GIF 为 1-bit 透明
   （背景在微信里显示为白底，属正常现象）。如需纯透明动图可选 APNG（后续扩展）。
2. **动态视频（MP4）去背**：本改造版聚焦 GIF 逐帧去背（纯 Dart，零原生依赖，最容易跑通）。
   若要支持短视频 MP4，可引入 `ffmpeg_kit_flutter` 抽帧 → 复用 `cutoutGifBytes` 的逐帧逻辑 →
   再合成。见下方「扩展」。
3. **逐帧耗时**：每帧都要调用一次端侧 MLKit 推理（几十~几百 ms/帧），长 GIF 处理较慢，
   属预期；可在 `cutout_service.dart` 里对帧做抽稀（如隔帧处理）提速。
4. **未做实时拍照**：功能 3「我的照片」走相册选择。如需 App 内直接拍照，可加 `camera` 插件
   替换 `file_picker` 的入口。
5. 本工程在 Windows 环境由助手生成并改造，**未经 Flutter 编译验证**（该环境无 Flutter SDK /
   无 Mac）。代码按 Flutter 3.x + body_detection API 规范编写，请在你本机 `flutter run` 实测，
   如有编译报错把信息贴回即可修正。

## 扩展：支持短视频 MP4 去背

在 `pubspec.yaml` 增加 `ffmpeg_kit_flutter: ^6.0.3`，在 `dynamic_sticker_screen.dart` 中：

```dart
// 用 ffmpeg 把视频抽成图片序列
await FFmpegKit.execute('-i input.mp4 frame_%03d.png');
// 对每帧调用 CutoutService.cutoutImageBytes(...) 得到透明帧
// 再用 FFmpegKit 把透明帧序列合成回 GIF/WebM
```

由于 GIF 不支持半透明、MP4 也不支持透明，透明动态视频建议输出 WebM（VP8/VP9 + alpha）。
