USE AccountOMS
GO
SELECT f.CodeM,a.Account,c.idRecordCase,c.GUID_Case,ce.pid
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case_PID_ENP ce ON
			c.id=ce.rf_idCase                  
WHERE f.DateRegistration>='20150101' AND f.DateRegistration<'20160215' and a.ReportYear=2015 AND a.rf_idSMO='34001'
ORDER BY f.DateRegistration		                    