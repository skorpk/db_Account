USE AccountOMS
GO
declare @account varchar(15)='34002-3466-1A',
		@codeMO char(6)='184512',
		@month TINYINT=9,
		@year SMALLINT=2017
        
create table #case
(
	ID_Patient varchar(36) NOT NULL,
	id BIGINT,
	GUID_Case uniqueidentifier NOT NULL,
	rf_idV006 tinyint NULL,
	rf_idV008 smallint NULL,
	rf_idV014 TINYINT,
	rf_idV018 VARCHAR(19),
	rf_idV019 smallint,
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
	IDDOCT VARCHAR(25)		
)

CREATE TABLE #tBirthWeight(	GUID_Case uniqueidentifier,VNOV_M smallint )
CREATE TABLE #tDisgnosis(GUID_Case uniqueidentifier,Code VARCHAR(10),TypeDiagnosis TINYINT )

CREATE TABLE #tCoeff(GUID_Case uniqueidentifier, CODE_SL SMALLINT,VAL_C DECIMAL(3,2))
CREATE TABLE #tTalon(GUID_Case uniqueidentifier, Tal_D DATE, Tal_P date)


exec dbo.usp_GetCaseFromRegisterCaseDBFilesH @account,@codeMO,@month,@year

SELECT * FROM #case	 WHERE GUID_Case='812E776F-5914-4CA5-83B7-09549C0D39DA'
go
DROP TABLE #tBirthWeight
DROP TABLE #tDisgnosis
DROP TABLE #tCoeff
DROP TABLE #tTalon
DROP TABLE #case
