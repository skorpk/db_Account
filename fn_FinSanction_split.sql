use AccountOMS
go		
IF OBJECT_ID (N'dbo.fn_GetMEKRegisterCaseDB', N'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_GetMEKRegisterCaseDB
go
CREATE FUNCTION dbo.fn_GetMEKRegisterCaseDB(@rf_idCase bigint)
RETURNS decimal(15,2)
as
begin
declare @d decimal(15,2)
		select @d=Amount from RegisterCases.dbo.t_FinancialSanctions d where d.TypeSanction=1 and d.rf_idCase=@rf_idCase
	
RETURN(@d)
end
GO
IF OBJECT_ID (N'dbo.fn_GetMEERegisterCaseDB', N'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_GetMEERegisterCaseDB
go
CREATE FUNCTION dbo.fn_GetMEERegisterCaseDB(@rf_idCase bigint)
RETURNS decimal(15,2)
as
begin
declare @d decimal(15,2)
		select @d=Amount from RegisterCases.dbo.t_FinancialSanctions d where d.TypeSanction=2 and d.rf_idCase=@rf_idCase
	
RETURN(@d)
end
GO
IF OBJECT_ID (N'dbo.fn_GetEKMPRegisterCaseDB', N'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_GetEKMPRegisterCaseDB
go
CREATE FUNCTION dbo.fn_GetEKMPRegisterCaseDB(@rf_idCase bigint)
RETURNS decimal(15,2)
as
begin
declare @d decimal(15,2)
		select @d=Amount from RegisterCases.dbo.t_FinancialSanctions d where d.TypeSanction=3 and d.rf_idCase=@rf_idCase
	
RETURN(@d)
end
GO