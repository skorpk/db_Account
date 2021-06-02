USE AccountOMSReports
GO
DELETE FROM dbo.t_SendingDataIntoFFOMS WHERE IsUnload=0 AND ReportYear=2019
GO
DECLARE @dateEndPay DATETIME=GETDATE(), -- на сегодняшний день
		@dateStartPay DATETIME, -- дата последнего платежа. Производим вычисление каждый раз.
		@dateEnd DATE= GETDATE(), -- на сегодняшний день случаи
		@reportYear smallint= 2019, 
		@dateStart datetime ='20190101' --с начало года берем

DECLARE @lastMonth TINYINT

SELECT @lastMonth=MAX(ReportMonth) FROM dbo.t_SendingDataIntoFFOMS WHERE ReportYear=@reportYear AND IsUnload=1

SELECT @dateStartPay=CASE WHEN @lastMonth=12 THEN  CAST(@reportYear+1 AS VARCHAR(4))+'0115' ELSE 
			CAST(@reportYear AS VARCHAR(4))+right('0'+CAST(@lastMonth+1 AS VARCHAR(2)),2)+'10' END


EXEC dbo.usp_SendingDataToFFOMS2019 @reportYear, @dateStart,@dateEnd ,@dateStartPay,@dateEndPay
GO
EXEC usp_CalculationPVT_FFOMS2019