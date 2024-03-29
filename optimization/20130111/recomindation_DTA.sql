use [AccountOMS]
go

CREATE NONCLUSTERED INDEX [_dta_index_t_RegisterPatient_31_613577224__K10_K4_1_5_6_7_8_9] ON [dbo].[t_RegisterPatient] 
(
	[rf_idRecordCase] ASC,
	[Fam] ASC
)
INCLUDE ( [id],
[Im],
[Ot],
[rf_idV005],
[BirthDay],
[BirthPlace]) WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
go

CREATE STATISTICS [_dta_stat_613577224_7_1] ON [dbo].[t_RegisterPatient]([rf_idV005], [id])
go

CREATE STATISTICS [_dta_stat_613577224_1_10_7] ON [dbo].[t_RegisterPatient]([id], [rf_idRecordCase], [rf_idV005])
go

CREATE NONCLUSTERED INDEX [_dta_index_t_Case_31_917578307__K2_K1_3_5_6_7_8_12_13_14_15_16_17_18_19_22_23_27] ON [dbo].[t_Case] 
(
	[rf_idRecordCasePatient] ASC,
	[id] ASC
)
INCLUDE ( [idRecordCase],
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
[Age]) WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
go

CREATE STATISTICS [_dta_stat_917578307_1_19] ON [dbo].[t_Case]([id], [rf_idV004])
go

CREATE STATISTICS [_dta_stat_917578307_1_18_19] ON [dbo].[t_Case]([id], [rf_idV012], [rf_idV004])
go

CREATE STATISTICS [_dta_stat_917578307_17_1_19_18] ON [dbo].[t_Case]([rf_idV009], [id], [rf_idV004], [rf_idV012])
go

CREATE STATISTICS [_dta_stat_917578307_12_1_19_18_17] ON [dbo].[t_Case]([rf_idV002], [id], [rf_idV004], [rf_idV012], [rf_idV009])
go

CREATE STATISTICS [_dta_stat_917578307_22_1_19_18_17_7] ON [dbo].[t_Case]([rf_idV010], [id], [rf_idV004], [rf_idV012], [rf_idV009], [rf_idDirectMO])
go

CREATE STATISTICS [_dta_stat_917578307_5_1_19_18_17_7_12] ON [dbo].[t_Case]([rf_idV006], [id], [rf_idV004], [rf_idV012], [rf_idV009], [rf_idDirectMO], [rf_idV002])
go

CREATE STATISTICS [_dta_stat_917578307_1_6_19_18_17_7_12_22] ON [dbo].[t_Case]([id], [rf_idV008], [rf_idV004], [rf_idV012], [rf_idV009], [rf_idDirectMO], [rf_idV002], [rf_idV010])
go

CREATE STATISTICS [_dta_stat_917578307_1_2_19_18_17_7_12_22_5] ON [dbo].[t_Case]([id], [rf_idRecordCasePatient], [rf_idV004], [rf_idV012], [rf_idV009], [rf_idDirectMO], [rf_idV002], [rf_idV010], [rf_idV006])
go

CREATE STATISTICS [_dta_stat_917578307_19_18_17_7_12_22_5_6_2] ON [dbo].[t_Case]([rf_idV004], [rf_idV012], [rf_idV009], [rf_idDirectMO], [rf_idV002], [rf_idV010], [rf_idV006], [rf_idV008], [rf_idRecordCasePatient])
go

CREATE STATISTICS [_dta_stat_917578307_1_7_19_18_17_12_22_5_6_2_3] ON [dbo].[t_Case]([id], [rf_idDirectMO], [rf_idV004], [rf_idV012], [rf_idV009], [rf_idV002], [rf_idV010], [rf_idV006], [rf_idV008], [rf_idRecordCasePatient], [idRecordCase])
go

