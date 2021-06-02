USE AccountOMS
GO
declare @p1 XML,
		@idoc int

SELECT	@p1=HRM.ZL_LIST				
FROM	OPENROWSET(BULK 'D:\Test\protocol.xml',SINGLE_BLOB) HRM (ZL_LIST)

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

SELECT DISTINCT t.SL_ID
FROM #t t JOIN dbo.t_260order_ONK o ON
		t.SL_ID=o.GUID_Case

SELECT f.FileNameHR,f.DateRegistration,a.Account,a.ReportMonth,t.SL_ID,c.id,age,m.mes
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient		
					JOIN dbo.t_MES m ON
            c.id=m.rf_idCase
					JOIN dbo.t_260order_ONK o ON
            c.id=o.rf_idCase
					JOIN #t t ON
            t.SL_ID=o.GUID_Case
WHERE t.COMMENT LIKE 'CODE_SH обязателен для заполнения'

SELECT * FROM dbo.vw_LEK_PR260_ONK WHERE rf_idCase=126355364



GO
DROP TABLE #t