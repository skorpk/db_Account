USE AccountOMS
GO
if(OBJECT_ID('t_AdditionalAccounts',N'U')) is not null
	drop table dbo.t_AdditionalAccounts
go
create table dbo.t_AdditionalAccounts
(
	CodeM char(8) null,
	CodeSMO char(5) null,
	ReportMonth tinyint null,
	ReportYear smallint null,	
	NumberRegister tinyint null,
	Letter CHAR(1) NULL,
	DateRegistration DATETIME NULL,
	DateAccount date null ,	
	AmountPayment decimal(15,2) null
) 
GO
ALTER TABLE t_AdditionalAccounts ADD Account AS (CodeSMO+'-'+CAST(reportMonth AS VARCHAR(2))+'-'+CAST(NumberRegister AS VARCHAR(1))+Letter)
GO
EXEC sys.sp_rename @objname = N'dbo.t_AdditionalAccounts.CodeM', -- nvarchar(1035)
	@newname = 'CodeLPU', -- sysname
	@objtype = 'COLUMN' -- varchar(13)

GO
ALTER TABLE t_AdditionalAccounts ADD CodeM AS (LEFT(CodeLPU,6))