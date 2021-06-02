USE RegisterCases
GO
SELECT f.CodeM, c.GUID_Case
INTO #tCase
FROM dbo.t_File f INNER JOIN dbo.t_RegistersCase a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCase r ON
			a.id=r.rf_idRegistersCase
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCase
					INNER JOIN dbo.t_Kiro k ON
			c.id=k.rf_idCase                  
					INNER JOIN dbo.t_RecordCaseBack rr ON
		c.id=rr.rf_idCase
			  INNER JOIN dbo.t_CaseBack c1 ON
			rr.id=c1.rf_idRecordCaseBack       
WHERE DateRegistration>'20190101' AND ReportYear=2019 AND c1.TypePay=1 AND c.DateEnd>='20190101'


SELECT DISTINCT f.CodeM, f.CodeM+' - '+l.NameS, a.Account,f.FileNameHR, a.rf_idSMO
FROM AccountOMS.dbo.t_File f INNER JOIN AccountOMS.dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN AccountOMS.dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN AccountOMS.dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN #tCase cc ON
			c.GUID_Case=cc.GUID_Case   
					INNER JOIN dbo.vw_sprT001 l ON
			f.CodeM=l.CodeM               
WHERE DateRegistration>'20190101' AND ReportYear=2019 AND a.Letter='S' AND NOT EXISTS(SELECT * FROM AccountOMS.dbo.t_Kiro WHERE rf_idCase=c.id)
ORDER BY rf_idSMO,f.CodeM
GO
DROP TABLE #tCase