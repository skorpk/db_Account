use AccountOMS
go
if OBJECT_ID('usp_GetCaseFromRegisterCaseDB',N'P') is not null
drop proc usp_GetCaseFromRegisterCaseDB
go
create procedure usp_GetCaseFromRegisterCaseDB
		@account varchar(15)
		,@rf_idF003 char(6)
		,@month tinyint
		,@year smallint
as

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
where reg.ReportMonth=@month and	reg.ReportYear=@year and reg.NumberRegister=@number and	reg.PropertyNumberRegister=@property

insert #case
SELECT DISTINCT UPPER(t.ID_Patient)
		,t.id
		,t.GUID_Case
		,t.rf_idV006,t.rf_idV008
		,t.rf_idV014,t.rf_idV018,t.rf_idV019
		,t.rf_idDirectMO,t.HopitalisationType
		,t.rf_idMO,t.rf_idV002,t.IsChildTariff,t.NumberHistoryCase,t.DateBegin
		,t.DateEnd		
		,d.DS0
		,d.DS1
		,NULL AS DS2	
		,mes.MES
		,t.rf_idV009
		,t.rf_idV012
		,t.rf_idV004
		,t.IsSpecialCase
		,t.rf_idV010
		,mes.Quantity
		,mes.Tariff
		,t.AmountPayment
		,t.SANK_MEK
		,t.SANK_MEE
		,t.SANK_EKMP
		,t.[Emergency]
		,t.Comments
from (
		select rc.ID_Patient
				,c.id
				,c.GUID_Case
				,c.rf_idV006,c.rf_idV008
				,c.rf_idV014,c.rf_idV018,c.rf_idV019
				,c.rf_idDirectMO,c.HopitalisationType,
				c.rf_idMO,c.rf_idV002,c.IsChildTariff,c.NumberHistoryCase,c.DateBegin,c.DateEnd		
				,c.rf_idV009
				,c.rf_idV012
				,c.rf_idV004
				,c.IsSpecialCase
				,c.rf_idV010
				,c.AmountPayment
				,0.00 as SANK_MEK
				,0.00 as SANK_MEE
				,0.00 as SANK_EKMP
				,c.[Emergency]
				,c.Comments
		from RegisterCases.dbo.t_FileBack f inner join RegisterCases.dbo.t_RegisterCaseBack reg on
					f.id=reg.rf_idFilesBack
					and reg.id=@id
									inner join RegisterCases.dbo.t_RecordCaseBack rec on
						reg.id=rec.rf_idRegisterCaseBack 				
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
			) t inner join RegisterCases.dbo.vw_Diagnosis d on
					t.id=d.rf_idCase
				left join RegisterCases.dbo.t_Mes mes on
					t.id=mes.rf_idCase
---Вес новорожденных					
INSERT #tBirthWeight(GUID_Case,VNOV_M)
SELECT c.GUID_Case, b.BirthWeight						  	
from #Case c INNER JOIN RegisterCases.dbo.t_BirthWeight b ON
						c.id=b.rf_idCase 
--Диагнозы
INSERT #tDisgnosis(GUID_Case,Code,TypeDiagnosis)														
SELECT c.GUID_Case,d.DiagnosisCode,d.TypeDiagnosis
from #Case c INNER JOIN RegisterCases.dbo.t_Diagnosis d ON
						c.id=d.rf_idCase 
WHERE d.TypeDiagnosis IN(3,4)
go
/*
use RegisterCases
go
create nonclustered index IX_idCase on dbo.t_Mes(rf_idCase) INCLUDE(MES,Quantity,Tariff) with drop_existing

create nonclustered index IX_Case_AccountsOMS on dbo.t_Case(id,rf_idRecordCase)
INCLUDE
(
	GUID_Case,
	rf_idV006,
	rf_idV008,
	rf_idDirectMO,
	HopitalisationType,
	rf_idMO,
	rf_idV002,
	IsChildTariff,
	NumberHistoryCase,
	DateBegin,
	DateEnd,
	rf_idV009,
	rf_idV012,
	rf_idV004,
	IsSpecialCase,
	rf_idV010,
	AmountPayment
)
GO
CREATE NONCLUSTERED INDEX IX_RegisterCaseBack_AccountOMS
ON [dbo].[t_RegisterCaseBack] ([ReportYear],[ReportMonth],[NumberRegister],[PropertyNumberRegister])
GO
*/