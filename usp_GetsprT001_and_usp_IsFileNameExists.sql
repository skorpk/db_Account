use AccountOMS
go
if OBJECT_ID('usp_GetsprT001',N'P') is not null
drop proc usp_GetsprT001
go
create procedure usp_GetsprT001
				@CodeM varchar(6)
as 
select COUNT(*)
from oms_nsi.dbo.vw_sprT001
where CodeM=@CodeM
go
----------------------------------------------------------------------------
if OBJECT_ID('usp_IsFileNameExists',N'P') is not null
drop proc usp_IsFileNameExists
go
create procedure usp_IsFileNameExists
				@fileName varchar(26)
as 

select COUNT(*) from t_File where upper(FileNameHR)= UPPER(rtrim(ltrim(@fileName)))
go
