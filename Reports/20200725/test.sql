USE AccountOMS
GO
DECLARE @dateStartReg DATETIME='20200101',
		@dateEndReg DATETIME='20200725',
		@dateStartRegRAK DATETIME='20200724',
		@dateEndRegRAK DATETIME=GETDATE(),
		@reportYear SMALLINT=2020,
		@reportMonth TINYINT=7
declare @firstDayNextMonth date
SET @firstDayNextMonth=DATEADD(MONTH,1,'2020'+RIGHT('0'+CAST(@reportMonth-1 AS VARCHAR(2)),2)+'01')

SELECT DISTINCT c.id AS rf_idCase, cc.AmountPayment,f.CodeM,p.ENP,DATEDIFF(YEAR,pp.BirthDay,GETDATE()) AS Age,c.rf_idV006 AS USL_OK,c.rf_idRecordCasePatient,pp.rf_idV005 AS Sex, d.flag,f.TypeFile,@firstDayNextMonth AS dd, 1 AS TypeDs
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
					INNER JOIN oms_nsi.dbo.tmp_DS2report202007 d ON
             dd.DiagnosisCode=d.КОД					
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND a.ReportMonth<@reportMonth  AND  a.rf_idSMO<>'34'  AND dd.TypeDiagnosis=1 

--CREATE UNIQUE NONCLUSTERED INDEX IXCase ON #t(rf_idCase,flag,enp) WITH IGNORE_DUP_KEY

INSERT #t
SELECT DISTINCT c.id AS rf_idCase, cc.AmountPayment,f.CodeM,p.ENP,DATEDIFF(YEAR,pp.BirthDay,GETDATE()) AS Age,c.rf_idV006 AS USL_OK,c.rf_idRecordCasePatient,pp.rf_idV005 AS Sex, d.flag,f.TypeFile,@firstDayNextMonth AS dd,2
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
					INNER JOIN oms_nsi.dbo.tmp_DS2report202007 d ON
			dd.DiagnosisCode=d.КОД
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND a.ReportMonth<@reportMonth AND  a.rf_idSMO<>'34' AND f.TypeFile='F' AND dd.TypeDiagnosis<>1 


INSERT #t
SELECT DISTINCT c.id AS rf_idCase, cc.AmountPayment,f.CodeM,p.ENP,DATEDIFF(YEAR,pp.BirthDay,GETDATE()) AS Age,c.rf_idV006 AS USL_OK,c.rf_idRecordCasePatient,pp.rf_idV005 AS Sex, d.flag,f.TypeFile,@firstDayNextMonth AS dd,2
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
					INNER JOIN oms_nsi.dbo.tmp_DS2report202007 d ON
             dd.DiagnosisCode=d.КОД											
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND a.ReportMonth<@reportMonth AND  a.rf_idSMO<>'34' AND f.TypeFile='F' 

DELETE FROM #t WHERE Age<18

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #t p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStartRegRAK AND c.DateRegistration<@dateEndRegRAK AND c.TypeCheckup=1
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
-----------------------------определение страховой принадлежности--------------------
ALTER TABLE #t ADD LPU CHAR(6)
ALTER TABLE #t ADD Q CHAR(5)
ALTER TABLE #t ADD PID INT
ALTER TABLE #t ADD [sid] INT
ALTER TABLE #t ADD [lid] INT

CREATE NONCLUSTERED INDEX IX_1 ON #t(ENP) INCLUDE(PID) 

UPDATE e SET PID=p.Id
FROM #t e INNER JOIN PolicyRegister.dbo.PEOPLE p ON
		e.enp=p.ENP

--UPDATE e SET PID=p.PID
--FROM #t e INNER JOIN PolicyRegister.dbo.HISTENP p ON
--		e.enp=p.ENP
--WHERE e.pid IS null

--SELECT * FROM #t WHERE pid IS NULL 

EXEC Utility.dbo.sp_GetIdPolisLPU

CREATE NONCLUSTERED INDEX IX_Temp1
ON #t ([USL_OK],[TypeFile],[TypeDs],[AmountPayment],[sid])
INCLUDE ([rf_idCase],[ENP],[Age],[Sex],[flag])

-------------------------------------3----------------

;WITH cteCol4
AS(
SELECT DISTINCT d.ENP,n.flag,d.Age,d.sex_ENP AS Sex
FROM dbo.DNPersons202007 d INNER JOIN oms_nsi.dbo.tmp_DS2report202007 n ON
		d.DS=n.[КОД]
WHERE NOT EXISTS(SELECT 1 FROM PolicyRegister.dbo.PEOPLE p WHERE p.ENP=d.enp AND p.DS IS NOT null )
UNION ALL
SELECT DISTINCT enp,flag,t.Age,sex
FROM #t t INNER JOIN dbo.t_PurposeOfVisit p on
		t.rf_idCase=p.rf_idCase
WHERE t.sid IS NOT NULL AND t.TypeFile='H' AND p.rf_idV025='1.3' AND t.USL_OK=3 AND p.DN IN(1,2) AND t.AmountPayment>0
UNION ALL
SELECT DISTINCT enp,flag,t.Age,t.Sex
FROM #t t INNER JOIN dbo.t_Case p on
		t.rf_idCase=p.id
WHERE t.sid IS NOT NULL AND t.TypeFile='F' AND t.USL_OK=3 AND p.IsNeedDisp IN(1,2) AND t.TypeDs=1 AND t.AmountPayment>0
UNION ALL
SELECT DISTINCT enp,t.flag,t.Age,t.Sex
FROM  dbo.t_DS2_Info p 	INNER JOIN oms_nsi.dbo.tmp_DS2report202007 d ON
             p.DiagnosisCode=d.КОД	
			 INNER JOIN #t t ON
           p.rf_idCase=t.rf_idCase
		   AND d.flag=t.flag
WHERE t.sid IS NOT NULL AND t.TypeFile='F' AND t.USL_OK=3 AND p.IsNeedDisp IN(1,2) AND t.TypeDs=2 AND t.AmountPayment>0
)
SELECT flag,COUNT(DISTINCT enp) AS Col3
		,COUNT(distinct CASE WHEN c.Sex=1 AND age<65 THEN c.ENP ELSE NULL end) AS Col4
		,COUNT(distinct CASE WHEN c.Sex=1 AND age>=65 THEN c.ENP ELSE NULL end) AS Col5
		-------distinct ---Женщины--------------------------------------------------
		,COUNT(distinct CASE WHEN c.Sex=2 AND age< 59 THEN c.ENP ELSE NULL end) AS Col6
		,COUNT(distinct CASE WHEN c.Sex=2 AND age>=59 THEN c.ENP ELSE NULL end) AS Col7
