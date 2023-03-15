SELECT

	Employees.EmployeeID, Employees.FirstName ||  ' ' || Employees.LastName AS employee, SUM(quantity * price) AS sales

FROM

	orders
	INNER JOIN OrderDetails
	ON orders.orderid = orderdetails.OrderID
	INNER JOIN Products
	ON OrderDetails.ProductID = Products.ProductID
	INNER JOIN Employees
	ON Orders.EmployeeID = Employees.EmployeeID
	
GROUP BY Employees.EmployeeID, Employees.FirstName ||  ' ' || Employees.LastName

ORDER BY SUM(quantity * price) DESC

LIMIT 10