use AccountOMS
go
if OBJECT_ID('usp_GetFileUnLoadKey',N'P') is not null
drop proc usp_GetFileUnLoadKey
go
create proc usp_GetFileUnLoadKey
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

--помечаю файлы которые отдал в СМО

--испоьлзую выбор файлов с помощью FILESTREAM
--23.10.2013 решено отказаться от технологий выгрузки через SqlFileStream
select FileKey.PathName()
		,f.FileKey--GET_FILESTREAM_TRANSACTION_CONTEXT()
		,rtrim(FileNameKey) as FileNameKey
from t_FileKey f inner join @tableID t on
		f.rf_idFiles=t.id
go