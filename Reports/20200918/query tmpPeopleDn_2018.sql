USE AccountOMS
GO
--DROP TABLE tmpGood2018DN
go
SELECT distinct ReportYear,d.ENP,W,DateEnd,DS1,
REPLACE((SELECT DISTINCT ISNULL(RTRIM(dd.DS1),'') AS 'data()'
															 FROM dbo.tmpPeopleDN_2019 dd 
															 WHERE dd.MainDS<>d.MainDS AND  dd.ENP=d.enp AND dd.DS1 IS NOT NULL --AND dd.idRow>1
															 for xml path('')
															  ),' ',',') AS DS2
,IsDNType,col8,d.Col9
INTO tmpGood2018DN
FROM dbo.tmpPeopleDN_2018 d 
WHERE idrow =1 
ORDER BY ENP

ALTER TABLE tmpGood2018DN ADD id INT IDENTITY(1,1) NOT NULL

