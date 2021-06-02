use AccountOMS
go		
IF OBJECT_ID (N'dbo.fn_NumberRegister', N'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_NumberRegister
go
--функция возвращает 1 если присутствует данный номер реестр СП и ТК и небыл принят счет с данным номером на это лпу
--если возвращаемое значение отлично от 1 значит ошибка.
CREATE FUNCTION dbo.fn_NumberRegister(@account varchar(15))
RETURNS int
as
begin
declare @i int
		select @i=cast(rtrim(left(substring(@account,charindex('-',@account)+1,charindex('-',@account,charindex('-',@account)+1)-charindex('-',@account)-1),6)) as int)
RETURN(@i)
end
go
IF OBJECT_ID (N'dbo.fn_PrefixNumberRegister', N'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_PrefixNumberRegister
go
--функция возвращает 1 если присутствует данный номер реестр СП и ТК и небыл принят счет с данным номером на это лпу
--если возвращаемое значение отлично от 1 значит ошибка.
CREATE FUNCTION dbo.fn_PrefixNumberRegister(@account varchar(15))
RETURNS int
as
begin
declare @i int
		select @i=cast(replace(rtrim(left(left(@account,charindex('-',@account)),5)),'-','') as int)
RETURN(@i)
end
go
IF OBJECT_ID (N'dbo.fn_PropertyNumberRegister', N'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_PropertyNumberRegister
go
--функция возвращает 1 если присутствует данный номер реестр СП и ТК и небыл принят счет с данным номером на это лпу
--если возвращаемое значение отлично от 1 значит ошибка.
CREATE FUNCTION dbo.fn_PropertyNumberRegister(@account varchar(15))
RETURNS int
as
begin
declare @i int
		select @i=cast(case when IsNumeric(rtrim(left(right(@account,len(@account)-charindex('-',@account,charindex('-',@account)+1)),2)))=1 
						then rtrim(left(right(@account,len(@account)-charindex('-',@account,charindex('-',@account)+1)),2))
						else left(rtrim(left(right(@account,len(@account)-charindex('-',@account,charindex('-',@account)+1)),2)),1) end as int)
RETURN(@i)
end
go
IF OBJECT_ID (N'dbo.fn_LetterNumberRegister', N'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_LetterNumberRegister
go
--функция возвращает 1 если присутствует данный номер реестр СП и ТК и небыл принят счет с данным номером на это лпу
--если возвращаемое значение отлично от 1 значит ошибка.
CREATE FUNCTION dbo.fn_LetterNumberRegister(@account varchar(15))
RETURNS char(1)
as
begin
declare @i char(1)
		select @i=case when IsNumeric(rtrim(left(right(@account,len(@account)-charindex('-',@account,charindex('-',@account)+1)),2)))=0 
						then right(rtrim(left(right(@account,len(@account)-charindex('-',@account,charindex('-',@account)+1)),2)),1)
						else null end 
RETURN(@i)
end
go