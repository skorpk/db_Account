USE AccountOMS
GO
DECLARE @dateStart DATETIME='20140101',
		@dateEnd DATETIME='20150116'

CREATE TABLE #t (CodeM CHAR(6),
				 Col5 DECIMAL(11,2) NOT NULL DEFAULT(0),
				 Col6 DECIMAL(11,2) NOT NULL DEFAULT(0),
				 Col7 DECIMAL(11,2) NOT NULL DEFAULT(0),
				 Col8 DECIMAL(11,2) NOT NULL DEFAULT(0),
				 Col9 DECIMAL(11,2) NOT NULL DEFAULT(0),
				 Col10 DECIMAL(11,2) NOT NULL DEFAULT(0),
				 Col11 DECIMAL(11,2) NOT NULL DEFAULT(0),
				 Col12 DECIMAL(11,2) NOT NULL DEFAULT(0),
				 Col13 DECIMAL(11,2) NOT NULL DEFAULT(0),
				 Col14 DECIMAL(11,2) NOT NULL DEFAULT(0),
				 AttachLPU CHAR(6)
				 )
				 

--------Column 5--------------
	INSERT #t( CodeM ,Col5,AttachLPU )
	SELECT f.CodeM,SUM(c.AmountPayment),r.AttachLPU
	FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
				f.id=a.rf_idFiles	
				AND a.rf_idSMO<>'34'		
						INNER JOIN (VALUES('G')) l(Letter) ON
				a.Letter=l.Letter
						INNER JOIN dbo.t_RecordCasePatient r ON
				a.id=r.rf_idRegistersAccounts
						INNER JOIN dbo.t_Case c ON
				r.id=c.rf_idRecordCasePatient						
	WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2014 AND c.rf_idV006=3 
	GROUP BY f.CodeM,r.AttachLPU
--------Column 6--------------
	INSERT #t( CodeM ,Col6,AttachLPU )
	SELECT f.CodeM,SUM(c.AmountPayment),r.AttachLPU
	FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
				f.id=a.rf_idFiles			
				AND a.rf_idSMO<>'34'		
						INNER JOIN (VALUES('T')) l(Letter) ON
				a.Letter=l.Letter					
						INNER JOIN dbo.t_RecordCasePatient r ON
				a.id=r.rf_idRegistersAccounts
						INNER JOIN dbo.t_Case c ON
				r.id=c.rf_idRecordCasePatient	
	WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2014 AND c.rf_idV006=3 
	Group by f.CodeM,r.AttachLPU
