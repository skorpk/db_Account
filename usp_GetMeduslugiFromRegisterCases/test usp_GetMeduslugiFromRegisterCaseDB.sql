USE AccountOMS
go
SET NOCOUNT ON
DECLARE @account varchar(15)='34001-13050-1A',
		@codeMO char(6)='105301',
		@month TINYINT=2,
		@year SMALLINT=2013
		
--SELECT dbo.fn_LetterNumberRegister(@account)		
		
CREATE TABLE #meduslugi 
(
	GUID_Case uniqueidentifier NOT NULL,
	id int NOT NULL,
	GUID_MU uniqueidentifier NOT NULL,
	rf_idMO char(6) NOT NULL,
	rf_idV002 smallint NOT NULL,
	IsChildTariff bit NOT NULL,
	DateHelpBegin date NOT NULL,
	DateHelpEnd date NOT NULL,
	DiagnosisCode char(10) NOT NULL,
	MUCode varchar(16) NOT NULL,
	Quantity decimal(6, 2) NOT NULL,
	Price decimal(15, 2) NOT NULL,
	TotalPrice decimal(15, 2) NOT NULL,
	rf_idV004 int NOT NULL
)
EXEC usp_GetMeduslugiFromRegisterCaseDB @account,@codeMO,@month,@year

SELECT * FROM #meduslugi

		
--SELECT * from dbo.fn_GetMeduslugiFromRegisterCaseDB(@account,@rf_idF003,@month,@year)
go
DROP TABLE #meduslugi