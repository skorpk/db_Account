USE AccountOMS
GO
DECLARE @dateStartReg DATETIME='20180101',
		@dateEndReg DATETIME=GETDATE(),
		@reportYear SMALLINT=2017
	


SELECT c.id AS rf_idCase,a.Account,a.DateRegister,c.idRecordCase,CAST(c.AmountPayment AS MONEY),p.Fam+' '+p.Im+' '+ISNULL(p.Ot,'') AS FIO,ps.ENP, c.DateBegin,c.DateEnd
FROM t_File f INNER JOIN t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts                  
					INNER JOIN dbo.t_PatientSMO ps ON
             r.id=ps.rf_idRecordCasePatient
					INNER JOIN t_Case c ON
		r.id = c.rf_idRecordCasePatient 	
					INNER JOIN dbo.t_RegisterPatient p on
		r.id=p.rf_idRecordCase
		AND p.rf_idFiles = f.id
					INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase			
					INNER JOIN dbo.t_Meduslugi m ON
        c.id=m.rf_idCase
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg AND a.ReportYear>=@reportYear AND f.CodeM='151012'
	AND d.DS1='S72.1' AND m.MUSurgery='A16.03.022.004' AND c.rf_idV006=1
ORDER BY FIO
