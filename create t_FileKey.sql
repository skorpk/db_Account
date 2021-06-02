use AccountOMS
go
if OBJECT_ID('t_FileKey',N'U') is not null
drop table t_FileKey
go
CREATE TABLE dbo.t_FileKey
(
	[GUID] [uniqueidentifier] ROWGUIDCOL NOT NULL UNIQUE, 
	[rf_idFiles] INTEGER UNIQUE,
	[FileNameKey] varchar(30),
	[FileKey] VARBINARY(MAX) FILESTREAM not NULL
)
GO
ALTER TABLE [dbo].[t_FileKey] ADD  CONSTRAINT [DF_GUID_FileKey]  DEFAULT (newsequentialid()) FOR [GUID]
GO
ALTER TABLE [dbo].[t_FileKey]  WITH CHECK ADD  CONSTRAINT [FK_FileKey_Files] FOREIGN KEY([rf_idFiles])
REFERENCES [dbo].[t_File] ([id])
ON DELETE CASCADE
GO