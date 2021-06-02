USE AccountOMS
GO
CREATE TABLE #doublePatient(PID INT)
INSERT #doublePatient
SELECT pe.PID
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts								
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case_PID_ENP pe ON
			c.id=pe.rf_idCase			
WHERE f.DateRegistration>'20140101' AND f.DateRegistration<GETDATE() AND a.ReportYear>2013 AND f.CodeM='806501'
GROUP BY pe.PID
HAVING COUNT(*)>4

SELECT sum(c.AmountPayment)
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts								
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case_PID_ENP pe ON
			c.id=pe.rf_idCase
					INNER JOIN #doublePatient dp ON
			pe.pid=dp.pid
WHERE f.DateRegistration>'20140101' AND f.DateRegistration<GETDATE() AND a.ReportYear>2013 AND f.CodeM='806501'			