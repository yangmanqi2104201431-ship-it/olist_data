-- =============================================================================
-- 项目名称: Olist 电商数据集 MySQL 初始化与数据导入脚本
-- 脚本功能: 创建数据库、构建 Staging 层基础表、导入本地 CSV 数据并验证
-- =============================================================================

-- 1. 创建并切换数据库
CREATE DATABASE IF NOT EXISTS db_olist DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE db_olist;

-- =============================================================================
-- 第二部分：创建基础数据表 (Staging Tables)
-- =============================================================================

-- 1. 客户表 (Customers)
CREATE TABLE IF NOT EXISTS stg_customers (
    customer_id VARCHAR(50) COMMENT '客户ID',
    customer_unique_id VARCHAR(50) COMMENT '客户唯一ID',
    customer_zip_code_prefix INT COMMENT '邮政编码前缀',
    customer_city VARCHAR(255) COMMENT '城市',
    customer_state VARCHAR(10) COMMENT '州/省'
) COMMENT='客户维度表';

-- 2. 卖家表 (Sellers)
CREATE TABLE IF NOT EXISTS stg_sellers (
    seller_id VARCHAR(50) COMMENT '卖家ID',
    seller_zip_code_prefix INT COMMENT '卖家邮政编码前缀',
    seller_city VARCHAR(255) COMMENT '卖家城市',
    seller_state VARCHAR(10) COMMENT '卖家州/省'
) COMMENT='卖家维度表';

-- 3. 订单表 (Orders)
CREATE TABLE IF NOT EXISTS stg_orders (
    order_id VARCHAR(50) COMMENT '订单ID',
    customer_id VARCHAR(50) COMMENT '客户ID',
    order_status VARCHAR(50) COMMENT '订单状态',
    order_purchase_timestamp DATETIME COMMENT '下单时间',
    order_approved_at DATETIME COMMENT '支付批准时间',
    order_delivered_carrier_date DATETIME COMMENT '物流接件时间',
    order_delivered_customer_date DATETIME COMMENT '客户收货时间',
    order_estimated_delivery_date DATETIME COMMENT '预计送达时间'
) COMMENT='订单主表';

-- 4. 订单明细表 (Order Items)
CREATE TABLE IF NOT EXISTS stg_order_items (
    order_id VARCHAR(50) COMMENT '订单ID',
    order_item_id INT COMMENT '订单项序列号',
    product_id VARCHAR(50) COMMENT '商品ID',
    seller_id VARCHAR(50) COMMENT '卖家ID',
    shipping_limit_date DATETIME COMMENT '卖家发货截止日期',
    price DECIMAL(10,2) COMMENT '商品价格',
    freight_value DECIMAL(10,2) COMMENT '运费'
) COMMENT='订单商品明细表';

-- 5. 订单支付表 (Order Payments)
CREATE TABLE IF NOT EXISTS stg_order_payments (
    order_id VARCHAR(50) COMMENT '订单ID',
    payment_sequential INT COMMENT '支付顺序(多笔支付时的序号)',
    payment_type VARCHAR(50) COMMENT '支付方式',
    payment_installments INT COMMENT '分期付款期数',
    payment_value DECIMAL(10,2) COMMENT '支付金额'
) COMMENT='订单支付明细表';

-- 6. 订单评价表 (Order Reviews)
CREATE TABLE IF NOT EXISTS stg_reviews (
    review_id VARCHAR(50) COMMENT '评价ID',
    order_id VARCHAR(50) COMMENT '订单ID',
    review_score INT COMMENT '评价分数(1-5)',
    review_comment_title VARCHAR(255) COMMENT '评价标题',
    review_comment_message TEXT COMMENT '评价内容',
    review_creation_date DATETIME COMMENT '评价创建时间',
    review_answer_timestamp DATETIME COMMENT '评价回复时间'
) COMMENT='订单评价表';

-- 7. 商品表 (Products)
CREATE TABLE IF NOT EXISTS stg_products (
    product_id VARCHAR(50) COMMENT '商品ID',
    product_category_name VARCHAR(255) COMMENT '商品类目名称(葡萄牙语)',
    product_name_lenght INT COMMENT '商品名称长度',
    product_description_lenght INT COMMENT '商品描述长度',
    product_photos_qty INT COMMENT '商品照片数量',
    product_weight_g INT COMMENT '商品重量(克)',
    product_length_cm INT COMMENT '商品长度(厘米)',
    product_height_cm INT COMMENT '商品高度(厘米)',
    product_width_cm INT COMMENT '商品宽度(厘米)'
) COMMENT='商品维度表';

