USE AccountOMS
GO
DECLARE @reportMonth TINYINT=4
SELECT o.rf_idCase,o.Account,o.LPU, c.idRecordCase,o.DATE_Z_1,o.Date_Z_2,o.GUID_Case
FROM dbo.t_260order_ONK o INNER JOIN dbo.t_ONK_SL s ON
			o.rf_idCase=s.rf_idCase 
							INNER JOIN dbo.t_Case c ON
			o.rf_idCase=c.id                          
WHERE [MONTH]=@reportMonth AND USL_OK <3 AND s.DS1_T<3
	AND NOT EXISTS(SELECT * FROM dbo.t_ONK_USL u WHERE u.rf_idCase=o.rf_idCase)