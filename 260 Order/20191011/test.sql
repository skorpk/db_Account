USE AccountOMS
GO
SELECT *
FROM dbo.t_260order_ONK WHERE GUID_Case='91CB6DE3-5456-3C47-E053-02057DC10F18'

SELECT d.*
FROM dbo.t_ONK_SL s INNER JOIN dbo.t_DiagnosticBlock d ON
		s.id=d.rf_idONK_SL
WHERE s.rf_idCase=105667376 AND CodeDiagnostic=3


SELECT *
FROM t_DiagnosticBlock WHERE rf_idONK_SL=144601 AND CodeDiagnostic=3