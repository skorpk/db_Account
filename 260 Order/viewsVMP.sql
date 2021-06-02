USE AccountOMS
GO
if OBJECT_ID('vw_Account260_VMP',N'V') is not NULL
	DROP VIEW vw_Account260_VMP
GO
CREATE VIEW vw_Account260_VMP
AS
SELECT DISTINCT id,CODE,CODE_MO,[YEAR],[MONTH],Account AS NSCHET, DateRegister AS DSCHET,PLAT,SUMMAV
from dbo.t_260order_VMP
go
if OBJECT_ID('vw_ZAP260_VMP',N'V') is not NULL
	DROP VIEW vw_ZAP260_VMP
GO
CREATE VIEW vw_ZAP260_VMP
as
SELECT id AS idFile,rf_idRecordCasePatient,N_ZAP,IsNew AS PR_NOV from dbo.t_260order_VMP
go
if OBJECT_ID('vw_Pacient260_VMP',N'V') is not NULL
	DROP VIEW vw_Pacient260_VMP
GO
CREATE VIEW vw_Pacient260_VMP
AS
SELECT id AS idFile,rf_idRecordCasePatient,N_ZAP,ID_PAC,VPOLIS,SPOLIS,NPOLIS,rf_idSMO AS SMO,NOVOR from dbo.t_260order_VMP
go
if OBJECT_ID('vw_Z_SL260_VMP',N'V') is not NULL
	DROP VIEW vw_Z_SL260_VMP
GO
CREATE VIEW vw_Z_SL260_VMP
AS
SELECT id AS idFile,rf_idRecordCasePatient,N_ZAP, IDCASE,USL_OK,VIDPOM,FOR_POM,NPR_MO, dd.DirectionDate AS NPR_DATE,l.mcod AS LPU,DATE_Z_1,Date_Z_2,KD_Z,RSLT
		,ISHOD, IDSP,AmountPayment AS SUMV
from dbo.t_260order_VMP o INNER JOIN vw_sprT001 l ON
			o.LPU=l.CodeM
							LEFT JOIN dbo.t_DirectionDate dd ON
			o.rf_idCase = dd.rf_idCase

GO
if OBJECT_ID('vw_SL260_VMP',N'V') is not NULL
	DROP VIEW vw_SL260_VMP
GO
CREATE VIEW vw_SL260_VMP
AS
SELECT rf_idRecordCasePatient,rf_idCase,GUID_Case AS SL_ID,VID_HMP,METOD_HMP,PROFIL_K,rf_idV002 AS PROFIL,DET, TAL_D,TAL_NUM,TAL_P,NHISTORY,DATE_1,DATE_2,DS1
	,C_ZAB,DS_ONK, PRVS,VERS_SPEC,IDDOKT,Quantity AS ED_COL, TARIFF AS TARIF, SUM_M
from dbo.t_260order_VMP 
go
if OBJECT_ID('vw_Cons260_VMP',N'V') is not NULL
	DROP VIEW vw_Cons260_VMP
GO
CREATE VIEW vw_Cons260_VMP
AS
SELECT o.rf_idCase,PR_CONS,DateCons AS DT_CONS 
FROM dbo.t_260order_VMP o INNER JOIN dbo.t_Consultation c ON
			o.rf_idCase=c.rf_idCase
go
if OBJECT_ID('vw_ONK_SL260_VMP',N'V') is not NULL
	DROP VIEW vw_ONK_SL260_VMP
GO
CREATE VIEW vw_ONK_SL260_VMP
AS
SELECT s.id,s.rf_idCase, s.DS1_T,s.rf_idN002 AS STAD,s.rf_idN003 AS ONK_T, s.rf_idN004 AS ONK_N, s.rf_idN005 AS ONK_M, s.IsMetastasis AS MTSTZ, s.TotalDose AS SOD
		,s.K_FR,CAST(s.WEI AS DECIMAL(5,1)) AS WEI,s.HEI, s.BSA
FROM dbo.t_260order_VMP o INNER JOIN dbo.t_ONK_SL s	on
			o.rf_idCase=s.rf_idCase
