USE AccountOMS
GO
alter PROCEDURE usp_GetXMLSendingDataToFFOMSEKMP104
		@reportMonth TINYINT,
		@reportYear SMALLINT,
		@nameFile varchar(20)
AS
DECLARE @code1 INT

SET @code1=@reportMonth        

--SET @nameFile='MR3418'+ right('00000'+CAST(@reportMonth AS VARCHAR(2)),4)
SELECT t.colXML from(
SELECT (
SELECT '1.0' AS 'VERSION', CAST(GETDATE() AS DATE) AS 'DATA',@nameFile AS 'FILENAME' FOR XML PATH('ZGLV'),TYPE),
(SELECT @code1 AS 'CODE', @reportYear AS 'YEAR',@reportMonth AS 'MONTH' FOR XML PATH('SVD'),TYPE),
------------------------------------------------
(SELECT rf_idCase AS 'N_ZAP',  BirthDay AS 'PACIENT/DR',
		DateBegin AS 'SLUCH/DATE_1',RTRIM(DS1) AS 'SLUCH/DS1',rf_idV009 AS 'SLUCH/RSLT',GOSP_TYPE AS 'SLUCH/GOSP_TYPE',
		PVT AS 'SLUCH/PVT', AP_Type AS 'SLUCH/AP_TYPE'		
		,CASE WHEN IsEKMP=1 then RTRIM(Reason) ELSE NULL END AS 'EKMP/PROBLEM', CASE WHEN IsEKMP=1 then TypeExp ELSE NULL END  AS 'EKMP/TYPE'
		,CASE WHEN IsEKMP=0 THEN 1 ELSE NULL END AS 'NO_EKMP'
FROM dbo.t_OrderAdult_104_2018_EKMP s
WHERE ReportMonth=@reportMonth
FOR XML PATh('ZAP'),TYPE,ROOT('PODR')
) 
FOR XML PATH(''),TYPE,ROOT('MR_OB')
) t(colXML)
go