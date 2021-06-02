USE AccountOMS
GO
DECLARE @dateStart DATETIME='20200401',
		@dateEnd DATETIME='20201031',
		@dateEndPay DATETIME='20201031',
		@quater TINYINT=3,
		@startMonth TINYINT,
		@endMonth TINYINT
IF(@quater=2)
BEGIN
	SELECT @startMonth=3,@endMonth=7
END
ELSE
begin
	SELECT @startMonth=6,@endMonth=10
end
---обратить внимание на возраст
CREATE TABLE #csg(code varchar(10), typeHardCase TINYINT,PeriodUse TINYINT,crit VARCHAR(5))
INSERT #csg(code,typeHardCase,PeriodUse) VALUES('st12.008.1',1,1),('st12.009.1',1,1),('st23.004.1',2,1),('st12.013.2',3,1),('st12.013.1',4,1)

INSERT #csg(code,typeHardCase,PeriodUse,crit) VALUES('st12.008.1',1,2,null),('st12.009.1',1,2,null),('st23.004.1',1,2,'cr8')
,('st12.013.2',2,2,'cr4'),('st12.013.1',3,2,'cr5'),('st12.013.1',4,2,'cr6')

SELECT DISTINCT c.id AS rf_idCase, f.CodeM, cc.AmountPayment,1 AS TypeRequest,cc.id AS rf_idCompletedCasse,cc.DateBegin,cc.DateEnd,a.ReportMonth,
		CASE WHEN c.rf_idV009 IN(105,106) THEN c.rf_idV009 ELSE NULL END RSLT,DATEDIFF(DAY,cc.DateBegin,cc.DateEnd) as DiffDate,ps.ENP,0 AS IsTypeHardCase
		,c.rf_idRecordCasePatient
INTO #tCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO ps ON
            r.id=ps.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient	
			AND cc.DateEnd>='20200401'									
					INNER JOIN dbo.t_Diagnosis d ON
			c.id=d.rf_idCase					
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2020 AND  a.ReportMonth>@startMonth AND a.ReportMonth<@endMonth AND c.rf_idV006=1
	AND d.TypeDiagnosis IN(1,3) AND d.DiagnosisCode IN('U07.1','U07.2') AND a.rf_idSMO<>'34' AND c.Age BETWEEN 18 AND 65

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
						   FROM dbo.t_PaymentAcceptedCase2 c
						   WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndPay
						   GROUP BY c.rf_idCase
						 ) r ON
			p.rf_idCase=r.rf_idCase

DELETE FROM #tCases WHERE AmountPayment=0
PRINT('Delete')
--1 - легкая, 2-средняя, 3-тяжелая, 4-крайне тяжелая
--ALTER TABLE #tCases ADD IsTypeHardCase TINYINT NOT NULL DEFAULT(0)

UPDATE c SET c.IsTypeHardCase=cc.typeHardCase
FROM #tCases c INNER JOIN dbo.t_MES m ON
		c.rf_idCase=m.rf_idCase
				INNER JOIN #csg cc ON
        m.MES=cc.code
WHERE c.ReportMonth<9 AND cc.PeriodUse=1

UPDATE c SET c.IsTypeHardCase=cc.typeHardCase
FROM #tCases c INNER JOIN dbo.t_MES m ON
		c.rf_idCase=m.rf_idCase
				INNER JOIN dbo.t_AdditionalCriterion a ON
        c.rf_idCase=a.rf_idCase
				INNER JOIN #csg cc ON
        m.MES=cc.code
		AND a.rf_idAddCretiria=cc.crit
WHERE c.ReportMonth>=9 AND cc.PeriodUse=2 AND cc.crit IS NOT NULL

UPDATE c SET c.IsTypeHardCase=cc.typeHardCase
FROM #tCases c INNER JOIN dbo.t_MES m ON
		c.rf_idCase=m.rf_idCase
				INNER JOIN #csg cc ON
        m.MES=cc.code
WHERE c.ReportMonth>=9 AND cc.PeriodUse=2 AND cc.crit IS null

SELECT m.MES,COUNT(DISTINCT c.rf_idCompletedCasse)
FROM #tCases c INNER JOIN dbo.t_MES m ON
		c.rf_idCase=m.rf_idCase
WHERE c.IsTypeHardCase=0 
GROUP BY mes
ORDER BY mes

--SELECT c.*,a.rf_idAddCretiria
--FROM #tCases c INNER JOIN dbo.t_MES m ON
--		c.rf_idCase=m.rf_idCase
--			LEFT JOIN dbo.t_AdditionalCriterion a ON
--        c.rf_idCase=a.rf_idCase
--WHERE c.IsTypeHardCase=0 AND m.MES='st23.004.1'
--ORDER BY mes

