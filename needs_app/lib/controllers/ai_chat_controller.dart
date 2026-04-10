import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:needs_app/services/ai_chat_service.dart';

/// 消息数据模型
class ChatMessage {
  final String id;
  final String content;
  final String role; // 'user' 或 'assistant'
  final DateTime timestamp;
  final bool isLoading;

  ChatMessage({
    required this.id,
    required this.content,
    required this.role,
    required this.timestamp,
    this.isLoading = false,
  });
}

/// AI 对话控制器
/// 使用 GetX 管理对话状态
class AiChatController extends GetxController {
  final AiChatService _aiChatService;
  final Logger _logger = Logger();

  // 订单 ID
  late int orderId;

  // 对话消息列表
  final RxList<ChatMessage> messages = RxList<ChatMessage>();

  // 加载状态
  final RxBool isLoading = RxBool(false);

  // 错误信息
  final RxString errorMessage = RxString('');

  // 调货状态
  final RxString dispatchStatus = RxString('pending');

  // 输入框文本
  final RxString inputText = RxString('');

  AiChatController({AiChatService? aiChatService})
      : _aiChatService = aiChatService ?? AiChatService();

  /// 初始化对话
  void initChat(int orderId) {
    this.orderId = orderId;
    _logger.i('AI Chat initialized for order: $orderId');

    // 添加初始系统消息
    _addSystemMessage('平台 AI 调货助手已就绪，有什么需要帮助的吗？');
  }

  /// 发送消息
  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) {
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      _logger.i('Sending message: $message');

      // 添加用户消息到列表
      _addMessage(
        content: message,
        role: 'user',
      );

      // 清空输入框
      inputText.value = '';

      // 构建历史消息
      final history = _buildMessageHistory();

      // 调用后台 API
      final result = await _aiChatService.sendMessage(
        orderId: orderId,
        message: message,
        history: history,
      );

      if (result['success'] == true) {
        // 添加 AI 回复
        final aiReply = result['data']?['reply'] ?? '无法获取回复';
        _addMessage(
          content: aiReply,
          role: 'assistant',
        );

        _logger.i('AI Message received');
      } else {
        errorMessage.value = result['message'] ?? '发送失败';
        _logger.w('Send message failed: ${errorMessage.value}');

        // 添加错误提示
        _addSystemMessage('发送失败：${errorMessage.value}');
      }
    } catch (e) {
      errorMessage.value = '发生错误：${e.toString()}';
      _logger.e('Send message error: $e');
      _addSystemMessage('发生错误，请重试');
    } finally {
      isLoading.value = false;
    }
  }

  /// 刷新调货状态
  Future<void> refreshStatus() async {
    try {
      final result = await _aiChatService.getStatus(orderId);

      if (result['success'] == true) {
        final status = result['data']?['status'] ?? 'pending';
        final message = result['data']?['message'] ?? '';

        dispatchStatus.value = status;
        _logger.i('Status updated: $status');

        if (message.isNotEmpty && !messages.any((m) => m.content == message)) {
          _addSystemMessage(message);
        }
      } else {
        _logger.w('Get status failed: ${result['message']}');
      }
    } catch (e) {
      _logger.e('Refresh status error: $e');
    }
  }

  /// 添加用户/AI 消息
  void _addMessage({
    required String content,
    required String role,
  }) {
    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      role: role,
      timestamp: DateTime.now(),
    );

    messages.add(message);
    _logger.i('Message added: $role - ${content.substring(0, 50)}...');
  }

  /// 添加系统消息
  void _addSystemMessage(String content) {
    _addMessage(
      content: content,
      role: 'system',
    );
  }

  /// 构建发送给后台的消息历史
  List<Map<String, String>> _buildMessageHistory() {
    return messages
        .where((m) => m.role != 'system') // 不包括系统消息
        .map((m) => {
              'role': m.role,
              'content': m.content,
            })
        .toList();
  }

  /// 清空对话
  void clearChat() {
    messages.clear();
    errorMessage.value = '';
    inputText.value = '';
    _logger.i('Chat cleared');
  }

  /// 获取格式化的消息列表（用于显示）
  List<ChatMessage> getDisplayMessages() {
    return messages.toList();
  }
}
