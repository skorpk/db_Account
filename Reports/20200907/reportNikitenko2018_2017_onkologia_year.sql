USE AccountOMS
go
DECLARE @dateStartReg DATETIME='20170101',
		@dateEndReg DATETIME='20190125',
		@dateStartRegRAK DATETIME='20170101',
		@dateEndRegRAK DATETIME=GETDATE()

DECLARE @dd DATE='20190101'		

SELECT DiagnosisCode ,MainDS INTO #tDiag FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'C%'
INSERT #tDiag SELECT DiagnosisCode ,MainDS FROM dbo.vw_sprMKB10 WHERE MainDS BETWEEN 'D00' AND 'D48'

SELECT DiagnosisCode ,MainDS INTO #tDiag2 FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'C%'
INSERT #tDiag2 SELECT DiagnosisCode ,MainDS FROM dbo.vw_sprMKB10 WHERE MainDS BETWEEN 'D00' AND 'D09'


CREATE UNIQUE NONCLUSTERED INDEX ix_1 ON #tDiag(DiagnosisCode)
CREATE UNIQUE NONCLUSTERED INDEX ix_1 ON #tDiag2(DiagnosisCode)
---------------------------------------------------2018-------------------------------------------------
SELECT DISTINCT c.id AS rf_idCase, c.AmountPayment,p.ENP,a.ReportMonth,a.ReportYear,@dd AS dd,CASE WHEN d.MainDS BETWEEN 'D10' AND 'D48' THEN 1 ELSE 0 END AS IdTypeCol12
INTO #t
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient					
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient					
					INNER JOIN dbo.vw_Diagnosis dd ON
			c.id=dd.rf_idCase						
					INNER JOIN #tDiag d ON
             dd.DS1=d.DiagnosisCode
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=2018 AND f.TypeFile='H' AND c.rf_idV006 =3 AND a.rf_idSMO<>'34'

INSERT #t
SELECT DISTINCT c.id AS rf_idCase, c.AmountPayment,p.ENP,a.ReportMonth,a.ReportYear,@dd AS dd,CASE WHEN d.MainDS BETWEEN 'D10' AND 'D48' THEN 1 ELSE 0 END AS IdTypeCol12
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient						
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient			
					INNER JOIN dbo.t_Diagnosis dd ON
			c.id=dd.rf_idCase						
					INNER JOIN #tDiag d ON
             dd.DiagnosisCode=d.DiagnosisCode	
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg AND a.ReportYear =2018  AND f.TypeFile='F'
	 AND c.rf_idV006 =3   AND a.rf_idSMO<>'34'

INSERT #t
SELECT DISTINCT c.id AS rf_idCase, c.AmountPayment,p.ENP,a.ReportMonth,a.ReportYear,@dd AS dd,CASE WHEN d.MainDS BETWEEN 'D10' AND 'D48' THEN 1 ELSE 0 END AS IdTypeCol12
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient						
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient			
					INNER JOIN dbo.t_DS2_Info dd ON
			c.id=dd.rf_idCase						
					INNER JOIN #tDiag d ON
             dd.DiagnosisCode=d.DiagnosisCode	
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear =2018 AND f.TypeFile='F' AND c.rf_idV006 =3  AND a.rf_idSMO<>'34'

-------------------------------------------2017-----------------------------------------
INSERT #t
SELECT DISTINCT c.id AS rf_idCase, c.AmountPayment,p.ENP,a.ReportMonth,2018,@dd AS dd,CASE WHEN d.MainDS BETWEEN 'D10' AND 'D48' THEN 1 ELSE 0 END AS IdTypeCol12
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts										
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case_PID_ENP p ON
            c.id=p.rf_idCase
					INNER JOIN dbo.vw_Diagnosis dd ON
			c.id=dd.rf_idCase						
					INNER JOIN #tDiag d ON
             dd.DS1=d.DiagnosisCode					
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=2017 AND f.TypeFile='H' AND c.rf_idV006 <4 AND a.rf_idSMO<>'34'
	AND p.enp IS NOT NULL


UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #t p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStartRegRAK AND c.DateRegistration<@dateEndRegRAK AND c.TypeCheckup=1
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

ALTER TABLE #t ADD LPU CHAR(6)
ALTER TABLE #t ADD Q CHAR(5)
ALTER TABLE #t ADD PID INT
ALTER TABLE #t ADD [sid] INT
ALTER TABLE #t ADD [lid] INT

