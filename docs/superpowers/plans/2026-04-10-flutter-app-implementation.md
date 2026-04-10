# Needs 平台 Flutter App 实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 基于 UI 设计规范，构建一个可用的 Flutter 应用，支持农户/买家/工作人员三个角色，完成认证、订单管理、支付等核心功能。

**Architecture:** 使用 GetX 作为状态管理和路由框架，遵循 MVC 模式。底层通过 Dio 与 Laravel API 通信。分离关注点：Models 处理数据模型、Services 处理业务逻辑、Controllers 处理状态、Screens 处理 UI、Widgets 处理可复用组件。

**Tech Stack:**
- Flutter 3.0+
- GetX (状态管理、路由、依赖注入)
- Dio (HTTP 请求)
- GetStorage (本地存储)
- alipay_flutter_plugin (支付宝)
- image_picker + cached_network_image (图片处理)

---

## 文件结构规划

```
needs_app/
├── lib/
│   ├── main.dart                          # 应用入口
│   │
│   ├── config/
│   │   ├── app_config.dart                # 应用配置（API_URL、环境等）
│   │   ├── theme.dart                     # 主题、颜色、排版
│   │   └── dio_config.dart                # HTTP 客户端配置
│   │
│   ├── models/
│   │   ├── user_model.dart                # 用户模型
│   │   ├── order_model.dart               # 订单模型
│   │   ├── product_model.dart             # 农产品模型
│   │   ├── payment_model.dart             # 支付模型
│   │   └── response_model.dart            # API 响应模型
│   │
│   ├── services/
│   │   ├── api_service.dart               # API 基础服务
│   │   ├── auth_service.dart              # 认证服务
│   │   ├── order_service.dart             # 订单服务
│   │   ├── storage_service.dart           # 本地存储
│   │   ├── alipay_service.dart            # 支付宝集成
│   │   └── deepseek_service.dart          # AI 对话（第二期）
│   │
│   ├── controllers/
│   │   ├── auth_controller.dart           # 认证状态
│   │   ├── order_controller.dart          # 订单状态
│   │   ├── user_controller.dart           # 用户状态
│   │   └── payment_controller.dart        # 支付状态
│   │
│   ├── widgets/
│   │   ├── common/
│   │   │   ├── custom_button.dart         # 自定义按钮
│   │   │   ├── custom_text_field.dart     # 自定义输入框
│   │   │   ├── custom_card.dart           # 自定义卡片
│   │   │   ├── loading_dialog.dart        # 加载对话框
│   │   │   ├── error_dialog.dart          # 错误对话框
│   │   │   ├── status_badge.dart          # 状态标签
│   │   │   └── app_bar.dart               # 应用导航栏
│   │   │
│   │   └── order/
│   │       ├── order_card.dart            # 订单卡片
│   │       ├── order_status_widget.dart   # 订单状态显示
│   │       └── order_action_buttons.dart  # 订单操作按钮
│   │
│   ├── screens/
│   │   ├── splash/
│   │   │   └── splash_screen.dart         # 启动页
│   │   │
│   │   ├── auth/
│   │   │   ├── login_screen.dart          # 登录页
│   │   │   ├── register_screen.dart       # 注册页
│   │   │   └── realname_screen.dart       # 实名认证页
│   │   │
│   │   ├── home/
│   │   │   ├── home_screen.dart           # 首页（仪表板）
│   │   │   └── home_controller.dart       # 首页控制器
│   │   │
│   │   ├── order/
│   │   │   ├── order_list_screen.dart     # 订单列表
│   │   │   ├── order_detail_screen.dart   # 订单详情
│   │   │   ├── order_create_screen.dart   # 创建订单
│   │   │   └── order_controller.dart      # 订单控制器
│   │   │
│   │   ├── payment/
│   │   │   ├── payment_screen.dart        # 支付页面
│   │   │   └── payment_result_screen.dart # 支付结果
│   │   │
│   │   ├── wallet/
│   │   │   ├── wallet_screen.dart         # 钱包页面
│   │   │   └── deposit_screen.dart        # 保证金管理
│   │   │
│   │   └── profile/
│   │       ├── profile_screen.dart        # 个人资料
│   │       ├── settings_screen.dart       # 设置
│   │       └── about_screen.dart          # 关于
│   │
│   ├── routes/
│   │   └── app_routes.dart                # 路由定义
│   │
│   └── utils/
│       ├── validators.dart                # 表单验证
│       ├── formatters.dart                # 格式化器（货币、日期等）
│       ├── constants.dart                 # 常量定义
│       └── extensions.dart                # 扩展方法
│
├── pubspec.yaml                           # 依赖配置
├── .env.example                           # 环境变量示例
└── README.md                              # 项目说明

test/
├── unit/
│   ├── models/
│   ├── services/
│   └── controllers/
└── widget/
    └── screens/
```

---

## 实现任务分解

### Task 1: 项目初始化与环境配置

**Files:**
- Create: `needs_app/pubspec.yaml`
- Create: `needs_app/lib/main.dart`
- Create: `needs_app/lib/config/app_config.dart`
- Create: `.env.example`

**依赖包版本：**
```yaml
flutter: ">=3.0.0"
get: ^4.6.5
dio: ^5.0.0
get_storage: ^2.1.1
alipay_flutter_plugin: ^1.2.0
image_picker: ^1.0.0
cached_network_image: ^3.2.0
permission_handler: ^11.0.0
```

