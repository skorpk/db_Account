USE AccountOMS
GO
--DECLARE @codeM char(6)='126501'

SELECT DISTINCT a.id
,CASE WHEN c.DateEnd>'20170103' then 1 ELSE 0 END AS Deduction
	,f.CodeM,a.Account
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON    
			r.id=c.rf_idRecordCasePatient              
WHERE f.DateRegistration>='20170101' AND f.DateRegistration<=GETDATE() AND a.rf_idSMO='34006' --AND f.CodeM=@codeM
		AND NOT EXISTS(SELECT * FROM dbo.t_RefActOfSettledAccountBySMO WHERE rf_idAccounts=a.id) 
ORDER BY f.CodeM
--UNION ALL
--SELECT DISTINCT a.id,0 AS Deduction,f.CodeM
--FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
--			f.id=a.rf_idFiles
--							INNER JOIN dbo.t_RecordCasePatient r ON
--			a.id=r.rf_idRegistersAccounts
--					INNER JOIN dbo.t_Case c ON    
--			r.id=c.rf_idRecordCasePatient              
--WHERE f.DateRegistration>=@dtStart AND f.DateRegistration<=@dtEnd AND a.rf_idSMO='34006' AND f.CodeM=@codeM 
--		AND NOT EXISTS(SELECT * FROM dbo.t_RefActOfSettledAccountBySMO WHERE rf_idAccounts=a.id)
