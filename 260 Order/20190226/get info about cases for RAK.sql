USE AccountOMS
GO
SELECT f.CodeM, a.Account,cc.idRecordCase, f.DateRegistration, a.ReportMonth
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case c  ON
			r.id=c.rf_idRecordCasePatient
WHERE f.DateRegistration>'20190101' AND a.ReportYear=2019 and c.id IN(95663715,95663793,95713644)