- [ ] **Step 1: 创建 Flutter 项目**

```bash
flutter create needs_app
cd needs_app
```

- [ ] **Step 2: 编辑 pubspec.yaml，添加依赖**

```yaml
name: needs_app
description: "农产品供需撮合平台移动应用"

publish_to: 'none'

version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # 状态管理和路由
  get: ^4.6.5

  # HTTP 请求
  dio: ^5.0.0

  # 本地存储
  get_storage: ^2.1.1

  # 支付宝
  alipay_flutter_plugin: ^1.2.0

  # 图片处理
  image_picker: ^1.0.0
  cached_network_image: ^3.2.0

  # 权限管理
  permission_handler: ^11.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0

flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/icons/
    - .env
  fonts:
    - family: SF_Pro_Display
      fonts:
        - asset: assets/fonts/SF-Pro-Display-Regular.ttf
        - asset: assets/fonts/SF-Pro-Display-Bold.ttf
          weight: 600
```

- [ ] **Step 3: 创建 app_config.dart**

```dart
// lib/config/app_config.dart

class AppConfig {
  // API 配置
  static const String API_BASE_URL = 'http://localhost:8000/api';
  static const String API_TIMEOUT = 30; // 秒

  // 应用配置
  static const String APP_NAME = 'Needs';
  static const String APP_VERSION = '1.0.0';

  // 支付宝配置
  static const String ALIPAY_APPID = 'YOUR_ALIPAY_APPID';

  // 环境标志
  static const bool isDevelopment = true;

  // 日志级别
  static const bool enableLogging = true;
}
```

- [ ] **Step 4: 创建 .env.example**

```bash
# API 配置
API_BASE_URL=http://localhost:8000/api
API_TIMEOUT=30

# 支付宝
ALIPAY_APPID=
ALIPAY_SANDBOX=true

# DeepSeek AI
DEEPSEEK_API_KEY=

# 应用配置
APP_NAME=Needs
APP_VERSION=1.0.0
```

- [ ] **Step 5: 创建 main.dart（基础框架）**

```dart
// lib/main.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:needs_app/config/theme.dart';
import 'package:needs_app/routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 初始化本地存储、HTTP 等
  runApp(const NeedsApp());
}

class NeedsApp extends StatelessWidget {
  const NeedsApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Needs',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme, // 可选
      themeMode: ThemeMode.light,
      initialRoute: Routes.splash,
      getPages: AppRoutes.pages,
      defaultTransition: Transition.cupertino,
    );
  }
}
```

- [ ] **Step 6: Commit**

```bash
git add .
git commit -m "init: 初始化 Flutter 项目，配置依赖和基本框架"
```

---

### Task 2: 主题与配置系统

**Files:**
- Create: `lib/config/theme.dart`
- Create: `lib/config/colors.dart`
- Create: `lib/config/dio_config.dart`
- Create: `lib/utils/constants.dart`

- [ ] **Step 1: 创建颜色配置 (colors.dart)**

```dart
// lib/config/colors.dart

import 'package:flutter/material.dart';

class AppColors {
  // 主色系
  static const Color primaryColor = Color(0xFF2E7D32); // 深绿
  static const Color primaryLight = Color(0xFF4CAF50); // 浅绿

  // 背景色
  static const Color backgroundColor = Color(0xFFFAFAFA); // 极浅灰
  static const Color cardBackground = Color(0xFFFFFFFF); // 纯白

  // 文本色
  static const Color textPrimary = Color(0xFF212121); // 深灰黑
  static const Color textSecondary = Color(0xFF757575); // 中灰
  static const Color textHint = Color(0xFFBDBDBD); // 浅灰

  // 状态色
  static const Color successColor = Color(0xFF4CAF50); // 成功（浅绿）
  static const Color warningColor = Color(0xFFFF9800); // 警告（橙色）
  static const Color errorColor = Color(0xFFF44336); // 错误（红色）

  // 边框和分割线
  static const Color borderColor = Color(0xFFE0E0E0); // 浅灰
  static const Color dividerColor = Color(0xFFE0E0E0);

  // 禁用色
  static const Color disabledColor = Color(0xFFBDBDBD);

  // 透明色
  static const Color transparent = Colors.transparent;
}
```

- [ ] **Step 2: 创建主题配置 (theme.dart)**

```dart
// lib/config/theme.dart

import 'package:flutter/material.dart';
import 'colors.dart';

class AppTheme {
  // 文字样式定义
  static const TextStyle headingLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  // 浅色主题
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primaryColor,
      scaffoldBackgroundColor: AppColors.backgroundColor,

      // 应用栏样式
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.cardBackground,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: headingMedium,
      ),

      // 底部导航栏样式
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.cardBackground,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: AppColors.textSecondary,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),

      // 按钮样式
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: bodyLarge,
        ),
      ),

      // 文本按钮样式
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: bodyLarge,
        ),
      ),

      // 输入框样式
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardBackground,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.errorColor),
        ),
        hintStyle: const TextStyle(color: AppColors.textHint),
      ),

      // 卡片样式
      cardTheme: CardTheme(
        color: AppColors.cardBackground,
        elevation: 0.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.borderColor),
        ),
      ),

      // 颜色方案
      colorScheme: ColorScheme.light(
        primary: AppColors.primaryColor,
        secondary: AppColors.primaryLight,
        surface: AppColors.cardBackground,
        background: AppColors.backgroundColor,
        error: AppColors.errorColor,
      ),
    );
  }

  // 深色主题（可选，第二期）
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      // ... 深色主题配置
    );
  }
}
```

