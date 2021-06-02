USE AccountOMS
GO
--SELECT  CodeM ,NAMES as LPU 
--FROM AccountOMS.dbo.vw_GetLPUAccountMaximus

ALTER VIEW [dbo].[vw_GetLPUAccountMaximusByReportPeriod]
AS
SELECT DISTINCT f.CodeM,YEAR(GETDATE()) AS ReportYear, MONTH(GETDATE()) AS ReportMonth
FROM t_File f INNER JOIN dbo.t_RegistersAccounts a ON
		f.id=a.rf_idFiles				
WHERE f.DateRegistration>='20161104' AND a.rf_idSMO='34006' AND NOT EXISTS(SELECT * FROM t_RefActOfSettledAccountBySMO WHERE rf_idAccounts=a.id)
UNION 
SELECT f.CodeM, YEAR(f.DateAct), MONTH(f.DateAct)
FROM t_Act_Accounts_MEEAndEKMP f 
WHERE NOT EXISTS(SELECT * FROM dbo.t_RefActOfSettledAccount_EKMP_MEE WHERE rf_idAccounts=f.rf_idAccount AND rf_idCase=f.rf_idCase AND rf_idAct_Accounts_MEEAndEKMP=f.id)			          

