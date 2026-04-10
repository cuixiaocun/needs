# 🚀 Flutter App 开发清单（v4.1）

> 三个 App 一份代码（农户 / 买家 / 工作人员 App）
>
> 基于 Flutter 3.0+，支持 iOS + Android

---

## 一、环境要求

### 1.1 系统要求
```
Flutter 3.0+ (推荐 3.13+)
Dart 3.0+
iOS: Xcode 14.0+ (Mac only)
Android: Android Studio + NDK
```

### 1.2 检查环境
```bash
flutter doctor

# 输出应该看到：
# ✓ Flutter (version 3.13.x)
# ✓ Dart (version 3.x)
# ✓ Xcode (iOS development)
# ✓ Android Studio (Android development)
```

---

## 二、项目初始化

### 2.1 创建 Flutter 项目
```bash
# 创建项目
flutter create needs_app
cd needs_app

# 或用官方模板
flutter create --template=app needs_app
```

### 2.2 项目结构
```
needs_app/
├── lib/
│   ├── main.dart                     # 应用入口
│   ├── config/
│   │   ├── app_config.dart           # 应用配置
│   │   ├── api_config.dart           # API 配置
│   │   └── theme.dart                # 主题配置
│   │
│   ├── models/                       # 数据模型
│   │   ├── user_model.dart
│   │   ├── order_model.dart
│   │   ├── farm_model.dart
│   │   └── ...
│   │
│   ├── services/                     # 业务逻辑服务
│   │   ├── api_service.dart          # API 通信
│   │   ├── auth_service.dart         # 认证
│   │   ├── storage_service.dart      # 本地存储
│   │   ├── alipay_service.dart       # 支付宝集成
│   │   └── ...
│   │
│   ├── providers/                    # 状态管理（GetX / Provider）
│   │   ├── auth_provider.dart
│   │   ├── order_provider.dart
│   │   └── ...
│   │
│   ├── screens/                      # 页面
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   ├── register_screen.dart
│   │   │   └── realname_screen.dart  # 实名认证
│   │   │
│   │   ├── home/
│   │   │   └── home_screen.dart
│   │   │
│   │   ├── order/
│   │   │   ├── create_order_screen.dart  # 挂单
│   │   │   ├── order_list_screen.dart
│   │   │   ├── order_detail_screen.dart
│   │   │   └── order_status_screen.dart  # 订单状态
│   │   │
│   │   ├── market/
│   │   │   ├── receiving_screen.dart     # 工作人员：收货
│   │   │   ├── dispatch_screen.dart      # 工作人员：出货
│   │   │   └── pickup_code_screen.dart   # 工作人员：提货码
│   │   │
│   │   ├── dispatch/
│   │   │   └── emergency_screen.dart     # 工作人员：紧急调货
│   │   │
│   │   ├── payment/
│   │   │   └── alipay_screen.dart        # 支付宝支付
│   │   │
│   │   └── profile/
│   │       ├── profile_screen.dart
│   │       ├── deposit_screen.dart       # 保证金管理（农户）
│   │       └── settlement_screen.dart    # 结算明细（农户）
│   │
│   ├── widgets/                      # 可复用组件
│   │   ├── common/
│   │   │   ├── app_bar.dart
│   │   │   ├── bottom_nav_bar.dart
│   │   │   └── loading_dialog.dart
│   │   │
│   │   ├── order/
│   │   │   ├── order_card.dart
│   │   │   ├── order_status_badge.dart
│   │   │   └── order_timeline.dart
│   │   │
│   │   └── market/
│   │       ├── photo_upload.dart
│   │       ├── weight_input.dart
│   │       └── grade_selector.dart
│   │
│   ├── utils/                        # 工具函数
│   │   ├── logger.dart
│   │   ├── validators.dart
│   │   ├── formatters.dart
│   │   └── constants.dart
│   │
│   ├── assets/                       # 资源
│   │   ├── images/
│   │   ├── icons/
│   │   └── fonts/
│   │
│   └── app.dart                      # App 主体（路由配置）
│
├── android/                          # Android 原生代码
│   └── app/
│       └── build.gradle              # Android 配置
│
├── ios/                              # iOS 原生代码
│   └── Runner/
│       └── Info.plist                # iOS 配置
│
├── pubspec.yaml                      # Flutter 依赖管理
├── pubspec.lock                      # 依赖锁定版本
└── analysis_options.yaml              # Dart 代码分析配置
```

