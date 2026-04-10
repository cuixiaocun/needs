# Flutter 可复用 UI 组件库使用指南

## 概述

该项目包含一套完整的、生产就绪的 Flutter UI 组件库，提供了一致的设计系统和用户体验。所有文案均为简体中文。

## 组件列表

### 1. CustomButton - 自定义按钮

支持主操作按钮和次操作按钮，可选择 icon + label、loading 状态、disabled 状态。

#### 主操作按钮（深绿背景）
```dart
import 'package:needs_app/widgets/common/custom_button.dart';

CustomButton(
  label: '确认',
  onPressed: () {
    print('按钮被点击');
  },
  isPrimary: true,
)
```

#### 次操作按钮（边框样式）
```dart
CustomButton(
  label: '取消',
  onPressed: () {},
  isPrimary: false,
)
```

#### 带图标的按钮
```dart
CustomButton(
  label: '提交',
  icon: Icons.send,
  onPressed: () {},
  isPrimary: true,
)
```

#### Loading 状态
```dart
CustomButton(
  label: '加载中...',
  isLoading: true,
  isPrimary: true,
)
```

#### Disabled 状态
```dart
CustomButton(
  label: '禁用',
  isEnabled: false,
  isPrimary: true,
)
```

**属性：**
- `label` (String): 按钮文字
- `onPressed` (VoidCallback?): 点击回调
- `isPrimary` (bool): 是否为主操作按钮，默认 true
- `icon` (IconData?): 前缀图标
- `isLoading` (bool): 是否显示加载状态，默认 false
- `isEnabled` (bool): 是否启用，默认 true
- `width` (double?): 宽度，不设置时自适应
- `height` (double): 高度，默认 56dp
- `borderRadius` (double): 圆角，默认 12dp

---

### 2. CustomTextField - 自定义文本输入框

支持标签、前缀图标、后缀图标、验证器。焦点时显示深绿边框，错误时显示红色边框。

#### 基础输入框
```dart
import 'package:needs_app/widgets/common/custom_text_field.dart';

CustomTextField(
  label: '邮箱',
  hintText: '请输入邮箱地址',
)
```

#### 带验证器的输入框
```dart
CustomTextField(
  label: '邮箱',
  hintText: '请输入邮箱地址',
  keyboardType: TextInputType.emailAddress,
  validator: (value) {
    if (value == null || value.isEmpty) {
      return '邮箱不能为空';
    }
    if (!value.contains('@')) {
      return '请输入有效的邮箱地址';
    }
    return null;
  },
)
```

#### 密码输入框
```dart
CustomTextField(
  label: '密码',
  hintText: '请输入密码',
  isPassword: true,
)
```

#### 带前缀图标的输入框
```dart
CustomTextField(
  label: '用户名',
  prefixIcon: Icons.person,
  hintText: '请输入用户名',
)
```

**属性：**
- `label` (String?): 标签文字
- `hintText` (String?): 提示文字
- `controller` (TextEditingController?): 控制器
- `keyboardType` (TextInputType): 键盘类型，默认 TextInputType.text
- `isPassword` (bool): 是否为密码框，默认 false
- `prefixIcon` (IconData?): 前缀图标
- `suffixIcon` (IconData?): 后缀图标
- `validator` (Function?): 验证函数
- `maxLines` (int): 最大行数，默认 1
- `onChanged` (Function?): 内容变化回调
- `onSubmitted` (Function?): 提交回调

---

### 3. CustomCard - 自定义卡片

纯白背景、1dp 浅灰边框、12dp 圆角、0.5dp 阴影。支持 onTap、padding、InkWell 触碰反馈。

#### 基础卡片
```dart
import 'package:needs_app/widgets/common/custom_card.dart';

CustomCard(
  child: Text('卡片内容'),
)
```

#### 可点击的卡片
```dart
CustomCard(
  child: Column(
    children: [
      Text('商品名称'),
      Text('商品价格'),
    ],
  ),
  onTap: () {
    print('卡片被点击');
  },
)
```

#### 自定义 padding
```dart
CustomCard(
  padding: EdgeInsets.all(24.0),
  child: Text('自定义 padding 的卡片'),
)
```

**属性：**
- `child` (Widget): 子组件
- `onTap` (VoidCallback?): 点击回调
- `padding` (EdgeInsets?): 内部填充，默认 16x12dp
- `margin` (EdgeInsets?): 外部边距
- `borderRadius` (double): 圆角，默认 12dp
- `elevation` (double): 阴影深度，默认 0.5dp
- `backgroundColor` (Color): 背景色，默认白色
- `borderColor` (Color): 边框色，默认浅灰
- `borderWidth` (double): 边框宽度，默认 1dp

---

### 4. LoadingDialog - 加载对话框

显示加载对话框（中央圆形加载动画 + 文字）。

#### 显示加载对话框
```dart
import 'package:needs_app/widgets/common/loading_dialog.dart';

LoadingDialog.show(context, message: '加载中...');
```

#### 隐藏加载对话框
```dart
LoadingDialog.hide(context);
```

