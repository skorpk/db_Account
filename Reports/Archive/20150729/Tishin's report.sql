USE AccountOMS
GO		
DECLARE @dtStart DATETIME='20150101',
		@dtEnd DATETIME='20150720 23:59:59',
		@reportYear SMALLINT=2015,
		@reportMonthEnd TINYINT=6


CREATE TABLE #LPU(MainLPU CHAR(6),CodeM CHAR(6) )

CREATE UNIQUE NONCLUSTERED INDEX QU_IX_CodeM ON #LPU(CodeM) WITH IGNORE_DUP_KEY
/*	
INSERT #LPU( MainLPU, CodeM )
SELECT LEFT(v.Main,6),LEFT(v.Child,6)
FROM (VALUES ('10100112','10590118'),('10100311','10500811'),('10400118','10400213'),('10400118','10400311'),('10400118','10500118'),('10400118','10500213'),('10400118','10500414'),
			('10400118','10500517'),('10400118','10500625'),('10400118','10500745'),('12452812','12450112'),('13102013','13502013'),('15560115','15500115'),('16101516','16501516'),
			('18540218','17540517'),('25562725','25502725'),('39100139','39500139'),('39100139','39101539'),('39100339','39101539'),('39100339','39550139'),('45100145','45101145'),
			('45100145','45101245'),('45100145','45101345'),('45100145','45101445'),('45100145','45101545'),('45100145','45101645'),('45100145','45101745'),('51100151','51100251'),
			('57100157','57100257'),('59100159','59100259'),('61100161','61101161'),('61100161','61490161'),('61100161','61490261'),('61100161','61490361'),('71100118','71450261')) v(Main,Child)
*/
--SELECT CodeM FROM #LPU  GROUP BY CodeM HAVING COUNT(*)>1

INSERT #LPU( MainLPU, CodeM )
SELECT CodeM,CodeM FROM dbo.vw_sprT001 l WHERE NOT EXISTS(SELECT * FROM #LPU WHERE CodeM=l.CodeM)

CREATE TABLE #tPeople(rf_idCase BIGINT,
					  CodeM CHAR(6),
					  AmountPayment DECIMAL(11,2), 
					  AttachLPU CHAR(6),
					  IsChild tinyint,
					  MU varchar(12),
					  Quantity DECIMAL(6,2),
					  IsAlien AS (CASE WHEN CodeM=AttachLPU THEN 1 ELSE 2 END)
					  )
					  
INSERT #tPeople( rf_idCase,CodeM ,AmountPayment ,AttachLPU ,IsChild ,MU,Quantity)
SELECT c.id,f.CodeM,c.AmountPayment,r.AttachLPU,CASE WHEN c.Age<18 THEN 1 ELSE 2 END ,m.MU,SUM(m.Quantity)
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
			AND a.rf_idSMO<>'34'
					INNER JOIN #LPU l ON
			f.CodeM=l.CodeM
					INNER JOIN (VALUES('A'),('G'),('J') ) v(Letter) ON
			a.Letter=v.Letter
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase		
WHERE f.DateRegistration>@dtStart AND f.DateRegistration<@dtEnd AND a.ReportYear=@reportYear AND c.rf_idV006=3 AND m.Price>0 AND a.ReportMonth>0 AND a.ReportMonth<=@reportMonthEnd
GROUP BY c.id,f.CodeM,c.AmountPayment,r.AttachLPU,CASE WHEN c.Age<18 THEN 1 ELSE 2 END ,m.MU

