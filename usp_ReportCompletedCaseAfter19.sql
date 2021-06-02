use AccountOMS
go
if OBJECT_ID('usp_ReportCompletedCaseAfter19',N'P') is not null
drop proc usp_ReportCompletedCaseAfter19
go
create proc usp_ReportCompletedCaseAfter19
			@dateBeg datetime,
			@dateEnd datetime,
			@codeFilial tinyint
as
set language Russian
--фиктивная переменная, для отбора новых тарифов под модернизацию
declare @dateCaseEnd datetime='20121120'

CREATE TABLE #t
(
	id bigint,
	CodeM varchar(6) NULL,
	NameS varchar(250) NULL,
	rf_idSMO char(5) NULL,
	sNameS varchar(250) NULL,
	Account varchar(15) NULL,
	DateAccount char(10) NULL,
	DateRegistration varchar(21) NULL,
	ReportDate nvarchar(30) NULL,
	Summa decimal(11, 2) NULL,
	MES varchar(16) NULL,
	MUName varchar(255) NOT NULL,
	Quantity decimal(38, 2) NULL,
	Tariff decimal(15, 2) NULL,
	MUId bigint NOT NULL,
	DateEnd date NOT NULL,
	unitCode tinyint
)

insert #t
select distinct id,t.CodeM,t001.NameS,t.rf_idSMO,smo.sNameS,
		t.Account,t.DateAccount,t.DateRegistration,t.ReportDate,t.Summa,rtrim(t.MES),vw_MU.MUName,t.Quantity,t.Tariff,vw_MU.MUId,t.DateEnd,vw_MU.unitCode
from (
		select c.id,f.CodeM as CodeM,m.MES,a.rf_idSMO
				,a.Account
				,CONVERT(CHAR(10),a.DateRegister,104) as DateAccount
				,CONVERT(CHAR(10),f.DateRegistration,104)+' '+CONVERT(CHAR(10),f.DateRegistration,108) as DateRegistration
				,dbo.fn_MonthName(a.ReportYear,a.ReportMonth) as ReportDate
				,cast(a.AmountPayment as decimal(11,2)) as Summa
				,m.Quantity
				,m.Tariff
				,c.DateEnd
		from t_File f inner join t_RegistersAccounts a on
				f.id=a.rf_idFiles
						inner join t_RecordCasePatient r on
				a.id=r.rf_idRegistersAccounts
				and a.Letter in ('M','М')
						inner join t_Case c on
				r.id=c.rf_idRecordCasePatient
				--and c.DateEnd>=@dateBeg 
				and c.DateEnd<=@dateEnd
						inner join t_MES m with(INDEX(IX_MES_CASE)) on 
				c.id=m.rf_idCase				
		where f.DateRegistration>=@dateBeg and f.DateRegistration<=@dateEnd
		) t inner join vw_sprMUCompletedCase vw_MU on
		t.MES=vw_MU.MU			
				inner join vw_sprT001 t001 on
		t.CodeM=t001.CodeM
				inner join vw_sprSMO smo on
		t.rf_idSMO=smo.smocod
where  t001.FilialId=@codeFilial

alter table #t add AccountFF varchar(15)
alter table #t add  SumBF decimal(11,2)
alter table #t add AccountBF varchar(15)
alter table #t add Tariff_FF decimal(11,2)


;with Account(CodeM,Account,DateRegistration,MES,Tariff_FF,SumFF,AccountFF,SumBF, AccountBF)
AS
(
select t.CodeM		
		,t.Account
		,t.DateRegistration
		,t.MES
		----------------F-----------------------
		,m.Price as Tariff_FF
		,cast(SUM(t.Quantity*m.Price) as decimal(11,2)) as SumFF
		,case when m.rf_MUId is null then null else REPLACE(REPLACE(t.Account,'M','F'),'М','F') end as AccountFF
		----------------B-----------------------
		,cast(SUM(t.Quantity*mb.Price)as decimal(11,2)) as SumBF
		,case when mb.rf_MUId is null then null else REPLACE(REPLACE(t.Account,'M','B'),'М','B') end as AccountBF
from #t t left join oms_NSI.dbo.sprMUPriceModernization m on
		m.rf_MUId=t.MUId 
		and t.DateEnd>=m.MUPriceDateBeg 
		and t.DateEnd<=m.MUPriceDateEnd
			left join oms_NSI.dbo.sprMUPriceAVO mb on
		t.MUId=mb.rf_MUId
		and @dateCaseEnd>=mb.MUPriceDateBeg 
		and @dateCaseEnd<=mb.MUPriceDateEnd
group by t.CodeM,t.Account,t.DateRegistration,t.MES,m.Price,mb.Price,m.rf_MUId ,mb.rf_MUId 
) 
update t
set t.AccountFF=a.AccountFF,t.SumBF=a.SumBF,t.AccountBF=a.AccountBF, t.Tariff_FF=a.Tariff_FF
from #t t left join (
					select CodeM,Account,DateRegistration,MES,AccountFF,sum(SumBF) as SumBF, AccountBF,Tariff_FF
					from Account
					group by CodeM,Account,DateRegistration,MES,AccountFF, AccountBF,Tariff_FF
					) a on
		a.CodeM=t.CodeM
		and a.Account=t.Account
		and a.DateRegistration=t.DateRegistration
		and a.MES=t.MES

select t.CodeM
		,t.NameS
		,t.rf_idSMO
		,t.sNameS
		,t.Account
		,t.DateAccount
		,t.DateRegistration
		,t.ReportDate 
		,t.Summa 
		,t.MES 
		,t.MUName 
		,sum(t.Quantity) as Quantity
		,t.Tariff 
		,isnull(m.Price,0) as FF
		,t1.SumFF as SumFF
		,u.unitName
		,max(t.AccountFF) as AccountFF
		----------------B-----------------------
		,isnull(mb.Price,0) as FB
		,case when isnull(mb.Price,0)>0 then isnull(t.SumBF,0) else 0 end as SumBF
		,case when isnull(mb.Price,0)>0 then isnull(t.AccountBF,'') else '' end as AccountBF
from #t t inner join dbo.vw_unitName u on
		t.unitCode=u.unitCode
			inner join (select Account,CodeM,rf_idSMO,sum(Quantity*Tariff_FF) as SumFF from #t group by Account,CodeM,rf_idSMO) t1 on
		 t.Account=t1.Account
		 and t.CodeM=t1.CodeM
		 and t.rf_idSMO=t1.rf_idSMO
			left join oms_NSI.dbo.sprMUPriceModernization m on
		m.rf_MUId=t.MUId 
		and @dateCaseEnd>=m.MUPriceDateBeg 
		and @dateCaseEnd<=m.MUPriceDateEnd
			left join oms_NSI.dbo.sprMUPriceAVO mb on
		t.MUId=mb.rf_MUId
		and t.DateEnd>=mb.MUPriceDateBeg 
		and t.DateEnd<=mb.MUPriceDateEnd
group by t.CodeM,t.NameS,t.rf_idSMO,t.sNameS,t.Account,t.DateAccount,t.DateRegistration,t.ReportDate,t.Summa,t.MES 
		,t.MUName,t.Tariff,t1.SumFF,isnull(m.Price,0),u.unitName,isnull(mb.Price,0)
		,isnull(t.SumBF,0),isnull(t.AccountBF,'') 
order by CodeM,Account,MES

drop table #t

go