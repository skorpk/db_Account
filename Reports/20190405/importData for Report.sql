USE ExchangeFinancing
GO 
SELECT distinct cm.rf_idCase2 AS rf_idCase, f.DateRegistration,p.id AS idAkt,p.DocumentDate,p.DocumentNumber,
	 f.CodeM, RIGHT(a.Account, 1) AS Letter,
	 sc.AmountReduction AS AmountDeduction,
	 p.rf_idF006 AS TypeCheckup
FROM ExchangeFinancing.dbo.t_AFileIn f INNER JOIN ExchangeFinancing.dbo.t_DocumentOfCheckup p ON 
							f.id = p.rf_idAFile 
										INNER JOIN ExchangeFinancing.dbo.t_CheckedAccount2019 a ON 
							p.id = a.rf_idDocumentOfCheckup 
										INNER JOIN ExchangeFinancing.dbo.t_CheckedCase2019 sc ON 
							a.id = sc.rf_idCheckedAccount										
										INNER JOIN dbo.vw_CaseMO cm ON
							sc.rf_idCase=cm.rf_idCase											
WHERE f.DateRegistration>='20190101' AND f.DateRegistration<GETDATE()	AND cm.ReportYear>2018 AND a.ReportYear>2018