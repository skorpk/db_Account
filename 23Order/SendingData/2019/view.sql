USE AccountOMSReports
GO
alter VIEW vw_Crit23Order
as
SELECT DISTINCT a.rf_idCase,a.rf_idAddCretiria
FROM dbo.t_SendingDataIntoFFOMS s INNER JOIN dbo.t_AdditionalCriterion a ON
			s.rf_idCase=a.rf_idCase
GO
alter VIEW vw_K_FR23Order
as
SELECT DISTINCT a.rf_idCase,a.K_FR
FROM dbo.t_SendingDataIntoFFOMS s INNER JOIN dbo.t_ONK_SL a ON
			s.rf_idCase=a.rf_idCase
WHERE a.K_FR IS NOT NULL
GO

ALTER VIEW [dbo].[vw_SendingDataIntoFFOMS]
AS
SELECT  DISTINCT 
        rf_idCase ,
        CodeM ,	--
        rf_idV006 ,	  --
        SeriaPolis ,--
        NumberPolis , --
        BirthDay ,	--
        rf_idV005 ,--
        DateBegin ,--
        DateEnd ,	 --
        DS1 ,     --   
        rf_idV009 ,	--
        MES ,  --
        AmountPayment ,  --      
        PVT ,--
        IsUnload , --
		IDSP,
        ENP	  --
FROM dbo.t_SendingDataIntoFFOMS
WHERE IsDisableCheck=0  AND IsFullDoubleDate=0
GO
ALTER VIEW [dbo].[vw_SendingDataIntoFFOMS05]
as
SELECT  DISTINCT rf_idCase, id, rf_idF008 ,SeriaPolis , RTRIM(NumberPolis) AS NumberPolis,rf_idV005 , BirthDay ,
		VZST ,rf_idV014,rf_idMO ,UnitOfHospital ,DateBegin ,
		DateEnd,RTRIM(DS1) AS DS1,RTRIM(DS2) AS DS2,RTRIM(DS3) AS DS3 , rf_idV009 ,K_KSG , KSG_PG 
		,UR_K 
		,SL_K  
		,IT_SL 	
		,TypeCases
		,AmountPayment,PVT, IsFullDoubleDate, IsUnload, ReportMonth,ReportYear,IDSP 		
FROM dbo.t_SendingDataIntoFFOMS s
GO
ALTER VIEW vw_SUM23Order
as
SELECT rf_idCase,TypeCases, AmountPayment,SUM(ISNULL(TotalPriceMU,0)) AS TotalPriceMU,IDSP
FROM dbo.t_SendingDataIntoFFOMS GROUP BY rf_idCase,TypeCases, AmountPayment,IDSP
go