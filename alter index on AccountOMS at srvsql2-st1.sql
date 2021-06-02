USE [AccountOMS]
GO
ALTER TABLE [dbo].[t_MES] DROP CONSTRAINT [FK_MES_Cases];
ALTER TABLE [dbo].[t_Meduslugi] DROP CONSTRAINT [FK_Meduslugi_Cases];
ALTER TABLE [dbo].[t_Case] DROP CONSTRAINT [PK__t_Case__3213E83F38996AB5];
DROP INDEX [IX_ClusteredIdex] ON [dbo].[t_Meduslugi] WITH ( ONLINE = OFF );
ALTER TABLE [dbo].[t_Case] DROP CONSTRAINT [FK_Cases_RecordCasePatient]
ALTER TABLE [dbo].[t_RecordCasePatient] DROP CONSTRAINT [PK_RecordCasePatient_idFiles_idRecordCase]


/****** Object:  Index [PK__t_File__3213E83F1367E606]    Script Date: 21.08.2017 21:16:43 ******/
ALTER TABLE [dbo].[t_File] DROP CONSTRAINT [PK__t_File__3213E83F1367E606]
GO

ALTER TABLE dbo.t_File ALTER COLUMN id int NOT NULL

--UPDATE dbo.t_File SET id2=id

--ALTER TABLE dbo.t_File DROP COLUMN id



ALTER TABLE [dbo].[t_File] ADD  CONSTRAINT [PK__t_File__3213E83F1367E606] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO


-----------------------------------------------------------------------------------------------------------------------------------------------
ALTER TABLE [dbo].[t_RecordCasePatient] ADD  CONSTRAINT [PK_RecordCasePatient_idFiles_idRecordCase] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
ALTER TABLE [dbo].[t_Case]  WITH CHECK ADD  CONSTRAINT [FK_Cases_RecordCasePatient] FOREIGN KEY([rf_idRecordCasePatient])
REFERENCES [dbo].[t_RecordCasePatient] ([id])
ON DELETE CASCADE
ALTER TABLE [dbo].[t_Case] CHECK CONSTRAINT [FK_Cases_RecordCasePatient];
ALTER TABLE [dbo].[t_Case] ADD PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
------------------------------------------------------------------------------------------------------

ALTER TABLE [dbo].[t_Meduslugi]  WITH CHECK ADD  CONSTRAINT [FK_Meduslugi_Cases] FOREIGN KEY([rf_idCase])
REFERENCES [dbo].[t_Case] ([id])
ON DELETE CASCADE
ALTER TABLE [dbo].[t_Meduslugi] CHECK CONSTRAINT [FK_Meduslugi_Cases]
ALTER TABLE [dbo].[t_MES]  WITH CHECK ADD  CONSTRAINT [FK_MES_Cases] FOREIGN KEY([rf_idCase])
REFERENCES [dbo].[t_Case] ([id])
ON DELETE CASCADE
ALTER TABLE [dbo].[t_MES] CHECK CONSTRAINT [FK_MES_Cases];

CREATE CLUSTERED INDEX [IX_ClusteredIdex] ON [dbo].[t_Meduslugi]
(
	[id] ASC,
	[rf_idCase] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO




