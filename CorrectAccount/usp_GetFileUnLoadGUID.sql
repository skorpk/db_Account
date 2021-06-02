USE [AccountOMS]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
if OBJECT_ID('usp_GetFileUnLoadGUID',N'P') is not null
drop proc usp_GetFileUnLoadGUID
go
create proc [dbo].[usp_GetFileUnLoadGUID]
as
--испоьлзую выбор файлов с помощью FILESTREAM
select FileZIP.PathName(),GET_FILESTREAM_TRANSACTION_CONTEXT(),rtrim(f.FileNameHR) as FileNameHR
from t_File f inner join t_DoubleGuidCase t on
		f.id=t.rf_idFiles
go
create nonclustered index IX_Case_GUID on dbo.t_Case(Guid_Case) with drop_existing
go