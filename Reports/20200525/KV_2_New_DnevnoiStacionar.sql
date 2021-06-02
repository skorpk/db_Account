USE AccountOMS
GO
DECLARE @dateStartReg DATETIME='20200409',
		@dateEndReg DATETIME='20200516',
		@dateStartRegRAK DATETIME='20200409',
		@dateEndRegRAK DATETIME='20200516',
		@reportYear SMALLINT=2020,
		@reportMonth TINYINT=5


SELECT DiagnosisCode INTO #tDiagOnk FROM dbo.vw_sprMKB10 WHERE MainDS BETWEEN 'C00' AND 'C97'
UNION ALL
SELECT DiagnosisCode FROM dbo.vw_sprMKB10 WHERE MainDS BETWEEN 'D00' AND 'D09'


SELECT DISTINCT cc.id,c.id AS rf_idCase,cc.AmountPayment,c.rf_idv002,f.CodeM,dd.DS1, a.rf_idSMO, a.rf_idMO	
INTO #tCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_CompletedCase cc ON
            r.id=cc.rf_idRecordCasePatient
					INNER JOIN dbo.vw_Diagnosis dd ON
			c.id=dd.rf_idCase						
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND a.ReportMonth>2  AND a.ReportMonth<@reportMonth 
AND c.rf_idV006=2

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c 											
								WHERE c.DateRegistration>=@dateStartRegRAK AND c.DateRegistration<@dateEndRegRAK
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
-----------------------------------------2019------------------------
SELECT DISTINCT cc.id,c.id AS rf_idCase,cc.AmountPayment,c.rf_idv002,f.CodeM,dd.DS1, a.rf_idSMO, a.rf_idMO	
INTO #tCases2019
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_CompletedCase cc ON
            r.id=cc.rf_idRecordCasePatient
					INNER JOIN dbo.vw_Diagnosis dd ON
			c.id=dd.rf_idCase						
WHERE f.DateRegistration>='20190401' AND f.DateRegistration<'20200118'  AND a.ReportYear=2019 AND a.ReportMonth=4 
AND c.rf_idV006=2


UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases2019 p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c 											
								WHERE c.DateRegistration>='20190401' AND c.DateRegistration<'20200121'
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
-----------------------------------


SELECT c.rf_idCase
INTO #tCase4_1_3
FROM #tCases c INNER JOIN #tDiagOnk d ON
		c.DS1=d.DiagnosisCode
WHERE AmountPayment>0
UNION ALL
SELECT c.rf_idCase FROM #tCases c WHERE AmountPayment>0 AND c.rf_idV002=137
UNION ALL
SELECT c.rf_idCase FROM #tCases c WHERE AmountPayment>0 AND EXISTS(SELECT 1 FROM dbo.t_Meduslugi m WHERE MUGroupCode=60 AND MUUnGroupCode=3 AND c.rf_idCase=m.rf_idCase)

SELECT c.rf_idCase
INTO #tCase4_1_3_2019
FROM #tCases2019 c INNER JOIN #tDiagOnk d ON
		c.DS1=d.DiagnosisCode