--------Column 7--------------	
	INSERT #t( CodeM ,Col7,AttachLPU )
	SELECT f.CodeM,SUM(c.AmountPayment),r.AttachLPU 
	FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
				f.id=a.rf_idFiles			
				AND a.rf_idSMO<>'34'		
						INNER JOIN (VALUES('D'),('U'),('O'),('R'),('F'),('I'),('V') ) l(Letter) ON
				a.Letter=l.Letter				
						INNER JOIN dbo.t_RecordCasePatient r ON
				a.id=r.rf_idRegistersAccounts
						INNER JOIN dbo.t_Case c ON
				r.id=c.rf_idRecordCasePatient		
	WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2014 AND c.rf_idV006=3 
	Group by f.CodeM,r.AttachLPU
	--------Column 8--------------
	INSERT #t( CodeM ,Col8,AttachLPU )
	SELECT f.CodeM,SUM(c.AmountPayment),r.AttachLPU 
	FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
				f.id=a.rf_idFiles	
				AND a.rf_idSMO<>'34'				
						INNER JOIN (VALUES('K')) l(Letter) ON
				a.Letter=l.Letter					
						INNER JOIN dbo.t_RecordCasePatient r ON
				a.id=r.rf_idRegistersAccounts
						INNER JOIN dbo.t_Case c ON
				r.id=c.rf_idRecordCasePatient	
	WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2014 AND c.rf_idV006=3 
	Group by f.CodeM,r.AttachLPU
	--------Column 9--------------
	INSERT #t( CodeM ,Col9 ,AttachLPU)
	SELECT f.CodeM,SUM(c.AmountPayment),r.AttachLPU 
	FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
				f.id=a.rf_idFiles
				AND a.rf_idSMO<>'34'					
						INNER JOIN (VALUES('A'),('J') ) l(Letter) ON
				a.Letter=l.Letter				
						INNER JOIN dbo.t_RecordCasePatient r ON
				a.id=r.rf_idRegistersAccounts
						INNER JOIN dbo.t_Case c ON
				r.id=c.rf_idRecordCasePatient	
	WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2014 AND c.rf_idV006=3 
			AND EXISTS(SELECT * FROM dbo.t_Meduslugi WHERE rf_idCase=c.id AND MUGroupCode=2 AND MUUnGroupCode=76)
	Group by f.CodeM,r.AttachLPU		
	--------Column 10--------------
	INSERT #t( CodeM ,Col10,AttachLPU )
	SELECT f.CodeM,SUM(c.AmountPayment),r.AttachLPU
	FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
				f.id=a.rf_idFiles	
				AND a.rf_idSMO<>'34'				
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
	Group by f.CodeM,r.AttachLPU
	--------Column 11--------------
	INSERT #t( CodeM ,Col11,AttachLPU )
	SELECT f.CodeM,SUM(c.AmountPayment),r.AttachLPU
	FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
				f.id=a.rf_idFiles
				AND a.rf_idSMO<>'34'					
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
	Group by f.CodeM,r.AttachLPU
	--------Column 12--------------
	INSERT #t( CodeM ,Col12,AttachLPU )
	SELECT f.CodeM,SUM(c.AmountPayment),r.AttachLPU
	FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
				f.id=a.rf_idFiles
				AND a.rf_idSMO<>'34'					
						INNER JOIN (VALUES('A'),('J') ) l(Letter) ON
				a.Letter=l.Letter				
						INNER JOIN dbo.t_RecordCasePatient r ON
				a.id=r.rf_idRegistersAccounts
						INNER JOIN dbo.t_Case c ON
				r.id=c.rf_idRecordCasePatient	
	WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2014 AND c.rf_idV006=3 
			AND EXISTS(SELECT * FROM dbo.t_Meduslugi WHERE rf_idCase=c.id AND MUGroupCode=2 AND MUUnGroupCode=81)
	Group by f.CodeM,r.AttachLPU
	--------Column 13--------------
	INSERT #t( CodeM ,Col13,AttachLPU )
	SELECT f.CodeM,SUM(c.AmountPayment),r.AttachLPU
	FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
				f.id=a.rf_idFiles			
				AND a.rf_idSMO<>'34'		
						INNER JOIN (VALUES('A'),('J') ) l(Letter) ON
				a.Letter=l.Letter				
						INNER JOIN dbo.t_RecordCasePatient r ON
				a.id=r.rf_idRegistersAccounts
						INNER JOIN dbo.t_Case c ON
				r.id=c.rf_idRecordCasePatient	
	WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2014 AND c.rf_idV006=3 
			AND EXISTS(SELECT * FROM dbo.t_MES WHERE rf_idCase=c.id AND MES LIKE '2.89.*')	
	Group by f.CodeM,r.AttachLPU
	
	--------Column 14--------------
	INSERT #t( CodeM ,Col14,AttachLPU )
	SELECT f.CodeM,SUM(c.AmountPayment),r.AttachLPU 
	FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
				f.id=a.rf_idFiles	
				AND a.rf_idSMO<>'34'				
						INNER JOIN (VALUES('A')) l(Letter) ON
				a.Letter=l.Letter				
						INNER JOIN dbo.t_RecordCasePatient r ON
				a.id=r.rf_idRegistersAccounts
						INNER JOIN dbo.t_Case c ON
				r.id=c.rf_idRecordCasePatient	
	WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2014 AND c.rf_idV006=3 
	Group by f.CodeM,r.AttachLPU
SELECT l.filialName,t.CodeM,l.Names,l.pfa
		,CAST(SUM(Col5) AS MONEY)
		,CAST(SUM(Col6) AS MONEY)
		,CAST(SUM(Col7) AS MONEY)
		,CAST(SUM(Col8) AS MONEY)
		,CAST(SUM(Col9) AS MONEY)
		,CAST(SUM(Col10) AS MONEY)
		,CAST(SUM(Col11) AS MONEY)
		,CAST(SUM(Col12) AS MONEY)
		,CAST(SUM(Col13) AS MONEY)
		,CAST(SUM(Col14)-SUM(Col9)-SUM(Col10)-SUM(Col11)-SUM(Col12)-SUM(Col13) AS MONEY) 
FROM #t t INNER JOIN dbo.vw_sprT001 l ON
		 t.CodeM=l.CodeM
GROUP BY l.filialName,t.CodeM,l.Names,l.pfa	
GO
DROP TABLE #t		 