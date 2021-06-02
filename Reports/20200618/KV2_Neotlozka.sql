USE AccountOMS
GO
DECLARE @dateStartReg DATETIME='20200501',
		@dateEndReg DATETIME='20200616',
		@dateStartRegRAK DATETIME='20200501',
		@dateEndRegRAK DATETIME='20200616',
		@reportYear SMALLINT=2020,
		@reportMonth TINYINT=5


SELECT 1 AS TypeDiag,DiagnosisCode INTO #tDiag FROM dbo.vw_sprMKB10 WHERE MainDS BETWEEN 'J12' AND 'J18'

INSERT #tDiag(TypeDiag,DiagnosisCode) VALUES(1,'Z03.8'),(1,'Z22.8'),(1,'Z20.8'),(1,'Z11.5'),(1,'B34.2'),(1,'B33.8'),(1,'U07.1'),(1,'U07.2')
			,(3,'Z20.8'),(3,'B34.2'),(3,'U07.1'),(3,'U07.2')
CREATE UNIQUE NONCLUSTERED INDEX IX_Diag ON #tDiag(DiagnosisCode,TypeDiag)

SELECT cc.id,c.id AS rf_idCase,cc.AmountPayment,c.rf_idv002,f.CodeM,a.rf_idSMO, a.rf_idMO
	,COUNT(CASE WHEN dd.DiagnosisCode LIKE 'U%' THEN 1 ELSE NULL END) IsCOVID,1 AS TypeP
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
					INNER JOIN dbo.t_Meduslugi m ON
            m.rf_idCase = c.id
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND a.ReportMonth=@reportMonth
AND c.rf_idV006=3 AND m.MUGroupCode=2 AND m.MUUnGroupCode IN(80,82) AND a.Letter='J' AND dd.TypeDiagnosis IN(1,3) 
		AND EXISTS(SELECT 1 FROM #tDiag d WHERE d.DiagnosisCode=dd.DiagnosisCode AND d.TypeDiag=dd.TypeDiagnosis)
GROUP BY cc.id,c.id ,cc.AmountPayment,c.rf_idv002,f.CodeM,a.rf_idSMO, a.rf_idMO		 

CREATE UNIQUE NONCLUSTERED INDEX ix_1 ON #tCases(rf_idCase) WITH IGNORE_DUP_KEY
INSERT #tCases
SELECT DISTINCT cc.id,c.id AS rf_idCase,cc.AmountPayment,c.rf_idv002,f.CodeM,a.rf_idSMO, a.rf_idMO, NULL IsCOVID,2 AS TypeP
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
					INNER JOIN dbo.t_Meduslugi m ON
            m.rf_idCase = c.id
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND a.ReportMonth=@reportMonth
AND c.rf_idV006=3 AND m.MUGroupCode=2 AND m.MUUnGroupCode IN(80,82) AND dd.TypeDiagnosis IN(1,3)
AND NOT EXISTS (SELECT 1 FROM #tDiag d WHERE d.DiagnosisCode=dd.DiagnosisCode AND d.TypeDiag=dd.TypeDiagnosis) 

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c 											
								WHERE c.DateRegistration>=@dateStartRegRAK AND c.DateRegistration<@dateEndRegRAK
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
--------------------------2019---------------------------------
SELECT cc.id,c.id AS rf_idCase,cc.AmountPayment,c.rf_idv002,f.CodeM,a.rf_idSMO, a.rf_idMO
	,COUNT(CASE WHEN dd.DiagnosisCode LIKE 'U%' THEN 1 ELSE NULL END) IsCOVID,1 AS TypeP
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
					INNER JOIN dbo.t_Meduslugi m ON
            m.rf_idCase = c.id
WHERE f.DateRegistration>='20190401' AND f.DateRegistration<'20200118'  AND a.ReportYear=2019 AND a.ReportMonth=@reportMonth AND c.rf_idV006=3 AND m.MUGroupCode=2 AND m.MUUnGroupCode IN(80,82) AND a.Letter='J' AND dd.TypeDiagnosis IN(1,3)
	AND EXISTS(SELECT 1 FROM #tDiag d WHERE d.DiagnosisCode=dd.DiagnosisCode AND d.TypeDiag=dd.TypeDiagnosis) 
GROUP BY cc.id,c.id ,cc.AmountPayment,c.rf_idv002,f.CodeM,a.rf_idSMO, a.rf_idMO		 

INSERT #tCases2019
SELECT DISTINCT cc.id,c.id AS rf_idCase,cc.AmountPayment,c.rf_idv002,f.CodeM,a.rf_idSMO, a.rf_idMO, NULL IsCOVID,2 AS TypeP
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
					INNER JOIN dbo.t_Meduslugi m ON
            m.rf_idCase = c.id
WHERE f.DateRegistration>='20190401' AND f.DateRegistration<'20200118'  AND a.ReportYear=2019 AND a.ReportMonth=@reportMonth AND c.rf_idV006=3 AND m.MUGroupCode=2 AND m.MUUnGroupCode IN(80,82) AND a.Letter='J' AND dd.TypeDiagnosis IN(1,3)
	AND NOT EXISTS(SELECT 1 FROM #tDiag d WHERE d.DiagnosisCode=dd.DiagnosisCode AND d.TypeDiag=dd.TypeDiagnosis) 

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases2019 p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c 											
								WHERE c.DateRegistration>='20190401' AND c.DateRegistration<'20200121'
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

--------------------------Фактическое----------------------
;WITH cte
AS(
SELECT DISTINCT 1 AS IdRow,'2.3.1' AS ColName,rf_idMO AS MCOD,0 AS Col1,NULL AS Col2,0.0 AS Col4
    ,CASE WHEN rf_idSMO<>'34' THEN id ELSE NULL END AS Col5
	,CASE WHEN rf_idSMO='34' THEN id ELSE NULL END AS Col6
	,CASE WHEN rf_idSMO<>'34' THEN AmountPayment ELSE 0.0 END AS Col7
	,CASE WHEN rf_idSMO='34' THEN AmountPayment ELSE 0.0 END AS Col8
FROM #tCases
WHERE AmountPayment>0 AND TypeP=1
UNION all
SELECT DISTINCT 2 AS IdRow,'2.3.1.1' AS ColName,rf_idMO AS MCOD,0 AS Col1,NULL AS Col2,0.0 AS Col4
    ,CASE WHEN rf_idSMO<>'34' THEN id ELSE NULL END AS Col5
	,CASE WHEN rf_idSMO='34' THEN id ELSE NULL END AS Col6
	,CASE WHEN rf_idSMO<>'34' THEN AmountPayment ELSE 0.0 END AS Col7
	,CASE WHEN rf_idSMO='34' THEN AmountPayment ELSE 0.0 END AS Col8
FROM #tCases
WHERE AmountPayment>0 AND IsCOVID=1 AND TypeP=1
UNION ALL
SELECT DISTINCT 3 AS IdRow,'2.3.2' AS ColName,rf_idMO AS MCOD,0 AS Col1,NULL AS Col2,0.0 AS Col4
    ,CASE WHEN rf_idSMO<>'34' THEN id ELSE NULL END AS Col5
	,CASE WHEN rf_idSMO='34' THEN id ELSE NULL END AS Col6
	,CASE WHEN rf_idSMO<>'34' THEN AmountPayment ELSE 0.0 END AS Col7
	,CASE WHEN rf_idSMO='34' THEN AmountPayment ELSE 0.0 END AS Col8
FROM #tCases
WHERE AmountPayment>0 AND TypeP=2
---------------------2019---------------------------------
UNION ALL
SELECT DISTINCT 1 AS IdRow,'2.3.1' AS ColName,rf_idMO AS MCOD,0 AS Col1
	,CASE WHEN rf_idSMO='34' THEN id ELSE NULL END AS Col2
	,CASE WHEN rf_idSMO='34' THEN AmountPayment ELSE 0.0 END AS Col4
    ,NULL AS Col5,NULL AS Col6,0.0 AS Col7,0.0 AS Col8
FROM #tCases2019
WHERE AmountPayment>0 AND TypeP=1
UNION all
SELECT DISTINCT 2 AS IdRow,'2.3.1.1' AS ColName,rf_idMO AS MCOD,0 AS Col1
	,CASE WHEN rf_idSMO='34' THEN id ELSE NULL END AS Col2
	,CASE WHEN rf_idSMO='34' THEN AmountPayment ELSE 0.0 END AS Col4
    ,NULL AS Col5,NULL AS Col6,0.0 AS Col7,0.0 AS Col8
FROM #tCases2019
WHERE AmountPayment>0 AND IsCOVID=1 AND TypeP=1
UNION ALL
SELECT DISTINCT 3 AS IdRow,'2.3.2' AS ColName,rf_idMO AS MCOD,0 AS Col1
	,CASE WHEN rf_idSMO='34' THEN id ELSE NULL END AS Col2
	,CASE WHEN rf_idSMO='34' THEN AmountPayment ELSE 0.0 END AS Col4
    ,NULL AS Col5,NULL AS Col6,0.0 AS Col7,0.0 AS Col8
FROM #tCases2019
WHERE AmountPayment>0 AND TypeP=2
UNION all
-----------------RATE-----------------------
SELECT 3 AS IdRow,'2.3.2',p.mcod,CAST(p.rate AS INT),NULL Col2,0.0 AS Col4,NULL, NULL,0.0,0.0	
FROM oms_nsi.dbo.plan2020 p
WHERE unitCode IN('31','146')
)
SELECT c.IdRow,l.mcod,l.LPU_Mcode AS LPU,c.ColName,
       CAST(SUM(c.Col1) AS INt) AS Col1,COUNT(c.Col2) AS Col2
	   ,CAST(cast(SUM(c.Col4)/1000.0 as decimal(15,2)) AS money) AS Col4
	   ,COUNT(DISTINCT c.Col5) AS Col5,COUNT(c.Col6) AS Col6
	   ,CAST(cast(SUM(c.Col7)/1000.0 as decimal(15,2)) AS money) AS Col7
	   ,CAST(cast(SUM(c.Col8)/1000.0 as decimal(15,2)) AS money) AS Col8
FROM cte c INNER JOIN (SELECT DISTINCT mcod,LPU_Mcode FROM dbo.vw_sprT001) l ON
		c.MCOD=l.MCOD
GROUP BY c.IdRow,c.ColName,l.mcod,l.LPU_Mcode
ORDER BY l.mcod,c.IdRow
GO
DROP TABLE #tCases
GO
DROP TABLE #tCases2019
GO
DROP TABLE #tDiag
