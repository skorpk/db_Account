USE [AccountOMS]
GO

/****** Object:  View [dbo].[vw_GetLPUAccountMaximus]    Script Date: 19.01.2017 10:22:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER VIEW [dbo].[vw_GetLPUAccountMaximus]
AS
SELECT DISTINCT f.CodeM,l.NAMES,l.filialCode
FROM t_File f INNER JOIN dbo.t_RegistersAccounts a ON
		f.id=a.rf_idFiles
				INNER JOIN dbo.vw_sprT001 l ON
		f.CodeM=l.CodeM              
WHERE f.DateRegistration>='20161104' AND a.rf_idSMO='34006' AND NOT EXISTS(SELECT * FROM t_RefActOfSettledAccountBySMO WHERE rf_idAccounts=a.id)
UNION 
SELECT f.CodeM,l.NAMES,l.filialCode
FROM t_Act_Accounts_MEEAndEKMP f INNER JOIN dbo.vw_sprT001 l ON
			f.CodeM=l.CodeM    
WHERE NOT EXISTS(SELECT * FROM dbo.t_RefActOfSettledAccount_EKMP_MEE WHERE rf_idAccounts=f.rf_idAccount AND rf_idCase=f.rf_idCase AND rf_idAct_Accounts_MEEAndEKMP=f.id)			          


GO


