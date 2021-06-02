USE AccountOMS
GO
DELETE FROM dbo.t_RegistersAccounts WHERE NOT EXISTS(SELECT * FROM dbo.t_File WHERE id=rf_idFiles)
DELETE FROM dbo.t_RecordCasePatient WHERE NOT EXISTS(SELECT * FROM dbo.t_RegistersAccounts WHERE id=rf_idRegistersAccounts)
DELETE FROM dbo.t_PatientSMO WHERE NOT EXISTS(SELECT * FROM dbo.t_RecordCasePatient WHERE id=rf_idRecordCasePatient)
DELETE FROM dbo.t_Case WHERE NOT EXISTS(SELECT * FROM dbo.t_RecordCasePatient WHERE id=rf_idRecordCasePatient)
DELETE FROM dbo.t_Meduslugi WHERE NOT EXISTS(SELECT * FROM dbo.t_Case WHERE id=rf_idCase)
DELETE FROM dbo.t_Mes WHERE NOT EXISTS(SELECT * FROM dbo.t_Case WHERE id=rf_idCase)