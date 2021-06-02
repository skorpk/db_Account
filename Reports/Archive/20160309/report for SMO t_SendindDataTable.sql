USE AccountOMS
GO
--SELECT COUNT(*) FROM t_SendingDataIntoFFOMS WHERE IsFullDoubleDate=1
SELECT s.rf_idCase,s.IDPeople,s.DS1,c.rf_idV006,1 AS Priz
INTO #tmp
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.tmp_PVTRecordDelete p ON
			f.CodeM=p.CodeM
			AND a.Account=p.Account
			AND c.idRecordCase=p.NumberCase
					INNER JOIN dbo.t_SendingDataIntoFFOMS s ON
			c.id=s.rf_idCase                  
WHERE f.DateRegistration>'20150101' AND a.ReportYear=2015

--DECLARE @codeSMO VARCHAR(5)='34001'
SELECT DISTINCT a.Account,a.DateRegister AS DateAccount,a.rf_idSMO,c.idRecordCase,ISNULL(s.SeriaPolis,'')+s.NumberPolis
		,CASE WHEN s.rf_idV005=1 THEN 'М' ELSE 'Ж' END AS [Пол],s.BirthDay,s.CodeM,l.NAMES AS [Наименование МО]
		,s.DateBegin,s.DateEnd, v6.name AS [Условия оказания],s.DS1,m.Diagnosis,v9.name,
		s.MES, csg.name,CAST(s.AmountPayment AS MONEY) AS [Сумма], s.IDPeople as PID, p.Fam+' '+p.Im+' '+ISNULL(p.Ot,'') AS FIo,r.NewBorn		
		,s.IsFullDoubleDate, DENSE_RANK() OVER (PARTITION BY s.IDPeople,s.DS1 ORDER BY c.DateBegin) AS PrizOfGroup
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient					  			
					INNER JOIN dbo.t_SendingDataIntoFFOMS s ON
			c.id=s.rf_idCase
					INNER JOIN #tmp t ON
			s.IDPeople=t.IDPeople
			AND s.DS1=t.DS1	
			AND s.rf_idV006=t.rf_idV006		                  
					INNER JOIN RegisterCases.dbo.vw_sprV006 v6 ON
			s.rf_idV006=v6.id                  
					INNER JOIN dbo.vw_sprMKB10 m ON
			s.DS1=m.DiagnosisCode   
					INNER JOIN RegisterCases.dbo.vw_sprV009 v9 ON
			s.rf_idV009=v9.id 
					INNER JOIN dbo.vw_sprCSG csg ON
		    s.MES=csg.code      
					INNER JOIN dbo.vw_sprT001 l ON
			s.CodeM=l.CodeM   					
					INNER JOIN dbo.t_RegisterPatient p on
			r.id=p.rf_idRecordCase
			AND f.id=p.rf_idFiles	
WHERE IsDisableCheck=0 AND s.rf_idV006=1
ORDER BY s.IDPeople,s.DS1, s.IsFullDoubleDate
go
DROP TABLE #tmp	
