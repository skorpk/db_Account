USE AccountOMS
GO
BEGIN TRANSACTION
UPDATE c SET c.IsSpecialCase=3
fROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN t_Meduslugi m ON
			c.id=m.rf_idCase							
WHERE f.DateRegistration>'20130805' AND f.DateRegistration<GETDATE() AND c.IsSpecialCase IS NULL
		AND m.MUGroupCode=2 AND MUUnGroupCode IN (83,84,85,86,87)

SELECT c.id
fROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN t_Meduslugi m ON
			c.id=m.rf_idCase							
WHERE f.DateRegistration>'20130805' AND f.DateRegistration<GETDATE() AND c.IsSpecialCase IS NULL
		AND m.MUGroupCode=2 AND MUUnGroupCode IN (83,84,85,86,87)
		
ROLLBACK