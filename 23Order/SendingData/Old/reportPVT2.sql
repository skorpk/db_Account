USE AccountOMS
GO

---------------------------------------стационар-----------------------------------------------
DECLARE @typeV6 TINYINT=1
SELECT DISTINCT a.Account,c.idRecordCase,ISNULL(s.SeriaPolis,'')+s.NumberPolis,s.ENP
		,CASE WHEN s.rf_idV005=1 THEN 'М' ELSE 'Ж' END AS [Пол],s.BirthDay,s.CodeM,l.NAMES AS [Наименование МО]
		,s.DateBegin,s.DateEnd, v6.name AS [Условия оказания],s.DS1,m.Diagnosis,v9.name,
		s.MES, csg.name,CAST(s.AmountPayment AS MONEY) AS [Сумма], s.PVT,s.IDPeople as PID, p.Fam+' '+p.Im+' '+ISNULL(p.Ot,'') AS FIo,r.NewBorn,
		DENSE_RANK() OVER (PARTITION BY s.ENP,s.DS1 ORDER BY c.DateBegin) AS Priz,c.id, CASE WHEN s.IsUnload=1 THEN 'В' ELSE 'Н' END 		
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_SendingDataIntoFFOMS s ON
			c.id=s.rf_idCase  
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
					INNER JOIN (select p.rf_idRecordCase,p.id,p.rf_idFiles,p.ID_Patient
									,case when UPPER(isnull(p.Fam,'НЕТ'))='НЕТ' then pa.Fam else p.Fam end as FAM
									,case when UPPER(isnull(p.Im ,'НЕТ'))='НЕТ' then pa.Im else p.Im end as Im
									,case when UPPER(isnull(p.Fam,'НЕТ'))='НЕТ' then pa.Ot else p.Ot end Ot									
								from t_RegisterPatient p INNER JOIN t_RegisterPatientAttendant pa on
										p.id=pa.rf_idRegisterPatient	
								union all
								select p.rf_idRecordCase,p.id,p.rf_idFiles,p.ID_Patient,p.Fam as FAM,p.Im as Im	,p.Ot as Ot	
								from t_RegisterPatient p WITH(INDEX(IX_PVT_FIO)) 
								WHERE NOT EXISTS(SELECT * FROM t_RegisterPatientAttendant pa WHERE pa.rf_idRegisterPatient=p.id)
							)p on
			r.id=p.rf_idRecordCase
			AND f.id=p.rf_idFiles	
WHERE s.rf_idV006=@typeV6 AND IsDisableCheck=0  /*AND IsUnload=0*/ AND IsFullDoubleDate=0
	AND EXISTS(SELECT * FROM dbo.t_SendingDataIntoFFOMS WHERE rf_idV006=s.rf_idV006 and ENP=s.ENP AND DS1=s.DS1 AND PVT>0)
ORDER BY ENP,s.DateBegin
------------------------------------------------дневной стационар----------------------------------------------------------------------
set @typeV6 =2
SELECT DISTINCT a.Account,c.idRecordCase,ISNULL(s.SeriaPolis,'')+s.NumberPolis,s.ENP
		,CASE WHEN s.rf_idV005=1 THEN 'М' ELSE 'Ж' END AS [Пол],s.BirthDay,s.CodeM,l.NAMES AS [Наименование МО]
		,s.DateBegin,s.DateEnd, v6.name AS [Условия оказания],s.DS1,m.Diagnosis,v9.name,
		s.MES, csg.name,CAST(s.AmountPayment AS MONEY) AS [Сумма], s.PVT,s.IDPeople as PID, p.Fam+' '+p.Im+' '+ISNULL(p.Ot,'') AS FIo,r.NewBorn,
		DENSE_RANK() OVER (PARTITION BY s.ENP,s.DS1 ORDER BY c.DateBegin) AS Priz,c.id, CASE WHEN s.IsUnload=1 THEN 'В' ELSE 'Н' END 		
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_SendingDataIntoFFOMS s ON
			c.id=s.rf_idCase  
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
					INNER JOIN (select p.rf_idRecordCase,p.id,p.rf_idFiles,p.ID_Patient
									,case when UPPER(isnull(p.Fam,'НЕТ'))='НЕТ' then pa.Fam else p.Fam end as FAM
									,case when UPPER(isnull(p.Im ,'НЕТ'))='НЕТ' then pa.Im else p.Im end as Im
									,case when UPPER(isnull(p.Fam,'НЕТ'))='НЕТ' then pa.Ot else p.Ot end Ot									
								from t_RegisterPatient p INNER JOIN t_RegisterPatientAttendant pa on
										p.id=pa.rf_idRegisterPatient	
								union all
								select p.rf_idRecordCase,p.id,p.rf_idFiles,p.ID_Patient,p.Fam as FAM,p.Im as Im	,p.Ot as Ot	
								from t_RegisterPatient p WITH(INDEX(IX_PVT_FIO)) 
								WHERE NOT EXISTS(SELECT * FROM t_RegisterPatientAttendant pa WHERE pa.rf_idRegisterPatient=p.id)
							)p on
			r.id=p.rf_idRecordCase
			AND f.id=p.rf_idFiles	
WHERE s.rf_idV006=@typeV6 AND IsDisableCheck=0  /*AND IsUnload=0*/ AND IsFullDoubleDate=0
	AND EXISTS(SELECT * FROM dbo.t_SendingDataIntoFFOMS WHERE rf_idV006=s.rf_idV006 and ENP=s.ENP AND DS1=s.DS1 AND PVT>0)
ORDER BY ENP,s.DateBegin