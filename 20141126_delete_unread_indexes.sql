USE [AccountOMS]
GO

SET ARITHABORT ON
GO

SET CONCAT_NULL_YIELDS_NULL ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_NULLS ON
GO

SET ANSI_PADDING ON
GO

SET ANSI_WARNINGS ON
GO

SET NUMERIC_ROUNDABORT OFF
GO

/****** Object:  Index [IDX_tFile_DateReg]    Script Date: 11/26/2014 13:47:37 ******/
CREATE NONCLUSTERED INDEX [IDX_tFile_DateReg] ON [dbo].[t_File] 
(
	[DateRegistration] ASC
)
INCLUDE ( [id],
[FileVersion],
[DateCreate],
[FileNameHR],
[FileNameLR],
[CodeM],
[Insurance]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO

USE [AccountOMS]
GO

/****** Object:  Index [QU_FileIn]    Script Date: 11/26/2014 13:48:14 ******/
CREATE UNIQUE NONCLUSTERED INDEX [QU_FileIn] ON [dbo].[t_File] 
(
	[FileNameHR] ASC
)
WHERE ([DateRegistration]>'20131201')
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO

USE [AccountOMS]
GO

SET ARITHABORT ON
GO

SET CONCAT_NULL_YIELDS_NULL ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_NULLS ON
GO

SET ANSI_PADDING ON
GO

SET ANSI_WARNINGS ON
GO

SET NUMERIC_ROUNDABORT OFF
GO

/****** Object:  Index [<Name of Missing Index, sysname,>]    Script Date: 11/26/2014 13:48:53 ******/
CREATE NONCLUSTERED INDEX [<Name of Missing Index, sysname,>] ON [dbo].[t_RegisterPatient] 
(
	[Sex] ASC
)
INCLUDE ( [Fam],
[Im],
[Ot],
[rf_idV005],
[rf_idRecordCase]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [AccountOMSInsurer]
GO

USE [AccountOMS]
GO

SET ARITHABORT ON
GO

SET CONCAT_NULL_YIELDS_NULL ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_NULLS ON
GO

SET ANSI_PADDING ON
GO

SET ANSI_WARNINGS ON
GO

SET NUMERIC_ROUNDABORT OFF
GO

/****** Object:  Index [IX_Account_YEAR_ExchangeFinancing]    Script Date: 11/26/2014 13:49:32 ******/
CREATE NONCLUSTERED INDEX [IX_Account_YEAR_ExchangeFinancing] ON [dbo].[t_RegistersAccounts] 
(
	[Account] ASC,
	[ReportYear] ASC
)
INCLUDE ( [id],
[rf_idSMO]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO

USE [AccountOMS]
GO

SET ARITHABORT ON
GO

SET CONCAT_NULL_YIELDS_NULL ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_NULLS ON
GO

SET ANSI_PADDING ON
GO

SET ANSI_WARNINGS ON
GO

SET NUMERIC_ROUNDABORT OFF
GO

/****** Object:  Index [IDX_RegAcc_RepYear_Letter]    Script Date: 11/26/2014 13:50:37 ******/
CREATE NONCLUSTERED INDEX [IDX_RegAcc_RepYear_Letter] ON [dbo].[t_RegistersAccounts] 
(
	[ReportYear] ASC,
	[Letter] ASC
)
INCLUDE ( [rf_idFiles],
[id],
[ReportMonth],
[PrefixNumberRegister],
[DateRegister],
[Account],
[ReportYearMonth]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO

USE [AccountOMS]
GO

/****** Object:  Index [IX_ID_rf_idRegistersAccounts]    Script Date: 11/26/2014 13:51:35 ******/
CREATE NONCLUSTERED INDEX [IX_ID_rf_idRegistersAccounts] ON [dbo].[t_RecordCasePatient] 
(
	[rf_idRegistersAccounts] ASC,
	[id] ASC
)
INCLUDE ( [SeriaPolis],
[NumberPolis],
[AttachLPU]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [AccountOMSInsurer]
GO

USE [AccountOMS]
GO

/****** Object:  Index [IX_Case_CodeM_ExchangeFinancing]    Script Date: 11/26/2014 13:53:04 ******/
CREATE NONCLUSTERED INDEX [IX_Case_CodeM_ExchangeFinancing] ON [dbo].[t_Case] 
(
	[rf_idMO] ASC
)
INCLUDE ( [rf_idRecordCasePatient],
[idRecordCase],
[GUID_Case],
[AmountPayment],
[DateEnd]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [AccountOMSCase]
GO

USE [AccountOMS]
GO

/****** Object:  Index [IX_Case_FinancingTestData_2]    Script Date: 11/26/2014 13:53:14 ******/
CREATE NONCLUSTERED INDEX [IX_Case_FinancingTestData_2] ON [dbo].[t_Case] 
(
	[idRecordCase] ASC,
	[rf_idMO] ASC
)
INCLUDE ( [rf_idRecordCasePatient],
[GUID_Case],
[AmountPayment],
[DateEnd]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [AccountOMSCase]
GO

USE [AccountOMS]
GO

/****** Object:  Index [IX_CodeM_ExchangeFinancing_1]    Script Date: 11/26/2014 13:53:29 ******/
CREATE NONCLUSTERED INDEX [IX_CodeM_ExchangeFinancing_1] ON [dbo].[t_Case] 
(
	[rf_idMO] ASC
)
INCLUDE ( [id],
[rf_idRecordCasePatient],
[GUID_Case],
[AmountPayment],
[idRecordCase]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [AccountOMSCase]
GO

USE [AccountOMS]
GO

/****** Object:  Index [IX_Case_idRecordCasePatient_ID_DateEnd]    Script Date: 11/26/2014 13:53:51 ******/
CREATE NONCLUSTERED INDEX [IX_Case_idRecordCasePatient_ID_DateEnd] ON [dbo].[t_Case] 
(
	[id] ASC,
	[rf_idRecordCasePatient] ASC
)
INCLUDE ( [DateEnd],
[DateBegin],
[AmountPayment]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [AccountOMSCase]
GO

USE [AccountOMS]
GO

/****** Object:  Index [IX_DateEnd_ID_idRecordCasePatient]    Script Date: 11/26/2014 13:54:06 ******/
CREATE NONCLUSTERED INDEX [IX_DateEnd_ID_idRecordCasePatient] ON [dbo].[t_Case] 
(
	[DateEnd] ASC
)
INCLUDE ( [id],
[rf_idRecordCasePatient],
[rf_idV009],
[AmountPayment]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [AccountOMSCase]
GO

USE [AccountOMS]
GO

/****** Object:  Index [IX_EChnageFinancing_AmountPayment_1]    Script Date: 11/26/2014 13:54:21 ******/
CREATE NONCLUSTERED INDEX [IX_EChnageFinancing_AmountPayment_1] ON [dbo].[t_Case] 
(
	[rf_idMO] ASC,
	[AmountPayment] ASC
)
INCLUDE ( [rf_idRecordCasePatient],
[idRecordCase],
[DateEnd]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [AccountOMSCase]
GO

USE [AccountOMS]
GO

/****** Object:  Index [IX_EF_GUID_MO_DateEnd]    Script Date: 11/26/2014 13:54:36 ******/
CREATE NONCLUSTERED INDEX [IX_EF_GUID_MO_DateEnd] ON [dbo].[t_Case] 
(
	[GUID_Case] ASC,
	[rf_idMO] ASC,
	[DateEnd] ASC
)
INCLUDE ( [rf_idRecordCasePatient],
[idRecordCase]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [AccountOMSCase]
GO

USE [AccountOMS]
GO

/****** Object:  Index [IX_DateEnd_Age]    Script Date: 11/26/2014 13:54:54 ******/
CREATE NONCLUSTERED INDEX [IX_DateEnd_Age] ON [dbo].[t_Case] 
(
	[DateEnd] ASC,
	[Age] ASC
)
INCLUDE ( [id],
[rf_idRecordCasePatient],
[IsSpecialCase],
[AmountPayment],
[Comments]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [AccountOMSCase]
GO

USE [AccountOMS]
GO

/****** Object:  Index [IX_USL_OK_AmountPayment_IDCase]    Script Date: 11/26/2014 13:55:08 ******/
CREATE NONCLUSTERED INDEX [IX_USL_OK_AmountPayment_IDCase] ON [dbo].[t_Case] 
(
	[rf_idV006] ASC
)
INCLUDE ( [id],
[rf_idRecordCasePatient],
[AmountPayment]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [AccountOMSCase]
GO

USE [AccountOMS]
GO

/****** Object:  Index [IX_TypeDiagnosis_Case_DS]    Script Date: 11/26/2014 13:55:59 ******/
CREATE NONCLUSTERED INDEX [IX_TypeDiagnosis_Case_DS] ON [dbo].[t_Diagnosis] 
(
	[TypeDiagnosis] ASC
)
INCLUDE ( [DiagnosisCode],
[rf_idCase]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO

USE [AccountOMS]
GO

/****** Object:  Index [IDX_MU_MUGrCode]    Script Date: 11/26/2014 13:57:17 ******/
CREATE NONCLUSTERED INDEX [IDX_MU_MUGrCode] ON [dbo].[t_Meduslugi] 
(
	[MUGroupCode] ASC
)
INCLUDE ( [rf_idCase]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [AccountMU]
GO

USE [AccountOMS]
GO

/****** Object:  Index [IX_MUCode_idCase]    Script Date: 11/26/2014 13:57:32 ******/
CREATE NONCLUSTERED INDEX [IX_MUCode_idCase] ON [dbo].[t_Meduslugi] 
(
	[MUGroupCode] ASC,
	[MUUnGroupCode] ASC,
	[MUCode] ASC
)
INCLUDE ( [rf_idCase]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [AccountMU]
GO

USE [AccountOMS]
GO

/****** Object:  Index [IX_MES_CASE_2]    Script Date: 11/26/2014 13:58:18 ******/
CREATE NONCLUSTERED INDEX [IX_MES_CASE_2] ON [dbo].[t_MES] 
(
	[MES] ASC,
	[rf_idCase] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [AccountOMSCase]
GO

