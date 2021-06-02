use AccountOMS
go
--declare @id int
--select @id=id
--from t_File
--where CodeM='151005' and FileNameHR='HM151005T34_111269'

create table #t
(
	id int,
	sumCase decimal(15,2),
	sumAccount decimal(15,2)
)

insert #t
select a.id,SUM(c.AmountPayment),a.AmountPayment
from t_RegistersAccounts a inner join t_RecordCasePatient r on
		a.id=r.rf_idRegistersAccounts
							inner join t_Case c on
		r.id=c.rf_idRecordCasePatient
		--					inner join t_Meduslugi m on
		--c.id=m.rf_idCase
--where a.rf_idFiles=@id
--order by idRecordCase
group by a.id,a.AmountPayment

select *
from #t t1 inner join #t t2 on
		t1.id=t2.id
where t1.sumCase<>t2.sumAccount

drop table #t