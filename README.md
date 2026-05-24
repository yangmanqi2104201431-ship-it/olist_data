# olist_data

# Olist 巴西电商数据分析项目

> 基于 Kaggle 公开数据集，完整还原从数据清洗、建模到可视化的电商分析全流程。  
> 数据范围：**2016-09 ~ 2018-08**｜工具栈：**MySQL · Python · Tableau**

---

## 项目简介

本项目使用 [Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) 巴西电商公开数据集，针对平台的经营健康度进行系统性分析，覆盖以下四大主题：

| 分析模块 | 核心问题 | 关键结论 |
|---|---|---|
| **数据质量** | 原始数据可用吗？ | 整体质量良好，GMV 口径误差 < 0.02% |
| **留存与漏斗** | 用户来了会再来吗？ | 复购率仅 1.81%，M+1 留存悬崖式跌至 0.45% |
| **销售与 RFM** | 钱从哪里来？谁在花钱？ | 月均 GMV 同比增长 83%；93% 用户只买一次 |
| **差评根因** | 差评从哪里来？怎么治？ | 延迟是首因，消除延迟可降低约 30% 差评率 |

**项目适合谁看：**
- 正在学习 SQL / 数据分析的同学，参考完整的建模思路与 SQL 写法
- 准备数据分析岗位面试，需要一个有深度的项目案例
- 对电商业务数据指标体系感兴趣的业务同学

---

## 目录结构

```
Olist_data/
│
├── create_tables.sql/              # SQL 脚本（按执行顺序编号）
│   ├── 01_create_tables.sql        # 建库、建表、导入原始 CSV
│   ├── 02_fact_orders.sql          # 构建核心宽表 fact_orders
│   ├── 03_build_dm..sql            # 构建 DM 层聚合表（KPI/地区/品类/RFM）
│   ├── 04_cohort_retention.sql     # Cohort 留存分析
│   ├── 05_funnel_analysis.sql      # 转化漏斗分析
│   ├── 06_sales_trends.sql         # 销售趋势与结构拆解
│   ├── 07_rfm_segmentation.sql     # RFM 用户分层
│   └── 08_review_rootcause.sql     # 差评根因分析
│
├── 数据质量/                        # Python 数据质量自动化检查
│   ├── 01_data_quality_checks.ipynb
│   ├── run_data_quality_checks.py
│   ├── 缺失值.xls
│   └── reports/
│       ├── python_data_quality_metrics.json
│       └── python_data_quality_report.md
│
├── 事件表/                          # SQL 查询结果导出（CSV）
│   ├── fact_orders_*.csv           # 核心宽表（~19 MB）
│   ├── dm_kpi_daily_*.csv          # 日粒度 KPI 汇总
│   ├── dm_customer_rfm_*.csv       # 客户 RFM 属性
│   ├── dm_category_daily_*.csv     # 品类日粒度
│   ├── dm_state_daily_*.csv        # 地区日粒度
│   └── hourly_user_order_stats_*.csv
│
├── 留存与漏斗/                       # 留存 & 漏斗分析结果（CSV）
│   ├── cohort_matrix.csv
│   ├── cohort_summary.csv
│   ├── funnel_overall.csv
│   ├── funnel_monthly.csv
│   ├── funnel_by_category.csv
│   ├── funnel_dropoff.csv
│   └── repurchase_summary.csv
│
├── 销售与RFM分析/                    # 销售趋势 & RFM 结果（CSV）
│   ├── sales_monthly.csv
│   ├── sales_by_category.csv
│   ├── sales_by_state.csv
│   ├── rfm_scores.csv
│   ├── rfm_segments.csv
│   └── 环比增长_最近_6_个月.csv
│
├── 差评根因/                         # 差评分析结果（CSV）
│   ├── 差评率.csv
│   ├── 履约时长分桶.csv
│   ├── _延迟天数分桶.csv
│   ├── 州.csv
│   ├── category.csv
│   └── seller_rate.csv
│
├── Tableau结果/                      # 可视化截图
│   ├── 月度GMV.png
│   ├── 月度买家与订单趋势.png
│   ├── GMV分析.png
│   ├── RFM分层.png
│   ├── 留存占比.png
│   ├── 用户占比.png
│   ├── 时活跃用户数.png
│   └── badreview.png
│
├── olist_analysis_conclusion.md    # 完整分析结论报告（Markdown）
├── Olist电商数据分析报告.pdf          # PDF 版分析报告
└── Olist电商数据分析报告_格式统一.docx # Word 版分析报告
```

---

## 数据模型架构

本项目采用分层数据架构，原始数据经过清洗与建模后逐层聚合：

