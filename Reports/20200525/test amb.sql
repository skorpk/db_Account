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
SELECT distinct  MUGroupCode,MUUnGroupCode,MUCode, MU,1 AS TypeMU INTO #tMU FROM dbo.vw_sprMU WHERE MUGroupCode=2 AND MUUnGroupCode=78 AND MUCode NOT BETWEEN 54 AND 60
insert #tMU SELECT DISTINCT MUGroupCode,MUUnGroupCode,MUCode, MU,4 AS TypeMU FROM dbo.vw_sprMU WHERE MUGroupCode=2 AND MUUnGroupCode=78 AND MUCode NOT BETWEEN 54 AND 60 
delete  FROM #tMU WHERE MUGroupCode=2 AND MUUnGroupCode=78 AND MUCode BETWEEN 90 AND 91 AND TypeMU=4

SELECT @@ROWCOUNT 

--посещения
insert #tMU SELECT MUGroupCode,MUUnGroupCode,MUCode, MU,2  FROM dbo.vw_sprMU WHERE MUGroupCode=2 AND MUUnGroupCode=79 AND MUCode NOT BETWEEN 59 AND 64
insert #tMU SELECT MUGroupCode,MUUnGroupCode,MUCode, MU,2  FROM dbo.vw_sprMU WHERE MUGroupCode=2 AND MUUnGroupCode=81
insert #tMU SELECT MUGroupCode,MUUnGroupCode,MUCode, MU,2  FROM dbo.vw_sprMU WHERE MUGroupCode=2 AND MUUnGroupCode=88 AND MUCode NOT BETWEEN 46 AND 51
---------------MU 4.*-------------------------
insert #tMU SELECT MUGroupCode,MUUnGroupCode,MUCode, MU,3  FROM dbo.vw_sprMU WHERE MUGroupCode=4 AND MUUnGroupCode IN(8,11,12,13,14,15,16)
insert #tMU SELECT MUGroupCode,MUUnGroupCode,MUCode, MU,3  FROM dbo.vw_sprMU WHERE MUGroupCode=4 AND MUUnGroupCode=17  AND MUCode NOT IN(785,786)
insert #tMU SELECT MUGroupCode,MUUnGroupCode,MUCode, MU,3  FROM dbo.vw_sprMU WHERE MUGroupCode=4 AND MUUnGroupCode=20  AND MUCode=702

SELECT cc.id,c.id AS rf_idCase,cc.AmountPayment,c.rf_idv002,f.CodeM,a.rf_idSMO, a.rf_idMO
	,COUNT(CASE WHEN dd.DiagnosisCode LIKE 'U%' THEN 1 ELSE NULL END) IsCOVID,1 AS TypeCase,letter,c.rf_idRecordCasePatient
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
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND a.ReportMonth>2  AND a.ReportMonth<@reportMonth 
		AND c.rf_idV006=3 AND dd.TypeDiagnosis IN(1,3) 
		AND EXISTS(SELECT 1 FROM #tDiag d WHERE d.DiagnosisCode=dd.DiagnosisCode AND d.TypeDiag=dd.TypeDiagnosis) AND l.PFA=1 AND a.rf_idMO='340057'
GROUP BY cc.id,c.id ,cc.AmountPayment,c.rf_idv002,f.CodeM,a.rf_idSMO, a.rf_idMO	,a.Letter,c.rf_idRecordCasePatient 

CREATE UNIQUE NONCLUSTERED INDEX ix_1 ON #tCases(rf_idCase) WITH IGNORE_DUP_KEY

INSERT #tCases
SELECT DISTINCT cc.id,c.id AS rf_idCase,cc.AmountPayment,c.rf_idv002,f.CodeM,a.rf_idSMO, a.rf_idMO, NULL IsCOVID,2 AS TypeP,letter,c.rf_idRecordCasePatient
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
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND a.ReportMonth>2  AND a.ReportMonth<@reportMonth 
AND c.rf_idV006=3 AND dd.TypeDiagnosis IN(1,3) AND NOT EXISTS (SELECT 1 FROM #tDiag d WHERE d.DiagnosisCode=dd.DiagnosisCode AND d.TypeDiag=dd.TypeDiagnosis) AND l.PFA=1
AND a.rf_idMO='340057'
SELECT @@ROWCOUNT

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c 											
								WHERE c.DateRegistration>=@dateStartRegRAK AND c.DateRegistration<@dateEndRegRAK
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

SELECT  5 AS IdRow,'2.1.10' AS ColName,c.rf_idMO AS MCOD,0 AS Col1,NULL AS Col2,0.0 AS Col4
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

SELECT DISTINCT 5 AS IdRow,'2.1.10' AS ColName,l.mcod AS MCOD,0 AS Col1,NULL AS Col2,0.0 AS Col4
	,NULL AS Col5,NULL AS col6,c.AmountPayment AS Col7
	,0.0 AS Col8
FROM dbo.t_AdditionalAccounts202003 c INNER JOIN #tLPU l ON
			c.CodeLPU=l.CodeM
WHERE c.NumberRegister=6 AND c.ReportYearMonth=202004
GO
DROP TABLE #tMU
GO
DROP TABLE #tCases
go
DROP TABLE #tLPU
GO
DROP TABLE #tDiag

