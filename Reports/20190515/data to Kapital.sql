USE PDAccountOMSReports
GO
DECLARE @dateStartReg DATETIME='20190101',
		@dateEndReg DATETIME='20190411',
		@reportYearStart SMALLINT=2019,
		@reportYearEnd SMALLINT=2019,
		@reportMonthStart TINYINT=1,
		@reportMonthEnd TINYINT=3,
		@CodeSMO CHAR(5)='34007'

declare	@dateStart DATE,
		@dateEnd DATE
	

set @dateStart=CAST(@reportYearStart AS CHAR(4))+RIGHT('0'+CAST(@reportMonthStart AS VARCHAR(2)),2)+'01'
set	@dateEnd=DATEADD(MONTH,1,CAST((CAST(@reportYearEnd AS CHAR(4))+RIGHT('0'+CAST(@reportMonthEnd AS VARCHAR(2)),2)+'01') AS DATE))

DECLARE @startPeriod INT=CAST(CAST(@reportYearStart AS VARCHAR(4))+RIGHT('0'+CAST(@reportMonthStart AS VARCHAR(2)),2) AS INT),
		@endPeriod int=CAST(CAST(@reportYearEnd AS VARCHAR(4))+RIGHT('0'+CAST(@reportMonthEnd AS VARCHAR(2)),2) AS INT)

CREATE TABLE #tmpCases(ENP VARCHAR(16),rf_idCase BIGINT, pid int)

INSERT #tmpCases( ENP, rf_idCase,pid)
SELECT ps.ENP,c.id,p.id
FROM AccountOMS.dbo.t_File f INNER JOIN AccountOMS.dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN AccountOMS.dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts                  
					INNER JOIN AccountOMS.dbo.t_Case c ON
		r.id = c.rf_idRecordCasePatient     
					INNER JOIN AccountOMS.dbo.t_PatientSMO ps ON
		r.id=ps.rf_idRecordCasePatient                         
					INNER JOIN AccountOMS.dbo.t_Diagnosis d ON
		c.id=d.rf_idCase  
					INNER JOIN PolicyRegister.dbo.PEOPLE p ON
		ps.ENP=p.ENP                
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg AND a.ReportYearMonth>=@startPeriod AND a.ReportYearMonth<=@endPeriod		
		 and c.DateEnd>=@dateStart AND c.DateEnd<@dateEnd AND d.DiagnosisCode LIKE 'C%' AND d.TypeDiagnosis IN(1,3) AND a.rf_idSMO=@CodeSMO

SELECT DISTINCT f.CodeM,a.rf_idSMO, a.Account, c.idRecordCase,f.DateRegistration,a.DateRegister,c.id AS rf_idCase, c1.PID,c.AmountPayment,c.AmountPayment AS AmountPaymentAcc,c.rf_idV006 ,d.DS3		
INTO #tmpPeople
FROM AccountOMS.dbo.t_File f INNER JOIN AccountOMS.dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles				
				INNER JOIN AccountOMS.dbo.t_RecordCasePatient r ON
		a.id=r.rf_idRegistersAccounts				
				INNER JOIN AccountOMS.dbo.t_Case c  ON
		r.id=c.rf_idRecordCasePatient
				INNER JOIN 	#tmpCases c1 ON
		c.id=c1.rf_idCase              
				INNER JOIN AccountOMS.dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase															
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg AND a.ReportYearMonth>=@startPeriod AND a.ReportYearMonth<=@endPeriod AND d.DS1 LIKE 'C%' AND d.DS3 LIKE 'R52%'
		AND a.rf_idSMO=@CodeSMO
CREATE UNIQUE NONCLUSTERED INDEX UQ_Index ON #tmpPeople(rf_idCase) WITH IGNORE_DUP_KEY
INSERT #tmpPeople 
SELECT DISTINCT f.CodeM,a.rf_idSMO, a.Account, c.idRecordCase,f.DateRegistration,a.DateRegister,c.id AS rf_idCase, c1.PID,c.AmountPayment,c.AmountPayment AS AmountPaymentAcc,c.rf_idV006,d.DS3
FROM AccountOMS.dbo.t_File f INNER JOIN AccountOMS.dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles				
				INNER JOIN AccountOMS.dbo.t_RecordCasePatient r ON
		a.id=r.rf_idRegistersAccounts				
				INNER JOIN AccountOMS.dbo.t_Case c  ON
		r.id=c.rf_idRecordCasePatient
				INNER JOIN 	#tmpCases c1 ON
		c.id=c1.rf_idCase              
				INNER JOIN AccountOMS.dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase												
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg AND a.ReportYearMonth>=@startPeriod AND a.ReportYearMonth<=@endPeriod AND d.DS2 LIKE 'C%' AND d.DS3 LIKE 'R52%'
	  AND a.rf_idSMO=@CodeSMO

UPDATE p SET p.AmountPaymentAcc=p.AmountPayment-r.AmountDeduction
FROM #tmpPeople p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM AccountOMS.dbo.t_PaymentAcceptedCase2 c
								WHERE c.TypeCheckup=1 and c.DateRegistration>=@dateStartReg AND c.DateRegistration<GETDATE()
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase


SELECT DISTINCT p.CodeM,p.Account,p.DateRegister,p.idRecordCase,DS3
FROM #tmpPeople p
WHERE p.AmountPayment=0 and p.AmountPaymentAcc=0 
UNION ALL
SELECT DISTINCT p.CodeM,p.Account,p.DateRegister,p.idRecordCase,DS3
FROM #tmpPeople p
WHERE p.AmountPayment>0 and p.AmountPaymentAcc>0 
GO

DROP TABLE #tmpCases
DROP TABLE #tmpPeople
GO

