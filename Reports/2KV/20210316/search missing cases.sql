USE AccountOMS
GO
------------------Амбулаторная помощь(помощь)----------------------
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

-----------------------------------------Складываю случаи---------------
SELECT DISTINCT c.rf_idCase, 1 AS Col1
INTO #tMissingCases
FROM #tCases c 
WHERE c.TypeCase=1 AND EXISTS(SELECT 1 FROM dbo.t_MES m INNER JOIN #tMU mm ON mm.MU = m.mes WHERE m.rf_idCase=c.rf_idCase AND mm.TypeMU=1)
AND rf_idSMO<>'34'
UNION ALL-------------------------------------------------------
SELECT DISTINCT c.rf_idCase,2
FROM #tCases c  INNER JOIN (SELECT MU,rf_idCase,SUM(Quantity) AS Quantity FROM dbo.t_Meduslugi GROUP BY rf_idCase,MU) m ON
			m.rf_idCase=c.rf_idCase 
			INNER JOIN #tMU mm ON 
			mm.MU = m.MU 
			AND mm.TypeMU=2
WHERE c.TypeCase=1 AND rf_idSMO<>'34'

UNION ALL-----------------------2.1.10-------------
SELECT DISTINCT c.rf_idCase,4
from(SELECT DISTINCT c.rf_idCase,id,c.rf_idMO,m.Quantity,c.AmountPayment,c.rf_idSMO
	FROM #tCases c  INNER JOIN (SELECT MU,rf_idCase,SUM(Quantity) AS Quantity FROM dbo.t_Meduslugi GROUP BY rf_idCase,MU) m ON
				m.rf_idCase=c.rf_idCase 
				INNER JOIN #tMU mm ON 
				mm.MU = m.MU 
				AND mm.TypeMU=2
	WHERE c.TypeCase=2
	) c
WHERE rf_idSMO<>'34'
UNION ALL--15/02/2021
SELECT DISTINCT c.rf_idCase,5
FROM #tCases c WHERE c.TypeFile='F'  AND c.rf_idSMO<>'34'
UNION ALL----------------------------------------------2.1.11---------------------------------
SELECT DISTINCT c.rf_idCase,51
FROM #tCases c 
WHERE c.TypeCase=2 AND EXISTS(SELECT 1 FROM dbo.t_mes m INNER JOIN #tMU mm ON mm.MU = m.MES WHERE m.rf_idCase=c.rf_idCase AND mm.TypeMU=4)
AND c.rf_idSMO<>'34'
GO
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

SELECT DISTINCT c.rf_idCase INTO #tCase_2_2_1_1
FROM #tCases c 
WHERE c.rf_idMO<>'34' AND c.TypeCase=1 AND EXISTS(SELECT 1 FROM dbo.t_Mes m INNER JOIN #tMU mm ON mm.MU = m.MES WHERE m.rf_idCase=c.rf_idCase AND mm.TypeMU=1)	
	AND NOT EXISTS(SELECT 1 FROM #tCase_2_1_1_1 c1 WHERE c1.rf_idCase=c.rf_idCase)


SELECT DISTINCT c.rf_idCase INTO #tCase_2_2_1_2
FROM #tCases c INNER JOIN (SELECT MU,rf_idCase,SUM(Quantity) AS Quantity FROM dbo.t_Meduslugi GROUP BY rf_idCase,MU) m ON
			m.rf_idCase=c.rf_idCase 
			INNER JOIN #tMU mm ON 
			mm.MU = m.MU 
			AND mm.TypeMU=2
WHERE c.rf_idMO<>'34' AND c.TypeCase=1 AND NOT EXISTS(SELECT 1 FROM #tCase_2_1_1_2 cc WHERE cc.rf_idCase=c.rf_idCase)


--------------------------------------Складываю случаи---------------

INSERT #tMissingCases 
SELECT DISTINCT c.rf_idCase,6
FROM #tCases c 
WHERE c.rf_idSMO<>'34' AND c.TypeCase=1 AND EXISTS(SELECT 1 FROM dbo.t_Mes m INNER JOIN #tMU mm ON mm.MU = m.MES WHERE m.rf_idCase=c.rf_idCase AND mm.TypeMU=1)	
	AND NOT EXISTS(SELECT 1 FROM #tCase_2_1_1_1 c1 WHERE c1.rf_idCase=c.rf_idCase)
INSERT #tMissingCases 

SELECT DISTINCT c.rf_idCase,7
FROM #tCases c 
WHERE c.rf_idSMO='34' AND c.TypeCase=1 AND EXISTS(SELECT 1 FROM dbo.t_Mes m INNER JOIN #tMU mm ON mm.MU = m.MES WHERE m.rf_idCase=c.rf_idCase AND mm.TypeMU=11)	

iNSERT #tMissingCases
SELECT DISTINCT c.rf_idCase,8
FROM #tCases c INNER JOIN (SELECT MU,rf_idCase,SUM(Quantity) AS Quantity FROM dbo.t_Meduslugi GROUP BY rf_idCase,MU) m ON
			m.rf_idCase=c.rf_idCase 
			INNER JOIN #tMU mm ON 
			mm.MU = m.MU 
			AND mm.TypeMU=2
WHERE c.rf_idSMO<>'34' AND c.TypeCase=1 AND NOT EXISTS(SELECT 1 FROM #tCase_2_1_1_2 cc WHERE cc.rf_idCase=c.rf_idCase)

iNSERT #tMissingCases
SELECT DISTINCT c.rf_idCase,9
FROM #tCases c INNER JOIN (SELECT MU,rf_idCase,SUM(Quantity) AS Quantity FROM dbo.t_Meduslugi GROUP BY rf_idCase,MU) m ON
			m.rf_idCase=c.rf_idCase 
			INNER JOIN #tMU mm ON 
			mm.MU = m.MU 
			AND mm.TypeMU=21
WHERE c.rf_idsMO='34' AND c.TypeCase=1


iNSERT #tMissingCases 
SELECT DISTINCT c.rf_idCase,12
FROM #tCases c INNER join (SELECT m.rf_idCase ,SUM(m.Quantity) Quantity FROM dbo.t_Meduslugi m WHERE  m.MUGroupCode=60 AND m.MUUnGroupCode=4 GROUP BY m.rf_idCase) m ON
			m.rf_idCase=c.rf_idCase 			

iNSERT #tMissingCases 
SELECT DISTINCT c.rf_idCase,13
FROM #tCases c INNER join (SELECT m.rf_idCase ,SUM(m.Quantity) Quantity FROM dbo.t_Meduslugi m WHERE  m.MUGroupCode=60 AND m.MUUnGroupCode=5 GROUP BY m.rf_idCase) m ON
			m.rf_idCase=c.rf_idCase 
---------------------------------------------------------MU 60.6.*---------------------------------------------------

iNSERT #tMissingCases 
SELECT DISTINCT c.rf_idCase,14
FROM #tCases c INNER join (SELECT m.rf_idCase ,SUM(m.Quantity) Quantity FROM dbo.t_Meduslugi m WHERE  m.MUGroupCode=60 AND m.MUUnGroupCode=6 GROUP BY m.rf_idCase) m ON
			m.rf_idCase=c.rf_idCase 

iNSERT #tMissingCases 
SELECT DISTINCT c.rf_idCase,15
FROM #tCases c INNER join (SELECT m.rf_idCase ,SUM(m.Quantity) Quantity FROM dbo.t_Meduslugi m WHERE  m.MUGroupCode=60 AND m.MUUnGroupCode=7 GROUP BY m.rf_idCase) m ON
			m.rf_idCase=c.rf_idCase 

iNSERT #tMissingCases 
SELECT DISTINCT c.rf_idCase,16
FROM #tCases c INNER join (SELECT m.rf_idCase ,SUM(m.Quantity) Quantity FROM dbo.t_Meduslugi m WHERE  m.MUGroupCode=60 AND m.MUUnGroupCode=8 GROUP BY m.rf_idCase) m ON
			m.rf_idCase=c.rf_idCase 

iNSERT #tMissingCases 
SELECT DISTINCT c.rf_idCase,17
FROM #tCases c INNER join (SELECT m.rf_idCase ,SUM(m.Quantity) Quantity FROM dbo.t_Meduslugi m WHERE  m.MUGroupCode=60 AND m.MUUnGroupCode=9 GROUP BY m.rf_idCase) m ON
			m.rf_idCase=c.rf_idCase 

iNSERT #tMissingCases 
SELECT DISTINCT c.rf_idCase,228
FROM #tCases c INNER join (SELECT m.rf_idCase ,SUM(m.Quantity) Quantity 
						   FROM dbo.t_Meduslugi m 
						   WHERE m.MUGroupCode=4 AND m.MUUnGroupCode=17 AND m.MUCode =787 
						   GROUP BY m.rf_idCase) m ON
			m.rf_idCase=c.rf_idCase 			

iNSERT #tMissingCases 
SELECT DISTINCT c.rf_idCase,19
FROM (SELECT distinct rf_idCase,AmountPayment,rf_idSMO,rf_idMO FROM #tCases) c 
WHERE EXISTS(SELECT 1 FROM dbo.t_Meduslugi m WHERE 	m.rf_idCase=c.rf_idCase AND m.MUGroupCode=60 AND m.MUUnGroupCode=3)

iNSERT #tMissingCases 
SELECT DISTINCT c.rf_idCase,20
FROM #tCases c INNER JOIN #tLPU l ON
		l.mcod = c.rf_idMO
				INNER JOIN (SELECT rf_idCase,SUM(Quantity) AS Quantity FROM dbo.t_Meduslugi m WHERE  m.MUGroupCode=2 AND m.MUUnGroupCode IN(79,81,88) GROUP BY rf_idCase,MU) m on 
		m.rf_idCase=c.rf_idCase 		
WHERE c.Letter='T'  AND c.rf_idSMO<>'34'

iNSERT #tMissingCases 
SELECT DISTINCT c.rf_idCase,21
FROM #tCases c INNER JOIN (SELECT rf_idCase,SUM(Quantity) AS Quantity FROM dbo.t_Meduslugi m WHERE  m.MUGroupCode=2 AND m.MUUnGroupCode IN(76,79,81,88) GROUP BY rf_idCase,MU) m on 
		m.rf_idCase=c.rf_idCase 		
WHERE c.TypeCase=2  AND c.rf_idSMO<>'34' AND NOT EXISTS(SELECT 1 FROM #tLPU l WHERE l.mcod = c.rf_idMO)
AND NOT exists(SELECT 1 FROM #tCase_2_2_1_2 tt WHERE c.rf_idCase=tt.rf_idCase)

iNSERT #tMissingCases 
SELECT DISTINCT c.rf_idCase,22
FROM #tCases c INNER JOIN (SELECT rf_idCase,SUM(Quantity) AS Quantity FROM dbo.t_Meduslugi m WHERE  m.MUGroupCode=2 AND m.MUUnGroupCode IN(76,79,81,88) GROUP BY rf_idCase,MU) m on 
		m.rf_idCase=c.rf_idCase 		
WHERE c.TypeCase=2  AND c.rf_idSMO='34' 

iNSERT #tMissingCases 
SELECT DISTINCT c.rf_idCase,23
FROM #tCases c 
WHERE c.TypeFile='F'  AND c.rf_idSMO='34'
-------------------------------------------------------2.2.11---------------------------------

iNSERT #tMissingCases
SELECT DISTINCT c.rf_idCase,24
FROM #tCases c INNER JOIN dbo.t_MES m on 
		m.rf_idCase=c.rf_idCase 			 			
WHERE c.TypeCase=2  AND c.rf_idSMO='34' AND m.MES LIKE '2.78.%' 

iNSERT #tMissingCases
SELECT DISTINCT c.rf_idCase,25
FROM #tCases c INNER JOIN dbo.t_MES m on 
		m.rf_idCase=c.rf_idCase 
WHERE /*c.TypeCase=2  AND*/ c.rf_idSMO='34' AND m.MES LIKE '2.89.%'

iNSERT #tMissingCases
SELECT DISTINCT c.rf_idCase,2211
FROM #tCases c INNER JOIN (SELECT DISTINCT rf_idCase
							FROM  dbo.t_Meduslugi m1 INNER JOIN #tMU m2 ON
									m1.MU=m2.MU
									AND m2.TypeMU=4 
							WHERE Price>0.0
							) m1 ON
        c.rf_idCase=m1.rf_idCase				

INSERT #tMissingCases 
SELECT DISTINCT c.rf_idCase,27
FROM #tCases c INNER JOIN dbo.t_MES m on 
		m.rf_idCase=c.rf_idCase 	
				INNER JOIN #tLPU l ON
		c.rf_idMO=l.mcod		
WHERE c.rf_idSMO<>'34' AND m.mes LIKE '2.78.%' AND c.Letter='T' AND NOT exists(SELECT 1 FROM #tCase_2_2_1_1 tt WHERE c.rf_idCase=tt.rf_idCase)

INSERT #tMissingCases 
SELECT DISTINCT c.rf_idCase,28
FROM #tCases c INNER JOIN dbo.t_MES m on 
		m.rf_idCase=c.rf_idCase 	
				INNER JOIN #tLPU l ON
		c.rf_idMO=l.mcod		
WHERE /*c.TypeCase=2  AND*/ c.rf_idSMO<>'34' AND m.mes LIKE '2.78.9[0-1]' AND NOT exists(SELECT 1 FROM #tCase_2_2_1_1 tt WHERE c.rf_idCase=tt.rf_idCase)

INSERT #tMissingCases 
SELECT DISTINCT c.rf_idCase ,29
FROM #tCases c INNER JOIN dbo.t_MES m on 
		m.rf_idCase=c.rf_idCase 		
			INNER JOIN #tLPU l ON
		c.rf_idMO=l.mcod							
WHERE c.rf_idSMO<>'34' AND m.mes LIKE '2.89.%' AND NOT exists(SELECT 1 FROM #tCase_2_2_1_1 tt WHERE c.rf_idCase=tt.rf_idCase)--берутся все случаи, не обращщаем внимания на диагноз
--------------------------Не подушевое----------------------------------

INSERT #tMissingCases 
SELECT DISTINCT c.rf_idCase,30
FROM #tCases c INNER JOIN dbo.t_MES m on 
		m.rf_idCase=c.rf_idCase 									 						
WHERE c.TypeCase=2  AND c.rf_idSMO<>'34' AND m.mes LIKE '2.78.%' AND NOT EXISTS (SELECT 1 FROM #tLPU WHERE mcod=c.rf_idMO)

INSERT #tMissingCases 
SELECT DISTINCT c.rf_idCase,31
FROM #tCases c INNER JOIN dbo.t_MES m on 
		m.rf_idCase=c.rf_idCase 				
WHERE c.rf_idSMO<>'34' AND m.mes LIKE '2.89.%' AND NOT EXISTS (SELECT 1 FROM #tLPU WHERE mcod=c.rf_idMO)
GO
DROP TABLE #tMU
GO
DROP TABLE #tCases
GO
DROP TABLE #tLPU
GO
DROP TABLE #tDiag
GO
DROP TABLE #tCase_2_1_1_1
go
DROP TABLE #tCase_2_2_1_1
go
DROP TABLE #tCase_2_2_1_2
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
----------------------------------Берем всю амбулаторку--------------------
SELECT DISTINCT cc.id,c.id AS rf_idCase
INTO #tAmb
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_CompletedCase cc ON
            r.id=cc.rf_idRecordCasePatient			
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND a.ReportMonth=@reportMonth
AND c.rf_idV006=3 


INSERT #tMissingCases 
SELECT DISTINCT rf_idCase,32
FROM #tCases
WHERE AmountPayment>0 AND TypeP=1

--INSERT #tMissingCases 
--SELECT DISTINCT rf_idCase,33
--FROM #tCases
--WHERE AmountPayment>0 AND IsCOVID=1 AND TypeP=1

INSERT #tMissingCases 
SELECT DISTINCT rf_idCase,34
FROM #tCases
WHERE AmountPayment>0 AND TypeP=2

----------------------------------------------
SELECT m.*
FROM #tMissingCases m JOIN (
							SELECT 'Дубли' AS DoubleCol,rf_idCase
							FROM #tMissingCases
							GROUP BY rf_idCase
							HAVING COUNT(*)>1
							) d ON
                 m.rf_idCase=d.rf_idCase
ORDER BY d.rf_idCase,m.Col1


SELECT 'Пропущенные случаи #tAmb', m.rf_idCase
FROM #tMissingCases m WHERE NOT EXISTS(SELECT 1  FROM #tAmb a WHERE a.rf_idCase=m.rf_idCase)

SELECT 'Пропущенные случаи #tMissingCases',m.rf_idCase
FROM #tAmb m WHERE NOT EXISTS(SELECT 1  FROM #tMissingCases a WHERE a.rf_idCase=m.rf_idCase)
go
DROP TABLE #tCases
go
DROP TABLE #tDiag
GO
DROP TABLE #tMissingCases
GO
DROP TABLE #tParams
GO
DROP TABLE #tAmb