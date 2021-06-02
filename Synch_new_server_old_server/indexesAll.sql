USE [AccountOMS]
GO
CREATE NONCLUSTERED INDEX [IX_AmountPayment_DateEnd] ON [dbo].[t_Case]
(
	[AmountPayment] ASC
)
INCLUDE ( 	[id],
	[rf_idRecordCasePatient],
	[DateEnd],
	[rf_idMO],
	[idRecordCase]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
CREATE NONCLUSTERED INDEX [IX_Case_idRecordCasePatient] ON [dbo].[t_Case]
(
	[rf_idRecordCasePatient] ASC,
	[id] ASC
)
INCLUDE ( 	[rf_idMO],
	[idRecordCase],
	[rf_idV006],
	[rf_idV008],
	[rf_idDirectMO],
	[HopitalisationType],
	[rf_idV002],
	[IsChildTariff],
	[NumberHistoryCase],
	[DateBegin],
	[DateEnd],
	[rf_idV009],
	[rf_idV012],
	[rf_idV004],
	[rf_idV010],
	[AmountPayment],
	[GUID_Case],
	[Age],
	[rf_idDoctor]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
CREATE NONCLUSTERED INDEX [IX_Date_Id] ON [dbo].[t_Case]
(
	[DateEnd] ASC
)
INCLUDE ( 	[id],
	[rf_idRecordCasePatient],
	[idRecordCase],
	[NumberHistoryCase],
	[DateBegin],
	[AmountPayment]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_DateEnd_GUID_Case]    Script Date: 22.08.2017 8:04:40 ******/
CREATE NONCLUSTERED INDEX [IX_DateEnd_GUID_Case] ON [dbo].[t_Case]
(
	[DateEnd] ASC
)
INCLUDE ( 	[id],
	[rf_idRecordCasePatient],
	[GUID_Case],
	[idRecordCase],
	[rf_idMO],
	[rf_idSubMO],
	[rf_idDepartmentMO],
	[rf_idV002],
	[IsChildTariff],
	[DateBegin],
	[rf_idV004],
	[rf_idDoctor],
	[Age],
	[AmountPayment],
	[rf_idV006]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
CREATE NONCLUSTERED INDEX [IX_DateEnd_WCF_Case] ON [dbo].[t_Case]
(
	[DateEnd] ASC,
	[id] ASC
)
INCLUDE ( 	[rf_idMO],
	[rf_idV006],
	[rf_idV002],
	[DateBegin],
	[AmountPayment]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
CREATE NONCLUSTERED INDEX [IX_IDMO] ON [dbo].[t_Case]
(
	[rf_idMO] ASC
)
INCLUDE ( 	[rf_idRecordCasePatient],
	[idRecordCase],
	[AmountPayment]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_V002_DateEnd] ON [dbo].[t_Case]
(
	[rf_idV002] ASC,
	[DateEnd] ASC
)
INCLUDE ( 	[id],
	[rf_idRecordCasePatient],
	[DateBegin],
	[AmountPayment]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
CREATE NONCLUSTERED INDEX [IX_V006_DateEnd] ON [dbo].[t_Case]
(
	[rf_idV006] ASC,
	[DateEnd] ASC
)
INCLUDE ( 	[id],
	[rf_idRecordCasePatient],
	[idRecordCase],
	[HopitalisationType],
	[IsChildTariff],
	[NumberHistoryCase],
	[DateBegin],
	[AmountPayment],
	[Age],
	[rf_idDoctor]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
CREATE NONCLUSTERED INDEX [IX_V006_V008_DateEnd] ON [dbo].[t_Case]
(
	[rf_idV006] ASC,
	[rf_idV008] ASC,
	[DateEnd] ASC
)
INCLUDE ( 	[id],
	[rf_idRecordCasePatient],
	[rf_idMO],
	[AmountPayment]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
CREATE NONCLUSTERED INDEX [IX_V009_DateEnd_Report1] ON [dbo].[t_Case]
(
	[rf_idV009] ASC,
	[DateEnd] ASC
)
INCLUDE ( 	[id],
	[rf_idRecordCasePatient],
	[idRecordCase],
	[rf_idV006],
	[rf_idV002],
	[IsChildTariff],
	[AmountPayment],
	[rf_idDoctor]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF

GO
CREATE NONCLUSTERED INDEX [IX_FileCodeM] ON [dbo].[t_File]
(
	[CodeM] ASC
)
INCLUDE ( 	[DateRegistration]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF

GO
CREATE NONCLUSTERED INDEX [IX_FileName_DateReg] ON [dbo].[t_File]
(
	[DateRegistration] ASC
)
INCLUDE ( 	[id],
	[FileNameHR],
	[CodeM]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
CREATE NONCLUSTERED INDEX [IX_FileName_ID] ON [dbo].[t_File]
(
	[FileNameHR] ASC
)
INCLUDE ( 	[id]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_MU_IDCase] ON [dbo].[t_Meduslugi]
(
	[MUGroupCode] ASC,
	[MUUnGroupCode] ASC
)
INCLUDE ( 	[rf_idCase],
	[MUCode],
	[Quantity]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
CREATE NONCLUSTERED INDEX [IX_MES_CASE] ON [dbo].[t_Mes]
(
	[rf_idCase] ASC
)
INCLUDE ( 	[MES],
	[Quantity],
	[Tariff]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
CREATE NONCLUSTERED INDEX [IX_MES_IdCase] ON [dbo].[t_Mes]
(
	[MES] ASC
)
INCLUDE ( 	[rf_idCase]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [QU_MES_Case] ON [dbo].[t_Mes]
(
	[rf_idCase] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = ON, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
CREATE NONCLUSTERED INDEX [IX_RecordCase_RefAccount] ON [dbo].[t_RecordCasePatient]
(
	[rf_idRegistersAccounts] ASC
)
INCLUDE ( 	[id],
	[idRecord],
	[IsNew],
	[ID_Patient],
	[rf_idF008],
	[NewBorn],
	[AttachLPU]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
CREATE NONCLUSTERED INDEX [IX_RecordCasePatient_RefAccount] ON [dbo].[t_RecordCasePatient]
(
	[rf_idRegistersAccounts] ASC
)
INCLUDE ( 	[id],
	[SeriaPolis],
	[NumberPolis],
	[AttachLPU],
	[NewBorn]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[t_Case]  WITH NOCHECK ADD  CONSTRAINT [FK_Cases_RecordCasePatient] FOREIGN KEY([rf_idRecordCasePatient])
REFERENCES [dbo].[t_RecordCasePatient] ([id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[t_Case] CHECK CONSTRAINT [FK_Cases_RecordCasePatient]
GO
ALTER TABLE [dbo].[t_PatientSMO]  WITH NOCHECK ADD  CONSTRAINT [FK_PatientSMO_Patient] FOREIGN KEY([rf_idRecordCasePatient])
REFERENCES [dbo].[t_RecordCasePatient] ([id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[t_PatientSMO] CHECK CONSTRAINT [FK_PatientSMO_Patient]
GO
ALTER TABLE [dbo].[t_RegistersAccounts]  WITH NOCHECK ADD  CONSTRAINT [FK_RegistersAccounts_Files] FOREIGN KEY([rf_idFiles])
REFERENCES [dbo].[t_File] ([id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[t_RegistersAccounts] CHECK CONSTRAINT [FK_RegistersAccounts_Files]
GO
