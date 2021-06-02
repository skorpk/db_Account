USE AccountOMS
GO
alter PROCEDURE usp_GetDataOrder260
			@reportYear SMALLINT,
			@reportMonth TINYINT
AS
SELECT [VERSION],DATA,FILENAME,COUNT(DISTINCT rf_idRecordCasePatient) AS SD_Z FROM dbo.t_260order WHERE [YEAR]=@reportYear AND [Month]=@reportMonth GROUP BY [VERSION],DATA,FILENAME
-----------Account--------------------
SELECT  id AS idFile ,CODE ,CODE_MO ,YEAR ,MONTH ,NSCHET ,DSCHET ,PLAT ,SUMMAV FROM dbo.vw_Account260 WHERE [YEAR]=@reportYear AND [Month]=@reportMonth
   --------------------ZAP---------------
SELECT id AS idFile,N_ZAP,CAST(IsNew AS TINYINT) AS PR_NOV from dbo.t_260order WHERE [YEAR]=@reportYear AND [Month]=@reportMonth ORDER BY id,N_ZAP
----------------------PACIENT-----------------
SELECT id AS idFile,rf_idRecordCasePatient,N_ZAP,ID_PAC,VPOLIS,SPOLIS,NPOLIS,rf_idSMO AS SMO,NOVOR from dbo.t_260order WHERE [YEAR]=@reportYear AND [Month]=@reportMonth ORDER BY id,N_ZAP
----------------------Z_SL--------------------
SELECT id AS idFile,rf_idRecordCasePatient,N_ZAP, IDCASE,USL_OK,VIDPOM,FOR_POM,NPR_MO, dd.DirectionDate AS NPR_DATE,LPU,DATE_Z_1,Date_Z_2,KD_Z,RSLT
		,ISHOD, IDSP,AmountPayment AS SUMV
from dbo.t_260order o LEFT JOIN dbo.t_DirectionDate dd ON
			o.rf_idCase = dd.rf_idCase
WHERE [YEAR]=@reportYear AND [Month]=@reportMonth
ORDER BY id,N_ZAP
---------------------SL---------------------
SELECT rf_idRecordCasePatient,rf_idCase,GUID_Case AS SL_ID,VID_HMP,METOD_HMP,PROFIL_K,rf_idV002 AS PROFIL,DET, TAL_D,TAL_NUM,TAL_P,NHISTORY,DATE_1,DATE_2,DS1
	,C_ZAB,DS_ONK, PRVS,VERS_SPEC,IDDOKT,Quantity AS ED_COL, TARIFF, SUM_M
from dbo.t_260order 
WHERE [YEAR]=@reportYear AND [Month]=@reportMonth
--------------------CONS-----------------
SELECT o.rf_idCase,PR_CONS,DateCons AS DT_CONS 
FROM dbo.t_260order o INNER JOIN dbo.t_Consultation c ON
			o.rf_idCase=c.rf_idCase
WHERE [YEAR]=@reportYear AND [Month]=@reportMonth
--------------------ONK_SL----------------
SELECT s.id,s.rf_idCase, s.DS1_T,s.rf_idN002 AS STAD,s.rf_idN003 AS ONK_T, s.rf_idN004 AS ONK_N, s.rf_idN005 AS ONK_M, s.IsMetastasis AS MTSTZ, s.TotalDose AS SOD
		,s.K_FR,s.WEI,s.HEI, s.BSA
FROM dbo.t_260order o INNER JOIN dbo.t_ONK_SL s	on
			o.rf_idCase=s.rf_idCase
WHERE [YEAR]=@reportYear AND [Month]=@reportMonth
-------------------B_DIAG----------------
SELECT  rf_idONK_SL ,TypeDiagnostic AS DIAG_TIP,CodeDiagnostic AS DIAG_CODE,ResultDiagnostic AS DIAG_RSLT ,DateDiagnostic AS DIAG_DATE ,REC_RSLT 
FROM dbo.t_260order o INNER JOIN dbo.t_ONK_SL s	on
			o.rf_idCase=s.rf_idCase
						inner join dbo.t_DiagnosticBlock d ON
			s.id=d.rf_idONK_SL                      
WHERE [YEAR]=@reportYear AND [Month]=@reportMonth
------------------B_PROT----------------
SELECT  rf_idONK_SL ,d.Code AS PROT,DateContraindications AS D_PROT 
FROM dbo.t_260order o INNER JOIN dbo.t_ONK_SL s	on
			o.rf_idCase=s.rf_idCase
						inner join t_Contraindications d ON
			s.id=d.rf_idONK_SL                      
WHERE [YEAR]=@reportYear AND [Month]=@reportMonth 
-----------------ONK_USL----------------
SELECT  s.id AS rf_idONK_SL,rf_idN013 AS USL_TIP,TypeSurgery AS HIR_TIP,TypeDrug AS LEK_TIP_L,TypeCycleOfDrug AS LEK_TIP_V,TypeRadiationTherapy AS LUCH_TIP,PPTR 
FROM dbo.t_260order o INNER JOIN dbo.t_ONK_SL s	on
			o.rf_idCase=s.rf_idCase
						inner join dbo.t_ONK_USL u ON
		s.rf_idCase=u.rf_idCase                     
WHERE [YEAR]=@reportYear AND [Month]=@reportMonth 
----------------LEK_PR-----------------
SELECT  s.id,o.rf_idCase ,d.rf_idN013 AS USL_TIP,rf_idV020 AS REGNUM,rf_idV024 AS CODE_SH,DateInjection AS DATE_INJ 
FROM dbo.t_260order o INNER JOIN dbo.t_ONK_SL s	on
			o.rf_idCase=s.rf_idCase
						INNER JOIN dbo.t_ONK_USL u ON
			s.rf_idCase=u.rf_idCase						                      
						inner join  dbo.t_DrugTherapy d ON
			u.rf_idCase=d.rf_idCase
			AND u.rf_idN013 = d.rf_idN013
WHERE [YEAR]=@reportYear AND [Month]=@reportMonth
--------------------USL------------------------
SELECT  o.rf_idCase ,m.id  AS IDSERV,m.rf_idMO AS LPU,m.rf_idV002 AS PROFIL,MUSurgery AS VID_VME,m.IsChildTariff AS DET,DateHelpBegin AS DATE_IN,DateHelpEnd AS DATE_OUT,DiagnosisCode AS DS,
        MUSurgery AS CODE_USL,m.Quantity AS KOL_USL,Price AS TARIF,TotalPrice AS SUM_USL,m.rf_idV004 AS PRVS,m.rf_idDoctor AS CODE_MD
FROM dbo.t_260order o INNER JOIN dbo.t_Meduslugi m ON
		o.rf_idCase=m.rf_idCase
WHERE [YEAR]=@reportYear AND [Month]=@reportMonth AND m.MUSurgery IS NOT NULL
go					                        