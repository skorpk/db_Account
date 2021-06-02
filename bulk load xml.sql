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
CREATE TABLE #t
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
	MO_PR nchar(6),
	-----case---
	IDCASE int,
	ID_C uniqueidentifier,
	USL_OK tinyint,
	VIDPOM smallint,
	NPR_MO nvarchar(6),
	EXTR tinyint,
	LPU_C nvarchar(6),
	PROFIL_C smallint,
	DET_C tinyint,
	NHISTORY nvarchar(50),
	DATE_1 date,
	DATE_2 date,
	DS0 nvarchar(10),
	DS1 nvarchar(10),
	DS2 nvarchar(10),
	CODE_MES1 nvarchar(16),
	RSLT smallint,
	ISHOD smallint,
	PRVS_c bigint,
	OS_SLUCH tinyint,
	IDSP tinyint,
	ED_COL decimal(5, 2),
	TARIF_C decimal(15, 2),
	SUMV decimal(15, 2),
	--REFREASON tinyint, 
	SANK_MEK decimal(15, 2),
	SANK_MEE decimal(15, 2),
	SANK_EKMP decimal(15, 2),
	COMENTSL nvarchar(250),
	F_SP TINYINT,
	----USL----
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

INSERT #t( N_ZAP , PR_NOV , ID_PAC , VPOLIS , SPOLIS , NPOLIS , SMO , SMO_OK , NOVOR , MO_PR 
		 , IDCASE , ID_C , USL_OK , VIDPOM , NPR_MO , EXTR , LPU_C , PROFIL_C , DET_C , NHISTORY , DATE_1 , DATE_2 , DS0 , DS1 , DS2 , CODE_MES1 , RSLT , ISHOD 
		, PRVS_c , OS_SLUCH , IDSP , ED_COL , TARIF_C , SUMV , SANK_MEK , SANK_MEE , SANK_EKMP , COMENTSL , F_SP 
		 , IDSERV , ID_U , LPU , PROFIL , DET , DATE_IN , DATE_OUT , DS , CODE_USL , KOL_USL , TARIF , SUMV_USL , PRVS , COMENTU , PODR
		)
SELECT N_ZAP,PR_NOV,ID_PAC,VPOLIS,SPOLIS,NPOLIS,SMO,SMO_OK,NOVOR,MO_PR
		--case
		,IDCASE,ID_C,USL_OK,VIDPOM,NPR_MO,EXTR,LPU_C,PROFIL_C,DET_C,NHISTORY,replace(DATE_1,'-',''),replace(DATE_2,'-','')
		,DS0,DS1,DS2,CODE_MES1,RSLT,ISHOD,PRVS_C,OS_SLUCH,IDSP,ED_COL,TARIF_C,SUMV,SANK_MEK,SANK_MEE,SANK_EKMP,COMENTSL,F_SP
		--usl
		,IDSERV,ID_U,LPU,PROFIL,DET,replace(DATE_IN,'-',''),replace(DATE_OUT,'-',''),DS,CODE_USL,KOL_USL,TARIF,SUMV_USL,PRVS,COMENTU,PODR
FROM OPENXML (@idoc, 'ZL_LIST/ZAP/SLUCH/USL',3)
	WITH(
			N_ZAP int '../../N_ZAP',
			-------------------------------------
			PR_NOV tinyint '../../PR_NOV',
			ID_PAC nvarchar(36)'../../PACIENT/ID_PAC',
			VPOLIS tinyint '../../PACIENT/VPOLIS',
			SPOLIS nchar(10) '../../PACIENT/SPOLIS',
			NPOLIS nchar(20) '../../PACIENT/NPOLIS',
			SMO nchar(5) '../../PACIENT/SMO',
			SMO_OK nchar(5) '../../PACIENT/SMO_OK',
			NOVOR nchar(9) '../../PACIENT/NOVOR',
			MO_PR nchar(6) '../../PACIENT/MO_PR',
			-------------------------------------			
			IDCASE int '../IDCASE',
			ID_C uniqueidentifier '../ID_C',			
			USL_OK tinyint '../US_OK',
			VIDPOM SMALLINT '../VIDPOM',
			NPR_MO nchar(6) '../NPR_MO',
			EXTR tinyint '../EXTR',
			LPU_C nchar(6) '../LPU',
			PROFIL_C SMALLINT '../PROFIL',
			DET_C tinyint '../DET',
			NHISTORY nvarchar(50) '../NHISTORY',
			DATE_1 nchar(10) '../DATE_1',
			DATE_2 nchar(10) '../DATE_2',
			DS0 nchar(10) '../DS0',
			DS1 nchar(10) '../DS1',
			DS2 nchar(10) '../DS2',
			CODE_MES1 nchar(16) '../CODE_MES1',			
			RSLT smallint '../RSLT',
			ISHOD SMALLINT '../ISHOD',
			PRVS_C bigint '../PRVS',
			OS_SLUCH tinyint '../OS_SLUCH',
			IDSP TINYINT '../IDSP',
			ED_COL DECIMAL(5,2) '../ED_COL',
			TARIF_C DECIMAL(15,2) '../TARIF',	
			SUMV DECIMAL(15,2) '../SUMV',	
			SANK_MEK DECIMAL(15,2) '../SANK_MEK',
			SANK_MEE DECIMAL(15,2) '../SANK_MEE',
			SANK_EKMP DECIMAL(15,2) '../SANK_EKMP',
			COMENTSL NVARCHAR(250) '../COMENTSL',
			F_SP TINYINT '../F_SP',
			--------------------------------------
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
DROP TABLE #t