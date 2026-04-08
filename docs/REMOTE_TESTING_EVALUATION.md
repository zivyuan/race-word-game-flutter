# 远程测试方案评估报告

> 版本: 1.0 | 日期: 2026-04-09 | 作者: Mac (QA Lead)

---

## 目录

1. [评估背景与目标](#1-评估背景与目标)
2. [云真机平台评估](#2-云真机平台评估)
3. [iOS 远程测试方案评估](#3-ios-远程测试方案评估)
4. [CI/CD 集成测试评估](#4-cicd-集成测试评估)
5. [本项目推荐方案](#5-本项目推荐方案)
6. [成本对比总结](#6-成本对比总结)
7. [实施路线图](#7-实施路线图)

---

## 1. 评估背景与目标

### 1.1 项目特点

- **框架**: Flutter (Dart) — 跨平台 iOS/Android
- **目标用户**: 儿童 — 需要大量真机测试（语音、相机、AR）
- **关键功能**: 语音识别、TTS、相机、AR、离线数据库、通知
- **当前痛点**: 无 iOS 真机、需要远程测试能力、CI/CD 自动化缺失

### 1.2 评估维度

| 维度 | 权重 | 说明 |
|------|------|------|
| Flutter 兼容性 | 25% | 原生支持 vs 需要适配层 |
| 设备覆盖 | 20% | iOS/Android 设备种类和数量 |
| 成本 | 20% | 免费额度、按量计费、包月 |
| 集成难度 | 15% | CI/CD 集成、配置复杂度 |
| 调试能力 | 10% | 日志、截图、视频回放 |
| 可靠性 | 10% | 平台稳定性、队列等待时间 |

---

## 2. 云真机平台评估

### 2.1 Firebase Test Lab

**提供商**: Google

#### Flutter 支持
- **原生支持** — 可直接运行 Flutter integration tests
- Android: 上传 APK 直接测试
- iOS: 上传测试 zip 文件（需要额外配置）
- 支持 Flutter Driver 和 Patrol 框架

#### 设备覆盖

| 类型 | 数量 | 说明 |
|------|------|------|
| Android 虚拟设备 | ~30 型号 | 各版本 Android |
| Android 物理设备 | ~20 型号 | Pixel, Samsung, Moto |
| iOS 物理设备 | ~10 型号 | iPhone/iPad 系列 |

#### 定价

| 类型 | 免费额度 | 付费价格 |
|------|----------|----------|
| 虚拟设备 | 60 分钟/天 | $1/设备/小时 (~$0.017/分钟) |
| 物理设备 | 30 分钟/天 | $5/设备/小时 (~$0.083/分钟) |
| 付费要求 | — | Blaze (按量付费) 计划 |

#### 优势
- Flutter 社区最广泛使用，文档丰富
- 免费日额度对小型项目非常友好
- 与 Firebase Analytics/Crashlytics 深度集成
- Robo 测试可自动探索 UI

#### 劣势
- iOS 物理设备型号有限
- 无 Web/Desktop Flutter 测试
- 设备队列高峰期可能等待
- 物理设备仅限 iOS，不支持 Android 物理设备高级调试

#### 适用场景
- 日常开发迭代中的自动化测试
- 与 Firebase 生态深度集成的项目
- 预算有限的小型团队

#### 本项目评分: **8.2/10**

```
Flutter 兼容性: ★★★★★ (9/10)
设备覆盖:       ★★★☆☆ (6/10)
成本:           ★★★★★ (9/10)
集成难度:       ★★★★★ (9/10)
调试能力:       ★★★★☆ (8/10)
可靠性:         ★★★★☆ (7/10)
```

---

### 2.2 AWS Device Farm

**提供商**: Amazon Web Services

#### Flutter 支持
- **非原生** — 需要通过 Sylph 或 Appium 桥接
- Sylph: 将 Flutter Driver 测试包装为 Appium 兼容格式
- 配置复杂，需要额外维护适配层

#### 设备覆盖

| 类型 | 数量 | 说明 |
|------|------|------|
| Android 设备 | ~200+ 型号 | 覆盖最广 |
| iOS 设备 | ~100+ 型号 | 覆盖全面 |
| Web 浏览器 | 桌面浏览器 | Selenium 支持 |

#### 定价

| 类型 | 免费额度 | 付费价格 |
|------|----------|----------|
| 按需计费 | 1,000 分钟（一次性） | $0.17/设备/分钟 ($10.20/小时) |
| 无限套餐 | — | $250/月/设备槽位 |

#### 优势
- 设备目录最大，覆盖全面
- 支持无限套餐，高频测试性价比高
- 与 AWS CI/CD (CodeBuild, CodePipeline) 无缝集成
- 支持远程交互式调试 (Remote Access)

#### 劣势
- Flutter 需要额外适配层 (Sylph/Appium)
- 按需计费比 Firebase 贵 ~2x
- 学习曲线陡峭
- Sylph 社区维护，非官方支持

#### 适用场景
- AWS 生态内的项目
- 需要最广设备覆盖的企业
- 高频测试 (>50 小时/月) 使用无限套餐

#### 本项目评分: **6.5/10**

```
Flutter 兼容性: ★★★☆☆ (5/10)
设备覆盖:       ★★★★★ (9/10)
成本:           ★★★☆☆ (5/10)
集成难度:       ★★☆☆☆ (4/10)
调试能力:       ★★★★☆ (8/10)
可靠性:         ★★★★☆ (8/10)
```

---

### 2.3 BrowserStack (App Automate + App Live)

**提供商**: BrowserStack

#### Flutter 支持
- **通过 Appium** — 上传 APK/IPA 进行自动化测试
- 支持 Espresso/XCUITest 底层框架
- 需要将 Flutter 测试适配为 Appium 格式

#### 设备覆盖

| 类型 | 数量 | 说明 |
|------|------|------|
| Android 设备 | 2,000+ 型号 | 覆盖最广 |
| iOS 设备 | 1,500+ 型号 | 覆盖最广 |
| 总设备数 | 3,500+ | 包含平板 |

#### 定价

| 计划 | 价格 | 包含 |
|------|------|------|
| 免费试用 | 限时 | 功能受限 |
| Freelancer | $12.50/月 | 基础功能 |
| App Automate (年付) | $199/月 | 无限自动测试分钟 |
| App Automate (月付) | $249/月 | 无限自动测试分钟 |
| App Live | $29-199/月 | 手动远程测试 |

#### 优势
- **设备数量业界第一** — 3,500+ 真实设备
- **无限分钟** — App Automate 无测试时长限制
- 调试工具最强: 视频、截图、网络日志、控制台日志、Appium 日志
- 本地测试支持 (Local Testing)
- UI 直观，上手快

#### 劣势
- Flutter 原生支持不如 Firebase
- 包月价格对个人开发者偏高
- App Automate 和 App Live 分开计费
- 需要 Appium 适配层

#### 适用场景
- 需要最广设备覆盖的大规模测试
- 企业级测试需求，预算充足
- 同时需要 Web + Mobile 测试的团队

#### 本项目评分: **7.8/10**

```
Flutter 兼容性: ★★★☆☆ (7/10)
设备覆盖:       ★★★★★ (10/10)
成本:           ★★★☆☆ (6/10)
集成难度:       ★★★☆☆ (7/10)
调试能力:       ★★★★★ (10/10)
可靠性:         ★★★★★ (9/10)
```

---

### 2.4 Sauce Labs

**提供商**: Sauce Labs

#### Flutter 支持
- **通过 Appium** — 与 BrowserStack 类似
- 支持 Espresso/XCUITest
- 社区有 Flutter Appium 集成指南

#### 设备覆盖

| 类型 | 数量 | 说明 |
|------|------|------|
| Android/iOS 设备 | 800+ 型号 | 虚拟 + 物理 |
| 桌面浏览器 | 1,000+ 组合 | 跨浏览器 |

#### 定价

| 计划 | 价格 | 包含 |
|------|------|------|
| 免费试用 | 14 天 | 有限时长 |
| Starter | 按量 | ~$149/月起 |
| Pro | 按量 | ~$299/月起 |
| Enterprise | 定制 | SLA 保障 |

#### 优势
- 测试分析功能强大 (Test Analytics)
- 支持 Live Testing（手动远程测试）
- 与 Jira/Slack/Teams 集成良好
- 企业级 SLA 和支持

#### 劣势
- 定价不透明，按分钟计费复杂
- Flutter 文档较少
- 设备数量不如 BrowserStack
- 免费额度有限

#### 适用场景
- 已使用 Sauce Labs 的企业
- 需要强大测试分析报告的团队
- 有 Jira/Slack 集成需求

#### 本项目评分: **6.8/10**

```
Flutter 兼容性: ★★★☆☆ (6/10)
设备覆盖:       ★★★★☆ (7/10)
成本:           ★★★☆☆ (5/10)
集成难度:       ★★★☆☆ (7/10)
调试能力:       ★★★★☆ (8/10)
可靠性:         ★★★★★ (9/10)
```

### 2.5 云真机平台对比总结

| 维度 | Firebase Test Lab | AWS Device Farm | BrowserStack | Sauce Labs |
|------|-------------------|-----------------|--------------|------------|
| **Flutter 原生支持** | ✅ 是 | ❌ 需 Sylph | ⚠️ Appium | ⚠️ Appium |
| **设备总数** | ~60 | ~300+ | 3,500+ | 800+ |
| **免费额度** | 60min/天虚拟 | 1000min 一次性 | 限时试用 | 14 天试用 |
| **虚拟设备价格** | $1/hr | $10.20/hr | 不适用 | ~$6-10/hr |
| **物理设备价格** | $5/hr | $10.20/hr | $199-249/月无限 | ~$8-15/hr |
| **调试工具** | 良好 | 优秀 | 最优 | 优秀 |
| **CI/CD 集成** | 简单 | 需配置 | 简单 | 简单 |
| **本项目推荐** | ★★★★★ | ★★★☆☆ | ★★★★☆ | ★★★☆☆ |

---

## 3. iOS 远程测试方案评估

### 3.1 TestFlight Beta 测试

**提供商**: Apple (官方)

#### 工作流程
```
Xcode Archive → App Store Connect → TestFlight 分发 → 测试者安装 → 反馈收集
```

#### 能力

| 功能 | 详情 |
|------|------|
| 内部测试 | 最多 100 人，即时分发 |
| 外部测试 | 最多 10,000 人，需 Apple 审核 |
| 分发方式 | 邮件邀请 / 公开链接 |
| 构建有效期 | 90 天 |
| 反馈收集 | 内置截图、崩溃日志 |
| 分组测试 | A/B 测试（2025 新增） |
| 平台支持 | iOS, iPadOS, macOS, watchOS, tvOS, visionOS |

#### 优势
- **唯一官方渠道** — 最接近生产环境的测试
- **免费** — 包含在 Apple Developer 会员 ($99/年) 中
- **覆盖完整 iOS 生态** — 测试者使用自己的设备
- **2025 新增**: A/B 测试、iOS 26 SDK 支持
- 崩溃报告自动收集

#### 劣势
- 测试者需要有**自己的 iOS 设备**
- 外部测试需 Apple 审核（通常 < 24 小时）
- 无法自动化测试，依赖人工
- 无远程访问测试者设备的能力
- 反馈渠道有限（仅 App 内截图 + 文字）

#### 本项目适用性

对于「单词竞速卡片」项目：
- ✅ 适合收集儿童用户的真实使用反馈
- ✅ 适合验证语音识别、TTS 在真实设备上的表现
- ✅ 适合 AR 功能在不同 iPhone 上的兼容性
- ❌ 无法解决「团队无 iOS 设备」的核心问题
- ❌ 无法自动化回归测试

#### 本项目评分: **7.0/10** (作为分发工具)
#### 本项目评分: **3.0/10** (作为远程测试工具)

---

### 3.2 第三方真机租赁/云设备平台

#### 3.2.1 BrowserStack App Live (手动远程测试)

| 功能 | 详情 |
|------|------|
| 远程交互 | 实时操控真实 iOS 设备 |
| 设备型号 | 最新 iPhone 15/16 系列、iPad 系列 |
| 调试工具 | 实时日志、网络拦截、截图 |
| 价格 | $29-199/月 |
| 时区/语言 | 支持多时区、多语言环境 |

**适合**: 手动探索性测试、UI 兼容性验证

#### 3.2.2 AWS Device Farm Remote Access

| 功能 | 详情 |
|------|------|
| 远程交互 | SSH/VNC 连接真实设备 |
| 设备型号 | 覆盖全面 |
| 调试工具 | 交互式调试 |
| 价格 | $250/月/槽位 (无限) |
| 集成 | AWS 生态 |

**适合**: 需要深度调试的场景

#### 3.2.3 其他云设备平台

| 平台 | 特点 | 价格参考 |
|------|------|----------|
| **TestGrid** | 专注移动测试，支持自动化 | 按需定价 |
| **Pcloudy** | AI 驱动的测试推荐 | $99/月起 |
| **Perfecto** | 企业级，报告强大 | 定制定价 |
| **LambdaTest** | 新兴平台，性价比高 | 免费层 + 按量 |
| **Sauce Labs Live** | 手动远程测试 | 包含在套餐中 |

#### 3.2.4 自建设备农场

| 方案 | 成本 | 说明 |
|------|------|------|
| Mac mini + iPhone | ~$1,000 一次性 | 最小可行方案 |
| Mac Studio + 多设备 | ~$3,000-5,000 一次性 | 小团队方案 |
| MacStadium 租赁 | ~$50-200/月 | 云端 Mac |

**适合**: 长期项目，需要完全控制测试环境

---

### 3.3 iOS 远程测试方案对比

| 方案 | 自动化 | 远程操控 | 成本 | 设备多样性 |
|------|--------|----------|------|------------|
| **TestFlight** | ❌ | ❌ | $99/年 | 取决于测试者 |
| **BrowserStack App Live** | ❌ | ✅ | $29-199/月 | 3,500+ |
| **AWS Remote Access** | ❌ | ✅ | $250/月/槽位 | 300+ |
| **自建农场** | ✅ | ✅ | $1,000+ 一次性 | 自行购买 |
| **MacStadium** | ✅ | ✅ | $50-200/月 | 自行购买 |

---

## 4. CI/CD 集成测试评估

### 4.1 GitHub Actions + macOS Runner

#### Flutter 构建支持

```yaml
# 示例配置
jobs:
  build-ios:
    runs-on: macos-15          # Apple Silicon
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.22.x'
      - run: flutter pub get
      - run: flutter test
      - run: flutter build ios --release
```

#### 能力

| 功能 | 详情 |
|------|------|
| macOS Runner | Intel (macos-13) / Apple Silicon (macos-14, macos-15) |
| 免费额度 | 公开仓库无限；私有仓库 2,000 min/月 (Linux) |
| macOS 价格 | ~$0.08/分钟 (10x Linux 乘数) |
| 自托管 Runner | ✅ 支持（可消除分钟费用） |
| 缓存支持 | ✅ pub cache、build cache |
| 并行任务 | 取决于仓库计划 |

#### iOS 签名

- 需要手动配置证书和 Provisioning Profile
- 通常配合 fastlane match 管理签名
- 可使用 GitHub Secrets 存储敏感信息
- 配置复杂度: **中高**

#### 优势
- 与 GitHub 深度集成（PR、Issues、Releases）
- 庞大的 Actions Marketplace
- 灵活性最高
- 公开仓库免费
- 自托管可消除运行成本

#### 劣势
- macOS 分钟费用高
- iOS 签名配置复杂
- 冷启动时间长 (~20-40 秒)
- 无内置 TestFlight 部署（需 fastlane）

#### 本项目评分: **7.5/10**

```
Flutter 支持:  ★★★★☆ (8/10)  - 社区 Actions 成熟
iOS 构建:     ★★★☆☆ (6/10)  - 签名配置复杂
成本:         ★★★☆☆ (6/10)  - macOS 分钟贵
灵活性:       ★★★★★ (10/10) - 最灵活
易用性:       ★★★☆☆ (7/10)  - 配置工作量中等
```

---

### 4.2 Codemagic

#### Flutter 专精 CI/CD

```yaml
# 示例配置 (codemagic.yaml)
workflows:
  ios-build:
    name: iOS Build & Test
    environment:
      flutter: 3.22.x
      xcode: latest
    scripts:
      - flutter pub get
      - flutter test
      - flutter build ipa
    publishing:
      app_store_connect:
        submit_to_testflight: true
```

#### 能力

| 功能 | 详情 |
|------|------|
| macOS Runner | Apple Silicon (M1/M2) 专用 |
| 免费额度 | 500 分钟/月 |
| 付费起步 | ~$20/月 |
| iOS 签名 | **内置管理** — 无需手动配置 |
| TestFlight | **一键部署** |
| 跨平台 | iOS + Android 同时构建 |

#### 优势
- **Flutter 最佳 CI/CD** — 开箱即用
- 签名管理自动化，省去最大痛点
- TestFlight 部署一键完成
- 预装 Flutter SDK，零配置
- 构建时间优化（缓存、增量构建）

#### 劣势
- 通用生态不如 GitHub Actions
- macOS 分钟比 GitHub Actions 稍贵
- 无自托管选项
- 非 Flutter 项目支持有限

#### 本项目评分: **9.0/10**

```
Flutter 支持:  ★★★★★ (10/10) - 原生专精
iOS 构建:     ★★★★★ (10/10) - 签名自动化
成本:         ★★★★☆ (7/10)  - 免费层够用
灵活性:       ★★★☆☆ (6/10)  - 专注 Flutter
易用性:       ★★★★★ (10/10) - 最简单
```

---

### 4.3 Cirrus CI

#### 能力

| 功能 | 详情 |
|------|------|
| macOS Runner | Intel + Apple Silicon |
| 免费额度 | 公开仓库免费 |
| Apple Silicon | ✅ M1/M2 支持 |
| 配置 | .cirrus.yml |
| Docker | 支持 macOS Docker |

#### 优势
- Apple Silicon 性能优异
- 开源友好
- 配置灵活
- 竞争性定价

#### 劣势
- Flutter 专用工具少
- 社区和 Marketplace 较小
- iOS 签名文档不足
- 调试体验不如前两者

#### 本项目评分: **6.5/10**

```
Flutter 支持:  ★★★☆☆ (6/10)
iOS 构建:     ★★★☆☆ (5/10)
成本:         ★★★★☆ (8/10)
灵活性:       ★★★★☆ (8/10)
易用性:       ★★★☆☆ (5/10)
```

---

### 4.4 CI/CD 方案对比

| 维度 | GitHub Actions | Codemagic | Cirrus CI |
|------|---------------|-----------|-----------|
| **Flutter 开箱即用** | ⚠️ 需配置 | ✅ 原生 | ⚠️ 需配置 |
| **iOS 签名自动化** | ❌ 手动+fastlane | ✅ 内置 | ❌ 手动 |
| **TestFlight 部署** | via fastlane | ✅ 一键 | via fastlane |
| **免费额度** | 2000 min/月(私有) | 500 min/月 | 公开免费 |
| **macOS 成本** | ~$0.08/min | ~$0.10-0.15/min | 竞争性 |
| **Apple Silicon** | ✅ | ✅ | ✅ |
| **自托管** | ✅ | ❌ | ❌ |
| **生态/插件** | 最大 | Flutter 专精 | 小 |
| **本项目推荐** | ★★★★☆ | ★★★★★ | ★★★☆☆ |

---

## 5. 本项目推荐方案

### 5.1 当前阶段（开发期）

**推荐组合**: Codemagic + Firebase Test Lab

```
┌─────────────────────────────────────────────┐
│                CI/CD Pipeline                │
│                                              │
│  GitHub Push/PR                              │
│       │                                      │
│       ▼                                      │
│  ┌─────────────┐                             │
│  │  Codemagic   │  ← iOS/Android 构建        │
│  │  Flutter 专精 │  ← 自动签名               │
│  └──────┬──────┘  ← 单元测试 + Widget 测试    │
│         │                                   │
│         ▼                                   │
│  ┌─────────────────┐                        │
│  │ Firebase Test Lab │  ← Android 真机/虚拟   │
│  │ Integration Tests │  ← 免费日额度          │
│  └─────────────────┘                        │
│         │                                   │
│         ▼                                   │
│  ┌─────────────────┐                        │
│  │   TestFlight     │  ← iOS Beta 分发       │
│  │ (手动测试)       │  ← 收集真实反馈         │
│  └─────────────────┘                        │
└─────────────────────────────────────────────┘
```

#### 理由
1. **Codemagic**: Flutter 项目的最佳 CI/CD，签名自动化省去最大痛点，500 分钟免费层足够日常开发
2. **Firebase Test Lab**: 免费日额度覆盖 Android 自动化测试，Flutter 原生支持
3. **TestFlight**: iOS 真机测试的唯一官方渠道，配合外部测试者收集反馈

#### 预估月成本

| 服务 | 免费层 | 预估超出 | 月费用 |
|------|--------|----------|--------|
| Codemagic | 500 min/月 | ~200 min | ~$10 |
| Firebase Test Lab | 60 min/天 | 通常不超 | $0 |
| TestFlight | 含在 $99/年 | — | ~$8 |
| **月总计** | — | — | **~$18** |

### 5.2 中期阶段（发布前）

**增加**: BrowserStack App Automate

- 在发布前进行全面设备兼容性测试
- 覆盖低端 Android 和旧 iOS 设备
- 月付 $199（仅在发布冲刺月启用）

### 5.3 长期阶段（稳定运营）

**升级方案**: GitHub Actions 自托管 macOS Runner

```
┌──────────────────────────────────────────────┐
│              长期 CI/CD 架构                   │
│                                               │
│  自托管 Mac mini ($1,000 一次性)               │
│       │                                       │
│       ├─► GitHub Actions Runner                │
│       │    ├─► iOS 构建 + 测试                 │
│       │    ├─► TestFlight 自动部署             │
│       │    └─► Firebase Test Lab 集成          │
│       │                                       │
│       └─► BrowserStack (按需)                  │
│            └─► 大规模设备兼容性测试              │
└──────────────────────────────────────────────┘
```

- 消除 macOS 分钟费用
- 完全控制构建环境
- 可本地连接 iPhone 进行 E2E 测试

---

## 6. 成本对比总结

### 月度成本估算（活跃开发期）

| 方案 | 配置 | 月成本 | 年成本 |
|------|------|--------|--------|
| **推荐方案** | Codemagic + FTL + TestFlight | ~$18 | ~$216 |
| GitHub Actions | 全部 GitHub 生态 | ~$30-50 | ~$360-600 |
| 全 BrowserStack | App Automate + App Live | ~$249 | ~$2,988 |
| 全 AWS | Device Farm + CodeBuild | ~$250-300 | ~$3,000-3,600 |
| 自建 | Mac mini + GitHub Actions | ~$50 (电费) | ~$1,100 (含设备) |

### ROI 分析

| 方案 | 设备覆盖 | 测试效率 | 成本效率 |
|------|----------|----------|----------|
| **推荐方案** | ★★★☆☆ | ★★★★☆ | ★★★★★ |
| GitHub Actions | ★★★☆☆ | ★★★★☆ | ★★★☆☆ |
| 全 BrowserStack | ★★★★★ | ★★★★★ | ★★☆☆☆ |
| 全 AWS | ★★★★☆ | ★★★★☆ | ★★☆☆☆ |
| 自建 | ★★☆☆☆ | ★★★★☆ | ★★★★★ |

---

## 7. 实施路线图

### Phase 1: 基础搭建 (第 1 周)

- [ ] 注册 Codemagic，配置 Flutter 项目
- [ ] 配置 iOS 签名（证书 + Provisioning Profile）
- [ ] 配置 Firebase Test Lab（Android）
- [ ] 编写基础 CI pipeline（lint + unit test + build）
- [ ] 配置 TestFlight 分发

### Phase 2: 自动化测试 (第 2-3 周)

- [ ] 将 TEST_PLAN.md 中的 E2E 用例实现为 integration_test
- [ ] 配置 Firebase Test Lab 运行 integration tests
- [ ] 配置 Codemagic 自动部署到 TestFlight
- [ ] 添加 PR 自动测试 gate

### Phase 3: 扩展覆盖 (第 4 周)

- [ ] 集成 BrowserStack（发布前测试）
- [ ] 配置 Android 构建自动化
- [ ] 添加性能测试基线
- [ ] 配置测试报告收集

### Phase 4: 持续优化 (持续)

- [ ] 根据测试结果优化测试用例
- [ ] 评估自建 macOS Runner 的 ROI
- [ ] 扩展设备覆盖范围
- [ ] 集成崩溃报告和分析

---

## 附录

### A. 参考链接

- [Firebase Test Lab - Flutter 集成](https://firebase.google.com/docs/test-lab/flutter/integration-testing-with-flutter)
- [Firebase Test Lab 定价](https://firebase.google.com/docs/test-lab/usage-quotas-pricing)
- [AWS Device Farm 定价](https://aws.amazon.com/device-farm/pricing/)
- [BrowserStack 定价](https://www.browserstack.com/pricing)
- [Codemagic 官网](https://codemagic.io/)
- [TestFlight - Apple Developer](https://developer.apple.com/testflight/)
- [Top Device Farms 2026 - TestGrid](https://testgrid.io/blog/best-device-farms/)
- [Best Device Farms 2026 - Panto AI](https://www.getpanto.ai/blog/device-farms-for-mobile-testing)

### B. 决策记录

| 日期 | 决策 | 理由 |
|------|------|------|
| 2026-04-09 | 选择 Codemagic 作为 CI/CD | Flutter 专精，签名自动化 |
| 2026-04-09 | 选择 Firebase Test Lab 作为云真机 | 免费日额度，原生 Flutter 支持 |
| 2026-04-09 | 选择 TestFlight 作为 iOS Beta 分发 | 官方渠道，覆盖真实用户场景 |
| 2026-04-09 | 保留 BrowserStack 作为发布前扩展 | 最大设备覆盖，补充兼容性测试 |

---

> **结论**: 推荐采用 **Codemagic + Firebase Test Lab + TestFlight** 的组合方案，月成本约 $18，满足当前开发期所有测试需求。发布前按需引入 BrowserStack 进行全面兼容性验证。长期可考虑自建 Mac mini 降低 CI/CD 成本。
