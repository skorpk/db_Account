USE AccountOMSReports
GO
DECLARE @reportYear SMALLINT=2015,
		@dateStart DATETIME='20150101',
		@dateEnd DATETIME='20150713 23:59:59',
		@dateEndPay DATETIME='20150827 23:59:59'


SELECT @dateStart=CAST(@reportYear AS CHAR(4))+'0101'		

DECLARE @l AS TABLE(CodeM VARCHAR(6))

INSERT @l( CodeM ) VALUES  ('101003'),('114504'),('114506'),('115506'),('115510'),('121018'),('124528'),('124530'),('125505'),('131020'),('134505'),('134510'),('135509')
							,('141016'),('141022'),('141023'),('141024'),('145516'),('145526'),('154602'),('154608'),('154620'),('155502'),('155601'),('161007'),('161015')
							,('165525'),('165531'),('174601'),('175603'),('175617'),('175627'),('175709'),('184512'),('184603'),('185515'),('251001'),('251002'),('251003')
							,('251008'),('254504'),('254505'),('254506'),('255601'),('255627'),('255802'),('301001'),('311001'),('321001'),('331001'),('341001'),('351001')
							,('361001'),('371001'),('381001'),('391001'),('391002'),('391003'),('401001'),('411001'),('421001'),('431001'),('441001'),('451001'),('451002')
							,('461001'),('471001'),('481001'),('491001'),('501001'),('511001'),('521001'),('531001'),('541001'),('551001'),('561001'),('571001'),('581001')
							,('591001'),('601001'),('611001'),('621001'),('711001')

CREATE TABLE #tPeople(rf_idCase BIGINT,					  
					  CodeM CHAR(6),
					  Letter CHAR(1),
					  IsSpecialCase	TINYINT,
					  AmountPayment DECIMAL(11,2),
					  PeopleID BIGINT,
                      rf_idV009 SMALLINT,
					  IsCol5 TINYINT,
					  DateRegistration DATETIME,
					  DateEnd DATE,
					  IsDouble TINYINT  
					  )
INSERT #tPeople( rf_idCase,CodeM ,IsSpecialCase,AmountPayment,Letter,rf_idV009,DateRegistration,DateEnd)
SELECT c.id,f.CodeM, CASE WHEN c.IsSpecialCase LIKE '%3' THEN 3 ELSE 4 end, c.AmountPayment-p.AmountDeduction,a.Letter,c.rf_idV009
		,f.DateRegistration,c.DateEnd
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles						
					INNER JOIN (VALUES('O'),('F') ,('D'),('V'),('U') ) v(letter) ON
			a.Letter=v.letter
					INNER JOIN @l l ON
			f.CodeM=l.CodeM                  
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient																				
					INNER JOIN oms_nsi.dbo.sprSpecialCase sc ON
			c.IsSpecialCase=sc.OS_SLUCH
			AND sc.Step=1                  
					INNER JOIN (SELECT p.rf_idCase,SUM(AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase p INNER JOIN (VALUES('O'),('F') ,('D'),('V'),('U') ) v(letter) ON
											p.Letter=v.Letter
								WHERE p.DateRegistration>=@dateStart AND p.DateRegistration<=@dateEndPay
								GROUP BY p.rf_idCase) p ON
			c.id=p.rf_idCase                  
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportMonth>0 AND a.ReportMonth<=6 AND a.ReportYear=@reportYear 

UPDATE p SET PeopleID=pc.IDPeople
FROM #tPeople p INNER JOIN dbo.t_People_Case pc ON
			p.rf_idCase=pc.rf_idCase

UPDATE p SET p.IsDouble=1
FROM #tPeople p INNER JOIN (
							SELECT TOP 1 WITH TIES rf_idCase
							FROM #tPeople
							WHERE AmountPayment>0 AND Letter<>'O'
							ORDER BY ROW_NUMBER() OVER (PARTITION BY PeopleID,CodeM,Letter ORDER BY DateEnd desc,DateRegistration desc)
							) d ON
		p.rf_idCase=d.rf_idCase     
		                    
--по счетам с буквой О дубликаты считаются по другому
UPDATE p SET p.IsDouble=1
FROM #tPeople p INNER JOIN (
							SELECT TOP 1 WITH TIES rf_idCase
							FROM #tPeople
							WHERE AmountPayment>0 AND Letter='O'
							ORDER BY ROW_NUMBER() OVER (PARTITION BY IsSpecialCase ,PeopleID,CodeM ORDER BY DateEnd desc,DateRegistration desc)
							) d ON
		p.rf_idCase=d.rf_idCase

---------Удаляю не нужные случаи
DELETE FROM #tPeople WHERE IsDouble IS NULL AND Letter<>'O'

---------Расчитываю колонку №5
UPDATE p SET p.IsCol5=1	FROM #tPeople p WHERE  p.AmountPayment>0 AND Letter='O'	AND p.IsSpecialCase=4 AND p.IsDouble=1

UPDATE p SET p.IsCol5=1
FROM #tPeople p INNER JOIN (VALUES(316),(352),(353),(354),(357),(358) ) v(id) ON
			p.rf_idV009=v.id
WHERE p.AmountPayment>0	AND p.IsSpecialCase=3 AND Letter='O' 
		AND NOT EXISTS(SELECT * FROM #tPeople WHERE CodeM=p.CodeM AND PeopleID=p.PeopleID AND p.IsSpecialCase=4 AND Letter=p.Letter)

SELECT l.CodeM, l.NAMES
		,count(distinct(CASE WHEN p.Letter='O' AND p.IsSpecialCase=3 THEN p.PeopleID ELSE NULL END)) AS Col3
		,count(distinct(CASE WHEN p.Letter='O' AND p.IsSpecialCase=4 THEN p.PeopleID ELSE NULL END)) AS Col4
		,COUNT( distinct(CASE WHEN p.IsCol5 IS NOT NULL THEN PeopleID ELSE NULL END)) AS Col5
		,count(distinct(CASE WHEN p.Letter='F' AND p.IsSpecialCase=3 THEN p.PeopleID ELSE NULL END)) AS Col6
		,count(distinct(CASE WHEN p.Letter='F' AND p.IsSpecialCase=4 THEN p.PeopleID ELSE NULL END)) AS Col7
		,count(distinct(CASE WHEN p.Letter='V' AND p.IsSpecialCase=3 THEN p.PeopleID ELSE NULL END)) AS Col8
		,count(distinct(CASE WHEN p.Letter='V' AND p.IsSpecialCase=4 THEN p.PeopleID ELSE NULL END)) AS Col9
		,count(distinct(CASE WHEN p.Letter='D' AND p.IsSpecialCase=3 THEN p.PeopleID ELSE NULL END)) AS Col10
		,count(distinct(CASE WHEN p.Letter='D' AND p.IsSpecialCase=4 THEN p.PeopleID ELSE NULL END)) AS Col11
		,count(distinct(CASE WHEN p.Letter='U' AND p.IsSpecialCase=3 THEN p.PeopleID ELSE NULL END)) AS Col12
		,count(distinct(CASE WHEN p.Letter='U' AND p.IsSpecialCase=4 THEN p.PeopleID ELSE NULL END)) AS Col13
FROM #tPeople p INNER JOIN dbo.vw_sprT001 l ON
			p.CodeM=l.CodeM
WHERE ISNULL(p.AmountPayment,0)>0 
GROUP BY l.CodeM, l.NAMES
ORDER BY l.CodeM

GO
DROP TABLE #tPeople