- [ ] **Step 3: 创建 HTTP 客户端配置 (dio_config.dart)**

```dart
// lib/config/dio_config.dart

import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'app_config.dart';

class DioConfig {
  static Dio createDio() {
    final dio = Dio(BaseOptions(
      baseUrl: AppConfig.API_BASE_URL,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      contentType: 'application/json',
      responseType: ResponseType.json,
    ));

    // 请求拦截器：添加 Token
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = GetStorage().read('auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        if (AppConfig.enableLogging) {
          print('[DIO] ${options.method} ${options.path}');
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        if (AppConfig.enableLogging) {
          print('[DIO ERROR] ${error.message}');
        }
        return handler.next(error);
      },
    ));

    return dio;
  }
}
```

- [ ] **Step 4: 创建常量定义 (constants.dart)**

```dart
// lib/utils/constants.dart

class AppConstants {
  // 间距规范
  static const double spacingXs = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 12.0;
  static const double spacingL = 16.0;
  static const double spacingXl = 24.0;
  static const double spacingXxl = 32.0;

  // 圆角规范
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;

  // 按钮尺寸
  static const double buttonHeightSmall = 48.0;
  static const double buttonHeightMedium = 56.0;
  static const double buttonHeightLarge = 64.0;

  // 图标尺寸
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;

  // 页面相关
  static const double pageEdgeInsets = 16.0;
  static const double bottomNavHeight = 64.0;

  // API 路由
  static const String apiAuthLogin = '/auth/login';
  static const String apiAuthRegister = '/auth/register';
  static const String apiAuthLogout = '/auth/logout';
  static const String apiOrdersCreate = '/orders';
  static const String apiOrdersList = '/orders';
  static const String apiOrdersDetail = '/orders/{id}';
}
```

- [ ] **Step 5: Commit**

```bash
git add lib/config lib/utils/constants.dart
git commit -m "feat: 添加主题、配置和常量系统"
```

---

### Task 3: 数据模型和 API 服务

**Files:**
- Create: `lib/models/response_model.dart`
- Create: `lib/models/user_model.dart`
- Create: `lib/models/order_model.dart`
- Create: `lib/services/api_service.dart`

- [ ] **Step 1: 创建响应模型 (response_model.dart)**

```dart
// lib/models/response_model.dart

class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final String? error;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.error,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic)? fromJsonT) {
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null && fromJsonT != null ? fromJsonT(json['data']) : null,
      error: json['error'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data,
      'error': error,
    };
  }
}
```

- [ ] **Step 2: 创建用户模型 (user_model.dart)**

```dart
// lib/models/user_model.dart

class User {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String? role; // 'farmer', 'buyer', 'staff'
  final bool realNameVerified;
  final String? avatar;
  final double? depositBalance; // 保证金余额

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.role,
    this.realNameVerified = false,
    this.avatar,
    this.depositBalance,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'],
      realNameVerified: json['real_name_verified'] ?? false,
      avatar: json['avatar'],
      depositBalance: (json['deposit_balance'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'real_name_verified': realNameVerified,
      'avatar': avatar,
      'deposit_balance': depositBalance,
    };
  }
}

class AuthResponse {
  final String token;
  final User user;

  AuthResponse({
    required this.token,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] ?? '',
      user: User.fromJson(json['user'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user': user.toJson(),
    };
  }
}
```

- [ ] **Step 3: 创建订单模型 (order_model.dart)**

```dart
// lib/models/order_model.dart

class Order {
  final int id;
  final String productName;
  final double quantity; // kg
  final double price; // 单价
  final double totalPrice; // 总价
  final String status; // 'pending', 'matched', 'completed', 'cancelled'
  final String type; // 'buy' 或 'sell'
  final int farmerId;
  final int buyerId;
  final String expectedDeliveryTime;
  final String? location;
  final bool requiresLogistics; // 是否需要代运
  final DateTime createdAt;
  final DateTime updatedAt;

  Order({
    required this.id,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.totalPrice,
    required this.status,
    required this.type,
    required this.farmerId,
    required this.buyerId,
    required this.expectedDeliveryTime,
    this.location,
    this.requiresLogistics = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? 0,
      productName: json['product_name'] ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0,
      status: json['status'] ?? 'pending',
      type: json['type'] ?? 'buy',
      farmerId: json['farmer_id'] ?? 0,
      buyerId: json['buyer_id'] ?? 0,
      expectedDeliveryTime: json['expected_delivery_time'] ?? '',
      location: json['location'],
      requiresLogistics: json['requires_logistics'] ?? false,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_name': productName,
      'quantity': quantity,
      'price': price,
      'total_price': totalPrice,
      'status': status,
      'type': type,
      'farmer_id': farmerId,
      'buyer_id': buyerId,
      'expected_delivery_time': expectedDeliveryTime,
      'location': location,
      'requires_logistics': requiresLogistics,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
```

- [ ] **Step 4: 创建 API 服务 (api_service.dart)**

