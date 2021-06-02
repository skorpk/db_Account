USE RegisterCases
GO
if OBJECT_ID('vw_sprMUWithAge',N'V') is not null
	drop view vw_sprMUWithAge
GO
CREATE VIEW vw_sprMUWithAge
as
SELECT MU,cast(replace('<Root><Age age="'+Age+'" /></Root>',';','" /><Age age="') as xml) AS Age FROM oms_nsi.dbo.sprMUWithAge
go