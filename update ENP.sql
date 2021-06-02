USE AccountOMSReports
go
UPDATE ps SET ps.ENp=pe.ENP
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts		
					INNER JOIN dbo.t_PatientSMO ps ON
			r.id=ps.rf_idRecordCasePatient	
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN [SRVSQL2-ST1].AccountOMS.dbo.t_Case_PID_ENP pe ON
			c.id=pe.rf_idCase				
WHERE f.DateRegistration>'20170120' AND f.DateRegistration<GETDATE() AND a.ReportYear=2017 AND ps.ENP IS null
	   