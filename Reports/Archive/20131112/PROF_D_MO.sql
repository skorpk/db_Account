use AccountOMS
go	 
DECLARE @reportYear SMALLINT=2013,
			@dateBegin DATETIME='20130701',
			@dateEnd DATETIME='20131125 23:59:59',
			@reportMonth TINYINT=11

 ---------------a new block---------------------------
DECLARE @LPU AS table (CodeM CHAR(6))
INSERT @LPU
SELECT LEFT(l.CodeLPU,6)  AS CodeM
FROM (VALUES('115506'),('115510'),('121018'),('124501'),('124528'),('124530'),('125505'),('131020'),('135509'),('145516'),('145526'),('155502'),('155601'),
			('165525'),('165531'),('175603'),('175617'),('175627'),('185515'),('251008'),('254506'),('255601'),('255627'),('301001'),('311001'),('321001'),
			('331001'),('341001'),('351001'),('361001'),('371001'),('381001'),('391003'),('391015'),('395501'),('401001'),('411001'),('421001'),('431001'),
			('441001'),('451002'),('461001'),('471001'),('481001'),('491001'),('501001'),('511001'),('521001'),('531001'),('541001'),('551001'),('561001'),
			('571001'),('581001'),('591001'),('601001'),('611001'),('621001')) as l(CodeLPU)
order by CodeM
---------------a new block---------------------------

CREATE table #tCase 
(
	id bigint,
	Step TINYINT,
	CodeM CHAR(6),
	CodeSMO CHAR(5),	
	AmountPayment decimal(11,2), 	
	AmountPaymentAccepted decimal(11,2),
	AmountPaymentAccept decimal(11,2),
	AmountDeduction decimal(11,2),	
	)

INSERT #tCase( id, Step,AmountPayment,CodeM,CodeSMO)
SELECT t.id,t.Step,t.AmountPayment,CodeM,rf_idSMO
from (				
		SELECT c.id,1 AS Step,c.AmountPayment,f.CodeM,a.rf_idSMO
		FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
					f.id=a.rf_idFiles							
					AND a.ReportMonth>=1							
					AND a.ReportMonth<=@reportMonth
					AND a.ReportYear=@reportYear
						  INNER JOIN dbo.t_RecordCasePatient r ON
					a.id=r.rf_idRegistersAccounts
						  INNER JOIN dbo.t_RegisterPatient p ON
					f.id=p.rf_idFiles
					AND r.id=p.rf_idRecordCase
						  INNER JOIN dbo.t_Case c ON
					r.id=c.rf_idRecordCasePatient
					AND c.IsCompletedCase=1
					AND c.DateEnd<=@dateEnd
					AND c.DateEnd>='20130101'
							INNER JOIN dbo.t_MES mes ON
					c.id=mes.rf_idCase
							INNER JOIN dbo.vw_sprMUCompletedCase mu ON
					mes.MES=mu.MU
		WHERE a.Letter='F' AND mu.MUGroupCode=72 AND MUUnGroupCode=2 AND f.DateRegistration>=@dateBegin AND f.DateRegistration<=@dateEnd		
		--------------------------------t_Meduslugi-----------------------------------------------------
		UNION ALL
		SELECT DISTINCT c.id,2,c.AmountPayment,f.CodeM,a.rf_idSMO
		FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
					f.id=a.rf_idFiles
						AND a.ReportMonth>=1							
						AND a.ReportMonth<=@reportMonth
						AND a.ReportYear=@reportYear
						  INNER JOIN dbo.t_RecordCasePatient r ON
					a.id=r.rf_idRegistersAccounts
						   INNER JOIN dbo.t_RegisterPatient p ON
					f.id=p.rf_idFiles
					AND r.id=p.rf_idRecordCase
						  INNER JOIN dbo.t_Case c ON
					r.id=c.rf_idRecordCasePatient
					AND c.IsCompletedCase=0
							INNER JOIN dbo.t_Meduslugi m ON
					c.id=m.rf_idCase					
		WHERE a.Letter='F' AND m.MUGroupCode=2 AND MUUnGroupCode=85 AND f.DateRegistration>=@dateBegin AND f.DateRegistration<=@dateEnd			
		) t
GROUP BY t.id,t.Step,t.AmountPayment,CodeM,rf_idSMO

