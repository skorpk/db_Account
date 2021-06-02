USE AccountOMS
GO
SELECT c.LPU
		--------------------стационар-------------------------------
		,COUNT(CASE WHEN c.V006 ='Стационарно' THEN c.Account+CAST(c.idRecordCase AS VARCHAR(10)) ELSE NULL end) AS CountRowStac
		,CAST(SUM(CASE WHEN c.V006 ='Стационарно' THEN c.AmountPayment ELSE 0.0 end) AS MONEY) AS AmountPaymentStac
		--------------------В дневном стационаре-------------------------------
		,COUNT(CASE WHEN c.V006 ='В дневном стационаре' THEN c.Account+CAST(c.idRecordCase AS VARCHAR(10)) ELSE NULL end) AS CountRowDnStac
		,CAST(SUM(CASE WHEN c.V006 ='В дневном стационаре' THEN c.AmountPayment ELSE 0.0 end) AS MONEY) AS AmountPaymentDnStac
		--------------------амбулаторно-------------------------------
		,COUNT(CASE WHEN c.V006 ='Амбулаторно' THEN c.Account+CAST(c.idRecordCase AS VARCHAR(10)) ELSE NULL end) AS CountRowAmbul
		,CAST(SUM(CASE WHEN c.V006 ='Амбулаторно' THEN c.AmountPayment ELSE 0.0 end) AS MONEY) AS AmountPaymentAmbul
		--------------------Вне медицинской организации-------------------------------
		,COUNT(CASE WHEN c.V006 ='Вне медицинской организации' THEN c.Account+CAST(c.idRecordCase AS VARCHAR(10)) ELSE NULL end) AS CountRowSMP
		,CAST(SUM(CASE WHEN c.V006 ='Вне медицинской организации' THEN c.AmountPayment ELSE 0.0 end) AS MONEY) AS AmountPaymentSMP
FROM dbo.tmpCovidCases c 
GROUP BY c.LPU
ORDER BY LPU