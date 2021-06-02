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
--посещения
insert #tMU SELECT MUGroupCode,MUUnGroupCode,MUCode, MU,2  FROM dbo.vw_sprMU WHERE MUGroupCode=2 AND MUUnGroupCode=79 AND MUCode NOT BETWEEN 59 AND 64
insert #tMU SELECT MUGroupCode,MUUnGroupCode,MUCode, MU,2  FROM dbo.vw_sprMU WHERE MUGroupCode=2 AND MUUnGroupCode=81
insert #tMU SELECT MUGroupCode,MUUnGroupCode,MUCode, MU,2  FROM dbo.vw_sprMU WHERE MUGroupCode=2 AND MUUnGroupCode=88 AND MUCode NOT BETWEEN 46 AND 51
---------------MU 4.*-------------------------
insert #tMU SELECT MUGroupCode,MUUnGroupCode,MUCode, MU,3  FROM dbo.vw_sprMU WHERE MUGroupCode=4 AND MUUnGroupCode IN(8,11,12,13,14,15,16)
insert #tMU SELECT MUGroupCode,MUUnGroupCode,MUCode, MU,3  FROM dbo.vw_sprMU WHERE MUGroupCode=4 AND MUUnGroupCode=17  AND MUCode NOT IN(785,786)
insert #tMU SELECT MUGroupCode,MUUnGroupCode,MUCode, MU,3  FROM dbo.vw_sprMU WHERE MUGroupCode=4 AND MUUnGroupCode=20  AND MUCode=702
insert #tMU SELECT MUGroupCode,MUUnGroupCode,MUCode, MU,3  FROM dbo.vw_sprMU WHERE MUGroupCode=60 AND MUUnGroupCode IN(4,5)
---------------MU 4.*-------------------------
insert #tMU SELECT MUGroupCode,MUUnGroupCode,MUCode, MU,4  FROM dbo.vw_sprMU WHERE MUGroupCode=4 AND MUUnGroupCode IN(8,11,12,13,14,15,16)
insert #tMU SELECT MUGroupCode,MUUnGroupCode,MUCode, MU,4  FROM dbo.vw_sprMU WHERE MUGroupCode=4 AND MUUnGroupCode=17  AND MUCode NOT IN(785,786)
insert #tMU SELECT MUGroupCode,MUUnGroupCode,MUCode, MU,4  FROM dbo.vw_sprMU WHERE MUGroupCode=4 AND MUUnGroupCode=20  AND MUCode=702