INSERT #tPeople( rf_idCase,CodeM ,AmountPayment ,AttachLPU ,IsChild ,MU ,Quantity)
SELECT c.id,f.CodeM,c.AmountPayment,r.AttachLPU,CASE WHEN c.Age<18 THEN 1 ELSE 2 END ,m.MES,m.Quantity
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
			AND a.rf_idSMO<>'34'
				  INNER JOIN #LPU l ON
			f.CodeM=l.CodeM
					INNER JOIN (VALUES('A'),('G'),('J') ) v(Letter) ON
			a.Letter=v.Letter
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase		
WHERE f.DateRegistration>@dtStart AND f.DateRegistration<@dtEnd AND a.ReportYear=@reportYear AND c.rf_idV006=3 AND a.ReportMonth>0 AND a.ReportMonth<=@reportMonthEnd 
--------------------------------------Update information about RAK---------------------------
UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tPeople p INNER JOIN (
							SELECT  sc.rf_idCase, SUM(ISNULL(sc.AmountEKMP, 0) + ISNULL(sc.AmountMEE, 0) + ISNULL(sc.AmountMEK, 0)) AS AmountDeduction
							FROM ExchangeFinancing.dbo.t_AFileIn f INNER JOIN ExchangeFinancing.dbo.t_DocumentOfCheckup p ON 
														f.id = p.rf_idAFile 
																	INNER JOIN ExchangeFinancing.dbo.t_CheckedAccount a ON 
														p.id = a.rf_idDocumentOfCheckup 
																	INNER JOIN ExchangeFinancing.dbo.t_CheckedCase sc ON 
														a.id = sc.rf_idCheckedAccount
							WHERE f.DateRegistration>=@dtStart AND f.DateRegistration<@dtEnd
							GROUP BY sc.rf_idCase
							) r ON						
			p.rf_idCase=r.rf_idCase

--CREATE NONCLUSTERED INDEX IX_People
--ON #tPeople([CodeM],[AmountPayment]) INCLUDE ([IsChild],[MU],[Quantity],[IsAlien])
			
SELECT  MainLPU ,
        l1.NAMES ,
        t.MU ,
        m.MUName ,
        SUM(IsOurAdult) ,
        SUM(IsAlienAdult) ,
        SUM(IsOurChild) ,
        SUM(IsAlienChild)
FROM (
SELECT l.MainLPU, p.MU
		,CAST(SUM(CASE WHEN p.IsAlien=1 AND p.IsChild=2 THEN Quantity ELSE 0 END) as money) AS IsOurAdult 
		,CAST(SUM(CASE WHEN p.IsAlien=2 AND p.IsChild=2 THEN Quantity ELSE 0 END) as money) AS IsAlienAdult 
		,CAST(SUM(CASE WHEN p.IsAlien=1 AND p.IsChild=1 THEN Quantity ELSE 0 END) as money) AS IsOurChild 
		,CAST(SUM(CASE WHEN p.IsAlien=2 AND p.IsChild=1 THEN Quantity ELSE 0 END) as money) AS IsAlienChild
FROM #tPeople p	 INNER JOIN #LPU l ON
		p.CodeM=l.CodeM				
WHERE p.AmountPayment>0	--AND l.CodeM<>'391015'	
GROUP BY l.MainLPU,p.MU
---для МО с кодом 391015 считаем объемы отдельно
/*
UNION ALL--детей
SELECT l.MainLPU
		,p.MU
		,0 AS IsOurAdult 
		,0 AS IsAlienAdult 
		,SUM(CASE WHEN p.IsAlien=1 AND p.IsChild=1 THEN Quantity ELSE 0 END) AS IsOurChild 
		,SUM(CASE WHEN p.IsAlien=2 AND p.IsChild=1 THEN Quantity ELSE 0 END) AS IsAlienChild
FROM #tPeople p	 INNER JOIN #LPU l ON
		p.CodeM=l.CodeM				
WHERE p.AmountPayment>0	AND l.CodeM='391015' AND l.MainLPU='391001'
GROUP BY l.MainLPU,p.MU
UNION ALL --взрослый
SELECT l.MainLPU, p.MU
		,SUM(CASE WHEN p.IsAlien=1 AND p.IsChild=2 THEN Quantity ELSE 0 END) AS IsOurAdult 
		,SUM(CASE WHEN p.IsAlien=2 AND p.IsChild=2 THEN Quantity ELSE 0 END) AS IsAlienAdult 
		,0 AS IsOurChild 
		,0 AS IsAlienChild
FROM #tPeople p	 INNER JOIN #LPU l ON
		p.CodeM=l.CodeM			
WHERE p.AmountPayment>0	AND l.CodeM='391015' AND l.MainLPU='391003'
GROUP BY l.MainLPU,p.MU
*/
		) t INNER JOIN dbo.vw_sprT001 l1 ON
					t.MainLPU=l1.CodeM
			INNER JOIN dbo.vw_sprMUAll m ON
					t.MU=m.MU
GROUP BY t.MainLPU ,l1.NAMES ,t.MU ,m.MUName
ORDER BY MainLPU,t.MU
go

DROP TABLE #tPeople
DROP TABLE #LPU