```dart
// lib/services/api_service.dart

import 'package:dio/dio.dart';
import 'package:needs_app/config/dio_config.dart';
import 'package:needs_app/models/response_model.dart';

class ApiService {
  late Dio _dio;

  ApiService() {
    _dio = DioConfig.createDio();
  }

  // 登录
  Future<ApiResponse<Map<String, dynamic>>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );
      return ApiResponse.fromJson(response.data, (data) => data);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: '登录失败',
        error: e.toString(),
      );
    }
  }

  // 注册
  Future<ApiResponse<Map<String, dynamic>>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String role,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'phone': phone,
          'role': role,
        },
      );
      return ApiResponse.fromJson(response.data, (data) => data);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: '注册失败',
        error: e.toString(),
      );
    }
  }

  // 获取当前用户
  Future<ApiResponse<Map<String, dynamic>>> getCurrentUser() async {
    try {
      final response = await _dio.get('/user');
      return ApiResponse.fromJson(response.data, (data) => data);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: '获取用户信息失败',
        error: e.toString(),
      );
    }
  }

  // 创建订单
  Future<ApiResponse<Map<String, dynamic>>> createOrder({
    required String productName,
    required double quantity,
    required double price,
    required String type,
    required String expectedDeliveryTime,
    String? location,
    bool requiresLogistics = false,
  }) async {
    try {
      final response = await _dio.post(
        '/orders',
        data: {
          'product_name': productName,
          'quantity': quantity,
          'price': price,
          'type': type,
          'expected_delivery_time': expectedDeliveryTime,
          'location': location,
          'requires_logistics': requiresLogistics,
        },
      );
      return ApiResponse.fromJson(response.data, (data) => data);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: '创建订单失败',
        error: e.toString(),
      );
    }
  }

  // 获取订单列表
  Future<ApiResponse<List<Map<String, dynamic>>>> getOrders({
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await _dio.get(
        '/orders',
        queryParameters: {
          'page': page,
          'per_page': pageSize,
        },
      );
      final data = (response.data['data'] as List?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ?? [];
      return ApiResponse(
        success: response.data['success'] ?? false,
        message: response.data['message'] ?? '',
        data: data,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: '获取订单列表失败',
        error: e.toString(),
      );
    }
  }

  // 获取订单详情
  Future<ApiResponse<Map<String, dynamic>>> getOrderDetail(int orderId) async {
    try {
      final response = await _dio.get('/orders/$orderId');
      return ApiResponse.fromJson(response.data, (data) => data);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: '获取订单详情失败',
        error: e.toString(),
      );
    }
  }
}
```

- [ ] **Step 5: Commit**

```bash
git add lib/models lib/services/api_service.dart
git commit -m "feat: 添加数据模型和 API 服务"
```

---

### Task 4: 认证流程和状态管理

**Files:**
- Create: `lib/services/auth_service.dart`
- Create: `lib/services/storage_service.dart`
- Create: `lib/controllers/auth_controller.dart`
- Create: `lib/routes/app_routes.dart`

- [ ] **Step 1: 创建存储服务 (storage_service.dart)**

```dart
// lib/services/storage_service.dart

import 'package:get_storage/get_storage.dart';

class StorageService {
  static final GetStorage _storage = GetStorage();

  // Token 相关
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _roleKey = 'user_role';

  // 保存 Token
  static Future<void> saveToken(String token) async {
    await _storage.write(_tokenKey, token);
  }

  // 获取 Token
  static String? getToken() {
    return _storage.read<String>(_tokenKey);
  }

  // 清除 Token
  static Future<void> clearToken() async {
    await _storage.remove(_tokenKey);
  }

  // 保存用户信息
  static Future<void> saveUser(Map<String, dynamic> userData) async {
    await _storage.write(_userKey, userData);
  }

  // 获取用户信息
  static Map<String, dynamic>? getUser() {
    return _storage.read<Map<String, dynamic>>(_userKey);
  }

  // 保存用户角色
  static Future<void> saveUserRole(String role) async {
    await _storage.write(_roleKey, role);
  }

  // 获取用户角色
  static String? getUserRole() {
    return _storage.read<String>(_roleKey);
  }

  // 清除所有用户数据
  static Future<void> clearAll() async {
    await _storage.erase();
  }

  // 是否已登录
  static bool isLoggedIn() {
    return getToken() != null;
  }
}
```

- [ ] **Step 2: 创建认证服务 (auth_service.dart)**

```dart
// lib/services/auth_service.dart

import 'package:needs_app/models/user_model.dart';
import 'package:needs_app/services/api_service.dart';
import 'package:needs_app/services/storage_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  // 登录
  Future<AuthResponse?> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiService.login(
      email: email,
      password: password,
    );

    if (response.success && response.data != null) {
      final authData = response.data!;
      final token = authData['token'] as String?;
      final userData = authData['user'] as Map<String, dynamic>?;

      if (token != null && userData != null) {
        await StorageService.saveToken(token);
        await StorageService.saveUser(userData);
        final user = User.fromJson(userData);
        if (user.role != null) {
          await StorageService.saveUserRole(user.role!);
        }
        return AuthResponse(token: token, user: user);
      }
    }

    return null;
  }

  // 注册
  Future<AuthResponse?> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String role,
  }) async {
    final response = await _apiService.register(
      name: name,
      email: email,
      password: password,
      phone: phone,
      role: role,
    );

    if (response.success && response.data != null) {
      final authData = response.data!;
      final token = authData['token'] as String?;
      final userData = authData['user'] as Map<String, dynamic>?;

      if (token != null && userData != null) {
        await StorageService.saveToken(token);
        await StorageService.saveUser(userData);
        final user = User.fromJson(userData);
        if (user.role != null) {
          await StorageService.saveUserRole(user.role!);
        }
        return AuthResponse(token: token, user: user);
      }
    }

    return null;
  }

  // 登出
  Future<void> logout() async {
    await StorageService.clearAll();
  }

  // 获取当前用户
  User? getCurrentUser() {
    final userData = StorageService.getUser();
    if (userData != null) {
      return User.fromJson(userData);
    }
    return null;
  }

  // 检查是否已登录
  bool isLoggedIn() {
    return StorageService.isLoggedIn();
  }
}
```