FROM cteCol4 c GROUP BY flag ORDER BY Flag


--SELECT * FROM #t WHERE enp='3454740891000412'
----------------------------Таблица Крайнов-------------------------------
/*
;WITH cteCol4
AS(
SELECT DISTINCT d.ENP,n.flag,d.Age,d.sex_ENP AS Sex,'Max' AS OwnerP
FROM dbo.DNPersons202007 d INNER JOIN oms_nsi.dbo.tmp_DS2report202007 n ON
		d.DS=n.[КОД]
WHERE NOT EXISTS(SELECT 1 FROM PolicyRegister.dbo.PEOPLE p WHERE p.ENP=d.enp AND ISNULL(p.DS,'22220101')<@firstDayNextMonth )
UNION ALL
SELECT DISTINCT enp,flag,t.Age,sex,'Sergey'
FROM #t t INNER JOIN dbo.t_PurposeOfVisit p on
		t.rf_idCase=p.rf_idCase
WHERE t.sid IS NOT NULL AND t.TypeFile='H' AND p.rf_idV025='1.3' AND t.USL_OK=3 AND p.DN IN(1,2) AND t.AmountPayment>0
UNION ALL
SELECT DISTINCT enp,flag,t.Age,t.Sex,'Sergey'
FROM #t t INNER JOIN dbo.t_Case p on
		t.rf_idCase=p.id
WHERE t.sid IS NOT NULL AND t.TypeFile='F' AND t.USL_OK=3 AND p.IsNeedDisp IN(1,2) AND t.TypeDs=1 AND t.AmountPayment>0
UNION ALL
SELECT DISTINCT enp,t.flag,t.Age,t.Sex,'Sergey'
FROM  dbo.t_DS2_Info p 	INNER JOIN oms_nsi.dbo.tmp_DS2report202007 d ON
             p.DiagnosisCode=d.КОД	
			 INNER JOIN #t t ON
           p.rf_idCase=t.rf_idCase
		   AND d.flag=t.flag
WHERE t.sid IS NOT NULL AND t.TypeFile='F' AND t.USL_OK=3 AND p.IsNeedDisp IN(1,2) AND t.TypeDs=2 AND t.AmountPayment>0
)
SELECT *
FROM cteCol4 c 
WHERE NOT EXISTS(SELECT 1 FROM t_dnlnold WHERE flag=c.flag AND enp=c.enp AND DataD IS null) ORDER BY c.OwnerP
*/
----------------------------Таблица Антонововой-------------------------------
/*
;WITH cteCol4
AS(
SELECT DISTINCT d.ENP,n.flag,d.Age,d.sex_ENP AS Sex
FROM dbo.DNPersons202007 d INNER JOIN oms_nsi.dbo.tmp_DS2report202007 n ON
		d.DS=n.[КОД]
WHERE NOT EXISTS(SELECT 1 FROM PolicyRegister.dbo.PEOPLE p WHERE p.ENP=d.enp AND ISNULL(p.DS,'22220101')<@firstDayNextMonth)
UNION ALL
SELECT DISTINCT enp,flag,t.Age,sex
FROM #t t INNER JOIN dbo.t_PurposeOfVisit p on
		t.rf_idCase=p.rf_idCase
WHERE t.sid IS NOT NULL AND t.TypeFile='H' AND p.rf_idV025='1.3' AND t.USL_OK=3 AND p.DN IN(1,2) AND t.AmountPayment>0
UNION ALL
SELECT DISTINCT enp,flag,t.Age,t.Sex
FROM #t t INNER JOIN dbo.t_Case p on
		t.rf_idCase=p.id
WHERE t.sid IS NOT NULL AND t.TypeFile='F' AND t.USL_OK=3 AND p.IsNeedDisp IN(1,2) AND t.TypeDs=1 AND t.AmountPayment>0
UNION ALL
SELECT DISTINCT enp,t.flag,t.Age,t.Sex
FROM  dbo.t_DS2_Info p 	INNER JOIN oms_nsi.dbo.tmp_DS2report202007 d ON
             p.DiagnosisCode=d.КОД	
			 INNER JOIN #t t ON
           p.rf_idCase=t.rf_idCase
		   AND d.flag=t.flag
WHERE t.sid IS NOT NULL AND t.TypeFile='F' AND t.USL_OK=3 AND p.IsNeedDisp IN(1,2) AND t.TypeDs=2 AND t.AmountPayment>0
)
SELECT *
FROM t_dnlnold c 
WHERE NOT EXISTS(SELECT 1 FROM cteCol4 WHERE flag=c.flag AND enp=c.enp ) AND DataD IS NULL
*/
GO
DROP TABLE #t
GO
