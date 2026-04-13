import 'package:dio/dio.dart';
import '../config/app_config.dart';
import 'storage_service.dart';

class OrderService {
  final Dio _dio;
  final StorageService _storageService;

  OrderService({Dio? dio, StorageService? storageService})
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

  /// 创建订单
  Future<Map<String, dynamic>> createOrder({
    required String productName,
    required double quantity,
    required String unit,
    required double pricePerUnit,
    required String type,
    required String qualityLevel,
    String? scheduledDeliveryTime,
    String? deliveryMethod,
    String? notes,
  }) async {
    try {
      final data = {
        'product_name': productName,
        'quantity': quantity,
        'unit': unit,
        'price_per_unit': pricePerUnit,
        'type': type,
        'quality_level': qualityLevel,
        'scheduled_delivery_time': scheduledDeliveryTime,
        'delivery_method': deliveryMethod,
        'notes': notes,
      };

      final response = await _dio.post('/orders', data: data);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData['success'] == true) {
          return {
            'success': true,
            'data': responseData['data'],
            'message': '订单创建成功',
          };
        } else {
          return {
            'success': false,
            'message': responseData['message'] ?? '订单创建失败',
          };
        }
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? '订单创建失败',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': '错误：${e.toString()}',
      };
    }
  }

  /// 获取订单列表
  /// [page] - 页码（从1开始）
  /// [status] - 筛选状态（all=不筛选, pending, confirmed, completed 等）
  /// [type] - 订单类型（all=不筛选, buy, sell）
  Future<Map<String, dynamic>> getOrders({
    int page = 1,
    String? status,
    String? type,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page};
      if (status != null && status != 'all') {
        queryParams['status'] = status;
      }
      if (type != null && type != 'all') {
        queryParams['type'] = type;
      }

      final response = await _dio.get(
        '/orders',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true) {
          return {
            'success': true,
            'data': data['data'] ?? [],
            'pagination': {
              'current_page': data['current_page'] ?? 1,
              'last_page': data['last_page'] ?? 1,
              'total': data['total'] ?? 0,
              'per_page': data['per_page'] ?? 20,
            },
            'message': '',
          };
        } else {
          return {
            'success': false,
            'data': [],
            'pagination': {},
            'message': data['message'] ?? '获取订单失败',
          };
        }
      } else {
        return {
          'success': false,
          'data': [],
          'pagination': {},
          'message': response.data['message'] ?? '获取订单列表失败',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'data': [],
        'pagination': {},
        'message': '错误：${e.toString()}',
      };
    }
  }

  /// 获取单个订单详情
  Future<Map<String, dynamic>> getOrderDetail(int orderId) async {
    try {
      final response = await _dio.get('/orders/$orderId');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true) {
          return {
            'success': true,
            'data': data['data'],
            'message': '',
          };
        } else {
          return {
            'success': false,
            'data': null,
            'message': data['message'] ?? '获取订单详情失败',
          };
        }
      } else {
        return {
          'success': false,
          'data': null,
          'message': response.data['message'] ?? '获取订单详情失败',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'data': null,
        'message': '错误：${e.toString()}',
      };
    }
  }

  /// 更新订单（用于确认配对）
  Future<Map<String, dynamic>> updateOrder(
    int orderId, {
    int? matchedOrderId,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (matchedOrderId != null) {
        data['matched_order_id'] = matchedOrderId;
      }

      final response = await _dio.patch(
        '/orders/$orderId',
        data: data,
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData['success'] == true) {
          return {
            'success': true,
            'data': responseData['data'],
          };
        } else {
          return {
            'success': false,
            'message': responseData['message'] ?? '更新订单失败',
          };
        }
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? '更新订单失败',
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