CREATE NONCLUSTERED INDEX IX_1 ON #t(ENP) INCLUDE(PID) 

UPDATE e SET PID=p.Id
FROM #t e INNER JOIN PolicyRegister.dbo.PEOPLE p ON
		e.enp=p.ENP
WHERE e.AmountPayment>0

CREATE NONCLUSTERED INDEX IX_2 ON #t(Pid) INCLUDE(dd,sid,lid,lpu,Q)


EXEC Utility.dbo.sp_GetIdPolisLPU

CREATE TABLE #tTotal(idRow INT, Col1   varchar(16) null)			

INSERT #tTotal(idRow,Col1)
SELECT distinct 1 , ENP
FROM #t t
WHERE t.sid IS NOT NULL 

SELECT p.ENP,c.DateEnd
INTO #tENP
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts										
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN #t t ON
            p.enp=t.enp
					INNER JOIN dbo.t_Meduslugi m ON
            c.id=m.rf_idCase
WHERE f.DateRegistration>='20180101' AND f.DateRegistration<@dateEndReg AND a.ReportYear=2018 AND a.Letter='K' AND m.MUGroupCode=60 AND m.MUUnGroupCode IN(4,5,7,8,9) AND t.sid IS NOT NULL 
UNION ALL
SELECT p.ENP,c.DateEnd
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts										
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN #t t ON
            p.enp=t.enp
					INNER JOIN dbo.vw_Diagnosis dd ON
            c.id=dd.rf_idCase
					INNER JOIN #tDiag d ON
             dd.DS1=d.DiagnosisCode	
WHERE f.DateRegistration>='20180101' AND f.DateRegistration<@dateEndReg AND a.ReportYear=2018 AND a.Letter IN('Z','S','H') AND t.sid IS NOT NULL 


INSERT #tTotal(idRow,Col1)
SELECT 2 ,t.ENP	
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts										
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN #tENP t ON
            p.enp=t.enp
WHERE f.DateRegistration>='20180101' AND f.DateRegistration<@dateEndReg AND a.ReportYear=2018  AND c.rf_idV002 IN(18,60) AND c.DateEnd<t.DateEnd

INSERT #tTotal(idRow,Col1)
SELECT 3 ,p.ENP
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts										
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient			
					INNER JOIN dbo.t_Meduslugi m ON
            c.id=m.rf_idCase
					INNER JOIN dbo.vw_Diagnosis dd ON
            c.id=dd.rf_idCase
					INNER JOIN #tDiag2 d ON
             dd.DS1=d.DiagnosisCode	
WHERE f.DateRegistration>='20180101' AND f.DateRegistration<@dateEndReg AND a.ReportYear=2018 AND a.Letter='K' AND m.MUGroupCode=60 AND m.MUUnGroupCode IN(4,5,7,8,9) 

INSERT #tTotal(idRow,Col1)
SELECT 3 ,p.ENP
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts										
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient								
					INNER JOIN dbo.vw_Diagnosis dd ON
            c.id=dd.rf_idCase
					INNER JOIN #tDiag2 d ON
             dd.DS1=d.DiagnosisCode	
					INNER JOIN dbo.t_PurposeOfVisit pv ON
             c.id=pv.rf_idCase
WHERE f.DateRegistration>='20180101' AND f.DateRegistration<@dateEndReg AND a.ReportYear=2018 AND c.rf_idV002 IN(18,60) AND pv.rf_idV025 ='1.3'


INSERT #tTotal(idRow,Col1)
SELECT 11 ,ENP
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts										
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient		
					INNER JOIN dbo.vw_Diagnosis dd ON
            c.id=dd.rf_idCase
					INNER JOIN #tDiag2 d ON
             dd.DS1=d.DiagnosisCode					
WHERE f.DateRegistration>='20180101' AND f.DateRegistration<@dateEndReg AND a.ReportYear=2018 AND c.rf_idV002 IN(18,60) AND f.TypeFile='H' AND c.rf_idV006=1

INSERT #tTotal(idRow,Col1)
SELECT 12 , ENP
FROM #t t
WHERE t.sid IS NOT NULL AND t.IdTypeCol12=0

SELECT idRow,COUNT(DISTINCT Col1)
FROM #tTotal
GROUP BY idRow
ORDER BY idRow
GO 
DROP TABLE #tTotal
go
DROP TABLE #t
GO
DROP TABLE #tDiag
GO
DROP TABLE #tDiag2
GO
DROP TABLE #tENP