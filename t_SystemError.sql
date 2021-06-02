USE AccountOMS
GO
if(OBJECT_ID('t_SystemError',N'U')) is not null
	drop table dbo.t_SystemError
go
create table t_SystemError
(
	[FileName] varchar(26),
	DateOperation DATETIME,
	ERROR VARCHAR(100)	
)
go