CREATE NONCLUSTERED INDEX [_dta_index_t_RegisterPatientDocument_31_789577851__K1_K2_3_4_5_6_7] ON [dbo].[t_RegisterPatientDocument] 
(
	[rf_idRegisterPatient] ASC,
	[rf_idDocumentType] ASC
)
INCLUDE ( [SeriaDocument],
[NumberDocument],
[SNILS],
[OKATO],
[OKATO_Place]) WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
go

CREATE NONCLUSTERED INDEX [_dta_index_t_RecordCasePatient_31_757577737__K2_K1_7_8] ON [dbo].[t_RecordCasePatient] 
(
	[rf_idRegistersAccounts] ASC,
	[id] ASC
)
INCLUDE ( [SeriaPolis],
[NumberPolis]) WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
go

CREATE NONCLUSTERED INDEX [_dta_index_t_File_31_293576084__K3_K2_6] ON [dbo].[t_File] 
(
	[DateRegistration] ASC,
	[id] ASC
)
INCLUDE ( [FileNameHR]) WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
go

SET QUOTED_IDENTIFIER ON
go

SET ARITHABORT ON
go

SET CONCAT_NULL_YIELDS_NULL ON
go

SET ANSI_NULLS ON
go

SET ANSI_PADDING ON
go

SET ANSI_WARNINGS ON
go

SET NUMERIC_ROUNDABORT OFF
go

SET ARITHABORT ON
go

SET CONCAT_NULL_YIELDS_NULL ON
go

SET QUOTED_IDENTIFIER ON
go

SET ANSI_NULLS ON
go

SET ANSI_PADDING ON
go

SET ANSI_WARNINGS ON
go

SET NUMERIC_ROUNDABORT OFF
go

CREATE STATISTICS [_dta_stat_293576084_9_3] ON [dbo].[t_File]([CodeM], [DateRegistration])
go

SET QUOTED_IDENTIFIER ON
go

SET ARITHABORT ON
go

SET CONCAT_NULL_YIELDS_NULL ON
go

SET ANSI_NULLS ON
go

SET ANSI_PADDING ON
go

SET ANSI_WARNINGS ON
go

SET NUMERIC_ROUNDABORT OFF
go

SET ARITHABORT ON
go

SET CONCAT_NULL_YIELDS_NULL ON
go

SET QUOTED_IDENTIFIER ON
go

SET ANSI_NULLS ON
go

SET ANSI_PADDING ON
go

SET ANSI_WARNINGS ON
go

SET NUMERIC_ROUNDABORT OFF
go

CREATE STATISTICS [_dta_stat_293576084_2_9] ON [dbo].[t_File]([id], [CodeM])
go

SET QUOTED_IDENTIFIER ON
go

SET ARITHABORT ON
go

SET CONCAT_NULL_YIELDS_NULL ON
go

SET ANSI_NULLS ON
go

SET ANSI_PADDING ON
go

SET ANSI_WARNINGS ON
go

SET NUMERIC_ROUNDABORT OFF
go

SET ARITHABORT ON
go

SET CONCAT_NULL_YIELDS_NULL ON
go

SET QUOTED_IDENTIFIER ON
go

SET ANSI_NULLS ON
go

SET ANSI_PADDING ON
go

SET ANSI_WARNINGS ON
go

SET NUMERIC_ROUNDABORT OFF
go

CREATE STATISTICS [_dta_stat_293576084_10_9_2] ON [dbo].[t_File]([Insurance], [CodeM], [id])
go

SET QUOTED_IDENTIFIER ON
go

SET ARITHABORT ON
go

SET CONCAT_NULL_YIELDS_NULL ON
go

SET ANSI_NULLS ON
go

SET ANSI_PADDING ON
go

SET ANSI_WARNINGS ON
go

SET NUMERIC_ROUNDABORT OFF
go

CREATE NONCLUSTERED INDEX [_dta_index_t_RegistersAccounts_31_677577452__K1_K2_K8_5_7_9_10_19_20] ON [dbo].[t_RegistersAccounts] 
(
	[rf_idFiles] ASC,
	[id] ASC,
	[PrefixNumberRegister] ASC
)
INCLUDE ( [ReportYear],
[NumberRegister],
[PropertyNumberRegister],
[DateRegister],
[Letter],
[Account]) WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
go

