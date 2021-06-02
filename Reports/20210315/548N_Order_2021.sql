USE AccountOMS
GO
DECLARE @dateStartReg DATETIME='20210101',
		@dateEndReg DATETIME=GETDATE(),
		@dateStartRegRAK DATETIME='20210101',
		@dateEndRegRAK DATETIME=GETDATE(),
		@reportYear SMALLINT=2021,
		@reportMonth TINYINT=2

DECLARE @firstDayNextMonth DATE

SET @firstDayNextMonth=(CASE WHEN @reportMonth>1 THEN DATEADD(MONTH,1,'2021'+RIGHT('0'+CAST(@reportMonth AS VARCHAR(2)),2)+'01') ELSE '20210201' END) 
SELECT @firstDayNextMonth		

SELECT DiagnosisCode INTO #tDiagC FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'C%'
INSERT #tDiagC SELECT DiagnosisCode FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'D0[0-9]%'


SELECT DISTINCT c.id AS rf_idCase, c.AmountPayment,f.CodeM,p.ENP,c.rf_idRecordCasePatient,a.ReportMonth,1 AS TypeQ
INTO #tCases
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
					INNER JOIN #tDiagC d ON
             dd.DS1=d.DiagnosisCode					
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND f.TypeFile='H' AND a.ReportMonth<=@reportMonth
	 AND c.rf_idV006 <4 AND c.Age>17 AND a.rf_idSMO<>'34'

PRINT('Query 1 -'+ CAST(@@ROWCOUNT AS VARCHAR(20)))

INSERT #tCases
SELECT DISTINCT c.id AS rf_idCase, c.AmountPayment,f.CodeM,p.ENP,c.rf_idRecordCasePatient,a.ReportMonth,2
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
					INNER JOIN #tDiagC d ON
             dd.DiagnosisCode=d.DiagnosisCode	
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND f.TypeFile='F' AND c.rf_idV006 =3 AND c.Age>17 AND a.rf_idSMO<>'34'
	AND a.ReportMonth<=@reportMonth

PRINT('Query 2 -'+ CAST(@@ROWCOUNT AS VARCHAR(20)))

INSERT #tCases
SELECT DISTINCT c.id AS rf_idCase, c.AmountPayment,f.CodeM,p.ENP,c.rf_idRecordCasePatient,a.ReportMonth,3
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
					INNER JOIN #tDiagC d ON
             dd.DiagnosisCode=d.DiagnosisCode	
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear  AND f.TypeFile='F'
	 AND c.rf_idV006 =3  AND c.Age>17 AND a.rf_idSMO<>'34' AND a.ReportMonth<=@reportMonth
PRINT('Query 3 -'+ CAST(@@ROWCOUNT AS VARCHAR(20)))

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStartRegRAK AND c.DateRegistration<@dateEndRegRAK AND c.TypeCheckup=1
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
PRINT('Query 4 -'+ CAST(@@ROWCOUNT AS VARCHAR(20)))

DELETE FROM #tCases WHERE AmountPayment=0.0


SELECT DISTINCT ENP,@firstDayNextMonth AS dd,0 AS IsListOfDN,12 as ReportMonth, 0 AS TypeQ
INTO #t 
FROM dbo.DNPersons202007 d 
WHERE d.ReportYear=@reportYear AND d.flag>27--берем только онкологию

PRINT('Insert 1 -'+ CAST(@@ROWCOUNT AS VARCHAR(20)))

ALTER TABLE #t ADD LPU CHAR(6)
ALTER TABLE #t ADD Q CHAR(5)
ALTER TABLE #t ADD PID INT
ALTER TABLE #t ADD [sid] INT
ALTER TABLE #t ADD [lid] INT

CREATE UNIQUE NONCLUSTERED INDEX IX_1 ON #t(ENP) INCLUDE(PID) WITH IGNORE_DUP_KEY

INSERT #t(enp,dd,IsListOfDN,ReportMonth,TypeQ) SELECT ENP,@firstDayNextMonth AS dd,1 AS IsListOfDN, ReportMonth,TypeQ FROM #tCases 
PRINT('Insert 2 -'+ CAST(@@ROWCOUNT AS VARCHAR(20)))

