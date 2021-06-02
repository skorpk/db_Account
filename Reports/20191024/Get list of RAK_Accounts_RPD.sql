USE AccountOMSReports
GO
DECLARE @dateStart DATETIME='20190901',
		@dateEnd DATETIME=GETDATE(),
		@dateEndPay DATETIME=GETDATE(),
		@reportYear SMALLINT=2019,
		@reportMonth TINYINT=10

SELECT DISTINCT cc.id AS rf_idCase,f.FileNameHR,f.CodeM,a.id AS rf_idAccount, a.rf_idSMO AS CodeSMO
INTO #tCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts										
					INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient                  					
WHERE f.DateRegistration>=@dateStart AND f.DateRegistration<@dateEnd  AND a.ReportYear=@reportYear AND f.CodeM IN('141023','251001') 
		AND a.ReportMonth=@reportMonth AND f.FileNameHR LIKE 'H%'

		--список РАК
SELECT distinct f.FileName,f.CodeM,f.CodeSMO
FROM ExchangeFinancing.dbo.t_AFileIn f INNER JOIN ExchangeFinancing.dbo.t_DocumentOfCheckup d ON
								f.id=d.rf_idAFile
										INNER JOIN ExchangeFinancing.dbo.t_CheckedAccount2019 a ON
                                d.id=a.rf_idDocumentOfCheckup 
										INNER JOIN #tCases cc ON
								a.rf_idRegisterAccounts=cc.rf_idAccount       
ORDER BY f.CodeSMO,f.CodeM,f.FileName

SELECT DISTINCT f.FileName,f.CodeM,f.CodeSMO
FROM ExchangeFinancing.dbo.t_DFileIn f INNER JOIN ExchangeFinancing.dbo.t_PaymentDocument p ON
						f.id=p.rf_idDFile
									INNER JOIN ExchangeFinancing.dbo.t_SettledAccount a ON
                        p.id=a.rf_idPaymentDocument
									INNER JOIN #tCases cc ON
                        a.rf_idRegisterAccounts=cc.rf_idAccount
ORDER BY f.CodeSMO,f.CodeM,f.FileName


SELECT DISTINCT FileNameHR,CodeM, CodeSMO FROM #tCases ORDER BY CodeSMO,CodeM, FileNameHR
GO
DROP TABLE #tCases
