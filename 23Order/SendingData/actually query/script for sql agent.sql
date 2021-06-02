USE AccountOMS
GO
SET QUOTED_IDENTIFIER on
--���������� �������� �� ������������ ������� �������
DELETE FROM dbo.t_SendingDataIntoFFOMS WHERE IsFullDoubleDate=0 AND IsUnload=0 AND ReportYear=2018

DECLARE @dateEndPay DATETIME=GETDATE(), -- �� ����������� ����
		@dateStartPay DATETIME, -- ���� ���������� �������. ���������� ���������� ������ ���.
		@dateEnd DATE= GETDATE(), -- �� ����������� ���� ������
		@reportYear smallint= 2018, 
		@dateStart datetime ='20180101' --� ������ ���� �����

DECLARE @lastMonth TINYINT

SELECT @lastMonth=MAX(ReportMonth) FROM dbo.t_SendingDataIntoFFOMS WHERE ReportYear=@reportYear AND IsUnload=1

SELECT @dateStartPay=CASE WHEN @lastMonth=12 THEN  CAST(@reportYear+1 AS VARCHAR(4))+'0115' ELSE 
			CAST(@reportYear AS VARCHAR(4))+left('0'+CAST(@lastMonth+1 AS VARCHAR(2)),2)+'10' END

--SELECT @dateStartPay,@dateEnd,@reportYear,@dateStart,@dateEndPay

EXEC dbo.usp_SendingDataToFFOMS @reportYear, @dateStart,@dateEnd ,@dateStartPay,@dateEndPay 

EXEC dbo.usp_CalculationPVT_FFOMS