WHERE AmountPayment>0
UNION ALL
SELECT c.rf_idCase FROM #tCases2019 c WHERE AmountPayment>0 AND c.rf_idV002=137
UNION ALL
SELECT c.rf_idCase FROM #tCases2019 c WHERE AmountPayment>0 AND EXISTS(SELECT 1 FROM dbo.t_Meduslugi m WHERE MUGroupCode=60 AND MUUnGroupCode=3 AND c.rf_idCase=m.rf_idCase)
-----------------------Фактические объемы----------------------------
;WITH cte
AS(
SELECT DISTINCT 1 AS IdRow,c.rf_idMO AS MCOD,'4.1' AS ColName,0 AS Col1,NULL AS Col2,0.0 AS Col4
		,CASE WHEN c.rf_idSMO<>'34' THEN c.id ELSE NULL END AS Col5
		,CASE WHEN c.rf_idSMO='34' THEN c.id ELSE NULL END AS Col6
		,CASE WHEN c.rf_idSMO<>'34' THEN c.AmountPayment ELSE 0.0 END AS Col7
		,CASE WHEN c.rf_idSMO='34' THEN c.AmountPayment ELSE 0.0 END AS Col8
FROM #tCases c INNER JOIN #tDiagOnk d ON
		c.DS1=d.DiagnosisCode
WHERE AmountPayment>0
UNION ALL
SELECT DISTINCT 2 AS IdRow,c.rf_idMO,'4.2' AS ColName,0 AS Col1,NULL AS Col2,0.0 AS Col4
		,CASE WHEN c.rf_idSMO<>'34' THEN c.id ELSE NULL END AS Col5
		,CASE WHEN c.rf_idSMO='34' THEN c.id ELSE NULL END AS Col6
		,CASE WHEN c.rf_idSMO<>'34' THEN c.AmountPayment ELSE 0.0 END AS Col7
		,CASE WHEN c.rf_idSMO='34' THEN c.AmountPayment ELSE 0.0 END AS Col8
FROM #tCases c 
WHERE AmountPayment>0 AND c.rf_idV002=137
UNION ALL
SELECT DISTINCT 3 AS IdRow,c.rf_idMO,'4.3' AS ColName,0 AS Col1,NULL AS Col2,0.0 AS Col4
		,CASE WHEN c.rf_idSMO<>'34' THEN c.id ELSE NULL END AS Col5
		,CASE WHEN c.rf_idSMO='34' THEN c.id ELSE NULL END AS Col6
		,CASE WHEN c.rf_idSMO<>'34' THEN c.AmountPayment ELSE 0.0 END AS Col7
		,CASE WHEN c.rf_idSMO='34' THEN c.AmountPayment ELSE 0.0 END AS Col8
FROM #tCases c 
WHERE AmountPayment>0 AND EXISTS(SELECT 1 FROM dbo.t_Meduslugi m WHERE MUGroupCode=60 AND MUUnGroupCode=3 AND c.rf_idCase=m.rf_idCase)
UNION ALL
SELECT DISTINCT 4 AS IdRow,c.rf_idMO,'4.4' AS ColName,0 AS Col1,NULL AS Col2,0.0 AS Col4
		,CASE WHEN c.rf_idSMO<>'34' THEN c.id ELSE NULL END AS Col5
		,CASE WHEN c.rf_idSMO='34' THEN c.id ELSE NULL END AS Col6
		,CASE WHEN c.rf_idSMO<>'34' THEN c.AmountPayment ELSE 0.0 END AS Col7
		,CASE WHEN c.rf_idSMO='34' THEN c.AmountPayment ELSE 0.0 END AS Col8
FROM #tCases c 
WHERE c.AmountPayment>0 AND NOT EXISTS(SELECT 1 FROM #tCase4_1_3 cc WHERE cc.rf_idCase=c.rf_idCase)
-----------------------Плановые объемы----------------------------
UNION all
SELECT DISTINCT 1 AS IdRow,c.rf_idMO,'4.1' AS ColName,0 AS Col1
        ,CASE WHEN c.rf_idSMO='34' THEN c.id ELSE NULL END AS Col2
		,CASE WHEN c.rf_idSMO='34' THEN c.AmountPayment ELSE 0.0 END AS Col4
		,null AS Col5, NULL AS Col6,0.0  AS Col7,0.0 AS Col8
FROM #tCases2019 c INNER JOIN #tDiagOnk d ON
		c.DS1=d.DiagnosisCode
WHERE AmountPayment>0
UNION all
SELECT DISTINCT 2 AS IdRow,c.rf_idMO,'4.2' AS ColName,0 AS Col1
        ,CASE WHEN c.rf_idSMO='34' THEN c.rf_idCase ELSE NULL END AS Col2
		,CASE WHEN c.rf_idSMO='34' THEN c.AmountPayment ELSE 0.0 END AS Col4
		,null AS Col5, NULL AS Col6,0.0  AS Col7,0.0 AS Col8
FROM #tCases2019 c 
WHERE AmountPayment>0 AND c.rf_idV002=137
UNION all
SELECT DISTINCT 3 AS IdRow,c.rf_idMO,'4.3' AS ColName,0 AS Col1
        ,CASE WHEN c.rf_idSMO='34' THEN c.id ELSE NULL END AS Col2
		,CASE WHEN c.rf_idSMO='34' THEN c.AmountPayment ELSE 0.0 END AS Col4
		,null AS Col5, NULL AS Col6,0.0  AS Col7,0.0 AS Col8
FROM #tCases2019 c 
WHERE AmountPayment>0 AND EXISTS(SELECT 1 FROM dbo.t_Meduslugi m WHERE MUGroupCode=60 AND MUUnGroupCode=3 AND c.rf_idCase=m.rf_idCase)
UNION ALL
SELECT DISTINCT 4 AS IdRow,c.rf_idMO,'4.4' AS ColName,0 AS Col1
        ,CASE WHEN c.rf_idSMO='34' THEN c.id ELSE NULL END AS Col2
		,CASE WHEN c.rf_idSMO='34' THEN c.AmountPayment ELSE 0.0 END AS Col4
		,null AS Col5, NULL AS Col6,0.0  AS Col7,0.0 AS Col8
FROM #tCases2019 c 
WHERE c.AmountPayment>0 AND NOT EXISTS(SELECT 1 FROM #tCase4_1_3_2019 cc WHERE cc.rf_idCase=c.rf_idCase)
----------------------------RATE----------------
UNION ALL
SELECT 1 AS IdRow,p.mcod,'4.1',CAST(p.rate AS INT),NULL Col2,0.0 AS Col4,NULL, NULL,0.0,0.0	
FROM oms_nsi.dbo.plan2020 p
WHERE unitCode='4.1'
UNION ALL
SELECT 2 AS IdRow,p.mcod,'4.2',CAST(p.rate AS INT),NULL Col2,0.0 AS Col4,NULL, NULL,0.0,0.0	
FROM oms_nsi.dbo.plan2020 p
WHERE unitCode='4.2'
UNION ALL
SELECT 3 AS IdRow,p.mcod,'4.3',CAST(p.rate AS INT),NULL Col2,0.0 AS Col4,NULL, NULL,0.0,0.0	
FROM oms_nsi.dbo.plan2020 p
WHERE unitCode='259'
UNION all
SELECT 4 AS IdRow,p.mcod,'4.4',CAST(p.rate AS INT),NULL Col2,0.0 AS Col4,NULL, NULL,0.0,0.0	
FROM oms_nsi.dbo.plan2020 p
WHERE unitCode='143'
UNION all
SELECT 4 AS IdRow,p.mcod,'4.4',CAST(-p.rate AS INT),NULL Col2,0.0 AS Col4,NULL, NULL,0.0,0.0	
FROM oms_nsi.dbo.plan2020 p
WHERE unitCode IN('4.1','4.2')
)
SELECT c.IdRow,l.mcod,l.LPU_Mcode AS LPU,c.ColName,
       CAST(SUM(c.Col1) AS INt) AS Col1,COUNT(c.Col2) AS Col2,CAST(SUM(c.Col4) AS money) AS Col4
	   ,COUNT(c.Col5) AS Col5,COUNT(c.Col6) AS Col6,CAST(SUM(c.Col7) AS money) AS Col7,CAST(SUM(c.Col8) AS money) AS Col8
FROM cte c INNER JOIN (SELECT DISTINCT mcod,LPU_Mcode FROM dbo.vw_sprT001) l ON
		c.MCOD=l.MCOD
GROUP BY c.IdRow,c.ColName,l.mcod,l.LPU_Mcode
ORDER BY l.mcod,c.IdRow

GO
DROP TABLE #tCase4_1_3_2019
GO
DROP TABLE #tCase4_1_3
GO
DROP TABLE #tCases
GO
DROP TABLE #tCases2019
GO
DROP TABLE #tDiagOnk