#### 在异步操作中使用
```dart
LoadingDialog.show(context, message: '提交中...');
try {
  await submitForm();
  LoadingDialog.hide(context);
  // 显示成功消息
} catch (e) {
  LoadingDialog.hide(context);
  // 显示错误消息
}
```

**方法：**
- `LoadingDialog.show(BuildContext, {String message})`: 显示加载对话框
- `LoadingDialog.hide(BuildContext)`: 隐藏加载对话框

---

### 5. ErrorDialog - 错误对话框

显示错误提示。

#### 显示错误对话框
```dart
import 'package:needs_app/widgets/common/error_dialog.dart';

ErrorDialog.show(
  context,
  title: '登录失败',
  message: '邮箱或密码错误，请重新输入',
  confirmButtonText: '重试',
  onConfirm: () {
    // 处理重试逻辑
  },
)
```

**方法：**
- `ErrorDialog.show(BuildContext, {String title, String message, String confirmButtonText, VoidCallback? onConfirm})`

---

## 设计系统

### 颜色定义 (AppColors)

```dart
import 'package:needs_app/config/colors.dart';

// 主色系
AppColors.primary        // #27AE60 (深绿)
AppColors.primaryDark    // #1E8449 (更深绿)
AppColors.primaryLight   // #52BE80 (浅绿)

// 文本色
AppColors.textPrimary    // #2C3E50 (深灰)
AppColors.textSecondary  // #7F8C8D (浅灰)
AppColors.textHint       // #BDBDC3 (提示文字色)

// 其他
AppColors.white          // #FFFFFF
AppColors.border         // #ECF0F1 (边框色)
AppColors.error          // #E74C3C (错误色)
AppColors.success        // #27AE60 (成功色)
AppColors.warning        // #F39C12 (警告色)
```

### 尺寸定义 (AppTheme)

```dart
import 'package:needs_app/config/colors.dart';

// 按钮
AppTheme.buttonHeight              // 56.0dp
AppTheme.buttonBorderRadius        // 12.0dp
AppTheme.buttonIconSize            // 20.0dp
AppTheme.buttonFontSize            // 16.0

// 输入框
AppTheme.textFieldHeight           // 56.0dp
AppTheme.textFieldBorderRadius     // 12.0dp
AppTheme.textFieldBorderWidth      // 1.0dp
AppTheme.textFieldFocusBorderWidth // 2.0dp

// 卡片
AppTheme.cardBorderRadius          // 12.0dp
AppTheme.cardBorderWidth           // 1.0dp
AppTheme.cardElevation             // 0.5dp
AppTheme.cardPaddingHorizontal     // 16.0dp
AppTheme.cardPaddingVertical       // 12.0dp

// 间距
AppTheme.paddingSmall              // 8.0dp
AppTheme.paddingMedium             // 16.0dp
AppTheme.paddingLarge              // 24.0dp
AppTheme.paddingXLarge             // 32.0dp

// 字体大小
AppTheme.fontSizeSmall             // 12.0
AppTheme.fontSizeMedium            // 14.0
AppTheme.fontSizeLarge             // 16.0
AppTheme.fontSizeXLarge            // 18.0
```

---

## 最佳实践

1. **导入组件时使用统一导出**
   ```dart
   import 'package:needs_app/widgets/common/index.dart';
   ```

2. **使用设计系统颜色和尺寸**
   ```dart
   // 好的做法
   Container(
     color: AppColors.primary,
     padding: EdgeInsets.all(AppTheme.paddingMedium),
   )

   // 避免硬编码
   Container(
     color: Color(0xFF27AE60),
     padding: EdgeInsets.all(16.0),
   )
   ```

3. **按钮状态管理**
   ```dart
   bool _isLoading = false;

   CustomButton(
     label: _isLoading ? '加载中...' : '提交',
     isLoading: _isLoading,
     isEnabled: !_isLoading,
     onPressed: () async {
       setState(() => _isLoading = true);
       try {
         await submitData();
       } finally {
         setState(() => _isLoading = false);
       }
     },
   )
   ```

4. **表单验证**
   ```dart
   final _formKey = GlobalKey<FormState>();

   Form(
     key: _formKey,
     child: Column(
       children: [
         CustomTextField(
           label: '邮箱',
           validator: (value) {
             if (value?.isEmpty ?? true) return '邮箱不能为空';
             if (!value!.contains('@')) return '邮箱格式不正确';
             return null;
           },
         ),
         CustomButton(
           label: '提交',
           onPressed: () {
             if (_formKey.currentState!.validate()) {
               // 提交表单
             }
           },
         ),
       ],
     ),
   )
   ```

---

## 文件位置

- 组件：`lib/widgets/common/`
- 设计系统：`lib/config/colors.dart` 和 `lib/config/index.dart`
- 导出：`lib/widgets/index.dart` 和 `lib/widgets/common/index.dart`

---

## 总结

该组件库提供了：
- ✅ 5 个核心 UI 组件（按钮、输入框、卡片、加载对话框、错误对话框）
- ✅ 完整的设计系统（颜色、尺寸、间距、字体）
- ✅ 所有文案使用简体中文
- ✅ 支持自定义样式和主题
- ✅ 生产就绪，无代码警告
- ✅ 易于扩展和维护
