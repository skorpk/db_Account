USE PlanDD
GO
CREATE PROCEDURE [dbo].[usp_ReportBSSS2]
				@dateEnd DATETIME,
				@reportMonth TINYINT
as
declare @firstDayNextMonth date
---дата актуализации на РЗ
SET @firstDayNextMonth=DATEADD(MONTH,1,'2020'+RIGHT('0'+CAST(@reportMonth AS VARCHAR(2)),2)+'01')

CREATE TABLE #tDiagI(idrow TINYINT,Diagnosis VARCHAR(6), TypeDiag TINYINT)
INSERT #tDiagI(idrow,Diagnosis,TypeDiag)
VALUES(1,'I20.1',1),(2,'I20.8',1),(3,'I20.9',1),(4,'I25.0',1),(5,'I25.1',1),(6,'I25.2',1),(7,'I25.5',1),(8,'I25.6',1),(9,'I25.8',1),(10,'I25.9',1),
(11,'I10',2),(12,'I11',2),(13,'I12',2),(14,'I13',2),(15,'I15',2),(16,'I50.0',1),(17,'I50.1',1),(18,'I50.9',1),(19,'I48',2),(20,'I47',2),(21,'I65.2',1),
(22,'I69.0',1),(23,'I69.1',1),(24,'I69.2',1),(25,'I69.3',1),(26,'I69.4',1),(27,'I67.8',1)


SELECT DISTINCT ENP,@firstDayNextMonth AS dd, 1 AS IsListOfDN, 1 AS ReportMonth,DS AS DS1
	, CASE WHEN CHARINDEX('.',DS)>0 THEN SUBSTRING(DS,0,CHARINDEX('.',DS)) ELSE DS END AS MainDS 
INTO #t 
FROM dbo.DNPersons2020
UNION 
SELECT DISTINCT Enp,@firstDayNextMonth AS dd ,2, ReportMonth,DS1, MainDS FROM dbo.tmp_BSSS2 WHERE DateRegistration<@dateEnd AND ReportMonth<=@reportMonth


ALTER TABLE #t ADD LPU CHAR(6)
ALTER TABLE #t ADD Q CHAR(5)
ALTER TABLE #t ADD PID INT
ALTER TABLE #t ADD [sid] INT
ALTER TABLE #t ADD [lid] INT

CREATE NONCLUSTERED INDEX IX_1 ON #t(ENP) INCLUDE(PID) 

UPDATE e SET PID=p.Id
FROM #t e INNER JOIN PolicyRegister.dbo.PEOPLE p ON
		e.enp=p.ENP

CREATE NONCLUSTERED INDEX IX_2 ON #t(Pid) INCLUDE(dd,sid,lid,lpu,Q)

EXEC Utility.dbo.sp_GetIdPolisLPU

;WITH cte
AS(
SELECT DISTINCT DS1, ENP AS AllENP,NULL AS AprilENP,mainDS FROM #t WHERE [sid] IS NOT NULL
UNION ALL
SELECT DISTINCT d.DS1, NULL,d.ENP,d.MainDS
FROM dbo.tmp_BSSS2 d INNER JOIN #t e ON
			d.ENP=e.enp
WHERE e.[sid] IS NOT NULL AND d.ReportMonth=@reportMonth AND dn=2 
AND NOT EXISTS(SELECT 1 FROM #t tt WHERE tt.enp=e.ENP AND tt.ReportMonth<@reportMonth)
)
SELECT * INTO #tTotal FROM cte e 

;WITH cte
AS(
	SELECT t.AllENP,t.AprilENP,d.idrow,d.Diagnosis
	FROM #tTotal t INNER JOIN #tDiagI d ON
		t.DS1=d.Diagnosis
	WHERE d.TypeDiag=1
	UNION ALL
	SELECT t.AllENP,t.AprilENP,d.idrow,d.Diagnosis
	FROM #tTotal t INNER JOIN #tDiagI d ON
		t.MainDS=d.Diagnosis
	WHERE d.TypeDiag=2
	UNION ALL
	SELECT t.AllENP,t.AprilENP,28,t.DS1
	FROM #tTotal t
	WHERE NOT EXISTS(SELECT 1 FROM #tDiagI d WHERE d.Diagnosis=t.MainDS OR d.Diagnosis=t.DS1)
	UNION ALL--добавляем диагнозы из отчета по которым нет сведений
    SELECT NULL,NULL,d.idrow,d.Diagnosis
	FROM #tDiagI d
	WHERE NOT EXISTS(SELECT 1 FROM #tTotal t WHERE d.Diagnosis=t.MainDS OR d.Diagnosis=t.DS1)
)
SELECT c.idrow,ROW_NUMBER() OVER(ORDER BY c.idrow,c.Diagnosis) AS IdRow2,m.Diagnosis,c.Diagnosis,COUNT(DISTINCT c.AllENP), COUNT(DISTINCT c.AprilENP)
FROM cte c INNER JOIN dbo.vw_sprMKB10 m ON
		c.Diagnosis=m.DiagnosisCode
GROUP BY c.idrow,c.Diagnosis,m.Diagnosis
ORDER BY c.idrow,c.Diagnosis		

DROP TABLE #tDiagI
DROP TABLE #t
DROP TABLE #tTotal
GO