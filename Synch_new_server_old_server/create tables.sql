USE AccountOMS
GO
CREATE TABLE [dbo].[tmp_FileSynchFin]
(
[rf_idFile] [int] NULL
) ON [PRIMARY]
GO
CREATE TABLE [dbo].[t_FileSynchFin]
(
	[rf_idFile] [int] NULL,
	[DateSynch] [datetime] NULL
) ON [PRIMARY]

GO

