USE AccountOMS
GO
DELETE FROM dbo.t_SendingDataIntoFFOMS WHERE IsUnload=0 AND ReportYear=2018
SELECT ReportMonth,ReportYear,COUNT(DISTINCT rf_idCase) from dbo.t_SendingDataIntoFFOMS WHERE ReportYear=2018 GROUP BY ReportMonth,ReportYear ORDER BY ReportMonth
----------------------step 2--------------------
DECLARE @dateEndPay DATETIME=GETDATE(), -- на сегодняшний день
		@dateStartPay DATETIME, -- дата последнего платежа. Производим вычисление каждый раз.
		@dateEnd DATE= GETDATE(), -- на сегодняшний день случаи
		@reportYear smallint= 2018, 
		@dateStart datetime ='20180101' --с начало года берем

DECLARE @lastMonth TINYINT

SELECT @lastMonth=MAX(ReportMonth) FROM dbo.t_SendingDataIntoFFOMS WHERE ReportYear=@reportYear AND IsUnload=1

SELECT @dateStartPay=CASE WHEN @lastMonth=12 THEN  CAST(@reportYear+1 AS VARCHAR(4))+'0115' ELSE 
			CAST(@reportYear AS VARCHAR(4))+left('0'+CAST(@lastMonth+1 AS VARCHAR(2)),2)+'10' END

EXEC dbo.usp_SendingDataToFFOMS @reportYear, @dateStart,@dateEnd ,@dateStartPay,@dateEndPay 
--------------------step 3----------------------
EXEC dbo.usp_CalculationPVT_FFOMS
go