--SELECT *
--FROM t_Case
/*
----------------------------Легкая форма--------------------------------------
;WITH cteLight
AS(
SELECT m.MES,COUNT(DISTINCT c.rf_idCompletedCasse) AS Hospitalization
FROM #tCases c INNER JOIN dbo.t_MES m ON
		c.rf_idCase=m.rf_idCase
WHERE mes IN('st12.008.1','st12.009.1')
GROUP BY m.MES
UNION all
SELECT m.MES,COUNT(DISTINCT c.rf_idCompletedCasse)
FROM #tCases c INNER JOIN dbo.t_MES m ON
		c.rf_idCase=m.rf_idCase
				INNER JOIN dbo.t_AdditionalCriterion a ON
        c.rf_idCase=a.rf_idCase
WHERE c.ReportMonth=9 and mes IN('st23.004.1') AND a.rf_idAddCretiria='cr8'
GROUP BY m.MES
)
SELECT 1,l.Mes, SUM(l.Hospitalization) FROM cteLight l GROUP BY l.MES ORDER BY l.MES
----------------------------Средне тяжелая форма--------------------------------------
;WITH cteLight
AS(
SELECT m.MES,COUNT(DISTINCT c.rf_idCompletedCasse) AS Hospitalization
FROM #tCases c INNER JOIN dbo.t_MES m ON
		c.rf_idCase=m.rf_idCase
WHERE mes='st23.004.1' AND c.ReportMonth<9
GROUP BY m.MES
UNION all
SELECT m.MES,COUNT(DISTINCT c.rf_idCompletedCasse)
FROM #tCases c INNER JOIN dbo.t_MES m ON
		c.rf_idCase=m.rf_idCase
				INNER JOIN dbo.t_AdditionalCriterion a ON
        c.rf_idCase=a.rf_idCase
WHERE c.ReportMonth=9 and mes ='st12.013.2' AND a.rf_idAddCretiria='cr4'
GROUP BY m.MES
)
SELECT 2,l.Mes, SUM(l.Hospitalization) FROM cteLight l GROUP BY l.MES ORDER BY l.MES
----------------------------тяжелая форма--------------------------------------
;WITH cteLight
AS(
SELECT m.MES,COUNT(DISTINCT c.rf_idCompletedCasse) AS Hospitalization
FROM #tCases c INNER JOIN dbo.t_MES m ON
		c.rf_idCase=m.rf_idCase
WHERE mes='st12.013.2' AND c.ReportMonth<9
GROUP BY m.MES
UNION all
SELECT m.MES,COUNT(DISTINCT c.rf_idCompletedCasse)
FROM #tCases c INNER JOIN dbo.t_MES m ON
		c.rf_idCase=m.rf_idCase
				INNER JOIN dbo.t_AdditionalCriterion a ON
        c.rf_idCase=a.rf_idCase
WHERE c.ReportMonth=9 and mes ='st12.013.1' AND a.rf_idAddCretiria='cr5'
GROUP BY m.MES
)
SELECT 3,l.Mes, SUM(l.Hospitalization) FROM cteLight l GROUP BY l.MES ORDER BY l.MES
----------------------------крайне тяжелая форма--------------------------------------
;WITH cteLight
AS(
SELECT m.MES,COUNT(DISTINCT c.rf_idCompletedCasse) AS Hospitalization
FROM #tCases c INNER JOIN dbo.t_MES m ON
		c.rf_idCase=m.rf_idCase
WHERE mes='st12.013.1' AND c.ReportMonth<9
GROUP BY m.MES
UNION all
SELECT m.MES,COUNT(DISTINCT c.rf_idCompletedCasse)
FROM #tCases c INNER JOIN dbo.t_MES m ON
		c.rf_idCase=m.rf_idCase
				INNER JOIN dbo.t_AdditionalCriterion a ON
        c.rf_idCase=a.rf_idCase
WHERE c.ReportMonth=9 and mes ='st12.013.1' AND a.rf_idAddCretiria='cr6'
GROUP BY m.MES
)
SELECT 4,l.Mes, SUM(l.Hospitalization) FROM cteLight l GROUP BY l.MES ORDER BY l.MES
--------------------
SELECT IsTypeHardCase,COUNT(rf_idCompletedCasse) FROM #tCases GROUP BY IsTypeHardCase ORDER BY IsTypeHardCase
*/
GO
DROP TABLE #tCases
GO
DROP TABLE #csg