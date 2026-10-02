create database operations_data;
use operations_data;
drop table operations_orders;
CREATE TABLE operations_orders (
    Order_ID VARCHAR(20),
    Order_Date DATE,
    Customer_ID VARCHAR(20),
    Region VARCHAR(20),
    Department VARCHAR(30),
    Team VARCHAR(20),
    Priority VARCHAR(20),
    Order_Status VARCHAR(20),
    Processing_Hours DECIMAL(10,2),
    Shipping_Days INT,
    Order_Value DECIMAL(10,2),
    Order_Error VARCHAR(10),
    SLA_Hours INT,
    Employee_ID VARCHAR(20)
);

SHOW VARIABLES LIKE 'local_infile';

LOAD DATA LOCAL INFILE 'C:/Users/Hiral/OneDrive/Documents/Operational-Workflow-Analytics/Data/operations_cleaned.csv'
INTO TABLE operations_orders
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    Order_ID,
    Order_Date,
    Customer_ID,
    Region,
    Department,
    Team,
    Priority,
    Order_Status,
    @Processing_Hours,
    @Shipping_Days,
    @Order_Value,
    Order_Error,
    SLA_Hours,
    Employee_ID
)
SET
    Processing_Hours = NULLIF(@Processing_Hours, ''),
    Shipping_Days = NULLIF(@Shipping_Days, ''),
    Order_Value = NULLIF(@Order_Value, '');

select * from operations_orders;

SELECT COUNT(*) AS total_rows
FROM operations_orders;

SELECT COUNT(*) AS missing_processing
FROM operations_orders
WHERE Processing_Hours IS NULL;

SELECT COUNT(*) AS zero_processing
FROM operations_orders
WHERE Processing_Hours = 0;

SELECT COUNT(*) AS missing_order_value
FROM operations_orders
WHERE Order_Value IS NULL;

SELECT
    MIN(Processing_Hours) AS min_processing,
    MAX(Processing_Hours) AS max_processing
FROM operations_orders;

select count(distinct Order_ID)	as unique_orders from operations_orders;

select count(*) as negative_processing_hrs from operations_orders where Processing_Hours <0;

select Region, count(*) as order_count from operations_orders group by Region order by Region;

select count(*) as order_count, 
	avg(Processing_Hours) as avg_processing_hrs, 
    avg(Shipping_Days) as avg_shipping_days, 
    avg(Order_Value) as avg_order_value
from operations_orders;

select Order_Status,
	count(*) as order_count
    from operations_orders
    group by Order_Status
    order by order_count desc;
    
select 
	count(*) as order_count,
    round( 100.0*
    sum( 
		case 
		when Processing_Hours <=SLA_Hours then 1
        else 0
        end
        )/ count(*), 2
        )as sla_met_orders,
		round( 100.0*
    sum( 
		case 
		when Processing_Hours >SLA_Hours then 1
        else 0
        end
        )/ count(*), 2
        )as sla_breached_orders
      from operations_orders;
      
select
    COUNT(*) AS total_orders,
    COUNT(Processing_Hours) AS orders_with_processing_time
FROM operations_orders;