-- 8. 商品类目翻译表 (Product Category Name Translation)
CREATE TABLE IF NOT EXISTS stg_product_category_translation (
    product_category_name VARCHAR(255) COMMENT '商品类目名称(葡萄牙语)',
    product_category_name_english VARCHAR(255) COMMENT '商品类目名称(英语)'
) COMMENT='商品类目语言翻译表';

-- 9. 地理位置表 (Geolocation)
CREATE TABLE IF NOT EXISTS stg_geolocation (
    geolocation_zip_code_prefix INT COMMENT '邮政编码前缀',
    geolocation_lat DECIMAL(10,8) COMMENT '纬度',
    geolocation_lng DECIMAL(11,8) COMMENT '经度',
    geolocation_city VARCHAR(255) COMMENT '城市',
    geolocation_state VARCHAR(10) COMMENT '州/省'
) COMMENT='地理位置参考表';


-- =============================================================================
-- 第三部分：开启权限并导入本地 CSV 数据
-- =============================================================================

-- 开启服务端本地导入文件的权限
SET GLOBAL local_infile = 1;

-- 注意：GitHub 使用者需要根据自身实际存放路径修改下方的 'C:/Users/.../archive/' 路径

-- 1. 导入客户表
LOAD DATA LOCAL INFILE 'C:/Users/21042/Downloads/archive/olist_customers_dataset.csv'
INTO TABLE stg_customers
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;

-- 2. 导入卖家表
LOAD DATA LOCAL INFILE 'C:/Users/21042/Downloads/archive/olist_sellers_dataset.csv'
INTO TABLE stg_sellers
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;

-- 3. 导入订单主表
LOAD DATA LOCAL INFILE 'C:/Users/21042/Downloads/archive/olist_orders_dataset.csv'
INTO TABLE stg_orders
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;

-- 4. 导入订单明细表
LOAD DATA LOCAL INFILE 'C:/Users/21042/Downloads/archive/olist_order_items_dataset.csv'
INTO TABLE stg_order_items
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;

-- 5. 导入订单支付表
LOAD DATA LOCAL INFILE 'C:/Users/21042/Downloads/archive/olist_order_payments_dataset.csv'
INTO TABLE stg_order_payments
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;

-- 6. 导入订单评价表
LOAD DATA LOCAL INFILE 'C:/Users/21042/Downloads/archive/olist_order_reviews_dataset.csv'
INTO TABLE stg_reviews
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;

-- 7. 导入商品表
LOAD DATA LOCAL INFILE 'C:/Users/21042/Downloads/archive/olist_products_dataset.csv'
INTO TABLE stg_products
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;

-- 8. 导入商品类目翻译表
LOAD DATA LOCAL INFILE 'C:/Users/21042/Downloads/archive/product_category_name_translation.csv'
INTO TABLE stg_product_category_translation
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;

-- 9. 导入地理位置表
LOAD DATA LOCAL INFILE 'C:/Users/21042/Downloads/archive/olist_geolocation_dataset.csv'
INTO TABLE stg_geolocation
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;


-- =============================================================================
-- 第四部分：数据量验证
-- =============================================================================

SELECT 'stg_orders' AS table_name, COUNT(*) AS row_count FROM stg_orders
UNION ALL SELECT 'stg_order_items', COUNT(*) FROM stg_order_items
UNION ALL SELECT 'stg_order_payments', COUNT(*) FROM stg_order_payments
UNION ALL SELECT 'stg_customers', COUNT(*) FROM stg_customers
UNION ALL SELECT 'stg_reviews', COUNT(*) FROM stg_reviews
UNION ALL SELECT 'stg_products', COUNT(*) FROM stg_products
UNION ALL SELECT 'stg_sellers', COUNT(*) FROM stg_sellers
UNION ALL SELECT 'stg_product_category_translation', COUNT(*) FROM stg_product_category_translation
UNION ALL SELECT 'stg_geolocation', COUNT(*) FROM stg_geolocation;
