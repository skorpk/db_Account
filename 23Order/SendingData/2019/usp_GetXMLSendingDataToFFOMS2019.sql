USE [AccountOMSReports]
GO
/****** Object:  StoredProcedure [dbo].[usp_GetXMLSendingDataToFFOMS2019]    Script Date: 11.02.2019 15:37:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[usp_GetXMLSendingDataToFFOMS2019]
					@nameFile varchar(20),
					@reportMonth TINYINT,
					@reportYear SMALLINT,
					@code tinyint
as

DECLARE @code1 INT

SELECT @code1=MAX(id) FROM dbo.t_SendingFileToFFOMS WHERE ReportMonth=@reportMonth AND ReportYear=@reportYear AND NumberOfEndFile=@code

SELECT t.colXML from(
SELECT (
SELECT '2.0' AS 'VERSION', CAST(GETDATE() AS DATE) AS 'DATA',@nameFile+RIGHT('000'+CAST(@code AS varchar(3)),4) AS 'FILENAME' FOR XML PATH('ZGLV'),TYPE),
(SELECT @code1 AS 'CODE', @reportYear AS 'YEAR',@reportMonth AS 'MONTH' FOR XML PATH('SVD'),TYPE),
(SELECT id AS 'N_ZAP', rf_idF008 AS 'PACIENT/VPOLIS',SeriaPolis AS 'PACIENT/SPOLIS', RTRIM(NumberPolis) AS 'PACIENT/NPOLIS',rf_idV005 AS 'PACIENT/W', BirthDay AS 'PACIENT/DR',
		VZST AS 'PACIENT/VZST',id AS 'SLUCH/IDCASE',rf_idV014 AS 'SLUCH/FOR_POM',rf_idMO AS 'SLUCH/LPU',UnitOfHospital AS 'SLUCH/PODR',DateBegin AS 'SLUCH/DATE_1',
		DateEnd AS 'SLUCH/DATE_2',RTRIM(DS1) AS 'SLUCH/DS1',RTRIM(DS2) AS 'SLUCH/DS2',RTRIM(DS3) AS 'SLUCH/DS3', rf_idV009 AS 'SLUCH/RSLT',K_KSG AS 'SLUCH/K_KSG', KSG_PG AS 'SLUCH/KSG_PG'
		--CRIT
		,(SELECT rf_idAddCretiria AS CRIT FROM dbo.vw_Crit23Order o WHERE o.rf_idCase=s.rf_idCase FOR XML PATH(''),TYPE)'SLUCH'	
		---09.02.2018 add a new tag K_FR
		,(SELECT K_FR FROM dbo.vw_K_FR23Order o WHERE o.rf_idCase=s.rf_idCase FOR XML PATH(''),TYPE)'SLUCH'		
		,UR_K AS 'SLUCH/UR_K'
		,SL_K AS 'SLUCH/SL_K',
		IT_SL AS 'SLUCH/IT_SL'
		,(SELECT IDSL AS 'IDSL',Coefficient AS 'Z_SL' FROM dbo.vw_Coefficient cc WHERE cc.id=s.rf_idCase FOR XML PATH('SL_KOEF'),TYPE) 'SLUCH'
		--CASE WHEN IDSP IN(33,43) THEN AmountPayment ELSE NULL end 		
		,(SELECT CASE WHEN TypeCases=10 THEN AmountPayment-TotalPriceMU ELSE AmountPayment END 
			FROM dbo.vw_SUM23Order so WHERE so.rf_idCase=s.rf_idCase FOR XML PATH('SUM_KSG'),Type 
		  ) 'SLUCH'
		 --CASE WHEN IDSP IN(4,28) THEN AmountPayment ELSE NULL end AS 'SLUCH/SUM_DIAL',
		,(
			SELECT TotalPriceMU AS SUM_DIAL FROM dbo.vw_SUM23Order so WHERE so.rf_idCase=s.rf_idCase AND so.TypeCases=10 FOR XML PATH(''),Type 
		  ) 'SLUCH',
		AmountPayment AS 'SLUCH/SUM_IT',PVT AS 'SLUCH/PVT'
		,(select idMU AS 'IDSERV', MUSurgery AS 'CODE_USL',Quantity AS 'KOL_USL',TotalPriceMU AS 'SUM_USL' 
		  FROM dbo.t_SendingDataIntoFFOMS WHERE rf_idCase=s.rf_idCase AND idMU IS NOT NULL FOR XML PATH ('USL'), TYPE ) 'SLUCH'
FROM dbo.vw_SendingDataIntoFFOMS05 s
WHERE ReportMonth=@reportMonth AND ReportYear=@reportYear AND IsFullDoubleDate=0 AND IsUnload=0
FOR XML PATh('ZAP'),TYPE,ROOT('PODR')
) 
FOR XML PATH(''),TYPE,ROOT('ISP_OB')
) t(colXML)

--IF ORIGINAL_LOGIN()<>'vtfoms\skrainov'
--begin
	UPDATE t_SendingDataIntoFFOMS SET IsUnload=1 WHERE ReportMonth=@reportMonth AND ReportYear=@reportYear AND IsFullDoubleDate=0 AND IsUnload=0
--end
