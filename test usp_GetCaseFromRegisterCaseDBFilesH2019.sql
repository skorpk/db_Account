USE AccountOMS
GO
declare @account varchar(15)='34007-1215-0A',
		@codeMO char(6)='145516',
		@month TINYINT=11,
		@year SMALLINT=2018
        
create table #case
(
	ID_Patient varchar(36) NOT NULL,
	id BIGINT,
	GUID_Case uniqueidentifier NOT NULL,
	rf_idV006 tinyint NULL,
	rf_idV008 smallint NULL,
	rf_idV014 TINYINT,
	rf_idV018 VARCHAR(19),
	rf_idV019 int,
	rf_idDirectMO char(6) NULL,
	HopitalisationType tinyint NULL,
	rf_idMO char(6) NOT NULL,
	rf_idV002 smallint NOT NULL,
	IsChildTariff bit NOT NULL,
	NumberHistoryCase nvarchar(50) NOT NULL,
	DateBegin date NOT NULL,
	DateEnd date NOT NULL,
	DS0 char(10) NULL,
	DS1 char(10) NULL,
	DS2 char(10) NULL,
	MES char(16) NULL,
	rf_idV009 smallint NOT NULL,
	rf_idV012 smallint NOT NULL,
	rf_idV004 int NOT NULL,
	IsSpecialCase tinyint NULL,
	rf_idV010 tinyint NOT NULL,
	Quantity decimal(5, 2) NULL,
	Tariff decimal(15, 2) NULL,
	AmountPayment decimal(15, 2) NOT NULL,
	SANK_MEK decimal(15, 2) NULL,
	SANK_MEE decimal(15, 2) NULL,
	SANK_EKMP decimal(15, 2) NULL,
	[Emergency] tinyint NULL,
	Comments VARCHAR(250),
	IT_SL DECIMAL(3,2),
	P_PER TINYINT,
	IDDOCT VARCHAR(25),
	rf_idSubMO VARCHAR(8),
	rf_idDepartmentMO INT,
	DS_ONK	TINYINT,
	MSE TINYINT,
	C_ZAB TINYINT
)
--временные таблицы для сведений из реестра сведений
CREATE TABLE #tBirthWeight(	GUID_Case uniqueidentifier,VNOV_M smallint )
CREATE TABLE #tDisgnosis(GUID_Case uniqueidentifier,Code VARCHAR(10),TypeDiagnosis TINYINT )

CREATE TABLE #tCoeff_0(GUID_Case uniqueidentifier, CODE_SL SMALLINT,VAL_C DECIMAL(3,2))
CREATE TABLE #tTalon(GUID_Case uniqueidentifier, Tal_D DATE, Tal_P DATE,NumberOfTicket VARCHAR(20))
CREATE TABLE #tmpKiro(GUID_Case UNIQUEIDENTIFIER,CODE_KIRO INT, VAL_K DECIMAL(3,2))
CREATE TABLE #tmpAddCriterion(GUID_Case UNIQUEIDENTIFIER,ADD_CRITERION VARCHAR(20))
CREATE TABLE #tmpNEXT(GUID_Case UNIQUEIDENTIFIER,NEXT_VISIT DATE)

-------------------18.04.2018-------------------
CREATE TABLE #tDirectionDate(GUID_Case UNIQUEIDENTIFIER,NPR_Date DATE)
CREATE TABLE #tProfileOfBed(GUID_Case UNIQUEIDENTIFIER,PROFIL_K smallint)
CREATE TABLE #tPurposeOfVisit(GUID_Case UNIQUEIDENTIFIER,P_CEL VARCHAR(3),DN TINYINT)--DN может быть пустой
CREATE TABLE #tCombinationOfSchema(GUID_CASE UNIQUEIDENTIFIER,DKK2 VARCHAR(10))
-------------------20.07.2018------------------
CREATE TABLE #ONK_SL_RC
					(							
						GUID_Case UNIQUEIDENTIFIER,
						DS1_T TINYINT,
						STAD SMALLINT, --обязательные к заполнению
						ONK_T SMALLINT,--обязательные к заполнению
						ONK_N SMALLINT,--обязательные к заполнению
						ONK_M SMALLINT,--обязательные к заполнению
						MTSTZ TINYINT,
						SOD DECIMAL(5,2),
						PR_CONS TINYINT,
						DT_CONS date						
						 )
CREATE TABLE #B_DIAG_RC(GUID_Case UNIQUEIDENTIFIER,DIAG_TIP TINYINT,DIAG_CODE SMALLINT, DIAG_RSLT SMALLINT, DIAG_DATE date)
CREATE TABLE #B_PROT_RC(GUID_Case UNIQUEIDENTIFIER,PROT TINYINT,D_PROT DATE)

--16.07.2018
create table #NAPR_RC(GUID_Case uniqueidentifier,NAPR_DATE DATE,NAPR_V TINYINT,MET_ISSL TINYINT,NAPR_USL VARCHAR(15))

