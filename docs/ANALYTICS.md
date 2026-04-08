# 单词竞速卡片 - 数据监控与分析方案

**版本**: 1.0
**日期**: 2026-04-09
**负责人**: Scout

---

## 一、核心指标体系

### 1.1 用户指标（DAU/MAU）

| 指标 | 说明 | 数据来源 |
|------|------|----------|
| DAU | 日活跃用户数 | `SELECT COUNT(DISTINCT userId) FROM game_records WHERE lastPlayedAt >= CURDATE()` |
| MAU | 月活跃用户数 | `SELECT COUNT(DISTINCT userId) FROM game_records WHERE lastPlayedAt >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)` |
| 新用户注册数 | 每日注册量 | `SELECT COUNT(*) FROM users WHERE createdAt >= CURDATE()` |
| 留存率 | 次日/7日留存 | 用户表 createdAt 关联 game_records |

### 1.2 使用指标

| 指标 | 说明 | 计算方式 |
|------|------|----------|
| 人均卡片集数 | 用户创建的卡片集数量 | `cardsets` 表 GROUP BY userId |
| 人均卡片数 | 每个卡片集的平均卡片数 | `cards` 表 GROUP BY cardSetId |
| 人均游戏局数 | 用户每天玩游戏次数 | `game_records` 中 timesShown 统计 |
| 平均游戏时长 | 每局游戏持续时间 | 前端埋点上报（1.1 实现） |

### 1.3 学习效果指标

| 指标 | 说明 | 计算方式 |
|------|------|----------|
| 平均正确率 | `SUM(timesKnown) / SUM(timesShown)` | `game_records` 表聚合 |
| 掌握卡片数 | `timesKnown >= 5` 的卡片数 | `game_records` 表 |
| 学习覆盖率 | 有记录的卡片 / 总卡片 | `game_records` JOIN `cards` |
| 连续学习天数 | 用户连续活跃天数 | `game_records.lastPlayedAt` 排序 |

### 1.4 系统指标

| 指标 | 说明 | 监控方式 |
|------|------|----------|
| API 响应时间 | P50/P95/P99 | index.ts 请求日志（已有 duration） |
| 错误率 | 5xx / 总请求 | 请求日志 level=ERROR |
| 图片上传量 | 每日上传文件数 | `uploads/cards/` 目录统计 |
| 数据库连接池 | 当前/最大连接数 | MySQL `SHOW STATUS` |

---

## 二、数据收集方案

### 2.1 后端现有数据

API 已有请求日志，包含：
- 时间戳
- HTTP 方法和路径
- 状态码
- 响应时间（ms）

**优化建议（1.1）**：
```typescript
// 在请求日志中增加 userId 和设备信息
app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    const duration = Date.now() - start;
    const userId = req.body?.userId || req.query?.userId || 'anonymous';
    console.log(JSON.stringify({
      ts: new Date().toISOString(),
      method: req.method,
      path: req.originalUrl,
      status: res.statusCode,
      duration,
      userId,
      ua: req.headers['user-agent'],
    }));
  });
  next();
});
```

### 2.2 数据库统计查询

```sql
-- 每日活跃用户数（过去 7 天）
SELECT
  DATE(lastPlayedAt) as date,
  COUNT(DISTINCT card_id) as active_cards
FROM game_records
WHERE lastPlayedAt >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
GROUP BY DATE(lastPlayedAt)
ORDER BY date;

-- 用户学习进度分布
SELECT
  CASE
    WHEN timesKnown >= 5 THEN 'mastered'
    WHEN timesShown > 0 THEN 'learning'
    ELSE 'new'
  END as level,
  COUNT(*) as count
FROM game_records
GROUP BY level;

-- 最热门卡片集（按游戏次数排序）
SELECT
  cs.name,
  cs.id,
  SUM(gr.timesShown) as total_plays,
  COUNT(DISTINCT gr.id) as record_count
FROM cardsets cs
JOIN cards c ON c.cardSetId = cs.id
LEFT JOIN game_records gr ON gr.cardId = c.id
GROUP BY cs.id, cs.name
ORDER BY total_plays DESC
LIMIT 10;
```

### 2.3 前端埋点方案（1.2 实现）

关键事件：
- `app_open` - 应用启动
- `user_register` - 用户注册
- `cardset_create` - 创建卡片集
- `card_create` - 添加卡片
- `game_start` - 开始游戏
- `game_end` - 游戏结束（附 score/total/accuracy）
- `card_tap` - 点击卡片（附 correct/wrong）

---

## 三、监控告警

### 3.1 健康检查

API 已提供 `GET /api/health`，建议配置：
- 每 1 分钟检查一次
- 连续 3 次失败触发告警
- 通过 PM2 自动重启

```bash
# 简单健康检查脚本
*/1 * * * * curl -sf http://localhost:3000/api/health || systemctl restart race-word-game-api
```

### 3.2 错误告警

- 5xx 错误连续 5 次 → 立即通知
- API 响应时间 > 3s → 性能预警
- 数据库连接失败 → 基础设施告警

---

## 四、MVP 阶段数据目标

| 指标 | 1.0 目标 | 1.1 目标 | 1.2 目标 |
|------|----------|----------|----------|
| 日活用户 | 10+ | 50+ | 200+ |
| 次日留存 | 30%+ | 40%+ | 50%+ |
| 平均正确率 | 60%+ | 65%+ | 70%+ |
| 掌握卡片率 | 10%+ | 20%+ | 30%+ |
| API 可用性 | 99%+ | 99.5%+ | 99.9%+ |
