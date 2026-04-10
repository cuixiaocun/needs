import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:needs_app/config/app_config.dart';
import 'storage_service.dart';

/// AI 对话服务
/// 处理与后台 AI 对话接口的通信
class AiChatService {
  final Dio _dio;
  final StorageService _storageService;
  final Logger _logger = Logger();

  AiChatService({
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

  /// 发送消息给 AI
  /// 返回 AI 的回复
  Future<Map<String, dynamic>> sendMessage({
    required int orderId,
    required String message,
    List<Map<String, String>>? history,
  }) async {
    try {
      _logger.i('Sending message to AI for order: $orderId');

      final requestData = {
        'order_id': orderId,
        'message': message,
      };

      // 如果有历史消息，添加到请求中
      if (history != null && history.isNotEmpty) {
        requestData['history'] = history;
      }

      final response = await _dio.post(
        '/ai/chat',
        data: requestData,
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['success'] == true) {
          _logger.i('AI Chat successful');
          return {
            'success': true,
            'data': data['data'],
            'message': '消息发送成功',
          };
        } else {
          final message = data['message'] ?? '发送失败';
          _logger.w('AI Chat failed: $message');
          return {
            'success': false,
            'message': message,
          };
        }
      } else {
        final message = response.data['message'] ?? '服务器错误';
        _logger.w('AI Chat error: $message');
        return {
          'success': false,
          'message': message,
        };
      }
    } catch (e) {
      _logger.e('AI Chat error: $e');
      return {
        'success': false,
        'message': '网络错误：${e.toString()}',
      };
    }
  }

  /// 获取 AI 调货状态
  Future<Map<String, dynamic>> getStatus(int orderId) async {
    try {
      _logger.i('Getting AI status for order: $orderId');

      final response = await _dio.get('/ai/status/$orderId');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['success'] == true) {
          _logger.i('AI Status fetch successful');
          return {
            'success': true,
            'data': data['data'],
          };
        } else {
          final message = data['message'] ?? '获取状态失败';
          _logger.w('Get AI Status failed: $message');
          return {
            'success': false,
            'message': message,
          };
        }
      } else {
        final message = response.data['message'] ?? '服务器错误';
        _logger.w('Get AI Status error: $message');
        return {
          'success': false,
          'message': message,
        };
      }
    } catch (e) {
      _logger.e('Get AI Status error: $e');
      return {
        'success': false,
        'message': '网络错误：${e.toString()}',
      };
    }
  }
}
