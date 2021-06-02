USE AccountOMS
go
DECLARE @dateStart DATETIME='20200101',
		@dateEnd DATETIME='20210117',
		@dateEndPay DATETIME='20210120'


SELECT DISTINCT c.id AS rf_idCase, f.CodeM, c.AmountPayment,c.rf_idV004,ss.DS,p.ENP,cc.DateEnd
INTO #tCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient			
					inner JOIN dbo.t_CompletedCase cc ON
            r.id=cc.rf_idRecordCasePatient			
					INNER JOIN dbo.t_Diagnosis d ON
			c.id=d.rf_idCase
			AND d.TypeDiagnosis=1			
					INNER JOIN dbo.t_PurposeOfVisit pp ON
			c.id=pp.rf_idCase					
					INNER JOIN dbo.T_DN2020EIR ss ON
              p.enp=ss.ENP
			  AND f.CodeM=ss.CODEM
			  AND d.DiagnosisCode=ss.DS
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2020 AND c.rf_idV006=3 AND f.TypeFile='H' AND pp.rf_idV025='1.3'

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndPay
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

DROP TABLE tmp_CasesDN_EIR

SELECT rf_idCase,CodeM,rf_idV004,DS AS DS1,ENP,DateEnd
INTO tmp_CasesDN_EIR
FROM #tCases WHERE AmountPayment>0
ORDER BY enp
GO
DROP TABLE #tCases