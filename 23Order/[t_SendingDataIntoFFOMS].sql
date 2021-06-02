USE [AccountOMSReports]
GO

/****** Object:  Table [dbo].[t_SendingDataIntoFFOMS]    Script Date: 06.07.2019 16:23:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING OFF
GO

CREATE TABLE [dbo].[t_SendingDataIntoFFOMS](
	[id] [bigint] NULL,
	[rf_idCase] [bigint] NOT NULL,
	[CodeM] [char](6) NOT NULL,
	[rf_idMO] [char](6) NOT NULL,
	[ReportMonth] [tinyint] NOT NULL,
	[ReportYear] [smallint] NOT NULL,
	[rf_idF008] [tinyint] NOT NULL,
	[rf_idV006] [tinyint] NOT NULL,
	[SeriaPolis] [varchar](10) NULL,
	[NumberPolis] [varchar](20) NOT NULL,
	[BirthDay] [date] NOT NULL,
	[rf_idV005] [tinyint] NOT NULL,
	[idRecordCase] [bigint] NOT NULL,
	[rf_idV014] [tinyint] NULL,
	[UnitOfHospital] [varchar](20) NULL,
	[DateBegin] [date] NOT NULL,
	[DateEnd] [date] NOT NULL,
	[DS1] [char](10) NULL,
	[DS2] [char](10) NULL,
	[DS3] [char](10) NULL,
	[rf_idV009] [smallint] NOT NULL,
	[MES] [varchar](20) NULL,
	[AmountPayment] [decimal](15, 2) NOT NULL,
	[AmountPaymentZSL] [decimal](15, 2) NOT NULL,
	[idMU] [varchar](36) NULL,
	[MUSurgery] [varchar](20) NULL,
	[Age] [smallint] NULL,
	[VZST] [int] NOT NULL,
	[K_KSG] [varchar](20) NULL,
	[KSG_PG] [int] NOT NULL,
	[PVT] [int] NOT NULL,
	[IsDisableCheck] [int] NOT NULL,
	[IsFullDoubleDate] [bit] NOT NULL,
	[IsUnload] [bit] NOT NULL,
	[IT_SL] [decimal](3, 2) NULL,
	[SL_K]  AS (case when [IT_SL] IS NOT NULL then (1) else (0) end),
	[ENP] [varchar](16) NULL,
	[TypeCases] [tinyint] NOT NULL,
	[Quantity] [int] NULL,
	[TotalPriceMU] [decimal](15, 2) NULL,
	[UR_K] [tinyint] NULL,
	[IDSP] [tinyint] NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[t_SendingDataIntoFFOMS] ADD  DEFAULT ((0)) FOR [IsFullDoubleDate]
GO

ALTER TABLE [dbo].[t_SendingDataIntoFFOMS] ADD  DEFAULT ((0)) FOR [IsUnload]
GO

ALTER TABLE [dbo].[t_SendingDataIntoFFOMS] ADD  DEFAULT ((9)) FOR [TypeCases]
GO


