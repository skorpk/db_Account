USE AccountOMS
GO
DECLARE @dateRegStart DATETIME='20140101',
		@dateRegEnd DATETIME='20141115',
		@codeM CHAR(6)='161007'
		
SELECT c.id,c.DateBegin,c.DateEnd,f.CodeM,a.Account,en.PID,c.idRecordCase,c.AmountPayment,p.Fam,p.id,c.GUID_Case
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
			AND f.CodeM=@codeM
			AND a.rf_idSMO<>'34'
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_Case_PID_ENP en ON
			c.id=en.rf_idCase		
					INNER JOIN dbo.t_RegisterPatient p ON
			f.id=p.rf_idFiles
			AND r.id=p.rf_idRecordCase	
					
WHERE f.DateRegistration>@dateRegStart AND f.DateRegistration<@dateRegEnd AND a.ReportYear=2014 AND f.CodeM=@codeM AND a.rf_idSMO<>'34'	AND en.PID=1656434
		AND c.rf_idV006=1
		
SELECT * FROM dbo.t_RegisterPatientAttendant WHERE rf_idRegisterPatient=36155202		

GO
USE RegisterCases
GO
SELECT p.*
FROM dbo.t_File f INNER JOIN dbo.t_RegistersCase a ON
			f.id=a.rf_idFiles 		
					INNER JOIN dbo.t_RecordCase r ON
			a.id=r.rf_idRegistersCase
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCase						
					INNER JOIN dbo.t_RefRegisterPatientRecordCase r1 ON
			r.id=r1.rf_idRecordCase
					INNER JOIN dbo.t_RegisterPatient p ON
			r1.rf_idRecordCase=p.id
WHERE c.GUID_Case='382F4FCF-7B0F-1DA7-BFD5-22CC11558736'			