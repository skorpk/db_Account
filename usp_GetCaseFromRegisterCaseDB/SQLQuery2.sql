use AccountOMS
go

--create table #case
--(
--	ID_Patient varchar(36) NOT NULL,
--	GUID_Case uniqueidentifier NOT NULL,
--	rf_idV006 tinyint NULL,
--	rf_idV008 smallint NULL,
--	rf_idDirectMO char(6) NULL,
--	HopitalisationType tinyint NULL,
--	rf_idMO char(6) NOT NULL,
--	rf_idV002 smallint NOT NULL,
--	IsChildTariff bit NOT NULL,
--	NumberHistoryCase nvarchar(50) NOT NULL,
--	DateBegin date NOT NULL,
--	DateEnd date NOT NULL,
--	DS0 char(10) NULL,
--	DS1 char(10) NULL,
--	DS2 char(10) NULL,
--	MES char(16) NULL,
--	rf_idV009 smallint NOT NULL,
--	rf_idV012 smallint NOT NULL,
--	rf_idV004 int NOT NULL,
--	IsSpecialCase tinyint NULL,
--	rf_idV010 tinyint NOT NULL,
--	Quantity decimal(5, 2) NULL,
--	Tariff decimal(15, 2) NULL,
--	AmountPayment decimal(15, 2) NOT NULL,
--	SANK_MEK decimal(15, 2) NULL,
--	SANK_MEE decimal(15, 2) NULL,
--	SANK_EKMP decimal(15, 2) NULL
--)
--GO
SET STATISTICS IO ON
SET STATISTICS TIME ON

declare @account varchar(15)='34001-10-1'
		,@rf_idF003 char(6)='251001'
		,@month tinyint=3
		,@year smallint=2012

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


--insert #case
select t.ID_Patient
		,t.GUID_Case
		,t.rf_idV006,t.rf_idV008,t.rf_idDirectMO,t.HopitalisationType
		,t.rf_idMO,t.rf_idV002,t.IsChildTariff,t.NumberHistoryCase,t.DateBegin
		,t.DateEnd		
		,d.DS0
		,d.DS1
		,d.DS2	
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
from (
select rc.ID_Patient
		,c.id
		,c.GUID_Case
		,c.rf_idV006,c.rf_idV008,c.rf_idDirectMO,c.HopitalisationType,
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

go
--drop table #case