CREATE NONCLUSTERED INDEX [_dta_index_t_RegistersAccounts_31_677577452__K1_K2_K8_7_9_10_19] ON [dbo].[t_RegistersAccounts] 
(
	[rf_idFiles] ASC,
	[id] ASC,
	[PrefixNumberRegister] ASC
)
INCLUDE ( [NumberRegister],
[PropertyNumberRegister],
[DateRegister],
[Letter]) WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
go

CREATE STATISTICS [_dta_stat_677577452_1_11] ON [dbo].[t_RegistersAccounts]([rf_idFiles], [rf_idSMO])
go

SET QUOTED_IDENTIFIER ON
go

SET ARITHABORT ON
go

SET CONCAT_NULL_YIELDS_NULL ON
go

SET ANSI_NULLS ON
go

SET ANSI_PADDING ON
go

SET ANSI_WARNINGS ON
go

SET NUMERIC_ROUNDABORT OFF
go

SET ARITHABORT ON
go

SET CONCAT_NULL_YIELDS_NULL ON
go

SET QUOTED_IDENTIFIER ON
go

SET ANSI_NULLS ON
go

SET ANSI_PADDING ON
go

SET ANSI_WARNINGS ON
go

SET NUMERIC_ROUNDABORT OFF
go

CREATE STATISTICS [_dta_stat_677577452_5_20] ON [dbo].[t_RegistersAccounts]([ReportYear], [Account])
go

CREATE STATISTICS [_dta_stat_677577452_11_8] ON [dbo].[t_RegistersAccounts]([rf_idSMO], [PrefixNumberRegister])
go

CREATE STATISTICS [_dta_stat_677577452_2_8] ON [dbo].[t_RegistersAccounts]([id], [PrefixNumberRegister])
go

CREATE STATISTICS [_dta_stat_677577452_1_6] ON [dbo].[t_RegistersAccounts]([rf_idFiles], [ReportMonth])
go

CREATE STATISTICS [_dta_stat_677577452_8_1_2] ON [dbo].[t_RegistersAccounts]([PrefixNumberRegister], [rf_idFiles], [id])
go

SET QUOTED_IDENTIFIER ON
go

SET ARITHABORT ON
go

SET CONCAT_NULL_YIELDS_NULL ON
go

SET ANSI_NULLS ON
go

SET ANSI_PADDING ON
go

SET ANSI_WARNINGS ON
go

SET NUMERIC_ROUNDABORT OFF
go

SET ARITHABORT ON
go

SET CONCAT_NULL_YIELDS_NULL ON
go

SET QUOTED_IDENTIFIER ON
go

SET ANSI_NULLS ON
go

SET ANSI_PADDING ON
go

SET ANSI_WARNINGS ON
go

SET NUMERIC_ROUNDABORT OFF
go

CREATE STATISTICS [_dta_stat_677577452_5_1_20] ON [dbo].[t_RegistersAccounts]([ReportYear], [rf_idFiles], [Account])
go

CREATE STATISTICS [_dta_stat_677577452_8_5_1] ON [dbo].[t_RegistersAccounts]([PrefixNumberRegister], [ReportYear], [rf_idFiles])
go

CREATE STATISTICS [_dta_stat_677577452_6_7_1] ON [dbo].[t_RegistersAccounts]([ReportMonth], [NumberRegister], [rf_idFiles])
go

CREATE STATISTICS [_dta_stat_677577452_1_8_11] ON [dbo].[t_RegistersAccounts]([rf_idFiles], [PrefixNumberRegister], [rf_idSMO])
go

CREATE STATISTICS [_dta_stat_1013578649_1_2] ON [dbo].[t_Diagnosis]([DiagnosisCode], [rf_idCase])
go

