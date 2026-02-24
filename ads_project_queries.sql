SET GLOBAL local_infile = 1;
CREATE DATABASE ads_portfolio;
USE ads_portfolio;
CREATE TABLE ads_row (
	date VARCHAR(50),
    platform VARCHAR(100),
    campaign_type VARCHAR(100),
    industrty VARCHAR(100),
    country VARCHAR(100),
    impressions VARCHAR(50),
    clicks VARCHAR(50),
    CTR VARCHAR(50),
    CPC VARCHAR(50),
    ad_spend VARCHAR(50),
    conversions VARCHAR(50),
    CPA VARCHAR(50),
    revenue VARCHAR(50),
    ROAS VARCHAR(50)
);
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/global_ads_performance_dataset.csv'
INTO TABLE ads_row
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;
CREATE TABLE global_ads AS
SELECT
	STR_TO_DATE(date, '%Y-%m-%d') AS date,
    platform,
    campaign_type,
    industrty AS industry,
    country,
    CAST(impressions AS UNSIGNED) AS impressions,
    CAST(clicks AS UNSIGNED) AS clicks,
    CAST(CTR AS DECIMAL(8,4)) AS CTR,
    CAST(CPC AS DECIMAL(10,4)) AS CPC,
    CAST(ad_spend AS DECIMAL(12,2)) AS ad_spend,
    CAST(conversions AS UNSIGNED) AS conversions,
    CAST(CPA AS DECIMAL(10,4)) AS CPA,
    CAST(revenue AS DECIMAL(12,2)) AS revenue,
    CAST(ROAS AS DECIMAL(10,4)) AS ROAS
FROM ads_row;
DESCRIBE global_ads;
SHOW COLUMNS FROM global_ads;
ALTER TABLE global_ads 
ADD id INT NOT NULL AUTO_INCREMENT PRIMARY KEY;
CREATE VIEW campaign_performance AS 
SELECT  
    campaign_type,
    SUM(impressions) AS total_impressions,
    SUM(clicks) AS total_clicks,
    SUM(conversions) AS total_conversions,
    SUM(ad_spend) AS total_spend,
    SUM(revenue) AS total_revenue,
    (SUM(clicks)/SUM(impressions)) * 100 AS ctr_percentage,
    (SUM(conversions)/SUM(clicks)) * 100 AS conversion_rate,
    (SUM(revenue) - SUM(ad_spend)) AS profit
FROM global_ads
GROUP BY campaign_type;
CREATE VIEW platform_performance AS
SELECT 
    platform,
    SUM(impressions) AS impressions,
    SUM(clicks) AS clicks,
    SUM(conversions) AS conversions,
    SUM(ad_spend) AS spend,
    SUM(revenue) AS revenue,
    (SUM(revenue) - SUM(ad_spend)) AS profit
FROM global_ads
GROUP BY platform;
CREATE VIEW country_performance AS
SELECT 
    country,
    SUM(ad_spend) AS spend,
    SUM(revenue) AS revenue,
    SUM(revenue) - SUM(ad_spend) AS profit
FROM global_ads
GROUP BY country;
CREATE VIEW monthly_performance AS 
SELECT  
    YEAR(date) AS year,
    MONTH(date) AS month,
    SUM(ad_spend) AS total_spend,
    SUM(revenue) AS total_revenue,
    SUM(clicks) AS total_clicks,
    SUM(conversions) AS total_conversions
FROM global_ads
GROUP BY YEAR(date), MONTH(date);
SELECT * 
FROM global_ads 
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/ads_export_2.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';
