USE AccountOMS
go
DECLARE @dtStart DATETIME='20160623',
		@dtEnd DATETIME='20161208',
		@codeSMO CHAR(5)='34006'
SELECT a.Account
		,a.DateRegister
		,c.idRecordCase
		,ISNULL(p.Fam+' '+p.Im+' '+p.Ot,'Неизвестно') AS Fio
		,p.Sex,p.BirthDay,c.Age
		,c.DateBegin
		,c.DateEnd
		,d.DS1
		,mkb10.Diagnosis
		,v6.name AS Usl_OK
		,v8.name AS VidMP
		,f.CodeM
		,l.NameS AS LPU
		,CAST(c.AmountPayment AS MONEY) AS AmountPayment
		,CASE WHEN c.HopitalisationType=1 THEN 'плановая' ELSE 'экстренная' END AS TypeHosp
		,v2.name AS Profil
		,0 AS Tariff
		,c.NumberHistoryCase		
		,v9.name AS RSLT
		,v12.name AS ISHOD		
		,ISNULL(r.SeriaPolis,'') AS SeriaPolis
		,r.NumberPolis
		,r.AttachLPU
		,c.rf_idDoctor
		,v4.name AS PRVS
		,v10.name AS IDSP
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles				
			AND  a.rf_idSMO=@codeSMO
				INNER JOIN dbo.t_RecordCasePatient r ON
		a.id=r.rf_idRegistersAccounts
				INNER JOIN dbo.t_RegisterPatient p ON
		r.id=p.rf_idRecordCase
		AND f.id=p.rf_idFiles				
				INNER JOIN dbo.t_Case c  ON
		r.id=c.rf_idRecordCasePatient	
				INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase
				INNER JOIN dbo.vw_sprMKB10 mkb10 ON
		d.DS1=mkb10.DiagnosisCode			
				INNER JOIN RegisterCases.dbo.vw_sprV009 v9 ON
		c.rf_idV009=v9.id
				INNER JOIN RegisterCases.dbo.vw_sprV012 v12 ON
		c.rf_idV012=v12.id		
				INNER JOIN RegisterCases.dbo.vw_sprV004 v4 ON
		c.rf_idV004=v4.id		
				INNER JOIN RegisterCases.dbo.vw_sprV002 v2 ON
		c.rf_idV002=v2.id
				INNER JOIN RegisterCases.dbo.vw_sprV006 v6 ON
		c.rf_idv006=v6.id 
				INNER JOIN RegisterCases.dbo.vw_sprv08 v8 ON
		c.rf_idV008=v8.ID             
				INNER JOIN RegisterCases.dbo.vw_sprT001 l ON
		f.CodeM=l.CodeM 
				INNER JOIN RegisterCases.dbo.vw_sprV010 v10 ON
		c.rf_idV010=v10.id             				
WHERE f.DateRegistration>@dtStart AND f.DateRegistration<@dtEnd