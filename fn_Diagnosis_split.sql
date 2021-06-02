use AccountOMS
go		
IF OBJECT_ID (N'dbo.fn_GetDS0RegisterCaseDB', N'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_GetDS0RegisterCaseDB
go
CREATE FUNCTION dbo.fn_GetDS0RegisterCaseDB(@rf_idCase bigint)
RETURNS varchar(10)
as
begin
declare @d varchar(10)
		select @d=DiagnosisCode	from RegisterCases.dbo.t_Diagnosis d where d.TypeDiagnosis=2 and d.rf_idCase=@rf_idCase
	
RETURN(@d)
end
GO
IF OBJECT_ID (N'dbo.fn_GetDS1RegisterCaseDB', N'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_GetDS1RegisterCaseDB
go
CREATE FUNCTION dbo.fn_GetDS1RegisterCaseDB(@rf_idCase bigint)
RETURNS varchar(10)
as
begin
declare @d varchar(10)
		select @d=DiagnosisCode	from RegisterCases.dbo.t_Diagnosis d where d.TypeDiagnosis=1 and d.rf_idCase=@rf_idCase	
RETURN(@d)
end
GO
IF OBJECT_ID (N'dbo.fn_GetDS2RegisterCaseDB', N'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_GetDS2RegisterCaseDB
go
CREATE FUNCTION dbo.fn_GetDS2RegisterCaseDB(@rf_idCase bigint)
RETURNS varchar(10)
as
begin
declare @d varchar(10)
		select @d=DiagnosisCode	from RegisterCases.dbo.t_Diagnosis d where d.TypeDiagnosis=3 and d.rf_idCase=@rf_idCase
	
RETURN(@d)
end
GO