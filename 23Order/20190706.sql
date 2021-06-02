USE AccountOMSReports
go
DECLARE @dateEndPay DATETIME='20190610', -- �� ����������� ����
		@dateStartPay DATETIME, -- ���� ���������� �������. ���������� ���������� ������ ���.
		@dateEnd DATE= '20190610', -- �� ����������� ���� ������
		@reportYear smallint= 2019, 
		@dateStart datetime ='20190101' --� ������ ���� �����

DECLARE @lastMonth TINYINT

SELECT @lastMonth=MAX(ReportMonth) FROM dbo.t_SendingDataIntoFFOMS WHERE ReportYear=@reportYear-- AND IsUnload=1

SELECT @dateStartPay=CASE WHEN @lastMonth=12 THEN  CAST(@reportYear+1 AS VARCHAR(4))+'0115' ELSE 
			CAST(@reportYear AS VARCHAR(4))+right('0'+CAST(@lastMonth+1 AS VARCHAR(2)),2)+'10' END

SELECT  @reportYear, @dateStart,@dateEnd ,@dateStartPay,@dateEndPay

EXEC dbo.usp_SendingDataToFFOMS2019 @reportYear, @dateStart,@dateEnd ,@dateStartPay,@dateEndPay
 GO
EXEC usp_CalculationPVT_FFOMS2019 