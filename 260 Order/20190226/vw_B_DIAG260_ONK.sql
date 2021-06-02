USE [AccountOMS]
GO

/****** Object:  View [dbo].[vw_B_DIAG260_ONK]    Script Date: 07.03.2019 11:21:51 ******/
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
WHERE DateDiagnostic>='20180901'			 

GO