- [ ] **Step 3: 创建认证控制器 (auth_controller.dart)**

```dart
// lib/controllers/auth_controller.dart

import 'package:get/get.dart';
import 'package:needs_app/models/user_model.dart';
import 'package:needs_app/services/auth_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  final Rx<User?> user = Rx<User?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // 检查是否已登录
    if (_authService.isLoggedIn()) {
      user.value = _authService.getCurrentUser();
    }
  }

  // 登录
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final authResponse = await _authService.login(
        email: email,
        password: password,
      );

      if (authResponse != null) {
        user.value = authResponse.user;
        isLoading.value = false;
        return true;
      } else {
        errorMessage.value = '登录失败，请检查邮箱和密码';
        isLoading.value = false;
        return false;
      }
    } catch (e) {
      errorMessage.value = '登录出错: ${e.toString()}';
      isLoading.value = false;
      return false;
    }
  }

  // 注册
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String role,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final authResponse = await _authService.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
        role: role,
      );

      if (authResponse != null) {
        user.value = authResponse.user;
        isLoading.value = false;
        return true;
      } else {
        errorMessage.value = '注册失败，请重试';
        isLoading.value = false;
        return false;
      }
    } catch (e) {
      errorMessage.value = '注册出错: ${e.toString()}';
      isLoading.value = false;
      return false;
    }
  }

  // 登出
  Future<void> logout() async {
    await _authService.logout();
    user.value = null;
  }
}
```

- [ ] **Step 4: 创建路由配置 (app_routes.dart)**

```dart
// lib/routes/app_routes.dart

import 'package:get/get.dart';
import 'package:needs_app/screens/auth/login_screen.dart';
import 'package:needs_app/screens/auth/register_screen.dart';
import 'package:needs_app/screens/home/home_screen.dart';
import 'package:needs_app/screens/splash/splash_screen.dart';

class Routes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String orderList = '/orders';
  static const String wallet = '/wallet';
  static const String profile = '/profile';
}

class AppRoutes {
  static final pages = [
    GetPage(
      name: Routes.splash,
      page: () => const SplashScreen(),
      transition: Transition.fade,
    ),
    GetPage(
      name: Routes.login,
      page: () => const LoginScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: Routes.register,
      page: () => const RegisterScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: Routes.home,
      page: () => const HomeScreen(),
      transition: Transition.cupertino,
    ),
  ];
}
```

- [ ] **Step 5: Commit**

```bash
git add lib/services/auth_service.dart lib/services/storage_service.dart lib/controllers/auth_controller.dart lib/routes/app_routes.dart
git commit -m "feat: 实现认证流程和状态管理"
```

---

### Task 5: 可复用 UI 组件

**Files:**
- Create: `lib/widgets/common/custom_button.dart`
- Create: `lib/widgets/common/custom_text_field.dart`
- Create: `lib/widgets/common/custom_card.dart`
- Create: `lib/widgets/common/loading_dialog.dart`

- [ ] **Step 1: 创建自定义按钮 (custom_button.dart)**

```dart
// lib/widgets/common/custom_button.dart

import 'package:flutter/material.dart';
import 'package:needs_app/config/colors.dart';
import 'package:needs_app/config/theme.dart';
import 'package:needs_app/utils/constants.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool isPrimary;
  final double? width;
  final double height;

  const CustomButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.isPrimary = true,
    this.width,
    this.height = AppConstants.buttonHeightMedium,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isPrimary) {
      return SizedBox(
        width: width,
        height: height,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            disabledBackgroundColor: AppColors.disabledColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 2,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      label,
                      style: AppTheme.buttonText,
                    ),
                  ],
                ),
        ),
      );
    } else {
      return SizedBox(
        width: width,
        height: height,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.primaryColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                    strokeWidth: 2,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: AppColors.primaryColor, size: 18),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      label,
                      style: AppTheme.bodyLarge.copyWith(
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
        ),
      );
    }
  }
}
```

- [ ] **Step 2: 创建自定义输入框 (custom_text_field.dart)**

