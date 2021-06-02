USE [AccountOMS]
GO

/****** Object:  View [dbo].[vw_B_DIAG260_ONK]    Script Date: 11.10.2019 11:24:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




ALTER VIEW [dbo].[vw_B_DIAG260_ONK]
AS
SELECT  rf_idONK_SL ,TypeDiagnostic AS DIAG_TIP,CodeDiagnostic AS DIAG_CODE,ResultDiagnostic AS DIAG_RSLT ,DateDiagnostic AS DIAG_DATE ,REC_RSLT 
FROM dbo.t_260order_ONK o INNER JOIN dbo.t_ONK_SL s	on
			o.rf_idCase=s.rf_idCase
						inner join dbo.t_DiagnosticBlock d ON
			s.id=d.rf_idONK_SL 
WHERE DateDiagnostic>='20180901' AND NOT EXISTS(SELECT 1 FROM dbo.t_BadDiag260 WHERE s.id=rf_idONK_SL AND CodeDiagnostic=d.CodeDiagnostic)
--SELECT  rf_idONK_SL ,TypeDiagnostic AS DIAG_TIP,CASE WHEN n.ID_M_D IS NULL AND TypeDiagnostic=1 THEN null ELSE CodeDiagnostic end AS DIAG_CODE
--		,ResultDiagnostic AS DIAG_RSLT ,DateDiagnostic AS DIAG_DATE ,REC_RSLT 
--FROM dbo.t_260order_ONK o INNER JOIN dbo.t_ONK_SL s	on
--			o.rf_idCase=s.rf_idCase
--						inner join dbo.t_DiagnosticBlock d ON
--			s.id=d.rf_idONK_SL  
--						INNER JOIN dbo.vw_sprMKB10 m ON
--			o.DS1=m.DiagnosisCode
--						LEFT JOIN oms_nsi.dbo.sprN009 n on
--			m.MainDS=n.DS_Mrf			 
--WHERE DateDiagnostic>='20180901'



GO


