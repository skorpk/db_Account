use AccountOMS
go
if(OBJECT_ID('t_FileExit',N'U')) is not null
	drop table dbo.t_FileExit
go
create table dbo.t_FileExit
(
	rf_idFile int not null CONSTRAINT FK_FileExit_Files FOREIGN KEY(rf_idFile) REFERENCES dbo.t_File(id) on delete cascade,
	[FileName] varchar(26) not null,	
	DateUnLoad datetime not null CONSTRAINT DF_DateUnLoad DEFAULT (GETDATE()),
	UserName varchar(30) not null CONSTRAINT DF_UnLoadUserName default (ORIGINAL_LOGIN())	
)
go