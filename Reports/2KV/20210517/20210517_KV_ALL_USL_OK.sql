USE AccountOMS
GO
------------------Амбулаторная помощь(помощь)----------------------
DECLARE @dateStartReg DATETIME='20210101',
		@dateEndReg DATETIME='20210516',
		@dateStartRegRAK DATETIME='20210101',
		@dateEndRegRAK DATETIME='20210518',
		@reportYear SMALLINT=2021,
		@reportMonth TINYINT=4

DECLARE @dateStartRegPrev DATETIME='20200101',
		@dateEndRegPrev DATETIME='20200516',
		@dateStartRegRAKPrev DATETIME='20200101',
		@dateEndRegRAKPrev DATETIME='20200519',
		@reportYearPrev SMALLINT=2020

DECLARE @reportPeriod INT=CAST(CAST(@reportYear AS CHAR(4))+RIGHT('0'+cast(@reportMonth AS VARCHAR(2)) ,2) AS INT)

SELECT @reportPeriod

---таблица с параметрами. Сделана для того что бы объявить только тут и потом не прописывать параметры каждый раз
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

--обращения
SELECT MUGroupCode,MUUnGroupCode,MUCode, MU,1 AS TypeMU INTO #tMU FROM dbo.vw_sprMU WHERE MUGroupCode=2 AND MUUnGroupCode=78 AND MUCode NOT BETWEEN 54 AND 60
delete  FROM #tMU WHERE MUGroupCode=2 AND MUUnGroupCode=78 AND MUCode BETWEEN 90 AND 91 AND TypeMU=1--15/02/2021

insert #tMU SELECT DISTINCT MUGroupCode,MUUnGroupCode,MUCode, MU,4 AS TypeMU FROM dbo.vw_sprMU WHERE MUGroupCode=2 AND MUUnGroupCode=78 AND MUCode NOT BETWEEN 54 AND 60 
--insert #tMU SELECT DISTINCT MUGroupCode,MUUnGroupCode,MUCode, MU,4 AS TypeMU FROM dbo.vw_sprMU WHERE MUGroupCode=2 AND MUUnGroupCode=89
delete  FROM #tMU WHERE MUGroupCode=2 AND MUUnGroupCode=78 AND MUCode BETWEEN 90 AND 91 AND TypeMU=4

--посещения
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
WHERE c.TypeCase=1 

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
	,SUM(CASE WHEN rf_idSMO<>'34' THEN m1.Quantity ELSE NULL END) AS Col5
	,NULL AS col6
	,SUM(CASE WHEN rf_idSMO<>'34' THEN AmountPayment ELSE 0.0 END) AS Col7
	,0.0 AS Col8
FROM (SELECT rf_idMO,rf_idCase,rf_idSMO,AmountPayment FROM #tCases WHERE TypeCase=1 ) c JOIN (SELECT rf_idCase,SUM(Quantity) AS Quantity 
																							  FROM dbo.t_Meduslugi m INNER JOIN #tMU mm ON 
																											mm.MU = m.MU 
																											AND mm.TypeMU=2
																							  GROUP BY rf_idCase) m1 ON
			m1.rf_idCase=c.rf_idCase 			
GROUP BY c.rf_idMO,CASE WHEN rf_idSMO<>'34' THEN AmountPayment ELSE 0.0 END 

UNION ALL------------------------------------
--------------------------------COVID---------------------------------
SELECT  3 AS IdRow,'2.1.1.1.1' AS ColName,rf_idMO AS MCOD,0 AS Col1,NULL AS Col2,0.0 AS Col4
	,CASE WHEN rf_idSMO<>'34' THEN 1 ELSE NULL END AS Col5
	,NULL AS col6
	,CASE WHEN rf_idSMO<>'34' THEN AmountPayment ELSE 0.0 END AS Col7
	,0.0 AS Col8
FROM #tCases c 
WHERE c.TypeCase=1 AND c.IsCOVID>0 AND EXISTS(SELECT 1 FROM dbo.t_mes m INNER JOIN #tMU mm ON mm.MU = m.mes WHERE m.rf_idCase=c.rf_idCase AND mm.TypeMU=1)
UNION ALL
SELECT  4 AS IdRow,'2.1.1.1.2' AS ColName,c.rf_idMO AS MCOD,0 AS Col1,NULL AS Col2,0.0 AS Col4
	,CASE WHEN rf_idSMO<>'34' THEN m1.Quantity ELSE NULL END AS Col5
	,NULL AS col6
	,CASE WHEN rf_idSMO<>'34' THEN AmountPayment ELSE 0.0 END AS Col7
	,0.0 AS Col8
FROM #tCases c  INNER JOIN (SELECT rf_idCase,SUM(Quantity) AS Quantity 
							FROM dbo.t_Meduslugi m INNER JOIN #tMU mm ON 
									mm.MU = m.MU 
									AND mm.TypeMU=2
							GROUP BY rf_idCase) m1 ON
			m1.rf_idCase=c.rf_idCase 			
WHERE c.TypeCase=1 AND c.IsCOVID>0 
------------------------------------------------------------------------------
UNION ALL-----------------------2.1.10-------------
SELECT 5 AS IdRow,'2.1.10' AS ColName,c.rf_idMO AS MCOD,0 AS Col1,NULL AS Col2,0.0 AS Col4
	,(CASE WHEN c.rf_idSMO<>'34' THEN c.Quantity ELSE NULL END) AS Col5
	,NULL AS col6
	,CASE WHEN c.rf_idSMO<>'34' THEN AmountPayment ELSE 0.0 END AS Col7
	,0.0 AS Col8
from(SELECT DISTINCT id,c.rf_idMO,m1.Quantity,c.AmountPayment,c.rf_idSMO
	FROM #tCases c  INNER JOIN (SELECT rf_idCase,SUM(Quantity) AS Quantity 
								FROM dbo.t_Meduslugi m  INNER JOIN #tMU mm ON 
										mm.MU = m.MU 
										AND mm.TypeMU=2 
								GROUP BY rf_idCase) m1 ON
				m1.rf_idCase=c.rf_idCase 				
	WHERE c.TypeCase=2
	) c
UNION ALL
SELECT DISTINCT 5 AS IdRow,'2.1.10' AS ColName,l.mcod AS MCOD,0 AS Col1,NULL AS Col2,0.0 AS Col4
	,NULL AS Col5,NULL AS col6,c.AmountPayment AS Col7
	,0.0 AS Col8
FROM dbo.t_AdditionalAccounts202003 c INNER JOIN #tLPU l ON
			c.CodeLPU=l.CodeM
