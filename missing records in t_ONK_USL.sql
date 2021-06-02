USE AccountOMS
GO
SELECT DISTINCT f.CodeM,f.FileNameHR, c.GUID_Case,a.Account,f.DateRegistration,c.id
INTO #t
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case c  ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_ONK_SL s ON
			c.id=s.rf_idCase		                  
WHERE f.DateRegistration>'20190115' AND a.ReportYear=2019 AND NOT EXISTS(SELECT * FROM dbo.t_ONK_USL WHERE rf_idCase=c.id )


SELECT t.DateRegistration,f.CodeM,t.FileNameHR,Account,t.id,c.GUID_Case
FROM RegisterCases.dbo.t_File f INNER JOIN RegisterCases.dbo.t_RegistersCase a ON
			f.id=a.rf_idFiles
					INNER JOIN RegisterCases.dbo.t_RecordCase r ON
			a.id=r.rf_idRegistersCase
					INNER JOIN RegisterCases.dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCase
					INNER JOIN RegisterCases.dbo.t_Case c  ON
			r.id=c.rf_idRecordCase
					INNER JOIN RegisterCases.dbo.t_ONK_USL s ON
			c.id=s.rf_idCase		                  
					INNER JOIN #t t  ON
			c.GUID_Case=t.GUID_Case                  
WHERE f.DateRegistration>'20190115' AND a.ReportYear=2019 
--GROUP BY t.DateRegistration,f.CodeM,t.FileNameHR,Account
ORDER BY t.DateRegistration
GO
DROP TABLE #t