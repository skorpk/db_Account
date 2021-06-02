use AccountOMS
go
if exists(select * from sys.types where name='TVP_ErrorNumber' )
	drop type TVP_ErrorNumber
go
CREATE TYPE dbo.TVP_ErrorNumber AS TABLE(id int)
GO
if exists(select * from sys.types where name='TVP_ReportMO' )
	drop type TVP_ReportMO
go
CREATE TYPE dbo.TVP_ReportMO AS TABLE(id int, isfault bit)
GO