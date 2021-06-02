USE AccountOMS
GO
declare @p1 XML,
		@idoc int

SELECT	@p1=HRM.ZL_LIST				
FROM	OPENROWSET(BULK 'c:\Test\CT34_19083.xml',SINGLE_BLOB) HRM (ZL_LIST)

EXEC sp_xml_preparedocument @idoc OUTPUT, @p1

--SELECT COUNT(*)
--FROM OPENXML (@idoc, 'ZL_LIST/SCHET/ZAP',2)
--	WITH(
--			N_ZAP INT
--		)

SELECT *
FROM OPENXML (@idoc, 'ZL_LIST/SCHET/ZAP/Z_SL/SL/ONK_SL/ONK_USL',2)
	WITH(
			SL_ID UNIQUEIDENTIFIER '../../SL_ID',
			USL_TIP TINYINT,
			PPTR tinyint
		)
WHERE PPTR IS NOT NULL AND USL_TIP<>2


EXEC sp_xml_removedocument @idoc
GO
