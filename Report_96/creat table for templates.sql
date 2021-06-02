USE AccountOMS
GO

CREATE TABLE [dbo].[t_Report_Templates](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[NameFile] [varchar](50) NOT NULL,
	[DateLoad] [datetime] NOT NULL,
	[UserName] [varchar](50) NOT NULL,
	[DATA] [varbinary](max) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[t_Report_Templates] ADD  DEFAULT (getdate()) FOR [DateLoad]
GO

ALTER TABLE [dbo].[t_Report_Templates] ADD  DEFAULT (original_login()) FOR [UserName]
GO


