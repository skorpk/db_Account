---------------------------BACKUP------------------------------------------------------
BACKUP DATABASE AccountOMS 
TO  DISK = N'E:\Backup\AccountOMS\Account_20111203.bak' 
WITH NOFORMAT, INIT,  
NAME = N'AccountOMS-Full Database Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 10
GO
---------------------------RESTORE----------------------------------------------------
use master
go
alter database AccountOMS set SINGLE_USER with rollback immediate
go
RESTORE DATABASE AccountOMS FROM  DISK = N'E:\Backup\AccountOMS\Account_20111126.bak' WITH  FILE = 1,  NOUNLOAD, REPLACE, STATS = 10

--RESTORE HEADERONLY FROM  DISK = N'E:\Backup\RegisterCase\RegisterCase_20111029.bak' WITH  NOUNLOAD
GO
alter database AccountOMS set MULTI_USER 
go
