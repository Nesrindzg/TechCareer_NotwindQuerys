USE Notwind
GO
--SORULAR
-- S1-) sadece çalıştırınız ve çıktının ekran görüntüsünü slaytınıza ekleyiniz

-- 1. Tanım Sorusu:
-- Northwind veritabanında toplam kaç tablo vardır? Bu tabloların isimlerini listeleyiniz.
-- SELECT COUNT(*) AS TableCount FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE';
-- SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE';

-- System tarafından oluşturulan tabloları dahil etmemek için:
SELECT COUNT(*) AS TableCount FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE' AND TABLE_NAME not like 'sys%';
SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE' AND TABLE_NAME not like 'sys%';

-- 2. JOIN Sorusu:
-- Her sipariş (Orders) için, müşterinin adı (CustomerName), çalışan adı (Employee Full Name), sipariş tarihi (orderdate)
--ve gönderici şirketin adı (Shipper) ile birlikte bir liste çıkarın.
SELECT O.OrderID, C.ContactName AS CustomerName, CONCAT(E.FirstName,' ',E.LastName) AS EmployeeName, O.OrderDate, S.CompanyName
FROM Orders O
INNER JOIN Customers C ON C.CustomerID=O.CustomerID
INNER JOIN Employees E ON E.EmployeeID=O.EmployeeID
INNER JOIN Shippers S ON S.ShipperID=O.ShipVia

-- 3. Aggregate Fonksiyon:
-- Tüm siparişlerin toplam tutarını bulun. (Order Details tablosundaki Quantity UnitPrice üzerinden
--hesaplayınız)
SELECT *FROM [Order Details] OD

SELECT OD.OrderID,SUM(OD.UnitPrice*Quantity) AS TotalPrice, CAST(SUM(OD.UnitPrice*Quantity*(1.00-OD.Discount)) AS DECIMAL(18,2)) AS DiscountedPrice
FROM [Order Details] OD
GROUP BY OD.OrderID

SELECT SUM(OD.UnitPrice*Quantity) AS TotalPrice, CAST(SUM(OD.UnitPrice*Quantity*(1.00-OD.Discount)) AS DECIMAL(18,2)) AS DiscountedPrice
FROM [Order Details] OD
-- 4. Gruplama:
-- Hangi ülkeden kaç müşteri vardır?
SELECT C.Country,COUNT(*) AS Total FROM Customers C GROUP BY C.Country

-- 5. Subquery Kullanımı:
-- En pahalı ürünün adını ve fiyatını listeleyiniz.
SELECT P.ProductName, P.UnitPrice FROM Products P WHERE P.UnitPrice=(SELECT MAX(UnitPrice) FROM Products)

-- 6. JOIN ve Aggregate:
-- Çalışan başına düşen sipariş sayısını gösteren bir liste çıkarınız.
-- Ortalama bir çalışana düşen sipariş sayısı
SELECT 
	COUNT(DISTINCT(O.OrderID)) AS OrderSUM, 
	COUNT(DISTINCT(E.EmployeeID)) AS EmployeeSUM,
	(COUNT(DISTINCT(O.OrderID))/COUNT(DISTINCT(E.EmployeeID))) AS OrdersPerEmployee
FROM Orders O
INNER JOIN Employees E ON E.EmployeeID=O.EmployeeID

-- Çalışanların aldığı toplam sipariş sayıları
SELECT (E.FirstName+' '+E.LastName) AS EmployeeName, COUNT(*) AS OrderCount FROM Orders O 
INNER JOIN Employees E ON E.EmployeeID=O.EmployeeID
GROUP BY O.EmployeeID, (E.FirstName+' '+E.LastName)


-- 7. Tarih Filtreleme:
-- 1997 yılında verilen siparişleri listeleyin.
SELECT O.OrderID, CONVERT(DATE,O.OrderDate) AS OrderDate, C.ContactName AS CustomerName
FROM Orders O
INNER JOIN Customers C ON C.CustomerID=O.CustomerID
WHERE YEAR(O.OrderDate)='1997'
ORDER BY O.OrderDate

-- 8. CASE Kullanımı:
-- Ürünleri fiyat aralıklarına göre kategorilere ayırarak listeleyin: 020 → Ucuz, 2050 → Orta, 50+ → Pahalı.
SELECT P.ProductName, P.UnitPrice,
CASE
        WHEN P.UnitPrice BETWEEN 0 AND 20 THEN 'Ucuz'
        WHEN P.UnitPrice BETWEEN 20 AND 50 THEN 'Orta'
        WHEN P.UnitPrice > 50 THEN 'Pahalı'
    END AS PriceCategory
FROM Products P

-- 9. Nested Subquery:
-- En çok sipariş verilen ürünün adını ve sipariş adedini (adet bazında) bulun.
SELECT TOP 1 OD.ProductID, P.ProductName, COUNT(*) AS TotalOrder, SUM(OD.Quantity) AS TotalQuantity FROM [Order Details] OD
INNER JOIN Products P ON P.ProductID=OD.ProductID
GROUP BY OD.ProductID, P.ProductName ORDER BY TotalOrder DESC

SELECT OD.ProductID, P.ProductName, COUNT(*) AS TotalOrder, SUM(OD.Quantity) AS TotalQuantity FROM [Order Details] OD
INNER JOIN Products P ON P.ProductID=OD.ProductID
GROUP BY OD.ProductID, P.ProductName ORDER BY TotalQuantity DESC

-- 10. View Oluşturma:
-- Ürünler ve kategori bilgilerini birleştiren bir görünüm (view) oluşturun.
CREATE VIEW VW_ProductsCategory AS
SELECT P.ProductID, P.ProductName, C.CategoryName, C.Description, P.QuantityPerUnit, P.UnitPrice 
FROM Products P
INNER JOIN Categories C ON C.CategoryID=P.CategoryID;

