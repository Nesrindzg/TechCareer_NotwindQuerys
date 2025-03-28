**SQL BITIRME PROJESI**  
TECHCAREER  
NESRİN DÜZGÜN  

Anahtar Kelimeler: **SQL, MSSQL, RDBMS, GITHUB**


## Giriş

Bu sunumda, **Northwind veritabanı** üzerinde çalıştırılması gereken **24 farklı sorunun çözümlerini** anlatacağım. 

- **Kullanılan Yapılar:**
  - `SELECT`
  - `INNER JOIN`
  - `VIEW`
  - `TRIGGER`
  - `PROCEDURE`

Her bir çözümü detaylıca açıklayarak, nasıl ve neden bu yöntemleri kullandığımı paylaşacağım.

---

## Kullanılan Veritabanı

**Northwind Veritabanı** 

- Microsoft tarafından sağlanan örnek bir veritabanıdır.
- İçerisinde müşteri, sipariş, tedarikçi gibi tablolar bulunmaktadır.
- SQL sorgularını test etmek ve geliştirme yapmak için idealdir.

**Tablolar:**
- Customers
- Orders
- Products
- Employees

---

## Örnek SQL Sorgusu

**Siparişlerin Toplam Tutarı:**

```sql
SELECT 
  OD.OrderID,
  SUM(OD.UnitPrice*Quantity) AS TotalPrice, 
  CAST(SUM(OD.UnitPrice*Quantity*(1.00-OD.Discount)) AS DECIMAL(18,2)) AS DiscountedPrice
FROM [Order Details] OD
GROUP BY OD.OrderID
```

---

## Sonuç ve Öneriler

- SQL'in temel ve ileri düzey sorguları nasıl kullanılacağını öğrendim.
- **VIEW, TRIGGER ve PROCEDURE** gibi yapıları Northwind veritabanında test ettim.
- Gerçek dünya projelerinde kullanılabilecek pratik çözümler geliştirdim.

> **Gelecekteki Planlar:** Daha büyük ve karmaşık veritabanları üzerinde çalışma yaparak **performans optimizasyonu** ve **gelişmiş sorgular** konularında kendimi geliştirmek istiyorum.

---
