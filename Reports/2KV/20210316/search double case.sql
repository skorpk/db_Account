USE AccountOMS
GO
------------------јмбулаторна€ помощь(помощь)----------------------
DECLARE @dateStartReg DATETIME='20210101',
		@dateEndReg DATETIME='20210316',
		@dateStartRegRAK DATETIME='20210101',
		@dateEndRegRAK DATETIME='20210316',
		@reportYear SMALLINT=2021,
		@reportMonth TINYINT=2

DECLARE @dateStartRegPrev DATETIME='20200101',
		@dateEndRegPrev DATETIME='20200316',
		@dateStartRegRAKPrev DATETIME='20200101',
		@dateEndRegRAKPrev DATETIME='20200319',
		@reportYearPrev SMALLINT=2020


DECLARE @reportPeriod INT=202102

---таблица с параметрами. —делана дл€ того что бы объ€вить только тут и потом не прописывать параметры каждый раз
CREATE TABLE #tParams(dateStartReg datetime,dateEndReg DATETIME,dateEndRegRAK DATETIME,reportYear SMALLINT,reportMonth TINYINT,reportPeriod INT
					,dateStartRegPrev datetime,dateEndRegPrev DATETIME,dateEndRegRAKPrev DATETIME,reportYearPrev SMALLINT)

INSERT #tParams
VALUES(  @dateStartReg , @dateEndReg ,@dateEndRegRAK,@reportYear,@reportMonth, @reportPeriod,@dateStartRegPrev , @dateEndRegPrev ,@dateEndRegRAKPrev,@reportYearPrev)

SELECT 1 AS TypeDiag,DiagnosisCode INTO #tDiag FROM dbo.vw_sprMKB10 WHERE MainDS BETWEEN 'J12' AND 'J18'

INSERT #tDiag(TypeDiag,DiagnosisCode) VALUES(1,'Z03.8'),(1,'Z22.8'),(1,'Z20.8'),(1,'Z11.5'),(1,'B34.2'),(1,'B33.8'),(1,'U07.1'),(1,'U07.2')
			,(3,'Z20.8'),(3,'B34.2'),(3,'U07.1'),(3,'U07.2')

CREATE UNIQUE NONCLUSTERED INDEX IX_Diag ON #tDiag(DiagnosisCode,TypeDiag)

SELECT CodeM,mcod,1 AS PFA INTO #tLPU FROM dbo.vw_sprT001 WHERE pfa=1 AND DateEnd>'20210101'
UNION 
SELECT CodeM,mcod, 1 AS PFA FROM dbo.vw_sprT001 WHERE pfv=1 AND DateEnd>'20210101'

--обращени€
SELECT MUGroupCode,MUUnGroupCode,MUCode, MU,1 AS TypeMU INTO #tMU FROM dbo.vw_sprMU WHERE MUGroupCode=2 AND MUUnGroupCode=78 AND MUCode NOT BETWEEN 54 AND 60
delete  FROM #tMU WHERE MUGroupCode=2 AND MUUnGroupCode=78 AND MUCode BETWEEN 90 AND 91 AND TypeMU=1--15/02/2021

insert #tMU SELECT DISTINCT MUGroupCode,MUUnGroupCode,MUCode, MU,4 AS TypeMU FROM dbo.vw_sprMU WHERE MUGroupCode=2 AND MUUnGroupCode=78 AND MUCode NOT BETWEEN 54 AND 60 
--insert #tMU SELECT DISTINCT MUGroupCode,MUUnGroupCode,MUCode, MU,4 AS TypeMU FROM dbo.vw_sprMU WHERE MUGroupCode=2 AND MUUnGroupCode=89
delete  FROM #tMU WHERE MUGroupCode=2 AND MUUnGroupCode=78 AND MUCode BETWEEN 90 AND 91 AND TypeMU=4

