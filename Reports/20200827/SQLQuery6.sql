USE AccountOMS
GO
DECLARE @dateStartReg DATETIME='20190101',
		@dateEndReg DATETIME='20200131',
		@dateStartRegRAK DATETIME='20190101',
		@dateEndRegRAK DATETIME=GETDATE(),
		@reportYear SMALLINT=2019

declare @firstDayNextMonth DATE='20200101'
SELECT DiagnosisCode,MainDS INTO #tDiag FROM dbo.vw_sprMKB10 WHERE MainDS BETWEEN 'I00' AND 'I99'
UNION ALL
SELECT DiagnosisCode,MainDS FROM dbo.vw_sprMKB10 WHERE MainDS ='G45'

SELECT DISTINCT c.id AS rf_idCase, cc.AmountPayment,p.ENP,DATEDIFF(YEAR,pp.BirthDay,GETDATE()) AS Age,@firstDayNextMonth AS dd,d.MainDS,p1.DN
INTO #t
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient
					INNER JOIN dbo.t_RegisterPatient pp ON
            r.id=pp.rf_idRecordCase
			AND pp.rf_idFiles = f.id
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_CompletedCase Cc ON
			r.id=cc.rf_idRecordCasePatient
					INNER JOIN dbo.t_Diagnosis dd ON
			c.id=dd.rf_idCase						
					INNER JOIN #tDiag d ON
             dd.DiagnosisCode=d.DiagnosisCode	
					INNER JOIN dbo.t_PurposeOfVisit p1 on
			c.id=p1.rf_idCase			
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND  a.rf_idSMO<>'34'  AND dd.TypeDiagnosis=1 AND c.rf_idV006=3 AND p1.DN IN(1,2)

INSERT #t
SELECT DISTINCT c.id AS rf_idCase, cc.AmountPayment,p.ENP,DATEDIFF(YEAR,pp.BirthDay,GETDATE()) AS Age,@firstDayNextMonth AS dd,d.MainDS,c.IsNeedDisp
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient
					INNER JOIN dbo.t_RegisterPatient pp ON
            r.id=pp.rf_idRecordCase
			AND pp.rf_idFiles = f.id
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_CompletedCase Cc ON
			r.id=cc.rf_idRecordCasePatient
					INNER JOIN dbo.t_Diagnosis dd ON
			c.id=dd.rf_idCase																
					INNER JOIN #tDiag d ON
             dd.DiagnosisCode=d.DiagnosisCode				
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND  a.rf_idSMO<>'34' AND f.TypeFile='F' /*AND dd.TypeDiagnosis<>1 */AND c.Age>17 AND c.IsNeedDisp IN(1,2)
	AND c.rf_idV006=3


INSERT #t
SELECT DISTINCT c.id AS rf_idCase, cc.AmountPayment,p.ENP,DATEDIFF(YEAR,pp.BirthDay,GETDATE()) AS Age,@firstDayNextMonth AS dd,d.MainDS,dd.IsNeedDisp
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient
					INNER JOIN dbo.t_RegisterPatient pp ON
            r.id=pp.rf_idRecordCase
			AND pp.rf_idFiles = f.id
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_CompletedCase Cc ON
			r.id=cc.rf_idRecordCasePatient
					INNER JOIN dbo.t_DS2_Info dd ON
			c.id=dd.rf_idCase					
					INNER JOIN #tDiag d ON
             dd.DiagnosisCode=d.DiagnosisCode													
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND  a.rf_idSMO<>'34' AND f.TypeFile='F'  AND dd.IsNeedDisp IN(1,2) AND c.rf_idV006=3

DELETE FROM #t WHERE Age<18

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #t p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStartRegRAK AND c.DateRegistration<@dateEndRegRAK AND c.TypeCheckup=1
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
----------------------------определение страховой принадлежности--------------------
INSERT #t(rf_idCase,AmountPayment,ENP,Age,dd,MainDS,DN) SELECT 1, 10, ENP, 30, @firstDayNextMonth ,rubrikDS ,0 FROM DNPersons_20200827 WHERE [YEAR]=@reportYear

ALTER TABLE #t ADD LPU CHAR(6)
ALTER TABLE #t ADD Q CHAR(5)
ALTER TABLE #t ADD PID INT
ALTER TABLE #t ADD [sid] INT
ALTER TABLE #t ADD [lid] INT

CREATE NONCLUSTERED INDEX IX_1 ON #t(ENP) INCLUDE(PID) 
UPDATE e SET PID=p.Id
FROM #t e INNER JOIN PolicyRegister.dbo.PEOPLE p ON
		e.enp=p.ENP

