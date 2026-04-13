# 农产品供需撮合平台 - AI 开发同步文档 (AI Development Sync)

本文件作为跨 Agent 开发的“全局上下文”，记录核心业务逻辑、技术变更及设计决策，确保不同 AI 助手在协作时保持思路一致。

---

## 📅 更新记录

### 2026-04-10: 实现 AI 引导式挂单与智能撮合
**负责人**: Antigravity (AI)
**概览**: 实现了买卖双方通过 AI 对话收集交易意向、自动创建单据并进行暗池匹配的功能。

#### 1. 核心业务逻辑 (AI Broker Logic)
- **沟通隔离**: 买卖双方严禁直接通讯。所有交易属性（产品、数量、品质、价格、交付期）由 AI 分步问询提取。
- **意向单 (Intention Order)**: 只有单边参与者时，单据以 `status = pending` 存在于 `orders` 表中。
- **撮合机制**: `MatchingService` 在新单入库时自动扫描反向需求。匹配权重：品类(硬性) > 价格(重合度) > 日期(交叠) > 品质(等级一致)。
- **AI 语气 (Tone)**: 采用“接地气但专业”的经纪人角色。称呼用户为“老板/老乡”，但在关键交易数据上必须追问到底，确保准确性。

#### 2. 技术变更 (Technical Changes)
- **数据库 (Backend)**:
  - `orders` 表：`farmer_id` 改为 `nullable`；新增 `type` (sell/buy), `quality_level` (特级/一级/二级)。
  - 新增 `MatchingService` 服务类，封装撮合逻辑。
  - `AiChatController`：支持无 `order_id` 的挂单模式，解析 AI 的 `[CREATE_ORDER: {...}]` 指令。
- **AI 提示词 (Prompts)**:
  - `DeepseekService`：新增 `INTENT_PROMPT`。支持识别用户身份并输出结构化 JSON 标记。
- **前端 (Flutter)**:
  - 新增 `MatchCard` 组件：在聊天中渲染匹配结果卡片。
  - 修改 `AiChatScreen`：支持双模式运行（挂单助手/调货助手）。
  - 首页入口：在欢迎语下方添加了“AI 挂单助手”卡片入口。

#### 3. 后续待办与风险 (Pending & Risks)
- **待办**: 实现匹配卡片点击后的“成交支付”流程。
- **待办**: 扩展匹配算法，支持地理位置距离优先匹配。
- **风险**: 若 AI 输出的 JSON 格式非法，后端解析会失败。目前已在 `INTENT_PROMPT` 中加强约束。

---

## 🛠 开发规范 (AI Context)
1. **国际化**: 所有 UI 文本和 AI 回复必须使用 **简体中文 (Simplified Chinese)**。
2. **安全性**: 所有涉及金额和逻辑的操作需在后端校验，AI 仅负责收集信息和前端展现建议。
3. **隔离性**: 始终保持买卖双方的身份匿名性，除非交易进入实质交货阶段。

---

*下一个 Agent 接入建议：在开始新代码前，请先完整阅读此文档并查看 `database/migrations` 确认最新表结构。*