--посещени€
insert #tMU SELECT MUGroupCode,MUUnGroupCode,MUCode, MU,2  FROM dbo.vw_sprMU WHERE MUGroupCode=2 AND MUUnGroupCode=76 --15/02/2021
insert #tMU SELECT MUGroupCode,MUUnGroupCode,MUCode, MU,2  FROM dbo.vw_sprMU WHERE MUGroupCode=2 AND MUUnGroupCode=79 AND MUCode NOT BETWEEN 59 AND 64
insert #tMU SELECT MUGroupCode,MUUnGroupCode,MUCode, MU,2  FROM dbo.vw_sprMU WHERE MUGroupCode=2 AND MUUnGroupCode=81
insert #tMU SELECT MUGroupCode,MUUnGroupCode,MUCode, MU,2  FROM dbo.vw_sprMU WHERE MUGroupCode=2 AND MUUnGroupCode=88 AND MUCode NOT BETWEEN 46 AND 51
---------------MU 4.*-------------------------
insert #tMU SELECT MUGroupCode,MUUnGroupCode,MUCode, MU,3  FROM dbo.vw_sprMU WHERE MUGroupCode=4 AND MUUnGroupCode IN(8,11,12,13,14,15,16)
insert #tMU SELECT MUGroupCode,MUUnGroupCode,MUCode, MU,3  FROM dbo.vw_sprMU WHERE MUGroupCode=4 AND MUUnGroupCode=17  AND MUCode NOT IN(785,786)
insert #tMU SELECT MUGroupCode,MUUnGroupCode,MUCode, MU,3  FROM dbo.vw_sprMU WHERE MUGroupCode=4 AND MUUnGroupCode=20  AND MUCode=702

