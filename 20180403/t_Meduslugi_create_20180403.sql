USE [AccountOMS]
GO

/****** Object:  Table [dbo].[t_Meduslugi]    Script Date: 03.04.2018 19:58:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--SET ANSI_PADDING ON
--GO

--CREATE TABLE [dbo].[t_Meduslugi](
--	[rf_idCase] [bigint] NOT NULL,
--	[id] [varchar](36) NOT NULL,
--	[GUID_MU] [uniqueidentifier] NOT NULL,
--	[rf_idMO] [char](6) NOT NULL,
--	[rf_idSubMO] [char](6) NULL,
--	[rf_idDepartmentMO] [int] NULL,
--	[rf_idV002] [smallint] NOT NULL,
--	[IsChildTariff] [bit] NULL,
--	[DateHelpBegin] [date] NOT NULL,
--	[DateHelpEnd] [date] NOT NULL,
--	[DiagnosisCode] [char](10) NULL,
--	[MUGroupCode] [tinyint] NOT NULL,
--	[MUUnGroupCode] [tinyint] NOT NULL,
--	[MUCode] [smallint] NOT NULL,
--	[Quantity] [decimal](6, 2) NOT NULL,
--	[Price] [decimal](15, 2) NOT NULL,
--	[TotalPrice] [decimal](15, 2) NOT NULL,
--	[rf_idV004] [int] NOT NULL,
--	[rf_idDoctor] [char](16) NULL,
--	[Comments] [nvarchar](250) NULL,
--	[MU]  AS ((((CONVERT([varchar](2),[MUGroupCode],(0))+'.')+CONVERT([varchar](2),[MUUnGroupCode],(0)))+'.')+CONVERT([varchar](3),[MUCode],(0))),
--	[MUSurgery] [varchar](20) NULL,
--	[MUInt]  AS (([MUGroupCode]*(100000)+[MUUnGroupCode]*(1000))+[MUCode]),
--	[IsNeedUsl] [tinyint] NULL
--) ON [AccountMU]

--GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[t_Meduslugi]  WITH CHECK ADD  CONSTRAINT [FK_Meduslugi_Cases2] FOREIGN KEY([rf_idCase])
REFERENCES [dbo].[t_Case] ([id])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[t_Meduslugi] CHECK CONSTRAINT [FK_Meduslugi_Cases2]
GO


