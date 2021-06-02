USE AccountOMS
GO
------------------јмбулаторна€ помощь(помощь)----------------------
DECLARE @dateStartReg DATETIME='20200801',
		@dateEndReg DATETIME='20200916',
		@dateStartRegRAK DATETIME='20200801',
		@dateEndRegRAK DATETIME='20200916',
		@reportYear SMALLINT=2020,
		@reportMonth TINYINT=8

DECLARE @reportPeriod INT=202007
---таблица с параметрами. —делана дл€ того что бы объ€вить только тут и потом не прописывать параметры каждый раз

SELECT 1 AS TypeDiag,DiagnosisCode INTO #tDiag FROM dbo.vw_sprMKB10 WHERE MainDS BETWEEN 'J12' AND 'J18'

INSERT #tDiag(TypeDiag,DiagnosisCode) VALUES(1,'Z03.8'),(1,'Z22.8'),(1,'Z20.8'),(1,'Z11.5'),(1,'B34.2'),(1,'B33.8'),(1,'U07.1'),(1,'U07.2')
			,(3,'Z20.8'),(3,'B34.2'),(3,'U07.1'),(3,'U07.2')
CREATE UNIQUE NONCLUSTERED INDEX IX_Diag ON #tDiag(DiagnosisCode,TypeDiag)

SELECT DiagnosisCode INTO #tDiagOnk FROM dbo.vw_sprMKB10 WHERE MainDS BETWEEN 'C00' AND 'C97'
UNION ALL
SELECT DiagnosisCode FROM dbo.vw_sprMKB10 WHERE MainDS BETWEEN 'D00' AND 'D09'


SELECT DISTINCT cc.id,c.id AS rf_idCase,cc.AmountPayment,c.rf_idv002,f.CodeM
	,CASE WHEN dd.TypeDiagnosis=1 THEN dd.DiagnosisCode ELSE NULL END as DS1, 
		CASE WHEN dd.TypeDiagnosis=3 THEN dd.DiagnosisCode ELSE NULL END as DS2, a.rf_idSMO, a.rf_idMO	
	,CASE WHEN dd.DiagnosisCode LIKE 'U%' THEN 1 ELSE 0 END AS IsCovid, c.rf_idV014
INTO #tCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_CompletedCase cc ON
            r.id=cc.rf_idRecordCasePatient
					INNER JOIN dbo.t_Diagnosis dd ON
			c.id=dd.rf_idCase						
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear  AND a.ReportMonth=@reportMonth
AND c.rf_idV006=1 

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c 											
								WHERE c.DateRegistration>=@dateStartRegRAK AND c.DateRegistration<@dateEndRegRAK
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
-------------------------------------------2019------------------------------------

SELECT DISTINCT cc.id,c.id AS rf_idCase,cc.AmountPayment,c.rf_idv002,f.CodeM
	,CASE WHEN dd.TypeDiagnosis=1 THEN dd.DiagnosisCode ELSE NULL END as DS1, 
		CASE WHEN dd.TypeDiagnosis=3 THEN dd.DiagnosisCode ELSE NULL END as DS2, a.rf_idSMO, a.rf_idMO	
	,CASE WHEN dd.DiagnosisCode LIKE 'U%' THEN 1 ELSE 0 END AS IsCovid, c.rf_idV014
INTO #tCases2019
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_CompletedCase cc ON
            r.id=cc.rf_idRecordCasePatient
					INNER JOIN dbo.t_Diagnosis dd ON
			c.id=dd.rf_idCase						
WHERE f.DateRegistration>='20190401' AND f.DateRegistration<'20200118'  AND a.ReportYear=2019 AND a.ReportMonth=@reportMonth 
AND c.rf_idV006=1

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases2019 p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c 											
								WHERE c.DateRegistration>='20190401' AND c.DateRegistration<'20200121'
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
-----------------------------------------------
SELECT  COUNT(DISTINCT CASE WHEN c.rf_idSMO<>'34' THEN c.id ELSE NULL END) AS Col5
		,COUNT(DISTINCT CASE WHEN c.rf_idSMO='34' THEN c.id ELSE NULL END )AS Col6
		,sum(CASE WHEN c.rf_idSMO<>'34' THEN c.AmountPayment ELSE 0.0 END ) AS Col7
		,sum(CASE WHEN c.rf_idSMO='34' THEN c.AmountPayment ELSE 0.0  END ) AS Col8
FROM (
		SELECT distinct rf_idSMO,id,AmountPayment 
		FROM #tCases c 
		) c 
WHERE AmountPayment>0

SELECT COUNT(DISTINCT c.rf_idCase) 
FROM #tCases c INNER JOIN #tDiagOnk d ON
		c.DS1=d.DiagnosisCode
WHERE c.rf_idSMO<>'34' AND c.AmountPayment>0


