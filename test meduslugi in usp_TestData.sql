USE AccountOMS
GO
declare @account varchar(15)='34002-432-1s',
		@codeMO char(6)='161007',
		@month TINYINT=12,
		@year SMALLINT=2014

create table #case
(
	ID_Patient varchar(36) NOT NULL,
	id BIGINT,
	GUID_Case uniqueidentifier NOT NULL,
	rf_idV006 tinyint NULL,
	rf_idV008 smallint NULL,
	rf_idV014 TINYINT,
	rf_idV018 VARCHAR(9),
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
	Comments VARCHAR(250)
	
)
CREATE TABLE #tBirthWeight(	GUID_Case uniqueidentifier,VNOV_M smallint )
CREATE TABLE #tDisgnosis(GUID_Case uniqueidentifier,Code VARCHAR(10),TypeDiagnosis TINYINT )
if OBJECT_ID('tempDB..#case',N'U') is not null
begin
	exec usp_GetCaseFromRegisterCaseDB @account,@codeMO,@month,@year
END

CREATE TABLE #meduslugi 
		(
			GUID_Case uniqueidentifier NOT NULL,
			id int NOT NULL,
			GUID_MU uniqueidentifier NOT NULL,
			rf_idMO char(6) NOT NULL,
			rf_idV002 smallint NULL,
			rf_idV001 VARCHAR(15),
			IsChildTariff bit NOT NULL,
			DateHelpBegin date NOT NULL,
			DateHelpEnd date NOT NULL,
			DiagnosisCode char(10) NOT NULL,
			MUCode varchar(16) NOT NULL,
			Quantity decimal(6, 2) NOT NULL,
			Price decimal(15, 2) NOT NULL,
			TotalPrice decimal(15, 2) NOT NULL,
			rf_idV004 int NOT NULL,
			Comments VARCHAR(250)
		)		
EXEC usp_GetMeduslugiFromRegisterCaseDB @account

GO
DROP TABLE #case
DROP TABLE #meduslugi
DROP TABLE #tBirthWeight
DROP TABLE #tDisgnosis