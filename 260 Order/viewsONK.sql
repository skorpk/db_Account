USE AccountOMS
GO
if OBJECT_ID('vw_Account260_ONK',N'V') is not NULL
	DROP VIEW vw_Account260_ONK
GO
CREATE VIEW vw_Account260_ONK
AS
SELECT DISTINCT id,CODE,CODE_MO,[YEAR],[MONTH],Account AS NSCHET, DateRegister AS DSCHET,PLAT,SUMMAV
from dbo.t_260order_ONK
go
---------------------------------------------------------------------------------------------------
if OBJECT_ID('vw_ZAP260_ONK',N'V') is not NULL
	DROP VIEW vw_ZAP260_ONK
GO
CREATE VIEW vw_ZAP260_ONK
as
SELECT id AS idFile,rf_idRecordCasePatient,N_ZAP,IsNew AS PR_NOV from dbo.t_260order_ONK
go
---------------------------------------------------------------------------------------------------
if OBJECT_ID('vw_Pacient260_ONK',N'V') is not NULL
	DROP VIEW vw_Pacient260_ONK
GO
CREATE VIEW vw_Pacient260_ONK
AS
SELECT id AS idFile,rf_idRecordCasePatient,N_ZAP,ID_PAC,VPOLIS,SPOLIS,NPOLIS,rf_idSMO AS SMO,NOVOR from dbo.t_260order_ONK
go
---------------------------------------------------------------------------------------------------
if OBJECT_ID('vw_Z_SL260_ONK',N'V') is not NULL
	DROP VIEW vw_Z_SL260_ONK
GO
CREATE VIEW vw_Z_SL260_ONK
AS
SELECT o.id AS idFile,o.rf_idRecordCasePatient,N_ZAP, IDCASE,USL_OK,VIDPOM,FOR_POM,NPR_MO, dd.DirectionDate AS NPR_DATE,l.mcod AS LPU,DATE_Z_1,Date_Z_2,KD_Z,RSLT
		,ISHOD,cc.VB_P, IDSP,o.AmountPayment AS SUMV
from dbo.t_260order_ONK o INNER JOIN vw_sprT001 l ON
			o.LPU=l.CodeM
							INNER JOIN dbo.t_CompletedCase cc ON
			o.rf_idRecordCasePatient=cc.rf_idRecordCasePatient                          
							LEFT JOIN dbo.t_DirectionDate dd ON
			o.rf_idCase = dd.rf_idCase

GO
---------------------------------------------------------------------------------------------------
if OBJECT_ID('vw_SL260_ONK',N'V') is not NULL
	DROP VIEW vw_SL260_ONK
GO
CREATE VIEW vw_SL260_ONK
AS
SELECT c.rf_idRecordCasePatient,o.rf_idCase,c.GUID_Case AS SL_ID,c.rf_idSubMO AS LPU_1,c.rf_idDepartmentMO AS PODR,c.rf_idV002 AS PROFIL,PROFIL_K,DET,p.rf_idV025 AS P_CEL,
		NHISTORY,TypeTranslation AS P_PER,DATE_1,DATE_2,c.KD,DS1
		,o.C_ZAB,o.DS_ONK, p.DN, CASE WHEN c.rf_idV002=158 THEN 1 ELSE NULL END AS REAB
		,PRVS,VERS_SPEC,IDDOKT,Quantity AS ED_COL, SUM_M AS TARIF, SUM_M --для амбулаторки ставим сумму случая
from dbo.t_260order_ONK o INNER JOIN t_Case c ON
			o.rf_idCase=c.id
					LEFT JOIN dbo.t_PurposeOfVisit p ON
			c.id=p.rf_idCase                  
					LEFT JOIN dbo.t_DS_ONK_REAB rd ON
			c.id=rd.rf_idCase                  
WHERE c.DateEnd>='20190101'
go
---------------------------------------------------------------------------------------------------
if OBJECT_ID('vw_NAPR260_ONK',N'V') is not NULL
	DROP VIEW vw_NAPR260_ONK
GO
CREATE VIEW vw_NAPR260_ONK
AS
SELECT c.rf_idRecordCasePatient,o.rf_idCase, dm.DirectionDate AS NAPR_DATE, l.mcod AS NAPR_MO ,dm.TypeDirection AS NAPR_V, dm.MethodStudy AS MET_ISSL,dm.DirectionMU AS NAPR_USL        
from dbo.t_260order_ONK o INNER JOIN t_Case c ON
			o.rf_idCase=c.id
					INNER JOIN dbo.t_DirectionMU dm ON 
			c.id=dm.rf_idCase
					INNER JOIN dbo.vw_sprT001 l ON
			dm.DirectionMO=l.CodeM                  
