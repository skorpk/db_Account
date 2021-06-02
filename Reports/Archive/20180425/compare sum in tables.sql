USE AccountOMS
GO			  
SELECT SUM(c.AmountPayment)-SUM(t.AmountDeduction),COUNT(DISTINCT p.ENP)
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles		
				INNER JOIN dbo.t_RecordCasePatient r ON
		a.id=r.rf_idRegistersAccounts				
				INNER JOIN dbo.t_PatientSMO p ON
		r.id=p.rf_idRecordCasePatient              
				INNER JOIN dbo.t_Case c  ON
		r.id=c.rf_idRecordCasePatient	
				INNER JOIN dbo.t_PaymentAcceptedCase2 t ON
		c.id=t.rf_idCase
WHERE a.ReportYear=2018 AND a.rf_idSMO='34007' AND a.Letter='O' AND f.DateRegistration>'20180101' AND c.DateEnd>='20180101' AND c.DateEnd<'20181001'


SELECT SUM(t.AmountPaymentAccept),COUNT(DISTINCT c.id),COUNT(DISTINCT p.ENP)
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles				
				INNER JOIN dbo.t_RecordCasePatient r ON
		a.id=r.rf_idRegistersAccounts				
				INNER JOIN dbo.t_PatientSMO p ON
		r.id=p.rf_idRecordCasePatient              
				INNER JOIN dbo.t_Case c  ON
		r.id=c.rf_idRecordCasePatient	
				INNER JOIN dbo.t_PaidCase t ON
		c.id=t.rf_idCase
WHERE a.ReportYear=2018 AND a.rf_idSMO='34002' AND a.Letter='O' AND f.DateRegistration>'20180101' AND c.DateEnd>='20180101' AND c.DateEnd<'20181001'


