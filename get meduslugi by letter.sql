USE AccountOMS
GO
declare @account varchar(15)='34001-45-1Z',
		@codeMO char(6)='161007',
		@month TINYINT=6,
		@year SMALLINT=2013
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
			rf_idV004 int NOT NULL,
			Comments VARCHAR(250)
		)		
EXEC usp_GetMeduslugiFromRegisterCaseDB @account,@codeMO,@month,@year
SELECT * 
FROM #meduslugi m INNER JOIN vw_sprMuWithParamAccount sm ON
			m.MUCode=sm.MU
WHERE sm.AccountParam='Z'
GO
DROP TABLE #meduslugi
			