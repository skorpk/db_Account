use AccountOMS
go
if OBJECT_ID('usp_InsertCase_PID_ENP',N'P') is not null
drop proc usp_InsertCase_PID_ENP
go
create procedure usp_InsertCase_PID_ENP
				@year char(4)
as
declare @dateStart datetime=@year+'0101',
		@dateEnd datetime=@year+'1231 23:59:59'

--процедура по заполнению данными для случаев по гражданам которые застразхованных в метсных СМО
--Заполняем PID и ЕНП для подсчета населения по некоторым отчетам
create table #t
(
	GUID_Case uniqueidentifier,
	id bigint
)
insert #t
select distinct c.GUID_Case,c.id
from t_File f inner join t_RegistersAccounts a on
		f.id=a.rf_idFiles
		and f.DateRegistration >=@dateStart
		and f.DateRegistration <=@dateEnd
			inner join (select smocod from vw_sprSMO where smocod!='34') smo on	
		a.rf_idSMO=smo.smocod
			inner join t_RecordCasePatient r on
		a.id=r.rf_idRegistersAccounts
		and a.ReportMonth>0
		and a.ReportMonth<13
			inner join t_Case c on
		r.id=c.rf_idRecordCasePatient
			left join t_Case_PID_ENP p on
		c.id=p.rf_idCase
where p.rf_idCase is null
		
if EXISTS(select * from #t)
begin
	insert dbo.t_Case_PID_ENP
	select t.id,t.PID,t.UNumberPolicy,[Type]
	from (
			select t.id,cd.PID,cd.UNumberPolicy,1 as [Type]
			from #t t inner join RegisterCases.dbo.t_Case c on
					t.GUID_Case=c.GUID_Case
					and c.DateEnd>=@dateStart
					and c.DateEnd<=@dateEnd
						inner join RegisterCases.dbo.t_RefCasePatientDefine rf on
					c.id=rf.rf_idCase
						inner join RegisterCases.dbo.t_CaseDefine cd on 
					rf.id=cd.rf_idRefCaseIteration
			--where cd.UNumberPolicy is not null
			union all
			select t.id,null,cf.UniqueNumberPolicy,2 as [Type]
			from #t t inner join RegisterCases.dbo.t_Case c on
					t.GUID_Case=c.GUID_Case
					and c.DateEnd>=@dateStart
					and c.DateEnd<=@dateEnd
						inner join RegisterCases.dbo.t_RefCasePatientDefine rf on
					c.id=rf.rf_idCase
						inner join RegisterCases.dbo.t_CaseDefineZP1Found cf on 
					rf.id=cf.rf_idRefCaseIteration	
			--where cf.UniqueNumberPolicy is not null
		) t
end

drop table #t
go