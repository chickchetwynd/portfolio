SELECT

	Customers.Country, Categories.categoryname, SUM(quantity * price) AS sales
	
FROM

	OrderDetails
	INNER JOIN Products
	ON OrderDetails.ProductID = Products.ProductID
	INNER JOIN Categories
	ON Categories.CategoryID = Products.CategoryID
	INNER JOIN Orders
	ON orders.OrderID = OrderDetails.OrderID
	INNER JOIN Customers
	ON Customers.CustomerID = orders.CustomerID
	
GROUP BY categories.CategoryID, Categories.categoryname, Customers.Country

ORDER BY Customers.Country