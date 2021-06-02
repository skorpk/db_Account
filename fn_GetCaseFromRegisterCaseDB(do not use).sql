use AccountOMS
go		
IF OBJECT_ID (N'dbo.fn_GetCaseFromRegisterCaseDB', N'TF') IS NOT NULL
    DROP FUNCTION dbo.fn_GetCaseFromRegisterCaseDB
go
CREATE FUNCTION dbo.fn_GetCaseFromRegisterCaseDB(@account varchar(15),@rf_idF003 char(6),@month tinyint,@year smallint)
RETURNS @case TABLE(
					ID_Patient varchar(36) NOT NULL,
					idRecordCase int NOT NULL,
					GUID_Case uniqueidentifier NOT NULL,
					rf_idV006 tinyint NULL,
					rf_idV008 smallint NULL,
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
					SANK_EKMP decimal(15, 2) NULL
				)
as
begin
declare @number int,
		@property tinyint,
		@smo char(5)
		
select @number=dbo.fn_NumberRegister(@account),@smo=dbo.fn_PrefixNumberRegister(@account),@property=dbo.fn_PropertyNumberRegister(@account)

declare @diag as table (rf_idCase bigint,DS0 char(10),DS1 char(10),DS2 char(10))
declare @id int

select @id=reg.id 
from RegisterCases.dbo.t_FileBack f inner join RegisterCases.dbo.t_RegisterCaseBack reg on
			f.id=reg.rf_idFilesBack
			and f.CodeM=@rf_idF003 
where /*reg.ref_idF003=@rf_idF003 and	*/reg.ReportMonth=@month and	reg.ReportYear=@year and reg.NumberRegister=@number and	reg.PropertyNumberRegister=@property

insert @diag
select c.id,(select top 1 DiagnosisCode from RegisterCases.dbo.t_Diagnosis d where c.id=d.rf_idCase and TypeDiagnosis=2)
			,(select top 1 DiagnosisCode from RegisterCases.dbo.t_Diagnosis d where c.id=d.rf_idCase and TypeDiagnosis=1)
			,(select top 1 DiagnosisCode from RegisterCases.dbo.t_Diagnosis d where c.id=d.rf_idCase and TypeDiagnosis=3)			
from RegisterCases.dbo.t_RecordCaseBack rec inner join RegisterCases.dbo.t_CaseBack cb on
				rec.id=cb.rf_idRecordCaseBack and
				cb.TypePay=1
							inner join RegisterCases.dbo.t_Case c on
				rec.rf_idCase=c.id							
where rec.rf_idRegisterCaseBack=@id

insert @case
select rc.ID_Patient,c.idRecordCase,c.GUID_Case,c.rf_idV006,c.rf_idV008,rf_idDirectMO,c.HopitalisationType,
		c.rf_idMO,c.rf_idV002,c.IsChildTariff,c.NumberHistoryCase,c.DateBegin,c.DateEnd		
		,d.DS0
		,d.DS1
		,d.DS2	
		,mes.MES,c.rf_idV009,c.rf_idV012,c.rf_idV004,c.IsSpecialCase,c.rf_idV010,mes.Quantity,mes.Tariff,
		c.AmountPayment
		,sum(case when fin.TypeSanction=1 then fin.Amount else 0 end) as SANK_MEK
		,sum(case when fin.TypeSanction=2 then fin.Amount else 0 end) as SANK_MEE
		,sum(case when fin.TypeSanction=3 then fin.Amount else 0 end) as SANK_EKMP
from RegisterCases.dbo.t_FileBack f inner join RegisterCases.dbo.t_RegisterCaseBack reg on
			f.id=reg.rf_idFilesBack
			and f.CodeM=@rf_idF003 
									inner join RegisterCases.dbo.t_RecordCaseBack rec on
				reg.id=rec.rf_idRegisterCaseBack and
				--reg.ref_idF003=@rf_idF003 and
				reg.ReportMonth=@month and
				reg.ReportYear=@year and
				reg.NumberRegister=@number and
				reg.PropertyNumberRegister=@property
							inner join RegisterCases.dbo.t_PatientBack p on
				rec.id=p.rf_idRecordCaseBack and
				p.rf_idSMO=@smo
							inner join RegisterCases.dbo.t_CaseBack cb on
				rec.id=cb.rf_idRecordCaseBack and
				cb.TypePay=1
							inner join RegisterCases.dbo.t_Case c on
				rec.rf_idCase=c.id
							inner join RegisterCases.dbo.t_RecordCase rc on
				c.rf_idRecordCase=rc.id
							inner join @diag d on
				c.id=d.rf_idCase
							left join RegisterCases.dbo.t_Mes mes on
				c.id=mes.rf_idCase
							left join RegisterCases.dbo.t_FinancialSanctions fin on
				c.id=fin.rf_idCase
group by c.id,rc.ID_Patient,c.idRecordCase,c.GUID_Case,c.rf_idV006,c.rf_idV008,rf_idDirectMO,c.HopitalisationType,
		c.rf_idMO,c.rf_idV002,c.IsChildTariff,c.NumberHistoryCase,c.DateBegin,c.DateEnd,d.DS0
		,d.DS1,d.DS2,mes.MES,c.rf_idV009,c.rf_idV012,c.rf_idV004,c.IsSpecialCase,c.rf_idV010,mes.Quantity,mes.Tariff,
		c.AmountPayment
RETURN
end;