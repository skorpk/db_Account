USE AccountOMS
GO
DECLARE @dateStartReg DATETIME='20200409',
		@dateEndReg DATETIME='20200516',
		@dateStartRegRAK DATETIME='20200409',
		@dateEndRegRAK DATETIME='20200516',
		@reportYear SMALLINT=2020,
		@reportMonth TINYINT=5


SELECT 1 AS TypeDiag,DiagnosisCode INTO #tDiag FROM dbo.vw_sprMKB10 WHERE MainDS BETWEEN 'J12' AND 'J18'

INSERT #tDiag(TypeDiag,DiagnosisCode) VALUES(1,'Z03.8'),(1,'Z22.8'),(1,'Z20.8'),(1,'Z11.5'),(1,'B34.2'),(1,'B33.8'),(1,'U07.1'),(1,'U07.2')
			,(2,'Z20.8'),(2,'B34.2'),(2,'U07.1'),(2,'U07.2')
CREATE UNIQUE NONCLUSTERED INDEX IX_Diag ON #tDiag(DiagnosisCode,TypeDiag)


SELECT DISTINCT cc.id,c.id AS rf_idCase,cc.AmountPayment,c.rf_idv008,f.CodeM, 1 AS TypeCase
,CASE WHEN dd.DiagnosisCode LIKE 'U%' THEN 1 ELSE NULL END IsCOVID, a.rf_idSMO, a.rf_idMO	
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
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND a.ReportMonth=@reportMonth AND dd.TypeDiagnosis IN(1,3)
AND c.rf_idV006=4 AND EXISTS(SELECT 1 FROM #tDiag d WHERE d.DiagnosisCode=dd.DiagnosisCode) 

CREATE UNIQUE NONCLUSTERED INDEX IX_1 ON #tCases(rf_idCase) WITH IGNORE_DUP_KEY

INSERT #tCases
SELECT DISTINCT cc.id,c.id AS rf_idCase,cc.AmountPayment,c.rf_idv008,f.CodeM, 2 AS TypeCase,NULL as IsCOVID, a.rf_idSMO,a.rf_idMO
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
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND a.ReportMonth=@reportMonth AND dd.TypeDiagnosis IN(1,3)
AND c.rf_idV006=4 AND NOT EXISTS(SELECT 1 FROM #tDiag d WHERE d.DiagnosisCode=dd.DiagnosisCode)


UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c 											
								WHERE c.DateRegistration>=@dateStartRegRAK AND c.DateRegistration<@dateEndRegRAK
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
-----------------------------------------------2019--------------------------
SELECT DISTINCT cc.id,c.id AS rf_idCase,cc.AmountPayment,c.rf_idv008,f.CodeM, 1 AS TypeCase
,CASE WHEN dd.DiagnosisCode LIKE 'U%' THEN 1 ELSE NULL END IsCOVID, a.rf_idSMO,a.rf_idMO	
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
WHERE f.DateRegistration>='20190401' AND f.DateRegistration<'20200118'  AND a.ReportYear=2019 AND a.ReportMonth=@reportMonth AND dd.TypeDiagnosis IN(1,3)
AND c.rf_idV006=4 AND EXISTS(SELECT 1 FROM #tDiag d WHERE d.DiagnosisCode=dd.DiagnosisCode ) 

CREATE UNIQUE NONCLUSTERED INDEX IX_3 ON #tCases2019(rf_idCase) WITH IGNORE_DUP_KEY

INSERT #tCases2019
SELECT DISTINCT cc.id,c.id AS rf_idCase,cc.AmountPayment,c.rf_idv008,f.CodeM, 2 AS TypeCase,NULL as IsCOVID, a.rf_idSMO,a.rf_idMO	
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
WHERE f.DateRegistration>='20190401' AND f.DateRegistration<'20200118'  AND a.ReportYear=2019 AND a.ReportMonth=@reportMonth AND dd.TypeDiagnosis IN(1,3)
AND c.rf_idV006=4 AND NOT EXISTS(SELECT 1 FROM #tDiag d WHERE d.DiagnosisCode=dd.DiagnosisCode) 

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases2019 p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c 											
								WHERE c.DateRegistration>='20190401' AND c.DateRegistration<'20200121'
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
---------------------------------------------------------------------------------------
;WITH c
AS(
SELECT 1 AS IdRow,'5.1' AS ColName,rf_idMO AS MCOD,0 AS Col1,NULL AS Col2,0.0 AS Col4
    ,CASE WHEN AmountPayment=0.0 AND TypeCase=1 AND rf_idSMO<>'34' THEN rf_idCase ELSE NULL END AS Col5
	,CASE WHEN rf_idSMO='34' AND TypeCase=1 AND AmountPayment>0 THEN rf_idCase ELSE NULL END AS Col6
	,CASE WHEN AmountPayment=0.0 AND TypeCase=1 AND rf_idSMO<>'34' THEN 2428.3 ELSE 0.0 END AS Col7
	,CASE WHEN rf_idSMO='34' AND TypeCase=1 THEN AmountPayment ELSE 0.0 END AS Col8
FROM #tCases
UNION ALL
SELECT 2 AS IdRow,'5.1.1',rf_idMO,0 AS Col1,NULL AS Col2,0.0 AS Col4,CASE WHEN AmountPayment=0.0 AND TypeCase=1 AND IsCOVID=1 AND rf_idSMO<>'34' THEN rf_idCase ELSE NULL END AS Col5
	,CASE WHEN rf_idSMO='34' AND TypeCase=1 AND AmountPayment>0 AND IsCOVID=1 THEN rf_idCase ELSE NULL END AS Col6
	,CASE WHEN AmountPayment=0.0 AND TypeCase=1 AND IsCOVID=1 AND rf_idSMO<>'34' THEN 2428.3 ELSE 0.0 END AS Col7
	,CASE WHEN rf_idSMO='34' AND TypeCase=1 AND IsCOVID=1 THEN AmountPayment ELSE 0.0 END AS Col8
FROM #tCases
UNION ALL
SELECT 3 AS IdRow,'5.2',rf_idMO,0 AS Col1,NULL AS Col2,0.0 AS Col4
	,CASE WHEN AmountPayment=0.0 AND TypeCase=2 AND rf_idSMO<>'34' THEN rf_idCase ELSE NULL END AS Col5
	,CASE WHEN rf_idSMO='34' AND TypeCase=2 AND AmountPayment>0 THEN rf_idCase ELSE NULL END AS Col6
	,CASE WHEN TypeCase=2 AND rf_idSMO<>'34' THEN AmountPayment ELSE 0.0 END AS Col7
	,CASE WHEN rf_idSMO='34' AND TypeCase=2 THEN AmountPayment ELSE 0.0 END AS Col8
FROM #tCases 
UNION all
SELECT 3 AS IdRow,'5.2',l.mcod,0 AS Col1,NULL AS Col2,0.0 AS Col4,NULL AS Col5,NULL AS Col6,AmountPayment,0.0 AS Col8
FROM dbo.t_AdditionalAccounts202003 a INNER JOIN dbo.vw_sprT001 l ON
		a.CodeLPU=l.CodeM
WHERE ReportYearMonth=202005 AND a.rf_idV006=4 
UNION ALL --отнимаем сумму по случаям ковида
SELECT 3 AS IdRow,'5.2' AS ColName,rf_idMO AS MCOD,0 AS Col1,NULL AS Col2,0.0 AS Col4
    ,null AS Col5,NULL AS Col6
	,CASE WHEN AmountPayment=0.0 AND TypeCase=1 AND rf_idSMO<>'34' THEN -2428.3 ELSE 0.0 END AS Col7,0.0
FROM #tCases
----------------------2019---------------------------------------------
UNION all
SELECT 1 AS IdRow,'5.1',rf_idMO,0 AS Col1,CASE WHEN rf_idSMO='34' and TypeCase=1 THEN rf_idCase ELSE NULL END AS Col2
		,CASE WHEN TypeCase=1 AND rf_idSMO='34' THEN AmountPayment ELSE 0.0 END AS Col4,NULL, NULL,0.0,0.0	
FROM #tCases2019
WHERE AmountPayment>0
UNION all
SELECT 3 AS IdRow,'5.2',rf_idMO,0 AS Col1,CASE WHEN rf_idSMO='34' and TypeCase=2 THEN rf_idCase ELSE NULL END AS Col2
		,CASE WHEN TypeCase=2 AND rf_idSMO='34' THEN AmountPayment ELSE 0.0 END AS Col4,NULL, NULL,0.0,0.0	
FROM #tCases2019
WHERE AmountPayment>0
UNION ALL
SELECT 3 AS IdRow,'5.2',p.mcod,CAST(p.rate AS INT),NULL Col2,0.0 AS Col4,NULL, NULL,0.0,0.0	
FROM oms_nsi.dbo.plan2020 p
WHERE unitCode='26'
)
SELECT c.IdRow,l.mcod,l.NAMES AS LPU,c.ColName,
       CAST(SUM(c.Col1) AS INt) AS Col1,COUNT(c.Col2) AS Col2,CAST(SUM(c.Col4) AS money) AS Col4
	   ,COUNT(c.Col5) AS Col5,COUNT(c.Col6) AS Col6,CAST(SUM(c.Col7) AS money) AS Col7,CAST(SUM(c.Col8) AS money) AS Col8
FROM c c INNER JOIN dbo.vw_sprT001 l ON
		c.MCOD=l.MCOD
GROUP BY c.IdRow,c.ColName,l.mcod,l.NAMES 
ORDER BY l.mcod,c.IdRow
GO
DROP TABLE #tCases
GO
DROP TABLE #tCases2019
GO
DROP TABLE #tDiag