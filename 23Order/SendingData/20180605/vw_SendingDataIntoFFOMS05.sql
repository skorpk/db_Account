alter VIEW vw_SendingDataIntoFFOMS05
as
SELECT  DISTINCT rf_idCase, id, rf_idF008 ,SeriaPolis , RTRIM(NumberPolis) AS NumberPolis,rf_idV005 , BirthDay ,
		VZST ,rf_idV014,rf_idMO ,UnitOfHospital ,DateBegin ,
		DateEnd,RTRIM(DS1) AS DS1,RTRIM(DS2) AS DS2,RTRIM(DS3) AS DS3 , rf_idV009 ,K_KSG , KSG_PG 
		,DKK1 
		,DKK2 
		,UR_K 
		,SL_K  
		,IT_SL 	
		,TypeCases
		,AmountPayment,PVT, IsFullDoubleDate, IsUnload, ReportMonth,ReportYear 		
FROM dbo.t_SendingDataIntoFFOMS s
WHERE ReportMonth>4
GO
--SELECT * FROM vw_SendingDataIntoFFOMS05