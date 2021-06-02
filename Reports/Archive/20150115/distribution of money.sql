USE AccountOMS
GO
DECLARE @dateStart DATETIME='20140101',
		@dateEnd DATETIME='20150116'

SELECT l.filialName,t.CodeM,l.Names,l.pfa,SUM(Col5),SUM(Col6),SUM(Col7),SUM(Col8),SUM(Col9),SUM(Col10),SUM(Col11),SUM(Col12),SUM(Col13)
FROM (
	SELECT f.CodeM,SUM(c.AmountPayment) AS Col5,0.0 AS Col6,0.0 AS Col7,0.0 AS Col8,0.0 AS Col9,0.0 AS Col10,0.0 AS Col11,0.0 AS Col12,0.0 AS Col13
	FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
				f.id=a.rf_idFiles			
						INNER JOIN (VALUES('G')) l(Letter) ON
				a.Letter=l.Letter
						INNER JOIN dbo.t_RecordCasePatient r ON
				a.id=r.rf_idRegistersAccounts
						INNER JOIN dbo.t_Case c ON
				r.id=c.rf_idRecordCasePatient						
	WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2014 AND c.rf_idV006=3 
	GROUP BY f.CodeM
	UNION ALL
	SELECT f.CodeM,0.0 AS Col5,SUM(c.AmountPayment) AS Col6,0.0 AS Col7,0.0 AS Col8,0.0 AS Col9,0.0 AS Col10,0.0 AS Col11,0.0 AS Col12,0.0 AS Col13
	FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
				f.id=a.rf_idFiles			
						INNER JOIN (VALUES('T')) l(Letter) ON
				a.Letter=l.Letter					
						INNER JOIN dbo.t_RecordCasePatient r ON
				a.id=r.rf_idRegistersAccounts
						INNER JOIN dbo.t_Case c ON
				r.id=c.rf_idRecordCasePatient	
	WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2014 AND c.rf_idV006=3 
	GROUP BY f.CodeM
	UNION ALL
	SELECT f.CodeM,0.0 AS Col5,0.0 AS Col6,SUM(c.AmountPayment) AS Col7,0.0 AS Col8,0.0 AS Col9,0.0 AS Col10,0.0 AS Col11,0.0 AS Col12,0.0 AS Col13
	FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
				f.id=a.rf_idFiles			
						INNER JOIN (VALUES('D'),('U'),('O'),('R'),('F'),('I'),('V') ) l(Letter) ON
				a.Letter=l.Letter				
						INNER JOIN dbo.t_RecordCasePatient r ON
				a.id=r.rf_idRegistersAccounts
						INNER JOIN dbo.t_Case c ON
				r.id=c.rf_idRecordCasePatient		
	WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2014 AND c.rf_idV006=3 
	GROUP BY f.CodeM
	UNION ALL
	SELECT f.CodeM,0.0 AS Col5,0.0 AS Col6,0.0 AS Col7,SUM(c.AmountPayment) AS Col8,0.0 AS Col9,0.0 AS Col10,0.0 AS Col11,0.0 AS Col12,0.0 AS Col13
	FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
				f.id=a.rf_idFiles			
						INNER JOIN (VALUES('K')) l(Letter) ON
				a.Letter=l.Letter					
						INNER JOIN dbo.t_RecordCasePatient r ON
				a.id=r.rf_idRegistersAccounts
						INNER JOIN dbo.t_Case c ON
				r.id=c.rf_idRecordCasePatient	
	WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2014 AND c.rf_idV006=3 
	GROUP BY f.CodeM
	UNION ALL
	SELECT f.CodeM,0.0 AS Col5,0.0 AS Col6,0.0 AS Col7,0.0 AS Col8,SUM(c.AmountPayment) AS Col9,0.0 AS Col10,0.0 AS Col11,0.0 AS Col12,0.0 AS Col13
	FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
				f.id=a.rf_idFiles			
						INNER JOIN (VALUES('A'),('J') ) l(Letter) ON
				a.Letter=l.Letter				
						INNER JOIN dbo.t_RecordCasePatient r ON
				a.id=r.rf_idRegistersAccounts
						INNER JOIN dbo.t_Case c ON
				r.id=c.rf_idRecordCasePatient	
	WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2014 AND c.rf_idV006=3 
			AND EXISTS(SELECT * FROM dbo.t_Meduslugi WHERE rf_idCase=c.id AND MUGroupCode=2 AND MUUnGroupCode=76)
	GROUP BY f.CodeM		
	UNION ALL
	SELECT f.CodeM,0.0 AS Col5, 0.0 AS Col6, 0.0 AS Col7, 0.0 AS Col8, 0.0 AS Col9,SUM(c.AmountPayment) AS Col10, 0.0 AS Col11, 0.0 AS Col12, 0.0 AS Col13
	FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
				f.id=a.rf_idFiles			
						INNER JOIN (VALUES('A'),('J') ) l(Letter) ON
				a.Letter=l.Letter				
						INNER JOIN dbo.t_RecordCasePatient r ON
				a.id=r.rf_idRegistersAccounts
						INNER JOIN dbo.t_Case c ON
				r.id=c.rf_idRecordCasePatient	
	WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2014 AND c.rf_idV006=3 
			AND EXISTS(SELECT rf_idCase 
						FROM dbo.t_Meduslugi m INNER JOIN (VALUES('2.80.5'), ('2.80.16'), ('2.88.27'), ('2.88.38'), ('2.82.4')) v(MU) ON
										m.MU=v.MU									
						WHERE rf_idCase=c.id 
						UNION ALL
						SELECT rf_idCase
						FROM dbo.t_MES m INNER JOIN ( VALUES ('2.78.30'),('2.78.21')) v(MU) ON
										m.MES=v.MU
						WHERE m.rf_idCase=c.id									
						)	
	GROUP BY f.CodeM
	UNION ALL
	SELECT f.CodeM,0.0 AS Col5,0.0 AS Col6,0.0 AS Col7,0.0 AS Col8,0.0 AS Col9,0.0 AS Col10,SUM(c.AmountPayment) AS Col11,0.0 AS Col12,0.0 AS Col13
	FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
				f.id=a.rf_idFiles			
						INNER JOIN (VALUES('A'),('J') ) l(Letter) ON
				a.Letter=l.Letter				
						INNER JOIN dbo.t_RecordCasePatient r ON
				a.id=r.rf_idRegistersAccounts
						INNER JOIN dbo.t_Case c ON
				r.id=c.rf_idRecordCasePatient	
	WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2014 AND c.rf_idV006=3 
			AND EXISTS(SELECT rf_idCase 
						FROM dbo.t_Meduslugi m INNER JOIN (VALUES('2.79.13'), ('2.80.8'), ('2.79.47'), ('2.88.33'), ('2.79.49'), ('2.82.7') ) v(MU) ON
										m.MU=v.MU									
						WHERE rf_idCase=c.id 
						UNION ALL
						SELECT rf_idCase
						FROM dbo.t_MES m INNER JOIN ( VALUES ('2.78.26')) v(MU) ON
										m.MES=v.MU									
						WHERE m.rf_idCase=c.id									
						)								
	GROUP BY f.CodeM
	UNION ALL
	SELECT f.CodeM,0.0 AS Col5,0.0 AS Col6,0.0 AS Col7,0.0 AS Col8,0.0 AS Col9,0.0 AS Col10,0.0 AS Col11,SUM(c.AmountPayment) AS Col12,0.0 AS Col13
	FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
				f.id=a.rf_idFiles			
						INNER JOIN (VALUES('A'),('J') ) l(Letter) ON
				a.Letter=l.Letter				
						INNER JOIN dbo.t_RecordCasePatient r ON
				a.id=r.rf_idRegistersAccounts
						INNER JOIN dbo.t_Case c ON
				r.id=c.rf_idRecordCasePatient	
	WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2014 AND c.rf_idV006=3 
			AND EXISTS(SELECT * FROM dbo.t_Meduslugi WHERE rf_idCase=c.id AND MUGroupCode=2 AND MUUnGroupCode=81)
	GROUP BY f.CodeM
	UNION ALL
	SELECT f.CodeM,0.0 AS Col5, 0.0 AS Col6, 0.0 AS Col7, 0.0 AS Col8, 0.0 AS Col9, 0.0 AS Col10, 0.0 AS Col11, 0.0 AS Col12, SUM(c.AmountPayment) AS Col13
	FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
				f.id=a.rf_idFiles			
						INNER JOIN (VALUES('A'),('J') ) l(Letter) ON
				a.Letter=l.Letter				
						INNER JOIN dbo.t_RecordCasePatient r ON
				a.id=r.rf_idRegistersAccounts
						INNER JOIN dbo.t_Case c ON
				r.id=c.rf_idRecordCasePatient	
	WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2014 AND c.rf_idV006=3 
			AND EXISTS(SELECT * FROM dbo.t_MES WHERE rf_idCase=c.id AND MES LIKE '2.89.*')	
	GROUP BY f.CodeM
) t INNER JOIN vw_sprT001 l on			
	t.CodeM=l.CodeM
GROUP BY l.filialName,t.CodeM,l.Names,l.pfa	