go
if OBJECT_ID('vw_B_DIAG260_VMP',N'V') is not NULL
	DROP VIEW vw_B_DIAG260_VMP
GO
CREATE VIEW vw_B_DIAG260_VMP
AS
SELECT  rf_idONK_SL ,TypeDiagnostic AS DIAG_TIP,CodeDiagnostic AS DIAG_CODE,ResultDiagnostic AS DIAG_RSLT ,DateDiagnostic AS DIAG_DATE ,REC_RSLT 
FROM dbo.t_260order_VMP o INNER JOIN dbo.t_ONK_SL s	on
			o.rf_idCase=s.rf_idCase
						inner join dbo.t_DiagnosticBlock d ON
			s.id=d.rf_idONK_SL  
go
if OBJECT_ID('vw_B_PROT260_VMP',N'V') is not NULL
	DROP VIEW vw_B_PROT260_VMP
GO
CREATE VIEW vw_B_PROT260_VMP
AS
SELECT  rf_idONK_SL ,d.Code AS PROT,DateContraindications AS D_PROT 
FROM dbo.t_260order_VMP o INNER JOIN dbo.t_ONK_SL s	on
			o.rf_idCase=s.rf_idCase
						inner join t_Contraindications d ON
			s.id=d.rf_idONK_SL  
go
if OBJECT_ID('vw_ONK_USL260_VMP',N'V') is not NULL
	DROP VIEW vw_ONK_USL260_VMP
GO
CREATE VIEW vw_ONK_USL260_VMP
AS
SELECT  s.id AS rf_idONK_SL,rf_idN013 AS USL_TIP,TypeSurgery AS HIR_TIP,TypeDrug AS LEK_TIP_L,TypeCycleOfDrug AS LEK_TIP_V,TypeRadiationTherapy AS LUCH_TIP,PPTR 
FROM dbo.t_260order_VMP o INNER JOIN dbo.t_ONK_SL s	on
			o.rf_idCase=s.rf_idCase
						inner join dbo.t_ONK_USL u ON
		s.rf_idCase=u.rf_idCase 
go
if OBJECT_ID('vw_LEK_PR260_VMP',N'V') is not NULL
	DROP VIEW vw_LEK_PR260_VMP
GO
CREATE VIEW vw_LEK_PR260_VMP
AS		
SELECT  s.id AS rf_idONK_SL,o.rf_idCase ,d.rf_idN013 AS USL_TIP,rf_idV020 AS REGNUM,rf_idV024 AS CODE_SH,DateInjection AS DATE_INJ 
FROM dbo.t_260order_VMP o INNER JOIN dbo.t_ONK_SL s	on
			o.rf_idCase=s.rf_idCase
						INNER JOIN dbo.t_ONK_USL u ON
			s.rf_idCase=u.rf_idCase						                      
						inner join  dbo.t_DrugTherapy d ON
			u.rf_idCase=d.rf_idCase
			AND u.rf_idN013 = d.rf_idN013

go
if OBJECT_ID('vw_USL260_VMP',N'V') is not NULL
	DROP VIEW vw_USL260_VMP
GO
CREATE VIEW vw_USL260_VMP
AS
SELECT  o.rf_idCase ,m.id  AS IDSERV,l.mcod AS LPU,m.rf_idV002 AS PROFIL,MUSurgery AS VID_VME,m.IsChildTariff AS DET,DateHelpBegin AS DATE_IN,DateHelpEnd AS DATE_OUT,DiagnosisCode AS DS,
        MUSurgery AS CODE_USL,m.Quantity AS KOL_USL,Price AS TARIF,TotalPrice AS SUMV_USL,m.rf_idV004 AS PRVS,m.rf_idDoctor AS CODE_MD
FROM dbo.t_260order_VMP o INNER JOIN dbo.t_Meduslugi m ON
		o.rf_idCase=m.rf_idCase
							INNER JOIN dbo.vw_sprT001 l ON
		m.rf_idMO=l.CodeM 
WHERE m.MUSurgery IS NOT NULL		                         
GO
