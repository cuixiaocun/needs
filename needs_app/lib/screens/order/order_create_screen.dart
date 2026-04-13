import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:needs_app/config/colors.dart';
import 'package:needs_app/controllers/order_create_controller.dart';

/// 订单创建表单页面常量
class _OrderScreenConstants {
  // 订单类型常量
  static const String orderTypeSell = 'sell';
  static const String orderTypeBuy = 'buy';

  // 单位常量
  static const List<String> unitOptions = ['kg', 't', '斤', '箱', '件', '束', '盒'];

  // 品质等级常量
  static const List<String> qualityLevels = ['特级', '一级', '二级'];

  // 配送方式常量（值）
  static const List<String> deliveryMethodValues = [
    'self_pickup',
    'logistics',
    'negotiate'
  ];

  // 配送方式常量（显示文本）
  static const List<String> deliveryMethodLabels = ['自提', '物流配送', '双方协商'];

  // 默认品质等级
  static const String defaultQualityLevel = '一级';
}

/// 订单创建表单页面
/// 支持用户发布供应单或需求单
class OrderCreateScreen extends StatelessWidget {
  const OrderCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OrderCreateController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('发布订单'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildBasicInfoCard(controller),
              const SizedBox(height: 16),
              _buildProductPriceCard(controller),
              const SizedBox(height: 16),
              _buildQualityDeliveryCard(controller),
              const SizedBox(height: 16),
              _buildOtherInfoCard(controller),
              const SizedBox(height: 80), // 为浮动按钮留空间
            ],
          ),
        ),
      ),
      floatingActionButton: _buildSubmitButton(controller),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  /// 构建基本信息卡片
  Widget _buildBasicInfoCard(OrderCreateController controller) {
    return Card(
      elevation: AppTheme.cardElevation,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📋 基本信息',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Obx(
              () => SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: _OrderScreenConstants.orderTypeSell,
                    label: Text('供应单'),
                  ),
                  ButtonSegment(
                    value: _OrderScreenConstants.orderTypeBuy,
                    label: Text('需求单'),
                  ),
                ],
                selected: {controller.selectedOrderType.value},
                onSelectionChanged: (Set<String> newSelection) {
                  controller.selectedOrderType.value = newSelection.first;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建产品与价格卡片
  Widget _buildProductPriceCard(OrderCreateController controller) {
    return Card(
      elevation: AppTheme.cardElevation,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📦 产品与价格',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            // 产品名称
            TextField(
              decoration: InputDecoration(
                labelText: '产品名称',
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppTheme.textFieldBorderRadius),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              onChanged: (value) {
                controller.updateField('product_name', value);
              },
            ),
            const SizedBox(height: 16),
            // 数量和单位
            Row(
              children: [
                // 数量
                Expanded(
                  flex: 1,
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: '数量',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppTheme.textFieldBorderRadius,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[0-9.]'),
                      ),
                    ],
                    onChanged: (value) {
                      controller.updateField('quantity', value);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                // 单位
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: '单位',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppTheme.textFieldBorderRadius,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    isDense: true,
                    items: _OrderScreenConstants.unitOptions
                        .map(
                          (unit) => DropdownMenuItem(
                            value: unit,
                            child: Text(unit),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        controller.updateField('unit', value);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 单价
            TextField(
              decoration: InputDecoration(
                labelText: '单价',
                prefixText: '¥ ',
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppTheme.textFieldBorderRadius),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'[0-9.]'),
                ),
              ],
              onChanged: (value) {
                controller.updateField('price_per_unit', value);
              },
            ),
            const SizedBox(height: 16),
            // 预计总金额
            Obx(
              () => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.border,
                    width: AppTheme.textFieldBorderWidth,
                  ),
                  borderRadius: BorderRadius.circular(
                    AppTheme.textFieldBorderRadius,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '预计总金额',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '¥ ${controller.totalAmount.value.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建品质与配送卡片
  Widget _buildQualityDeliveryCard(OrderCreateController controller) {
    return Card(
      elevation: AppTheme.cardElevation,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '⭐ 品质与配送',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            // 品质等级
            Obx(
              () => DropdownButtonFormField<String>(
                initialValue: controller.formData['quality_level'] ??
                    _OrderScreenConstants.defaultQualityLevel,
                decoration: InputDecoration(
                  labelText: '品质等级',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      AppTheme.textFieldBorderRadius,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                isDense: true,
                items: _OrderScreenConstants.qualityLevels
                    .map(
                      (level) => DropdownMenuItem(
                        value: level,
                        child: Text(level),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    controller.updateField('quality_level', value);
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            // 预计交货时间
            Obx(
              () => InkWell(
                onTap: () async {
                  final context = Get.context;
                  if (context == null) {
                    Get.snackbar('错误', '无法打开日期选择器');
                    return;
                  }

                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                  );
                  if (pickedDate != null) {
                    controller.updateField('scheduled_delivery_time', pickedDate);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.border,
                      width: AppTheme.textFieldBorderWidth,
                    ),
                    borderRadius: BorderRadius.circular(
                      AppTheme.textFieldBorderRadius,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '预计交货时间',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        _formatDate(
                            controller.formData['scheduled_delivery_time']),
                        style: TextStyle(
                          fontSize: 14,
                          color: controller
                                      .formData['scheduled_delivery_time'] !=
                                  null
                              ? AppColors.textPrimary
                              : AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 配送方式
            Obx(
              () => DropdownButtonFormField<String?>(
                initialValue: controller.formData['delivery_method'] as String?,
                decoration: InputDecoration(
                  labelText: '配送方式',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      AppTheme.textFieldBorderRadius,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  hintText: '可选',
                ),
                isDense: true,
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('请选择'),
                  ),
                  ..._OrderScreenConstants.deliveryMethodValues
                      .asMap()
                      .entries
                      .map(
                        (entry) => DropdownMenuItem<String>(
                          value: entry.value,
                          child: Text(
                              _OrderScreenConstants.deliveryMethodLabels[entry.key]),
                        ),
                      ),
                ],
                onChanged: (value) {
                  controller.updateField('delivery_method', value);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建其他信息卡片
  Widget _buildOtherInfoCard(OrderCreateController controller) {
    return Card(
      elevation: AppTheme.cardElevation,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '💬 其他信息',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            // 备注
            TextField(
              decoration: InputDecoration(
                labelText: '备注',
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppTheme.textFieldBorderRadius),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              maxLines: 4,
              onChanged: (value) {
                controller.updateField('notes', value);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 构建提交按钮
  Widget _buildSubmitButton(OrderCreateController controller) {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 16.0,
        ),
        child: SizedBox(
          width: double.infinity,
          height: AppTheme.buttonHeight,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.textHint,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppTheme.buttonBorderRadius),
              ),
            ),
            onPressed: controller.isLoading.value
                ? null
                : () => controller.submitOrder(),
            child: controller.isLoading.value
                ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.white,
                    ),
                  )
                : const Text(
                    '发布订单',
                    style: TextStyle(
                      fontSize: AppTheme.buttonFontSize,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  /// 格式化日期为 YYYY-MM-DD
  /// 添加严格的类型检查来防止运行时错误
  String _formatDate(dynamic date) {
    if (date is DateTime) {
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }

    // 如果值不是 DateTime，返回占位文本
    if (date != null) {
      return '日期格式错误';
    }

    return '请选择日期';
  }
}
