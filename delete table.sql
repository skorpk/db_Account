use AccountOMS
go
if(OBJECT_ID('t_FileDelete',N'U')) is not null
	drop table dbo.t_FileDelete
go
create table dbo.t_FileDelete
(
	rf_idFile int not null,
	[FileName] varchar(26) not null,	
	DateDelete datetime not null CONSTRAINT DF_DateDelete DEFAULT (GETDATE()),
	UserName varchar(30) not null CONSTRAINT DF_DeleteUserName default (ORIGINAL_LOGIN())	
)
go