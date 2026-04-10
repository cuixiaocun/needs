import 'package:get/get.dart';
import 'package:logger/logger.dart';

/// 首页控制器
/// 使用 GetX 进行状态管理，追踪底部导航栏 Tab 的状态
class HomeController extends GetxController {
  final Logger _logger = Logger();

  // 当前选中的底部 Tab 索引
  final Rx<int> currentTabIndex = Rx<int>(0);

  @override
  void onInit() {
    super.onInit();
    _logger.i('HomeController initialized');
  }

  /// 切换 Tab
  /// [index] - 要切换到的 Tab 索引（0-3）
  void changeTab(int index) {
    if (index >= 0 && index <= 3) {
      currentTabIndex.value = index;
      _logger.d('Tab changed to: $index');
    }
  }

  /// 获取当前 Tab 索引
  int getCurrentTabIndex() {
    return currentTabIndex.value;
  }
}