create table #ONK_USL_RC
	(
		GUID_Case uniqueidentifier,
		ID_U UNIQUEIDENTIFIER,		
		USL_TIP TINYINT, 
		HIR_TIP TINYINT, 
		LEK_TIP_L TINYINT,
		LEK_TIP_V TINYINT,
		LUCH_TIP TINYINT
   )      
 					   

if OBJECT_ID('tempDB..#case',N'U') is not null
begin
	exec dbo.usp_GetCaseFromRegisterCaseDBFilesH2019 @account,@codeMO,@month,@year
end
go
if OBJECT_ID('tempDB..#case',N'U') is not null
	DROP TABLE #case
if OBJECT_ID('tempDB..#t5',N'U') is not NULL
	 DROP TABLE #t5
if OBJECT_ID('tempDB..#t8',N'U') is not NULL
	drop table #t8
if OBJECT_ID('tempDB..#t3',N'U') is not NULL
	drop table #t3
if OBJECT_ID('tempDB..#iTableMes',N'U') is not NULL
	DROP TABLE #iTableMes
if OBJECT_ID('tempDB..#CONS',N'U') is not NULL
	DROP TABLE #CONS
if OBJECT_ID('tempDB..#LEK_PR',N'U') is not NULL
DROP TABLE #LEK_PR
if OBJECT_ID('tempDB..#t6',N'U') is not NULL
	DROP TABLE #t6
if OBJECT_ID('tempDB..#tBW',N'U') is not NULL
	DROP TABLE #tBW
if OBJECT_ID('tempDB..#tDS',N'U') is not NULL
	DROP TABLE #tDS
if OBJECT_ID('tempDB..#tCoeff',N'U') is not NULL
	DROP TABLE #tCoeff
if OBJECT_ID('tempDB..#tKiro',N'U') is not NULL
	DROP TABLE #tKiro
if OBJECT_ID('tempDB..#B_DIAG',N'U') is not NULL
	DROP TABLE #B_DIAG
if OBJECT_ID('tempDB..#B_PROT',N'U') is not NULL
	DROP TABLE #B_PROT
if OBJECT_ID('tempDB..#NAPR',N'U') is not NULL
	DROP TABLE #NAPR
if OBJECT_ID('tempDB..#ONK_USL',N'U') is not NULL
	DROP TABLE #ONK_USL
if OBJECT_ID('tempDB..#tDost',N'U') is not NULL
	DROP TABLE #tDost
if OBJECT_ID('tempDB..#tDisabiliti',N'U') is not NULL
	DROP TABLE #tDisabiliti
if OBJECT_ID('tempDB..#ONK_SL',N'U') is not NULL
	DROP TABLE #ONK_SL
if OBJECT_ID('tempDB..#KSG_KPG',N'U') is not NULL
	DROP TABLE #KSG_KPG
if OBJECT_ID('tempDB..#tBirthWeight',N'U') is not NULL
	DROP TABLE #tBirthWeight
if OBJECT_ID('tempDB..#tDisgnosis',N'U') is not NULL
	DROP TABLE #tDisgnosis
if OBJECT_ID('tempDB..#tCoeff_0',N'U') is not NULL
	DROP TABLE #tCoeff_0
if OBJECT_ID('tempDB..#tTalon',N'U') is not NULL
	DROP TABLE #tTalon
if OBJECT_ID('tempDB..#tmpKiro',N'U') is not NULL
	DROP TABLE #tmpKiro
if OBJECT_ID('tempDB..#tmpAddCriterion',N'U') is not NULL
	DROP TABLE #tmpAddCriterion
if OBJECT_ID('tempDB..#tmpNEXT',N'U') is not NULL
	DROP TABLE #tmpNEXT	 
if OBJECT_ID('tempDB..#tDirectionDate',N'U') is not NULL
	DROP TABLE #tDirectionDate
if OBJECT_ID('tempDB..#tProfileOfBed',N'U') is not NULL
	DROP TABLE #tProfileOfBed
if OBJECT_ID('tempDB..#tPurposeOfVisit',N'U') is not NULL
	DROP TABLE #tPurposeOfVisit
if OBJECT_ID('tempDB..#tCombinationOfSchema',N'U') is not NULL
	DROP TABLE #tCombinationOfSchema
if OBJECT_ID('tempDB..#ONK_SL_RC',N'U') is not NULL
	DROP TABLE #ONK_SL_RC
if OBJECT_ID('tempDB..#B_DIAG_RC',N'U') is not NULL
	DROP TABLE #B_DIAG_RC 
if OBJECT_ID('tempDB..#B_PROT_RC',N'U') is not NULL
	DROP TABLE #B_PROT_RC 
if OBJECT_ID('tempDB..#NAPR_RC',N'U') is not NULL
	DROP TABLE #NAPR_RC
if OBJECT_ID('tempDB..#ONK_USL_RC',N'U') is not NULL
	DROP TABLE #ONK_USL_RC
GO
