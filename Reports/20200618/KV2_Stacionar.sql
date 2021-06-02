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

SELECT DiagnosisCode INTO #tDiagOnk FROM dbo.vw_sprMKB10 WHERE MainDS BETWEEN 'C00' AND 'C97'
UNION ALL
SELECT DiagnosisCode FROM dbo.vw_sprMKB10 WHERE MainDS BETWEEN 'D00' AND 'D09'


SELECT DISTINCT cc.id,c.id AS rf_idCase,cc.AmountPayment,c.rf_idv002,f.CodeM,dd.DS1, dd.DS2, a.rf_idSMO, a.rf_idMO	
	,CASE WHEN dd.DS1 LIKE 'U%' OR dd.DS2 LIKE 'U%' THEN 1 ELSE 0 END AS IsCovid, c.rf_idV014
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

SELECT DISTINCT cc.id,c.id AS rf_idCase,cc.AmountPayment,c.rf_idv002,f.CodeM,dd.DS1, dd.DS2, a.rf_idSMO, a.rf_idMO	
	,CASE WHEN dd.DS1 LIKE 'U%' OR dd.DS2 LIKE 'U%' THEN 1 ELSE 0 END AS IsCovid, c.rf_idV014
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
SELECT c.rf_idCase
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

;WITH cte
AS(
-------------------------Фактическое выпоненая медпомощь------------------
SELECT DISTINCT 1 AS IdRow,c.rf_idMO AS MCOD,'3.1' AS ColName,0 AS Col1,NULL AS Col2,0.0 AS Col4
		,CASE WHEN c.rf_idSMO<>'34' THEN c.id ELSE NULL END AS Col5
		,CASE WHEN c.rf_idSMO='34' THEN c.id ELSE NULL END AS Col6
		,CASE WHEN c.rf_idSMO<>'34' THEN c.AmountPayment ELSE 0.0 END AS Col7
		,CASE WHEN c.rf_idSMO='34' THEN c.AmountPayment ELSE 0.0 END AS Col8
FROM #tCases c INNER JOIN #tDiagOnk d ON
		c.DS1=d.DiagnosisCode
WHERE AmountPayment>0
UNION ALL
SELECT DISTINCT 2 AS IdRow,c.rf_idMO AS MCOD,'3.2' AS ColName,0 AS Col1,NULL AS Col2,0.0 AS Col4
		,CASE WHEN c.rf_idSMO<>'34' THEN c.id ELSE NULL END AS Col5
		,CASE WHEN c.rf_idSMO='34' THEN c.id ELSE NULL END AS Col6
		,CASE WHEN c.rf_idSMO<>'34' THEN c.AmountPayment ELSE 0.0 END AS Col7
		,CASE WHEN c.rf_idSMO='34' THEN c.AmountPayment ELSE 0.0 END AS Col8
FROM(
	SELECT c.rf_idMO,c.id,c.AmountPayment,rf_idSMO
	FROM #tCases c INNER JOIN #tDiag d ON
			c.DS1=d.DiagnosisCode
	WHERE AmountPayment>0 AND d.TypeDiag=1
	union
	SELECT c.rf_idMO,c.id,c.AmountPayment,rf_idSMO
	FROM #tCases c INNER JOIN #tDiag d ON
			c.DS2=d.DiagnosisCode
	WHERE AmountPayment>0 AND d.TypeDiag=3
	GROUP BY c.rf_idMO,c.id,c.AmountPayment,rf_idSMO
) c
UNION ALL
SELECT DISTINCT 3 AS IdRow,c.rf_idMO AS MCOD,'3.2.1' AS ColName,0 AS Col1,NULL AS Col2,0.0 AS Col4
		,CASE WHEN c.rf_idSMO<>'34' THEN c.id ELSE NULL END AS Col5
		,CASE WHEN c.rf_idSMO='34' THEN c.id ELSE NULL END AS Col6
		,CASE WHEN c.rf_idSMO<>'34' THEN c.AmountPayment ELSE 0.0 END AS Col7
		,CASE WHEN c.rf_idSMO='34' THEN c.AmountPayment ELSE 0.0 END AS Col8
FROM #tCases c 
WHERE AmountPayment>0 AND c.IsCovid=1
UNION ALL
SELECT DISTINCT 4 AS IdRow,c.rf_idMO AS MCOD,'3.2.2' AS ColName,0 AS Col1,NULL AS Col2,0.0 AS Col4
		,CASE WHEN c.rf_idSMO<>'34' THEN c.id ELSE NULL END AS Col5
		,CASE WHEN c.rf_idSMO='34' THEN c.id ELSE NULL END AS Col6
		,CASE WHEN c.rf_idSMO<>'34' THEN c.AmountPayment ELSE 0.0 END AS Col7
		,CASE WHEN c.rf_idSMO='34' THEN c.AmountPayment ELSE 0.0 END AS Col8
FROM #tCases c 
WHERE AmountPayment>0 AND EXISTS(SELECT 1 FROM dbo.t_Meduslugi WHERE rf_idCase=c.rf_idCase AND MUSurgery='A16.10.021.001')
UNION ALL
SELECT DISTINCT 5 AS IdRow,c.rf_idMO AS MCOD,'3.3' AS ColName,0 AS Col1,NULL AS Col2,0.0 AS Col4
		,CASE WHEN c.rf_idSMO<>'34' THEN c.id  ELSE NULL END AS Col5
		,CASE WHEN c.rf_idSMO='34' THEN c.id ELSE NULL END AS Col6
		,CASE WHEN c.rf_idSMO<>'34' THEN c.AmountPayment ELSE 0.0 END AS Col7
		,CASE WHEN c.rf_idSMO='34' THEN c.AmountPayment ELSE 0.0 END AS Col8
FROM #tCases c 
WHERE AmountPayment>0 AND c.rf_idV014 IN (1,2) AND NOT EXISTS(SELECT 1 FROM #tmpCase_33 WHERE rf_idCase=c.rf_idCase)
UNION ALL
SELECT DISTINCT 6 AS IdRow,c.rf_idMO AS MCOD,'3.4' AS ColName,0 AS Col1,NULL AS Col2,0.0 AS Col4
		,CASE WHEN c.rf_idSMO<>'34' THEN c.id ELSE NULL END AS Col5
		,CASE WHEN c.rf_idSMO='34' THEN c.id ELSE NULL END AS Col6
		,CASE WHEN c.rf_idSMO<>'34' THEN c.AmountPayment ELSE 0.0 END AS Col7
		,CASE WHEN c.rf_idSMO='34' THEN c.AmountPayment ELSE 0.0 END AS Col8
FROM #tCases c 
WHERE AmountPayment>0 AND c.rf_idV014 =3 AND NOT EXISTS(SELECT 1 FROM #tmpCase_33 WHERE rf_idCase=c.rf_idCase)
------------------2019----------------------
UNION all
SELECT DISTINCT 1 AS IdRow,c.rf_idMO AS MCOD,'3.1' AS ColName,0 AS Col1
	,CASE WHEN c.rf_idSMO='34' THEN c.id ELSE NULL END AS Col2
	,CASE WHEN c.rf_idSMO='34' THEN c.AmountPayment ELSE 0.0 END AS Col4
		,null AS Col5,null Col6,0.0 AS Col7,0.0 AS Col8
FROM #tCases2019 c INNER JOIN #tDiagOnk d ON
		c.DS1=d.DiagnosisCode
WHERE AmountPayment>0
UNION all
SELECT DISTINCT 2 AS IdRow,c.rf_idMO AS MCOD,'3.2' AS ColName,0 AS Col1
	,CASE WHEN c.rf_idSMO='34' THEN c.id ELSE NULL END AS Col2
	,CASE WHEN c.rf_idSMO='34' THEN c.AmountPayment ELSE 0.0 END AS Col4
		,null AS Col5,null Col6,0.0 AS Col7,0.0 AS Col8
FROM(
	SELECT c.rf_idMO,c.id,c.AmountPayment,rf_idSMO
	FROM #tCases2019 c INNER JOIN #tDiag d ON
			c.DS1=d.DiagnosisCode
	WHERE AmountPayment>0 AND d.TypeDiag=1
	union
	SELECT c.rf_idMO,c.id,c.AmountPayment,rf_idSMO
	FROM #tCases2019 c INNER JOIN #tDiag d ON
			c.DS2=d.DiagnosisCode
	WHERE AmountPayment>0 AND d.TypeDiag=3
	GROUP BY c.rf_idMO,c.id,c.AmountPayment,rf_idSMO
) c
UNION all
SELECT DISTINCT 4 AS IdRow,c.rf_idMO AS MCOD,'3.2.2' AS ColName,0 AS Col1
	,CASE WHEN c.rf_idSMO='34' THEN c.id ELSE NULL END AS Col2
	,CASE WHEN c.rf_idSMO='34' THEN c.AmountPayment ELSE 0.0 END AS Col4
		,null AS Col5,null Col6,0.0 AS Col7,0.0 AS Col8
FROM #tCases2019 c 
WHERE AmountPayment>0 AND EXISTS(SELECT 1 FROM dbo.t_Meduslugi WHERE rf_idCase=c.rf_idCase AND MUSurgery='A16.10.021.001')
UNION all
SELECT DISTINCT 5 AS IdRow,c.rf_idMO AS MCOD,'3.3' AS ColName,0 AS Col1
	,CASE WHEN c.rf_idSMO='34' THEN c.id ELSE NULL END AS Col2
	,CASE WHEN c.rf_idSMO='34' THEN c.AmountPayment ELSE 0.0 END AS Col4
		,null AS Col5,null Col6,0.0 AS Col7,0.0 AS Col8
FROM #tCases2019 c 
WHERE AmountPayment>0 AND c.rf_idV014 IN (1,2) AND NOT EXISTS(SELECT 1 FROM #tmpCase_33_2019 WHERE rf_idCase=c.rf_idCase)
UNION all
SELECT DISTINCT 6 AS IdRow,c.rf_idMO AS MCOD,'3.4' AS ColName,0 AS Col1
	,CASE WHEN c.rf_idSMO='34' THEN c.id ELSE NULL END AS Col2
	,CASE WHEN c.rf_idSMO='34' THEN c.AmountPayment ELSE 0.0 END AS Col4
		,null AS Col5,null Col6,0.0 AS Col7,0.0 AS Col8
FROM #tCases2019 c 
WHERE AmountPayment>0 AND c.rf_idV014=3 AND NOT EXISTS(SELECT 1 FROM #tmpCase_33_2019 WHERE rf_idCase=c.rf_idCase)
---------------------------RATE----------------
UNION ALL
SELECT 1 AS IdRow,p.mcod,'3.1',CAST(p.rate AS INT),NULL Col2,0.0 AS Col4,NULL, NULL,0.0,0.0	
FROM oms_nsi.dbo.plan2020 p
WHERE unitCode='3.1'
UNION ALL
SELECT 2 AS IdRow,p.mcod,'3.2',CAST(p.rate AS INT),NULL Col2,0.0 AS Col4,NULL, NULL,0.0,0.0	
FROM oms_nsi.dbo.plan2020 p
WHERE unitCode='3.2'
UNION ALL
SELECT 3 AS IdRow,p.mcod,'3.2.1',CAST(p.rate AS INT),NULL Col2,0.0 AS Col4,NULL, NULL,0.0,0.0	
FROM oms_nsi.dbo.plan2020 p
WHERE unitCode='3.2.1'
UNION ALL
SELECT 4 AS IdRow,p.mcod,'3.2.2',CAST(p.rate AS INT),NULL Col2,0.0 AS Col4,NULL, NULL,0.0,0.0	
FROM oms_nsi.dbo.plan2020 p
WHERE unitCode='3.2.2'
UNION ALL
SELECT 6 AS IdRow,p.mcod,'3.4',CAST(-p.rate AS INT),NULL Col2,0.0 AS Col4,NULL, NULL,0.0,0.0	
FROM oms_nsi.dbo.plan2020 p
WHERE unitCode IN('3.1','3.2')
UNION ALL
SELECT 6 AS IdRow,p.mcod,'3.4',CAST(p.rate AS INT),NULL Col2,0.0 AS Col4,NULL, NULL,0.0,0.0	
FROM oms_nsi.dbo.plan2020 p
WHERE unitCode IN('29','142','330','331','332','333','334','335','336','337','338','339','340','341','342','343','344','345','346','347','348','349','350',
'351','352','353','354','355','356','357','358','359','360','361','362','363','364','365','366','367','368','369','370','371',
'372','373','374','375','376','377','378','379','380','381','382','383','384','385','386')
)
SELECT c.IdRow,l.mcod,l.LPU_Mcode AS LPU,c.ColName,
       CAST(SUM(c.Col1) AS INt) AS Col1,COUNT(c.Col2) AS Col2
	   ,CAST(cast(SUM(c.Col4)/1000.0 as decimal(15,2)) AS money) AS Col4
	   ,COUNT(c.Col5) AS Col5,COUNT(c.Col6) AS Col6
	   ,CAST(cast(SUM(c.Col7)/1000.0 as decimal(15,2)) AS money) AS Col7
	   ,CAST(cast(SUM(c.Col8)/1000.0 as decimal(15,2)) AS money) AS Col8
FROM cte c INNER JOIN (SELECT DISTINCT mcod,LPU_Mcode FROM dbo.vw_sprT001) l ON
		c.MCOD=l.MCOD
GROUP BY c.IdRow,c.ColName,l.mcod,l.LPU_Mcode
ORDER BY l.mcod,c.IdRow
GO
DROP TABLE #tCases
GO
DROP TABLE #tmpCase_33_2019
GO
DROP TABLE #tmpCase_33
GO
DROP TABLE #tCases2019
GO
DROP TABLE #tDiagOnk
GO
DROP TABLE #tDiag