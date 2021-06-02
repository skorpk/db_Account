USE AccountOMS
GO
DECLARE @dateStart DATETIME='20190101',
		@dateEnd DATETIME=GETDATE(),
		@reportYear SMALLINT=2019

SELECT DISTINCT a.Account,a.DateRegister AS DateAccount, cc.idRecordCase, rp.Fam,rp.Im,rp.Ot,rp.BirthDay,p.ENP
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
					INNER JOIN dbo.t_RegisterPatient rp ON
			f.id=rp.rf_idFiles
			AND r.id=rp.rf_idRecordCase																					                 
					INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase                  
WHERE f.DateRegistration>=@dateStart AND f.DateRegistration<@dateEnd  AND a.ReportYear=@reportYear AND f.CodeM='121125' AND m.MUSurgery='A16.23.034.013' AND c.rf_idV006=1


				
