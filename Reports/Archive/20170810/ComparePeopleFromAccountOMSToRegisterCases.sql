USE AccountOMS
go
DECLARE @dtStart DATETIME='20170101',
		@dtEnd DATETIME='20170711',
		@dtEndRAK DATETIME='20170711',
		@Year SMALLINT=2017,
		@month TINYINT=6 

SELECT DISTINCT f.CodeM,a.NumberRegister,a.ReportYear,c.GUID_Case,p.FAM,p.im,p.ot,p.BirthDay,a.ReportMonth,p.ID_Patient
INTO #tmpPeople
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles	
				INNER JOIN dbo.t_RecordCasePatient r ON
		a.id=r.rf_idRegistersAccounts				
				INNER JOIN dbo.t_Case c  ON
		r.id=c.rf_idRecordCasePatient				
				INNER JOIN dbo.vw_RegisterPatient p ON
		r.id=p.rf_idRecordCase
		AND f.id=p.rf_idFiles              
				INNER JOIN (values(66850389),(72452613),(67458687),(68840192),(72024878),(67030725),(67030656),(67458682)) v(rf_idCase) ON
		c.id=v.rf_idCase              
WHERE f.DateRegistration>=@dtStart AND f.DateRegistration<@dtEnd AND a.ReportYear=@Year AND a.ReportMonth<=@month AND a.rf_idSMO<>'34' AND c.DateEnd>=@dtStart AND c.DateEnd<@dtEnd
		AND c.rf_idV006=1


SELECT p.Fam,p.Im,p.Ot,p.BirthDay 
from RegisterCases.dbo.t_File f INNER JOIN RegisterCases.dbo.t_RegistersCase a ON
			f.id=a.rf_idFiles
					 inner join RegisterCases.dbo.t_RecordCase r on
			a.id=r.rf_idRegistersCase
						inner join RegisterCases.dbo.t_Case c on
			r.id=c.rf_idRecordCase 
						INNER JOIN RegisterCases.dbo.t_RefRegisterPatientRecordCase rf on
			r.id=rf.rf_idRecordCase
						INNER JOIN RegisterCases.dbo.t_RegisterPatient p ON
			rf.rf_idRegisterPatient=p.id
			AND f.id=p.rf_idFiles
						INNER JOIN #tmpPeople pp ON
			f.CodeM=pp.CodeM
			AND a.NumberRegister=pp.NumberRegister
			AND a.ReportYear=pp.ReportYear
			AND a.ReportMonth=pp.ReportMonth
			AND c.GUID_Case=c.GUID_Case	
			AND p.ID_Patient=pp.ID_Patient	
WHERE p.BirthDay<>pp.BirthDay			                      
GO
DROP TABLE #tmpPeople