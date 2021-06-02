USE AccountOMS
GO
SELECT cc.rf_idCase,cc.AmountDeduction,d.DocumentNumber,d.DocumentDate
INTO #t
FROM ExchangeFinancing.dbo.t_CheckedCase cc INNER JOIN ExchangeFinancing.dbo.t_CheckedAccount a ON
		cc.rf_idCheckedAccount=a.id
					INNER JOIN ExchangeFinancing.dbo.t_DocumentOfCheckup d ON
		a.rf_idDocumentOfCheckup=d.id				                  
					INNER JOIN ExchangeFinancing.dbo.t_AFileIn f ON
		f.id=d.rf_idAFile                  
WHERE f.DateRegistration>'20160101' AND f.DateRegistration<'20170401' AND d.TypeCheckup>1 AND f.CodeM='131940' AND cc.AmountDeduction>0

SELECT a.rf_idSMO, a.Account,a.DateRegister,c.idRecordCase, ISNULL(ps.ENP,r.NumberPolis) AS Policy,c.NumberHistoryCase,c.DateBegin,c.DateEnd,d.DS1,mkb.Diagnosis,c.AmountPayment,t.AmountDeduction
		,v6.name,t.DocumentNumber,t.DocumentDate
FROM dbo.t_RegistersAccounts a INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
								INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
								INNER JOIN #t t ON
			c.id=t.rf_idCase
								INNER JOIN dbo.vw_Diagnosis d ON
			c.id=d.rf_idCase
								INNER JOIN dbo.vw_sprMKB10 mkb ON
			d.DS1=mkb.DiagnosisCode                              
								INNER JOIN RegisterCases.dbo.vw_sprV006 v6 ON
			c.rf_idV006=v6.id                              
								LEFT JOIN dbo.t_PatientSMO ps ON
			r.id=ps.rf_idRecordCasePatient                                
GO
DROP TABLE #t