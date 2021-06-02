USE PlanDD
GO
alter PROCEDURE usp_ReportDispObservation_I
				@dateEnd DATETIME,
				@reportMonth TINYINT
as
declare @firstDayNextMonth date
---дата актуализации на РЗ
SET @firstDayNextMonth=DATEADD(MONTH,1,'2020'+RIGHT('0'+CAST(@reportMonth AS VARCHAR(2)),2)+'01')

SELECT DISTINCT ENP,@firstDayNextMonth AS dd, 1 AS IsListOfDN, 1 AS ReportMonth INTO #t FROM dbo.DNPersons2020
UNION 
SELECT DISTINCT Enp,@firstDayNextMonth AS dd ,2, ReportMonth FROM dbo.tmp_DN_I WHERE DateRegistration<@dateEnd AND ReportMonth<=@reportMonth

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

--SELECT *
--FROM tmp_ENP_AttachLPU t
--WHERE NOT EXISTS(SELECT 1 FROM #t e WHERE [sid] IS NOT NULL and t.Enp=e.enp)


;WITH cte
AS(
SELECT DISTINCT LPU, ENP AS AllENP,NULL AS AprilENP FROM #t WHERE [sid] IS NOT NULL
UNION ALL
SELECT DISTINCT e.LPU, NULL,d.ENP 
FROM dbo.tmp_DN_I d INNER JOIN #t e ON
			d.ENP=e.enp
WHERE e.[sid] IS NOT NULL AND d.ReportMonth=@reportMonth AND dn=2 
AND NOT EXISTS(SELECT 1 FROM #t tt WHERE tt.enp=e.ENP AND tt.ReportMonth<@reportMonth)
)
SELECT e.LPU,l.NAMES, COUNT(DISTINCT e.AllENP) AS Col3, COUNT(e.AprilENP) AS Col4
FROM cte e INNER JOIN Consultation_NMRC.dbo.vw_sprT001 l ON
             e.LPU=l.CodeM
GROUP BY e.LPU,l.NAMES

DROP TABLE #t
GO
