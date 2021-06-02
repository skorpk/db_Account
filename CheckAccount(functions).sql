use AccountOMS
go		
IF OBJECT_ID (N'dbo.fn_CheckAccountExistSPTK', N'IF') IS NOT NULL
    DROP FUNCTION dbo.fn_CheckAccountExistSPTK
go
--проверка наличия реестра СП и ТК в БД
CREATE FUNCTION dbo.fn_CheckAccountExistSPTK(@account varchar(15),@codeMO char(6),@month tinyint,@year smallint)
RETURNS TABLE
as
	RETURN(
	        select r.id
			from RegisterCases.dbo.t_FileBack f inner join RegisterCases.dbo.t_RegisterCaseBack r on
					f.id=r.rf_idFilesBack
					and f.CodeM=@codeMO
						  inner join RegisterCases.dbo.t_RecordCaseBack rec on
					r.id=rec.rf_idRegisterCaseBack
					and ReportMonth=@month 
					and ReportYear=@year 
						inner join RegisterCases.dbo.t_PatientBack p on
					rec.id=p.rf_idRecordCaseBack							
			where rtrim(p.rf_idSMO)+'-'+CAST(r.NumberRegister as varchar(6))+'-'+CAST(r.PropertyNumberRegister as CHAR(1))= 
					(case when ISNUMERIC(RIGHT(@account,1))=1 then @account else SUBSTRING(@account,1,LEN(@account)-1) end)
		)

GO
IF OBJECT_ID (N'dbo.fn_CheckAccountExistInDB', N'IF') IS NOT NULL
    DROP FUNCTION dbo.fn_CheckAccountExistInDB
go
--проверка на наличие уже зарегестрированного счета с такми номером от МО
CREATE FUNCTION dbo.fn_CheckAccountExistInDB(@account varchar(15),@codeMO char(6),@month tinyint,@year smallint)
RETURNS TABLE
as
RETURN(
		select distinct a.id
		from t_File f inner join t_RegistersAccounts a on
				f.id=a.rf_idFiles
				and f.CodeM=@codeMO
				and a.ReportYear=@year
		where rtrim(PrefixNumberRegister)+'-'+CAST(NumberRegister as varchar(6))+'-'+CAST(PropertyNumberRegister as CHAR(1))+ISNULL(Letter,'')=@account
	)
GO