USE [AccountOMS]
GO

/****** Object:  Table [dbo].[t_CaseFinancePlan]    Script Date: 24.01.2018 15:37:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[t_CaseFinancePlan](
	[id] [int] NULL,
	[DateRegistration] [datetime] NULL,
	[CodeM] [char](6) NULL,
	[rf_idCase] [bigint] NULL,
	[AmountPayment] [decimal](15, 2) NULL,
	[DateEnd] [date] NULL,
	[rf_idV006] [tinyint] NULL,
	[Quantity] [int] NULL,
	[UnitCode] [int] NULL,
	[reportMonth]  AS (datepart(month,[DateEnd])),
	[ReportYear]  AS (datepart(year,[DateEnd]))
) ON Reports

GO
/****** Object:  Index [IX_File]    Script Date: 24.01.2018 15:38:10 ******/
CREATE NONCLUSTERED INDEX [IX_File] ON [dbo].[t_CaseFinancePlan]
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON Reports
GO

/****** Object:  Index [IX_UnitCode_Year_DateReg_Month]    Script Date: 24.01.2018 15:38:18 ******/
CREATE NONCLUSTERED INDEX [IX_UnitCode_Year_DateReg_Month] ON [dbo].[t_CaseFinancePlan]
(
	[UnitCode] ASC,
	[ReportYear] ASC,
	[DateRegistration] ASC,
	[reportMonth] ASC
)
INCLUDE ( 	[CodeM],
	[rf_idCase],
	[AmountPayment],
	[Quantity]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON Reports
GO





