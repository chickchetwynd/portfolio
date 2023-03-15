SELECT

	categories.CategoryID, Categories.categoryname, SUM(quantity * price) AS sales
	
FROM

	OrderDetails
	INNER JOIN Products
	ON OrderDetails.ProductID = Products.ProductID
	INNER JOIN Categories
	ON Categories.CategoryID = Products.CategoryID
	
GROUP BY categories.CategoryID, Categories.categoryname