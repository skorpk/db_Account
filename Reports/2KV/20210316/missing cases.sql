USE AccountOMS
GO
SELECT m.MES,c.id,d.DS1,a.ReportMonth,f.DateRegistration,c.rf_idV006,d.DS2,c.AmountPayment,a.rf_idSMO
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					JOIN t_mes m ON
            c.id=m.rf_idCase
					JOIN dbo.vw_Diagnosis d ON
            c.id=d.rf_idCase
WHERE c.id IN (126163231,126163228,126163226)


SELECT m.MES,c.id,d.DS1,a.ReportMonth,f.DateRegistration,c.rf_idV006,d.DS2,c.AmountPayment,a.rf_idSMO
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					JOIN t_mes m ON
            c.id=m.rf_idCase
					JOIN dbo.vw_Diagnosis d ON
            c.id=d.rf_idCase
WHERE c.id=125064234
