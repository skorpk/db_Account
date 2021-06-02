use AccountOMS
go
if OBJECT_ID('DeleteFile',N'TR') is not null
drop trigger DeleteFile
go
CREATE TRIGGER DeleteFile
on dbo.t_File
AFTER Delete
AS
--добавляем Код МУ в t_Meduslugi по законченным случаям
insert t_FileDelete(rf_idFile,FileName)
select distinct d.id,d.FileNameHR
from deleted d
go
ENABLE TRIGGER DeleteFile on dbo.t_File
go