WHERE c.NumberRegister=6 AND c.ReportYearMonth=@reportPeriod
UNION ALL--15/02/2021
SELECT  5 AS IdRow,'2.1.10' AS ColName,c.rf_idMO AS MCOD,0 AS Col1,NULL AS Col2,0.0 AS Col4
	,(CASE WHEN rf_idSMO<>'34' THEN 1 ELSE NULL END) AS Col5
	,NULL AS col6
	,CASE WHEN c.rf_idSMO<>'34' THEN AmountPayment ELSE 0.0 END AS Col7
	,0.0 AS Col8
FROM (SELECT DISTINCT rf_idMO, rf_idCase,AmountPayment,rf_idSMO FROM #tCases WHERE TypeFile='F' ) c 
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
WHERE c.NumberRegister IN(1,4) AND c.ReportYearMonth=@reportPeriod

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
       ,CAST(SUM(c.Col1) AS INt) AS Col1,COUNT(c.Col2) AS Col2
	   ,CAST(CAST(SUM(c.Col4)/1000.0 AS DECIMAL(15,2)) AS MONEY) AS Col4
	   ,CAST(SUM(ISNULL(c.Col5,0)) AS INT) AS Col5
	   ,COUNT(c.Col6) AS Col6
	   ,CAST(cast(SUM(c.Col7)/1000.0 as decimal(15,2)) AS money) AS Col7
	   ,CAST(cast(SUM(c.Col8)/1000.0 as decimal(15,2)) AS money) AS Col8
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
GO
------------------Амбулаторная помощь-------------------------------
DECLARE @dateStartReg DATETIME,
		@dateEndReg DATETIME,
		@dateStartRegRAK DATETIME,
		@dateEndRegRAK DATETIME,
		@reportYear SMALLINT,
		@reportMonth TINYINT,
		@reportPeriod int

DECLARE @dateStartRegPrev DATETIME,
		@dateEndRegPrev DATETIME,
		@dateStartRegRAKPrev DATETIME,
		@dateEndRegRAKPrev DATETIME,
		@reportYearPrev SMALLINT

SELECT @dateStartReg=dateStartReg,@dateEndReg=dateEndReg,@dateEndRegRAK=dateEndRegRAK,@reportYear=reportYear,@reportMonth=reportMonth,@reportPeriod =reportPeriod 
,@dateStartRegPrev=dateStartRegPrev,@dateEndRegPrev=dateEndRegPrev,@dateEndRegRAKPrev=dateEndRegRAKPrev,@reportYearPrev=reportYearPrev
FROM #tParams


SELECT 1 AS TypeDiag,DiagnosisCode INTO #tDiag FROM dbo.vw_sprMKB10 WHERE MainDS BETWEEN 'J12' AND 'J18'

INSERT #tDiag(TypeDiag,DiagnosisCode) VALUES(1,'Z03.8'),(1,'Z22.8'),(1,'Z20.8'),(1,'Z11.5'),(1,'B34.2'),(1,'B33.8'),(1,'U07.1'),(1,'U07.2')
			,(3,'Z20.8'),(3,'B34.2'),(3,'U07.1'),(3,'U07.2')
CREATE UNIQUE NONCLUSTERED INDEX IX_Diag ON #tDiag(DiagnosisCode,TypeDiag)

SELECT CodeM,mcod,1 AS PFA INTO #tLPU FROM dbo.vw_sprT001 WHERE pfa=1 AND DateEnd>'20200101'
UNION 
SELECT CodeM,mcod, 1 AS PFA FROM dbo.vw_sprT001 WHERE pfv=1 AND DateEnd>'20200101'

--обращения
SELECT MUGroupCode,MUUnGroupCode,MUCode, MU,1 AS TypeMU INTO #tMU FROM dbo.vw_sprMU WHERE MUGroupCode=2 AND MUUnGroupCode=78 --AND MUCode NOT BETWEEN 54 AND 60
UNION all
SELECT MUGroupCode,MUUnGroupCode,MUCode, MU,11 AS TypeMU FROM dbo.vw_sprMU WHERE MUGroupCode=2 AND MUUnGroupCode=78 AND MUCode NOT BETWEEN 54 AND 60
--посещения
insert #tMU SELECT MUGroupCode,MUUnGroupCode,MUCode, MU,2  FROM dbo.vw_sprMU WHERE MUGroupCode=2 AND MUUnGroupCode=79 
insert #tMU SELECT MUGroupCode,MUUnGroupCode,MUCode, MU,2  FROM dbo.vw_sprMU WHERE MUGroupCode=2 AND MUUnGroupCode=81
insert #tMU SELECT MUGroupCode,MUUnGroupCode,MUCode, MU,2  FROM dbo.vw_sprMU WHERE MUGroupCode=2 AND MUUnGroupCode=88 AND MUCode NOT BETWEEN 46 AND 51

insert #tMU SELECT MUGroupCode,MUUnGroupCode,MUCode, MU,21  FROM dbo.vw_sprMU WHERE MUGroupCode=2 AND MUUnGroupCode=79 AND MUCode NOT BETWEEN 59 AND 64
insert #tMU SELECT MUGroupCode,MUUnGroupCode,MUCode, MU,21  FROM dbo.vw_sprMU WHERE MUGroupCode=2 AND MUUnGroupCode=81
insert #tMU SELECT MUGroupCode,MUUnGroupCode,MUCode, MU,21  FROM dbo.vw_sprMU WHERE MUGroupCode=2 AND MUUnGroupCode=88 AND MUCode NOT BETWEEN 46 AND 51
---------------MU 4.*-------------------------
insert #tMU SELECT MUGroupCode,MUUnGroupCode,MUCode, MU,3  FROM dbo.vw_sprMU WHERE MUGroupCode=4 AND MUUnGroupCode IN(8,11,12,13,14,15,16)
insert #tMU SELECT MUGroupCode,MUUnGroupCode,MUCode, MU,3  FROM dbo.vw_sprMU WHERE MUGroupCode=4 AND MUUnGroupCode=17  AND MUCode NOT IN(785,786)
insert #tMU SELECT MUGroupCode,MUUnGroupCode,MUCode, MU,3  FROM dbo.vw_sprMU WHERE MUGroupCode=4 AND MUUnGroupCode=20  AND MUCode=702
insert #tMU SELECT MUGroupCode,MUUnGroupCode,MUCode, MU,3  FROM dbo.vw_sprMU WHERE MUGroupCode=4 AND MUUnGroupCode=27  AND MUCode=1 --15/02/2021
insert #tMU SELECT MUGroupCode,MUUnGroupCode,MUCode, MU,3  FROM dbo.vw_sprMU WHERE MUGroupCode=60 AND MUUnGroupCode IN(4,5)
---------------MU 4.*-------------------------
insert #tMU SELECT MUGroupCode,MUUnGroupCode,MUCode, MU,4  FROM dbo.vw_sprMU WHERE MUGroupCode=4 AND MUUnGroupCode IN(8,11,12,13,14,15,16)
insert #tMU SELECT MUGroupCode,MUUnGroupCode,MUCode, MU,4  FROM dbo.vw_sprMU WHERE MUGroupCode=4 AND MUUnGroupCode=17  AND MUCode NOT IN(785,786,787)
insert #tMU SELECT MUGroupCode,MUUnGroupCode,MUCode, MU,4  FROM dbo.vw_sprMU WHERE MUGroupCode=4 AND MUUnGroupCode=20  AND MUCode=702
insert #tMU SELECT MUGroupCode,MUUnGroupCode,MUCode, MU,4  FROM dbo.vw_sprMU WHERE MUGroupCode=4 AND MUUnGroupCode=27  AND MUCode=1


DELETE FROM #tMU WHERE MUGroupCode=4 AND MUUnGroupCode=11 AND MUCode=736 AND TypeMU=4
DELETE FROM #tMU WHERE MUGroupCode=4 AND MUUnGroupCode=12 AND MUCode=775 AND TypeMU=4

SELECT cc.id,c.id AS rf_idCase,cc.AmountPayment,c.rf_idv002,f.CodeM,a.rf_idSMO, a.rf_idMO
	,COUNT(CASE WHEN dd.DiagnosisCode IN ('U07.1','U07.2') THEN 1 ELSE NULL END) IsCOVID,1 AS TypeCase, f.TypeFile,a.Letter
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
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND a.ReportMonth=@reportMonth
AND c.rf_idV006=3 AND dd.TypeDiagnosis IN(1,3) AND EXISTS(SELECT 1 FROM #tDiag d WHERE d.DiagnosisCode=dd.DiagnosisCode AND d.TypeDiag=dd.TypeDiagnosis) 
GROUP BY cc.id,c.id ,cc.AmountPayment,c.rf_idv002,f.CodeM,a.rf_idSMO, a.rf_idMO	,f.TypeFile,a.Letter	 

CREATE UNIQUE NONCLUSTERED INDEX ix_1 ON #tCases(rf_idCase) INCLUDE(AmountPayment,rf_idSMO,rf_idMO,TypeCase) WITH IGNORE_DUP_KEY
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
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND a.ReportMonth=@reportMonth
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
	,COUNT(CASE WHEN dd.DiagnosisCode IN ('U07.1','U07.2') THEN 1 ELSE NULL END) IsCOVID,1 AS TypeCase,f.TypeFile,a.Letter
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
WHERE f.DateRegistration>=@dateStartRegPrev AND f.DateRegistration<@dateEndRegPrev  AND a.ReportYear=@reportYearPrev AND a.ReportMonth=@reportMonth
AND c.rf_idV006=3 AND dd.TypeDiagnosis IN(1,3) AND EXISTS(SELECT 1 FROM #tDiag d WHERE d.DiagnosisCode=dd.DiagnosisCode AND d.TypeDiag=dd.TypeDiagnosis) 
GROUP BY cc.id,c.id ,cc.AmountPayment,c.rf_idv002,f.CodeM,a.rf_idSMO, a.rf_idMO	,f.TypeFile	,a.Letter 

CREATE UNIQUE NONCLUSTERED INDEX ix_2 ON #tCases(rf_idCase) WITH IGNORE_DUP_KEY
INSERT #tCases2019
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
WHERE f.DateRegistration>=@dateStartRegPrev AND f.DateRegistration<@dateEndRegPrev  AND a.ReportYear=@reportYearPrev AND a.ReportMonth=@reportMonth
AND c.rf_idV006=3 AND dd.TypeDiagnosis IN(1,3) AND NOT EXISTS (SELECT 1 FROM #tDiag d WHERE d.DiagnosisCode=dd.DiagnosisCode AND d.TypeDiag=dd.TypeDiagnosis) 

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases2019 p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c 											
								WHERE c.DateRegistration>=@dateStartRegRAKPrev AND c.DateRegistration<@dateEndRegRAKPrev
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
;WITH cte
AS(
------------------------------------------------------
SELECT  1 AS IdRow,'2.2.1.1' AS ColName,rf_idMO AS MCOD
	,0 AS Col1,CAST(NULL AS INT) AS Col2,0.0 AS Col4
	,CASE WHEN rf_idSMO<>'34' THEN 1 ELSE 0 END AS Col5
	,0 AS col6
	,CASE WHEN rf_idSMO<>'34' THEN AmountPayment ELSE 0.0 END AS Col7
	,0.0 AS Col8
FROM #tCases c 
WHERE c.rf_idMO<>'34' AND c.TypeCase=1 AND EXISTS(SELECT 1 FROM dbo.t_Mes m INNER JOIN #tMU mm ON mm.MU = m.MES WHERE m.rf_idCase=c.rf_idCase AND mm.TypeMU=1)	
	AND NOT EXISTS(SELECT 1 FROM #tCase_2_1_1_1 c1 WHERE c1.rf_idCase=c.rf_idCase)
UNION all
SELECT  1 AS IdRow,'2.2.1.1' AS ColName,rf_idMO AS MCOD
	,0 AS Col1,CAST(NULL AS INT) AS Col2,0.0 AS Col4
	,0 AS Col5
	,CASE WHEN rf_idSMO='34' THEN 1 ELSE 0 END AS col6
	,0.0 AS Col7
	,CASE WHEN rf_idSMO='34' THEN AmountPayment ELSE 0.0 END AS Col8
FROM #tCases c 
WHERE c.rf_idMO='34' AND c.TypeCase=1 AND EXISTS(SELECT 1 FROM dbo.t_Mes m INNER JOIN #tMU mm ON mm.MU = m.MES WHERE m.rf_idCase=c.rf_idCase AND mm.TypeMU=11)	
UNION ALL
SELECT 2 AS IdRow,'2.2.1.2' AS ColName,c.rf_idMO AS MCOD
	,0 AS Col1,CAST(NULL AS INT) AS Col2,0.0 AS Col4
	,CASE WHEN rf_idSMO<>'34' THEN m1.Quantity ELSE 0 END AS Col5
	,0 AS col6
	,CASE WHEN rf_idSMO<>'34' THEN AmountPayment ELSE 0.0 END AS Col7
	,0.0 AS Col8
FROM #tCases c INNER JOIN (SELECT rf_idCase,SUM(Quantity) AS Quantity 
							FROM dbo.t_Meduslugi m INNER JOIN #tMU mm ON 
								mm.MU = m.MU 
								AND mm.TypeMU=2
								GROUP BY rf_idCase) m1 ON
			m1.rf_idCase=c.rf_idCase 			
WHERE c.rf_idMO<>'34' AND c.TypeCase=1 AND NOT EXISTS(SELECT 1 FROM #tCase_2_1_1_2 cc WHERE cc.rf_idCase=c.rf_idCase)
UNION ALL
SELECT 2 AS IdRow,'2.2.1.2' AS ColName,c.rf_idMO AS MCOD
	,0 AS Col1,CAST(NULL AS INT) AS Col2,0.0 AS Col4	
	,0 AS col5
	,CASE WHEN rf_idSMO='34' THEN m1.Quantity ELSE 0 END AS Col6
	,0.0 AS Col7
	,CASE WHEN rf_idSMO='34' THEN AmountPayment ELSE 0.0 END AS Col8	
FROM #tCases c INNER JOIN (SELECT rf_idCase,SUM(Quantity) AS Quantity 
							FROM dbo.t_Meduslugi m INNER JOIN #tMU mm ON 
							mm.MU = m.MU 
							AND mm.TypeMU=21
							GROUP BY rf_idCase) m1 ON
			m1.rf_idCase=c.rf_idCase 
			
WHERE c.rf_idMO='34' AND c.TypeCase=1

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
UNION ALL--15/02/2021
SELECT  3 AS IdRow,'2.2.1.1.1' AS ColName,rf_idMO AS MCOD
	,0 AS Col1
	,CASE WHEN rf_idSMO='34' THEN 1 ELSE 0 end AS Col2
	,CASE WHEN rf_idSMO='34' THEN AmountPayment ELSE 0.0 END AS Col4
	,0 AS Col5,0 AS col6,0 AS Col7,0 aS Col8
FROM #tCases2019 c 
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
UNION ALL
SELECT  4 AS IdRow,'2.2.1.2.1' AS ColName,rf_idMO AS MCOD
	,0 AS Col1
	,CASE WHEN rf_idSMO='34' THEN 1 ELSE 0 END AS Col2
	,CASE WHEN rf_idSMO='34' THEN AmountPayment ELSE 0.0 END AS Col4
	,0 AS Col5,0 AS col6,0 AS Col7,0 AS Col8
FROM #tCases2019 c 
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
UNION ALL
SELECT 5 AS IdRow,'2.2.2' AS ColName,c.rf_idMO AS MCOD
	,0 AS Col1
	,(CASE WHEN rf_idSMO='34' THEN m.Quantity ELSE NULL END) AS Col2
	,CASE WHEN rf_idSMO='34' THEN AmountPayment ELSE 0.0 END AS Col4
	,0 AS Col5,0 AS Col6,0 AS Col7,0 AS Col8
FROM #tCases2019 c INNER join (SELECT m.rf_idCase ,SUM(m.Quantity) Quantity FROM dbo.t_Meduslugi m WHERE  m.MUGroupCode=60 AND m.MUUnGroupCode=4 GROUP BY m.rf_idCase) m ON
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
UNION ALL
SELECT 6 AS IdRow,'2.2.3' AS ColName,c.rf_idMO AS MCOD
	,0 AS Col1
	,(CASE WHEN rf_idSMO='34' THEN m.Quantity ELSE NULL END) AS Col2
	,CASE WHEN rf_idSMO='34' THEN AmountPayment ELSE 0.0 END AS Col4
	,0 AS Col5,0 AS Col6,0 AS Col7,0 AS Col8
FROM #tCases2019 c INNER join (SELECT m.rf_idCase ,SUM(m.Quantity) Quantity FROM dbo.t_Meduslugi m WHERE  m.MUGroupCode=60 AND m.MUUnGroupCode=5 GROUP BY m.rf_idCase) m ON
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
UNION ALL
SELECT 7 AS IdRow,'2.2.4' AS ColName,c.rf_idMO AS MCOD
	,0 AS Col1
	,(CASE WHEN rf_idSMO='34' THEN m.Quantity ELSE NULL END) AS Col2
	,CASE WHEN rf_idSMO='34' THEN AmountPayment ELSE 0.0 END AS Col4
	,0 AS Col5,0 AS Col6,0 AS Col7,0 AS Col8
FROM #tCases2019 c INNER join (SELECT m.rf_idCase ,SUM(m.Quantity) Quantity FROM dbo.t_Meduslugi m WHERE  m.MUGroupCode=60 AND m.MUUnGroupCode=6 GROUP BY m.rf_idCase) m ON
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
UNION ALL
SELECT 8 AS IdRow,'2.2.5' AS ColName,c.rf_idMO AS MCOD
	,0 AS Col1
	,(CASE WHEN rf_idSMO='34' THEN m.Quantity ELSE NULL END) AS Col2
	,CASE WHEN rf_idSMO='34' THEN AmountPayment ELSE 0.0 END AS Col4
	,0 AS Col5,0 AS Col6,0 AS Col7,0 AS Col8
FROM #tCases2019 c INNER join (SELECT m.rf_idCase ,SUM(m.Quantity) Quantity FROM dbo.t_Meduslugi m WHERE  m.MUGroupCode=60 AND m.MUUnGroupCode=7 GROUP BY m.rf_idCase) m ON
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
UNION ALL
SELECT  9 AS IdRow,'2.2.6' AS ColName,c.rf_idMO AS MCOD
	,0 AS Col1
	,(CASE WHEN rf_idSMO='34' THEN m.Quantity ELSE NULL END) AS Col2
	,CASE WHEN rf_idSMO='34' THEN AmountPayment ELSE 0.0 END AS Col4
	,0 AS Col5,0 AS Col6,0 AS Col7,0 AS Col8
FROM #tCases2019 c INNER join (SELECT m.rf_idCase ,SUM(m.Quantity) Quantity FROM dbo.t_Meduslugi m WHERE  m.MUGroupCode=60 AND m.MUUnGroupCode=8 GROUP BY m.rf_idCase) m ON
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
UNION ALL
SELECT 10 AS IdRow,'2.2.7' AS ColName,c.rf_idMO AS MCOD
	,0 AS Col1
	,(CASE WHEN rf_idSMO='34' THEN m.Quantity ELSE NULL END) AS Col2
	,CASE WHEN rf_idSMO='34' THEN AmountPayment ELSE 0.0 END AS Col4
	,0 AS Col5,0 AS Col6,0 AS Col7,0 AS Col8
FROM #tCases2019 c INNER join (SELECT m.rf_idCase ,SUM(m.Quantity) Quantity FROM dbo.t_Meduslugi m WHERE  m.MUGroupCode=60 AND m.MUUnGroupCode=9 GROUP BY m.rf_idCase) m ON
			m.rf_idCase=c.rf_idCase 			
------------------------------------------------------------------MU 4.17.*-----------------------------------
UNION ALL
SELECT 11 AS IdRow,'2.2.8' AS ColName,c.rf_idMO AS MCOD
	,0 AS Col1,CAST(NULL AS INT) AS Col2,0.0 AS Col4
	,(CASE WHEN rf_idSMO<>'34' THEN m.Quantity ELSE NULL END) AS Col5
	,(CASE WHEN rf_idSMO='34' THEN m.Quantity ELSE NULL END) AS Col6
	,CASE WHEN rf_idSMO<>'34' THEN AmountPayment ELSE 0.0 END AS Col7
	,CASE WHEN rf_idSMO='34' THEN AmountPayment ELSE 0.0 END AS Col8
FROM #tCases c INNER join (SELECT m.rf_idCase ,SUM(m.Quantity) Quantity 
						   FROM dbo.t_Meduslugi m 
						   WHERE m.MUGroupCode=4 AND m.MUUnGroupCode=17 AND m.MUCode =787 
						   GROUP BY m.rf_idCase) m ON
			m.rf_idCase=c.rf_idCase 			
UNION ALL
SELECT 11 AS IdRow,'2.2.8' AS ColName,c.rf_idMO AS MCOD
	,0 AS Col1
	,(CASE WHEN rf_idSMO='34' THEN m.Quantity ELSE NULL END) AS Col2
	,CASE WHEN rf_idSMO='34' THEN AmountPayment ELSE 0.0 END AS Col4
	,0 AS Col5,0 AS Col6,0 AS Col7,0 AS Col8
FROM #tCases2019 c INNER join (SELECT m.rf_idCase ,SUM(m.Quantity) Quantity 
							   FROM dbo.t_Meduslugi m 
							   WHERE m.MUGroupCode=4 AND m.MUUnGroupCode=17 AND m.MUCode =787 
							   GROUP BY m.rf_idCase) m ON
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
UNION ALL
SELECT 13 AS IdRow,'2.2.10' AS ColName,c.rf_idMO AS MCOD
	,0 AS Col1
	, m.Quantity AS Col2
	,AmountPayment AS Col4
	,0 AS Col5,0 AS Col6,0 AS Col7,0 AS Col8
FROM #tCases2019 c INNER JOIN (SELECT rf_idCase,SUM(Quantity) AS Quantity FROM dbo.t_Meduslugi m WHERE  m.MUGroupCode=2 AND m.MUUnGroupCode IN(79,81,88) GROUP BY rf_idCase,MU) m on 
		m.rf_idCase=c.rf_idCase 		
WHERE c.rf_idSMO='34' AND c.TypeCase=2
UNION ALL
SELECT  13 AS IdRow,'2.2.10' AS ColName,c.rf_idMO AS MCOD
	,0 AS Col1
	, m.Quantity AS Col2
	,AmountPayment AS Col4
	,0 AS Col5,0 AS Col6,0 AS Col7,0 AS Col8
FROM #tCases2019 c INNER JOIN (SELECT rf_idCase,SUM(Quantity) AS Quantity FROM dbo.t_Meduslugi m WHERE  m.MUGroupCode=2 AND m.MUUnGroupCode =76 GROUP BY rf_idCase,MU) m on 
		m.rf_idCase=c.rf_idCase 		
WHERE  c.rf_idSMO='34' AND c.TypeCase=2
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
WHERE /*c.TypeCase=2  AND*/ c.rf_idSMO='34' AND m.MES LIKE '2.89.%'
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
WHERE c.rf_idSMO<>'34' AND m.mes LIKE '2.78.%' AND c.Letter='T'
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
WHERE /*c.TypeCase=2  AND*/ c.rf_idSMO<>'34' AND m.mes LIKE '2.78.9[0-1]'
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
WHERE c.rf_idSMO<>'34' AND m.mes LIKE '2.89.%' --берутся все случаи, не обращщаем внимания на диагноз
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
WHERE c.rf_idSMO<>'34' AND m.mes LIKE '2.89.%' AND NOT EXISTS (SELECT 1 FROM #tLPU WHERE mcod=c.rf_idMO)
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
	   ,CAST(cast(SUM(c.Col4)/1000.0 as decimal(15,2)) AS money) AS Col4
	   ,CAST(SUM(ISNULL(c.Col5,0)) AS INT) AS Col5
	   ,CAST(SUM(ISNULL(c.Col6,0)) AS INT) AS Col6
	   ,CAST(cast(SUM(c.Col7)/1000.0 as decimal(15,2)) AS money) AS Col7
	   ,CAST(cast(SUM(c.Col8)/1000.0 as decimal(15,2)) AS money) AS Col8
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
GO
DROP TABLE #tCase_2_1_1_1
GO
DROP TABLE #tCase_2_1_1_2
GO
-------------------Неотложная помощь-----------------------------------
DECLARE @dateStartReg DATETIME,
		@dateEndReg DATETIME,
		@dateStartRegRAK DATETIME,
		@dateEndRegRAK DATETIME,
		@reportYear SMALLINT,
		@reportMonth TINYINT,
		@reportPeriod int

DECLARE @dateStartRegPrev DATETIME,
		@dateEndRegPrev DATETIME,
		@dateStartRegRAKPrev DATETIME,
		@dateEndRegRAKPrev DATETIME,
		@reportYearPrev SMALLINT

SELECT @dateStartReg=dateStartReg,@dateEndReg=dateEndReg,@dateEndRegRAK=dateEndRegRAK,@reportYear=reportYear,@reportMonth=reportMonth,@reportPeriod =reportPeriod 
,@dateStartRegPrev=dateStartRegPrev,@dateEndRegPrev=dateEndRegPrev,@dateEndRegRAKPrev=dateEndRegRAKPrev,@reportYearPrev=reportYearPrev
FROM #tParams

SELECT 1 AS TypeDiag,DiagnosisCode INTO #tDiag FROM dbo.vw_sprMKB10 WHERE MainDS BETWEEN 'J12' AND 'J18'

INSERT #tDiag(TypeDiag,DiagnosisCode) VALUES(1,'Z03.8'),(1,'Z22.8'),(1,'Z20.8'),(1,'Z11.5'),(1,'B34.2'),(1,'B33.8'),(1,'U07.1'),(1,'U07.2')
			,(3,'Z20.8'),(3,'B34.2'),(3,'U07.1'),(3,'U07.2')
CREATE UNIQUE NONCLUSTERED INDEX IX_Diag ON #tDiag(DiagnosisCode,TypeDiag)

SELECT cc.id,c.id AS rf_idCase,cc.AmountPayment,c.rf_idv002,f.CodeM,a.rf_idSMO, a.rf_idMO
	,COUNT(CASE WHEN dd.DiagnosisCode IN ('U07.1','U07.2') THEN 1 ELSE NULL END) IsCOVID,1 AS TypeP
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
	,COUNT(CASE WHEN dd.DiagnosisCode IN ('U07.1','U07.2') THEN 1 ELSE NULL END) IsCOVID,1 AS TypeP
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
WHERE f.DateRegistration>=@dateStartRegPrev AND f.DateRegistration<@dateEndRegPrev  AND a.ReportYear=@reportYearPrev AND a.ReportMonth=@reportMonth AND c.rf_idV006=3 AND m.MUGroupCode=2 AND m.MUUnGroupCode IN(80,82) AND a.Letter='J' AND dd.TypeDiagnosis IN(1,3)
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
WHERE f.DateRegistration>=@dateStartRegPrev AND f.DateRegistration<@dateEndRegPrev  AND a.ReportYear=@reportYearPrev AND a.ReportMonth=@reportMonth AND c.rf_idV006=3 AND m.MUGroupCode=2 AND m.MUUnGroupCode IN(80,82) AND a.Letter='J' AND dd.TypeDiagnosis IN(1,3)
	AND NOT EXISTS(SELECT 1 FROM #tDiag d WHERE d.DiagnosisCode=dd.DiagnosisCode AND d.TypeDiag=dd.TypeDiagnosis) 

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases2019 p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c 											
								WHERE c.DateRegistration>=@dateStartRegRAK AND c.DateRegistration<@dateEndRegRAKPrev
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
go
-------------------Удаляем таблицы которые участвуют в формировании данных для неотложной помощи-----------------------
DROP TABLE #tCases
go
DROP TABLE #tCases2019
go
DROP TABLE #tDiag
GO

-------------------------Стационар---------------------------------
DECLARE @dateStartReg DATETIME,
		@dateEndReg DATETIME,
		@dateStartRegRAK DATETIME,
		@dateEndRegRAK DATETIME,
		@reportYear SMALLINT,
		@reportMonth TINYINT,
		@reportPeriod int

DECLARE @dateStartRegPrev DATETIME,
		@dateEndRegPrev DATETIME,
		@dateStartRegRAKPrev DATETIME,
		@dateEndRegRAKPrev DATETIME,
		@reportYearPrev SMALLINT

SELECT @dateStartReg=dateStartReg,@dateEndReg=dateEndReg,@dateEndRegRAK=dateEndRegRAK,@reportYear=reportYear,@reportMonth=reportMonth,@reportPeriod =reportPeriod 
,@dateStartRegPrev=dateStartRegPrev,@dateEndRegPrev=dateEndRegPrev,@dateEndRegRAKPrev=dateEndRegRAKPrev,@reportYearPrev=reportYearPrev
FROM #tParams


SELECT 1 AS TypeDiag,DiagnosisCode INTO #tDiag FROM dbo.vw_sprMKB10 WHERE MainDS BETWEEN 'J12' AND 'J18'

INSERT #tDiag(TypeDiag,DiagnosisCode) VALUES(1,'Z03.8'),(1,'Z22.8'),(1,'Z20.8'),(1,'Z11.5'),(1,'B34.2'),(1,'B33.8'),(1,'U07.1'),(1,'U07.2')
			,(3,'Z20.8'),(3,'B34.2'),(3,'U07.1'),(3,'U07.2')
CREATE UNIQUE NONCLUSTERED INDEX IX_Diag ON #tDiag(DiagnosisCode,TypeDiag)

SELECT DiagnosisCode INTO #tDiagOnk FROM dbo.vw_sprMKB10 WHERE MainDS BETWEEN 'C00' AND 'C97'
UNION ALL
SELECT DiagnosisCode FROM dbo.vw_sprMKB10 WHERE MainDS BETWEEN 'D00' AND 'D09'
UNION ALL
SELECT DiagnosisCode FROM dbo.vw_sprMKB10 WHERE MainDS BETWEEN 'D45' AND 'D47'


SELECT DISTINCT cc.id,c.id AS rf_idCase,cc.AmountPayment,c.rf_idv002,f.CodeM
	,CASE WHEN dd.TypeDiagnosis=1 THEN dd.DiagnosisCode ELSE NULL END as DS1, 
		CASE WHEN dd.TypeDiagnosis=3 THEN dd.DiagnosisCode ELSE NULL END as DS2, a.rf_idSMO, a.rf_idMO	
	,CASE WHEN dd.TypeDiagnosis IN(1,3) AND  dd.DiagnosisCode in ('U07.1','U07.2') THEN 1 ELSE 0 END AS IsCovid, c.rf_idV014
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
	,CASE WHEN dd.TypeDiagnosis IN(1,3) AND  dd.DiagnosisCode in ('U07.1','U07.2') THEN 1 ELSE 0 END AS IsCovid, c.rf_idV014
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
WHERE f.DateRegistration>=@dateStartRegPrev AND f.DateRegistration<@dateEndRegPrev  AND a.ReportYear=@reportYearPrev AND a.ReportMonth=@reportMonth 
AND c.rf_idV006=1


UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases2019 p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c 											
								WHERE c.DateRegistration>=@dateStartRegRAK AND c.DateRegistration<@dateEndRegRAKPrev
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
-----------------------------------------------
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

SELECT DISTINCT c.rf_idCase
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
	WHERE AmountPayment>0 AND d.TypeDiag=3 AND NOT EXISTS(SELECT 1 FROM #tCases cc INNER JOIN #tDiagOnk dd ON
																cc.DS1=dd.DiagnosisCode
															WHERE cc.id=c.id)
	GROUP BY c.rf_idMO,c.id,c.AmountPayment,rf_idSMO
) c
UNION ALL

SELECT DISTINCT 3 AS IdRow,c.rf_idMO AS MCOD,'3.2.1' AS ColName,0 AS Col1,NULL AS Col2,0.0 AS Col4
		,CASE WHEN c.rf_idSMO<>'34' THEN c.id ELSE NULL END AS Col5
		,CASE WHEN c.rf_idSMO='34' THEN c.id ELSE NULL END AS Col6
		,CASE WHEN c.rf_idSMO<>'34' THEN c.AmountPayment ELSE 0.0 END AS Col7
		,CASE WHEN c.rf_idSMO='34' THEN c.AmountPayment ELSE 0.0 END AS Col8
FROM(
		SELECT c.rf_idMO,c.id,c.AmountPayment,rf_idSMO
		FROM #tCases c 
		WHERE AmountPayment>0 AND c.IsCovid=1 AND c.DS1 IN ('U07.1','U07.2')
		UNION 
		SELECT c.rf_idMO,c.id,c.AmountPayment,rf_idSMO
		FROM #tCases c 
		WHERE AmountPayment>0 AND c.IsCovid=1 AND c.DS2 IN ('U07.1','U07.2') AND NOT EXISTS(SELECT 1 FROM #tCases cc INNER JOIN #tDiagOnk dd ON
																						cc.DS1=dd.DiagnosisCode
																					WHERE cc.id=c.id)
	) c

UNION ALL--15/02/2021
SELECT DISTINCT 3 AS IdRow,c.rf_idMO AS MCOD,'3.2.1' AS ColName,0 AS Col1
		,CASE WHEN c.rf_idSMO='34' THEN c.id ELSE NULL END AS Col2
		,CASE WHEN c.rf_idSMO='34' THEN c.AmountPayment ELSE 0.0 END AS Col4
		,null AS Col5
		,null AS Col6
		,0 AS Col7
		,0 AS Col8
FROM(
		SELECT c.rf_idMO,c.id,c.AmountPayment,rf_idSMO
		FROM #tCases2019 c 
		WHERE AmountPayment>0 AND c.IsCovid=1 AND c.DS1 IN ('U07.1','U07.2')
		UNION 
		SELECT c.rf_idMO,c.id,c.AmountPayment,rf_idSMO
		FROM #tCases2019 c 
		WHERE AmountPayment>0 AND c.IsCovid=1 AND c.DS2 IN ('U07.1','U07.2') AND NOT EXISTS(SELECT 1 FROM #tCases cc INNER JOIN #tDiagOnk dd ON
																						cc.DS1=dd.DiagnosisCode
																					WHERE cc.id=c.id)
	) c
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
	   ,COUNT(DISTINCT c.Col5) AS Col5,COUNT(DISTINCT c.Col6) AS Col6
	   ,CAST(cast(SUM(c.Col7)/1000.0 as decimal(15,2)) AS money) AS Col7
	   ,CAST(cast(SUM(c.Col8)/1000.0 as decimal(15,2)) AS money) AS Col8
FROM cte c INNER JOIN (SELECT DISTINCT mcod,LPU_Mcode FROM dbo.vw_sprT001) l ON
		c.MCOD=l.MCOD
GROUP BY c.IdRow,c.ColName,l.mcod,l.LPU_Mcode
ORDER BY l.mcod,c.IdRow
go
-------------------Удаляем таблицы которые участвуют в формировании данных для стационара-----------------------
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

--------------------------------------Дневной стационар---------------------------
DECLARE @dateStartReg DATETIME,
		@dateEndReg DATETIME,
		@dateStartRegRAK DATETIME,
		@dateEndRegRAK DATETIME,
		@reportYear SMALLINT,
		@reportMonth TINYINT,
		@reportPeriod int

DECLARE @dateStartRegPrev DATETIME,
		@dateEndRegPrev DATETIME,
		@dateStartRegRAKPrev DATETIME,
		@dateEndRegRAKPrev DATETIME,
		@reportYearPrev SMALLINT

SELECT @dateStartReg=dateStartReg,@dateEndReg=dateEndReg,@dateEndRegRAK=dateEndRegRAK,@reportYear=reportYear,@reportMonth=reportMonth,@reportPeriod =reportPeriod 
,@dateStartRegPrev=dateStartRegPrev,@dateEndRegPrev=dateEndRegPrev,@dateEndRegRAKPrev=dateEndRegRAKPrev,@reportYearPrev=reportYearPrev
FROM #tParams

SELECT DiagnosisCode INTO #tDiagOnk FROM dbo.vw_sprMKB10 WHERE MainDS BETWEEN 'C00' AND 'C97'
UNION ALL
SELECT DiagnosisCode FROM dbo.vw_sprMKB10 WHERE MainDS BETWEEN 'D00' AND 'D09'
UNION ALL
SELECT DiagnosisCode FROM dbo.vw_sprMKB10 WHERE MainDS BETWEEN 'D45' AND 'D47'

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
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND a.ReportMonth=@reportMonth
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
WHERE f.DateRegistration>=@dateStartRegPrev AND f.DateRegistration<@dateEndRegPrev  AND a.ReportYear=@reportYearPrev AND a.ReportMonth=@reportMonth
AND c.rf_idV006=2


UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases2019 p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c 											
								WHERE c.DateRegistration>=@dateStartRegRAK AND c.DateRegistration<@dateEndRegRAKPrev
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
       CAST(SUM(c.Col1) AS INt) AS Col1,COUNT(c.Col2) AS Col2
	   ,CAST(cast(SUM(c.Col4)/1000.0 as decimal(15,2)) AS money) AS Col4
	   ,COUNT(c.Col5) AS Col5
	   ,COUNT(c.Col6) AS Col6
	   ,CAST(cast(SUM(c.Col7)/1000.0 as decimal(15,2)) AS money) AS Col7
	   ,CAST(cast(SUM(c.Col8)/1000.0 as decimal(15,2)) AS money) AS Col8
FROM cte c INNER JOIN (SELECT DISTINCT mcod,LPU_Mcode FROM dbo.vw_sprT001) l ON
		c.MCOD=l.MCOD
GROUP BY c.IdRow,c.ColName,l.mcod,l.LPU_Mcode
ORDER BY l.mcod,c.IdRow
go
-------------------Удаляем таблицы которые участвуют в формировании данных для дневного стационара-----------------------
DROP TABLE #tCase4_1_3_2019
go
DROP TABLE #tCase4_1_3
go
DROP TABLE #tCases
go
DROP TABLE #tCases2019
go
DROP TABLE #tDiagOnk
go
-------------------------СМП-----------------------------------------
DECLARE @dateStartReg DATETIME,
		@dateEndReg DATETIME,
		@dateStartRegRAK DATETIME,
		@dateEndRegRAK DATETIME,
		@reportYear SMALLINT,
		@reportMonth TINYINT,
		@reportPeriod int

DECLARE @dateStartRegPrev DATETIME,
		@dateEndRegPrev DATETIME,
		@dateStartRegRAKPrev DATETIME,
		@dateEndRegRAKPrev DATETIME,
		@reportYearPrev SMALLINT

SELECT @dateStartReg=dateStartReg,@dateEndReg=dateEndReg,@dateEndRegRAK=dateEndRegRAK,@reportYear=reportYear,@reportMonth=reportMonth,@reportPeriod =reportPeriod 
,@dateStartRegPrev=dateStartRegPrev,@dateEndRegPrev=dateEndRegPrev,@dateEndRegRAKPrev=dateEndRegRAKPrev,@reportYearPrev=reportYearPrev
FROM #tParams


SELECT 1 AS TypeDiag,DiagnosisCode INTO #tDiag FROM dbo.vw_sprMKB10 WHERE MainDS BETWEEN 'J12' AND 'J18'

INSERT #tDiag(TypeDiag,DiagnosisCode) VALUES(1,'Z03.8'),(1,'Z22.8'),(1,'Z20.8'),(1,'Z11.5'),(1,'B34.2'),(1,'B33.8'),(1,'U07.1'),(1,'U07.2')
			,(3,'Z20.8'),(3,'B34.2'),(3,'U07.1'),(3,'U07.2')
CREATE UNIQUE NONCLUSTERED INDEX IX_Diag ON #tDiag(DiagnosisCode,TypeDiag)


SELECT DISTINCT cc.id,c.id AS rf_idCase,cc.AmountPayment,c.rf_idv008,f.CodeM, 1 AS TypeCase
,COUNT(CASE WHEN  dd.DiagnosisCode IN ('U07.1','U07.2')  THEN 1 ELSE NULL END) IsCOVID, a.rf_idSMO, a.rf_idMO	
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
AND c.rf_idV006=4 AND EXISTS(SELECT 1 FROM #tDiag d WHERE d.DiagnosisCode=dd.DiagnosisCode AND d.TypeDiag=dd.TypeDiagnosis) 
GROUP BY cc.id,c.id ,cc.AmountPayment,c.rf_idv008,f.CodeM,a.rf_idSMO, a.rf_idMO

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
,CASE WHEN dd.DiagnosisCode IN ('U07.1','U07.2') THEN 1 ELSE NULL END IsCOVID, a.rf_idSMO,a.rf_idMO	
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
WHERE f.DateRegistration>=@dateStartRegPrev AND f.DateRegistration<@dateEndRegPrev  AND a.ReportYear=@reportYearPrev AND a.ReportMonth=@reportMonth AND dd.TypeDiagnosis IN(1,3)
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
WHERE f.DateRegistration>=@dateStartRegPrev AND f.DateRegistration<@dateEndRegPrev  AND a.ReportYear=@reportYearPrev AND a.ReportMonth=@reportMonth AND dd.TypeDiagnosis IN(1,3)
AND c.rf_idV006=4 AND NOT EXISTS(SELECT 1 FROM #tDiag d WHERE d.DiagnosisCode=dd.DiagnosisCode) 

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases2019 p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c 											
								WHERE c.DateRegistration>=@dateStartRegRAK AND c.DateRegistration<@dateEndRegRAKPrev
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
---------------------------------------------------------------------------------------
;WITH c
AS(
SELECT 1 AS IdRow,'5.1' AS ColName,rf_idMO AS MCOD,0 AS Col1,NULL AS Col2,0.0 AS Col4
    ,CASE WHEN AmountPayment=0.0 AND TypeCase=1 AND rf_idSMO<>'34' THEN rf_idCase ELSE NULL END AS Col5
	,CASE WHEN rf_idSMO='34' AND TypeCase=1 AND AmountPayment>0 THEN rf_idCase ELSE NULL END AS Col6
	,CASE WHEN AmountPayment=0.0 AND TypeCase=1 AND rf_idSMO<>'34' THEN 2713.4 ELSE 0.0 END AS Col7
	,CASE WHEN rf_idSMO='34' AND TypeCase=1 THEN AmountPayment ELSE 0.0 END AS Col8
FROM #tCases
UNION ALL
SELECT 2 AS IdRow,'5.1.1',rf_idMO,0 AS Col1,NULL AS Col2,0.0 AS Col4,CASE WHEN AmountPayment=0.0 AND TypeCase=1 AND IsCOVID=1 AND rf_idSMO<>'34' THEN rf_idCase ELSE NULL END AS Col5
	,CASE WHEN rf_idSMO='34' AND TypeCase=1 AND AmountPayment>0 AND IsCOVID=1 THEN rf_idCase ELSE NULL END AS Col6
	,CASE WHEN AmountPayment=0.0 AND TypeCase=1 AND IsCOVID=1 AND rf_idSMO<>'34' THEN 2713.4 ELSE 0.0 END AS Col7
	,CASE WHEN rf_idSMO='34' AND TypeCase=1 AND IsCOVID=1 THEN AmountPayment ELSE 0.0 END AS Col8
FROM #tCases
UNION ALL--15/02/2021
SELECT 2 AS IdRow,'5.1.1',rf_idMO,0 AS Col1
	,CASE WHEN rf_idSMO='34' AND TypeCase=1 AND AmountPayment>0 AND IsCOVID=1 THEN rf_idCase ELSE NULL END AS Col2
	,CASE WHEN rf_idSMO='34' AND TypeCase=1 AND IsCOVID=1 THEN AmountPayment ELSE 0.0 END  AS Col4
	,null AS Col5
	,NULL AS Col6
	,0.0 AS Col7
	,0.0 AS Col8
FROM #tCases2019
UNION all
SELECT 3 AS IdRow,'5.2',rf_idMO,0 AS Col1,NULL AS Col2,0.0 AS Col4
	,CASE WHEN /*AmountPayment=0.0 AND*/ TypeCase=2 AND rf_idSMO<>'34' THEN rf_idCase ELSE NULL END AS Col5
	,CASE WHEN rf_idSMO='34' AND TypeCase=2 AND AmountPayment>0 THEN rf_idCase ELSE NULL END AS Col6
	,CASE WHEN TypeCase=2 AND rf_idSMO<>'34' THEN AmountPayment ELSE 0.0 END AS Col7
	,CASE WHEN rf_idSMO='34' AND TypeCase=2 THEN AmountPayment ELSE 0.0 END AS Col8
FROM #tCases 
UNION all
SELECT 3 AS IdRow,'5.2',l.mcod,0 AS Col1,NULL AS Col2,0.0 AS Col4,NULL AS Col5,NULL AS Col6,AmountPayment,0.0 AS Col8
FROM dbo.t_AdditionalAccounts202003 a INNER JOIN dbo.vw_sprT001 l ON
		a.CodeLPU=l.CodeM
WHERE ReportYearMonth=@reportPeriod AND a.rf_idV006=4 
UNION ALL --отнимаем сумму по случаям ковида
SELECT 3 AS IdRow,'5.2' AS ColName,rf_idMO AS MCOD,0 AS Col1,NULL AS Col2,0.0 AS Col4
    ,null AS Col5,NULL AS Col6
	,CASE WHEN AmountPayment=0.0 AND TypeCase=1 AND rf_idSMO<>'34' THEN -2713.4 ELSE 0.0 END AS Col7,0.0
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
       CAST(SUM(c.Col1) AS INt) AS Col1,COUNT(c.Col2) AS Col2
	   ,CAST(cast(SUM(c.Col4)/1000.0 as decimal(15,2)) AS money) AS Col4
	   ,COUNT(c.Col5) AS Col5,COUNT(c.Col6) AS Col6
	   ,CAST(cast(SUM(c.Col7)/1000.0 as decimal(15,2)) AS money) AS Col7
	   ,CAST(cast(SUM(c.Col8)/1000.0 as decimal(15,2)) AS money) AS Col8
FROM c c INNER JOIN dbo.vw_sprT001 l ON
		c.MCOD=l.MCOD
GROUP BY c.IdRow,c.ColName,l.mcod,l.NAMES 
ORDER BY l.mcod,c.IdRow
go
-------------------Удаляем таблицы которые участвуют в формировании данных для СМП-----------------------
DROP TABLE #tCases
go
DROP TABLE #tCases2019
go
DROP TABLE #tDiag
GO
DROP TABLE #tParams
