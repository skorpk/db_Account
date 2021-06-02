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


insert #tMU SELECT DISTINCT MUGroupCode,MUUnGroupCode,MUCode, MU,5 AS TypeMU FROM dbo.vw_sprMU WHERE MUGroupCode=2 AND MUUnGroupCode=78 AND MUCode  BETWEEN 54 AND 60 
insert #tMU SELECT DISTINCT MUGroupCode,MUUnGroupCode,MUCode, MU,5 AS TypeMU FROM dbo.vw_sprMU WHERE MUGroupCode=2 AND MUUnGroupCode=78 AND MUCode IN(90,91)


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
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND a.ReportMonth>2  AND a.ReportMonth<@reportMonth 
AND c.rf_idV006=3 AND dd.TypeDiagnosis IN(1,3) AND EXISTS(SELECT 1 FROM #tDiag d WHERE d.DiagnosisCode=dd.DiagnosisCode AND d.TypeDiag=dd.TypeDiagnosis) 
AND a.rf_idMO='340041'
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
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND a.ReportMonth>2  AND a.ReportMonth<@reportMonth 
AND c.rf_idV006=3 AND dd.TypeDiagnosis IN(1,3) AND NOT EXISTS (SELECT 1 FROM #tDiag d WHERE d.DiagnosisCode=dd.DiagnosisCode AND d.TypeDiag=dd.TypeDiagnosis) 
AND a.rf_idMO='340041'


UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c 											
								WHERE c.DateRegistration>=@dateStartRegRAK AND c.DateRegistration<@dateEndRegRAK
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase



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
WHERE c.TypeCase=2  AND c.Letter='K'
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
go
DROP TABLE #tMU
GO
DROP TABLE #tCases
GO
DROP TABLE #tLPU
GO
DROP TABLE #tDiag

    