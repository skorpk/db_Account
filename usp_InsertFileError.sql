use AccountOMS
go
if OBJECT_ID('usp_InsertFileError',N'P') is not null
drop proc usp_InsertFileError
go
create proc usp_InsertFileError
			@fileName varchar(26),
			@errorID tinyint
as
	declare @idFile int
	insert t_FileError([FileName]) values(@fileName)
	set @idFile=SCOPE_IDENTITY()
	insert t_Errors(rf_idFileError,ErrorNumber,rf_sprErrorAccount) values(@idFile,50,@errorID)
	
	select @idFile,1
go

