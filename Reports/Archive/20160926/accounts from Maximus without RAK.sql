USE AccountOMS
GO
/*
WITH cteA
AS
(
SELECT a.id,f.CodeM,l.NAMES,a.Account, a.DateRegister, a.ReportYear, a.ReportMonth, COUNT(c.id) AS CountCase
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.vw_sprT001 l ON
			f.CodeM=l.CodeM                  
WHERE f.DateRegistration>'20140101' AND f.DateRegistration<'20170221' AND a.rf_idSMO='34006' AND  
				NOT EXISTS(SELECT rf_idCase
							FROM ExchangeFinancing.dbo.t_AFileIn f INNER JOIN  ExchangeFinancing.dbo.t_DocumentOfCheckup d ON
													f.id=d.rf_idAFile
																INNER JOIN ExchangeFinancing.dbo.t_CheckedAccount a ON
													d.id=a.rf_idDocumentOfCheckup
														INNER JOIN ExchangeFinancing.dbo.t_CheckedCase c1 ON
													a.id=c1.rf_idCheckedAccount 																							
							WHERE f.DateRegistration>='20140101' AND f.DateRegistration<GETDATE() AND c1.rf_idCase=c.id)
GROUP BY a.id,f.CodeM,l.NAMES,a.Account, a.DateRegister, a.ReportYear, a.ReportMonth
--ORDER BY a.ReportYear,a.ReportMonth,f.CodeM
)
SELECT DISTINCT  f.id,a.CodeA,a.CodeM,CAST(f.DateCreate AS DATE) AS DateCreate,f.ActFileName,a.ReportYear-2000 AS ReportYear
--INTO #t
FROM dbo.t_ActFileBySMO f INNER JOIN dbo.t_RefActOfSettledAccountBySMO a ON
			f.id=a.rf_idActFileBySMO
						INNER JOIN cteA c ON
			a.rf_idAccounts=c.id  
						INNER JOIN ExchangeFinancing.dbo.t_AFileTested af ON
			f.ActFileName=af.FileNameTested
						INNER JOIN ExchangeFinancing.dbo.t_AError e ON
			af.id=e.rf_idAFileTested                      
WHERE e.xmlElementPR IS NOT NULL
*/




SELECT a.id,f.CodeM,l.NAMES,a.Account, a.DateRegister, a.ReportYear, a.ReportMonth, COUNT(c.id) AS CountCase
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.vw_sprT001 l ON
			f.CodeM=l.CodeM                  
WHERE f.DateRegistration>'20140101' AND f.DateRegistration<'20170221' AND a.rf_idSMO='34006' AND  
				NOT EXISTS(SELECT rf_idCase
							FROM ExchangeFinancing.dbo.t_AFileIn f INNER JOIN  ExchangeFinancing.dbo.t_DocumentOfCheckup d ON
													f.id=d.rf_idAFile
																INNER JOIN ExchangeFinancing.dbo.t_CheckedAccount a ON
													d.id=a.rf_idDocumentOfCheckup
														INNER JOIN ExchangeFinancing.dbo.t_CheckedCase c1 ON
													a.id=c1.rf_idCheckedAccount 																							
							WHERE f.DateRegistration>='20140101' AND f.DateRegistration<GETDATE() AND c1.rf_idCase=c.id)
GROUP BY a.id,f.CodeM,l.NAMES,a.Account, a.DateRegister, a.ReportYear, a.ReportMonth
ORDER BY f.CodeM

go
--DROP TABLE #t
