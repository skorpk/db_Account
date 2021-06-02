use AccountOMS
go		
IF OBJECT_ID (N'dbo.fn_MonthName', N'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_MonthName
go
--функция возвращает 1 если присутствует данный номер реестр СП и ТК и небыл принят счет с данным номером на это лпу
--если возвращаемое значение отлично от 1 значит ошибка.
go
CREATE FUNCTION dbo.fn_MonthName(@year smallint, @month tinyint)
RETURNS nvarchar(30)
as
begin
declare @i nvarchar(30),
		@d char(10)=CAST(@year as CHAR(4))+right('0'+CAST(@month as varchar(2)),2)+'01'
		
		select @i=DATENAME(MONTH,@d)+' '+CAST(@year as CHAR(4))+' г.'
RETURN(@i)
end
go


