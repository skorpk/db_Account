USE AccountOMS
GO
--SELECT DISTINCT p.MainDS,COUNT(DISTINCT ENP)
--FROM dbo.t_Case c INNER JOIN dbo.tmpPeopleDN_2018 p ON
--		c.id=p.rf_idCase
--WHERE p.idRow=1 AND p.ds1 LIKE 'I%' AND c.age>18 AND Col9 IS null
--GROUP BY p.MainDS

--SELECT COUNT(DISTINCT ENP)
--FROM dbo.t_Case c INNER JOIN dbo.tmpPeopleDN_2018 p ON
--		c.id=p.rf_idCase
--WHERE p.idRow=1 AND p.ds1 LIKE 'I%' AND c.age<18 AND Col9 IS null
--/*
--BEGIN TRANSACTION
--UPDATE p SET p.idRow=null
--FROM dbo.t_Case c INNER JOIN dbo.tmpPeopleDN_2020 p ON
--		c.id=p.rf_idCase
--WHERE p.idRow=1 AND p.ds1 LIKE 'I%' AND c.age<18
--COMMIT
--*/
SELECT COUNT(DISTINCT p.ENP)
FROM  dbo.tmpPeopleDN_2018 p INNER JOIN dbo.tmpGood2019DN g ON
			p.enp=g.enp
WHERE p.idRow=1 AND p.ds1 LIKE 'I%' AND p.Col9 IS NULL AND g.DS1 LIKE 'I%'


SELECT COUNT(DISTINCT p.ENP)
FROM  dbo.tmpPeopleDN_2018 p INNER JOIN dbo.tmpGood2019DN g ON
			p.enp=g.enp
WHERE p.idRow=1 AND p.Col9 IS NULL AND (p.ds1 LIKE 'C%' OR p.DS1 BETWEEN 'D00' AND 'D09') AND (g.ds1 LIKE 'C%' OR g.DS1 BETWEEN 'D00' AND 'D09')


/*
SELECT COUNT(DISTINCT ENP)
FROM dbo.tmpPeopleDN_2020 p 
WHERE p.idRow=1 AND (p.ds1 LIKE 'C%' OR p.DS1 BETWEEN 'D00' AND 'D09') AND Col9 IS NULL AND sid IS NOT null

SELECT *
FROM dbo.tmpPeopleDN_2020 p 
WHERE p.idRow=1 AND (p.ds1 LIKE 'C%' OR p.DS1 BETWEEN 'D00' AND 'D09') AND Col9 IS NULL AND sid IS NOT null
	AND NOT EXISTS(SELECT 1 FROM tmpOnkologia2020_GOOD g WHERE p.enp=g.enp)
	*/
--SELECT COUNT(DISTINCT ENP)
--FROM dbo.tmpOnkologia2019 o WHERE o.IdTypeCol12=0


--SELECT COUNT(DISTINCT ENP)
--FROM dbo.tmpPeopleDN_2019 p
--WHERE p.idRow=1 AND p.ds1 LIKE 'I%' AND Col9 IS NULL AND MainDS LIKE 'I%' and MainDS not IN('I26','I28','I30','I31','I33','I36','I37','I38 ','I39','I40','I41','I43','I46','I51','I52','I60','I61','I62','I63','I64 ','I68','I70','I71','I72',
--			'I73','I74','I77','I78','I79','I80','I81 ','I82','I83','I84','I85','I86','I87','I88','I89','I95','I97','I99')

