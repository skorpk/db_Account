USE AccountOMS
GO
EXEC dbo.usp_ReportHeartStenting @dtBegin = '20170101', @dtEndReg = '20180101', @dtBeginRAK = '20170101', @dtEndRegRAK = '20180101', @reportYear = 2017
