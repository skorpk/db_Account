USE [RegisterCases]
GO

/****** Object:  Index [IX_MES_AccountOMS]    Script Date: 07/19/2013 13:01:25 ******/
CREATE NONCLUSTERED INDEX [IX_MES_AccountOMS] ON [dbo].[t_MES] 
(
	[MES] ASC	
)
INCLUDE ( [rf_idCase])WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = ON, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [RegisterCases]
GO


CREATE NONCLUSTERED INDEX [IX_Meduslugi_Case] ON [dbo].[t_Meduslugi] 
(
	[rf_idCase] ASC
)
INCLUDE ( id,GUID_MU,rf_idMO,DiagnosisCode,rf_idV004,[DateHelpBegin],
[DateHelpEnd],
[IsChildTariff],
[MUCode],
[Quantity],
[Price],
[rf_idV002],
[TotalPrice],
[Comments]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = ON, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [RegisterCases]
GO
