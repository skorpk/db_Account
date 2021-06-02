USE AccountOMS
GO
declare @p1 XML,
		@idoc int

SELECT	@p1=HRM.ZL_LIST				
FROM	OPENROWSET(BULK 'c:\Test\protocol.xml',SINGLE_BLOB) HRM (ZL_LIST)

EXEC sp_xml_preparedocument @idoc OUTPUT, @p1

SELECT distinct *
FROM OPENXML (@idoc, 'FLK_P/PR',2)
	WITH(
			SL_ID UNIQUEIDENTIFIER,
			IM_POL NVARCHAR(50),
			N_ZAP INT,
			IDCASE INT			
		)
WHERE IM_POL IN('DT_CONS','STAD','KSG_KPG')


EXEC sp_xml_removedocument @idoc
GO
