USE AccountOMS
GO

SELECT COUNT(DISTINCT p.ENP)
FROM  dbo.tmpPeopleDN_2018 p INNER JOIN dbo.tmpGood2019DN g ON
			p.enp=g.enp
WHERE p.idRow=1 AND p.ds1 LIKE 'I%' AND p.Col9 IS NULL AND g.DS1 LIKE 'I%'

--UPDATE p SET p.idRow=null
--FROM  dbo.tmpPeopleDN_2018 p 			
--WHERE p.idRow=1 AND p.Col9 IS NULL AND p.ds1 LIKE 'I%' AND 
--NOT EXISTS(SELECT 1 FROM dbo.tmpGood2019DN g WHERE p.enp=g.enp and g.ds1 LIKE 'I%')

SELECT COUNT(DISTINCT p.ENP)
FROM  dbo.tmpPeopleDN_2018 p 			
WHERE p.idRow=1 AND p.Col9 IS NULL AND p.ds1 LIKE 'I%' 

SELECT COUNT(DISTINCT p.ENP)
FROM  dbo.tmpPeopleDN_2018 p 			
WHERE p.idRow IS null AND p.Col9 IS NULL AND p.ds1 LIKE 'I%'  AND NOT EXISTS(SELECT 1 FROM dbo.tmpPeopleDN_2018 pp WHERE pp.idRow>1 AND pp.ds1 LIKE 'I%' )


/*
SELECT COUNT(DISTINCT p.ENP)
FROM  dbo.tmpPeopleDN_2018 p INNER JOIN dbo.tmpGood2019DN g ON
			p.enp=g.enp
WHERE p.idRow=1 AND p.Col9 IS NULL AND (p.ds1 LIKE 'C%' OR p.DS1 BETWEEN 'D00' AND 'D09') AND (g.ds1 LIKE 'C%' OR g.DS1 BETWEEN 'D00' AND 'D09')
*/

--UPDATE p SET p.idRow=null
--FROM  dbo.tmpPeopleDN_2018 p 			
--WHERE p.idRow=1 AND p.Col9 IS NULL AND (p.ds1 LIKE 'C%' OR p.DS1 BETWEEN 'D00' AND 'D09') AND 
--NOT EXISTS(SELECT 1 FROM dbo.tmpGood2019DN g WHERE p.enp=g.enp and (g.ds1 LIKE 'C%' OR g.DS1 BETWEEN 'D00' AND 'D09'))

