# All code authored by Oliver Darlington

#avg shipping time per region
SELECT s.courier, o.region, 
AVG(CASE WHEN s.status = 'Delivered' THEN shipping_days END) AS Avg_shipping_time
FROM shipments as s
JOIN orders AS o 
ON s.order_id=o.order_id
GROUP BY s.courier, o.region
ORDER BY s.courier;

# avg shipping time per category
SELECT s.courier, o.category, 
AVG(CASE WHEN s.status = 'Delivered' THEN shipping_days END) AS Avg_shipping_time
FROM shipments as s
JOIN orders AS o 
ON s.order_id=o.order_id
GROUP BY s.courier, o.category
ORDER BY s.courier;

# Total cost of errors
SELECT s.courier, o.region,
SUM(CASE WHEN r.refund_reason IN ('Late', 'Damaged') THEN refund_amount END) + SUM(CASE WHEN s.status = 'Lost' THEN o.order_value END) AS Cost_of_errors
FROM shipments as s
JOIN orders AS o ON s.order_id=o.order_id
LEFT JOIN refunds as r on s.order_id=r.order_id
GROUP BY s.courier, o.region
ORDER BY s.courier, Cost_of_errors DESC;

# ERROR cost per delivery
SELECT s.courier,
COUNT(CASE WHEN s.status = 'Delivered' THEN s.shipment_id END) AS parcels_delivered,
SUM(CASE WHEN r.refund_reason IN ('Late', 'Damaged') THEN refund_amount END) + SUM(CASE WHEN s.status = 'Lost' THEN o.order_value END) AS Cost_of_errors,
(SUM(CASE WHEN r.refund_reason IN ('Late', 'Damaged') THEN refund_amount END) + SUM(CASE WHEN s.status = 'Lost' THEN o.order_value END)) / COUNT(CASE WHEN s.status = 'Delivered' THEN s.shipment_id END) AS cost_of_error_per_delivery
FROM shipments as s
JOIN orders AS o ON s.order_id=o.order_id
LEFT JOIN refunds as r on s.order_id=r.order_id
GROUP BY s.courier
ORDER BY courier, cost_of_error_per_delivery DESC;






# ERROR cost per delivery by category
SELECT s.courier, o.category,
COUNT(CASE WHEN s.status = 'Delivered' THEN s.shipment_id END) AS parcels_delivered,
SUM(CASE WHEN r.refund_reason IN ('Late', 'Damaged') THEN refund_amount END) + SUM(CASE WHEN s.status = 'Lost' THEN o.order_value END) AS Cost_of_errors,
(SUM(CASE WHEN r.refund_reason IN ('Late', 'Damaged') THEN refund_amount END) + SUM(CASE WHEN s.status = 'Lost' THEN o.order_value END)) / COUNT(CASE WHEN s.status = 'Delivered' THEN s.shipment_id END) AS cost_of_error_per_delivery
FROM shipments as s
JOIN orders AS o ON s.order_id=o.order_id
LEFT JOIN refunds as r on s.order_id=r.order_id
GROUP BY s.courier, o.category
ORDER BY o.category, cost_of_error_per_delivery DESC;

# Error cost per delivery by region
SELECT s.courier, o.region,
COUNT(CASE WHEN s.status = 'Delivered' THEN s.shipment_id END) AS parcels_delivered,
SUM(CASE WHEN r.refund_reason IN ('Late', 'Damaged') THEN refund_amount END) + SUM(CASE WHEN s.status = 'Lost' THEN o.order_value END) AS Cost_of_errors,
(SUM(CASE WHEN r.refund_reason IN ('Late', 'Damaged') THEN refund_amount END) + SUM(CASE WHEN s.status = 'Lost' THEN o.order_value END)) / COUNT(CASE WHEN s.status = 'Delivered' THEN s.shipment_id END) AS cost_of_error_per_delivery
FROM shipments as s
JOIN orders AS o ON s.order_id=o.order_id
LEFT JOIN refunds as r on s.order_id=r.order_id
GROUP BY s.courier, o.region
ORDER BY courier, cost_of_error_per_delivery DESC;







# Parcel category % of total
SELECT o.category, COUNT(s.shipment_id) AS catergory_total,
SUM(o.order_value) * 100 / SUM(SUM(o.order_value)) OVER() AS percent_total_value
FROM orders AS o
JOIN shipments AS s ON o.order_id=s.order_id
GROUP BY o.category
ORDER BY percent_total_value DESC;

