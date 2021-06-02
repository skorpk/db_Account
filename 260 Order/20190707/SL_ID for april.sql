USE AccountOMS
GO
declare @p1 XML,
		@idoc INT,
		@p2 XML,
		@idPac int

SELECT	@p1=HRM.ZL_LIST				
FROM	OPENROWSET(BULK 'd:\Test\CT34_19041.xml',SINGLE_BLOB) HRM (ZL_LIST)



EXEC sp_xml_preparedocument @idoc OUTPUT, @p1

SELECT *
INTO #t1
FROM OPENXML (@idoc, 'ZL_LIST/SCHET/ZAP/Z_SL/SL',2)
	WITH(
			SL_ID UNIQUEIDENTIFIER 
		)

EXEC sp_xml_removedocument @idoc


UPDATE o SET o.MONTH=4
FROM #t1 t INNER JOIN dbo.t_260order_ONK o ON
		t.SL_ID =o.GUID_Case
GO
DROP TABLE #t1
