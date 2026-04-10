import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:needs_app/config/colors.dart';
import 'package:needs_app/controllers/ai_chat_controller.dart';
import 'package:needs_app/widgets/chat/chat_bubble.dart';
import 'package:needs_app/widgets/common/custom_button.dart';

/// AI 对话屏幕
/// 显示与 AI 助手的对话界面，用于紧急调货协商
class AiChatScreen extends StatefulWidget {
  final int orderId;

  const AiChatScreen({super.key, required this.orderId});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  late AiChatController _controller;
  late TextEditingController _inputController;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(AiChatController());
    _controller.initChat(widget.orderId);

    _inputController = TextEditingController();
    _scrollController = ScrollController();

    // 初始化后刷新状态
    Future.delayed(const Duration(milliseconds: 500), () {
      _controller.refreshStatus();
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// 滚动到底部
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// 发送消息
  void _sendMessage() {
    final message = _inputController.text.trim();
    if (message.isEmpty) {
      return;
    }

    _controller.sendMessage(message);
    _inputController.clear();
    _scrollToBottom();
  }

  /// 构建状态指示器
  Widget _buildStatusBar() {
    return Obx(() {
      final status = _controller.dispatchStatus.value;
      final statusText = _getStatusText(status);
      final statusColor = _getStatusColor(status);

      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.1),
          border: Border(bottom: BorderSide(color: statusColor)),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontSize: AppTheme.fontSizeSmall,
                  fontWeight: AppTheme.fontWeightMedium,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  /// 获取状态文本
  String _getStatusText(String status) {
    switch (status) {
      case 'success':
        return '✓ 调货成功';
      case 'failed':
        return '× 调货失败，即将处理退款';
      default:
        return '⏳ 平台正在处理...';
    }
  }

  /// 获取状态颜色
  Color _getStatusColor(String status) {
    switch (status) {
      case 'success':
        return AppColors.primary;
      case 'failed':
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  /// 构建消息列表
  Widget _buildMessageList() {
    return Obx(() {
      final messages = _controller.messages;

      if (messages.isEmpty) {
        return Center(
          child: Text(
            '暂无消息',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        );
      }

      return ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[index];
          final showTime = index == 0 ||
              messages[index - 1].timestamp
                  .difference(message.timestamp)
                  .inMinutes
                  .abs() >
              5;

          return ChatBubble(
            content: message.content,
            role: message.role,
            showTime: showTime,
            timeText: _formatTime(message.timestamp),
          );
        },
      );
    });
  }

  /// 格式化时间
  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// 构建输入框
  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Obx(() {
          final isLoading = _controller.isLoading.value;

          return Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.border),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: TextField(
                    controller: _inputController,
                    enabled: !isLoading,
                    maxLines: null,
                    minLines: 1,
                    maxLength: 200,
                    decoration: InputDecoration(
                      hintText: '输入消息...',
                      hintStyle: TextStyle(color: AppColors.textHint),
                      border: InputBorder.none,
                      counterText: '',
                    ),
                    style: TextStyle(color: AppColors.textPrimary),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: isLoading ? null : _sendMessage,
                    customBorder: const CircleBorder(),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: isLoading
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.white,
                                ),
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.send,
                              color: Colors.white,
                              size: 20,
                            ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          '🤖 AI 调货助手',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: AppTheme.fontSizeTitle,
            fontWeight: AppTheme.fontWeightBold,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 状态指示器
            _buildStatusBar(),

            // 消息列表
            Expanded(
              child: _buildMessageList(),
            ),

            // 输入框
            _buildInputBar(),
          ],
        ),
      ),
    );
  }
}
