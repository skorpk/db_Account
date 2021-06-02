USE AccountOMS
GO
declare @p1 XML,
		@idoc int

SELECT	@p1=HRM.ZL_LIST				
FROM	OPENROWSET(BULK 'D:\Test\protocol.xml',SINGLE_BLOB) HRM (ZL_LIST)

EXEC sp_xml_preparedocument @idoc OUTPUT, @p1

SELECT DISTINCT OSHIB, SL_ID,IM_POL,BAS_EL,N_ZAP,IDCASE,COMMENT
FROM OPENXML (@idoc, 'FLK_P/PR',2)
	WITH(
			OSHIB SMALLINT,
			SL_ID UNIQUEIDENTIFIER,
			IM_POL NVARCHAR(50),
			BAS_EL VARCHAR(20),
			N_ZAP INT,
			IDCASE INT	,
			COMMENT nvarchar(250)		
		)
ORDER BY OSHIB,N_ZAP



--SELECT DISTINCT SL_ID
--INTO #t
--FROM OPENXML (@idoc, 'FLK_P/PR',2)
--	WITH(
--			SL_ID UNIQUEIDENTIFIER,
--			IM_POL NVARCHAR(50),
--			N_ZAP INT,
--			IDCASE INT			
--		)
--WHERE IM_POL='IDDOKT'
--EXEC sp_xml_removedocument @idoc

--SELECT c.GUID_Case,m.MU
--FROM t_Case c INNER JOIN #t t ON
--		c.GUID_Case=t.SL_ID
--				INNER JOIN dbo.t_Meduslugi m ON
--        c.id=m.rf_idCase
--GO
--DROP TABLE #t