UPDATE e SET PID=p.PID
FROM #t e INNER JOIN PolicyRegister.dbo.HISTENP p ON
		e.enp=p.ENP
WHERE e.pid IS null


EXEC Utility.dbo.sp_GetIdPolisLPU

;WITH cteAll
AS(
--SELECT DISTINCT d.ENP,d.rubrikDS AS MainDS,0 AS  DN
--FROM dbo.DNPersons_20200827 d 
--WHERE d.[YEAR]=@reportYear --AND NOT EXISTS(SELECT 1 FROM PolicyRegister.dbo.PEOPLE p WHERE p.ENP=d.enp AND ISNULL(p.DS,'22220101')<@firstDayNextMonth )
--UNION ALL
SELECT DISTINCT enp,t.MainDS,t.DN
FROM #t t 
WHERE t.sid IS NOT NULL AND t.AmountPayment>0
)
SELECT c.ENP,
       c.MainDS,
       c.DN
INTO #tt
FROM cteAll c

;WITH cte
AS(
SELECT 1 AS Id,enp,CASE WHEN DN=2 THEN enp ELSE NULL END AS ENP_New FROM #tt
UNION all
SELECT 2,enp,CASE WHEN DN=2 THEN enp ELSE NULL END AS ENP_New FROM #tt WHERE MainDS BETWEEN 'I20' AND 'I25'
UNION all
SELECT 3,enp,CASE WHEN DN=2 THEN enp ELSE NULL END AS ENP_New FROM #tt WHERE MainDS IN('I20','I23','I24','I25')
UNION all
SELECT 4,enp,CASE WHEN DN=2 THEN enp ELSE NULL END AS ENP_New FROM #tt WHERE MainDS IN('I21','I22')
UNION all
SELECT 5,enp,CASE WHEN DN=2 THEN enp ELSE NULL END AS ENP_New FROM #tt WHERE MainDS IN('I10','I11','I12','I13','I20','I23','I24','I25')
UNION all
SELECT 6,enp,CASE WHEN DN=2 THEN enp ELSE NULL END AS ENP_New FROM #tt WHERE MainDS IN('I10','I11','I12','I13','I20','I23','I24','I25','I48')
UNION all
SELECT 7,enp,CASE WHEN DN=2 THEN enp ELSE NULL END AS ENP_New FROM #tt WHERE MainDS IN('I20','I23','I24','I25','I50')
UNION all
SELECT 8,enp,CASE WHEN DN=2 THEN enp ELSE NULL END AS ENP_New FROM #tt WHERE MainDS IN('I20','I23','I24','I25','I48','I50')
UNION all
SELECT 9,enp,CASE WHEN DN=2 THEN enp ELSE NULL END AS ENP_New FROM #tt WHERE MainDS IN('I21','I22','I60','I61','I62','I63','I64')
UNION all
SELECT 10,enp,CASE WHEN DN=2 THEN enp ELSE NULL END AS ENP_New FROM #tt WHERE MainDS BETWEEN 'I60' AND 'I69'
UNION all
SELECT 11,enp,CASE WHEN DN=2 THEN enp ELSE NULL END AS ENP_New FROM #tt WHERE MainDS BETWEEN 'I60' AND 'I64'
UNION all
SELECT 11,enp,CASE WHEN DN=2 THEN enp ELSE NULL END AS ENP_New FROM #tt WHERE MainDS ='G45'
UNION all
SELECT 12,enp,CASE WHEN DN=2 THEN enp ELSE NULL END AS ENP_New FROM #tt WHERE MainDS BETWEEN 'I60' AND 'I64'
UNION all
SELECT 13,enp,CASE WHEN DN=2 THEN enp ELSE NULL END AS ENP_New FROM #tt WHERE MainDS ='I69'
UNION all
SELECT 14,enp,CASE WHEN DN=2 THEN enp ELSE NULL END AS ENP_New FROM #tt WHERE MainDS BETWEEN 'I10' AND 'I13'
UNION all
SELECT 15,enp,CASE WHEN DN=2 THEN enp ELSE NULL END AS ENP_New FROM #tt WHERE MainDS ='I48'
UNION all
SELECT 16,enp,CASE WHEN DN=2 THEN enp ELSE NULL END AS ENP_New FROM #tt WHERE MainDS ='I50'
)
SELECT c.id,COUNT(DISTINCT enp) AS ColAll,COUNT(DISTINCT c.ENP_New) AS ColNew
FROM cte c GROUP BY id
GO
DROP TABLE #tt
GO
DROP TABLE #t
GO
*/
--------------------------------------------------------2020---------------------------------------
DECLARE @dateStartReg DATETIME='20200101',
		@dateEndReg DATETIME='20200811',
		@dateStartRegRAK DATETIME='20200101',
		@dateEndRegRAK DATETIME=GETDATE(),
		@reportYear SMALLINT=2020

