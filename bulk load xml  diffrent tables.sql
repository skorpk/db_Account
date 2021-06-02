use AccountOMS
go
declare @doc xml,
		@patient XML
DECLARE @idoc INT
		
SELECT	@doc=HRM.ZL_LIST				
FROM	OPENROWSET(BULK 'c:\Test\HM155306S34001_1309004.XML',SINGLE_BLOB) HRM (ZL_LIST)

SELECT	@patient=LRM.PERS_LIST				
FROM	OPENROWSET(BULK 'c:\Test\LM155306S34001_1309004.xml',SINGLE_BLOB) LRM (PERS_LIST)

declare @t as table(rf_idFile int, IsError bit)
create table #t3 
(
	N_ZAP int,
	PR_NOV tinyint,
	ID_PAC nvarchar(36),
	VPOLIS tinyint,
	SPOLIS nchar(10),
	NPOLIS nchar(20),
	SMO nchar(5),
	SMO_OK nchar(5),
	NOVOR nchar(9),
	MO_PR nchar(6)
)


create table #t5 
(
	N_ZAP int,
	ID_PAC nvarchar(36),
	IDCASE int,
	ID_C uniqueidentifier,
	USL_OK tinyint,
	VIDPOM smallint,
	NPR_MO nvarchar(6),
	EXTR tinyint,
	LPU nvarchar(6),
	PROFIL smallint,
	DET tinyint,
	NHISTORY nvarchar(50),
	DATE_1 date,
	DATE_2 date,
	DS0 nvarchar(10),
	DS1 nvarchar(10),
	DS2 nvarchar(10),
	CODE_MES1 nvarchar(16),
	RSLT smallint,
	ISHOD smallint,
	PRVS bigint,
	OS_SLUCH tinyint,
	IDSP tinyint,
	ED_COL decimal(5, 2),
	TARIF decimal(15, 2),
	SUMV decimal(15, 2),
	--REFREASON tinyint, 
	SANK_MEK decimal(15, 2),
	SANK_MEE decimal(15, 2),
	SANK_EKMP decimal(15, 2),
	COMENTSL nvarchar(250),
	F_SP tinyint
)
					 
create table #t6
(
	IDCASE int,
	ID_C uniqueidentifier,
	IDSERV int,
	ID_U uniqueidentifier,
	LPU nvarchar(6),
	PROFIL smallint,
	DET tinyint,
	DATE_IN date,
	DATE_OUT date,
	DS nvarchar(10),
	CODE_USL nvarchar(16),
	KOL_USL decimal(6, 2),
	TARIF decimal(15, 2),
	SUMV_USL decimal(15, 2),
	PRVS bigint,
	COMENTU nvarchar(250),
	PODR int
)

SET STATISTICS TIME ON

EXEC sp_xml_preparedocument @idoc OUTPUT, @doc
insert #t3
SELECT N_ZAP,PR_NOV,ID_PAC,VPOLIS,SPOLIS,NPOLIS,SMO,SMO_OK,NOVOR,MO_PR
FROM OPENXML (@idoc, 'ZL_LIST/ZAP',2)
	WITH(
			N_ZAP int './N_ZAP',
			PR_NOV tinyint './PR_NOV',
			ID_PAC nvarchar(36)'./PACIENT/ID_PAC',
			VPOLIS tinyint './PACIENT/VPOLIS',
			SPOLIS nchar(10) './PACIENT/SPOLIS',
			NPOLIS nchar(20) './PACIENT/NPOLIS',
			SMO nchar(5) './PACIENT/SMO',
			SMO_OK nchar(5) './PACIENT/SMO_OK',
			NOVOR nchar(9) './PACIENT/NOVOR',
			MO_PR nchar(6) './PACIENT/MO_PR'
		)

insert #t5
SELECT N_ZAP,ID_PAC,IDCASE,ID_C,USL_OK,VIDPOM,NPR_MO,EXTR,LPU,PROFIL,DET,NHISTORY,replace(DATE_1,'-',''),replace(DATE_2,'-',''),DS0,DS1,DS2,CODE_MES1,RSLT,ISHOD,
		PRVS,OS_SLUCH,IDSP,ED_COL,TARIF,SUMV,SANK_MEK,SANK_MEE,SANK_EKMP,COMENTSL,F_SP
FROM OPENXML (@idoc, 'ZL_LIST/ZAP/SLUCH',3)
	WITH(	
			N_ZAP int '../N_ZAP',
			ID_PAC nvarchar(36) '../PACIENT/ID_PAC',
			IDCASE int ,
			ID_C uniqueidentifier,
			USL_OK tinyint ,
			VIDPOM smallint,
			NPR_MO nchar(6),
			EXTR tinyint ,
			LPU nchar(6) ,
			PROFIL smallint,
			DET tinyint ,
			NHISTORY nvarchar(50) ,
			DATE_1 nchar(10) ,
			DATE_2 nchar(10) ,
			DS0 nchar(10) ,
			DS1 nchar(10) ,
			DS2 nchar(10) ,
			CODE_MES1 nchar(16) ,			
			RSLT smallint ,
			ISHOD smallint,
			PRVS bigint ,
			OS_SLUCH tinyint ,
			IDSP TINYINT ,
			ED_COL DECIMAL(5,2) ,
			TARIF DECIMAL(15,2) ,	
			SUMV DECIMAL(15,2) ,	
			SANK_MEK DECIMAL(15,2),
			SANK_MEE DECIMAL(15,2),
			SANK_EKMP DECIMAL(15,2),
			COMENTSL NVARCHAR(250),
			F_SP TINYINT
		)

insert #t6
SELECT IDCASE,ID_C,IDSERV,ID_U,LPU,PROFIL,DET,replace(DATE_IN,'-',''),replace(DATE_OUT,'-',''),DS,CODE_USL,KOL_USL,TARIF,SUMV_USL,PRVS,COMENTU,PODR
FROM OPENXML (@idoc, 'ZL_LIST/ZAP/SLUCH/USL',3)
	WITH(
			IDCASE int '../IDCASE',
			ID_C uniqueidentifier '../ID_C',
			IDSERV INT ,
			ID_U uniqueidentifier ,
			LPU nchar(6) ,
			PROFIL smallint,
			DET tinyint ,
			DATE_IN nchar(10),
			DATE_OUT nchar(10),
			DS nchar(10),
			CODE_USL nchar(16),
			KOL_USL DECIMAL(6,2),
			TARIF DECIMAL(15,2) ,	
			SUMV_USL DECIMAL(15,2),	
			PRVS bigint ,
			COMENTU NVARCHAR(250),
			PODR int 
		)

EXEC sp_xml_removedocument @idoc

SET STATISTICS TIME OFF
drop table #t3
drop table #t5
drop table #t6