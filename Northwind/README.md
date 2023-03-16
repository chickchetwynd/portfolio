# Creating a dashboard in Tableau

I created this dashboard using Microsoft's fictional Northwind Trader's database, available [here](https://en.wikiversity.org/wiki/Database_Examples/Northwind/SQLite). The dashboard was created using Tableau Public and data validation was performed with SQL on DB Browser.

<br>

My goal was to create a useful tool for a potential Northwind employee so they could quickly find a variety of visualizations representing the sales data. I wanted to include general total sales info, important monthly metrics, as well as a section to quickly lookup past orders.

<br>

### Calculated Fields

<br>

Some of the visualizations required programing of calculated fields. For example, the graph of average sales per order, per month required grouping sales per order before being aggregated by month. It looks like this is SQL:

```SQL

WITH ordering AS
(
SELECT
	STRFTIME('%m', orders.OrderDate) AS month, 
	orders.orderid,
	ROUND(SUM(price * Quantity), 2) AS total_price

FROM Orders
INNER JOIN OrderDetails
ON orders.OrderID = OrderDetails.OrderID
INNER JOIN Products
ON OrderDetails.ProductID = Products.ProductID

GROUP BY orders.orderdate, orders.orderid
)

SELECT
	month, ROUND(AVG(total_price), 2)
	
FROM
	ordering
	
GROUP BY month
```

<br>

This query has two layers of grouping. One GROUP BY clause is in a CTE and groups the sum of sales per order. The main query then groups the average sales of orders by month. In Tableau, the same results were achieved first by creating a calculated field of sales:

<img width="221" alt="Screenshot 2023-03-15 at 4 59 44 PM" src="https://user-images.githubusercontent.com/121225842/225471604-a3929a89-5b36-4da2-bcb7-9b1cfab3a518.png">


And then using a Level Of Detail expression in a calulated field to group sales into orders:


<img width="353" alt="Screenshot 2023-03-15 at 4 57 39 PM" src="https://user-images.githubusercontent.com/121225842/225471321-d78fcdc6-8592-4e03-a8b0-5b9d3fc2d846.png">

<br>

To create month to date metrics, this required creating a calculated field as a filter that expressed sales figures for the 1st day of the month up until the current (fictional) day of the month (12th):

<img width="215" alt="Screenshot 2023-03-15 at 5 03 18 PM" src="https://user-images.githubusercontent.com/121225842/225473046-b7f52ac0-38e6-4166-8c8a-34b84673b696.png">

And then using a table calculation to calculate the percentage difference from the previous month:


<img width="916" alt="Screenshot 2023-03-15 at 5 03 55 PM" src="https://user-images.githubusercontent.com/121225842/225473227-8bd693fd-3899-4f3f-8fcf-042bcf5cf0cf.png">