WHERE c.DateEnd>='20190101'
go
---------------------------------------------------------------------------------------------------
if OBJECT_ID('vw_KSG_KPG260_ONK',N'V') is not NULL
	DROP VIEW vw_KSG_KPG260_ONK
GO
CREATE VIEW vw_KSG_KPG260_ONK
AS
SELECT c.rf_idRecordCasePatient,o.rf_idCase, nc.N_KSG,2019 AS VER_KSG, 0 AS KSG_PG,nc.KOEF_Z ,nc.KOEF_UP ,nc.BZTSZ ,1.00 AS KOEF_D,v.KOEF_U,
	   s.SL_K, c.IT_SL
from dbo.t_260order_ONK o INNER JOIN t_Case c ON
			o.rf_idCase=c.id						
					INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase
					INNER JOIN dbo.N_KSG_view nc ON
			m.MES=nc.N_KSG                  
					INNER JOIN dbo.t_SLK s ON
			c.id=s.rf_idCase                  
					INNER JOIN dbo.vw_sprT001 l ON
			c.rf_idMO=l.CodeM
					INNER JOIN dbo.V_KOEF_U v ON
			l.mcod=v.LPU
			AND ISNULL(c.rf_idSubMO,'99')=ISNULL(v.LPU_1,'99')                  
			AND ISNULL(c.rf_idDepartmentMO,'99')=ISNULL(v.PODR,'99')
			AND o.USL_OK=v.USL_OK
WHERE c.DateEnd>='20190101' AND o.Date_Z_2 BETWEEN nc.DATEBEG_KOEF_Z AND nc.DATEEND_KOEF_Z AND o.Date_Z_2 BETWEEN nc.DATEBEG_KOEF_UP AND nc.DATEEND_KOEF_UP
		AND o.Date_Z_2 BETWEEN nc.DATEBEG_BZTSZ AND nc.DATEEND_BZTSZ AND o.Date_Z_2 BETWEEN v.DATEBEG_KOEF_U AND v.DATEEND_KOEF_U
		AND o.Date_Z_2 between v.DATEBEG_LEVEL AND v.DATEEND_LEVEL AND o.Date_Z_2 between v.DATEBEG_KOEF_U AND v.DATEEND_KOEF_U
go
---------------------------------------------------------------------------------------------------
if OBJECT_ID('vw_CRIT260_ONK',N'V') is not NULL
	DROP VIEW vw_CRIT260_ONK
GO
CREATE VIEW vw_CRIT260_ONK
AS
SELECT o.rf_idCase,a.rf_idAddCretiria AS CRIT
from dbo.t_260order_ONK o INNER JOIN dbo.t_AdditionalCriterion a ON
			o.rf_idCase=a.rf_idCase          

go
---------------------------------------------------------------------------------------------------
if OBJECT_ID('vw_SL_KOEF260_ONK',N'V') is not NULL
	DROP VIEW vw_SL_KOEF260_ONK
GO
CREATE VIEW vw_SL_KOEF260_ONK
AS
SELECT o.rf_idCase,  cc.Code_SL AS IDSL,cc.Coefficient AS Z_SL
from dbo.t_260order_ONK o INNER JOIN dbo.t_Coefficient cc ON
                  o.rf_idCase=cc.rf_idCase  
go
---------------------------------------------------------------------------------------------------
if OBJECT_ID('vw_Cons260_ONK',N'V') is not NULL
	DROP VIEW vw_Cons260_ONK
GO
CREATE VIEW vw_Cons260_ONK
AS
SELECT o.rf_idCase,PR_CONS,DateCons AS DT_CONS 
FROM dbo.t_260order_ONK o INNER JOIN dbo.t_Consultation c ON
			o.rf_idCase=c.rf_idCase
go
---------------------------------------------------------------------------------------------------
if OBJECT_ID('vw_ONK_SL260_ONK',N'V') is not NULL
	DROP VIEW vw_ONK_SL260_ONK
GO
CREATE VIEW vw_ONK_SL260_ONK
AS
SELECT s.id,s.rf_idCase, s.DS1_T,s.rf_idN002 AS STAD,s.rf_idN003 AS ONK_T, s.rf_idN004 AS ONK_N, s.rf_idN005 AS ONK_M, s.IsMetastasis AS MTSTZ, s.TotalDose AS SOD
		,s.K_FR,CAST(s.WEI AS DECIMAL(5,1)) AS WEI,s.HEI, s.BSA
