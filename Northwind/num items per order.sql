WITH items_per_order AS
(
	SELECT
		OrderID, SUM(Quantity) AS num_items
	FROM
		OrderDetails
	GROUP BY OrderID
	)
	
SELECT

	STRFTIME('%m', orders.OrderDate) AS month,
	ROUND(AVG(items_per_order.num_items)) AS avg_num_items_per_order
	
FROM
	items_per_order
	INNER JOIN Orders
	ON items_per_order.orderid = orders.orderid
	
GROUP BY STRFTIME('%m', orders.OrderDate)
