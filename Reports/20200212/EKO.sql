USE AccountOMS
GO
DECLARE @dateStart DATETIME='20190101',
		@dateEnd DATETIME='20200118',
		@dateEndPay DATETIME='20200122',
		@reportYear SMALLINT=2019

CREATE TABLE #tCasesEko
(
	rf_idCase BIGINT,
	rf_idCompletedCase INT,
	CodeM CHAR(6),	
	AmountPaymentAcc DECIMAL(15,2),
	ENP VARCHAR(20),
	DateEnd date

)		

INSERT #tCasesEko( rf_idCase, CodeM,rf_idCompletedCase,AmountPaymentAcc,ENP,DateEnd )
SELECT c.id, f.CodeM,p.rf_idRecordCasePatient,c.AmountPayment,p.ENP,cc.DateEnd
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
			AND a.rf_idSMO<>'34'
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient
					INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase		
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd  AND a.ReportYear=@reportYear
		AND m.MES='ds02.005' AND c.rf_idV006=2


UPDATE p SET p.AmountPaymentAcc=p.AmountPaymentAcc-r.AmountDeduction
FROM #tCasesEko p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndPay
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase


SELECT c.id AS rf_idCase, f.CodeM,p.rf_idRecordCasePatient,c.AmountPayment AS AmountPaymentAcc,p.ENP,cc.DateBegin,cc.DateEnd,c.rf_idV006,m.MES,c.Comments
INTO #tCases2
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
			AND a.rf_idSMO<>'34'
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient
					INNER JOIN #tCasesEko ce ON
            p.ENP=ce.ENP  
					LEFT JOIN dbo.vw_MES_OneColumn m ON
            r.id=m.rf_idRecordCasePatient
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<CAST(GETDATE() AS DATE)  AND a.ReportYear>=@reportYear AND c.rf_idv006<4 AND cc.DateBegin>ce.DateEnd
	AND ce.AmountPaymentAcc>0.0 AND c.rf_idV002=136

UPDATE p SET p.AmountPaymentAcc=p.AmountPaymentAcc-r.AmountDeduction
FROM #tCases2 p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<CAST(GETDATE() AS DATE)
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

SELECT DISTINCT c.enp,c.DateEnd,l.CodeM+' - '+l.NAMES AS LPU,cc.rf_idV006,l.CodeM+' - '+l.NAMES AS LPU2,cc.DateBegin, cc.DateEnd,d.DS1,mkb.Diagnosis,ISNULL(cc.MES,'') AS MES,cc.Comments
FROM #tCasesEko c INNER JOIN #tCases2 cc ON
		c.ENP=cc.ENP
					INNER JOIN dbo.vw_sprT001 l on
		c.CodeM=l.CodeM
					INNER JOIN dbo.vw_sprT001 ll on
		cc.CodeM=ll.CodeM	
					INNER JOIN dbo.vw_Diagnosis d ON
        cc.rf_idCase=d.rf_idCase
					INNER JOIN dbo.vw_sprMKB10 mkb ON
        d.DS1=mkb.DiagnosisCode
WHERE cc.DateBegin>c.DateEnd AND c.AmountPaymentAcc>0.0 AND cc.AmountPaymentAcc>0.0 
ORDER BY c.ENP,c.DateEnd,cc.rf_idV006,cc.DateBegin
GO
DROP TABLE #tCasesEko
DROP TABLE #tCases2