USE AccountOMS
GO
declare @p1 XML,
		@idoc int

SELECT	@p1=HRM.ZL_LIST				
FROM	OPENROWSET(BULK 'D:\Test\protocol2.xml',SINGLE_BLOB) HRM (ZL_LIST)

EXEC sp_xml_preparedocument @idoc OUTPUT, @p1

SELECT DISTINCT OSHIB, SL_ID,IM_POL,BAS_EL,N_ZAP,IDCASE,COMMENT
INTO #t
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

SELECT DISTINCT SL_ID ,o.rf_idCase,OSHIB
FROM #t t JOIN dbo.t_260order_ONK o ON
		t.SL_ID=o.GUID_Case


/*
BEGIN TRANSACTION
UPDATE oo SET oo.IsUnload=null
FROM dbo.t_260order_ONK oo
WHERE MONTH=2 AND NOT EXISTS(SELECT o.rf_idCase
							  FROM dbo.t_260order_ONK o JOIN #t t ON
							  		o.GUID_Case=t.SL_ID
							  WHERE t.IM_POL IN('CONS','ONK_SL','C_ZAB') AND o.rf_idCase=oo.rf_idCase
							  )

	SELECT o.*,t.*
	FROM dbo.t_260order_ONK o JOIN #t t ON
			o.GUID_Case=t.SL_ID
	WHERE t.IM_POL not IN('CONS','ONK_SL','C_ZAB')
commit

SELECT oo.ID_PAC
FROM dbo.t_260order_ONK oo
WHERE MONTH=2 AND EXISTS(SELECT o.rf_idCase
							  FROM dbo.t_260order_ONK o JOIN #t t ON
							  		o.GUID_Case=t.SL_ID
							  WHERE t.IM_POL IN('CONS','ONK_SL','C_ZAB') AND o.rf_idCase=oo.rf_idCase
							  )
GROUP BY oo.ID_PAC
HAVING COUNT(*)=1
*/
GO
DROP TABLE #t