USE AccountOMS
GO
alter PROCEDURE usp_InsertSendingInformationAboutFile
				 @nameFile varchar(20),
				 @reportMonth TINYINT,
				 @reportYear SMALLINT,
				 @code TINYINT
as                    
INSERT dbo.t_SendingFileToFFOMS( NameFile,ReportMonth,ReportYear,NumberOfEndFile ) 
VALUES(@nameFile+RIGHT('000'+CAST(@code AS varchar(3)),4),@reportMonth,@reportYear,@code)

go
alter PROCEDURE usp_GetXMLSendingDataToFFOMS
					@nameFile varchar(20),
					@reportMonth TINYINT,
					@reportYear SMALLINT,
					@code tinyint
as
--DECLARE @nameFile varchar(20)='TKR3416',
--		@reportMonth TINYINT=1,
--		@reportYear SMALLINT=2015,
--		@code TINYINT=1
DECLARE @code1 INT

SELECT @code1=MAX(id) FROM dbo.t_SendingFileToFFOMS WHERE ReportMonth=@reportMonth AND ReportYear=@reportYear AND NumberOfEndFile=@code
SELECT t.colXML from(
SELECT (
SELECT '2.0' AS 'VERSION', CAST(GETDATE() AS DATE) AS 'DATA',@nameFile+RIGHT('000'+CAST(@code AS varchar(3)),4) AS 'FILENAME' FOR XML PATH('ZGLV'),TYPE),
(SELECT @code AS 'CODE', @reportYear AS 'YEAR',@reportMonth AS 'MONTH' FOR XML PATH('SVD'),TYPE),
(SELECT id AS 'N_ZAP', rf_idF008 AS 'PACIENT/VPOLIS',SeriaPolis AS 'PACIENT/SPOLIS', RTRIM(NumberPolis) AS 'PACIENT/NPOLIS',rf_idV005 AS 'PACIENT/W', BirthDay AS 'PACIENT/DR',
		VZST AS 'PACIENT/VZST',id AS 'SLUCH/IDCASE',rf_idV014 AS 'SLUCH/FOR_POM',rf_idMO AS 'SLUCH/LPU',UnitOfHospital AS 'SLUCH/PODR',DateBegin AS 'SLUCH/DATE_1',
		DateEnd AS 'SLUCH/DATE_2',DS1 AS 'SLUCH/DS1',DS2 AS 'SLUCH/DS2',DS3 AS 'SLUCH/DS3', rf_idV009 AS 'SLUCH/RSLT',K_KSG AS 'SLUCH/K_KSG', KSG_PG AS 'SLUCH/KSG_PG',0 AS 'SLUCH/SL_K',
		AmountPayment AS 'SLUCH/SUM',PVT AS 'SLUCH/PVT',
		idMU AS 'SLUCH/USL/IDSERV',MUSurgery AS 'SLUCH/USL/Code_USL'
FROM dbo.t_SendingDataIntoFFOMS
WHERE ReportMonth=@reportMonth AND ReportYear=@reportYear AND IsFullDoubleDate=0
FOR XML PATh('ZAP'),TYPE,ROOT('PODR')
) 
FOR XML PATH(''),TYPE,ROOT('ISP_OB')
) t(colXML)
GO