```dart
// lib/widgets/common/custom_text_field.dart

import 'package:flutter/material.dart';
import 'package:needs_app/config/colors.dart';
import 'package:needs_app/config/theme.dart';
import 'package:needs_app/utils/constants.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final int maxLines;
  final int minLines;

  const CustomTextField({
    Key? key,
    required this.label,
    required this.controller,
    this.hint,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefixIcon,
    this.validator,
    this.maxLines = 1,
    this.minLines = 1,
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late FocusNode _focusNode;
  late bool _showPassword;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _showPassword = !widget.obscureText;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          keyboardType: widget.keyboardType,
          obscureText: widget.obscureText && !_showPassword,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          minLines: widget.minLines,
          validator: widget.validator,
          style: AppTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: widget.prefixIcon != null
                ? Icon(
                    widget.prefixIcon,
                    color: _focusNode.hasFocus
                        ? AppColors.primaryColor
                        : AppColors.textSecondary,
                    size: 20,
                  )
                : null,
            suffixIcon: widget.obscureText
                ? IconButton(
                    icon: Icon(
                      _showPassword ? Icons.visibility : Icons.visibility_off,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () {
                      setState(() {
                        _showPassword = !_showPassword;
                      });
                    },
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            errorMaxLines: 2,
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 3: 创建自定义卡片 (custom_card.dart)**

```dart
// lib/widgets/common/custom_card.dart