SELECT
	Region, COUNT(*) AS orders_count,
	SUM(CASE WHEN Processing_Hours < SLA_Hours THEN 1 ELSE 0 END)AS SLA_met,
    SUM(CASE WHEN Processing_Hours >= SLA_Hours THEN 1 ELSE 0 END)AS SLA_breached,
    ROUND(100.00 * SUM(CASE WHEN Processing_Hours >= SLA_Hours THEN 1 ELSE 0 END)/COUNT(Processing_Hours),2)AS breach_rate_pct
	FROM operations_orders 
    GROUP BY Region
    ORDER BY breach_rate_pct;
    
    SELECT
	Region, Department, COUNT(*) AS orders_count,
	SUM(CASE WHEN Processing_Hours < SLA_Hours THEN 1 ELSE 0 END)AS SLA_met,
    SUM(CASE WHEN Processing_Hours >= SLA_Hours THEN 1 ELSE 0 END)AS SLA_breached,
    ROUND(100.00 * SUM(CASE WHEN Processing_Hours >= SLA_Hours THEN 1 ELSE 0 END)/COUNT(Processing_Hours),2)AS breach_rate_pct
	FROM operations_orders 
    WHERE Region is not null
    GROUP BY Region, Department
    ORDER BY breach_rate_pct desc;
    
    SELECT
	Region, Department, Team,COUNT(*) AS orders_count,
	SUM(CASE WHEN Processing_Hours < SLA_Hours THEN 1 ELSE 0 END)AS SLA_met,
    SUM(CASE WHEN Processing_Hours >= SLA_Hours THEN 1 ELSE 0 END)AS SLA_breached,
    ROUND(100.00 * SUM(CASE WHEN Processing_Hours >= SLA_Hours THEN 1 ELSE 0 END)/COUNT(Processing_Hours),2)AS breach_rate_pct,
    ROUND(AVG(Processing_Hours),2)AS Avg_processing_hrs
	FROM operations_orders 
    WHERE Region is not null AND Department IS NOT NULL
    GROUP BY Region, Department, Team
    ORDER BY breach_rate_pct desc;
    
    SELECT
	Region, Department, Priority,COUNT(*) AS orders_count,
	SUM(CASE WHEN Processing_Hours < SLA_Hours THEN 1 ELSE 0 END)AS SLA_met,
    SUM(CASE WHEN Processing_Hours >= SLA_Hours THEN 1 ELSE 0 END)AS SLA_breached,
    ROUND(100.00 * SUM(CASE WHEN Processing_Hours >= SLA_Hours THEN 1 ELSE 0 END)/COUNT(Processing_Hours),2)AS breach_rate_pct,
    ROUND(AVG(Processing_Hours),2)AS Avg_processing_hrs,
    AVG(SLA_Hours) AS avg_sla_hours
	FROM operations_orders 
    WHERE Region = 'West'
    AND Department = 'Warehouse'
    GROUP BY Region, Department, Priority
    ORDER BY breach_rate_pct desc;
    
    SELECT
	Region, Department, Priority,COUNT(*) AS orders_count,
	SUM(CASE WHEN Processing_Hours < SLA_Hours THEN 1 ELSE 0 END)AS SLA_met,
    SUM(CASE WHEN Processing_Hours >= SLA_Hours THEN 1 ELSE 0 END)AS SLA_breached,
    ROUND(100.00 * SUM(CASE WHEN Processing_Hours >= SLA_Hours THEN 1 ELSE 0 END)/COUNT(Processing_Hours),2)AS breach_rate_pct,
    ROUND(AVG(Processing_Hours),2)AS Avg_processing_hrs,
    AVG(SLA_Hours) AS avg_sla_hours
	FROM operations_orders 
    WHERE Department = 'Warehouse'
    AND Priority = 'High'
    GROUP BY Region, Department, Priority
    ORDER BY breach_rate_pct desc;
    
    #team performance within High-priority West Warehouse
	SELECT
	Team,COUNT(*) AS orders_count,
	SUM(CASE WHEN Processing_Hours < SLA_Hours THEN 1 ELSE 0 END)AS SLA_met,
    SUM(CASE WHEN Processing_Hours >= SLA_Hours THEN 1 ELSE 0 END)AS SLA_breached,
    ROUND(100.00 * SUM(CASE WHEN Processing_Hours >= SLA_Hours THEN 1 ELSE 0 END)/COUNT(Processing_Hours),2)AS breach_rate_pct,
    ROUND(AVG(Processing_Hours),2)AS Avg_processing_hrs,
	ROUND(MIN(Processing_Hours),2)AS min_processing_hrs,
    ROUND(MAX(Processing_Hours),2) AS max_processing_hrs
	FROM operations_orders 
    WHERE Region= 'West'
    AND Department = 'Warehouse'
    AND Priority = 'High' 
    GROUP BY Team
    ORDER BY breach_rate_pct desc;
    
    SELECT
	Team,COUNT(*) AS orders_count,
     ROUND(AVG(Processing_Hours),2)AS Avg_processing_hrs,
	ROUND(100.00*SUM(CASE WHEN Processing_Hours <=12 THEN 1 ELSE 0 END)/ COUNT(Processing_Hours),2)AS  pct_12_hours_or_less,
    ROUND(100.00*SUM(CASE WHEN Processing_Hours >16 THEN 1 ELSE 0 END)/ COUNT(Processing_Hours),2)AS pct_over_sla,
    ROUND(100.00 * SUM(CASE WHEN Processing_Hours >20 THEN 1 ELSE 0 END)/COUNT(Processing_Hours),2)AS  pct_over_20_hours
	FROM operations_orders 
    WHERE Region= 'West'
    AND Department = 'Warehouse'
    AND Priority = 'High' 
    GROUP BY Team
    ORDER BY Avg_processing_hrs desc;
    
    SELECT
	Team,COUNT(*) AS orders_count,
    ROUND(AVG(Order_Value),2)AS avg_order_value,
    ROUND(MIN(Order_Value),2)AS min_order_value,
    ROUND(MAX(Order_Value),2)AS max_order_value,
	ROUND(AVG(Processing_Hours),2)AS Avg_processing_hrs
	FROM operations_orders 
    WHERE Region= 'West'
    AND Department = 'Warehouse'
    AND Priority = 'High' 
    GROUP BY Team
    ORDER BY avg_order_value DESC;
    
    SELECT
	Employee_ID,COUNT(*) AS orders_count,
	SUM(CASE WHEN Processing_Hours < SLA_Hours THEN 1 ELSE 0 END)AS SLA_met,
    SUM(CASE WHEN Processing_Hours > SLA_Hours THEN 1 ELSE 0 END)AS SLA_breached,
    ROUND(100.00 * SUM(CASE WHEN Processing_Hours > SLA_Hours THEN 1 ELSE 0 END)/COUNT(Processing_Hours),2)AS breach_rate_pct,
    ROUND(AVG(Processing_Hours),2)AS Avg_processing_hrs
	FROM operations_orders 
    WHERE Region= 'West'
    AND Department = 'Warehouse'
    AND Priority = 'High' 
    AND Team = 'Team B'
    GROUP BY Employee_ID
    ORDER BY orders_count desc;