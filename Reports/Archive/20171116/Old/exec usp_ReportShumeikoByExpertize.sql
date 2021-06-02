USE AccountOMS
GO
DECLARE @dtBegin DATETIME='20170101',	
		@dtEndReg DATETIME='20170630 23:59:59',
		@dtEndRegAkt DATETIME='20171122 23:59:59',
		@v6 TINYINT=4,--меняем условия оказания мед.помощи
		@codeSMO CHAR(5)='34007'

EXEC dbo.usp_ReportShumeikoByExpertize @dtBegin ,@dtEndReg,@dtEndRegAkt,@v6, @codeSMO 
