import 'package:get/get.dart';

class Messages extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'zh_CN': {
          'app_name': '需求',
          'login': '登录',
          'register': '注册',
          'phone': '手机号码',
          'password': '密码',
          'login_welcome': '欢迎登录',
          'login_subtitle': '输入手机号和密码以继续',
          'no_account': '还没有账号？',
          'register_now': '立即注册',
          'error_login_failed': '登录失败',
          'error_invalid_credentials': '登录失败，请检查手机号和密码后重试',
          'loading_login': '登录中...',
          // 以后可以根据需要继续添加
        },
      };
}