---

## 三、核心依赖安装

### 3.1 编辑 pubspec.yaml
```yaml
dependencies:
  flutter:
    sdk: flutter

  # 网络请求
  dio: ^5.3.0                         # HTTP 客户端

  # 状态管理
  get: ^4.6.5                         # GetX 框架（推荐）
  # 或 provider: ^6.0.0               # Provider（备选）

  # 数据存储
  get_storage: ^2.1.0                 # 本地存储
  shared_preferences: ^2.1.0          # SharedPreferences

  # UI 组件
  flutter_screenutil: ^5.8.0          # 屏幕适配
  pull_to_refresh: ^2.0.0             # 下拉刷新
  smooth_page_indicator: ^1.0.0       # 页面指示器

  # 支付宝集成
  fluttertoast: ^8.2.0                # Toast 提示
  # 支付宝官方 Flutter plugin：
  alipay_flutter_plugin: ^0.0.5        # 支付宝支付

  # 图片处理
  image_picker: ^0.8.7                # 图片选择器
  image_cropper: ^3.0.0               # 图片裁剪
  cached_network_image: ^3.2.0        # 图片缓存

  # 地图和导航
  url_launcher: ^6.1.0                # URL 跳转
  amap_flutter_base: ^3.1.0           # 高德地图

  # 权限管理
  permission_handler: ^11.4.0         # 权限申请

  # 日期时间
  intl: ^0.18.0                       # 国际化

  # 实名认证（阿里云）
  # 需要联系阿里云获取 Flutter SDK
  # aliyun_realname_flutter: ^x.x.x

  # 极光推送
  jpush_flutter: ^3.4.0               # 推送通知

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_linter: ^2.0.0
```

### 3.2 安装依赖
```bash
cd needs_app
flutter pub get
```

---

## 四、关键特性实现

### 4.1 多角色 App 架构

**一个项目，三个 App：**
```
main.dart
    ↓
根据 App Flavor 选择入口
    ├── Farmer App      (agriculture flavor)
    ├── Buyer App       (buyer flavor)
    └── Worker App      (worker flavor)
```

**实现方式：**
```bash
# 在 flutter 命令中指定 flavor
flutter run --flavor=farmer -t lib/main_farmer.dart
flutter run --flavor=buyer -t lib/main_buyer.dart
flutter run --flavor=worker -t lib/main_worker.dart
```

### 4.2 认证流程（JWT + LocalStorage）

```dart
// lib/services/auth_service.dart

class AuthService {
  final storage = GetStorage();

  // 注册
  Future<bool> register(String phone, String password) async {
    try {
      final response = await dio.post(
        '/api/auth/register',
        data: {'phone': phone, 'password': password},
      );

      // 保存 token
      await storage.write('token', response.data['token']);
      await storage.write('user_id', response.data['user_id']);

      return true;
    } catch (e) {
      return false;
    }
  }

  // 登录
  Future<bool> login(String phone, String password) async {
    try {
      final response = await dio.post(
        '/api/auth/login',
        data: {'phone': phone, 'password': password},
      );

      await storage.write('token', response.data['token']);
      return true;
    } catch (e) {
      return false;
    }
  }

  // 获取 token
  String? getToken() => storage.read('token');

  // 退出登录
  Future<void> logout() async {
    await storage.remove('token');
    await storage.remove('user_id');
  }
}
```

### 4.3 支付宝支付集成

```dart
// lib/services/alipay_service.dart

import 'package:alipay_flutter_plugin/alipay_flutter_plugin.dart';

class AlipayService {
  // 发起支付
  Future<bool> pay(String orderInfo) async {
    try {
      // orderInfo 由后端生成的支付宝签名字符串
      final result = await AlipayFlutterPlugin.startAlipaySDK(orderInfo);

      if (result == "9000") {
        // 支付成功
        return true;
      } else if (result == "6001") {
        // 用户取消
        return false;
      } else {
        // 其他错误
        return false;
      }
    } catch (e) {
      print('支付异常: $e');
      return false;
    }
  }
}
```

### 4.4 实时状态更新（GetX）

