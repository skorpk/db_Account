USE AccountOMS
GO
declare @p1 XML,
		@idoc int

SELECT	@p1=HRM.ZL_LIST				
FROM	OPENROWSET(BULK 'c:\Test\CT34_19083.xml.xml',SINGLE_BLOB) HRM (ZL_LIST)

EXEC sp_xml_preparedocument @idoc OUTPUT, @p1

SELECT *
FROM OPENXML (@idoc, 'ZL_LIST/SCHET/ZAP',2)
	WITH(
			N_ZAP INT
		)
EXEC sp_xml_removedocument @idoc
GO
