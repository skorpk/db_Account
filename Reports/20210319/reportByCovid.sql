USE AccountOMS
GO
SELECT c.LPU
		--------------------���������-------------------------------
		,COUNT(CASE WHEN c.V006 ='�����������' THEN c.Account+CAST(c.idRecordCase AS VARCHAR(10)) ELSE NULL end) AS CountRowStac
		,CAST(SUM(CASE WHEN c.V006 ='�����������' THEN c.AmountPayment ELSE 0.0 end) AS MONEY) AS AmountPaymentStac
		--------------------� ������� ����������-------------------------------
		,COUNT(CASE WHEN c.V006 ='� ������� ����������' THEN c.Account+CAST(c.idRecordCase AS VARCHAR(10)) ELSE NULL end) AS CountRowDnStac
		,CAST(SUM(CASE WHEN c.V006 ='� ������� ����������' THEN c.AmountPayment ELSE 0.0 end) AS MONEY) AS AmountPaymentDnStac
		--------------------�����������-------------------------------
		,COUNT(CASE WHEN c.V006 ='�����������' THEN c.Account+CAST(c.idRecordCase AS VARCHAR(10)) ELSE NULL end) AS CountRowAmbul
		,CAST(SUM(CASE WHEN c.V006 ='�����������' THEN c.AmountPayment ELSE 0.0 end) AS MONEY) AS AmountPaymentAmbul
		--------------------��� ����������� �����������-------------------------------
		,COUNT(CASE WHEN c.V006 ='��� ����������� �����������' THEN c.Account+CAST(c.idRecordCase AS VARCHAR(10)) ELSE NULL end) AS CountRowSMP
		,CAST(SUM(CASE WHEN c.V006 ='��� ����������� �����������' THEN c.AmountPayment ELSE 0.0 end) AS MONEY) AS AmountPaymentSMP
FROM dbo.tmpCovidCases c 
GROUP BY c.LPU
ORDER BY LPU