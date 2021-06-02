use AccountOMS
go
declare @id int
select @id=id
from vw_getIdFileNumber where FileNameHR='HM174601S34002_1612001'

--select * from t_File where id=644292

declare @p1 varbinary(max)
SELECT	@p1=HRM.ZL_LIST				
FROM	OPENROWSET(BULK 'c:\Test\HM174601S34002_1612001.ZIP',SINGLE_BLOB) HRM (ZL_LIST)

update t_File
set FileZIP=@p1 where id=@id