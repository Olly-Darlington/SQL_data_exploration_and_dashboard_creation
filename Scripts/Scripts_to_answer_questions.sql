# All code authored by Oliver Darlington
# Examine data imported
DESCRIBE orders;
DESCRIBE refunds;
DESCRIBE shipments;

# Q1-2 are on the shipments table only, look at the table
SELECT * FROM shipments
LIMIT 20;

# The shipments table has imported with skipping rows, noticibly order_id 5 from this table. opening the .csv files in excel and it becomes apparent there are blank datpoints.
# replaced blank date rows with NULL as date is a text variable in this example, and replaced shipping days with 0.
# the data then loaded with no issues.

SELECT * FROM shipments
LIMIT 20;
# Checked and good.

# Q1 Solve
# Counting the number of shipment_id will return the number of parcles handles irrespective of other factors.
SELECT courier, COUNT(shipment_id) as parcels_handled
FROM shipments
GROUP BY courier
ORDER BY parcels_handled DESC;

# Q2 solve
# Averages the shipping days int for rows where shipping status = delivered, returns only one row
SELECT status, AVG(shipping_days) as avg_shipping_days
FROM shipments
WHERE status = 'Delivered'
GROUP BY status;

# Q3 requires a join on the orders table, view it
SELECT * FROM orders
LIMIT 20;

# Q3 solve
# Adapt previous query to include a join on the orders table on order_id, grouping by region will then return average for the entire region
SELECT o.region, AVG(s.shipping_days) as avg_shipping_days
FROM orders AS o
JOIN shipments AS s
	ON o.order_id = s.order_id
WHERE status = 'Delivered'
GROUP BY o.region
ORDER BY avg_shipping_days DESC;

# Q4 solve
# Requires just the orders table, looking for the total value so uses a sum function and sorts desc to show highest first
SELECT category, SUM(order_value) as total_order_value
FROM orders
GROUP BY category
ORDER BY total_order_value DESC;

# Q5 introduces the redunds table, view it
SELECT * FROM refunds
LIMIT 20;

# Q5 Solve
# Group again using order_id, refund rate is defined as refunded/ordered, so again a simple sum function will suffice, requires a left join to include all instances where an order is not refunded
SELECT o.category, (COUNT(r.refund_id) / COUNT(o.order_id)) AS refund_rate
FROM orders AS o
LEFT JOIN refunds AS r ON o.order_id=r.order_id
GROUP BY o.category
ORDER BY refund_rate DESC;

# Q6 wants a stastical test so requires moving outside of SQL, need totals for refunds and orders in both the highest and lowest categories to take to a python script
SELECT o.category, count(o.order_id) AS order_count, count(r.refund_id) AS refund_count
FROM orders AS o
LEFT JOIN refunds AS r ON o.order_id=r.order_id
WHERE category = 'Clothing'
OR category = 'Home'
GROUP BY o.category;

# See q6_z_test.py for Q6 solve

# Q7 Solve
# Calculating two percentages, need percentage returned and percentage refunded. Use the shipments and refunds tables, % can be calcated as a function in the SELECT statement
SELECT
    s.courier,
    COUNT(DISTINCT CASE
        WHEN r.order_id IS NOT NULL
        THEN s.order_id
    END) AS returned_and_refunded_count,
    COUNT(DISTINCT s.order_id) AS total_returned,
    ROUND(
        100.0 * COUNT(DISTINCT CASE
            WHEN r.order_id IS NOT NULL
            THEN s.order_id
        END)
        / NULLIF(COUNT(DISTINCT s.order_id), 0),
        2
    ) AS returned_and_refunded_percentage
FROM shipments AS s
LEFT JOIN refunds AS r
    ON s.order_id = r.order_id
WHERE s.status = 'Returned'
GROUP BY s.courier
ORDER BY returned_and_refunded_percentage ASC;


# Q8 requires data from all three tables, view them again
SELECT * FROM orders
LIMIT 20;
SELECT * FROM shipments
LIMIT 20;
SELECT * FROM refunds
LIMIT 20;

# Q8 Solve
# With assumptions made as to what goes into net revenue for each courier, net revenue per parcel for each courier is calculated

SELECT s.courier, o.category,
(SUM(o.order_value) / NULLIF(COUNT(s.shipment_id), 0) -
((SUM(CASE WHEN r.refund_reason IN ('Damaged', 'Late') THEN r.refund_amount ELSE 0 END)) 
+ (SUM(CASE WHEN s.status = 'Lost'THEN o.order_value ELSE 0 END))) 
    / NULLIF(COUNT(s.shipment_id), 0)) AS net_revenue_per_parcel
FROM Orders AS o
JOIN shipments AS s
    ON o.order_id = s.order_id
LEFT JOIN refunds AS r
    ON o.order_id = r.order_id
GROUP BY s.courier, o.category
ORDER BY net_revenue_per_parcel DESC;
