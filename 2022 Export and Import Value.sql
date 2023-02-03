--2022 EXPORT AND IMPORT VALUE DATA EXPLORATION
--- Skills used: Joins, Aggregate Functions, Windows Functions

---EXPORT VALUE
SELECT SUM(Value) As TotalExportValue
FROM dbo.export

SELECT Month, Sum(Value) As ExportValuePerMonth
FROM dbo.export
GROUP BY Month
ORDER BY ExportValuePerMonth DESC

SELECT Goods, SUM(Value) As ExportValueByGoods
FROM dbo.export
GROUP BY Goods
ORDER BY ExportValueByGoods DESC


--- IMPORT VALUE
SELECT SUM(Value) As TotalImportValue
FROM dbo.import

SELECT Month, Sum(Value) As ImportValuePerMonth
FROM dbo.import
GROUP BY Month
ORDER BY ImportValuePerMonth DESC

SELECT Goods, SUM(Value) As ImportValueByGoods
FROM dbo.import
GROUP BY Goods
ORDER BY ImportValueByGoods DESC

---EXPORT VALUE vs IMPORT VALUE	

----Determine Trade Surplus
SELECT (SUM(dbo.export.Value) - SUM(dbo.import.Value)) as TradeSurplus
FROM dbo.export FULL OUTER JOIN dbo.import on dbo.export.Month = dbo.import.Month