use AccountOMS
go
select id,FileNameHR,CodeM from t_File
go
alter table dbo.t_File add CodeM as SUBSTRING(FileNameHR,3,6)
go
create nonclustered index IX_FileCodeM on dbo.t_File(CodeM)
go

