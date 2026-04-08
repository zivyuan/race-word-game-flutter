# 单词竞速卡片 - QA 测试报告

**测试人员**: Mac (PocketForge QA)
**测试日期**: 2026-04-09
**测试范围**: 后端 API + Flutter 客户端
**版本**: 1.0.0

---

## 一、项目概况

| 项目 | 技术栈 | 文件数 | 代码行数(约) |
|------|--------|--------|-------------|
| 后端 API | Node.js + Express + TypeScript + Drizzle ORM + MySQL | 14 | ~600 |
| Flutter 客户端 | Dart + Flutter 3.x + Material 3 | 10 | ~1200 |

---

## 二、Bug 列表

### 严重 (Critical)

| # | 模块 | 描述 | 文件:行号 | 状态 |
|---|------|------|-----------|------|
| C1 | Flutter | **路由崩溃**: HomeScreen 在用户不存在时调用 `pushReplacementNamed('/onboarding')`，但应用未定义任何命名路由，会导致运行时崩溃 | `home_screen.dart:40` | 待修复 |
| C2 | API | **upsert 竞态条件**: `GameRecordRepository.upsert()` 存在 TOCTOU 竞态条件，并发请求可能导致重复插入或主键冲突 | `GameRecordRepository.ts:7-32` | 待修复 |

### 中等 (Medium)

| # | 模块 | 描述 | 文件:行号 | 状态 |
|---|------|------|-----------|------|
| M1 | Flutter | **API 错误码未检查**: `ApiService._parseResponse()` 不检查 HTTP 状态码，服务端 500 错误会被当作 JSON 解析失败而非服务器错误 | `api_service.dart:134-140` | 待修复 |
| M2 | Flutter | **游戏结果连击显示错误**: 结果页显示的"最高连续"实际是最终 streak 值（如果最后一题答错则为 0），不是游戏中的最高连击 | `game_screen.dart:390` | 待修复 |
| M3 | Flutter | **倒计时文案错误**: `_countdown > 1` 时统一显示 "3..."，但实际倒计时是 3 和 2，文案应区分 | `game_screen.dart:222` | 待修复 |
| M4 | Flutter | **未使用的导入**: `card_set_detail_screen.dart` 导入了 `dart:io` 但未使用 | `card_set_detail_screen.dart:1` | 待修复 |
| M5 | Flutter | **依赖未使用**: `cached_network_image` 已添加为依赖但实际使用的是 `Image.network`，浪费包体积 | `pubspec.yaml:19` | 待修复 |
| M6 | Flutter | **游戏统计未展示**: `ApiService.getGameStats()` 已实现但在 UI 中从未调用，掌握等级功能形同虚设 | `api_service.dart:112-119` | 待修复 |

### 轻微 (Low)

| # | 模块 | 描述 | 文件:行号 | 状态 |
|---|------|------|-----------|------|
| L1 | Flutter | **API 地址硬编码**: baseUrl 硬编码为 `http://10.0.2.2:3000`，无法通过配置切换环境 | `api_service.dart:7` | 待改进 |
| L2 | Flutter | **无下拉刷新**: HomeScreen 和 CardSetDetailScreen 缺少下拉刷新功能 | `home_screen.dart`, `card_set_detail_screen.dart` | 待改进 |
| L3 | Flutter | **totalCards 硬编码为 0**: HomeScreen 中 `totalCards` 写死为 0，注释 TODO 未实现 | `home_screen.dart:91` | 待改进 |
| L4 | API | **CORS 完全开放**: `app.use(cors())` 允许所有来源访问，生产环境应限制 | `index.ts:13` | 待改进 |
| L5 | API | **无速率限制**: 所有 API 端点无请求频率限制，易受滥用 | - | 待改进 |
| L6 | API | **无认证机制**: 所有端点公开访问，用户可操作其他用户的数据 | - | 待改进 |

---

## 三、代码质量评估

### 后端 API

| 维度 | 评分 | 说明 |
|------|------|------|
| 架构设计 | ★★★★☆ | 分层清晰（routes → repositories → db），类型定义完善 |
| 代码规范 | ★★★★☆ | TypeScript 严格模式，ESLint 配置完整 |
| 错误处理 | ★★★☆☆ | 统一 try-catch 但 err 类型为 any，缺少错误分类 |
| 安全性 | ★★☆☆☆ | 无认证、无速率限制、CORS 全开 |
| 数据完整性 | ★★★★☆ | 外键级联删除、参数化查询防 SQL 注入 |
| 测试覆盖 | ★☆☆☆☆ | 无任何测试 |

### Flutter 客户端

| 维度 | 评分 | 说明 |
|------|------|------|
| 架构设计 | ★★★☆☆ | 简单的 StatefulWidget + ApiService，适合小型项目 |
| UI/UX | ★★★★☆ | Material 3 设计，动画流畅，中文界面友好 |
| 状态管理 | ★★★☆☆ | SharedPreferences 存本地状态，未使用 Provider（虽然已引入） |
| 错误处理 | ★★★☆☆ | 基本的 try-catch + SnackBar，但网络错误提示不够友好 |
| 性能 | ★★★☆☆ | 使用 Image.network 而非 CachedNetworkImage，无列表优化 |
| 测试覆盖 | ★☆☆☆☆ | 仅 1 个基础渲染测试 |