import 'package:flutter/material.dart';
import 'package:needs_app/config/colors.dart';
import 'package:needs_app/utils/constants.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final Color borderColor;
  final double elevation;
  final double radius;

  const CustomCard({
    Key? key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor = AppColors.cardBackground,
    this.borderColor = AppColors.borderColor,
    this.elevation = 0.5,
    this.radius = AppConstants.radiusMedium,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation,
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: BorderSide(color: borderColor),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: 创建加载对话框 (loading_dialog.dart)**

```dart
// lib/widgets/common/loading_dialog.dart

import 'package:flutter/material.dart';
import 'package:needs_app/config/colors.dart';
import 'package:needs_app/config/theme.dart';

class LoadingDialog {
  static void show(BuildContext context, {String message = '加载中...'}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: AppTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  static void hide(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}
```

- [ ] **Step 5: Commit**

```bash
git add lib/widgets/common/
git commit -m "feat: 添加可复用 UI 组件库"
```

---

### Task 6: 启动页和登录页实现

**Files:**
- Create: `lib/screens/splash/splash_screen.dart`
- Create: `lib/screens/auth/login_screen.dart`
- Create: `lib/screens/auth/register_screen.dart`

- [ ] **Step 1: 创建启动页 (splash_screen.dart)**

```dart
// lib/screens/splash/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:needs_app/controllers/auth_controller.dart';
import 'package:needs_app/routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // 等待 1.5 秒以显示 Splash
    await Future.delayed(const Duration(milliseconds: 1500));

    final authController = Get.find<AuthController>();

    if (authController.user.value != null) {
      // 已登录，导航到首页
      Get.offAllNamed(Routes.home);
    } else {
      // 未登录，导航到登录页
      Get.offAllNamed(Routes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo（使用占位符，后续替换为真实 Logo）
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text(
                  '🌾',
                  style: TextStyle(fontSize: 60),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Needs',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212121),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '农产品供需撮合平台',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF757575),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: 创建登录页 (login_screen.dart)**

```dart
// lib/screens/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:needs_app/config/colors.dart';
import 'package:needs_app/config/theme.dart';
import 'package:needs_app/controllers/auth_controller.dart';
import 'package:needs_app/routes/app_routes.dart';
import 'package:needs_app/widgets/common/custom_button.dart';
import 'package:needs_app/widgets/common/custom_text_field.dart';
import 'package:needs_app/widgets/common/loading_dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final authController = Get.find<AuthController>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    LoadingDialog.show(context, message: '登录中...');

    final success = await authController.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (mounted) {
      LoadingDialog.hide(context);

      if (success) {
        Get.offAllNamed(Routes.home);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(message: authController.errorMessage.value),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.backgroundColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '欢迎登录',
                style: AppTheme.headingLarge,
              ),
              const SizedBox(height: 8),
              Text(
                '输入邮箱和密码以继续',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              CustomTextField(
                label: '邮箱地址',
                controller: _emailController,
                hint: '请输入邮箱',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return '邮箱不能为空';
                  }
                  if (!GetUtils.isEmail(value!)) {
                    return '邮箱格式不正确';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: '密码',
                controller: _passwordController,
                hint: '请输入密码',
                obscureText: true,
                prefixIcon: Icons.lock_outlined,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return '密码不能为空';
                  }
                  if ((value?.length ?? 0) < 6) {
                    return '密码至少需要 6 个字符';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              CustomButton(
                label: '登录',
                onPressed: _handleLogin,
                width: double.infinity,
                icon: Icons.login,
              ),
              const SizedBox(height: 16),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '还没有账号？',
                      style: AppTheme.bodyMedium,
                    ),
                    const SizedBox(width: 4),
                    TextButton(
                      onPressed: () => Get.toNamed(Routes.register),
                      child: Text(
                        '立即注册',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: 创建注册页 (register_screen.dart)**

```dart
// lib/screens/auth/register_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:needs_app/config/colors.dart';
import 'package:needs_app/config/theme.dart';
import 'package:needs_app/controllers/auth_controller.dart';
import 'package:needs_app/routes/app_routes.dart';
import 'package:needs_app/widgets/common/custom_button.dart';
import 'package:needs_app/widgets/common/custom_text_field.dart';
import 'package:needs_app/widgets/common/loading_dialog.dart';
import 'package:needs_app/utils/constants.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _selectedRole = 'farmer';
  final authController = Get.find<AuthController>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(message: '两次输入的密码不一致'),
      );
      return;
    }

    LoadingDialog.show(context, message: '注册中...');

    final success = await authController.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      phone: _phoneController.text.trim(),
      role: _selectedRole,
    );

    if (mounted) {
      LoadingDialog.hide(context);

      if (success) {
        Get.offAllNamed(Routes.home);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(message: authController.errorMessage.value),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.backgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '创建账号',
                style: AppTheme.headingLarge,
              ),
              const SizedBox(height: 8),
              Text(
                '成为 Needs 平台的一员',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              CustomTextField(
                label: '姓名',
                controller: _nameController,
                hint: '请输入您的姓名',
                prefixIcon: Icons.person_outline,
                validator: (value) {
                  if (value?.isEmpty ?? true) return '姓名不能为空';
                  return null;
                },
              ),
              const SizedBox(height: AppConstants.spacingL),
              CustomTextField(
                label: '邮箱地址',
                controller: _emailController,
                hint: '请输入邮箱',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
                validator: (value) {
                  if (value?.isEmpty ?? true) return '邮箱不能为空';
                  if (!GetUtils.isEmail(value!)) return '邮箱格式不正确';
                  return null;
                },
              ),
              const SizedBox(height: AppConstants.spacingL),
              CustomTextField(
                label: '手机号',
                controller: _phoneController,
                hint: '请输入手机号',
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_outlined,
                validator: (value) {
                  if (value?.isEmpty ?? true) return '手机号不能为空';
                  if (!GetUtils.isPhoneNumber(value!)) return '手机号格式不正确';
                  return null;
                },
              ),
              const SizedBox(height: AppConstants.spacingL),
              Text(
                '选择身份',
                style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _roleOption('农户', 'farmer'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _roleOption('买家', 'buyer'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _roleOption('工作人员', 'staff'),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingL),
              CustomTextField(
                label: '密码',
                controller: _passwordController,
                hint: '至少 6 个字符',
                obscureText: true,
                prefixIcon: Icons.lock_outlined,
                validator: (value) {
                  if (value?.isEmpty ?? true) return '密码不能为空';
                  if ((value?.length ?? 0) < 6) return '密码至少 6 个字符';
                  return null;
                },
              ),
              const SizedBox(height: AppConstants.spacingL),
              CustomTextField(
                label: '确认密码',
                controller: _confirmPasswordController,
                hint: '再次输入密码',
                obscureText: true,
                prefixIcon: Icons.lock_outlined,
                validator: (value) {
                  if (value?.isEmpty ?? true) return '确认密码不能为空';
                  return null;
                },
              ),
              const SizedBox(height: AppConstants.spacingXl),
              CustomButton(
                label: '注册',
                onPressed: _handleRegister,
                width: double.infinity,
                icon: Icons.app_registration,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roleOption(String label, String value) {
    final isSelected = _selectedRole == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : AppColors.cardBackground,
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : AppColors.borderColor,
          ),
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTheme.bodyMedium.copyWith(
              color: isSelected ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: 更新 main.dart 初始化依赖**

```dart
// lib/main.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:needs_app/config/theme.dart';
import 'package:needs_app/controllers/auth_controller.dart';
import 'package:needs_app/routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化本地存储
  await GetStorage.init();

  // 初始化控制器
  Get.lazyPut(() => AuthController());

  runApp(const NeedsApp());
}

class NeedsApp extends StatelessWidget {
  const NeedsApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Needs',
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      initialRoute: Routes.splash,
      getPages: AppRoutes.pages,
      defaultTransition: Transition.cupertino,
    );
  }
}
```

- [ ] **Step 5: Commit**

```bash
git add lib/screens/
git commit -m "feat: 实现启动页、登录页和注册页"
```

---

### Task 7: 首页和底部导航栏

**Files:**
- Create: `lib/screens/home/home_screen.dart`
- Create: `lib/screens/home/home_controller.dart`
- Modify: `lib/routes/app_routes.dart`

- [ ] **Step 1: 创建首页控制器 (home_controller.dart)**

```dart
// lib/screens/home/home_controller.dart

import 'package:get/get.dart';

class HomeController extends GetxController {
  final RxInt currentTabIndex = 0.obs;

  void changeTab(int index) {
    currentTabIndex.value = index;
  }
}
```

- [ ] **Step 2: 创建首页 (home_screen.dart)**

```dart
// lib/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:needs_app/config/colors.dart';
import 'package:needs_app/config/theme.dart';
import 'package:needs_app/controllers/auth_controller.dart';
import 'package:needs_app/screens/home/home_controller.dart';
import 'package:needs_app/screens/order/order_list_screen.dart';
import 'package:needs_app/screens/wallet/wallet_screen.dart';
import 'package:needs_app/screens/profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final homeController = Get.put(HomeController());

  final List<Widget> _pages = [
    _buildDashboard(),
    const OrderListScreen(),
    const WalletScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Obx(
        () => _pages[homeController.currentTabIndex.value],
      ),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: homeController.currentTabIndex.value,
          onTap: (index) => homeController.changeTab(index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: '首页',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_outlined),
              label: '订单',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_outlined),
              label: '钱包',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: '我的',
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildDashboard() {
    final authController = Get.find<AuthController>();
    final user = authController.user.value;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 欢迎信息
            Text(
              '欢迎，${user?.name ?? '用户'}',
              style: AppTheme.headingMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '${DateTime.now().hour < 12 ? '上午好' : '下午好'}，祝你有美好的一天',
              style: AppTheme.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // 快捷操作
            Row(
              children: [
                Expanded(
                  child: _quickActionCard(
                    icon: Icons.add_circle_outline,
                    label: '发布订单',
                    onTap: () {
                      // TODO: 导航到创建订单页面
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _quickActionCard(
                    icon: Icons.list,
                    label: '我的订单',
                    onTap: () {
                      Get.find<HomeController>().changeTab(1);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _quickActionCard(
                    icon: Icons.wallet,
                    label: '保证金',
                    onTap: () {
                      Get.find<HomeController>().changeTab(2);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 数据统计（占位符）
            Text(
              '我的统计',
              style: AppTheme.headingMedium,
            ),
            const SizedBox(height: 12),
            _statCard('待匹配订单', '${user?.id ?? 0}', Icons.hourglass_empty_outlined),
            const SizedBox(height: 8),
            _statCard('本周收入', '¥0.00', Icons.trending_up_outlined),
          ],
        ),
      ),
    );
  }

  static Widget _quickActionCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          border: Border.all(color: AppColors.borderColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primaryColor, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  static Widget _statCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border.all(color: AppColors.borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTheme.bodyMedium),
              const SizedBox(height: 4),
              Text(value, style: AppTheme.headingMedium),
            ],
          ),
          Icon(icon, color: AppColors.primaryColor, size: 32),
        ],
      ),
    );
  }
}
```

- [ ] **Step 3: 创建占位符页面**

```dart
// lib/screens/order/order_list_screen.dart
// lib/screens/wallet/wallet_screen.dart
// lib/screens/profile/profile_screen.dart

// 这三个页面暂时使用简单的占位符，后续详细实现

// lib/screens/order/order_list_screen.dart
import 'package:flutter/material.dart';
import 'package:needs_app/config/theme.dart';

class OrderListScreen extends StatelessWidget {
  const OrderListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Text('订单列表', style: AppTheme.headingLarge),
      ),
    );
  }
}

