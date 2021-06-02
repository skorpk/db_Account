USE [AccountOMS]
GO
/****** Object:  StoredProcedure [dbo].[usp_InsertCase_PID_ENP]    Script Date: 02/11/2014 14:58:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_InsertCase_ENP34]
				@year char(4)
as											   
declare @dateStart datetime=@year+'0101',
		@dateEnd datetime=@year+'1231 23:59:59'
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
		AND a.rf_idSMO='34'			
			inner join t_RecordCasePatient r on
		a.id=r.rf_idRegistersAccounts
		and a.ReportMonth>0
		and a.ReportMonth<13
			inner join t_Case c on
		r.id=c.rf_idRecordCasePatient
		AND c.DateEnd>=@dateStart
		AND c.DateEnd<=@dateEnd
			left join t_Case_PID_ENP34 p on
		c.id=p.rf_idCase
where p.rf_idCase is null

if EXISTS(select * from #t)
begin
	INSERT dbo.t_Case_PID_ENP34( rf_idCase ,PID ,ENP ,IsLocal ,ReportYear)	
	SELECT TOP 1 WITH ties t.id,t.PID,t.UNumberPolicy,[Type],@year
	from (
			SELECT t.id,cd.PID,cd.UNumberPolicy,1 as [Type]
			from #t t inner join RegisterCases.dbo.t_Case c on
								t.GUID_Case=c.GUID_Case
								and c.DateEnd>=@dateStart
								and c.DateEnd<=@dateEnd
									inner join RegisterCases.dbo.t_RefCasePatientDefine rf on
								c.id=rf.rf_idCase
									inner join RegisterCases.dbo.t_CaseDefine cd on 
								rf.id=cd.rf_idRefCaseIteration
			where cd.PID IS NOT NULL			
			union all
			SELECT t.id,null,cf.UniqueNumberPolicy,2 as [Type]
			from #t t inner join RegisterCases.dbo.t_Case c on
					t.GUID_Case=c.GUID_Case
					and c.DateEnd>=@dateStart
					and c.DateEnd<=@dateEnd
						inner join RegisterCases.dbo.t_RefCasePatientDefine rf on
					c.id=rf.rf_idCase
						inner join RegisterCases.dbo.t_CaseDefineZP1Found cf on 
					rf.id=cf.rf_idRefCaseIteration	
			where cf.UniqueNumberPolicy is not null			
		) t
	ORDER BY ROW_NUMBER() OVER(PARTITION BY t.id ORDER BY t.[Type] )
end
drop table #t
GO