```dart
// lib/providers/order_provider.dart

import 'package:get/get.dart';

class OrderController extends GetxController {
  var orders = <Order>[].obs;  // 响应式列表
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  fetchOrders() async {
    isLoading.value = true;
    try {
      final response = await ApiService().getOrders();
      orders.value = response.data;
    } finally {
      isLoading.value = false;
    }
  }

  // 创建订单
  createOrder(Order order) async {
    try {
      final response = await ApiService().createOrder(order);
      orders.add(response.data);
      Get.snackbar('成功', '订单已创建');
    } catch (e) {
      Get.snackbar('失败', '创建失败: $e');
    }
  }
}
```

### 4.5 工作人员 App 特殊功能

```dart
// lib/screens/market/receiving_screen.dart

class MarketReceivingScreen extends StatefulWidget {
  @override
  State<MarketReceivingScreen> createState() => _MarketReceivingScreenState();
}

class _MarketReceivingScreenState extends State<MarketReceivingScreen> {
  // 扫描二维码（订单号）
  Future<void> _scanOrderQR() async {
    final result = await barcodeScan.scan();
    // 根据扫描结果获取订单详情
  }

  // 拍照（上传 3 张图片）
  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    // 上传到后端
  }

  // 过磅后输入重量
  Future<void> _inputWeight() async {
    // 显示输入框
  }

  // 确认入库
  Future<void> _confirmReceiving() async {
    // 调用后端 API
  }
}
```

---

## 五、第一周 Flutter 开发清单

### Day 1
- [ ] Flutter 项目初始化 + 依赖安装
- [ ] 项目结构创建
- [ ] 主题配置（colors, fonts, etc）

### Day 2
- [ ] 认证页面（注册/登录）
- [ ] 实名认证集成（阿里云）
- [ ] JWT token 本地存储

### Day 3
- [ ] 首页布局
- [ ] 订单列表页面
- [ ] 订单详情页面

### Day 4
- [ ] 创建订单页面（AI 对话集成）
- [ ] 支付宝支付集成
- [ ] 支付回调处理

### Day 5
- [ ] 农户特定功能：保证金管理
- [ ] 农户特定功能：取消订单
- [ ] 工作人员特定功能：收货流程

### Day 6
- [ ] 工作人员特定功能：提货码核验
- [ ] 代理人电话集成
- [ ] 紧急调货功能

### Day 7
- [ ] 集成测试
- [ ] Bug 修复
- [ ] 灰度准备

---

## 六、常用 Flutter 命令

```bash
# 项目管理
flutter create needs_app                # 创建项目
flutter pub get                         # 获取依赖
flutter pub upgrade                     # 升级依赖
flutter clean                           # 清理构建文件

# 开发运行
flutter run                             # 运行应用
flutter run -d chrome                   # 运行到 Web（调试）
flutter run --flavor=farmer             # 运行特定 flavor

# 编译构建
flutter build apk                       # 构建 Android APK
flutter build appbundle                 # 构建 Android Bundle（Play Store）
flutter build ios                       # 构建 iOS（需要 Mac）
flutter build web                       # 构建 Web 版本

# 代码质量
flutter analyze                         # 代码分析
flutter test                            # 单元测试
dartfmt -r lib/                         # 代码格式化

# 实机调试
flutter devices                         # 列出连接的设备
flutter install                         # 安装到设备
```

---

## 七、iOS 原生配置

### 7.1 编辑 ios/Podfile（支付宝）
```ruby
target 'Runner' do
  # 支付宝
  pod 'AlipaySDK-iOS'
end
```

### 7.2 编辑 ios/Runner/Info.plist
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>alipay</string>
        </array>
    </dict>
</array>
```

### 7.3 运行
```bash
cd ios
pod install
cd ..
flutter run
```

---

## 八、Android 原生配置

### 8.1 编辑 android/app/build.gradle（支付宝）
```gradle
dependencies {
    // 支付宝
    implementation 'com.alipay.android:alipay-sdk-android:latest.release'
}
```

### 8.2 编辑 android/app/src/main/AndroidManifest.xml
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.CAMERA" />
```

---

## 九、API 集成示例