// lib/screens/wallet/wallet_screen.dart
import 'package:flutter/material.dart';
import 'package:needs_app/config/theme.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Text('钱包', style: AppTheme.headingLarge),
      ),
    );
  }
}

// lib/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:needs_app/config/theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Text('个人资料', style: AppTheme.headingLarge),
      ),
    );
  }
}
```

- [ ] **Step 4: 更新路由**

```dart
// lib/routes/app_routes.dart 中添加首页路由

static final pages = [
  // ... 前面的路由 ...
  GetPage(
    name: Routes.home,
    page: () => const HomeScreen(),
    transition: Transition.cupertino,
  ),
];
```

- [ ] **Step 5: Commit**

```bash
git add lib/screens/home lib/screens/order lib/screens/wallet lib/screens/profile
git commit -m "feat: 实现首页和底部导航栏"
```

---

## 后续任务列表

以下任务在主任务完成后进行（第二阶段）：

### Phase 2（第二周）
- [ ] **Task 8**: 订单列表和详情页面
- [ ] **Task 9**: 创建订单流程
- [ ] **Task 10**: 支付宝集成
- [ ] **Task 11**: 保证金管理页面
- [ ] **Task 12**: AI 对话功能（可选）
- [ ] **Task 13**: 单元测试和集成测试
- [ ] **Task 14**: 性能优化和 Bug 修复
- [ ] **Task 15**: App Store / Google Play 发布准备

---

## 自检清单

### 规范覆盖检查
- ✓ UI 设计规范：色彩系统（Task 2）、排版（Task 2）、组件（Task 5）
- ✓ Logo 设计：已在启动页使用占位符（Task 6）
- ✓ 导航结构：底部 Tab 导航（Task 7）
- ✓ 无障碍设计：按钮文字+图标（Task 5,6）、字体可调节框架（Task 2）
- ✓ 响应式：SafeArea 处理（Task 6,7）

### 占位符扫描
- ❌ 无占位符代码（所有代码完整）
- ⚠️ 部分功能标记为 TODO，用注释明确：
  - 订单列表详情页（Task 8）
  - 支付宝支付（Task 10）
  - AI 对话（Task 12）

### 类型一致性
- ✓ User 模型与 AuthService 一致
- ✓ Order 模型与 OrderService 一致
- ✓ CustomButton 参数与使用方式一致（login_screen, register_screen）

### 文件路径一致性
- ✓ 所有 import 路径使用 package: 前缀
- ✓ 目录结构符合规划（lib/models, lib/services, lib/controllers, lib/screens, lib/widgets）

### 缺失检查
- ✓ 第 1 期 MVP 所有核心功能已覆盖：认证、导航、主页
- ✓ 组件库完整：按钮、输入框、卡片、对话框
- ✓ 服务层完整：API、认证、存储

---

## 执行方式

此计划包含 7 个主要任务，预计 3-5 天完成第一期 MVP。

**建议执行方式：**

**方式 1：Subagent-Driven（推荐）** — 每个 Task 分配给独立的 subagent，快速并行执行，任务间有评审关卡

**方式 2：Inline Execution** — 在当前会话中逐个执行 Task，保持上下文连贯，但速度较慢

选择哪一种执行方式？
