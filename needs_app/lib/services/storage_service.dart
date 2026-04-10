import 'package:get_storage/get_storage.dart';

/// 本地存储服务
/// 使用 GetStorage 进行本地数据持久化
class StorageService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_info';
  static const String _roleKey = 'user_role';
  static const String _refreshTokenKey = 'refresh_token';

  final GetStorage _storage;

  StorageService({GetStorage? storage}) : _storage = storage ?? GetStorage();

  /// 保存 Token
  Future<void> saveToken(String token) async {
    await _storage.write(_tokenKey, token);
  }

  /// 获取 Token
  String? getToken() {
    return _storage.read(_tokenKey);
  }

  /// 保存 Refresh Token
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(_refreshTokenKey, token);
  }

  /// 获取 Refresh Token
  String? getRefreshToken() {
    return _storage.read(_refreshTokenKey);
  }

  /// 清除 Token
  Future<void> clearToken() async {
    await _storage.remove(_tokenKey);
    await _storage.remove(_refreshTokenKey);
  }

  /// 保存用户信息
  Future<void> saveUserInfo(Map<String, dynamic> userInfo) async {
    await _storage.write(_userKey, userInfo);
  }

  /// 获取用户信息
  Map<String, dynamic>? getUserInfo() {
    final data = _storage.read(_userKey);
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return null;
  }

  /// 保存用户角色
  Future<void> saveUserRole(String role) async {
    await _storage.write(_roleKey, role);
  }

  /// 获取用户角色
  String? getUserRole() {
    return _storage.read(_roleKey);
  }

  /// 检查是否已登录
  bool isLoggedIn() {
    return getToken() != null;
  }

  /// 清除所有数据
  Future<void> clearAll() async {
    await _storage.erase();
  }
}