FROM dbo.t_260order_ONK o INNER JOIN dbo.t_ONK_SL s	on
			o.rf_idCase=s.rf_idCase
go
---------------------------------------------------------------------------------------------------
if OBJECT_ID('vw_B_DIAG260_ONK',N'V') is not NULL
	DROP VIEW vw_B_DIAG260_ONK
GO
CREATE VIEW vw_B_DIAG260_ONK
AS
SELECT  rf_idONK_SL ,TypeDiagnostic AS DIAG_TIP,CodeDiagnostic AS DIAG_CODE,ResultDiagnostic AS DIAG_RSLT ,DateDiagnostic AS DIAG_DATE ,REC_RSLT 
FROM dbo.t_260order_ONK o INNER JOIN dbo.t_ONK_SL s	on
			o.rf_idCase=s.rf_idCase
						inner join dbo.t_DiagnosticBlock d ON
			s.id=d.rf_idONK_SL  
go
---------------------------------------------------------------------------------------------------
if OBJECT_ID('vw_B_PROT260_ONK',N'V') is not NULL
	DROP VIEW vw_B_PROT260_ONK
GO
CREATE VIEW vw_B_PROT260_ONK
AS
SELECT  rf_idONK_SL ,d.Code AS PROT,DateContraindications AS D_PROT 
FROM dbo.t_260order_ONK o INNER JOIN dbo.t_ONK_SL s	on
			o.rf_idCase=s.rf_idCase
						inner join t_Contraindications d ON
			s.id=d.rf_idONK_SL  
go
---------------------------------------------------------------------------------------------------
if OBJECT_ID('vw_ONK_USL260_ONK',N'V') is not NULL
	DROP VIEW vw_ONK_USL260_ONK
GO
CREATE VIEW vw_ONK_USL260_ONK
AS
SELECT  s.id AS rf_idONK_SL,rf_idN013 AS USL_TIP,TypeSurgery AS HIR_TIP,TypeDrug AS LEK_TIP_L,TypeCycleOfDrug AS LEK_TIP_V,TypeRadiationTherapy AS LUCH_TIP,PPTR 
FROM dbo.t_260order_ONK o INNER JOIN dbo.t_ONK_SL s	on
			o.rf_idCase=s.rf_idCase
						inner join dbo.t_ONK_USL u ON
		s.rf_idCase=u.rf_idCase 
go
---------------------------------------------------------------------------------------------------
if OBJECT_ID('vw_LEK_PR260_ONK',N'V') is not NULL
	DROP VIEW vw_LEK_PR260_ONK
GO
CREATE VIEW vw_LEK_PR260_ONK
AS		
SELECT  s.id AS rf_idONK_SL,o.rf_idCase ,d.rf_idN013 AS USL_TIP,rf_idV020 AS REGNUM,rf_idV024 AS CODE_SH,DateInjection AS DATE_INJ 
FROM dbo.t_260order_ONK o INNER JOIN dbo.t_ONK_SL s	on
			o.rf_idCase=s.rf_idCase
						INNER JOIN dbo.t_ONK_USL u ON
			s.rf_idCase=u.rf_idCase						                      
						inner join  dbo.t_DrugTherapy d ON
			u.rf_idCase=d.rf_idCase
			AND u.rf_idN013 = d.rf_idN013

go
---------------------------------------------------------------------------------------------------
if OBJECT_ID('vw_USL260_ONK',N'V') is not NULL
	DROP VIEW vw_USL260_ONK
GO
CREATE VIEW vw_USL260_ONK
AS
SELECT  o.rf_idCase ,m.id  AS IDSERV,l.mcod AS LPU,m.rf_idSubMO AS LPU_1,m.rf_idDepartmentMO AS PODR,m.rf_idV002 AS PROFIL,MUSurgery AS VID_VME,m.IsChildTariff AS DET,DateHelpBegin AS DATE_IN,DateHelpEnd AS DATE_OUT,DiagnosisCode AS DS,
        MUSurgery AS CODE_USL,m.Quantity AS KOL_USL,Price AS TARIF,TotalPrice AS SUMV_USL,m.rf_idV004 AS PRVS,m.rf_idDoctor AS CODE_MD
FROM dbo.t_260order_ONK o INNER JOIN dbo.t_Meduslugi m ON
		o.rf_idCase=m.rf_idCase
							INNER JOIN dbo.vw_sprT001 l ON
		m.rf_idMO=l.CodeM 
WHERE m.MUSurgery IS NOT NULL		                         
GO
