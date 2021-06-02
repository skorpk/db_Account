USE AccountOMS
GO

SELECT *
--UPDATE t SET t.step=11
FROM dbo.tmp_CSG2016 t
WHERE Step IS NULL AND 
	  DS1 IS NOT NULL AND 
	  DS2 IS NOT NULL AND 
	  Sur IS NULL AND 
	  Sex IS NULL AND 
	  Age IS NULL AND
	  LOS IS NULL  

--SELECT * FROM dbo.tmp_CSG2016 WHERE Step=7
/*
;WITH cte_OLDCSG 
AS
(
SELECT  t.mzCode ,
        t.mzName ,
        t.DS1 ,
        t.DS2 ,
        t.sur ,
        t.surName ,
		CAST(a.newCode AS TINYINT) AS Age,
        t.sex ,
        t.los ,
        t.Step
FROM dbo.tmp_CSG_20141226 t inner JOIN [SRVSQL1-ST2].oms_NSI.dbo.tCSGAge a ON
				t.age=CAST(a.Code AS TINYINT)
UNION ALL
SELECT  t.mzCode ,
        t.mzName ,
        t.DS1 ,
        t.DS2 ,
        t.sur ,
        t.surName ,
        t.age ,		
        t.sex ,
        t.los ,
        t.Step
FROM dbo.tmp_CSG_20141226 t WHERE age IS null
)
UPDATE t SET t.Step=t1.step
FROM cte_OLDCSG	t1 INNER JOIN dbo.tmp_CSG2016 t on
		    ISNULL(t.DS1,'bla-bla') = ISNULL(t1.DS1,'bla-bla')  
		AND ISNULL(t.DS2,'bla-bla') = ISNULL(t1.DS2,'bla-bla')  
		AND isnull(t.Sur,'bla-bla') = isnull(t1.Sur,'bla-bla') 
		AND isnull(t.Age,0) = isnull(t1.Age,0) 
		AND isnull(t.Sex,'bla-bla') = isnull(t1.Sex,'bla-bla') 
		AND isnull(t.LOS,0) = isnull(t1.LOS,0)
*/