use AccountOMS
go
if(OBJECT_ID('t_FileError',N'U')) is not null
	drop table dbo.t_FileError
go
create table dbo.t_FileError
(
	id int identity(1,1) not null PRIMARY KEY,
	[FileName] varchar(26) not null,
	DateCreate datetime not null CONSTRAINT DF_DateCreate DEFAULT (GETDATE())
)
go
if(OBJECT_ID('t_Errors',N'U')) is not null
	DROP TABLE DBO.T_ERRORS
go
create table t_Errors
(
	ErrorNumber smallint not null,
	rf_idFileError int not null CONSTRAINT FK_Errors_FileError FOREIGN KEY(rf_idFileError) REFERENCES dbo.t_FileError(id) ON DELETE CASCADE 
)
GO