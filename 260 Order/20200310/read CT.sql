USE AccountOMS
GO
declare @p1 XML,
		@idoc int

SELECT	@p1=HRM.ZL_LIST				
FROM	OPENROWSET(BULK 'd:\Test\CT34_20021.xml',SINGLE_BLOB) HRM (ZL_LIST)

EXEC sp_xml_preparedocument @idoc OUTPUT, @p1

--SELECT COUNT(*)
--FROM OPENXML (@idoc, 'ZL_LIST/SCHET/ZAP',2)
--	WITH(
--			N_ZAP INT
--		)

SELECT *
FROM OPENXML (@idoc, 'ZL_LIST/SCHET/ZAP/Z_SL/SL',2)
	WITH(
			SL_ID UNIQUEIDENTIFIER,
			N_ZAP INT '../../N_ZAP',
			NPR_DATE DATE '../NPR_DATE',
			NPR_MO nchar(6) '../NPR_MO'
		)
WHERE N_ZAP=11 AND NPR_DATE IS NOT NULL AND NPR_MO IS null


EXEC sp_xml_removedocument @idoc
GO