USE AccountOMS--Reports
GO		
DECLARE @letter CHAR(1)	='D',
		@dtStart DATETIME='20140101',
		@dtEnd DATETIME='20150203 23:59:59',
		@reportYear SMALLINT=2014,
		@dtRPDEnd datetime=GETDATE()

DECLARE @lpu AS TABLE(CodeM CHAR(6),Letter CHAR(1))


INSERT @lpu
        ( CodeM, Letter )
VALUES ('115506','D'),('121018','D'),('124530','D'),('125505','D'),('131020','D'),('135509','D'),('145516','D'),('145526','D'),('155601','D'),('165525','D'),
('185515','D'),('251008','D'),('255601','D'),('255627','D'),('361001','D'),('391003','D'),('431001','D'),('451002','D'),('481001','D'),('531001','D'),
('541001','D'),('591001','D'),('601001','D'),('611001','D'),('621001','D')
		
CREATE TABLE #tPeople(rf_idCase BIGINT,					  
					  CodeM CHAR(6),
					  Quantity DECIMAL(6,2),
					  MU VARCHAR(12),
					  AmountPayment DECIMAL(11,2),
					  AmountRAK DECIMAL(11,2)
					  )
INSERT #tPeople (rf_idCase,CodeM,Quantity,MU,AmountPayment)
SELECT c.id,f.CodeM,m.Quantity,m.MU,c.AmountPayment
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
			AND a.Letter=@letter
					INNER JOIN @lpu l ON
			f.CodeM=l.CodeM
			AND l.Letter=@letter
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
			AND c.DateEnd>'20131231' AND c.DateEnd<'20150101'
					INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase					
WHERE f.DateRegistration>@dtStart AND f.DateRegistration<@dtEnd AND a.ReportYear=@reportYear AND m.MU LIKE '2.83.%'--m.MUGroupCode=2 AND MUUnGroupCode=3

INSERT #tPeople (rf_idCase,CodeM,Quantity,MU,AmountPayment)
SELECT c.id,f.CodeM,m.Quantity,m.MES,c.AmountPayment
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
			AND a.Letter=@letter
					INNER JOIN @lpu l ON
			f.CodeM=l.CodeM
			AND l.Letter=@letter
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
			AND c.DateEnd>'20131231' AND c.DateEnd<'20150101'
					INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase					
WHERE f.DateRegistration>@dtStart AND f.DateRegistration<@dtEnd AND a.ReportYear=@reportYear AND m.MES LIKE '70.5.%'--m.MUGroupCode=2 AND MUUnGroupCode=3
--------------------------------------Update information about RAK---------------------------
UPDATE p SET p.AmountRAK=p.AmountPayment-r.AmountDeduction
FROM #tPeople p INNER JOIN (SELECT rf_idCase,SUM(AmountDeduction) AS AmountDeduction 
							FROM [SRVSQL1-ST2].AccountOMSReports.dbo.t_PaymentAcceptedCase a INNER JOIN @lpu l ON
										a.CodeM=l.CodeM
										AND l.Letter=@letter 
							WHERE DateRegistration>=@dtStart AND DateRegistration<@dtRPDEnd AND a.Letter=@letter	
							GROUP BY rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

SELECT m.MU, m.MUName, CAST(SUM(p.Quantity) AS MONEY) AS Col4
FROM #tPeople p INNER JOIN dbo.vw_sprMUAll m ON
		p.MU=m.MU
WHERE AmountRAK>0		
GROUP BY m.MU, m.MUName
ORDER BY m.MU
go

DROP TABLE #tPeople