declare @firstDayNextMonth DATE='20200801'

SELECT DiagnosisCode,MainDS INTO #tDiag FROM dbo.vw_sprMKB10 WHERE MainDS BETWEEN 'I00' AND 'I99'
UNION ALL
SELECT DiagnosisCode,MainDS FROM dbo.vw_sprMKB10 WHERE MainDS ='G45'

SELECT DISTINCT c.id AS rf_idCase, cc.AmountPayment,p.ENP,DATEDIFF(YEAR,pp.BirthDay,GETDATE()) AS Age,@firstDayNextMonth AS dd,d.MainDS,p1.DN
INTO #t
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient
					INNER JOIN dbo.t_RegisterPatient pp ON
            r.id=pp.rf_idRecordCase
			AND pp.rf_idFiles = f.id
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_CompletedCase Cc ON
			r.id=cc.rf_idRecordCasePatient
					INNER JOIN dbo.t_Diagnosis dd ON
			c.id=dd.rf_idCase						
					INNER JOIN #tDiag d ON
             dd.DiagnosisCode=d.DiagnosisCode	
					INNER JOIN dbo.t_PurposeOfVisit p1 on
			c.id=p1.rf_idCase			
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND a.ReportMonth<8 AND a.rf_idSMO<>'34'  AND dd.TypeDiagnosis=1 AND c.rf_idV006=3 AND p1.DN IN(1,2)

INSERT #t
SELECT DISTINCT c.id AS rf_idCase, cc.AmountPayment,p.ENP,DATEDIFF(YEAR,pp.BirthDay,GETDATE()) AS Age,@firstDayNextMonth AS dd,d.MainDS,c.IsNeedDisp
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient
					INNER JOIN dbo.t_RegisterPatient pp ON
            r.id=pp.rf_idRecordCase
			AND pp.rf_idFiles = f.id
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_CompletedCase Cc ON
			r.id=cc.rf_idRecordCasePatient
					INNER JOIN dbo.t_Diagnosis dd ON
			c.id=dd.rf_idCase																
					INNER JOIN #tDiag d ON
             dd.DiagnosisCode=d.DiagnosisCode				
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND a.ReportMonth<8 AND a.rf_idSMO<>'34' AND f.TypeFile='F' /*AND dd.TypeDiagnosis<>1*/ AND c.Age>17 AND c.IsNeedDisp IN(1,2)
	AND c.rf_idV006=3


INSERT #t
SELECT DISTINCT c.id AS rf_idCase, cc.AmountPayment,p.ENP,DATEDIFF(YEAR,pp.BirthDay,GETDATE()) AS Age,@firstDayNextMonth AS dd,d.MainDS,dd.IsNeedDisp
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient
					INNER JOIN dbo.t_RegisterPatient pp ON
            r.id=pp.rf_idRecordCase
			AND pp.rf_idFiles = f.id
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_CompletedCase Cc ON
			r.id=cc.rf_idRecordCasePatient
					INNER JOIN dbo.t_DS2_Info dd ON
			c.id=dd.rf_idCase					
					INNER JOIN #tDiag d ON
             dd.DiagnosisCode=d.DiagnosisCode													
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND a.ReportMonth<8 AND a.rf_idSMO<>'34' AND f.TypeFile='F'  AND dd.IsNeedDisp IN(1,2) AND c.rf_idV006=3

DELETE FROM #t WHERE Age<18

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #t p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStartRegRAK AND c.DateRegistration<@dateEndRegRAK AND c.TypeCheckup=1
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
-----------------------------определение страховой принадлежности--------------------
INSERT #t(rf_idCase,AmountPayment,ENP,Age,dd,MainDS,DN) SELECT 1, 10, ENP, 30, @firstDayNextMonth ,rubrikDS ,0 FROM DNPersons_20200827 WHERE [YEAR]=@reportYear

ALTER TABLE #t ADD LPU CHAR(6)
ALTER TABLE #t ADD Q CHAR(5)
ALTER TABLE #t ADD PID INT
ALTER TABLE #t ADD [sid] INT
ALTER TABLE #t ADD [lid] INT

CREATE NONCLUSTERED INDEX IX_1 ON #t(ENP) INCLUDE(PID) 

UPDATE e SET PID=p.Id
FROM #t e INNER JOIN PolicyRegister.dbo.PEOPLE p ON
		e.enp=p.ENP

