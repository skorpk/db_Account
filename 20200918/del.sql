USE AccountOMS
GO
SELECT TOP 6510 p.id,enp
INTO #t
FROM dbo.tmpPeopleDN_2020 p 
WHERE p.idRow=1 AND (p.ds1 LIKE 'C%' OR p.DS1 BETWEEN 'D00' AND 'D09') AND Col9 IS NULL AND sid IS NOT NULL
	AND NOT EXISTS(SELECT 1 FROM dbo.tmpPeopleDN_2020 pp WHERE pp.idRow>1  AND pp.enp=p.enp AND pp.DS1 LIKE 'C%' AND p.MainDS=pp.MainDS)

UPDATE p SET p.idRow=null
from dbo.tmpPeopleDN_2020 p INNER JOIN #t t ON
			p.id=t.id

UPDATE p SET idrow=null
FROM dbo.tmpPeopleDN_2020 p 
WHERE p.idRow=1 AND (p.ds1 LIKE 'C%' OR p.DS1 BETWEEN 'D00' AND 'D09') AND Col9 IS NULL AND sid IS NOT null
	AND NOT EXISTS(SELECT 1 FROM tmpOnkologia2020_GOOD g WHERE p.enp=g.enp)