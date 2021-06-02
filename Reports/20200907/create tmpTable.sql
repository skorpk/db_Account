USE AccountOMS
GO
;WITH cte
AS
(
SELECT DISTINCT enp,1 AS reportMonth,year FROM dbo.tmpDN_2019 WHERE year=2019
UNION ALL
SELECT DISTINCT enp,2 AS reportMonth,year FROM dbo.tmpDN_2019 WHERE year=2019
UNION ALL
SELECT DISTINCT enp,3 AS reportMonth,year FROM dbo.tmpDN_2019 WHERE year=2019
UNION ALL
SELECT DISTINCT enp,4 AS reportMonth,year FROM dbo.tmpDN_2019 WHERE year=2019
UNION ALL
SELECT DISTINCT enp,5 AS reportMonth,year FROM dbo.tmpDN_2019 WHERE year=2019
UNION ALL
SELECT DISTINCT enp,6 AS reportMonth,year FROM dbo.tmpDN_2019 WHERE year=2019
UNION ALL
SELECT DISTINCT enp,7 AS reportMonth,year FROM dbo.tmpDN_2019 WHERE year=2019
UNION ALL
SELECT DISTINCT enp,8 AS reportMonth,year FROM dbo.tmpDN_2019 WHERE year=2019
UNION ALL
SELECT DISTINCT enp,9 AS reportMonth,year FROM dbo.tmpDN_2019 WHERE year=2019
UNION ALL
SELECT DISTINCT enp,10 AS reportMonth,year FROM dbo.tmpDN_2019 WHERE year=2019
UNION ALL
SELECT DISTINCT enp,11 AS reportMonth,year FROM dbo.tmpDN_2019 WHERE year=2019
UNION ALL
SELECT DISTINCT enp,12 AS reportMonth,year FROM dbo.tmpDN_2019 WHERE year=2019
-----------------------------------------------------------------------------
UNION ALL
SELECT DISTINCT enp,1 AS reportMonth,year FROM dbo.tmpDN_2019 WHERE year=2020
UNION ALL
SELECT DISTINCT enp,2 AS reportMonth,year FROM dbo.tmpDN_2019 WHERE year=2020
UNION ALL
SELECT DISTINCT enp,3 AS reportMonth,year FROM dbo.tmpDN_2019 WHERE year=2020
UNION ALL
SELECT DISTINCT enp,4 AS reportMonth,year FROM dbo.tmpDN_2019 WHERE year=2020
UNION ALL
SELECT DISTINCT enp,5 AS reportMonth,year FROM dbo.tmpDN_2019 WHERE year=2020
UNION ALL
SELECT DISTINCT enp,6 AS reportMonth,year FROM dbo.tmpDN_2019 WHERE year=2020
UNION ALL
SELECT DISTINCT enp,7 AS reportMonth,year FROM dbo.tmpDN_2019 WHERE year=2020

)
SELECT enp,cte.reportMonth,cte.year,DATEADD(MONTH,1,CAST(cte.year AS CHAR(4))+right('0'+CAST(cte.reportMonth AS VARCHAR(2)),2)+'01') AS dd
INTO tmpDN_1920
FROM cte 