### 9.1 创建 API Service
```dart
// lib/services/api_service.dart

import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';

class ApiService {
  late Dio dio;
  final storage = GetStorage();

  ApiService() {
    dio = Dio(BaseOptions(
      baseUrl: 'http://localhost:8000/api',
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
    ));

    // 添加 token 到请求头
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = storage.read('token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (e, handler) {
          if (e.response?.statusCode == 401) {
            // token 过期，跳转到登录
            Get.offAllNamed('/login');
          }
          return handler.next(e);
        },
      ),
    );
  }

  // 获取订单列表
  Future<Response> getOrders() => dio.get('/orders');

  // 创建订单
  Future<Response> createOrder(Map<String, dynamic> data) {
    return dio.post('/orders/create', data: data);
  }

  // 订单支付（获取支付宝订单信息）
  Future<Response> getPaymentInfo(int orderId) {
    return dio.get('/orders/$orderId/payment');
  }
}
```

### 9.2 在页面中使用
```dart
// lib/screens/order/create_order_screen.dart

class CreateOrderScreen extends StatelessWidget {
  final apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('创建订单')),
      body: Column(
        children: [
          // 表单字段...
          ElevatedButton(
            onPressed: _submitOrder,
            child: Text('提交订单'),
          ),
        ],
      ),
    );
  }

  _submitOrder() async {
    try {
      final response = await apiService.createOrder({
        'product': 'flower',
        'quantity': 100,
        'price': 3.45,
      });

      Get.snackbar('成功', '订单已创建');
    } catch (e) {
      Get.snackbar('失败', '$e');
    }
  }
}
```

---

## 十、离线能力 & 错误处理

### 10.1 离线存储
```dart
// 订单草稿本地保存
final storage = GetStorage();
storage.write('draft_order', order.toJson());

// 离线时读取
final draft = storage.read('draft_order');
```

### 10.2 网络状态监听
```dart
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkService {
  final connectivity = Connectivity();

  Stream<ConnectivityResult> get onConnectivityChanged {
    return connectivity.onConnectivityChanged;
  }

  Future<bool> isConnected() async {
    final result = await connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }
}
```

---

## 十一、构建和上架

### 11.1 Android APK 构建
```bash
# 生成签名密钥
keytool -genkey -v -keystore ~/key.jks -alias key -keyalg RSA -keysize 2048 -validity 10000

# 配置签名
# 编辑 android/app/build.gradle

# 构建
flutter build apk --release
# 输出: build/app/outputs/apk/release/app-release.apk
```

### 11.2 iOS 构建
```bash
flutter build ios --release
# 需要 Mac 环境和 Apple 开发者账号
```

### 11.3 上架
- **Android**：上传到 Google Play 或各应用商店
- **iOS**：提交到 App Store (需要苹果开发者账号 ¥99/年)

---

## 十二、关键 Flutter 最佳实践

| 项 | 最佳实践 |
|----|--------|
| 状态管理 | 使用 GetX（简单高效）|
| API 调用 | 使用 Dio + 拦截器（处理 token） |
| 本地存储 | GetStorage（轻量级）+ SharedPreferences（标准）|
| 图片加载 | CachedNetworkImage（带缓存） |
| 列表性能 | ListView.builder（虚拟化列表） |
| 错误处理 | try-catch + 用户友好提示 |
| 权限申请 | permission_handler + 使用前检查 |
| 国际化 | intl 包 + Localizations |

---

## 十三、团队开发约定

```
代码风格：
- 文件名：snake_case (my_file.dart)
- 类名：PascalCase (MyClass)
- 变量名：camelCase (myVariable)
- 常量：camelCase 前加 const

文件位置：
- screens/ 放页面
- widgets/ 放可复用组件
- services/ 放业务逻辑
- models/ 放数据模型

Git 提交：
git checkout -b feature/order-list
git commit -m "feat: add order list screen"
git push origin feature/order-list
```

---

## 十四、第一周交付物

- ✅ Flutter 项目完整初始化 + 依赖安装
- ✅ 项目目录结构搭建
- ✅ 认证系统（注册/登录/JWT 存储）
- ✅ 支付宝支付集成测试通过
- ✅ 订单列表和详情页面
- ✅ 农户特定功能框架（保证金）
- ✅ 工作人员特定功能框架（收货）
- ✅ API 集成示例代码
- ✅ 代码提交到 Git develop 分支

---

> 💡 **建议**：第 1 周专注于 **认证系统 + API 对接**，确保网络通信正常。第 2-3 周再做 UI 和各个功能页面。

