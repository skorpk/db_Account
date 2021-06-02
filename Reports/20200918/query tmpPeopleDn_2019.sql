USE AccountOMS
GO
DROP TABLE tmpGood2019DN
go
SELECT distinct ReportYear,d.ENP,W,DateEnd,DS1,
REPLACE((SELECT DISTINCT ISNULL(RTRIM(dd.DS1),'') AS 'data()'
															 FROM dbo.tmpPeopleDN_2019 dd 
															 WHERE dd.MainDS<>d.MainDS AND  dd.ENP=d.enp AND dd.DS1 IS NOT NULL --AND dd.idRow>1
															 for xml path('')
															  ),' ',',') AS DS2
,IsDNType,col8,d.Col9
INTO tmpGood2019DN
FROM dbo.tmpPeopleDN_2019 d 
WHERE idrow =1 AND MainDS not IN('I26','I28','I30','I31','I33','I36','I37','I38 ','I39','I40','I41','I43','I46','I51','I52','I60','I61','I62','I63','I64 ','I68','I70','I71','I72',
			'I73','I74','I77','I78','I79','I80','I81 ','I82','I83','I84','I85','I86','I87','I88','I89','I95','I97','I99')
ORDER BY ENP

ALTER TABLE tmpGood2019DN ADD id INT IDENTITY(1,1) NOT NULL

