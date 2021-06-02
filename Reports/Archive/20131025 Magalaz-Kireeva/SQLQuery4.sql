USE AccountOMS
GO
ALTER VIEW vw_MagalazKireeva_34001
as
SELECT a.Account,a.DateRegister
		,c.idRecordCase,d.DS1,mkb10.Diagnosis,CAST(c.AmountPayment AS MONEY) AS AmountPayment,v2.name AS V002
		,0 AS Tariff,c.NumberHistoryCase,c.DateBegin,c.DateEnd,v9.name AS RSLT,v12.name AS ISHOD,v4.name AS PRVS
		,ISNULL(p.Fam+' '+p.Im+' '+p.Ot,'Неизвестно') AS Fio,p.Sex,p.BirthDay,c.Age,r.NumberPolis,r.AttachLPU
		,m.MU, mu.MUName, CAST(m.Quantity AS MONEY) AS Quantity,CAST(m.Price AS MONEY) AS Price,m.DateHelpBegin,m.DateHelpEnd
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles				
			AND  a.rf_idSMO='34001'
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
				INNER JOIN dbo.t_Meduslugi m on
			c.id=m.rf_idCase	  		
					INNER JOIN dbo.vw_sprMU mu ON
			m.MUGroupCode=mu.MUGroupCode
			AND m.MUUnGroupCode=mu.MUUnGroupCode
			AND m.MUCode=mu.MUCode
WHERE f.CodeM='115309' AND c.Age<18 AND m.DateHelpBegin>='20130101' AND m.DateHelpBegin<='20131231 23:59:59'
GO
ALTER VIEW vw_MagalazKireeva_34002
as
SELECT a.Account,a.DateRegister
		,c.idRecordCase,d.DS1,mkb10.Diagnosis,CAST(c.AmountPayment AS MONEY) AS AmountPayment,v2.name AS V002
		,0 AS Tariff,c.NumberHistoryCase,c.DateBegin,c.DateEnd,v9.name AS RSLT,v12.name AS ISHOD,v4.name AS PRVS
		,ISNULL(p.Fam+' '+p.Im+' '+p.Ot,'Неизвестно') AS Fio,p.Sex,p.BirthDay,c.Age,r.NumberPolis,r.AttachLPU
		,m.MU, mu.MUName, CAST(m.Quantity AS MONEY) AS Quantity,CAST(m.Price AS MONEY) AS Price,m.DateHelpBegin,m.DateHelpEnd
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles				
			AND  a.rf_idSMO='34002'
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
				INNER JOIN dbo.t_Meduslugi m on
			c.id=m.rf_idCase	  		
					INNER JOIN dbo.vw_sprMU mu ON
			m.MUGroupCode=mu.MUGroupCode
			AND m.MUUnGroupCode=mu.MUUnGroupCode
			AND m.MUCode=mu.MUCode
WHERE f.CodeM='155307' AND c.Age<18 AND m.DateHelpBegin>='20130101' AND m.DateHelpBegin<='20131231 23:59:59'
GO