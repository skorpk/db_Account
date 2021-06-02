use AccountOMS
go
if OBJECT_ID('usp_GetFileUnLoad',N'P') is not null
drop proc usp_GetFileUnLoad
go
create proc usp_GetFileUnLoad
			--@tableID as TVP_ErrorNumber READONLY
			@num nvarchar(max)
as
declare @tableID as TVP_ErrorNumber 
		
DECLARE @idoc int,
        @err int,
        @xml xml
        
select @xml=cast(replace('<Root><Num num="'+@num+'" /></Root>',',','" /><Num num="') as xml)
--CAST(dbo.fn_SplitNumber(@num) as xml)

 EXEC  @err = sp_xml_preparedocument @idoc OUTPUT, @xml
	insert @tableID 
	select num
	from OPENXML(@idoc, '/Root/Num', 1)
			  WITH (num int)

 EXEC sp_xml_removedocument @idoc
if ORIGINAL_LOGIN()<>'VTFOMS\AStepanova'
begin
	--помечаю файлы которые отдал в СМО
	insert t_FileExit(rf_idFile,FileName,DateUnLoad)
	select f.id,f.FileNameHR,GETDATE()
	from t_File f inner join @tableID t on
			f.id=t.id 
				left join t_FileExit fe on
			f.id=fe.rf_idFile		
	where fe.rf_idFile is null
end

--испоьлзую выбор файлов с помощью FILESTREAM
--23.10.2013 решено отказаться от технологий выгрузки через SqlFileStream
select FileZIP.PathName(),/*GET_FILESTREAM_TRANSACTION_CONTEXT()*/f.FileZIP,rtrim(FileNameHR) as FileNameHR
from t_File f inner join @tableID t on
		f.id=t.id
go
