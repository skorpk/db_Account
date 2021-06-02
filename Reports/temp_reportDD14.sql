use AccountOMS
go
declare @dateStart datetime='20120501',
		@dateEnd datetime=GETDATE()
--declare @t as table(CodeM char(6), col3 int, col4 int, col6 int, col7 int)

--insert @t
select CodeM,SUM(t.Col3), SUM(t.Col4),SUM(t.Col6), SUM(t.col7)
from (
		select CodeM,SUM(m.Quantity) as Col3,0  as Col4,0 as Col6, 0 as Col7
		from t_File f inner join t_RegistersAccounts a on
				f.id=a.rf_idFiles								
					  inner join t_RecordCasePatient p on
				a.id=p.rf_idRegistersAccounts
					  inner join t_Case c on
				p.id=c.rf_idRecordCasePatient
						inner join t_Meduslugi m on
				c.id=m.rf_idCase
		where f.DateRegistration>=@dateStart and f.DateRegistration<=@dateEnd and a.Letter='D' and m.MUInt=7001001
		group by CodeM
		union all
		select CodeM,0,SUM(m.Quantity),0,0
		from t_File f inner join t_RegistersAccounts a on
				f.id=a.rf_idFiles								
						inner join t_RecordCasePatient p on
				a.id=p.rf_idRegistersAccounts
						inner join t_Case c on
				p.id=c.rf_idRecordCasePatient
						inner join t_Meduslugi m on
				c.id=m.rf_idCase
		where f.DateRegistration>=@dateStart and f.DateRegistration<=@dateEnd and a.Letter='D' and m.MUInt=7001002
		group by CodeM	
		union all 
		select CodeM,0,0,SUM(m.Quantity),0
		from t_File f inner join t_RegistersAccounts a on
						f.id=a.rf_idFiles								
								inner join t_RecordCasePatient p on
						a.id=p.rf_idRegistersAccounts
								inner join t_Case c on
						p.id=c.rf_idRecordCasePatient
								inner join vw_MUChild14D_Col6 m on
						c.id=m.rf_idCase
		where f.DateRegistration>=@dateStart and f.DateRegistration<=@dateEnd and a.Letter='D' 
		group by CodeM
		union all 
		select CodeM,0,0,0,SUM(m.Quantity)
		from t_File f inner join t_RegistersAccounts a on
						f.id=a.rf_idFiles								
								inner join t_RecordCasePatient p on
						a.id=p.rf_idRegistersAccounts
								inner join t_Case c on
						p.id=c.rf_idRecordCasePatient
								inner join vw_MUChild14D_Col7 m on
						c.id=m.rf_idCase
		where f.DateRegistration>=@dateStart and f.DateRegistration<=@dateEnd and a.Letter='D' 
		group by CodeM			
	 ) t
group by CodeM




select * from @t