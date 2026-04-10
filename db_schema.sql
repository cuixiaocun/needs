-- ====================================================
-- 农产品智能撮合交易所 v4.1
-- 数据库初始化脚本（第一期新增 8 个表）
-- ====================================================

-- 表 1: 农户保证金账户
CREATE TABLE farmer_deposits (
  id BIGINT PRIMARY KEY COMMENT '主键',
  farmer_id BIGINT NOT NULL COMMENT '农户 ID',
  total_deposit DECIMAL(12, 2) DEFAULT 0 COMMENT '充值总额',
  available DECIMAL(12, 2) DEFAULT 0 COMMENT '可用余额',
  frozen DECIMAL(12, 2) DEFAULT 0 COMMENT '已冻结（订单占用）',
  deducted DECIMAL(12, 2) DEFAULT 0 COMMENT '已扣除（违约）',
  leverage_amount DECIMAL(15, 2) DEFAULT 0 COMMENT '10倍杠杆可用额度',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  UNIQUE KEY uk_farmer (farmer_id),
  INDEX idx_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='农户保证金账户';

-- 表 2: 保证金流水
CREATE TABLE farmer_deposit_logs (
  id BIGINT PRIMARY KEY COMMENT '主键',
  farmer_id BIGINT NOT NULL COMMENT '农户 ID',
  type ENUM('充值','冻结','解冻','扣除','提现') NOT NULL COMMENT '流水类型',
  amount DECIMAL(12, 2) NOT NULL COMMENT '流水金额',
  order_id BIGINT COMMENT '关联订单 ID',
  reason VARCHAR(255) COMMENT '原因说明',
  balance_before DECIMAL(12, 2) COMMENT '交易前余额',
  balance_after DECIMAL(12, 2) COMMENT '交易后余额',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  FOREIGN KEY (farmer_id) REFERENCES users(id),
  INDEX idx_farmer (farmer_id),
  INDEX idx_order (order_id),
  INDEX idx_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='保证金流水日志';

-- 表 3: 紧急调货日志
CREATE TABLE emergency_dispatch_logs (
  id BIGINT PRIMARY KEY COMMENT '主键',
  original_order_id BIGINT NOT NULL COMMENT '原订单 ID',
  original_farmer_id BIGINT NOT NULL COMMENT '原农户 ID',
  buyer_id BIGINT NOT NULL COMMENT '买家 ID',
  cancel_reason VARCHAR(255) COMMENT '取消原因',
  buyer_choice ENUM('按原时间','顺延次日','直接退款') NOT NULL COMMENT '买家选择',

  -- 第一段：代理人呼叫
  stage_1_start_time TIMESTAMP COMMENT '第一段开始时间',
  stage_1_agent_id BIGINT COMMENT '接单代理人 ID',
  stage_1_end_time TIMESTAMP COMMENT '第一段结束时间',
  stage_1_result ENUM('成功','失败','') DEFAULT '' COMMENT '第一段结果',

  -- 第二段：AI 调货
  stage_2_ai_result ENUM('成功','失败','') DEFAULT '' COMMENT '第二段 AI 结果',

  -- 替代订单信息
  replacement_order_id BIGINT COMMENT '替代订单 ID',
  replacement_farmer_id BIGINT COMMENT '替代农户 ID',

  -- 最终状态
  final_status ENUM('进行中','已完成','已退款','自动取消') DEFAULT '进行中' COMMENT '最终状态',

  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',

  FOREIGN KEY (original_order_id) REFERENCES orders(id),
  FOREIGN KEY (original_farmer_id) REFERENCES users(id),
  FOREIGN KEY (buyer_id) REFERENCES users(id),
  FOREIGN KEY (replacement_order_id) REFERENCES orders(id),
  INDEX idx_order (original_order_id),
  INDEX idx_status (final_status),
  INDEX idx_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='紧急调货日志';

-- 表 4: 代理人呼叫记录
CREATE TABLE agent_call_records (
  id BIGINT PRIMARY KEY COMMENT '主键',
  dispatch_log_id BIGINT NOT NULL COMMENT '紧急调货 ID',
  agent_id BIGINT NOT NULL COMMENT '代理人 ID',
  farmer_id BIGINT NOT NULL COMMENT '农户 ID',
  farmer_phone VARCHAR(20) COMMENT '农户电话',

  -- 呼叫信息
  called_at TIMESTAMP COMMENT '拨打时间',
  call_duration INT DEFAULT 0 COMMENT '通话时长（秒）',
  status ENUM('接通','未接','拒接','其他') DEFAULT '未接' COMMENT '呼叫状态',
  ringing_duration INT DEFAULT 0 COMMENT '响铃时长（秒）',

  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',

  FOREIGN KEY (dispatch_log_id) REFERENCES emergency_dispatch_logs(id),
  FOREIGN KEY (agent_id) REFERENCES users(id),
  FOREIGN KEY (farmer_id) REFERENCES users(id),
  INDEX idx_dispatch (dispatch_log_id),
  INDEX idx_agent (agent_id),
  INDEX idx_farmer (farmer_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='代理人呼叫记录';

-- 表 5: 市场收货记录
CREATE TABLE market_receiving_records (
  id BIGINT PRIMARY KEY COMMENT '主键',
  order_id BIGINT NOT NULL COMMENT '订单 ID',
  farmer_id BIGINT NOT NULL COMMENT '农户 ID',
  worker_id BIGINT NOT NULL COMMENT '市场工作人员 ID',

  -- 时间信息
  received_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '收货时间',

  -- 重量信息
  reported_weight INT NOT NULL COMMENT '农户报告重量（KG）',
  actual_weight INT NOT NULL COMMENT '实际过磅重量（KG）',
  weight_variance DECIMAL(5, 2) COMMENT '重量差异百分比',

  -- 等级信息
  reported_grade ENUM('特级','一级','二级') COMMENT '农户自报等级',
  actual_grade ENUM('特级','一级','二级') COMMENT '工作人员判定等级',

  -- 收货结果
  result ENUM('符合','降级','拒收') NOT NULL COMMENT '收货结果',
  downgrade_level INT COMMENT '降级档次数（如 1 = 一级→二级）',

  -- 证据
  photos JSON COMMENT '3 张照片 URL',
  remarks VARCHAR(500) COMMENT '备注',

  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',

  FOREIGN KEY (order_id) REFERENCES orders(id),
  FOREIGN KEY (farmer_id) REFERENCES users(id),
  FOREIGN KEY (worker_id) REFERENCES users(id),
  INDEX idx_order (order_id),
  INDEX idx_farmer (farmer_id),
  INDEX idx_worker (worker_id),
  INDEX idx_result (result)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='市场收货记录';

-- 表 6: 市场出货记录
CREATE TABLE market_dispatch_records (
  id BIGINT PRIMARY KEY COMMENT '主键',
  order_id BIGINT NOT NULL COMMENT '订单 ID',
  buyer_id BIGINT NOT NULL COMMENT '买家 ID',

  -- 出货类型
  dispatch_type ENUM('自提','代运') NOT NULL COMMENT '交付方式',

  -- 自提信息
  pickup_code VARCHAR(10) COMMENT '4 位提货码',
  self_pickup_at TIMESTAMP COMMENT '自提时间',
  pickup_worker_id BIGINT COMMENT '核验工作人员 ID',

  -- 代运信息
  hauling_order_id VARCHAR(50) COMMENT '货拉拉订单号',
  hauling_status ENUM('待接单','已接单','已取货','运输中','已送达','已取消') DEFAULT '待接单' COMMENT '代运状态',
  hauling_driver_phone VARCHAR(20) COMMENT '司机电话',
  signed_at TIMESTAMP COMMENT '签收时间',

  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',

  FOREIGN KEY (order_id) REFERENCES orders(id),
  FOREIGN KEY (buyer_id) REFERENCES users(id),
  FOREIGN KEY (pickup_worker_id) REFERENCES users(id),
  INDEX idx_order (order_id),
  INDEX idx_buyer (buyer_id),
  INDEX idx_dispatch_type (dispatch_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='市场出货记录';

-- 表 7: 农户结算单
CREATE TABLE farmer_settlements (
  id BIGINT PRIMARY KEY COMMENT '主键',
  farmer_id BIGINT NOT NULL COMMENT '农户 ID',
  settlement_date DATE NOT NULL COMMENT '结算周期（本周一）',

  -- 订单汇总
  total_orders INT NOT NULL COMMENT '该周订单数',
  total_revenue DECIMAL(15, 2) NOT NULL COMMENT '总收入',
  total_deductions DECIMAL(15, 2) DEFAULT 0 COMMENT '总扣款',
  net_amount DECIMAL(15, 2) NOT NULL COMMENT '实付金额',

  -- 结算状态
  status ENUM('待结算','已支付','已驳回') DEFAULT '待结算' COMMENT '结算状态',

  -- 支付信息
  payment_method ENUM('支付宝','微信','银行转账','其他') COMMENT '支付方式',
  payment_account VARCHAR(100) COMMENT '收款账户',
  paid_at TIMESTAMP COMMENT '支付时间',
  transaction_id VARCHAR(100) COMMENT '支付宝/微信交易号',

  remark VARCHAR(500) COMMENT '备注',

  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',

  FOREIGN KEY (farmer_id) REFERENCES users(id),
  UNIQUE KEY uk_farmer_date (farmer_id, settlement_date),
  INDEX idx_status (status),
  INDEX idx_settlement_date (settlement_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='农户结算单';

-- 表 8: 结算单明细
CREATE TABLE settlement_items (
  id BIGINT PRIMARY KEY COMMENT '主键',
  settlement_id BIGINT NOT NULL COMMENT '结算单 ID',
  order_id BIGINT NOT NULL COMMENT '订单 ID',

  -- 金额信息
  order_amount DECIMAL(15, 2) COMMENT '订单金额',

  -- 扣款类型
  deduction_type ENUM('降级差价','损耗','保证金扣除','其他') COMMENT '扣款类型',
  deduction_amount DECIMAL(12, 2) COMMENT '扣款金额',

  final_amount DECIMAL(15, 2) COMMENT '最终金额（order_amount - deduction_amount）',

  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',

  FOREIGN KEY (settlement_id) REFERENCES farmer_settlements(id) ON DELETE CASCADE,
  FOREIGN KEY (order_id) REFERENCES orders(id),
  INDEX idx_settlement (settlement_id),
  INDEX idx_order (order_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='结算单明细';

-- ====================================================
-- 现有表扩展字段（需要在旧表中新增）
-- ====================================================

-- orders 表新增字段
ALTER TABLE orders ADD COLUMN IF NOT EXISTS dispatch_type ENUM('自提','代运') COMMENT '交付方式';
ALTER TABLE orders ADD COLUMN IF NOT EXISTS emergency_dispatch_id BIGINT COMMENT '紧急调货 ID';
ALTER TABLE orders ADD COLUMN IF NOT EXISTS market_dispatch_id BIGINT COMMENT '市场出货记录 ID';
ALTER TABLE orders ADD COLUMN IF NOT EXISTS farmer_settled_at TIMESTAMP COMMENT '农户结算时间';

-- users 表新增字段（如果需要）
-- 农户相关
ALTER TABLE users ADD COLUMN IF NOT EXISTS deposit_id BIGINT COMMENT '保证金账户 ID';
ALTER TABLE users ADD COLUMN IF NOT EXISTS is_market_worker TINYINT(1) DEFAULT 0 COMMENT '是否市场工作人员';
ALTER TABLE users ADD COLUMN IF NOT EXISTS is_agent TINYINT(1) DEFAULT 0 COMMENT '是否代理人';
ALTER TABLE users ADD COLUMN IF NOT EXISTS agent_phone VARCHAR(20) COMMENT '代理人电话';

-- ====================================================
-- 验证脚本
-- ====================================================
-- 运行后检查：
-- SHOW TABLES;
-- DESC farmer_deposits;
-- DESC farmer_deposit_logs;
-- DESC emergency_dispatch_logs;
-- DESC agent_call_records;
-- DESC market_receiving_records;
-- DESC market_dispatch_records;
-- DESC farmer_settlements;
-- DESC settlement_items;
