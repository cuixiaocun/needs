import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:needs_app/services/auth_service.dart';
import 'package:needs_app/services/storage_service.dart';

/// 认证状态控制器
/// 使用 GetX 进行状态管理，追踪认证相关的状态
class AuthController extends GetxController {
  final AuthService _authService;
  final Logger _logger = Logger();

  // 依赖注入
  AuthController({
    AuthService? authService,
    StorageService? storageService,
  })  : _authService = authService ?? AuthService() {
    // StorageService 仅在 AuthService 初始化时使用，不需要单独存储
  }

  // 当前用户信息 - Rx 变量
  final Rx<Map<String, dynamic>?> user = Rx(null);

  // 加载状态
  final RxBool isLoading = RxBool(false);

  // 错误信息
  final RxString errorMessage = RxString('');

  // 登录状态
  final RxBool isLoggedIn = RxBool(false);

  /// 初始化控制器
  @override
  void onInit() {
    super.onInit();
    _initializeAuthState();
  }

  /// 初始化认证状态
  /// 检查本地存储中是否有已登录的用户
  void _initializeAuthState() {
    _logger.i('Initializing auth state');

    if (_authService.isLoggedIn()) {
      final userInfo = _authService.getCurrentUser();
      if (userInfo != null) {
        user.value = userInfo;
        isLoggedIn.value = true;
        _logger.i('User already logged in: ${userInfo['phone']}');
      }
    } else {
      isLoggedIn.value = false;
      _logger.i('User not logged in');
    }
  }

  /// 登录
  /// 使用手机号和密码登录
  Future<bool> login({
    required String phone,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      _logger.i('Login attempt: $phone');

      final result = await _authService.login(
        phone: phone,
        password: password,
      );

      if (result['success'] == true) {
        // 更新用户信息
        if (result['data']?['user'] != null) {
          user.value = result['data']['user'];
          isLoggedIn.value = true;
          _logger.i('Login successful');
        }
        return true;
      } else {
        errorMessage.value = result['message'] ?? 'Login failed';
        _logger.w('Login failed: ${errorMessage.value}');
        return false;
      }
    } catch (e) {
      errorMessage.value = 'An error occurred: ${e.toString()}';
      _logger.e('Login error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// 注册
  /// 创建新账户
  Future<bool> register({
    required String name,
    required String phone,
    required String password,
    required String passwordConfirmation,
    required String role,
    String? email,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      _logger.i('Register attempt: $phone with role: $role');

      final result = await _authService.register(
        name: name,
        phone: phone,
        password: password,
        passwordConfirmation: passwordConfirmation,
        role: role,
        email: email,
      );

      if (result['success'] == true) {
        // 自动登录
        if (result['data']?['user'] != null) {
          user.value = result['data']['user'];
          isLoggedIn.value = true;
          _logger.i('Registration successful and auto-logged in');
        }
        return true;
      } else {
        errorMessage.value = result['message'] ?? 'Registration failed';
        _logger.w('Registration failed: ${errorMessage.value}');
        return false;
      }
    } catch (e) {
      errorMessage.value = 'An error occurred: ${e.toString()}';
      _logger.e('Register error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// 登出
  /// 清除用户数据和认证信息
  Future<void> logout() async {
    try {
      isLoading.value = true;
      _logger.i('Logging out');

      await _authService.logout();

      // 清除本地状态
      user.value = null;
      isLoggedIn.value = false;
      errorMessage.value = '';

      _logger.i('Logout successful');
    } catch (e) {
      errorMessage.value = 'An error occurred during logout: ${e.toString()}';
      _logger.e('Logout error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// 获取当前用户
  Map<String, dynamic>? getCurrentUser() {
    return user.value;
  }

  /// 获取用户 ID
  String? getUserId() {
    return user.value?['id']?.toString();
  }

  /// 获取用户邮箱
  String? getUserEmail() {
    return user.value?['email'];
  }

  /// 获取用户角色
  String? getUserRole() {
    return user.value?['role'];
  }

  /// 获取用户名称
  String? getUserName() {
    return user.value?['name'];
  }

  /// 检查是否为农户
  bool isFarmer() {
    return getUserRole() == 'farmer';
  }

  /// 检查是否为买家
  bool isBuyer() {
    return getUserRole() == 'buyer';
  }

  /// 检查是否为代理人
  bool isAgent() {
    return getUserRole() == 'agent';
  }

  /// 检查是否为管理员
  bool isAdmin() {
    return getUserRole() == 'admin';
  }

  /// 刷新 Token
  Future<bool> refreshAuthToken() async {
    try {
      _logger.i('Refreshing auth token');

      final result = await _authService.refreshToken();

      if (result['success'] == true) {
        _logger.i('Token refreshed successfully');
        return true;
      } else {
        _logger.w('Token refresh failed');
        return false;
      }
    } catch (e) {
      _logger.e('Token refresh error: $e');
      return false;
    }
  }
}