SELECT cc.id,c.id AS rf_idCase,cc.AmountPayment,c.rf_idv002,f.CodeM,a.rf_idSMO, a.rf_idMO
	,COUNT(CASE WHEN dd.DiagnosisCode LIKE 'U%' THEN 1 ELSE NULL END) IsCOVID,1 AS TypeCase, f.TypeFile,a.Letter
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
					--INNER JOIN dbo.t_Meduslugi m ON
     --       m.rf_idCase = c.id
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND a.ReportMonth>2  AND a.ReportMonth<@reportMonth 
AND c.rf_idV006=3 AND dd.TypeDiagnosis IN(1,3) AND EXISTS(SELECT 1 FROM #tDiag d WHERE d.DiagnosisCode=dd.DiagnosisCode AND d.TypeDiag=dd.TypeDiagnosis) 
GROUP BY cc.id,c.id ,cc.AmountPayment,c.rf_idv002,f.CodeM,a.rf_idSMO, a.rf_idMO	,f.TypeFile,a.Letter	 

CREATE UNIQUE NONCLUSTERED INDEX ix_1 ON #tCases(rf_idCase) WITH IGNORE_DUP_KEY
INSERT #tCases
SELECT DISTINCT cc.id,c.id AS rf_idCase,cc.AmountPayment,c.rf_idv002,f.CodeM,a.rf_idSMO, a.rf_idMO, NULL IsCOVID,2 AS TypeP,f.TypeFile,a.Letter
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
					--INNER JOIN dbo.t_Meduslugi m ON
     --       m.rf_idCase = c.id
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND a.ReportMonth>2  AND a.ReportMonth<@reportMonth 
AND c.rf_idV006=3 AND dd.TypeDiagnosis IN(1,3) AND NOT EXISTS (SELECT 1 FROM #tDiag d WHERE d.DiagnosisCode=dd.DiagnosisCode AND d.TypeDiag=dd.TypeDiagnosis) 

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c 											
								WHERE c.DateRegistration>=@dateStartRegRAK AND c.DateRegistration<@dateEndRegRAK
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
--------------------------------2019---------------------------
SELECT cc.id,c.id AS rf_idCase,cc.AmountPayment,c.rf_idv002,f.CodeM,a.rf_idSMO, a.rf_idMO
	,COUNT(CASE WHEN dd.DiagnosisCode LIKE 'U%' THEN 1 ELSE NULL END) IsCOVID,1 AS TypeCase,f.TypeFile
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
					--INNER JOIN dbo.t_Meduslugi m ON
     --       m.rf_idCase = c.id
WHERE f.DateRegistration>='20190401' AND f.DateRegistration<'20200118'  AND a.ReportYear=2019 AND a.ReportMonth=4
AND c.rf_idV006=3 AND dd.TypeDiagnosis IN(1,3) AND EXISTS(SELECT 1 FROM #tDiag d WHERE d.DiagnosisCode=dd.DiagnosisCode AND d.TypeDiag=dd.TypeDiagnosis) 
GROUP BY cc.id,c.id ,cc.AmountPayment,c.rf_idv002,f.CodeM,a.rf_idSMO, a.rf_idMO	,f.TypeFile	 

CREATE UNIQUE NONCLUSTERED INDEX ix_2 ON #tCases(rf_idCase) WITH IGNORE_DUP_KEY
INSERT #tCases2019
SELECT DISTINCT cc.id,c.id AS rf_idCase,cc.AmountPayment,c.rf_idv002,f.CodeM,a.rf_idSMO, a.rf_idMO, NULL IsCOVID,2 AS TypeP,f.TypeFile
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
					--INNER JOIN dbo.t_Meduslugi m ON
     --       m.rf_idCase = c.id
WHERE f.DateRegistration>='20190401' AND f.DateRegistration<'20200118'  AND a.ReportYear=2019 AND a.ReportMonth=4
AND c.rf_idV006=3 AND dd.TypeDiagnosis IN(1,3) AND NOT EXISTS (SELECT 1 FROM #tDiag d WHERE d.DiagnosisCode=dd.DiagnosisCode AND d.TypeDiag=dd.TypeDiagnosis) 

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases2019 p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c 											
								WHERE c.DateRegistration>=@dateStartRegRAK AND c.DateRegistration<@dateEndRegRAK
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
;WITH cte
AS(
------------------------------------------------------
SELECT  1 AS IdRow,'2.2.1.1' AS ColName,rf_idMO AS MCOD
	,0 AS Col1,CAST(NULL AS INT) AS Col2,0.0 AS Col4
	,CASE WHEN rf_idSMO<>'34' THEN 1 ELSE 0 END AS Col5
	,CASE WHEN rf_idSMO='34' THEN 1 ELSE 0 END AS col6
	,CASE WHEN rf_idSMO<>'34' THEN AmountPayment ELSE 0.0 END AS Col7
	,CASE WHEN rf_idSMO='34' THEN AmountPayment ELSE 0.0 END AS Col8
FROM #tCases c 
WHERE c.TypeCase=1 AND EXISTS(SELECT 1 FROM dbo.t_Mes m INNER JOIN #tMU mm ON mm.MU = m.MES WHERE m.rf_idCase=c.rf_idCase AND mm.TypeMU=1)
	AND NOT EXISTS(SELECT 1 FROM #tLPU l WHERE l.mcod=c.rf_idMO)
UNION ALL
SELECT 2 AS IdRow,'2.2.1.2' AS ColName,c.rf_idMO AS MCOD
	,0 AS Col1,CAST(NULL AS INT) AS Col2,0.0 AS Col4
	,CASE WHEN rf_idSMO<>'34' THEN m.Quantity ELSE 0 END AS Col5
	,CASE WHEN rf_idSMO='34' THEN m.Quantity ELSE 0 END AS col6
	,CASE WHEN rf_idSMO<>'34' THEN AmountPayment ELSE 0.0 END AS Col7
	,CASE WHEN rf_idSMO='34' THEN AmountPayment ELSE 0.0 END AS Col8
FROM #tCases c INNER JOIN (SELECT MU,rf_idCase,SUM(Quantity) AS Quantity FROM dbo.t_Meduslugi GROUP BY rf_idCase,MU) m ON
			m.rf_idCase=c.rf_idCase 
			INNER JOIN #tMU mm ON 
			mm.MU = m.MU 
			AND mm.TypeMU=2
WHERE c.TypeCase=1 
AND NOT EXISTS(SELECT 1 FROM #tLPU l WHERE l.mcod=c.rf_idMO)
------------------------------------------------------------Case of Covid-19--------------------------------------------------------
UNION all
SELECT  3 AS IdRow,'2.2.1.1.1' AS ColName,rf_idMO AS MCOD
	,0 AS Col1,CAST(NULL AS INT) AS Col2,0.0 AS Col4
	,CASE WHEN rf_idSMO<>'34' THEN 1 ELSE 0 END AS Col5
	,CASE WHEN rf_idSMO='34' THEN  1 ELSE 0 END AS col6
	,CASE WHEN rf_idSMO<>'34' THEN AmountPayment ELSE 0.0 END AS Col7
	,CASE WHEN rf_idSMO='34' THEN AmountPayment ELSE 0.0 END AS Col8
FROM #tCases c 
WHERE c.TypeCase=1 AND EXISTS(SELECT 1 FROM dbo.t_mes m INNER JOIN #tMU mm ON mm.MU = m.MES WHERE m.rf_idCase=c.rf_idCase AND mm.TypeMU=1) AND c.IsCOVID=1
AND NOT EXISTS(SELECT 1 FROM #tLPU l WHERE l.mcod=c.rf_idMO)
UNION ALL
SELECT  4 AS IdRow,'2.2.1.2.1' AS ColName,rf_idMO AS MCOD
	,0 AS Col1,CAST(NULL AS INT) AS Col2,0.0 AS Col4
	,CASE WHEN rf_idSMO<>'34' THEN 1 ELSE 0 END AS Col5
	,CASE WHEN rf_idSMO='34' THEN 1 ELSE 0 END AS col6
	,CASE WHEN rf_idSMO<>'34' THEN AmountPayment ELSE 0.0 END AS Col7
	,CASE WHEN rf_idSMO='34' THEN AmountPayment ELSE 0.0 END AS Col8
FROM #tCases c 
WHERE c.TypeCase=1 AND EXISTS(SELECT 1 FROM dbo.t_Meduslugi m INNER JOIN #tMU mm ON mm.MU = m.MU WHERE m.rf_idCase=c.rf_idCase AND mm.TypeMU=2) AND c.IsCOVID=1
AND NOT EXISTS(SELECT 1 FROM #tLPU l WHERE l.mcod=c.rf_idMO)
-----считаем количество услуг--------
-------------------------------------------------------------MU 60.4.*-------------------------------------------------------------------
UNION ALL
SELECT 5 AS IdRow,'2.2.2' AS ColName,c.rf_idMO AS MCOD
	,0 AS Col1,CAST(NULL AS INT) AS Col2,0.0 AS Col4
	,(CASE WHEN rf_idSMO<>'34' THEN m.Quantity ELSE NULL END) AS Col5
	,(CASE WHEN rf_idSMO='34' THEN m.Quantity ELSE NULL END) AS Col6
	,CASE WHEN rf_idSMO<>'34' THEN AmountPayment ELSE 0.0 END AS Col7
	,CASE WHEN rf_idSMO='34' THEN AmountPayment ELSE 0.0 END AS Col8
FROM #tCases c INNER join (SELECT m.rf_idCase ,SUM(m.Quantity) Quantity FROM dbo.t_Meduslugi m WHERE  m.MUGroupCode=60 AND m.MUUnGroupCode=4 GROUP BY m.rf_idCase) m ON
			m.rf_idCase=c.rf_idCase 			
-----------------------------------------------------------------------------MU 60.5.*---------------------------------------------------------------
UNION ALL
SELECT 6 AS IdRow,'2.2.3' AS ColName,c.rf_idMO AS MCOD
	,0 AS Col1,CAST(NULL AS INT) AS Col2,0.0 AS Col4
	,(CASE WHEN rf_idSMO<>'34' THEN m.Quantity ELSE NULL END) AS Col5
	,(CASE WHEN rf_idSMO='34' THEN m.Quantity ELSE NULL END) AS Col6
	,CASE WHEN rf_idSMO<>'34' THEN AmountPayment ELSE 0.0 END AS Col7
	,CASE WHEN rf_idSMO='34' THEN AmountPayment ELSE 0.0 END AS Col8
FROM #tCases c INNER join (SELECT m.rf_idCase ,SUM(m.Quantity) Quantity FROM dbo.t_Meduslugi m WHERE  m.MUGroupCode=60 AND m.MUUnGroupCode=5 GROUP BY m.rf_idCase) m ON
			m.rf_idCase=c.rf_idCase 
			
---------------------------------------------------------MU 60.6.*---------------------------------------------------
UNION ALL
SELECT 7 AS IdRow,'2.2.4' AS ColName,c.rf_idMO AS MCOD
	,0 AS Col1,CAST(NULL AS INT) AS Col2,0.0 AS Col4
	,(CASE WHEN rf_idSMO<>'34' THEN m.Quantity ELSE NULL END) AS Col5
	,(CASE WHEN rf_idSMO='34' THEN m.Quantity ELSE NULL END) AS Col6
	,CASE WHEN rf_idSMO<>'34' THEN AmountPayment ELSE 0.0 END AS Col7
	,CASE WHEN rf_idSMO='34' THEN AmountPayment ELSE 0.0 END AS Col8
FROM #tCases c INNER join (SELECT m.rf_idCase ,SUM(m.Quantity) Quantity FROM dbo.t_Meduslugi m WHERE  m.MUGroupCode=60 AND m.MUUnGroupCode=6 GROUP BY m.rf_idCase) m ON
			m.rf_idCase=c.rf_idCase 
----------------------------------------------------------MU 60.7.*----------------------------------------------------
UNION ALL
SELECT 8 AS IdRow,'2.2.5' AS ColName,c.rf_idMO AS MCOD
	,0 AS Col1,CAST(NULL AS INT) AS Col2,0.0 AS Col4
	,(CASE WHEN rf_idSMO<>'34' THEN m.Quantity ELSE NULL END) AS Col5
	,(CASE WHEN rf_idSMO='34' THEN m.Quantity ELSE NULL END) AS Col6
	,CASE WHEN rf_idSMO<>'34' THEN AmountPayment ELSE 0.0 END AS Col7
	,CASE WHEN rf_idSMO='34' THEN AmountPayment ELSE 0.0 END AS Col8
FROM #tCases c INNER join (SELECT m.rf_idCase ,SUM(m.Quantity) Quantity FROM dbo.t_Meduslugi m WHERE  m.MUGroupCode=60 AND m.MUUnGroupCode=7 GROUP BY m.rf_idCase) m ON
			m.rf_idCase=c.rf_idCase 
---------------------------------------------------------------------------MU 60.8.*-----------------------------------
UNION ALL
SELECT  9 AS IdRow,'2.2.6' AS ColName,c.rf_idMO AS MCOD
	,0 AS Col1,CAST(NULL AS INT) AS Col2,0.0 AS Col4
	,(CASE WHEN rf_idSMO<>'34' THEN m.Quantity ELSE NULL END) AS Col5
	,(CASE WHEN rf_idSMO='34' THEN m.Quantity ELSE NULL END) AS Col6
	,CASE WHEN rf_idSMO<>'34' THEN AmountPayment ELSE 0.0 END AS Col7
	,CASE WHEN rf_idSMO='34' THEN AmountPayment ELSE 0.0 END AS Col8
FROM #tCases c INNER join (SELECT m.rf_idCase ,SUM(m.Quantity) Quantity FROM dbo.t_Meduslugi m WHERE  m.MUGroupCode=60 AND m.MUUnGroupCode=8 GROUP BY m.rf_idCase) m ON
			m.rf_idCase=c.rf_idCase 
			
-------------------------------------------------------------------------MU 60.9.*-----------------------------------
UNION ALL
SELECT 10 AS IdRow,'2.2.7' AS ColName,c.rf_idMO AS MCOD
	,0 AS Col1,CAST(NULL AS INT) AS Col2,0.0 AS Col4
	,(CASE WHEN rf_idSMO<>'34' THEN m.Quantity ELSE NULL END) AS Col5
	,(CASE WHEN rf_idSMO='34' THEN m.Quantity ELSE NULL END) AS Col6
	,CASE WHEN rf_idSMO<>'34' THEN AmountPayment ELSE 0.0 END AS Col7
	,CASE WHEN rf_idSMO='34' THEN AmountPayment ELSE 0.0 END AS Col8
FROM #tCases c INNER join (SELECT m.rf_idCase ,SUM(m.Quantity) Quantity FROM dbo.t_Meduslugi m WHERE  m.MUGroupCode=60 AND m.MUUnGroupCode=9 GROUP BY m.rf_idCase) m ON
			m.rf_idCase=c.rf_idCase 
			
------------------------------------------------------------------MU 4.17.*-----------------------------------
UNION ALL
SELECT 11 AS IdRow,'2.2.8' AS ColName,c.rf_idMO AS MCOD
	,0 AS Col1,CAST(NULL AS INT) AS Col2,0.0 AS Col4
	,(CASE WHEN rf_idSMO<>'34' THEN m.Quantity ELSE NULL END) AS Col5
	,(CASE WHEN rf_idSMO='34' THEN m.Quantity ELSE NULL END) AS Col6
	,CASE WHEN rf_idSMO<>'34' THEN AmountPayment ELSE 0.0 END AS Col7
	,CASE WHEN rf_idSMO='34' THEN AmountPayment ELSE 0.0 END AS Col8
FROM #tCases c INNER join (SELECT m.rf_idCase ,SUM(m.Quantity) Quantity FROM dbo.t_Meduslugi m WHERE m.MUGroupCode=4 AND m.MUUnGroupCode=17 AND m.MUUnGroupCode IN(785,786) GROUP BY m.rf_idCase) m ON
			m.rf_idCase=c.rf_idCase 
			
--------------------------------------------------------------MU 60.3.*-----------------------------------
UNION ALL
SELECT 12 AS IdRow,'2.2.9' AS ColName,c.rf_idMO AS MCOD
	,0 AS Col1,CAST(NULL AS INT) AS Col2,0.0 AS Col4
	,CASE WHEN rf_idSMO<>'34' THEN 1 ELSE NULL END AS Col5
	,CASE WHEN rf_idSMO='34' THEN  1 ELSE NULL END AS Col6
	,CASE WHEN rf_idSMO<>'34' THEN AmountPayment ELSE 0.0 END AS Col7
	,CASE WHEN rf_idSMO='34' THEN AmountPayment ELSE 0.0 END AS Col8
FROM (SELECT distinct rf_idCase,AmountPayment,rf_idSMO,rf_idMO FROM #tCases) c 
WHERE EXISTS(SELECT 1 FROM dbo.t_Meduslugi m WHERE 	m.rf_idCase=c.rf_idCase AND m.MUGroupCode=60 AND m.MUUnGroupCode=3)
UNION ALL
------------------------------------------------------------2.2.10----------------------------------------------------
-----------------------------Подушевики------------------------------
SELECT 13 AS IdRow,'2.2.10' AS ColName,c.rf_idMO AS MCOD
	,0 AS Col1,CAST(NULL AS INT) AS Col2,0.0 AS Col4
	,m.Quantity AS Col5,NULL AS Col6,AmountPayment AS Col7
	,0.0 AS Col8
FROM #tCases c INNER JOIN #tLPU l ON
		l.mcod = c.rf_idMO
				INNER JOIN (SELECT rf_idCase,SUM(Quantity) AS Quantity FROM dbo.t_Meduslugi m WHERE  m.MUGroupCode=2 AND m.MUUnGroupCode IN(79,81,88) GROUP BY rf_idCase,MU) m on 
		m.rf_idCase=c.rf_idCase 		
WHERE c.Letter='T'  AND c.rf_idSMO<>'34'
UNION ALL
SELECT  13 AS IdRow,'2.2.10' AS ColName,c.rf_idMO AS MCOD
	,0 AS Col1,CAST(NULL AS INT) AS Col2,0.0 AS Col4
	,(m.Quantity) AS Col5,null,AmountPayment AS Col7
	,0.0
FROM #tCases c INNER JOIN #tLPU l ON
		l.mcod = c.rf_idMO
				INNER JOIN (SELECT rf_idCase,SUM(Quantity) AS Quantity FROM dbo.t_Meduslugi m WHERE  m.MUGroupCode=2 AND m.MUUnGroupCode =76 GROUP BY rf_idCase,MU) m on 
		m.rf_idCase=c.rf_idCase 		
WHERE  c.rf_idSMO<>'34'
UNION ALL
SELECT  13 AS IdRow,'2.2.10' AS ColName,c.rf_idMO AS MCOD
	,0 AS Col1,CAST(NULL AS INT) AS Col2,0.0 AS Col4
	,1 AS Col5,null,AmountPayment AS Col7
	,0.0
FROM #tCases c INNER JOIN #tLPU l ON
		l.mcod = c.rf_idMO
WHERE c.TypeFile='F'  AND c.rf_idSMO<>'34'
UNION ALL
-----------------------------Не Подушевики------------------------------
SELECT  13 AS IdRow,'2.2.10' AS ColName,c.rf_idMO AS MCOD
	,0 AS Col1,CAST(NULL AS INT) AS Col2,0.0 AS Col4
	,m.Quantity  AS Col5
	,null,AmountPayment AS Col7
	,0.0
FROM #tCases c INNER JOIN (SELECT rf_idCase,SUM(Quantity) AS Quantity FROM dbo.t_Meduslugi m WHERE  m.MUGroupCode=2 AND m.MUUnGroupCode IN(76,79,81,88) GROUP BY rf_idCase,MU) m on 
		m.rf_idCase=c.rf_idCase 		
WHERE c.TypeCase=2  AND c.rf_idSMO<>'34' AND NOT EXISTS(SELECT 1 FROM #tLPU l WHERE l.mcod = c.rf_idMO)
UNION ALL-------------Иногородние
SELECT  13 AS IdRow,'2.2.10' AS ColName,c.rf_idMO AS MCOD
	,0 AS Col1,CAST(NULL AS INT) AS Col2,0.0 AS Col4
	,null AS Col5
	,(m.Quantity) 
	,0.0 AS Col7
	,AmountPayment AS Col8
FROM #tCases c INNER JOIN (SELECT rf_idCase,SUM(Quantity) AS Quantity FROM dbo.t_Meduslugi m WHERE  m.MUGroupCode=2 AND m.MUUnGroupCode IN(76,79,81,88) GROUP BY rf_idCase,MU) m on 
		m.rf_idCase=c.rf_idCase 		
WHERE c.TypeCase=2  AND c.rf_idSMO='34' 
UNION ALL
SELECT  13 AS IdRow,'2.2.10' AS ColName,c.rf_idMO AS MCOD
	,0 AS Col1,CAST(NULL AS INT) AS Col2,0.0 AS Col4
	,null AS Col5
	,1
	,0.0 AS Col7,AmountPayment 
FROM #tCases c 
WHERE c.TypeFile='F'  AND c.rf_idSMO='34'
-------------------------------------------------------2.2.11---------------------------------
UNION ALL
SELECT  14 AS IdRow,'2.2.11' AS ColName,c.rf_idMO AS MCOD
	,0 AS Col1,CAST(NULL AS INT) AS Col2,0.0 AS Col4
	,null AS Col5
	,1 AS Col6
	,0.0 AS Col7
	,c.AmountPayment AS Col8
FROM #tCases c INNER JOIN dbo.t_MES m on 
		m.rf_idCase=c.rf_idCase 			 			
WHERE c.TypeCase=2  AND c.rf_idSMO='34' AND m.MES LIKE '2.78.%'
UNION ALL
SELECT  14 AS IdRow,'2.2.11' AS ColName,c.rf_idMO AS MCOD
	,0 AS Col1,CAST(NULL AS INT) AS Col2,0.0 AS Col4
	,null AS Col5
	,1 AS Col6
	,0.0
	,c.AmountPayment AS Col8
FROM #tCases c INNER JOIN dbo.t_MES m on 
		m.rf_idCase=c.rf_idCase 
WHERE c.TypeCase=2  AND c.rf_idSMO='34' AND m.MES LIKE '2.89.%'
UNION ALL
SELECT  14 AS IdRow,'2.2.11' AS ColName,c.rf_idMO AS MCOD
	,0 AS Col1,CAST(NULL AS INT) AS Col2,0.0 AS Col4
	,null AS Col5
	,null AS Col6
	,CASE WHEN c.rf_idSMO<>'34' THEN c.AmountPayment ELSE 0.0 end
	,CASE WHEN c.rf_idSMO='34' THEN c.AmountPayment ELSE 0.0 end AS Col8
FROM #tCases c INNER JOIN (SELECT DISTINCT rf_idCase
							FROM  dbo.t_Meduslugi m1 INNER JOIN #tMU m2 ON
									m1.MU=m2.MU
									AND m2.TypeMU=4 
							WHERE Price>0.0
							) m1 ON
        c.rf_idCase=m1.rf_idCase				
WHERE c.TypeCase=2  AND c.Letter='K'---добавил условие. Что МУ с 4.* нужно брать только в счетах с буквой К. 29.05.2020
UNION ALL
-----------------------Подушевое--------------------
SELECT  14 AS IdRow,'2.2.11' AS ColName,c.rf_idMO AS MCOD
	,0 AS Col1,CAST(NULL AS INT) AS Col2,0.0 AS Col4
	,1 AS Col5
	,null AS Col6
	,c.AmountPayment
	,0.0 
FROM #tCases c INNER JOIN dbo.t_MES m on 
		m.rf_idCase=c.rf_idCase 	
				INNER JOIN #tLPU l ON
		c.rf_idMO=l.mcod		
				INNER JOIN #tMU m1 ON
        m.MES=m1.MU
		AND m1.TypeMU=5										
WHERE c.TypeCase=2  AND c.rf_idSMO<>'34' --AND m.mes LIKE '2.78.%' --AND c.Letter='T'
UNION ALL
SELECT  14 AS IdRow,'2.2.11' AS ColName,c.rf_idMO AS MCOD
	,0 AS Col1,CAST(NULL AS INT) AS Col2,0.0 AS Col4
	,1 AS Col5
	,null AS Col6
	,c.AmountPayment
	,0.0 
FROM #tCases c INNER JOIN dbo.t_MES m on 
		m.rf_idCase=c.rf_idCase 		
			INNER JOIN #tLPU l ON
		c.rf_idMO=l.mcod							
WHERE c.TypeCase=2  AND c.rf_idSMO<>'34' AND m.mes LIKE '2.89.%' 
--------------------------Не подушевое----------------------------------
UNION ALL
SELECT  14 AS IdRow,'2.2.11' AS ColName,c.rf_idMO AS MCOD
	,0 AS Col1,CAST(NULL AS INT) AS Col2,0.0 AS Col4
	,1 AS Col5
	,null AS Col6
	,c.AmountPayment
	,0.0 
FROM #tCases c INNER JOIN dbo.t_MES m on 
		m.rf_idCase=c.rf_idCase 									 						
WHERE c.TypeCase=2  AND c.rf_idSMO<>'34' AND m.mes LIKE '2.78.%' AND NOT EXISTS (SELECT 1 FROM #tLPU WHERE mcod=c.rf_idMO)
UNION ALL
SELECT  14 AS IdRow,'2.2.11' AS ColName,c.rf_idMO AS MCOD
	,0 AS Col1,CAST(NULL AS INT) AS Col2,0.0 AS Col4
	,1 AS Col5
	,null AS Col6
	,c.AmountPayment
	,0.0 
FROM #tCases c INNER JOIN dbo.t_MES m on 
		m.rf_idCase=c.rf_idCase 				
WHERE c.TypeCase=2  AND c.rf_idSMO<>'34' AND m.mes LIKE '2.89.%' AND NOT EXISTS (SELECT 1 FROM #tLPU WHERE mcod=c.rf_idMO)
UNION all
-----------------------------------------------------------------2019---------------------------------------------------
SELECT DISTINCT 1 AS IdRow,'2.2.1.1' AS ColName,rf_idMO AS MCOD
	,0 AS Col1
	,CASE WHEN rf_idSMO='34' THEN id ELSE NULL END AS Col2
	,CASE WHEN rf_idSMO='34' THEN AmountPayment ELSE 0.0 END AS Col4
	, NULL AS Col5
	,NULL AS col6
	,0.0 AS Col7
	,0.0 AS Col8
FROM #tCases2019 c 
WHERE c.TypeCase=1 AND EXISTS(SELECT 1 FROM dbo.t_MES m INNER JOIN #tMU mm ON mm.MU = m.MES WHERE m.rf_idCase=c.rf_idCase AND mm.TypeMU=1)
UNION ALL
SELECT  2 AS IdRow,'2.2.1.2' AS ColName,c.rf_idMO AS MCOD
	,0 AS Col1
	,CASE WHEN rf_idSMO='34' THEN m.Quantity ELSE NULL END AS Col2
	,CASE WHEN rf_idSMO='34' THEN AmountPayment ELSE 0.0 END AS Col4
	, NULL AS Col5
	,NULL AS col6
	,0.0 AS Col7
	,0.0 AS Col8
FROM #tCases2019 c INNER JOIN (SELECT rf_idCase,SUM(Quantity) AS Quantity , MU FROM dbo.t_Meduslugi m GROUP BY m.rf_idCase,m.MU) m ON
			m.rf_idCase=c.rf_idCase 
			INNER JOIN #tMU mm ON 
			mm.MU = m.MU 
			AND mm.TypeMU=2
WHERE c.TypeCase=1 
UNION ALL
SELECT DISTINCT 14 AS IdRow,'2.2.11' AS ColName,rf_idMO AS MCOD
	,0 AS Col1
	,CASE WHEN rf_idSMO='34' THEN id ELSE NULL END AS Col2
	,CASE WHEN rf_idSMO='34' THEN AmountPayment ELSE 0.0 END AS Col4
	, NULL AS Col5
	,NULL AS col6
	,0.0 AS Col7
	,0.0 AS Col8
FROM #tCases2019 c 
WHERE c.TypeCase=2 AND EXISTS(SELECT 1 FROM dbo.t_MES m INNER JOIN #tMU mm ON mm.MU = m.MES WHERE m.rf_idCase=c.rf_idCase AND mm.TypeMU=1)
UNION ALL
SELECT DISTINCT 14 AS IdRow,'2.2.11' AS ColName,rf_idMO AS MCOD
	,0 AS Col1
	, NULL  AS Col2
	,CASE WHEN rf_idSMO='34' THEN AmountPayment ELSE 0.0 END AS Col4
	, NULL AS Col5
	,NULL AS col6
	,0.0 AS Col7
	,0.0 AS Col8
FROM #tCases2019 c 
WHERE EXISTS(SELECT 1 FROM dbo.t_Meduslugi m INNER JOIN #tMU mm ON mm.MU = m.MU WHERE m.rf_idCase=c.rf_idCase AND mm.TypeMU=3)
UNION ALL------------------------2.2.10-----------------------
SELECT DISTINCT 13 AS IdRow,'2.2.10' AS ColName,rf_idMO AS MCOD
	,0 AS Col1
	,CASE WHEN rf_idSMO='34' THEN id ELSE NULL END AS Col2
	,CASE WHEN rf_idSMO='34' THEN AmountPayment ELSE 0.0 END AS Col4
	, NULL AS Col5
	,NULL AS col6
	,0.0 AS Col7
	,0.0 AS Col8
FROM #tCases2019 c 
WHERE c.TypeCase=2 AND EXISTS(SELECT 1 FROM dbo.t_Meduslugi m INNER JOIN #tMU mm ON mm.MU = m.MU WHERE m.rf_idCase=c.rf_idCase AND mm.TypeMU=2)
UNION ALL
SELECT DISTINCT 13 AS IdRow,'2.2.10' AS ColName,rf_idMO AS MCOD
	,0 AS Col1
	,CASE WHEN rf_idSMO='34' THEN id ELSE NULL END AS Col2
	,0.0 AS Col4
	, NULL AS Col5
	,NULL AS col6
	,0.0 AS Col7
	,0.0 AS Col8
FROM #tCases2019 c 
WHERE c.TypeFile='F'


------------------------------------MU 60.3.*-----------------------------------
UNION ALL
SELECT 12 AS IdRow,'2.2.9' AS ColName, c.rf_idMO AS MCOD
	,0 AS Col1
	,CASE WHEN rf_idSMO='34' THEN 1 ELSE NULL END AS Col2
	,CASE WHEN rf_idSMO='34' THEN AmountPayment ELSE 0.0 END AS Col8
	,NULL AS Col5
	,null
	,0.0
	,0.0
FROM #tCases2019 c 
WHERE EXISTS(SELECT 1 FROM dbo.t_Meduslugi m WHERE 	m.rf_idCase=c.rf_idCase AND m.MUGroupCode=60 AND m.MUUnGroupCode=3)
-----------------RATE-----------------------
UNION all
SELECT 5 AS IdRow,'2.2.2',p.mcod,CAST(p.rate AS INT),NULL Col2,0.0 AS Col4,NULL, NULL,0.0,0.0	
FROM oms_nsi.dbo.plan2020 p
WHERE unitCode='324'
UNION all
SELECT 6 AS IdRow,'2.2.3',p.mcod,CAST(p.rate AS INT),NULL Col2,0.0 AS Col4,NULL, NULL,0.0,0.0	
FROM oms_nsi.dbo.plan2020 p
WHERE unitCode='325'
UNION all
SELECT 7 AS IdRow,'2.2.4',p.mcod,CAST(p.rate AS INT),NULL Col2,0.0 AS Col4,NULL, NULL,0.0,0.0	
FROM oms_nsi.dbo.plan2020 p
WHERE unitCode='326'
UNION all
SELECT 8 AS IdRow,'2.2.5',p.mcod,CAST(p.rate AS INT),NULL Col2,0.0 AS Col4,NULL, NULL,0.0,0.0	
FROM oms_nsi.dbo.plan2020 p
WHERE unitCode='327'
UNION all
SELECT 9 AS IdRow,'2.2.6',p.mcod,CAST(p.rate AS INT),NULL Col2,0.0 AS Col4,NULL, NULL,0.0,0.0	
FROM oms_nsi.dbo.plan2020 p
WHERE unitCode='328'
UNION all
SELECT 10 AS IdRow,'2.2.7',p.mcod,CAST(p.rate AS INT),NULL Col2,0.0 AS Col4,NULL, NULL,0.0,0.0	
FROM oms_nsi.dbo.plan2020 p
WHERE unitCode='329'
UNION all
SELECT 12 AS IdRow,'2.2.9',p.mcod,CAST(p.rate AS INT),NULL Col2,0.0 AS Col4,NULL, NULL,0.0,0.0	
FROM oms_nsi.dbo.plan2020 p
WHERE unitCode='205'
UNION ALL-----------------переделывать
SELECT 13 AS IdRow,'2.2.10',p.mcod,CAST(p.rate AS INT),NULL Col2,0.0 AS Col4,NULL, NULL,0.0,0.0	
FROM oms_nsi.dbo.plan2020 p  INNER JOIN #tLPU l ON
		l.mcod = p.mcod
WHERE unitCode IN('38','145', '261', '262', '318', '319', '320', '321')
UNION ALL
SELECT 13 AS IdRow,'2.2.10',p.mcod,CAST(p.rate AS INT),NULL Col2,0.0 AS Col4,NULL, NULL,0.0,0.0	
FROM oms_nsi.dbo.plan2020 p  
WHERE unitCode IN('30','38','145', '261', '262', '318', '319', '320', '321')
AND NOT EXISTS(SELECT 1 FROM #tLPU WHERE mcod=p.mcod)
UNION ALL
SELECT 14 AS IdRow,'2.2.11',p.mcod,CAST(p.rate AS INT),NULL Col2,0.0 AS Col4,NULL, NULL,0.0,0.0	
FROM oms_nsi.dbo.plan2020 p  INNER JOIN #tLPU l ON
		l.mcod = p.mcod
WHERE unitCode IN('147','322','323')
UNION ALL
SELECT 14 AS IdRow,'2.2.11',p.mcod,CAST(p.rate AS INT),NULL Col2,0.0 AS Col4,NULL, NULL,0.0,0.0	
FROM oms_nsi.dbo.plan2020 p  
WHERE unitCode IN('32','147','322','323') AND NOT EXISTS(SELECT 1 FROM #tLPU WHERE mcod=p.mcod)
)
SELECT c.IdRow,l.mcod,l.LPU_Mcode AS LPU,c.ColName
       ,CAST(SUM(c.Col1) AS INt) AS Col1
	   ,COUNT(c.Col2) AS Col2
	   ,CAST(SUM(c.Col4) AS money) AS Col4
	   ,CAST(SUM(ISNULL(c.Col5,0)) AS INT) AS Col5
	   ,CAST(SUM(ISNULL(c.Col6,0)) AS INT) AS Col6
	   ,CAST(SUM(c.Col7) AS money) AS Col7
	   ,CAST(SUM(c.Col8) AS money) AS Col8
FROM cte c INNER JOIN (SELECT DISTINCT mcod,LPU_Mcode FROM dbo.vw_sprT001) l ON
		c.MCOD=l.MCOD			
GROUP BY c.IdRow,c.ColName,l.mcod,l.LPU_Mcode
ORDER BY l.mcod,c.IdRow
GO
DROP TABLE #tMU
GO
DROP TABLE #tCases
GO
DROP TABLE #tCases2019
go
DROP TABLE #tLPU
GO
DROP TABLE #tDiag
