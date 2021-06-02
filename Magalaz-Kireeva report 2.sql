USE AccountOMS
GO
CREATE TABLE #t(PID INT,idCase BIGINT,idPatient INT,DateBegin DATETIME,DateEnd DATETIME)

INSERT #t( PID ,idCase ,idPatient ,DateBegin ,DateEnd)
SELECT pid.PID,c.id,p.id,DATEADD(dd,-3,c.DateBegin),DATEADD(dd,3,c.DateEnd)
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
					f.id=a.rf_idFiles
							INNER JOIN (VALUES(1),(2),(3),(4),(5),(6)) v(m) ON
					a.ReportMonth=v.m					
						  INNER JOIN dbo.t_RecordCasePatient r ON
					a.id=r.rf_idRegistersAccounts
						  INNER JOIN dbo.t_RegisterPatient p ON
					f.id=p.rf_idFiles
					AND r.id=p.rf_idRecordCase
						  INNER JOIN dbo.t_Case c ON
					r.id=c.rf_idRecordCasePatient
					AND c.DateEnd>='20130101'
					AND c.DateEnd<'20130701'		
						INNER JOIN dbo.t_Case_PID_ENP pid on
					pid.rf_idCase=c.id																							  						  
WHERE f.DateRegistration>='20130101' AND f.DateRegistration<'20130701' AND a.ReportYear=2013 AND f.CodeM='104401' AND c.rf_idMO='104401'
	AND c.rf_idV006=1
		
SELECT *
FROM (
SELECT distinct a.Account,a.DateRegister
	   ,c.idRecordCase AS NumberCase
	   ,d.DS1,mkb10.Diagnosis
	  ,v006.name AS V006
	  ,c.AmountPayment
	  ,v002.name AS V002
	  ,c.NumberHistoryCase
	  ,c.DateBegin,c.DateEnd
	  ,v009.name as V009
	  ,v012.name AS V012,v004.name as V004
	  ,p.Fam+' '+p.Im+' '+ISNULL(p.Ot,'') AS FIO,p.Sex
	  ,p.BirthDay,c.Age
	  ,r.NumberPolis	  
	  ,t.DateBegin AS DateBeginTMP,t.DateEnd AS DateEndTMP
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
					f.id=a.rf_idFiles
							INNER JOIN (VALUES(1),(2),(3),(4),(5),(6)) v(m) ON
					a.ReportMonth=v.m					
						  INNER JOIN dbo.t_RecordCasePatient r ON
					a.id=r.rf_idRegistersAccounts
						  INNER JOIN dbo.t_RegisterPatient p ON
					f.id=p.rf_idFiles
					AND r.id=p.rf_idRecordCase					
						  INNER JOIN dbo.t_Case c ON
					r.id=c.rf_idRecordCasePatient					
						INNER JOIN dbo.t_Case_PID_ENP pid on
					pid.rf_idCase=c.id	
						INNER JOIN #t t ON
					pid.PID=t.PID
						INNER JOIN RegisterCases.dbo.vw_sprV006 v006 ON
					c.rf_idV006=v006.id
						INNER JOIN RegisterCases.dbo.vw_sprV009 v009 ON
					c.rf_idV009=v009.id
						INNER JOIN RegisterCases.dbo.vw_sprV012 v012 ON
					c.rf_idV012=v012.id
							INNER JOIN RegisterCases.dbo.vw_sprV004 v004 ON
					c.rf_idV004=v004.id				
							INNER JOIN dbo.vw_Diagnosis d ON
					c.id=d.rf_idCase
						INNER JOIN dbo.vw_sprMKB10 mkb10 ON
					d.DS1=mkb10.DiagnosisCode	
						INNER JOIN dbo.t_Meduslugi m ON
					c.id=m.rf_idCase		 
						INNER JOIN RegisterCases.dbo.vw_sprV002 v002 ON
					m.rf_idV002=v002.id					
							INNER JOIN dbo.vw_sprMUAll mu ON
					m.MU=mu.MU 
WHERE f.DateRegistration>='20130101' AND f.DateRegistration<'20130701' AND a.ReportYear=2013 AND f.CodeM='104401' AND c.rf_idMO='104401'
		AND m.MUGroupCode=60 AND m.MUUnGroupCode=2 AND MUCode IN (3,4) AND c.rf_idV006=3-- AND c.id<>t.idCase 
	) t
WHERE t.DateBeginTMP<=t.DateBegin AND t.DateBegin<=t.DateEndTMP

		
GO
DROP TABLE #t