```
原始 CSV（Kaggle 下载）
       │
       ▼
  Staging 层（stg_*）            ← 01_create_tables.sql
  9 张原始表，结构 1:1 对应 CSV
       │
       ▼
  事实层（fact_orders）           ← 02_fact_orders.sql
  仅保留 delivered 订单，
  聚合 GMV、delivery_days、
  ontime_flag、bad_review_flag
       │
       ▼
  数据集市层（dm_*）              ← 03_build_dm..sql
  ├── dm_kpi_daily        （日粒度 KPI）
  ├── dm_state_daily      （地区 × 日）
  ├── dm_category_daily   （品类 × 日）
  └── dm_customer_rfm     （客户 RFM 属性）
       │
       ▼
  分析查询层（SQL 脚本 04–08）
  留存 / 漏斗 / 销售 / RFM / 差评
       │
       ▼
  可视化（Tableau）
```

### 原始数据表说明

| 表名 | 行数 | 说明 |
|---|---:|---|
| stg_orders | 99,441 | 订单主表（状态、时间戳） |
| stg_order_items | 112,650 | 订单商品明细（价格、运费） |
| stg_order_payments | 103,886 | 支付明细（方式、金额） |
| stg_customers | 99,441 | 客户信息（城市、州） |
| stg_reviews | 99,224 | 订单评价（评分 1–5） |
| stg_products | 32,951 | 商品信息（品类、尺寸重量） |
| stg_sellers | — | 卖家信息（城市、州） |
| stg_product_category_translation | — | 品类葡–英对照表 |
| stg_geolocation | — | 邮编地理坐标表 |

---

## 环境准备

### 所需工具

| 工具 | 版本建议 | 用途 |
|---|---|---|
| MySQL | 8.0+ | 数据存储与 SQL 分析 |
| MySQL Workbench / DBeaver | 任意 | SQL 客户端 |
| Python | 3.8+ | 数据质量检查 |
| Jupyter Notebook | 任意 | 运行 `.ipynb` 文件 |
| Tableau Public / Desktop | 任意 | 可视化（可选） |

### Python 依赖安装

```bash
pip install pandas openpyxl jupyter
```

### 获取原始数据集

