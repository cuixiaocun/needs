import 'package:flutter/material.dart';
import 'package:needs_app/config/colors.dart';

/// 聊天气泡组件
/// 用于显示用户消息、AI 消息和系统消息
class ChatBubble extends StatelessWidget {
  /// 消息内容
  final String content;

  /// 消息角色：'user'（用户）、'assistant'（AI）、'system'（系统）
  final String role;

  /// 是否显示时间
  final bool showTime;

  /// 时间文本
  final String? timeText;

  const ChatBubble({
    super.key,
    required this.content,
    required this.role,
    this.showTime = false,
    this.timeText,
  });

  @override
  Widget build(BuildContext context) {
    if (role == 'system') {
      return _buildSystemMessage();
    } else if (role == 'user') {
      return _buildUserMessage();
    } else {
      return _buildAiMessage();
    }
  }

  /// 构建用户消息气泡（右侧，白色背景）
  Widget _buildUserMessage() {
    return Padding(
      padding: const EdgeInsets.only(right: 16, left: 60, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary, // 绿色背景
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              content,
              style: const TextStyle(
                color: Colors.white,
                fontSize: AppTheme.fontSizeMedium,
                height: 1.5,
              ),
              maxLines: null,
            ),
          ),
          if (showTime && timeText != null)
            Padding(
              padding: const EdgeInsets.only(top: 4, right: 4),
              child: Text(
                timeText!,
                style: TextStyle(
                  color: AppColors.textHint,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 构建 AI 消息气泡（左侧，浅灰背景）
  Widget _buildAiMessage() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 60, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.background, // 浅灰背景
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              content,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: AppTheme.fontSizeMedium,
                height: 1.5,
              ),
              maxLines: null,
            ),
          ),
          if (showTime && timeText != null)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 4),
              child: Text(
                timeText!,
                style: TextStyle(
                  color: AppColors.textHint,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 构建系统消息（居中，灰色）
  Widget _buildSystemMessage() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            content,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: AppTheme.fontSizeSmall,
            ),
            textAlign: TextAlign.center,
            maxLines: null,
          ),
        ),
      ),
    );
  }
}
