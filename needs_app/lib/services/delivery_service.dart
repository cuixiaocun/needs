import 'package:dio/dio.dart';
import '../config/app_config.dart';
import 'storage_service.dart';

class DeliveryService {
  final Dio _dio;
  final StorageService _storageService;

  DeliveryService({Dio? dio, StorageService? storageService})
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

  /// 获取交货费用和地点
  Future<Map<String, dynamic>> getDeliveryFee() async {
    try {
      final response = await _dio.get('/delivery/fee');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true) {
          final deliveryData = data['data'] as Map<String, dynamic>;
          return {
            'success': true,
            'location': deliveryData['location'] ?? '集散市场中转',
            'fee': (deliveryData['fee'] ?? 80).toDouble(),
            'description': deliveryData['description'] ?? '标准物流运费',
          };
        } else {
          return {
            'success': false,
            'message': data['message'] ?? '获取交货信息失败',
          };
        }
      } else {
        return {
          'success': false,
          'message': '获取交货信息失败',
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
