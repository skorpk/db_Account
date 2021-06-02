USE AccountOMSReports
GO
DROP TABLE [dbo].[t_PaymentAcceptedCaseType]
go
CREATE TABLE [dbo].[t_PaymentAcceptedCaseType]
(
	rf_idCase BIGINT NOT NULL,
	DateRegistration DATETIME NOT NULL,
	DocumentNumber VARCHAR(25) NOT NULL,
	DocumentDate DATE NOT NULL,
	TypeExamination TINYINT	NOT NULL
)
GO
IF OBJECT_ID('t_ReportAnalyzeDeath','U') IS NOT NULL
	DROP TABLE t_ReportAnalyzeDeath
go
CREATE TABLE t_ReportAnalyzeDeath
(
	  DateRegistration DATETIME,
	  ReportYearMonth INT,
	  rf_idV009 SMALLINT,
	  rf_idCase BIGINT,					  
	  DS1 varCHAR(6),
	  AmountPayment DECIMAL(11,2),	
	  CodeM CHAR(6),
	  CodeSMO CHAR(5),
	  Account VARCHAR(15),
	  DateAccount DATE,
	  rf_idV006 TINYINT,
	  rf_idV002 SMALLINT,
	  SNILS VARCHAR(11),
	  Child BIT,
	  NumberCase BIGINT,
	  Sex CHAR(1),
	  Policy VARCHAR(20)	  
)	