USE AccountOMS
GO
DROP TABLE dbo.tmpReportForFFOMS

SELECT ce.PID,c.id, CASE WHEN a.Letter='O' THEN 1 ELSE 0 END AS IsDispAccount
INTO tmpReportForFFOMS
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case_PID_ENP ce ON
			c.id=ce.rf_idCase
WHERE f.DateRegistration>'20160101' AND f.DateRegistration<GETDATE() AND a.ReportYear=2016 AND a.ReportMonth<11