SELECT c.id
FROM(
	SELECT DISTINCT c.rf_idMO,c.id,c.AmountPayment,rf_idSMO
	FROM #tCases c INNER JOIN #tDiag d ON
			c.DS1=d.DiagnosisCode
	WHERE AmountPayment>0 AND d.TypeDiag=1
	union
	SELECT DISTINCT c.rf_idMO,c.id,c.AmountPayment,rf_idSMO
	FROM #tCases c INNER JOIN #tDiag d ON
			c.DS2=d.DiagnosisCode
	WHERE AmountPayment>0 AND d.TypeDiag=3
	GROUP BY c.rf_idMO,c.id,c.AmountPayment,rf_idSMO
) c
WHERE c.rf_idSMO<>'34'
GROUP BY id HAVING COUNT(*)>1



SELECT distinct c.rf_idCase
INTO #tmpCase_33
FROM #tCases c INNER JOIN #tDiagOnk d ON
		c.DS1=d.DiagnosisCode
WHERE AmountPayment>0
UNION ALL
SELECT DISTINCT c.rf_idCase
FROM(
	SELECT c.rf_idCase
	FROM #tCases c INNER JOIN #tDiag d ON
			c.DS1=d.DiagnosisCode
	WHERE AmountPayment>0 AND d.TypeDiag=1
	GROUP BY c.rf_idCase
	union
	SELECT c.rf_idCase
	FROM #tCases c INNER JOIN #tDiag d ON
			c.DS2=d.DiagnosisCode
	WHERE AmountPayment>0 AND d.TypeDiag=3
	GROUP BY c.rf_idCase
) c

SELECT c.rf_idCase
INTO #tmpCase_33_2019
FROM #tCases2019 c INNER JOIN #tDiagOnk d ON
		c.DS1=d.DiagnosisCode
WHERE AmountPayment>0
UNION ALL
SELECT DISTINCT c.rf_idCase
FROM(
	SELECT c.rf_idCase
	FROM #tCases2019 c INNER JOIN #tDiag d ON
			c.DS1=d.DiagnosisCode
	WHERE AmountPayment>0 AND d.TypeDiag=1
	GROUP BY c.rf_idCase
	union
	SELECT c.rf_idCase
	FROM #tCases2019 c INNER JOIN #tDiag d ON
			c.DS2=d.DiagnosisCode
	WHERE AmountPayment>0 AND d.TypeDiag=3
	GROUP BY c.rf_idCase
) c

------------------------------------------------------------------------------------------
;WITH cte
AS(
-------------------------ƒубли------------------
SELECT DISTINCT 1 AS IdRow,c.rf_idMO AS MCOD,'3.1' AS ColName,0 AS Col1,NULL AS Col2,0.0 AS Col4
		,C.id
FROM #tCases c INNER JOIN #tDiagOnk d ON
		c.DS1=d.DiagnosisCode
WHERE AmountPayment>0 AND c.rf_idSMO<>'34'
UNION ALL
SELECT DISTINCT 2 AS IdRow,c.rf_idMO AS MCOD,'3.2' AS ColName,0 AS Col1,NULL AS Col2,0.0 AS Col4
		,c.id
FROM(
	SELECT DISTINCT c.rf_idMO,c.id,c.AmountPayment,rf_idSMO
	FROM #tCases c INNER JOIN #tDiag d ON
			c.DS1=d.DiagnosisCode
	WHERE AmountPayment>0 AND d.TypeDiag=1 AND c.rf_idSMO<>'34'
	union
	SELECT DISTINCT c.rf_idMO,c.id,c.AmountPayment,rf_idSMO
	FROM #tCases c INNER JOIN #tDiag d ON
			c.DS2=d.DiagnosisCode
	WHERE AmountPayment>0 AND d.TypeDiag=3 AND c.rf_idSMO<>'34' AND NOT EXISTS(SELECT 1 FROM #tDiagOnk WHERE DiagnosisCode=c.DS1)
	GROUP BY c.rf_idMO,c.id,c.AmountPayment,rf_idSMO
) c
UNION ALL
SELECT DISTINCT 5 AS IdRow,c.rf_idMO AS MCOD,'3.3' AS ColName,0 AS Col1,NULL AS Col2,0.0 AS Col4
		,c.id
FROM #tCases c 
WHERE AmountPayment>0 AND c.rf_idV014 IN (1,2) AND NOT EXISTS(SELECT 1 FROM #tmpCase_33 z WHERE z.rf_idCase=c.rf_idCase) AND c.rf_idSMO<>'34'
UNION ALL
SELECT DISTINCT 6 AS IdRow,c.rf_idMO AS MCOD,'3.4' AS ColName,0 AS Col1,NULL AS Col2,0.0 AS Col4
		,c.id
FROM #tCases c 
WHERE AmountPayment>0 AND c.rf_idV014 =3 AND NOT EXISTS(SELECT 1 FROM #tmpCase_33 cc WHERE cc.rf_idCase=c.rf_idCase) AND c.rf_idSMO<>'34'
)
SELECT id
FROM cte c GROUP BY id HAVING COUNT(*)>1




go

-------------------”дал€ем таблицы которые участвуют в формировании данных дл€ стационара-----------------------
DROP TABLE #tCases
go
DROP TABLE #tmpCase_33_2019
go
DROP TABLE #tmpCase_33
go
DROP TABLE #tCases2019
go
DROP TABLE #tDiagOnk
go
DROP TABLE #tDiag
GO
