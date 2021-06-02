USE AccountOMS
go

SELECT f.CodeM,a.Account,a.DateRegister,c.idRecordCase,c.id AS rf_idCase
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient						
					INNER JOIN dbo.t_PatientSMO p ON
			r.id=p.rf_idRecordCasePatient
					INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient  
WHERE c.DateEnd>'20190801' and c.GUID_Case IN ('926B7FA2-BEAF-60DB-E053-02057DC1B4B4','93E81E03-874B-5FE2-E053-02057DC1D8A1','92BF3F9D-0CAA-5F76-E053-02057DC10C7B','92BE6C9A-8008-30D1-E053-02057DC1C2EB')