UPDATE e SET PID=p.PID
FROM #t e INNER JOIN PolicyRegister.dbo.HISTENP p ON
		e.enp=p.ENP
WHERE e.pid IS null


EXEC Utility.dbo.sp_GetIdPolisLPU

;WITH cteAll
AS(
--SELECT DISTINCT d.ENP,d.rubrikDS AS MainDS,0 AS  DN
--FROM dbo.DNPersons_20200827 d 
--WHERE d.[YEAR]=@reportYear AND NOT EXISTS(SELECT 1 FROM PolicyRegister.dbo.PEOPLE p WHERE p.ENP=d.enp AND ISNULL(p.DS,'22220101')<@firstDayNextMonth )
--UNION ALL
SELECT DISTINCT enp,t.MainDS,t.DN
FROM #t t 
WHERE t.sid IS NOT NULL AND t.AmountPayment>0
)
SELECT c.ENP,
       c.MainDS,
       c.DN
INTO #tt
FROM cteAll c

;WITH cte
AS(
SELECT 1 AS Id,enp,CASE WHEN DN=2 THEN enp ELSE NULL END AS ENP_New FROM #tt
UNION all
SELECT 2,enp,CASE WHEN DN=2 THEN enp ELSE NULL END AS ENP_New FROM #tt WHERE MainDS BETWEEN 'I20' AND 'I25'
UNION all
SELECT 3,enp,CASE WHEN DN=2 THEN enp ELSE NULL END AS ENP_New FROM #tt WHERE MainDS IN('I20','I23','I24','I25')
UNION all
SELECT 4,enp,CASE WHEN DN=2 THEN enp ELSE NULL END AS ENP_New FROM #tt WHERE MainDS IN('I21','I22')
UNION all
SELECT 5,enp,CASE WHEN DN=2 THEN enp ELSE NULL END AS ENP_New FROM #tt WHERE MainDS IN('I10','I11','I12','I13','I20','I23','I24','I25')
UNION all
SELECT 6,enp,CASE WHEN DN=2 THEN enp ELSE NULL END AS ENP_New FROM #tt WHERE MainDS IN('I10','I11','I12','I13','I20','I23','I24','I25','I48')
UNION all
SELECT 7,enp,CASE WHEN DN=2 THEN enp ELSE NULL END AS ENP_New FROM #tt WHERE MainDS IN('I20','I23','I24','I25','I50')
UNION all
SELECT 8,enp,CASE WHEN DN=2 THEN enp ELSE NULL END AS ENP_New FROM #tt WHERE MainDS IN('I20','I23','I24','I25','I48','I50')
UNION all
SELECT 9,enp,CASE WHEN DN=2 THEN enp ELSE NULL END AS ENP_New FROM #tt WHERE MainDS IN('I21','I22','I60','I61','I62','I63','I64')
UNION all
SELECT 10,enp,CASE WHEN DN=2 THEN enp ELSE NULL END AS ENP_New FROM #tt WHERE MainDS BETWEEN 'I60' AND 'I69'
UNION all
SELECT 11,enp,CASE WHEN DN=2 THEN enp ELSE NULL END AS ENP_New FROM #tt WHERE MainDS BETWEEN 'I60' AND 'I64'
UNION all
SELECT 11,enp,CASE WHEN DN=2 THEN enp ELSE NULL END AS ENP_New FROM #tt WHERE MainDS ='G45'
UNION all
SELECT 12,enp,CASE WHEN DN=2 THEN enp ELSE NULL END AS ENP_New FROM #tt WHERE MainDS BETWEEN 'I60' AND 'I64'
UNION all
SELECT 13,enp,CASE WHEN DN=2 THEN enp ELSE NULL END AS ENP_New FROM #tt WHERE MainDS ='I69'
UNION all
SELECT 14,enp,CASE WHEN DN=2 THEN enp ELSE NULL END AS ENP_New FROM #tt WHERE MainDS BETWEEN 'I10' AND 'I13'
UNION all
SELECT 15,enp,CASE WHEN DN=2 THEN enp ELSE NULL END AS ENP_New FROM #tt WHERE MainDS ='I48'
UNION all
SELECT 16,enp,CASE WHEN DN=2 THEN enp ELSE NULL END AS ENP_New FROM #tt WHERE MainDS ='I50'
)
SELECT c.id,COUNT(DISTINCT enp) AS ColAll,COUNT(DISTINCT c.ENP_New) AS ColNew
FROM cte c GROUP BY id
GO
DROP TABLE #tt
GO
DROP TABLE #t
GO
DROP TABLE #tDiag