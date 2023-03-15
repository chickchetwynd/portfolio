SELECT

	Customers.country AS country, Customers.City AS city, SUM(quantity * price) AS sales

FROM

	orders
	INNER JOIN OrderDetails
	ON orders.orderid = orderdetails.OrderID
	INNER JOIN Products
	ON OrderDetails.ProductID = Products.ProductID
	INNER JOIN Customers
	ON Orders.CustomerID = Customers.CustomerID
	
GROUP BY Customers.country, Customers.city