SELECT * FROM VW_ProductsCategory

-- 11. Trigger:
-- Ürün silindiğinde log tablosuna kayıt yapan bir trigger yazınız.
CREATE TABLE ProductLog (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT,
    ProductName NVARCHAR(255),
    DeletedDate DATETIME DEFAULT GETDATE(),
    DeletedBy NVARCHAR(100)
);

CREATE TRIGGER TRG_ProductDeleteLog
ON Products
AFTER DELETE
AS
BEGIN
    INSERT INTO ProductLog (ProductID, ProductName, DeletedDate, DeletedBy)
    SELECT 
        d.ProductID, 
        d.ProductName, 
        GETDATE(), 
        SUSER_NAME()
    FROM deleted d;
END;
SELECT * FROM Products P WHERE P.ProductID=78
DELETE FROM Products  WHERE ProductID=78
SELECT * FROM ProductLog;

-- 12. Stored Procedure:
-- Belirli bir ülkeye ait müşterileri listeleyen bir stored procedure yazınız.
CREATE PROCEDURE GetCustomers
@country varchar(50)
AS
BEGIN
SELECT * FROM Customers C WHERE C.Country=@country
END;

EXEC GetCustomers @country='Italy';

-- 13. Left Join Kullanımı:
-- Tüm ürünlerin tedarikçileriyle (suppliers) birlikte listesini yapın. Tedarikçisi olmayan ürünler de listelensin.
SELECT * FROM Products P
LEFT JOIN Suppliers S ON S.SupplierID=P.SupplierID

-- 14. Fiyat Ortalamasının Üzerindeki Ürünler:
-- Fiyatı ortalama fiyatın üzerinde olan ürünleri listeleyin.
SELECT P.ProductName, P.UnitPrice FROM Products P
WHERE P.UnitPrice>(SELECT AVG(UnitPrice) FROM Products)

-- 15. En Çok Ürün Satan Çalışan:
-- Sipariş detaylarına göre en çok ürün satan çalışan kimdir?
SELECT TOP 1 (E.FirstName+' '+E.LastName) AS EmployeeName, COUNT(*) AS OrderCount FROM Orders O 
INNER JOIN Employees E ON E.EmployeeID=O.EmployeeID
GROUP BY O.EmployeeID, (E.FirstName+' '+E.LastName)
ORDER BY OrderCount DESC

-- 16. Ürün Stoğu Kontrolü:
-- Stok miktarı 10’un altında olan ürünleri listeleyiniz.
SELECT * FROM Products WHERE UnitsInStock<10

-- 17. Şirketlere Göre Sipariş Sayısı:
-- Her müşteri şirketinin yaptığı sipariş sayısını ve toplam harcamasını bulun.
SELECT O.CustomerID, COUNT(*) AS OrderCount, SUM(OD.UnitPrice*Quantity) AS Total FROM Orders O
INNER JOIN [Order Details] OD ON OD.OrderID=O.OrderID
GROUP BY O.CustomerID
ORDER BY OrderCount

SELECT * FROM Orders WHERE CustomerID='CENTC'
SELECT * FROM [Order Details] WHERE OrderID='10259'

-- 18. En Fazla Müşterisi Olan Ülke:
SELECT TOP 1 C.Country, COUNT(*) AS CustomerCount FROM Customers C
GROUP BY C.Country ORDER BY CustomerCount DESC

-- 19. Her Siparişteki Ürün Sayısı:
-- Siparişlerde kaç farklı ürün olduğu bilgisini listeleyin.
SELECT OD.OrderID, COUNT(OD.ProductID) AS ProductCount FROM [Order Details] OD 
GROUP BY OD.OrderID

SELECT * FROM [Order Details] OD 
WHERE OD.OrderID=10255

-- 20. Ürün Kategorilerine Göre Ortalama Fiyat:
-- Her kategoriye göre ortalama ürün fiyatını bulun.
SELECT C.CategoryName, AVG(P.UnitPrice) AS PriceAvg FROM Products P
INNER JOIN Categories C ON C.CategoryID=P.CategoryID
GROUP BY C.CategoryName

SELECT * FROM Products P
INNER JOIN Categories C ON C.CategoryID=P.CategoryID
WHERE C.CategoryName='Produce'

-- 21. Aylık Sipariş Sayısı:
-- Siparişleri ay ay gruplayarak kaç sipariş olduğunu listeleyin.
SELECT MONTH(O.OrderDate) AS Months, COUNT(*) AS OrderCount FROM Orders O
GROUP BY MONTH(O.OrderDate)
ORDER BY MONTH(O.OrderDate) 

-- 22. Çalışanların Müşteri Sayısı:
-- Her çalışanın ilgilendiği müşteri sayısını listeleyin.
SELECT (E.FirstName+' '+E.LastName) AS EmployeeName, COUNT(*) AS OrderCount FROM Orders O 
INNER JOIN Employees E ON E.EmployeeID=O.EmployeeID
GROUP BY O.EmployeeID, (E.FirstName+' '+E.LastName)

-- 23. Hiç siparişi olmayan müşterileri listeleyin.
SELECT O.OrderID,O.CustomerID,C.CompanyName FROM Orders O
RIGHT JOIN Customers C ON C.CustomerID=O.CustomerID
WHERE O.OrderID IS NULL

-- 24. Siparişlerin Nakliye (Freight) Maliyeti Analizi:
-- Nakliye maliyetine göre en pahalı 5 siparişi listeleyin.
SELECT TOP 5 O.OrderID,O.CustomerID,O.Freight FROM Orders O
ORDER BY O.Freight DESC