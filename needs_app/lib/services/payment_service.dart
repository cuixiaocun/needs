import 'package:dio/dio.dart';
import '../config/app_config.dart';
import 'storage_service.dart';

class PaymentService {
  final Dio _dio;
  final StorageService _storageService;

  PaymentService({Dio? dio, StorageService? storageService})
      : _dio = dio ?? Dio(),
        _storageService = storageService ?? StorageService() {
    _setupDio();
  }

  void _setupDio() {
    _dio.options = BaseOptions(
      baseUrl: AppConfig.currentApiBaseUrl,
      connectTimeout: Duration(seconds: AppConfig.apiTimeout),
      receiveTimeout: Duration(seconds: AppConfig.apiTimeout),
      sendTimeout: Duration(seconds: AppConfig.apiTimeout),
      validateStatus: (status) => status! < 500,
    );

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = _storageService.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }

  /// 创建支付宝支付链接
  Future<Map<String, dynamic>> createAlipayment(int orderId) async {
    try {
      final response = await _dio.post(
        '/payment/alipay',
        data: {'order_id': orderId},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true) {
          return {
            'success': true,
            'payment_url': data['payment_url'],
          };
        } else {
          return {
            'success': false,
            'message': data['message'] ?? '生成支付链接失败',
          };
        }
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? '支付链接生成失败',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': '错误：${e.toString()}',
      };
    }
  }

  /// 检查订单支付状态
  Future<Map<String, dynamic>> checkPaymentStatus(int orderId) async {
    try {
      final response = await _dio.get('/ai/status/$orderId');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true) {
          return {
            'success': true,
            'status': data['data']['status'],
            'order_status': data['data']['order_status'],
          };
        } else {
          return {
            'success': false,
            'message': data['message'] ?? '获取状态失败',
          };
        }
      } else {
        return {
          'success': false,
          'message': '获取状态失败',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': '错误：${e.toString()}',
      };
    }
  }
}
