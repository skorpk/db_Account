USE AccountOMS
go
select convert(varchar(10),a.DateRegister,104) as DateAccount,convert(varchar(10),f.DateRegistration,104) as DateReg
		,a.Account,l.CodeM,l.NameS,s.sNameS,cast(a.AmountPayment as money) as AmountPayment
from t_File f inner join t_RegistersAccounts a on
		f.id=a.rf_idFiles
				inner join vw_sprT001 l on
		f.CodeM=l.CodeM
		and l.FilialId=1
				inner join vw_sprSMO s on
		a.PrefixNumberRegister=s.smocod
where f.DateRegistration>='20130101' and f.DateRegistration<'20130201' and a.ReportYear=2013 and a.ReportMonth=1 and a.PrefixNumberRegister<>'34'
--group by l.CodeM,l.NameS
order by l.CodeM
go
