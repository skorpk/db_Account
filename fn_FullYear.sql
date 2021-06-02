use AccountOMS
go
IF OBJECT_ID (N'dbo.fn_FullYear', N'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_FullYear;
GO
create function dbo.fn_FullYear (@DateBeg date,@DateEnd date)
RETURNS int
as
begin
	declare @FullYear int
	select @FullYear=DATEDIFF(YEAR,@DateBeg,@DateEnd)-CASE WHEN 100*MONTH(@DateBeg)+DAY(@DateBeg)>100*MONTH(@DateEnd)+DAY(@DateEnd) THEN 1 ELSE 0 END;
	return (@FullYear)
end
GO