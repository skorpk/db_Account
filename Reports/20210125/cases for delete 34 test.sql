USE AccountOMS
GO
SELECT a.Account,f.CodeM,f.DateRegistration,cc.id AS rf_idCase,z.id AS rf_idCaseZSL
INTO tmp_CaseForDeleteFilin34_Test
FROM dbo.t_PaymentAcceptedCase2 p INNER JOIN expertAccounts.dbo.t_Case cc ON
			p.rf_idCase=cc.id
						INNER JOIN expertAccounts.dbo.t_RecordCasePatient r ON
            cc.rf_idRecordCasePatient=r.id
						INNER JOIN expertAccounts.dbo.t_RegistersAccounts a ON
            r.rf_idRegistersAccounts=a.id	
						INNER JOIN expertAccounts.dbo.t_File f ON
			a.rf_idFiles=f.id
						INNER JOIN expertAccounts.dbo.t_CompletedCase z ON
            r.id=z.rf_idRecordCasePatient
WHERE p.DateRegistration>'20201201' AND NOT EXISTS(SELECT id FROM t_Case c WHERE p.rf_idCase=c.id AND c.DateEnd>'20170101')