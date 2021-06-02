USE AccountOMS
GO
SELECT COUNT(*) FROM t_SendingDataIntoFFOMS WHERE IsFullDoubleDate=1

UPDATE s set s.IsFullDoubleDate=1
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.tmp_PVTRecordDelete p ON
			f.CodeM=p.CodeM
			AND a.Account=p.Account
			AND c.idRecordCase=p.NumberCase
					INNER JOIN dbo.t_SendingDataIntoFFOMS s ON
			c.id=s.rf_idCase                  
WHERE f.DateRegistration>'20150101' AND a.ReportYear=2015
