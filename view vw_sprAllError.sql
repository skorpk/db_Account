USE AccountOMS
go
if OBJECT_ID('vw_sprAllError',N'V') is not null
	drop view vw_sprAllError
go
create view vw_sprAllError
as
select Code,DescriptionError from oms_NSI.dbo.sprAllErrors
union all
select id,Description from oms_NSI.dbo.sprF012

go