UPDATE e SET PID=p.Id
FROM #t e INNER JOIN PolicyRegister.dbo.PEOPLE p ON
		e.enp=p.ENP
CREATE NONCLUSTERED INDEX IX_2 ON #t(Pid) INCLUDE(dd,sid,lid,lpu,Q,ReportMonth)


EXEC Utility.dbo.sp_GetIdPolisLPU

;WITH cteQ
AS(
SELECT ROW_NUMBER() OVER(PARTITION BY tt.ENP ORDER BY tt.DateBegin,tt.rf_idV006) AS IdRow, tt.ENP,tt.TypeQyery
FROM (
		SELECT cc.id,cc.DateBegin,c.rf_idV006,p.ENP,3 AS TypeQyery
		FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
					f.id=a.rf_idFiles
							INNER JOIN dbo.t_RecordCasePatient r ON
					a.id=r.rf_idRegistersAccounts
							INNER JOIN dbo.t_PatientSMO p ON
		            r.id=p.rf_idRecordCasePatient			
							INNER JOIN dbo.t_Case c ON
					r.id=c.rf_idRecordCasePatient										
							INNER JOIN dbo.t_CompletedCase cc ON
		            r.id=cc.rf_idRecordCasePatient	
							INNER JOIN dbo.t_Diagnosis d ON
					c.id=d.rf_idCase
					AND d.TypeDiagnosis=1									
							INNER JOIN #tDiagC k ON
                    d.DiagnosisCode=k.DiagnosisCode
							inner JOIN t_PurposeOfVisit pv ON
		             c.id=pv.rf_idCase
							INNER JOIN #t t ON
		             p.enp=t.ENP				 
		WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND f.TypeFile='H' 
				 AND c.rf_idV006 =3 AND pv.rf_idV025='1.3' AND c.Age>17 AND a.rf_idSMO<>'34' AND c.rf_idV002 =60 AND a.ReportMonth<=@reportMonth--AND [sid] IS NOT NULL
		UNION ALL
		SELECT cc.id,cc.DateBegin,c.rf_idV006,p.ENP,4 
		FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
					f.id=a.rf_idFiles
							INNER JOIN dbo.t_RecordCasePatient r ON
					a.id=r.rf_idRegistersAccounts
							INNER JOIN dbo.t_PatientSMO p ON
		            r.id=p.rf_idRecordCasePatient			
							INNER JOIN dbo.t_Case c ON
					r.id=c.rf_idRecordCasePatient			
							INNER JOIN dbo.t_Diagnosis d ON
					c.id=d.rf_idCase
					AND d.TypeDiagnosis=1							
							INNER JOIN #tDiagC k ON
                    d.DiagnosisCode=k.DiagnosisCode
							INNER JOIN dbo.t_CompletedCase cc ON
		            r.id=cc.rf_idRecordCasePatient										
							INNER JOIN #t t ON
		             p.enp=t.ENP				 
		WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND f.TypeFile='H'
				 AND c.rf_idV006 <3 AND c.Age>17 AND a.rf_idSMO<>'34' AND c.rf_idV002 =60 AND a.ReportMonth<=@reportMonth --AND [sid] IS NOT NULL
		) tt
)
SELECT q.IdRow,
       q.ENP,
       q.TypeQyery
INTO #Total
FROM cteQ q WHERE q.IdRow=1

SELECT SUM(t.col1) AS Col1, SUM(t.Col2) AS Col2, SUM(t.Col3) AS Col3, SUM(t.Col4) AS Col4
FROM (
		SELECT count(DISTINCT ENP) AS col1, 0 AS col2,0 AS Col3,0 AS Col4 FROM #t WHERE [sid] IS NOT NULL
		UNION all
		SELECT 0,COUNT(DISTINCT p.ENP),0,0 	FROM #Total p
		UNION all
		SELECT 0,0,COUNT(DISTINCT p.ENP),0 	FROM #Total p WHERE p.TypeQyery=3
		UNION all
		SELECT 0,0,0,COUNT(DISTINCT p.ENP) 	FROM #Total p WHERE p.TypeQyery=4
	) t
	
GO
DROP TABLE #t
GO
DROP TABLE #tCases
GO
DROP TABLE #tDiagC
GO
DROP TABLE #Total