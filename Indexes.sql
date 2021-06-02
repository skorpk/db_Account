USE [AccountOMS]
GO
CREATE NONCLUSTERED INDEX IX_Case_idRecordCasePatient
ON [dbo].[t_Case] ([rf_idRecordCasePatient])
INCLUDE ([rf_idMO])
GO
CREATE NONCLUSTERED INDEX IX_ID_rf_idRegistersAccounts on dbo.t_RecordCasePatient(id,rf_idRegistersAccounts)
go
CREATE NONCLUSTERED INDEX [IX_Case_idRecordCasePatient_ID_DateEnd] ON [dbo].[t_Case] 
(
	id ASC,
	[rf_idRecordCasePatient] ASC
)
INCLUDE ( DateEnd) ON [AccountOMSCase]
go
CREATE NONCLUSTERED INDEX IX_Files_ID_Letter on dbo.t_RegistersAccounts(Letter,rf_idFiles,id)
INCLUDE(rf_idSMO,DateRegister,ReportYear,ReportMonth,AmountPayment,Account)
go
CREATE NONCLUSTERED INDEX IX_DateEnd_ID_idRecordCasePatient
ON [dbo].[t_Case] ([DateEnd])
INCLUDE ([id],[rf_idRecordCasePatient])
go
