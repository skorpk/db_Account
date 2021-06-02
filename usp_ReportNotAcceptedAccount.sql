use AccountOMS
go
if OBJECT_ID('usp_ReportNotAcceptedAccount',N'P') is not null
drop proc usp_ReportNotAcceptedAccount
go
--подаются тока записи по файлам который были приняты.
create proc usp_ReportNotAcceptedAccount
			@num nvarchar(max)--TVP_ReportMO READONLY
as
SET LANGUAGE russian
			
declare @t as table(id int)
		
DECLARE @idoc int,
        @err int,
        @xml xml
        
select @xml=cast(replace('<Root><Num num="'+@num+'" /></Root>',',','" /><Num num="') as xml)
--CAST(dbo.fn_SplitNumber(@num) as xml)

 EXEC  @err = sp_xml_preparedocument @idoc OUTPUT, @xml
insert @t
select num
from OPENXML(@idoc, '/Root/Num', 1)
          WITH (num int)

 EXEC sp_xml_removedocument @idoc

	select f.FileName,convert(CHAR(10),f.DateCreate,104)+' '+cast(cast(f.DateCreate as time(7)) as varchar(8)) as DateRegistration
	,e.ErrorNumber,ea.DescriptionError
	from t_FileError f inner join t_Errors e on
				f.id=e.rf_idFileError
						inner join @t t1 on
				f.id=t1.id
						inner join vw_sprAllError ea on
				e.ErrorNumber=ea.Code
				
					
go