USE AccountOMS
GO
declare @p1 XML,
		@idoc int

SELECT	@p1=HRM.ZL_LIST				
FROM	OPENROWSET(BULK 'd:\Test\CT34_20041.xml',SINGLE_BLOB) HRM (ZL_LIST)

EXEC sp_xml_preparedocument @idoc OUTPUT, @p1
--поиск записей по VB_P

SELECT *
FROM OPENXML (@idoc, 'ZL_LIST/SCHET/ZAP/Z_SL/SL',2)
	WITH(
			SL_ID UNIQUEIDENTIFIER,
			N_ZAP INT '../../N_ZAP',
			IDCASE INT '../IDCASE',
			VB_P TINYINT '../VB_P',
			IDSP TINYINT '../IDSP',
			P_PER TINYINT
		)
WHERE N_ZAP=2 AND IDCASE=2 AND (IDSP=33 or P_PER=4) AND VB_P IS NOT NULL


EXEC sp_xml_removedocument @idoc
GO