UPDATE c  
SET c.AmountPaymentAccepted=c1.TotalAmountPayment
FROM #tCase c INNER JOIN (
							SELECT sc.rf_idCase,SUM(sc.AmountPayment) AS TotalAmountPayment
							FROM ExchangeFinancing.dbo.t_DFileIn f INNER JOIN ExchangeFinancing.dbo.t_PaymentDocument p ON
										f.id=p.rf_idDFile
																	INNER JOIN ExchangeFinancing.dbo.t_SettledAccount a ON
										p.id=a.rf_idPaymentDocument
																	INNER JOIN ExchangeFinancing.dbo.t_SettledCase sc ON
										a.id=sc.rf_idSettledAccount																		
							WHERE a.Account LIKE '%F' AND f.DateRegistration>=@dateBegin AND f.DateRegistration<=@dateEnd
							GROUP BY sc.rf_idCase
							UNION ALL--иногородние 
							SELECT rf_idCase,SUM(AmountPayment)
							FROM dbo.vw_DFileInSMO34 
							WHERE Letter LIKE 'F' AND DateRegistration>=@dateBegin AND DateRegistration<=@dateEnd
							GROUP BY rf_idCase
						) c1 ON c.id=c1.rf_idCase
						

UPDATE c1 SET c1.AmountPaymentAccept=c1.AmountPayment-p.AmountDeduction, c1.AmountDeduction=p.AmountDeduction
FROM #tCase c1 INNER JOIN (
						  SELECT c.rf_idCase--,SUM(c.AmountPaymentAccept) AS AmountPaymentAccept
								,SUM(ISNULL(c.AmountEKMP,0)+ISNULL(c.AmountMEE,0)+ISNULL(c.AmountMEK,0)) AS AmountDeduction
						  from ExchangeFinancing.dbo.t_AFileIn f INNER JOIN ExchangeFinancing.dbo.t_DocumentOfCheckup d ON
											f.id=d.rf_idAFile											
															INNER JOIN ExchangeFinancing.dbo.t_CheckedAccount a ON
											d.id=a.rf_idDocumentOfCheckup
											AND a.ReportYear=@reportYear
											AND a.ReportMonth>=1 AND a.ReportMonth<=@reportMonth
															INNER JOIN ExchangeFinancing.dbo.t_CheckedCase c ON
											a.id=c.rf_idCheckedAccount
						  WHERE DateRegistration>=@dateBegin AND DateRegistration<=@dateEnd AND a.Account LIKE '%F'
						  GROUP BY rf_idCase
						  UNION ALL--иногородние
						  SELECT rf_idCase,SUM(AmountDeduction)
						  FROM dbo.vw_AFileInSMO34
						  WHERE DateRegistration>=@dateBegin AND DateRegistration<=@dateEnd AND Letter LIKE 'F'
						  GROUP BY rf_idCase
						  ) p ON
				c1.id=p.rf_idCase					
						
			
SELECT l.CodeM,l.NameS,ISNULL(s.sNameS,''),	
		cast(sum(isnull(c.AmountPayment,0)) as money) AS col4,		
		cast(sum(CASE WHEN c.Step=1 THEN c.AmountPayment ELSE 0 END) as money) AS col5,		
		cast(sum(CASE WHEN c.Step=2 THEN c.AmountPayment ELSE 0 END) as money) AS col6,
		cast(sum(ISNULL(c.AmountPaymentAccept,0)) as money) AS col7,
		cast(sum(CASE WHEN c.Step=1 THEN ISNULL(c.AmountPaymentAccept,0) ELSE 0 END) as money) AS col8,
		cast(sum(CASE WHEN c.Step=2 THEN isnull(c.AmountPaymentAccept,0) ELSE 0 END) as money) AS col9,		
		cast(sum(ISNULL(c.AmountDeduction,0)) as money) AS col10,
		cast(sum(CASE WHEN c.Step=1 THEN ISNULL(c.AmountDeduction,0) ELSE 0 END) as money) AS col11,
		cast(sum(CASE WHEN c.Step=2 THEN isnull(c.AmountDeduction,0) ELSE 0 END) as money) AS col12,	  				
		cast(sum(ISNULL(c.AmountPaymentAccepted,0)) as money) AS col13,
		cast(sum(CASE WHEN c.Step=1 THEN ISNULL(c.AmountPaymentAccepted,0) ELSE 0 END) as money) AS col14,
		cast(sum(CASE WHEN c.Step=2 THEN isnull(c.AmountPaymentAccepted,0) ELSE 0 END) as money) AS col15		
FROM #tCase c INNER JOIN dbo.vw_sprSMO s ON
		c.CodeSMO=s.smocod
			  RIGHT JOIN (@LPU t INNER JOIN dbo.vw_sprT001 l ON l.CodeM=t.CodeM) ON
		c.CodeM=l.CodeM	
GROUP BY l.CodeM,l.NameS,s.sNameS
ORDER BY l.CodeM
GO
DROP TABLE #tCase
GO