SELECT cc.id,c.id AS rf_idCase,cc.AmountPayment,c.rf_idv002,f.CodeM,a.rf_idSMO, a.rf_idMO
	,COUNT(CASE WHEN dd.DiagnosisCode IN ('U07.1','U07.2') THEN 1 ELSE NULL END) IsCOVID,1 AS TypeCase,f.TypeFile
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
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND a.ReportMonth=@reportMonth 
AND c.rf_idV006=3 AND dd.TypeDiagnosis IN(1,3) AND EXISTS(SELECT 1 FROM #tDiag d WHERE d.DiagnosisCode=dd.DiagnosisCode AND d.TypeDiag=dd.TypeDiagnosis) AND l.PFA=1
GROUP BY cc.id,c.id ,cc.AmountPayment,c.rf_idv002,f.CodeM,a.rf_idSMO, a.rf_idMO	,f.TypeFile	 

CREATE UNIQUE NONCLUSTERED INDEX ix_1 ON #tCases(rf_idCase) WITH IGNORE_DUP_KEY
INSERT #tCases
SELECT DISTINCT cc.id,c.id AS rf_idCase,cc.AmountPayment,c.rf_idv002,f.CodeM,a.rf_idSMO, a.rf_idMO, 0 IsCOVID,2 AS TypeP,f.TypeFile
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
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND a.ReportMonth=@reportMonth 
AND c.rf_idV006=3 AND dd.TypeDiagnosis IN(1,3) AND NOT EXISTS (SELECT 1 FROM #tDiag d WHERE d.DiagnosisCode=dd.DiagnosisCode AND d.TypeDiag=dd.TypeDiagnosis) AND l.PFA=1

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c 											
								WHERE c.DateRegistration>=@dateStartRegRAK AND c.DateRegistration<@dateEndRegRAK
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase


SELECT  c.rf_idCase
INTO #tCase_2_1_1_1
FROM #tCases c 
WHERE c.TypeCase=1 AND EXISTS(SELECT 1 FROM dbo.t_MES m INNER JOIN #tMU mm ON mm.MU = m.mes WHERE m.rf_idCase=c.rf_idCase AND mm.TypeMU=1)


SELECT DISTINCT c.rf_idCase
INTO #tCase_2_1_1_2
FROM #tCases c  INNER JOIN (SELECT MU,rf_idCase,SUM(Quantity) AS Quantity FROM dbo.t_Meduslugi GROUP BY rf_idCase,MU) m ON
			m.rf_idCase=c.rf_idCase 
			INNER JOIN #tMU mm ON 
			mm.MU = m.MU 
			AND mm.TypeMU=2
WHERE c.TypeCase=1 AND rf_idSMO<>'34'
PRINT(@@ROWCOUNT)
PRINT('----------------------')
SELECT * FROM #tCases WHERE rf_idCase=125064234


SELECT  1 AS IdRow,'2.1.1.1' AS ColName,rf_idMO AS MCOD
	,0 AS Col1,CAST(NULL AS INT) AS Col2,0.0 AS Col4
	,CASE WHEN rf_idSMO<>'34' THEN 1 ELSE NULL END AS Col5
	,CAST(NULL AS INT) AS col6
	,CASE WHEN rf_idSMO<>'34' THEN AmountPayment ELSE 0.0 END AS Col7
	,0.0 AS Col8
FROM #tCases c 
WHERE c.TypeCase=1 AND EXISTS(SELECT 1 FROM dbo.t_MES m INNER JOIN #tMU mm ON mm.MU = m.mes WHERE m.rf_idCase=c.rf_idCase AND mm.TypeMU=1) AND c.rf_idCase=125064234

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
WHERE c.TypeCase=1 AND c.rf_idCase=125064234
GROUP BY c.rf_idMO,CASE WHEN rf_idSMO<>'34' THEN AmountPayment ELSE 0.0 END 

SELECT  3 AS IdRow,'2.1.1.1.1' AS ColName,rf_idMO AS MCOD,0 AS Col1,NULL AS Col2,0.0 AS Col4
	,CASE WHEN rf_idSMO<>'34' THEN 1 ELSE NULL END AS Col5
	,NULL AS col6
	,CASE WHEN rf_idSMO<>'34' THEN AmountPayment ELSE 0.0 END AS Col7
	,0.0 AS Col8
FROM #tCases c 
WHERE c.TypeCase=1 AND c.IsCOVID>0 AND EXISTS(SELECT 1 FROM dbo.t_mes m INNER JOIN #tMU mm ON mm.MU = m.mes WHERE m.rf_idCase=c.rf_idCase AND mm.TypeMU=1) AND c.rf_idCase=125064234

SELECT  4 AS IdRow,'2.1.1.1.2' AS ColName,c.rf_idMO AS MCOD,0 AS Col1,NULL AS Col2,0.0 AS Col4
	,CASE WHEN rf_idSMO<>'34' THEN m.Quantity ELSE NULL END AS Col5
	,NULL AS col6
	,CASE WHEN rf_idSMO<>'34' THEN AmountPayment ELSE 0.0 END AS Col7
	,0.0 AS Col8
FROM #tCases c  INNER JOIN (SELECT MU,rf_idCase,SUM(Quantity) AS Quantity FROM dbo.t_Meduslugi GROUP BY rf_idCase,MU) m ON
			m.rf_idCase=c.rf_idCase 
			INNER JOIN #tMU mm ON 
			mm.MU = m.MU 
			AND mm.TypeMU=2
WHERE c.TypeCase=1 AND c.IsCOVID>0  AND c.rf_idCase=125064234


SELECT 5 AS IdRow,'2.1.10' AS ColName,c.rf_idMO AS MCOD,0 AS Col1,NULL AS Col2,0.0 AS Col4
	,(CASE WHEN c.rf_idSMO<>'34' THEN c.Quantity ELSE NULL END) AS Col5
	,NULL AS col6
	,CASE WHEN c.rf_idSMO<>'34' THEN AmountPayment ELSE 0.0 END AS Col7
	,0.0 AS Col8
from(SELECT DISTINCT id,c.rf_idMO,m.Quantity,c.AmountPayment,c.rf_idSMO
	FROM #tCases c  INNER JOIN (SELECT MU,rf_idCase,SUM(Quantity) AS Quantity FROM dbo.t_Meduslugi GROUP BY rf_idCase,MU) m ON
				m.rf_idCase=c.rf_idCase 
				INNER JOIN #tMU mm ON 
				mm.MU = m.MU 
				AND mm.TypeMU=2
	WHERE c.TypeCase=2 AND c.rf_idCase=125064234
	) c


SELECT  5 AS IdRow,'2.1.10' AS ColName,c.rf_idMO AS MCOD,0 AS Col1,NULL AS Col2,0.0 AS Col4
	,(CASE WHEN rf_idSMO<>'34' THEN 1 ELSE NULL END) AS Col5
	,NULL AS col6
	,CASE WHEN c.rf_idSMO<>'34' THEN AmountPayment ELSE 0.0 END AS Col7
	,0.0 AS Col8
FROM #tCases c WHERE c.TypeFile='F'  AND c.rf_idCase=125064234

SELECT 6 AS IdRow,'2.1.11' AS ColName,rf_idMO AS MCOD,0 AS Col1,NULL AS Col2,0.0 AS Col4
	,CASE WHEN rf_idSMO<>'34' THEN 1 ELSE NULL END AS Col5
	,NULL AS col6
	,CASE WHEN rf_idSMO<>'34' THEN AmountPayment ELSE 0.0 END AS Col7
	,0.0 AS Col8
FROM #tCases c 
WHERE c.TypeCase=2 AND EXISTS(SELECT 1 FROM dbo.t_mes m INNER JOIN #tMU mm ON mm.MU = m.MES WHERE m.rf_idCase=c.rf_idCase AND mm.TypeMU=4) AND c.rf_idCase=125064234

GO
DROP TABLE #tMU
GO
DROP TABLE #tCases
go
DROP TABLE #tLPU
GO
DROP TABLE #tDiag
GO
DROP TABLE #tParams
GO
DROP TABLE #tCase_2_1_1_1
GO
DROP TABLE #tCase_2_1_1_2