1. 前往 Kaggle 下载数据：  
   [https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
2. 解压后得到以下 9 个 CSV 文件：
   - `olist_customers_dataset.csv`
   - `olist_sellers_dataset.csv`
   - `olist_orders_dataset.csv`
   - `olist_order_items_dataset.csv`
   - `olist_order_payments_dataset.csv`
   - `olist_order_reviews_dataset.csv`
   - `olist_products_dataset.csv`
   - `product_category_name_translation.csv`
   - `olist_geolocation_dataset.csv`

---

## 手把手操作教程

### Step 1 — 修改 CSV 文件路径

打开 `create_tables.sql/01_create_tables.sql`，找到第三部分"导入本地 CSV 数据"，将所有 `LOAD DATA LOCAL INFILE` 后的路径替换为你本机的实际存放路径：

```sql
-- 将下方路径替换为你本机解压后 CSV 文件所在目录
LOAD DATA LOCAL INFILE 'C:/Users/你的用户名/Downloads/archive/olist_customers_dataset.csv'
INTO TABLE stg_customers
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
```

> **提示**：路径统一使用正斜杠 `/`，避免转义问题。共需修改 9 处路径。

---

### Step 2 — 建库、建表、导入数据

在 MySQL 客户端中执行第一个脚本：

```sql
source /你的路径/create_tables.sql/01_create_tables.sql;
```

执行后验证导入行数：

```sql
SELECT 'stg_orders' AS table_name, COUNT(*) AS row_count FROM stg_orders
UNION ALL SELECT 'stg_order_items', COUNT(*) FROM stg_order_items
UNION ALL SELECT 'stg_order_payments', COUNT(*) FROM stg_order_payments
UNION ALL SELECT 'stg_customers', COUNT(*) FROM stg_customers
UNION ALL SELECT 'stg_reviews', COUNT(*) FROM stg_reviews
UNION ALL SELECT 'stg_products', COUNT(*) FROM stg_products
UNION ALL SELECT 'stg_sellers', COUNT(*) FROM stg_sellers;
```

**期望结果：**

| table_name | row_count |
|---|---:|
| stg_orders | 99,441 |
| stg_order_items | 112,650 |
| stg_order_payments | 103,886 |
| stg_customers | 99,441 |
| stg_reviews | 99,224 |
| stg_products | 32,951 |

---

### Step 3 — 构建事实层宽表

```sql
source /你的路径/create_tables.sql/02_fact_orders.sql;
```

该脚本将 Staging 表 JOIN 为 `fact_orders` 宽表，自动计算以下字段：

| 字段 | 含义 |
|---|---|
| `delivery_days` | 实际配送天数（下单 → 收货） |
| `delay_days` | 超出预计送达日期的天数（提前则为 0） |
| `ontime_flag` | 是否准时（1 = 准时，0 = 延迟，NULL = 无数据） |
| `bad_review_flag` | 是否差评（评分 ≤ 2 记为 1，否则为 0） |

验证：

```sql
SELECT COUNT(*) FROM fact_orders;
-- 期望：96,478（仅保留 delivered 状态订单）
```

---

### Step 4 — 构建 DM 层聚合表

```sql
source /你的路径/create_tables.sql/03_build_dm..sql;
```

生成 4 张聚合表，供后续分析使用：

| 表名 | 粒度 | 主要字段 |
|---|---|---|
| `dm_kpi_daily` | 日 | orders, buyers, GMV, AOV, 准时率, 差评率 |
| `dm_state_daily` | 日 × 州 | 同上，按州拆分 |
| `dm_category_daily` | 日 × 品类 | 同上，按品类拆分 |
| `dm_customer_rfm` | 客户 | recency_days, frequency, monetary |

> **注**：`dm_category_daily` 涉及多表 JOIN，构建耗时约 1–3 分钟，属正常现象。

---

### Step 5 — 运行 Python 数据质量检查

```bash
cd 数据质量/
jupyter notebook 01_data_quality_checks.ipynb
# 或直接运行脚本版本
python run_data_quality_checks.py
```

检查内容：
- 各表缺失值统计与分布
- 主外键一致性（孤儿记录数）
- GMV 口径对比（item_gmv vs paid_gmv）

报告自动输出到 `数据质量/reports/` 目录。

**关键数据质量结论：**

| 指标 | 结果 |
|---|---|
| 总订单数 | 99,441 |
| 已送达订单 | 96,478（97.02%） |
| item_gmv vs paid_gmv 误差 | -0.0184%（可忽略） |
| 孤儿记录数 | 0（主外键完全一致） |

---

### Step 6 — Cohort 留存分析

```sql
source /你的路径/create_tables.sql/04_cohort_retention.sql;
```

输出三组结果：
1. **留存矩阵**：cohort_month × purchase_month 的留存人数与留存率
2. **汇总留存曲线**：M+0 到 M+12 的全平台平均留存率
3. **复购摘要**：总用户数 / 复购用户数 / 复购率

将结果导出 CSV 后，用 Excel 数据透视表或 Tableau 可绘制 Cohort 热力图。

**关键指标：**

| 距首购月数 | 留存人数 | 留存率 |
|---|---:|---|
| M+0 | 93,358 | 100% |
| M+1 | 421 | 0.45% |
| M+3 | 192 | 0.21% |
| M+6 | 129 | 0.14% |
| M+12 | 36 | 0.04% |

---

### Step 7 — 转化漏斗分析

```sql
source /你的路径/create_tables.sql/05_funnel_analysis.sql;
```

输出三组结果：
1. **整体漏斗**：5 个阶段（下单 → 支付 → 发货 → 送达 → 评价）的转化率与流失率
2. **月度漏斗趋势**：配送率 & 评价率随时间的变化
3. **品类漏斗对比**：Top 10 品类的配送率与评价率

**整体漏斗结果：**

| 阶段 | 订单数 | 转化率 | 流失率 |
|---|---:|---|---|
| 1. 下单 | 99,441 | 100% | — |
| 2. 支付完成 | 98,207 | 98.76% | 1.24% |
| 3. 已发货 | 97,585 | 98.13% | 0.63% |
| 4. 已送达 | 96,478 | 97.02% | 1.13% |
| 5. 已评价 | 95,831 | 96.37% | 0.67% |

---

### Step 8 — 销售趋势分析

```sql
source /你的路径/create_tables.sql/06_sales_trends.sql;
```

输出四组结果：
1. **月度经营趋势**：GMV、订单量、客单价、准时率、差评率
2. **Top 10 品类**（近 12 个月 GMV 排名）
3. **Top 10 州**（近 12 个月 GMV 排名）
4. **近 6 个月环比增长**

---

### Step 9 — RFM 用户分层

```sql
source /你的路径/create_tables.sql/07_rfm_segmentation.sql;
```

使用 `NTILE(5)` 对 R / F / M 三个维度各打 1–5 分，按以下规则分层：

| 分层 | 判断条件 | 用户数 | 占比 |
|---|---|---:|---|
| Champions | R≥4 且 F≥4 且 M≥4 | 984 | 1.1% |
| Loyal | R≥4 且 F≥3 且 M≥3 | 627 | 0.7% |
| New Customers | R≥4 且 F≤2 | 35,342 | 37.9% |
| Potential Loyalist | R=3 且 F≥3 | 16,670 | 17.9% |
| At Risk | R≤2 且 F≥4 | 19,720 | 21.1% |
| Hibernating | R≤2 且 M≤2 | 7,561 | 8.1% |
| Others | 其余 | 12,454 | 13.3% |

---

### Step 10 — 差评根因分析

```sql
source /你的路径/create_tables.sql/08_review_rootcause.sql;
```

从六个维度定位差评来源：

| 分析维度 | 核心发现 |
|---|---|
| 总览 | 整体差评率 12.76%（12,225 / 96,478） |
| 履约时长 | 配送 22+ 天时差评率骤升至 40.6% |
| 延迟天数 | 延迟 1–3 天差评率即达 31.8%；6.8% 的延迟订单贡献 32.5% 的差评 |
| 地区 | RJ 州差评率 18.1%（比 SP 高 7.5pp），是最优先修复目标 |
| 品类 | office_furniture 差评率 21.4%，是平台均值 1.7 倍 |
| 卖家 | Top 差评卖家准时率普遍低于平台均值，差评与准时率强相关 |

---

### Step 11 — Tableau 可视化（可选）

将各步骤导出的 CSV 导入 Tableau Public，复现 `Tableau结果/` 目录下的可视化图表：

| 图表文件 | 对应分析模块 |
|---|---|
| `月度GMV.png` | 月度 GMV 趋势折线图 |
| `月度买家与订单趋势.png` | 订单量 & 买家数双轴趋势 |
| `GMV分析.png` | 品类 / 地区 GMV 结构图 |
| `RFM分层.png` | 用户 RFM 分层气泡图 |
| `留存占比.png` | Cohort 留存热力图 |
| `用户占比.png` | 各分层用户占比饼图 |
| `时活跃用户数.png` | 小时粒度活跃用户分布 |
| `badreview.png` | 差评率多维分析图 |

---

## 核心结论速览

### 留存与漏斗

- 整体漏斗转化率 **96.37%**，物流履约能力强且随时间持续提升
- 复购率仅 **1.81%**，平台呈强烈一次性消费特征，用户粘性极弱
- 最大流失点：下单 → 支付（1.24%），canceled 与 unavailable 各占约 50%

### 销售与 RFM

- 2018 年月均 GMV **R$ 1,056,000**，同比 2017 年增长 **+83%**
- **health_beauty** GMV 最高；**watches_gifts** 客单价最高（R$ 222）
- SP 州独占全平台 **43.3%** GMV；SP+RJ+MG 三州合计 **71.8%**
- 93% 用户仅购买过一次；Champions + Loyal 合计不足 **2%**

### 差评根因

- 整体差评率 **12.76%**；6.8% 的延迟订单贡献了 **32.5%** 的差评
- 配送超 **22 天**时差评率骤升至 40.6%（是 21 天内的 3.3 倍）
- RJ 州是最优先修复的地区；消除延迟可将全平台差评率降至约 **8.6%**

---

## 常见问题

**Q：`LOAD DATA LOCAL INFILE` 报错 `The used command is not allowed`？**  
A：需同时开启服务端与客户端的本地导入权限。脚本中已包含 `SET GLOBAL local_infile = 1;`（服务端），还需在 MySQL 连接参数中添加 `--local-infile=1`（客户端），或在 DBeaver / Workbench 的连接配置中勾选"Allow local infile"选项。

**Q：导入后行数对不上？**  
A：检查 CSV 文件的换行符类型。Windows 生成的 CSV 可能为 `\r\n`，将 `LINES TERMINATED BY '\n'` 改为 `LINES TERMINATED BY '\r\n'` 即可。

**Q：`fact_orders` 里只有 96,478 行，比 stg_orders 少了约 3000 行？**  
A：正常。`fact_orders` 只保留 `order_status = 'delivered'` 的订单，canceled、shipped 等其他状态被过滤掉了，这是分析设计的预期行为。

**Q：`dm_category_daily` 构建很慢？**  
A：该表涉及多表 JOIN 且数据量较大，正常耗时约 1–3 分钟，属正常现象，等待即可。

---

## 数据来源

- 原始数据集：[Olist Brazilian E-Commerce Public Dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)（Kaggle，CC BY-NC-SA 4.0）
- 数据时间范围：2016-09 ~ 2018-08
- 订单总量：99,441 笔 | 客户总数：99,441 人 | 商品总数：32,951 件

---

*如有问题欢迎提 Issue 或 PR。*
