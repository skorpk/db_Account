USE [AccountOMS]
GO
/****** Object:  StoredProcedure [dbo].[usp_GetXMLSendingDataToFFOMSEKMP104]    Script Date: 13.07.2018 7:49:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[usp_GetXMLSendingDataToFFOMSEKMP104]
		@reportMonth TINYINT,
		@reportYear SMALLINT,
		@nameFile varchar(20)
AS
DECLARE @code1 INT

SET @code1=@reportMonth        
IF @reportMonth<6 
begin
--SET @nameFile='MR3418'+ right('00000'+CAST(@reportMonth AS VARCHAR(2)),4)
SELECT t.colXML from(
SELECT (
SELECT '1.0' AS 'VERSION', CAST(GETDATE() AS DATE) AS 'DATA',@nameFile AS 'FILENAME' FOR XML PATH('ZGLV'),TYPE),
(SELECT @code1 AS 'CODE', @reportYear AS 'YEAR',@reportMonth AS 'MONTH' FOR XML PATH('SVD'),TYPE),
------------------------------------------------
(SELECT rf_idCase AS 'N_ZAP',  BirthDay AS 'PACIENT/DR',
		DateBegin AS 'SLUCH/DATE_1',RTRIM(DS1) AS 'SLUCH/DS1',rf_idV009 AS 'SLUCH/RSLT'
		,CASE WHEN  rf_idV014=3 THEN 0 WHEN rf_idV014=2 THEN 2 ELSE 1 END AS 'SLUCH/GOSP_TYPE',
		PVT AS 'SLUCH/PVT', AP_Type AS 'SLUCH/AP_TYPE'		
		,CASE WHEN IsEKMP=1 then RTRIM(Reason) ELSE NULL END AS 'EKMP/PROBLEM', CASE WHEN IsEKMP=1 then TypeExp ELSE NULL END  AS 'EKMP/TYPE'
		,CASE WHEN IsEKMP=1 and Reason is NULL THEN 1 ELSE null END AS 'EKMP/NO_PROBLEM'
		,CASE WHEN IsEKMP=0 THEN 1 ELSE NULL END AS 'NO_EKMP'
FROM dbo.vw_OrderAdult_104_2018_EKMP s
WHERE ReportMonth=@reportMonth
FOR XML PATh('ZAP'),TYPE,ROOT('PODR')
) 
FOR XML PATH(''),TYPE,ROOT('MR_OB')
) t(colXML)
END 
ELSE
BEGIN
	  SELECT t.colXML from(
	SELECT (
	SELECT '2.0' AS 'VERSION', CAST(GETDATE() AS DATE) AS 'DATA',@nameFile AS 'FILENAME' FOR XML PATH('ZGLV'),TYPE),
	(SELECT @code1 AS 'CODE', @reportYear AS 'YEAR',@reportMonth AS 'MONTH' FOR XML PATH('SVD'),TYPE),
	------------------------------------------------
	(SELECT  rf_idCase AS 'N_ZAP',  BirthDay AS 'PACIENT/DR',
			DateBegin AS 'SLUCH/DATE_1',RTRIM(DS1) AS 'SLUCH/DS1',s.rf_idV009 AS 'SLUCH/RSLT'
			,CASE WHEN  rf_idV006=1 THEN rf_idV014 ELSE null END AS 'SLUCH/FOR_POM'
			 ,AP_Type AS 'SLUCH/AP_TYPE'
			 ,1 AS 'NO_EKMP'					
	FROM dbo.t_OrderAdult_104_2018 s INNER JOIN (VALUES(105),(106),(205),(206),(313),(405),(406),(411)) v(rf_idV009) ON
			s.rf_idV009=v.rf_idV009
	WHERE ReportMonth=@reportMonth AND NOT EXISTS(SELECT * FROM dbo.t_OrderAdult_104_2018_EKMP_2 e WHERE s.rf_idCase=e.rf_idCase)
	FOR XML PATh('ZAP'),TYPE,ROOT('PODR')
	) 
	FOR XML PATH(''),TYPE,ROOT('MR_OB')
	) t(colXML)

END