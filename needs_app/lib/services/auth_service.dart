import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:needs_app/config/app_config.dart';
import 'storage_service.dart';

/// 认证服务
/// 处理与 API 的认证通信，包括登录、注册、登出等操作
class AuthService {
  final Dio _dio;
  final StorageService _storageService;
  final Logger _logger = Logger();

  AuthService({
    Dio? dio,
    StorageService? storageService,
  })  : _dio = dio ?? Dio(),
        _storageService = storageService ?? StorageService() {
    _setupDio();
  }

  /// 配置 Dio 实例
  void _setupDio() {
    _dio.options = BaseOptions(
      baseUrl: AppConfig.currentApiBaseUrl,
      connectTimeout: Duration(seconds: AppConfig.apiTimeout),
      receiveTimeout: Duration(seconds: AppConfig.apiTimeout),
      sendTimeout: Duration(seconds: AppConfig.apiTimeout),
      validateStatus: (status) {
        return status! < 500;
      },
    );

    // 添加请求拦截器，自动添加 token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _storageService.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          _logger.e('Dio Error: ${error.message}');
          return handler.next(error);
        },
      ),
    );
  }

  /// 登录
  /// 调用 API 登录，保存 token 和用户信息
  Future<Map<String, dynamic>> login({
    required String phone,
    required String password,
  }) async {
    try {
      _logger.i('Attempting login with phone: $phone');

      final response = await _dio.post(
        '/auth/login',
        data: {
          'phone': phone,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;

        // 保存 token
        if (data['data']?['token'] != null) {
          await _storageService.saveToken(data['data']['token']);
        }

        // 保存 refresh token (如果有)
        final refreshToken = data['data']?['refresh_token'];
        if (refreshToken != null) {
          await _storageService.saveRefreshToken(refreshToken);
        }

        // 保存用户信息
        final userInfo = data['data']?['user'];
        if (userInfo != null) {
          await _storageService.saveUserInfo(userInfo);
          if (userInfo['role'] != null) {
            await _storageService.saveUserRole(userInfo['role']);
          }
        }

        _logger.i('Login successful');
        return {
          'success': true,
          'data': data['data'],
          'message': data['message'] ?? 'Login successful',
        };
      } else {
        final message = response.data['message'] ?? 'Login failed';
        _logger.w('Login failed: $message');
        return {
          'success': false,
          'message': message,
        };
      }
    } catch (e) {
      _logger.e('Login error: $e');
      return {
        'success': false,
        'message': 'An error occurred during login: ${e.toString()}',
      };
    }
  }

  /// 注册
  /// 调用 API 注册新用户
  Future<Map<String, dynamic>> register({
    required String name,
    required String phone,
    required String password,
    required String passwordConfirmation,
    required String role,
    String? email,
  }) async {
    try {
      _logger.i('Attempting register with phone: $phone');

      final requestData = {
        'name': name,
        'phone': phone,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'role': role,
      };
      if (email != null) {
        requestData['email'] = email;
      }

      final response = await _dio.post(
        '/auth/register',
        data: requestData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;

        // 自动登录（如果 API 返回 token）
        final token = data['data']?['token'];
        if (token != null) {
          await _storageService.saveToken(token);

          final refreshToken = data['data']?['refresh_token'];
          if (refreshToken != null) {
            await _storageService.saveRefreshToken(refreshToken);
          }

          final userInfo = data['data']?['user'];
          if (userInfo != null) {
            await _storageService.saveUserInfo(userInfo);
            if (userInfo['role'] != null) {
              await _storageService.saveUserRole(userInfo['role']);
            }
          }
        }

        _logger.i('Register successful');
        return {
          'success': true,
          'data': data['data'],
          'message': data['message'] ?? 'Registration successful',
        };
      } else {
        final message = response.data['message'] ?? 'Registration failed';
        _logger.w('Register failed: $message');
        return {
          'success': false,
          'message': message,
        };
      }
    } catch (e) {
      _logger.e('Register error: $e');
      return {
        'success': false,
        'message': 'An error occurred during registration: ${e.toString()}',
      };
    }
  }

  /// 登出
  /// 清除本地存储的数据
  Future<void> logout() async {
    try {
      _logger.i('Logging out');
      // 可选：调用 API 登出端点
      try {
        await _dio.post('/auth/logout');
      } catch (e) {
        _logger.w('Error calling logout endpoint: $e');
      }

      // 清除本地数据
      await _storageService.clearAll();
      _logger.i('Logout successful');
    } catch (e) {
      _logger.e('Logout error: $e');
    }
  }

  /// 获取当前用户信息
  /// 从本地存储获取用户信息
  Map<String, dynamic>? getCurrentUser() {
    return _storageService.getUserInfo();
  }

  /// 检查登录状态
  bool isLoggedIn() {
    return _storageService.isLoggedIn();
  }

  /// 刷新 Token
  /// 使用 refresh token 获取新的 access token
  Future<Map<String, dynamic>> refreshToken() async {
    try {
      _logger.i('Attempting to refresh token');

      final refreshToken = _storageService.getRefreshToken();
      if (refreshToken == null) {
        _logger.w('No refresh token available');
        return {
          'success': false,
          'message': 'No refresh token available',
        };
      }

      final response = await _dio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['data']?['token'] != null) {
          await _storageService.saveToken(data['data']['token']);
        }

        _logger.i('Token refreshed successfully');
        return {
          'success': true,
          'token': data['data']['token'],
        };
      } else {
        _logger.w('Token refresh failed');
        return {
          'success': false,
          'message': 'Token refresh failed',
        };
      }
    } catch (e) {
      _logger.e('Token refresh error: $e');
      return {
        'success': false,
        'message': 'An error occurred during token refresh: ${e.toString()}',
      };
    }
  }
}