# ERROR cost per delivery by category
SELECT o.category,
COUNT(CASE WHEN s.status = 'Delivered' THEN s.shipment_id END) AS parcels_delivered,
SUM(r.refund_reason) + SUM(CASE WHEN s.status = 'Lost' THEN o.order_value END) AS Total_cost_of_errors,
(SUM(r.refund_reason) + SUM(CASE WHEN s.status = 'Lost' THEN o.order_value END)) / COUNT(CASE WHEN s.status = 'Delivered' THEN s.shipment_id END) AS total_cost_of_error_per_delivery
FROM shipments as s
JOIN orders AS o ON s.order_id=o.order_id
LEFT JOIN refunds as r on s.order_id=r.order_id
GROUP BY o.category
ORDER BY total_cost_of_error_per_delivery DESC;

# reason for refund as percent
SELECT refund_reason,
COUNT(refund_reason) * 100 / SUM(COUNT(refund_amount)) OVER() AS percent_refunds
FROM refunds
GROUP BY refund_reason
ORDER BY percent_refunds DESC;

# Value refund as percent
SELECT refund_reason,
SUM(refund_amount) * 100 / SUM(SUM(refund_amount)) OVER() AS percent_refunds_value
FROM refunds
GROUP BY refund_reason
ORDER BY percent_refunds_Value DESC;

# Wrong item orders as percent
SELECT o.category,
COUNT(CASE WHEN r.refund_reason = 'Wrong Item' THEN r.refund_amount END) * 100 / SUM(COUNT(r.refund_amount)) OVER() AS percent_refunds_due_to_wrong_item 
FROM orders AS o 
LEFT JOIN refunds AS r ON o.order_id=r.refund_id
GROUP BY o.category
ORDER BY percent_refunds_due_to_wrong_item DESC;

# Return Reson as % Clothing
SELECT o.category, r.refund_reason,
COUNT(CASE WHEN o.category = 'Clothing' THEN r.refund_amount END) * 100 / SUM(CASE WHEN o.category = 'Clothing' THEN COUNT(r.refund_amount) END) OVER() AS percent_refund_reason
FROM orders AS o 
LEFT JOIN refunds AS r ON o.order_id=r.refund_id
WHERE o.category = 'Clothing'
GROUP BY o.category, r.refund_reason
ORDER BY percent_refund_reason DESC;

# Return Reson as % Toys
SELECT o.category, r.refund_reason,
COUNT(CASE WHEN o.category = 'Toys' THEN r.refund_amount END) * 100 / SUM(CASE WHEN o.category = 'Toys' THEN COUNT(r.refund_amount) END) OVER() AS percent_refund_reason
FROM orders AS o 
LEFT JOIN refunds AS r ON o.order_id=r.refund_id
WHERE o.category = 'Toys'
GROUP BY o.category, r.refund_reason
ORDER BY percent_refund_reason DESC;

# Return Reson as % Electronics
SELECT o.category, r.refund_reason,
COUNT(CASE WHEN o.category = 'Electronics' THEN r.refund_amount END) * 100 / SUM(CASE WHEN o.category = 'Electronics' THEN COUNT(r.refund_amount) END) OVER() AS percent_refund_reason
FROM orders AS o 
LEFT JOIN refunds AS r ON o.order_id=r.refund_id
WHERE o.category = 'Electronics'
GROUP BY o.category, r.refund_reason
ORDER BY percent_refund_reason DESC;

# Return Reson as % Sports
SELECT o.category, r.refund_reason,
COUNT(CASE WHEN o.category = 'Sports' THEN r.refund_amount END) * 100 / SUM(CASE WHEN o.category = 'Sports' THEN COUNT(r.refund_amount) END) OVER() AS percent_refund_reason
FROM orders AS o 
LEFT JOIN refunds AS r ON o.order_id=r.refund_id
WHERE o.category = 'Sports'
GROUP BY o.category, r.refund_reason
ORDER BY percent_refund_reason DESC;

# Return Reson as % Home
SELECT o.category, r.refund_reason,
COUNT(CASE WHEN o.category = 'Home' THEN r.refund_amount END) * 100 / SUM(CASE WHEN o.category = 'Home' THEN COUNT(r.refund_amount) END) OVER() AS percent_refund_reason
FROM orders AS o 
LEFT JOIN refunds AS r ON o.order_id=r.refund_id
WHERE o.category = 'Home'
GROUP BY o.category, r.refund_reason
ORDER BY percent_refund_reason DESC;
