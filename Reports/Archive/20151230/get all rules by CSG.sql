USE AccountOMS
GO
WITH cteCSG 
AS
(
SELECT  ROW_NUMBER() OVER(PARTITION BY step ORDER BY mzCode ) AS id,		
        mzCode ,
        mzName ,
        DS1 ,
        DS2 ,
        sur ,
        surName ,
        age ,
        sex ,
        los ,
        Step
FROM dbo.tmp_CSG_20141226
WHERE step IS NOT null
)
SELECT *
FROM cteCSG WHERE id=1

