SELECT

	Customers.CustomerID, Customers.CustomerName AS name, SUM(quantity * price) AS sales

FROM

	orders
	INNER JOIN OrderDetails
	ON orders.orderid = orderdetails.OrderID
	INNER JOIN Products
	ON OrderDetails.ProductID = Products.ProductID
	INNER JOIN Customers
	ON Orders.CustomerID = Customers.CustomerID
	
GROUP BY Customers.CustomerID, Customers.CustomerName

ORDER BY SUM(quantity * price) DESC

LIMIT 10