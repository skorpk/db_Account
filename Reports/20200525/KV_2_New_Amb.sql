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
			,(3,'Z20.8'),(3,'B34.2'),(3,'U07.1'),(3,'U07.2')
CREATE UNIQUE NONCLUSTERED INDEX IX_Diag ON #tDiag(DiagnosisCode,TypeDiag)

SELECT CodeM,mcod,1 AS PFA INTO #tLPU FROM dbo.vw_sprT001 WHERE pfa=1 AND DateEnd>'20200101'
UNION 
SELECT CodeM,mcod, 1 AS PFA FROM dbo.vw_sprT001 WHERE pfv=1 AND DateEnd>'20200101'

--обращения
SELECT MUGroupCode,MUUnGroupCode,MUCode, MU,1 AS TypeMU INTO #tMU FROM dbo.vw_sprMU WHERE MUGroupCode=2 AND MUUnGroupCode=78 AND MUCode NOT BETWEEN 54 AND 60

insert #tMU SELECT DISTINCT MUGroupCode,MUUnGroupCode,MUCode, MU,4 AS TypeMU FROM dbo.vw_sprMU WHERE MUGroupCode=2 AND MUUnGroupCode=78 AND MUCode NOT BETWEEN 54 AND 60 
delete  FROM #tMU WHERE MUGroupCode=2 AND MUUnGroupCode=78 AND MUCode BETWEEN 90 AND 91 AND TypeMU=4
--посещения
insert #tMU SELECT MUGroupCode,MUUnGroupCode,MUCode, MU,2  FROM dbo.vw_sprMU WHERE MUGroupCode=2 AND MUUnGroupCode=79 AND MUCode NOT BETWEEN 59 AND 64
insert #tMU SELECT MUGroupCode,MUUnGroupCode,MUCode, MU,2  FROM dbo.vw_sprMU WHERE MUGroupCode=2 AND MUUnGroupCode=81
insert #tMU SELECT MUGroupCode,MUUnGroupCode,MUCode, MU,2  FROM dbo.vw_sprMU WHERE MUGroupCode=2 AND MUUnGroupCode=88 AND MUCode NOT BETWEEN 46 AND 51
---------------MU 4.*-------------------------
insert #tMU SELECT MUGroupCode,MUUnGroupCode,MUCode, MU,3  FROM dbo.vw_sprMU WHERE MUGroupCode=4 AND MUUnGroupCode IN(8,11,12,13,14,15,16)
insert #tMU SELECT MUGroupCode,MUUnGroupCode,MUCode, MU,3  FROM dbo.vw_sprMU WHERE MUGroupCode=4 AND MUUnGroupCode=17  AND MUCode NOT IN(785,786)
insert #tMU SELECT MUGroupCode,MUUnGroupCode,MUCode, MU,3  FROM dbo.vw_sprMU WHERE MUGroupCode=4 AND MUUnGroupCode=20  AND MUCode=702

SELECT cc.id,c.id AS rf_idCase,cc.AmountPayment,c.rf_idv002,f.CodeM,a.rf_idSMO, a.rf_idMO
	,COUNT(CASE WHEN dd.DiagnosisCode LIKE 'U%' THEN 1 ELSE NULL END) IsCOVID,1 AS TypeCase
