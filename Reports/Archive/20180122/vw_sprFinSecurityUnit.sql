USE oms_NSI
go      
--ALTER TABLE dbo.tFinSecurityUnit ADD XMLNum AS cast(replace('<Root><Num num="'+planUnitCodes+'" /></Root>',',','" /><Num num="') as xml) 

SELECT *--,cast(replace('<Root><Num num="'+planUnitCodes+'" /></Root>',',','" /><Num num="') as xml) AS XMlNum
--INTO #tmp
FROM oms_nsi.dbo.tFinSecurityUnit
go
CREATE VIEW vw_sprFinSecurityUnit
as
WITH cte
AS(
SELECT s.FinSecurityUnitId,m.c.value('@num[1]','tinyint') AS UnitCode
FROM oms_nsi.dbo.tFinSecurityUnit s CROSS APPLY s.XMLNum.nodes('/Root/Num') as m(c)
)
SELECT u.*,c.UnitCode
FROM cte c INNER JOIN oms_nsi.dbo.tFinSecurityUnit u ON
		c.FinSecurityUnitId=u.FinSecurityUnitId
go

