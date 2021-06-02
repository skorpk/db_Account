USE AccountOMS
GO
ALTER TABLE [dbo].[t_PatientSMO] DROP CONSTRAINT [FK_PatientSMO_Patient]
GO
ALTER TABLE [dbo].[t_Case] DROP CONSTRAINT [PK__t_Case__3213E83F38996AB5]
GO
ALTER TABLE [dbo].[t_Case] DROP CONSTRAINT [FK_Cases_RecordCasePatient]
go
ALTER TABLE [dbo].[t_RecordCasePatient] DROP CONSTRAINT [PK_RecordCasePatient_idFiles_idRecordCase]
GO 
DROP INDEX [IX_V009_DateEnd_Report1] ON [dbo].[t_Case]
GO
DROP INDEX [IX_V006_V008_DateEnd] ON [dbo].[t_Case]
GO
DROP INDEX [IX_V006_DateEnd] ON [dbo].[t_Case]
GO
DROP INDEX [IX_V002_DateEnd] ON [dbo].[t_Case]
GO
DROP INDEX [IX_IDMO] ON [dbo].[t_Case]
GO
DROP INDEX [IX_DateEnd_WCF_Case] ON [dbo].[t_Case]
GO
DROP INDEX [IX_DateEnd_GUID_Case] ON [dbo].[t_Case]
GO
DROP INDEX [IX_Date_Id] ON [dbo].[t_Case]
GO
DROP INDEX [IX_Case_idRecordCasePatient] ON [dbo].[t_Case]
GO
DROP INDEX [IX_AmountPayment_DateEnd] ON [dbo].[t_Case]
GO
DROP INDEX [IX_RecordCasePatient_RefAccount] ON [dbo].[t_RecordCasePatient]
GO
DROP INDEX [IX_RecordCase_RefAccount] ON [dbo].[t_RecordCasePatient]
GO
ALTER TABLE [dbo].[t_RegistersAccounts] DROP CONSTRAINT [PK_RegistersAccounts_idFiles_idRegisterCases]
GO

ALTER TABLE [dbo].[t_RegistersAccounts] DROP CONSTRAINT [FK_RegistersAccounts_Files]
GO







-----------------------------------------------------
ALTER TABLE dbo.t_Case ADD id2 int NULL
UPDATE dbo.t_Case SET id2=id
ALTER TABLE dbo.t_Case DROP COLUMN id
EXEC sp_RENAME 't_Case.id2' , 'id', 'COLUMN'
ALTER TABLE t_Case ALTER COLUMN id bigINT NOT null
---------------------------------------------------
go		 
-----------------------------------------------------
ALTER TABLE dbo.t_RecordCasePatient ADD id2 int NULL
UPDATE dbo.t_RecordCasePatient set id2=id
ALTER TABLE dbo.t_RecordCasePatient DROP COLUMN id
EXEC sp_RENAME 't_RecordCasePatient.id2' , 'id', 'COLUMN'
ALTER TABLE t_RecordCasePatient ALTER COLUMN id INT NOT null
---------------------------------------------------
go
---------------------------------------------------
ALTER TABLE dbo.t_RegistersAccounts ADD id2 int NULL
UPDATE dbo.t_RegistersAccounts SET id2=id
ALTER TABLE dbo.t_RegistersAccounts DROP COLUMN id
EXEC sp_RENAME 't_RegistersAccounts.id2' , 'id', 'COLUMN'
ALTER TABLE t_RegistersAccounts ALTER COLUMN id INT NOT null
---------------------------------------------------
go

ALTER TABLE [dbo].[t_RecordCasePatient] ADD  CONSTRAINT [PK_RecordCasePatient_idFiles_idRecordCase] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

ALTER TABLE [dbo].[t_PatientSMO]  WITH NOCHECK ADD  CONSTRAINT [FK_PatientSMO_Patient] FOREIGN KEY([rf_idRecordCasePatient])
REFERENCES [dbo].[t_RecordCasePatient] ([id])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[t_PatientSMO] CHECK CONSTRAINT [FK_PatientSMO_Patient]
GO
ALTER TABLE [dbo].[t_Case] ADD  CONSTRAINT [PK__t_Case__3213E83F38996AB5] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

ALTER TABLE [dbo].[t_Case]  WITH NOCHECK ADD  CONSTRAINT [FK_Cases_RecordCasePatient] FOREIGN KEY([rf_idRecordCasePatient])
REFERENCES [dbo].[t_RecordCasePatient] ([id])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[t_Case] CHECK CONSTRAINT [FK_Cases_RecordCasePatient]
GO

ALTER TABLE [dbo].[t_RegistersAccounts] ADD  CONSTRAINT [PK_RegistersAccounts_idFiles_idRegisterCases] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[t_RegistersAccounts]  WITH NOCHECK ADD  CONSTRAINT [FK_RegistersAccounts_Files] FOREIGN KEY([rf_idFiles])
REFERENCES [dbo].[t_File] ([id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[t_RecordCasePatient]  WITH CHECK ADD  CONSTRAINT [FK_RecordCasePatient_RegistersAccounts] FOREIGN KEY([rf_idRegistersAccounts])
REFERENCES [dbo].[t_RegistersAccounts] ([id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[t_RecordCasePatient] CHECK CONSTRAINT [FK_RecordCasePatient_RegistersAccounts]
GO
ALTER TABLE [dbo].[t_RegistersAccounts] CHECK CONSTRAINT [FK_RegistersAccounts_Files]
GO
ALTER TABLE [dbo].[t_Meduslugi]  WITH CHECK ADD  CONSTRAINT [FK_Meduslugi_Cases] FOREIGN KEY([rf_idCase])
REFERENCES [dbo].[t_Case] ([id])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[t_Meduslugi] CHECK CONSTRAINT [FK_Meduslugi_Cases]
GO
ALTER TABLE [dbo].[t_MES]  WITH CHECK ADD  CONSTRAINT [FK_MES_Cases] FOREIGN KEY([rf_idCase])
REFERENCES [dbo].[t_Case] ([id])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[t_MES] CHECK CONSTRAINT [FK_MES_Cases]
GO





