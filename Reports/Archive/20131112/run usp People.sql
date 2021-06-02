USE AccountOMSReports
go
--DECLARE @reportYear SMALLINT=2013,
--		@dateBegin DATETIME='20130701',
--		@dateEnd DATETIME='20131208 23:59:59',
--		@reportMonth TINYINT=12

--EXEC dbo.usp_ReportPROF_O_D_MO_People @reportYear , @dateBegin,@dateEnd,   @reportMonth 
--EXEC dbo.usp_ReportPROF_O_V_MO_People @reportYear , @dateBegin,@dateEnd,   @reportMonth 
--GO
DECLARE @reportYear SMALLINT=2013,
		@dateBegin DATETIME='20130501',
		@dateEnd DATETIME='20131207 23:59:59',
		@reportMonth TINYINT=12
EXEC dbo.usp_ReportDV_MO_People @reportYear, @dateBegin, @dateEnd, @reportMonth 