INTO #tCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN #tLPU l ON
            a.rf_idMO=l.mcod
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_CompletedCase cc ON
            r.id=cc.rf_idRecordCasePatient
					INNER JOIN dbo.t_Diagnosis dd ON
			c.id=dd.rf_idCase										
					--INNER JOIN dbo.t_Meduslugi m ON
     --       m.rf_idCase = c.id
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND a.ReportMonth>2  AND a.ReportMonth<@reportMonth 
AND c.rf_idV006=3 AND dd.TypeDiagnosis IN(1,3) AND EXISTS(SELECT 1 FROM #tDiag d WHERE d.DiagnosisCode=dd.DiagnosisCode AND d.TypeDiag=dd.TypeDiagnosis) AND l.PFA=1
GROUP BY cc.id,c.id ,cc.AmountPayment,c.rf_idv002,f.CodeM,a.rf_idSMO, a.rf_idMO		 

CREATE UNIQUE NONCLUSTERED INDEX ix_1 ON #tCases(rf_idCase) WITH IGNORE_DUP_KEY
INSERT #tCases
SELECT DISTINCT cc.id,c.id AS rf_idCase,cc.AmountPayment,c.rf_idv002,f.CodeM,a.rf_idSMO, a.rf_idMO, NULL IsCOVID,2 AS TypeP
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN #tLPU l ON
               a.rf_idMO=l.mcod
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_CompletedCase cc ON
            r.id=cc.rf_idRecordCasePatient
					INNER JOIN dbo.t_Diagnosis dd ON
			c.id=dd.rf_idCase					
					--INNER JOIN dbo.t_Meduslugi m ON
     --       m.rf_idCase = c.id
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND a.ReportMonth>2  AND a.ReportMonth<@reportMonth 
AND c.rf_idV006=3 AND dd.TypeDiagnosis IN(1,3) AND NOT EXISTS (SELECT 1 FROM #tDiag d WHERE d.DiagnosisCode=dd.DiagnosisCode AND d.TypeDiag=dd.TypeDiagnosis) AND l.PFA=1

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c 											
								WHERE c.DateRegistration>=@dateStartRegRAK AND c.DateRegistration<@dateEndRegRAK
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
;WITH cte 
AS(
SELECT  1 AS IdRow,'2.1.1.1' AS ColName,rf_idMO AS MCOD
	,0 AS Col1,CAST(NULL AS INT) AS Col2,0.0 AS Col4
	,CASE WHEN rf_idSMO<>'34' THEN 1 ELSE NULL END AS Col5
	,CAST(NULL AS INT) AS col6
	,CASE WHEN rf_idSMO<>'34' THEN AmountPayment ELSE 0.0 END AS Col7
	,0.0 AS Col8
FROM #tCases c 
WHERE c.TypeCase=1 AND EXISTS(SELECT 1 FROM dbo.t_MES m INNER JOIN #tMU mm ON mm.MU = m.mes WHERE m.rf_idCase=c.rf_idCase AND mm.TypeMU=1)
UNION ALL-------------------------------------------------------
SELECT 2 AS IdRow,'2.1.1.2' AS ColName,c.rf_idMO AS MCOD,0 AS Col1,NULL AS Col2,0.0 AS Col4
	,SUM(CASE WHEN rf_idSMO<>'34' THEN m.Quantity ELSE NULL END) AS Col5
	,NULL AS col6
	,SUM(CASE WHEN rf_idSMO<>'34' THEN AmountPayment ELSE 0.0 END) AS Col7
	,0.0 AS Col8
FROM #tCases c  INNER JOIN (SELECT MU,rf_idCase,SUM(Quantity) AS Quantity FROM dbo.t_Meduslugi GROUP BY rf_idCase,MU) m ON
			m.rf_idCase=c.rf_idCase 
			INNER JOIN #tMU mm ON 
			mm.MU = m.MU 
			AND mm.TypeMU=2
WHERE c.TypeCase=1 
GROUP BY c.rf_idMO,CASE WHEN rf_idSMO<>'34' THEN AmountPayment ELSE 0.0 END 

UNION ALL------------------------------------
SELECT  3 AS IdRow,'2.1.1.1.1' AS ColName,rf_idMO AS MCOD,0 AS Col1,NULL AS Col2,0.0 AS Col4
	,CASE WHEN rf_idSMO<>'34' THEN 1 ELSE NULL END AS Col5
	,NULL AS col6
	,CASE WHEN rf_idSMO<>'34' THEN AmountPayment ELSE 0.0 END AS Col7
	,0.0 AS Col8
FROM #tCases c 
WHERE c.TypeCase=1 AND c.IsCOVID=1 AND EXISTS(SELECT 1 FROM dbo.t_mes m INNER JOIN #tMU mm ON mm.MU = m.mes WHERE m.rf_idCase=c.rf_idCase AND mm.TypeMU=1)
UNION ALL
SELECT  4 AS IdRow,'2.1.1.2.1' AS ColName,c.rf_idMO AS MCOD,0 AS Col1,NULL AS Col2,0.0 AS Col4
	,CASE WHEN rf_idSMO<>'34' THEN m.Quantity ELSE NULL END AS Col5
	,NULL AS col6
	,CASE WHEN rf_idSMO<>'34' THEN AmountPayment ELSE 0.0 END AS Col7
	,0.0 AS Col8
FROM #tCases c  INNER JOIN (SELECT MU,rf_idCase,SUM(Quantity) AS Quantity FROM dbo.t_Meduslugi GROUP BY rf_idCase,MU) m ON
			m.rf_idCase=c.rf_idCase 
			INNER JOIN #tMU mm ON 
			mm.MU = m.MU 
			AND mm.TypeMU=2
WHERE c.TypeCase=1 AND c.IsCOVID=1 

UNION ALL-----------------------2.1.10-------------
SELECT 5 AS IdRow,'2.1.10' AS ColName,c.rf_idMO AS MCOD,0 AS Col1,NULL AS Col2,0.0 AS Col4
	,(CASE WHEN rf_idSMO<>'34' THEN m.Quantity ELSE NULL END) AS Col5
	,NULL AS col6
	,CASE WHEN rf_idSMO<>'34' THEN AmountPayment ELSE 0.0 END AS Col7
	,0.0 AS Col8
FROM #tCases c  INNER JOIN (SELECT MU,rf_idCase,SUM(Quantity) AS Quantity FROM dbo.t_Meduslugi GROUP BY rf_idCase,MU) m ON
			m.rf_idCase=c.rf_idCase 
			INNER JOIN #tMU mm ON 
			mm.MU = m.MU 
			AND mm.TypeMU=2
WHERE c.TypeCase=2
UNION ALL
SELECT DISTINCT 5 AS IdRow,'2.1.10' AS ColName,l.mcod AS MCOD,0 AS Col1,NULL AS Col2,0.0 AS Col4
	,NULL AS Col5,NULL AS col6,c.AmountPayment AS Col7
	,0.0 AS Col8
FROM dbo.t_AdditionalAccounts202003 c INNER JOIN #tLPU l ON
			c.CodeLPU=l.CodeM
WHERE c.NumberRegister=6 AND c.ReportYearMonth=202004
UNION ALL----------------------------------------------2.1.11---------------------------------
SELECT 6 AS IdRow,'2.1.11' AS ColName,rf_idMO AS MCOD,0 AS Col1,NULL AS Col2,0.0 AS Col4
	,CASE WHEN rf_idSMO<>'34' THEN 1 ELSE NULL END AS Col5
	,NULL AS col6
	,CASE WHEN rf_idSMO<>'34' THEN AmountPayment ELSE 0.0 END AS Col7
	,0.0 AS Col8
FROM #tCases c 
WHERE c.TypeCase=2 AND EXISTS(SELECT 1 FROM dbo.t_mes m INNER JOIN #tMU mm ON mm.MU = m.MES WHERE m.rf_idCase=c.rf_idCase AND mm.TypeMU=4)
UNION all
SELECT  6 AS IdRow,'2.1.11' AS ColName,l.mcod AS MCOD,0 AS Col1,NULL AS Col2,0.0 AS Col4
	,NULL AS Col5,NULL AS col6,c.AmountPayment AS Col7
	,0.0 AS Col8
FROM dbo.t_AdditionalAccounts202003 c INNER JOIN #tLPU l ON
			c.CodeLPU=l.CodeM
WHERE c.NumberRegister IN(1,4) AND c.ReportYearMonth=202004

----------------------RATE--------------------
UNION all
SELECT 5 AS IdRow,'2.1.10',p.mcod,CAST(p.rate AS INT),NULL Col2,0.0 AS Col4,NULL, NULL,0.0,0.0	
FROM oms_nsi.dbo.plan2020 p INNER JOIN #tLPU l ON
		l.mcod = p.mcod
WHERE unitCode ='30'
UNION all
SELECT 6 AS IdRow,'2.1.11',p.mcod,CAST(p.rate AS INT),NULL Col2,0.0 AS Col4,NULL, NULL,0.0,0.0	
FROM oms_nsi.dbo.plan2020 p INNER JOIN #tLPU l ON
		l.mcod = p.mcod
WHERE unitCode ='32'
)
SELECT c.IdRow,l.mcod,l.LPU_Mcode AS LPU,c.ColName
       ,CAST(SUM(c.Col1) AS INt) AS Col1,COUNT(c.Col2) AS Col2,CAST(SUM(c.Col4) AS money) AS Col4
	   ,CAST(SUM(ISNULL(c.Col5,0)) AS INT) AS Col5
	   ,COUNT(c.Col6) AS Col6
	   ,CAST(SUM(c.Col7) AS money) AS Col7
	   ,CAST(SUM(c.Col8) AS money) AS Col8
FROM cte c INNER JOIN (SELECT DISTINCT mcod,LPU_Mcode FROM dbo.vw_sprT001) l ON
		c.MCOD=l.MCOD
			INNER JOIN #tLPU ll ON
		l.mcod = ll.mcod
GROUP BY c.IdRow,c.ColName,l.mcod,l.LPU_Mcode
ORDER BY l.mcod,c.IdRow
GO
DROP TABLE #tMU
GO
DROP TABLE #tCases
go
DROP TABLE #tLPU
GO
DROP TABLE #tDiag
