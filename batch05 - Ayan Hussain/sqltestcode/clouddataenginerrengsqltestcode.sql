Q1. List top 5 customers by total order amount.
Retrieve the top 5 customers who have spent the most across all sales orders. Show CustomerID, CustomerName, and TotalSpent.


select top 5
    c.CustomerID,
    c.Name AS CustomerName,
    SUM(so.TotalAmount) AS TotalSpent
FROM Customer c
INNER JOIN SalesOrder so
    ON c.CustomerID = so.CustomerID
GROUP BY
    c.CustomerID,
    c.Name
ORDER BY
    TotalSpent DESC;

    Select CustomerID  from SalesOrder 





Q2. Find the number of products supplied by each supplier.
Display SupplierID, SupplierName, and ProductCount. Only include suppliers that have more than 10 products.





    select
    s.SupplierID,
    s.Name AS SupplierName,
    COUNT(po.ProductID) AS ProductCount
FROM Supplier s
INNER JOIN PurchaseOrder p
    ON s.SupplierID = p.SupplierID
INNER JOIN PurchaseOrderDetail po
    ON p.OrderID = po.OrderID
GROUP BY
    s.SupplierID,
    s.Name
HAVING COUNT(po.ProductID) > 10
ORDER BY ProductCount DESC;





Q3. Identify products that have been ordered but never returned.
Show ProductID, ProductName, and total order quantity.

select * from Product

select
    p.ProductID,
    p.Name AS ProductName,
    SUM(sod.Quantity) AS TotalOrderQuantity
FROM Product p
INNER JOIN SalesOrderDetail sod
    ON p.ProductID = sod.ProductID
LEFT JOIN ReturnDetail rd
    ON p.ProductID = rd.ProductID
WHERE rd.ProductID IS NULL
GROUP BY
    p.ProductID,
    p.Name;


Q4. For each category, find the most expensive product.
Display CategoryID, CategoryName, ProductName, and Price. Use a subquery to get the max price per category.


SELECT
    c.CategoryID,
    c.Name AS CategoryName,
    p.Name AS ProductName,
    p.Price
FROM Product p
INNER JOIN Category c
    ON p.CategoryID = c.CategoryID
WHERE p.Price =
(
    SELECT MAX(p2.Price)
    FROM Product p2
    WHERE p2.CategoryID = p.CategoryID
);



Q5. List all sales orders with customer name, product name, category, and supplier.
For each sales order, display:
OrderID, CustomerName, ProductName, CategoryName, SupplierName, and Quantity.

select
    so.OrderID,
    c.Name AS CustomerName,
    p.Name AS ProductName,
    cat.Name AS CategoryName,
    sup.Name AS SupplierName,
    sod.Quantity
FROM SalesOrder so
INNER JOIN Customer c
    ON so.CustomerID = c.CustomerID
INNER JOIN SalesOrderDetail sod
    ON so.OrderID = sod.OrderID
INNER JOIN Product p
    ON sod.ProductID = p.ProductID
INNER JOIN Category cat
    ON p.CategoryID = cat.CategoryID
INNER JOIN PurchaseOrderDetail pod
    ON p.ProductID = pod.ProductID
INNER JOIN PurchaseOrder po
    ON pod.OrderID = po.OrderID
INNER JOIN Supplier sup
    ON po.SupplierID = sup.SupplierID;


Q6. Find all shipments with details of warehouse, manager, and products shipped.
Display:
ShipmentID, WarehouseName, ManagerName, ProductName, QuantityShipped, and TrackingNumber.


SELECT
    s.ShipmentID,
    w.ContactInfo AS WarehouseName,
    e.Name AS ManagerName,
    p.Name AS ProductName,
    sd.Quantity AS QuantityShipped,
    s.TrackingNumber
FROM Shipment s
INNER JOIN Warehouse w
    ON s.WarehouseID = w.WarehouseID
INNER JOIN Employee e
    ON w.ManagerID = e.EmployeeID
INNER JOIN ShipmentDetail sd
    ON s.ShipmentID = sd.ShipmentID
INNER JOIN Product p
    ON sd.ProductID = p.ProductID;


Q7. Find the top 3 highest-value orders per customer using RANK(). Display CustomerID, CustomerName, OrderID, and TotalAmount.


SELECT TOP 3
    c.CustomerID,
    c.Name AS CustomerName,
    so.OrderID,
    so.TotalAmount
FROM Customer c
INNER JOIN SalesOrder so
    ON c.CustomerID = so.CustomerID
ORDER BY so.TotalAmount DESC;


Q8. For each product, show its sales history with the previous and next sales quantities (based on order date). Display ProductID, ProductName, OrderID, OrderDate, Quantity, PrevQuantity, and NextQuantity.


SELECT
    p.ProductID,
    p.Name AS ProductName,
    so.OrderID,
    so.OrderDate,
    sod.Quantity,

    LAG(sod.Quantity)
    OVER
    (
        PARTITION BY p.ProductID
        ORDER BY so.OrderDate
    ) AS PrevQuantity,

    LEAD(sod.Quantity)
    OVER
    (
        PARTITION BY p.ProductID
        ORDER BY so.OrderDate
    ) AS NextQuantity

FROM Product p
INNER JOIN SalesOrderDetail sod
    ON p.ProductID = sod.ProductID
INNER JOIN SalesOrder so
    ON sod.OrderID = so.OrderID;





Q9. Create a view named vw_CustomerOrderSummary that shows for each customer:
CustomerID, CustomerName, TotalOrders, TotalAmountSpent, and LastOrderDate.


SELECT
    c.CustomerID,
    c.Name AS CustomerName,
    COUNT(so.OrderID) AS TotalOrders,
    SUM(so.TotalAmount) AS TotalAmountSpent,
    MAX(so.OrderDate) AS LastOrderDate
FROM Customer c
LEFT JOIN SalesOrder so
    ON c.CustomerID = so.CustomerID
GROUP BY
    c.CustomerID,
    c.Name;



Q10. Write a stored procedure sp_GetSupplierSales that takes a SupplierID as input and returns the total sales amount for all products supplied by that supplier.

SELECT * FROM Supplier;


CREATE PROCEDURE sp_GetSupplierSales
    @SupplierID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        s.SupplierID,
        SUM(sod.Quantity * p.Price) AS TotalSalesAmount
    FROM Supplier s
    INNER JOIN PurchaseOrder po
        ON s.SupplierID = po.SupplierID
    INNER JOIN PurchaseOrderDetail pod
        ON po.OrderID = pod.OrderID
    INNER JOIN Product p
        ON pod.ProductID = p.ProductID
    INNER JOIN SalesOrderDetail sod
        ON p.ProductID = sod.ProductID
    WHERE s.SupplierID = @SupplierID
    GROUP BY s.SupplierID;
END;
GO