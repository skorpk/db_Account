use AccountOMS
go
if(OBJECT_ID('t_FileUser',N'U')) is not null
	drop table dbo.t_FileUser
go
create table t_FileUser
(
	[FileName] varchar(26),
	UserName varchar(40),
	DateOperation datetime
)
go
IF OBJECT_ID('usp_InsertIntoFileUser', N'P') IS NOT NULL
	DROP PROC usp_InsertIntoFileUser
GO
create procedure usp_InsertIntoFileUser
			@file varchar(26)
as
if not exists(select * from t_FileUser where [FileName]=@file and UserName= ORIGINAL_LOGIN())
begin
	insert t_FileUser([FileName],UserName,DateOperation) values(@file, ORIGINAL_LOGIN(), GETDATE())
end
go
IF OBJECT_ID('usp_DeleteFromFileUser', N'P') IS NOT NULL
	DROP PROC usp_DeleteFromFileUser
GO
create procedure usp_DeleteFromFileUser
			@file varchar(26)
as
	delete from t_FileUser where [FileName]=@file and UserName=ORIGINAL_LOGIN()
go
IF OBJECT_ID('usp_ExistsFromFileUser', N'P') IS NOT NULL
	DROP PROC usp_ExistsFromFileUser
GO
create procedure usp_ExistsFromFileUser
			@file varchar(26)
as
select COUNT(*) from t_FileUser where [FileName]=@file and UserName<>ORIGINAL_LOGIN()
go