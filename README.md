# 🎮 Race Word Game - Flutter

<div align="center">

![Race Word Game](https://img.shields.io/badge/Flutter-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Desktop-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge)
![Version](https://img.shields.io/badge/Version-1.0.0-brightgreen.svg?style=for-the-badge)

**儿童英语单词学习游戏 - 趣味性功能完整版**

[功能介绍](#-功能特色) • [快速开始](#-快速开始) • [技术栈](#-技术栈) • [截图展示](#-截图展示) • [贡献指南](#-贡献指南)

</div>

---

## 🌟 功能特色

### 🎯 核心学习功能
- **单词卡片学习** - 视觉化单词记忆
- **语音播放** - 标准发音指导
- **点选答题** - 互动式学习体验
- **进度跟踪** - 学习统计和分析

### 🎆 趣味性功能 (新增!)

#### 1. 🔥 连击特效系统
- **视觉冲击** - 连续答对时的炫酷粒子特效
- **即时反馈** - 3连击起触发动画效果
- **振动反馈** - 每5连击振动提醒
- **成就感** - 不同连击数对应不同动画

#### 2. 🏆 成就系统
- **9个预设成就** - 青铜、白银、黄金、钻石四个等级
- **自动解锁** - 游戏结束时自动检查并展示新成就
- **精美弹窗** - 成就解锁时的炫酷展示界面
- **收集动力** - 激励儿童持续学习

#### 3. 🎤 语音评分功能
- **录音界面** - 精美的录音波形动画
- **AI评分** - 模拟智能评分系统 (60-100分)
- **鼓励反馈** - 根据分数给出不同鼓励语
- **发音练习** - 帮助儿童提高英语发音

### 🎨 视觉设计
- **Material 3 设计语言** - 现代化界面风格
- **儿童友好配色** - 鲜艳活泼的颜色搭配
- **流畅动画** - 页面切换和交互动画
- **响应式布局** - 适配不同屏幕尺寸

---

## 🚀 快速开始

### 环境要求

- **Flutter**: 3.13.0 或更高版本
- **Dart**: 3.1.0 或更高版本
- **Node.js**: 16.0 或更高版本 (后端 API)

### 安装步骤

#### 1. 克隆项目
```bash
git clone https://github.com/zivyuan/race-word-game-flutter.git
cd race-word-game-flutter
```

#### 2. 安装依赖
```bash
# Flutter 依赖
flutter pub get

# 如果需要运行后端 API
cd ../race-word-game-api
npm install
```

#### 3. 配置环境

##### 后端 API (可选)
```bash
# 复制环境变量文件
cp .env.example .env

# 编辑 .env 文件，配置数据库等信息
vim .env
```

##### Flutter 项目
```bash
# 检查设备连接
flutter devices

# 运行项目
flutter run
```

#### 4. 开始使用
1. **创建账户** - 设置用户昵称和头像
2. **创建卡片集** - 添加要学习的单词
3. **开始游戏** - 选择卡片集开始学习
4. **体验功能** - 享受连击特效、成就系统和语音评分

---

## 💻 技术栈

### 前端技术
- **Flutter** - 跨平台UI框架
- **Dart** - 编程语言
- **Material Design 3** - 设计系统
- **Provider** - 状态管理
- **Cached Network Image** - 图片缓存
- **Flutter TTS** - 语音合成

### 后端技术
- **Node.js** - 运行时环境
- **Express.js** - Web 框架
- **TypeScript** - 类型安全
- **MySQL** - 数据库
- **Drizzle ORM** - 数据库查询
- **Redis** - 缓存 (可选)

### 开发工具
- **GitHub Actions** - CI/CD
- **Docker** - 容器化部署
- **VS Code** - 代码编辑器
- **Android Studio** - 安卓开发

---

## 📱 截图展示

### 🎮 游戏界面
| 主界面 | 游戏进行 | 成就解锁 |
|--------|----------|----------|
| ![Home](https://via.placeholder.com/300x600/02569B/FFFFFF?text=Home+Screen) | ![Game](https://via.placeholder.com/300x600/02569B/FFFFFF?text=Game+Screen) | ![Achievement](https://via.placeholder.com/300x600/02569B/FFFFFF?text=Achievement) |

### 🎆 趣味功能
| 连击特效 | 语音评分 | 成就收集 |
|----------|----------|----------|
| ![Combo](https://via.placeholder.com/300x600/FF4500/FFFFFF?text=Combo+Effect) | ![Voice](https://via.placeholder.com/300x600/32CD32/FFFFFF?text=Voice+Score) | ![Collection](https://via.placeholder.com/300x600/9370DB/FFFFFF?text=Achievement+Collection) |

---

## 📁 项目结构

```
race-word-game-flutter/
├── lib/
│   ├── models/                 # 数据模型
│   │   ├── models.dart
│   │   └── achievement_models.dart
│   ├── screens/               # 屏幕页面
│   │   ├── home_screen.dart
│   │   ├── game_screen.dart
│   │   ├── voice_score_screen.dart
│   │   └── ...
│   ├── widgets/              # UI 组件
│   │   ├── combo_effect.dart
│   │   ├── achievement_dialog.dart
│   │   └── ...
│   ├── services/             # 服务类
│   ├── theme/                # 主题配置
│   └── main.dart             # 应用入口
├── test/                    # 测试文件
├── docs/                    # 项目文档
├── pubspec.yaml            # 项目配置
└── README.md               # 说明文档
```

---

## 🎯 开发计划

### ✅ v1.0.0 (已发布)
- [x] 基础单词学习功能
- [x] Material 3 设计风格
- [x] 连击特效系统
- [x] 成就解锁系统
- [x] 语音评分功能
- [x] 数据统计和分析

### 🔮 v1.1.0 (计划中)
- [ ] 多人对战模式
- [ ] AR 单词展示
- [ ] 语音识别增强
- [ ] 云端同步功能
- [ ] 更多成就和奖励

---

## 🤝 贡献指南

我们欢迎社区贡献！请遵循以下步骤：

### 1. Fork 项目
```bash
gh repo fork zivyuan/race-word-game-flutter
```

### 2. 创建功能分支
```bash
git checkout -b feature/AmazingFeature
```

### 3. 提交更改
```bash
git commit -m 'Add some AmazingFeature'
```

### 4. 推送到分支
```bash
git push origin feature/AmazingFeature
```

### 5. 打开 Pull Request

---

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

---

## 🙏 致谢

感谢所有为这个项目做出贡献的开发者和设计师！

### 特别感谢
- **Flutter 团队** - 优秀的跨平台框架
- **Material Design 团队** - 现代化设计系统
- **社区贡献者** - 功能建议和问题反馈

---

## 📞 联系我们

- **问题反馈**: [GitHub Issues](https://github.com/zivyuan/race-word-game-flutter/issues)
- **功能建议**: [GitHub Discussions](https://github.com/zivyuan/race-word-game-flutter/discussions)
- **邮件联系**: [contact@example.com](mailto:contact@example.com)

---

<div align="center">

**⭐ 如果这个项目对你有帮助，请考虑给我们一个 Star！**

![Star History](https://img.shields.io/github/stars/zivyuan/race-word-game-flutter?style=social)

</div>