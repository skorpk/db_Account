USE AccountOMS
GO
declare	@year char(4)=2012
declare @dateStart datetime=@year+'0101',
		@dateEnd datetime=@year+'1231 23:59:59'

--TRUNCATE TABLE t_Case_PID_ENP_1
--процедура по заполнению данными для случаев по гражданам которые застразхованных в метсных СМО
--Заполняем PID и ЕНП для подсчета населения по некоторым отчетам
create table #t
(
	GUID_Case uniqueidentifier,
	id bigint
)
	
insert #t
select distinct c.GUID_Case,c.id
from t_Case c left join t_Case_PID_ENP_1 p on
		c.id=p.rf_idCase 
where c.DateEnd>=@dateStart	and c.DateEnd<=@dateEnd AND p.rf_idCase is null

if EXISTS(select * from #t)
begin
	insert dbo.t_Case_PID_ENP_1
	SELECT t.id,t.PID,t.UNumberPolicy,[Type],@year
	from (
			SELECT TOP 1 WITH ties t.id,cd.PID,cd.UNumberPolicy,1 as [Type]
			from #t t inner join RegisterCases.dbo.t_Case c on
								t.GUID_Case=c.GUID_Case
								and c.DateEnd>=@dateStart
								and c.DateEnd<=@dateEnd
									inner join RegisterCases.dbo.t_RefCasePatientDefine rf on
								c.id=rf.rf_idCase
									inner join RegisterCases.dbo.t_CaseDefine cd on 
								rf.id=cd.rf_idRefCaseIteration
			where cd.PID IS NOT NULL
			ORDER BY ROW_NUMBER() OVER(PARTITION BY t.id ORDER BY cd.PID)
			union all
			SELECT TOP 1 WITH ties t.id,null,cf.UniqueNumberPolicy,2 as [Type]
			from #t t inner join RegisterCases.dbo.t_Case c on
					t.GUID_Case=c.GUID_Case
					and c.DateEnd>=@dateStart
					and c.DateEnd<=@dateEnd
						inner join RegisterCases.dbo.t_RefCasePatientDefine rf on
					c.id=rf.rf_idCase
						inner join RegisterCases.dbo.t_CaseDefineZP1Found cf on 
					rf.id=cf.rf_idRefCaseIteration	
			where cf.UniqueNumberPolicy is not null
			ORDER BY ROW_NUMBER() OVER(PARTITION BY t.id ORDER BY cf.rf_idZP1)
		) t
end

drop table #t