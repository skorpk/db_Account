USE AccountOMS
GO

DECLARE @nameFile varchar(20)='TKR3418',
		@reportMonth TINYINT=1,
		@reportYear SMALLINT=2018,
		@code TINYINT=1
DECLARE @code1 INT

SELECT @code1=MAX(id) FROM dbo.t_SendingFileToFFOMS WHERE ReportMonth=@reportMonth AND ReportYear=@reportYear AND NumberOfEndFile=@code
SELECT t.colXML from(
SELECT (
SELECT '2.0' AS 'VERSION', CAST(GETDATE() AS DATE) AS 'DATA',@nameFile+RIGHT('000'+CAST(@code AS varchar(3)),4) AS 'FILENAME' FOR XML PATH('ZGLV'),TYPE),
(SELECT @code1 AS 'CODE', @reportYear AS 'YEAR',@reportMonth AS 'MONTH' FOR XML PATH('SVD'),TYPE),
(SELECT id AS 'N_ZAP', rf_idF008 AS 'PACIENT/VPOLIS',SeriaPolis AS 'PACIENT/SPOLIS', RTRIM(NumberPolis) AS 'PACIENT/NPOLIS',rf_idV005 AS 'PACIENT/W', BirthDay AS 'PACIENT/DR',
		VZST AS 'PACIENT/VZST',id AS 'SLUCH/IDCASE',rf_idV014 AS 'SLUCH/FOR_POM',rf_idMO AS 'SLUCH/LPU',UnitOfHospital AS 'SLUCH/PODR',DateBegin AS 'SLUCH/DATE_1',
		DateEnd AS 'SLUCH/DATE_2',RTRIM(DS1) AS 'SLUCH/DS1',RTRIM(DS2) AS 'SLUCH/DS2',RTRIM(DS3) AS 'SLUCH/DS3', rf_idV009 AS 'SLUCH/RSLT',K_KSG AS 'SLUCH/K_KSG', KSG_PG AS 'SLUCH/KSG_PG',SL_K AS 'SLUCH/SL_K',
		IT_SL AS 'SLUCH/IT_SL'
		,(SELECT IDSL AS 'IDSL',Coefficient AS 'Z_SL' FROM dbo.vw_Coefficient WHERE rf_idCase=s.rf_idCase FOR XML PATH('SL_KOEF'),TYPE) 'SLUCH'
		,CASE WHEN TypeCases=9 THEN AmountPayment ELSE NULL end AS 'SLUCH/SUM_KSG',
		CASE WHEN TypeCases=10 THEN AmountPayment ELSE NULL end AS 'SLUCH/SUM_DIAL',
		CASE WHEN TypeCases=9 THEN AmountPayment ELSE NULL  end AS 'SLUCH/SUM_IT',PVT AS 'SLUCH/PVT',
		idMU AS 'SLUCH/USL/IDSERV',MUSurgery AS 'SLUCH/USL/CODE_USL'
FROM dbo.t_SendingDataIntoFFOMS s
WHERE ReportMonth=@reportMonth AND ReportYear=@reportYear AND IsFullDoubleDate=0 AND IsUnload=0 AND rf_idCase=80576220
FOR XML PATh('ZAP'),TYPE,ROOT('PODR')
) 
FOR XML PATH(''),TYPE,ROOT('ISP_OB')
) t(colXML)