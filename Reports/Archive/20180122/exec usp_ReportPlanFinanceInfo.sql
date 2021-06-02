USE ExchangeFinancing
GO
EXEC dbo.usp_ReportPlanFinanceInfo @year = 2018, -- smallint
    @unitCode = 1, -- tinyint
    @dateBeginReg = '20180101', -- datetime
    @dateEndReg = '20180125',
	@dateEndRegRAK='20180125',
    @quater = 2

--GRANT EXECUTE ON usp_ReportPlanFinanceInfo TO db_AccountOMS;