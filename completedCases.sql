use AccountOMS
go
declare @dateBeg datetime='20120420',
		@dateEnd datetime='20120519',
		@codeFilial tinyint=1

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
				and f.CodeM='161007'
						inner join t_RecordCasePatient r on
				a.id=r.rf_idRegistersAccounts
				and a.Letter in ('M','Ì')
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

alter table #t add SumFF decimal(11,2)
alter table #t add AccountFF varchar(15)
alter table #t add  SumBF decimal(11,2)
alter table #t add AccountBF varchar(15)


;with Account(CodeM,Account,DateRegistration,SumFF,AccountFF/*,SumBF, AccountBF*/)
AS
(
select t.CodeM		
		,t.Account
		,t.DateRegistration
		----------------F-----------------------
		,cast(isnull(SUM(t.Quantity*m.Price),0) as decimal(11,2)) as SumFF
		,case when m.rf_MUId is null then null else REPLACE(REPLACE(t.Account,'M','F'),'Ì','F') end as AccountFF
		----------------B-----------------------
		--,cast(isnull(SUM(t.Quantity*mb.Price),0) as decimal(11,2)) as SumBF
		--,case when mb.rf_MUId is null then null else REPLACE(REPLACE(t.Account,'M','B'),'Ì','B') end as AccountBF
from #t t inner join oms_NSI.dbo.sprMUPriceModernization m on
		m.rf_MUId=t.MUId 
		and t.DateEnd>=m.MUPriceDateBeg 
		and t.DateEnd<=m.MUPriceDateEnd
		--	left join oms_NSI.dbo.sprMUPriceAVO mb on
		--t.MUId=mb.rf_MUId
		--and t.DateEnd>=mb.MUPriceDateBeg 
		--and t.DateEnd<=mb.MUPriceDateEnd
group by t.CodeM,t.Account,t.DateRegistration
		--,mb.Price
		,m.rf_MUId 
		--,mb.rf_MUId 
) 
update t
set t.SumFF=a.SumFF,t.AccountFF=a.AccountFF--,t.SumBF=a.SumBF,t.AccountBF=a.AccountBF
from #t t inner join (
					select CodeM,Account,DateRegistration,sum(SumFF) as SumFF,AccountFF--,sum(SumBF) as SumBF, AccountBF
					from Account
					group by CodeM,Account,DateRegistration,AccountFF--, AccountBF
					) a on
		a.CodeM=t.CodeM
		and a.Account=t.Account
		and a.DateRegistration=t.DateRegistration
		
------------------------------BB-----------------------------------------
;with AccountBF(CodeM,Account,DateRegistration,SumBF, AccountBF)
AS
(
select t.CodeM		
		,t.Account
		,t.DateRegistration
		----------------B-----------------------
		,cast(isnull(SUM(t.Quantity*mb.Price),0) as decimal(11,2)) as SumBF
		,case when mb.rf_MUId is null then null else REPLACE(REPLACE(t.Account,'M','B'),'Ì','B') end as AccountBF
from #t t inner join oms_NSI.dbo.sprMUPriceAVO mb on
		t.MUId=mb.rf_MUId
		and t.DateEnd>=mb.MUPriceDateBeg 
		and t.DateEnd<=mb.MUPriceDateEnd
group by t.CodeM,t.Account,t.DateRegistration,mb.Price,mb.rf_MUId 
) 
update t
set t.SumBF=a.SumBF,t.AccountBF=a.AccountBF
from #t t inner join (
					select CodeM,Account,DateRegistration,sum(SumBF) as SumBF, AccountBF
					from AccountBF
					group by CodeM,Account,DateRegistration,AccountBF
					) a on
		a.CodeM=t.CodeM
		and a.Account=t.Account
		and a.DateRegistration=t.DateRegistration

select * from #t order by Account,MES

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
		,t.SumFF
		,u.unitName
		,t.AccountFF
		----------------B-----------------------
		,isnull(mb.Price,0) as FB
		,t.SumBF
		,t.AccountBF
from #t t inner join dbo.vw_unitName u on
		t.unitCode=u.unitCode
			left join oms_NSI.dbo.sprMUPriceModernization m on
		m.rf_MUId=t.MUId 
		and t.DateEnd>=m.MUPriceDateBeg 
		and t.DateEnd<=m.MUPriceDateEnd
			left join oms_NSI.dbo.sprMUPriceAVO mb on
		t.MUId=mb.rf_MUId
		and t.DateEnd>=mb.MUPriceDateBeg 
		and t.DateEnd<=mb.MUPriceDateEnd
group by t.CodeM,t.NameS,t.rf_idSMO,t.sNameS,t.Account,t.DateAccount,t.DateRegistration,t.ReportDate,t.Summa,t.MES 
		,t.MUName,t.Tariff,isnull(m.Price,0),t.SumFF,u.unitName,t.AccountFF,isnull(mb.Price,0),t.SumBF,t.AccountBF

--select t.CodeM
--		,t.NameS
--		,t.rf_idSMO
--		,t.sNameS
--		,t.Account
--		,t.DateAccount
--		,t.DateRegistration
--		,t.ReportDate 
--		,t.Summa 
--		,t.MES 
--		,t.MUName 
--		,sum(t.Quantity) as Quantity
--		,t.Tariff 
--		,isnull(m.Price,0) as FF
--		,max(t.SumFF) as SumFF
--		,u.unitName
--		,max(t.AccountFF) as AccountFF
--		----------------B-----------------------
--		,isnull(mb.Price,0) as FB
--		,max(t.SumBF) as SumBF
--		,max(t.AccountBF) as AccountBF
--from #t t inner join dbo.vw_unitName u on
--		t.unitCode=u.unitCode
--			left join oms_NSI.dbo.sprMUPriceModernization m on
--		m.rf_MUId=t.MUId 
--		and t.DateEnd>=m.MUPriceDateBeg 
--		and t.DateEnd<=m.MUPriceDateEnd
--			left join oms_NSI.dbo.sprMUPriceAVO mb on
--		t.MUId=mb.rf_MUId
--		and t.DateEnd>=mb.MUPriceDateBeg 
--		and t.DateEnd<=mb.MUPriceDateEnd
--group by t.CodeM,t.NameS,t.rf_idSMO,t.sNameS,t.Account,t.DateAccount,t.DateRegistration,t.ReportDate,t.Summa,t.MES 
--		,t.MUName,t.Tariff,isnull(m.Price,0),u.unitName,isnull(mb.Price,0)
--order by MES
go
drop table #t
