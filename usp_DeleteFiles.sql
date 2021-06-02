use AccountOMS
go
if OBJECT_ID('usp_DeleteFile',N'P') is not null
drop proc usp_DeleteFile
go
--удаляем файлы если они не были отданны в СМО иначе ничего не удаляем
create proc usp_DeleteFile
			@id int
as
DELETE FROM dbo.t_FileExit WHERE rf_idFile=@id AND SUSER_ID()=283

if NOT EXISTS(select * from t_FileExit e where e.rf_idFile=@id)
BEGIN	 
	delete from t_File where id=@id
	select 1
end
else 
begin
	select 0
end
  
go