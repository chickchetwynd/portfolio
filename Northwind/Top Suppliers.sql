SELECT

	Suppliers.SupplierID, Suppliers.SupplierName, SUM(OrderDetails.Quantity * Products.price) AS sales


FROM

	orders
	INNER JOIN OrderDetails
	ON orders.orderid = orderdetails.OrderID
	INNER JOIN Products
	ON OrderDetails.ProductID = Products.ProductID
	INNER JOIN Suppliers
	ON Products.SupplierID = Suppliers.SupplierID
	
GROUP BY Suppliers.SupplierID, Suppliers.SupplierName

ORDER BY SUM(OrderDetails.Quantity * Products.price) DESC

LIMIT 10