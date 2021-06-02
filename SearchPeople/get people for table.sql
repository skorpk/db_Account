USE AccountOMS
GO

SELECT rf_idCase,Fam,IM,Ot,DR,ENP,DENSE_RANK() OVER (ORDER BY t.FAM, t.IM, t.Ot,t.DR,t.ENP) AS IDPeople
INTO #tmp
FROM (
		SELECT ce.rf_idCase,p.FAM,p.IM,ISNULL(p.OT,'') AS Ot,p.DR,p.ENP
		FROM dbo.t_Case_PID_ENP ce INNER JOIN PolicyRegister.dbo.PEOPLE p ON
						ce.PID=p.ID
		WHERE ce.ReportYear>2014 AND ce.PID IS NOT NULL
		UNION ALL
		SELECT ce.rf_idCase,p.FAM,p.IM,ISNULL(p.OT,''),p.DR,p.ENP
		FROM dbo.t_Case_PID_ENP ce INNER JOIN PolicyRegister.dbo.PEOPLE p ON
						ce.ENP=p.ENP
		WHERE ce.ReportYear>2014 AND ce.PID IS NULL
		UNION ALL
		SELECT ce.rf_idCase,p.FAM,p.IM,p.OT,p.DR,pe.ENP
		FROM dbo.t_Case_PID_ENP ce INNER JOIN PolicyRegister.dbo.HISTENP pe ON
						ce.ENP=pe.ENP
									INNER JOIN PolicyRegister.dbo.PEOPLE p ON
						pe.PID=p.ID                          
		WHERE ce.ReportYear>2014
		UNION ALL
		SELECT c.id,rp.Fam , rp.Im, ISNULL(rp.Ot,'НЕТ') ,rp.BirthDay,r.NumberPolis
		FROM dbo.t_Case c INNER JOIN dbo.t_RecordCasePatient r ON 
						c.rf_idRecordCasePatient = r.id 
								INNER JOIN dbo.t_RegistersAccounts a ON 
						r.rf_idRegistersAccounts = a.id 
								INNER JOIN dbo.t_File f ON 
						a.rf_idFiles = f.id 
								INNER JOIN dbo.t_RegisterPatient rp ON 
						r.id = rp.rf_idRecordCase												
		WHERE c.DateEnd>'20150101' AND a.rf_idSMO='34' AND NOT EXISTS(SELECT * FROM dbo.t_Case_PID_ENP WHERE rf_idCase=c.id)
	) t
---------------------Проверки--------------------------------
--;WITH cteFIO
--AS(
--	SELECT FAM,IM,Ot,DR FROM #tmp GROUP BY FAM,IM,Ot,DR HAVING COUNT(*)>1
--	)
--SELECT t.*
--FROM cteFIO f INNER JOIN #tmp t ON
--		f.Fam=t.Fam
--		AND f.IM=t.IM
--		AND f.Ot=t.Ot
--		AND f.Dr=t.Dr

--SELECT c.GUID_Case,c.id, a.ReportYear
--FROM dbo.t_Case c INNER JOIN dbo.t_RecordCasePatient r ON 
--					c.rf_idRecordCasePatient = r.id 
--							INNER JOIN dbo.t_RegistersAccounts a ON 
--					r.rf_idRegistersAccounts = a.id 
--							INNER JOIN dbo.t_File f ON 
--					a.rf_idFiles = f.id 
--WHERE DateEnd>'20141231' and NOT EXISTS(SELECT * FROM #tmp WHERE rf_idCase=c.id)

--DROP TABLE  PolicyRegister.dbo.tmpWrongPID
/*
SELECT DISTINCT ce.PID
FROM dbo.t_Case c INNER JOIN dbo.t_RecordCasePatient r ON 
					c.rf_idRecordCasePatient = r.id 
							INNER JOIN dbo.t_RegistersAccounts a ON 
					r.rf_idRegistersAccounts = a.id 
							INNER JOIN dbo.t_File f ON 
					a.rf_idFiles = f.id 
							INNER JOIN dbo.t_Case_PID_ENP ce ON
					c.id=ce.rf_idCase 
							INNER JOIN dbo.t_RegisterPatient rp ON 
					r.id = rp.rf_idRecordCase                         
WHERE DateEnd>'20141231' AND a.ReportYear>2014 and NOT EXISTS(SELECT * FROM #tmp WHERE rf_idCase=c.id) AND ce.PID IS NOT NULL
---------------------------------------------------------------------------

DECLARE @year char(4)=2015
declare @dateStart datetime=@year+'0101',
		@dateEnd datetime=GETDATE()

create table #t
(
	GUID_Case uniqueidentifier,
	id bigint
)

insert #t
SELECT c.GUID_Case,c.id--f.CodeM,a.Account,COUNT(c.id),a.ReportYear,f.DateRegistration 
FROM dbo.t_Case c INNER JOIN dbo.t_RecordCasePatient r ON 
					c.rf_idRecordCasePatient = r.id 
							INNER JOIN dbo.t_RegistersAccounts a ON 
					r.rf_idRegistersAccounts = a.id 
							INNER JOIN dbo.t_File f ON 
					a.rf_idFiles = f.id 
WHERE DateEnd>'20141231' and NOT EXISTS(SELECT * FROM #tmp WHERE rf_idCase=c.id) --AND f.CodeM='114506' AND a.Account='34001-194-1O'
--GROUP BY f.CodeM,a.Account,a.ReportYear,f.DateRegistration


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

DROP TABLE #t
*/
DROP TABLE #tmp