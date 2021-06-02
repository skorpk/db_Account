USE AccountOMSReports
GO
/*
BEGIN TRANSACTION
UPDATE s SET s.TotalPriceMU=m.TotalPrice
FROM dbo.t_SendingDataIntoFFOMS s INNER JOIN dbo.t_Meduslugi m ON
			s.rf_idCase=m.rf_idCase
			AND s.idMU=m.id
 WHERE ReportYear=2020 AND ReportMonth=6 AND s.TotalPriceMU<>m.TotalPrice --AND s.id=26660

--SELECT CASE WHEN TypeCases=10 THEN AmountPayment-TotalPriceMU ELSE AmountPayment END 
--			FROM dbo.vw_SUM23Order so WHERE so.rf_idCase=116702704

SELECT s.*
FROM dbo.t_SendingDataIntoFFOMS s INNER JOIN dbo.t_Meduslugi m ON
			s.rf_idCase=m.rf_idCase
			AND s.idMU=m.id
 WHERE ReportYear=2020 AND ReportMonth=6 AND s.id=22908
commit
*/
SELECT s.*,m.Quantity
FROM dbo.t_SendingDataIntoFFOMS s INNER JOIN dbo.t_Meduslugi m ON
			s.rf_idCase=m.rf_idCase
			AND s.idMU=m.id
 WHERE ReportYear=2020 AND ReportMonth=6 AND s.id=22908

 SELECT CASE WHEN TypeCases=10 THEN AmountPayment-TotalPriceMU ELSE AmountPayment END 
			FROM dbo.vw_SUM23Order so WHERE so.rf_idCase=116702704

SELECT *
FROM dbo.t_SendingDataIntoFFOMS