---

## 四、端到端测试用例

### TC-001: 新用户注册流程
1. 启动应用 → 显示欢迎页
2. 点击"开始使用" → 进入昵称输入页
3. 输入昵称"小明" → 点击"下一步"
4. 选择头像 🐱 → 点击"开始学习！"
5. **预期**: 调用 `POST /api/user` 创建用户，保存到 SharedPreferences，跳转至首页

### TC-002: 创建卡片集
1. 首页点击"新建" → 弹出创建卡片集页面
2. 输入名称"动物单词" → 点击"创建"
3. **预期**: 调用 `POST /api/cardsets`，返回首页，列表显示新卡片集

### TC-003: 使用预设模板创建
1. 创建卡片集页面 → 点击"动物单词 🐾"
2. **预期**: 直接创建并返回首页

### TC-004: 添加卡片
1. 进入卡片集详情 → 点击"拍照添加"
2. 拍照 → 输入单词"apple" → 确定
3. **预期**: 调用 `POST /api/cards`（multipart），卡片出现在列表中

### TC-005: 删除卡片集
1. 首页长按卡片集 → 弹出确认对话框
2. 点击"删除"
3. **预期**: 调用 `DELETE /api/cardsets/:id`，列表更新

### TC-006: 开始游戏
1. 卡片集详情页（有 >= 2 张卡片）→ 点击播放按钮
2. 点击"开始游戏"
3. **预期**: 5 秒倒计时后进入游戏，TTS 朗读单词

### TC-007: 游戏答题
1. 听到 TTS 朗读后，点击正确卡片
2. **预期**: 显示"答对了！✅"，得分 +1，记录 `record-shown` 和 `record-known`

### TC-008: 游戏答错
1. 听到 TTS 朗读后，点击错误卡片
2. **预期**: 显示正确答案，连击归零，记录 `record-shown`

### TC-009: 游戏结束
1. 完成 `卡片数 × 2` 轮答题
2. **预期**: 显示成绩统计（总题数、答对、正确率、最高连续）

### TC-010: 网络异常处理
1. 关闭 API 服务 → 打开应用
2. **预期**: 加载失败时显示 SnackBar 错误提示，应用不崩溃

### TC-011: 重新打开应用
1. 已注册用户关闭应用 → 重新打开
2. **预期**: 直接进入首页，无需重新注册

---

## 五、性能与兼容性

### API 性能
- 所有接口使用 Drizzle ORM 参数化查询，无 SQL 注入风险
- 数据库连接池配置：最大 10 连接，5 空闲，60 秒超时
- 文件上传限制 10MB，仅允许图片格式
- **建议**: 添加接口响应时间日志（已有请求日志，含 duration）

### Flutter 性能
- `Image.network` 未缓存，建议改用 `CachedNetworkImage`（已引入依赖）
- GridView 未配置 `cacheExtent`
- 无懒加载机制（数据量小，暂不影响）

### 兼容性
- **Android**: 最低 SDK 版本未明确限制，Flutter 默认支持 API 21+（Android 5.0）
- **iOS**: 默认支持 iOS 12+
- **屏幕适配**: 使用 GridView 固定 2 列，响应式布局
- **TTS**: 依赖系统 TTS 引擎，部分设备可能无英文语音包

---

## 六、已交付文档

| 文档 | 位置 | 说明 |
|------|------|------|
| API 接口文档 | `race-word-game-api/docs/API.md` | 全部接口的请求/响应格式 |
| 部署指南 | `race-word-game-api/docs/DEPLOY.md` | 后端和客户端部署步骤 |
| Flutter 单元测试 | `race-word-game-flutter/test/` | models、theme、game_logic |
| API 集成测试 | `race-word-game-api/test/api.test.ts` | 全接口测试用例 |
| QA 报告 | 本文档 | Bug 列表、测试用例、评估 |

---

## 七、总结

### 必须修复（上线前）
1. **C1**: HomeScreen 路由崩溃 → 改为直接 push OnboardingScreen
2. **C2**: GameRecord upsert 竞态 → 使用 INSERT ON DUPLICATE KEY UPDATE
3. **M1**: ApiService 未检查 HTTP 状态码 → 在 _parseResponse 中添加状态码校验

### 建议改进
1. 使用 CachedNetworkImage 替换 Image.network
2. 实现 getGameStats 在 UI 中的展示（学习进度页面）
3. 添加环境配置机制，支持 dev/staging/prod 切换
4. 移除未使用的 dart:io 导入和 provider 依赖（或实际使用它们）

### 整体评价
项目核心功能完整，代码结构清晰，适合作为儿童英语学习工具。主要风险点在于缺少认证机制和测试覆盖。建议在正式发布前修复 3 个 Critical/Medium 级别问题。
