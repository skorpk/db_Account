USE [AccountOMS]
GO
/****** Object:  Table [dbo].[t_MeduslugiOld]    Script Date: 03.04.2018 21:31:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[t_MeduslugiOld](
	[rf_idCase] [bigint] NOT NULL,
	[id] [varchar](36) NOT NULL,
	[GUID_MU] [uniqueidentifier] NOT NULL,
	[rf_idMO] [char](6) NOT NULL,
	[rf_idSubMO] [char](6) NULL,
	[rf_idDepartmentMO] [int] NULL,
	[rf_idV002] [smallint] NOT NULL,
	[IsChildTariff] [bit] NULL,
	[DateHelpBegin] [date] NOT NULL,
	[DateHelpEnd] [date] NOT NULL,
	[DiagnosisCode] [char](10) NULL,
	[MUGroupCode] [tinyint] NOT NULL,
	[MUUnGroupCode] [tinyint] NOT NULL,
	[MUCode] [smallint] NOT NULL,
	[Quantity] [decimal](6, 2) NOT NULL,
	[Price] [decimal](15, 2) NOT NULL,
	[TotalPrice] [decimal](15, 2) NOT NULL,
	[rf_idV004] [int] NOT NULL,
	[rf_idDoctor] [char](16) NULL,
	[Comments] [nvarchar](250) NULL,
	[MU]  AS ((((CONVERT([varchar](2),[MUGroupCode],(0))+'.')+CONVERT([varchar](2),[MUUnGroupCode],(0)))+'.')+CONVERT([varchar](3),[MUCode],(0))),
	[MUSurgery] [varchar](20) NULL,
	[MUInt]  AS (([MUGroupCode]*(100000)+[MUUnGroupCode]*(1000))+[MUCode]),
	[IsNeedUsl] [tinyint] NULL
) ON [AccountMU]

GO
SET ANSI_PADDING OFF
GO
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF

GO
/****** Object:  Index [IX_MU_Case]    Script Date: 03.04.2018 21:31:10 ******/
CREATE NONCLUSTERED INDEX [IX_MU_Case] ON [dbo].[t_MeduslugiOld]
(
	[MU] ASC
)
INCLUDE ( 	[rf_idCase]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [AccountMU]
GO
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF

GO
/****** Object:  Index [IX_MU_Case2]    Script Date: 03.04.2018 21:31:10 ******/
CREATE NONCLUSTERED INDEX [IX_MU_Case2] ON [dbo].[t_MeduslugiOld]
(
	[MU] ASC
)
INCLUDE ( 	[rf_idCase]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [AccountMU]
GO
/****** Object:  Index [IX_MU_idCase]    Script Date: 03.04.2018 21:31:10 ******/
CREATE NONCLUSTERED INDEX [IX_MU_idCase] ON [dbo].[t_MeduslugiOld]
(
	[MUGroupCode] ASC,
	[MUUnGroupCode] ASC
)
INCLUDE ( 	[rf_idCase]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [AccountMU]
GO
/****** Object:  Index [IX_MU_idCase2]    Script Date: 03.04.2018 21:31:10 ******/
CREATE NONCLUSTERED INDEX [IX_MU_idCase2] ON [dbo].[t_MeduslugiOld]
(
	[MUGroupCode] ASC,
	[MUUnGroupCode] ASC
)
INCLUDE ( 	[rf_idCase]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [AccountMU]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_MU_RefCase_ID]    Script Date: 03.04.2018 21:31:10 ******/
CREATE NONCLUSTERED INDEX [IX_MU_RefCase_ID] ON [dbo].[t_MeduslugiOld]
(
	[rf_idCase] ASC
)
INCLUDE ( 	[id],
	[MUCode],
	[MUGroupCode],
	[MUUnGroupCode]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [AccountMU]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_MU_RefCase_ID2]    Script Date: 03.04.2018 21:31:10 ******/
CREATE NONCLUSTERED INDEX [IX_MU_RefCase_ID2] ON [dbo].[t_MeduslugiOld]
(
	[rf_idCase] ASC
)
INCLUDE ( 	[id],
	[MUCode],
	[MUGroupCode],
	[MUUnGroupCode]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [AccountMU]
GO
/****** Object:  Index [QU_Case_MU]    Script Date: 03.04.2018 21:31:10 ******/
CREATE UNIQUE NONCLUSTERED INDEX [QU_Case_MU] ON [dbo].[t_MeduslugiOld]
(
	[rf_idCase] ASC,
	[GUID_MU] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = ON, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [AccountMU]
GO
/****** Object:  Index [QU_Case_MU2]    Script Date: 03.04.2018 21:31:10 ******/
CREATE UNIQUE NONCLUSTERED INDEX [QU_Case_MU2] ON [dbo].[t_MeduslugiOld]
(
	[rf_idCase] ASC,
	[GUID_MU] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = ON, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [AccountMU]
GO
ALTER TABLE [dbo].[t_MeduslugiOld]  WITH CHECK ADD  CONSTRAINT [FK_Meduslugi_Cases] FOREIGN KEY([rf_idCase])
REFERENCES [dbo].[t_Case] ([id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[t_MeduslugiOld] CHECK CONSTRAINT [FK_Meduslugi_Cases]
GO
