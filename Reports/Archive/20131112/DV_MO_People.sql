use AccountOMS
go	
IF OBJECT_ID('usp_ReportDV_MO_People',N'P') IS NOT NULL
	DROP PROCEDURE usp_ReportDV_MO_People
GO				 
CREATE PROCEDURE usp_ReportDV_MO_People
			@reportYear SMALLINT,
			@dateBegin DATETIME,
			@dateEnd DATETIME,
			@reportMonth TINYINT
as
 ---------------a new block---------------------------
DECLARE @LPU AS table (CodeM CHAR(6))
INSERT @LPU
SELECT LEFT(l.CodeLPU,6)  AS CodeM
FROM (VALUES('10100311'),('11450411'),('11450611'),('12101812'),('12450112'),('12452812'),('12453012'),('13450513'),('13451013'),('14101614'),('14102214'),
			('14102314'),('14102414'),('15460215'),('15460815'),('15462015'),('16100716'),('16101516'),('17460117'),('17570917'),('18451218'),('18460318'),
			('25100125'),('25100225'),('25100325'),('25450425'),('25450525'),('25580225'),('30100130'),('31100131'),('32100132'),('33100133'),('34100134'),
			('35100135'),('36100136'),('37100137'),('38100138'),('39100139'),('39100239'),('40100140'),('41100141'),('42100142'),('43100143'),('44100144'),
			('45100145'),('46100146'),('47100147'),('48100148'),('49100149'),('50100150'),('51100151'),('52100152'),('53100153'),('54100154'),('55100155'),
			('56100156'),('57100157'),('57100257'),('58100158'),('59100159'),('60100160'),('61100161'),('62100162'),('71100118')) as l(CodeLPU)
order by CodeM
---------------a new block---------------------------
CREATE table #tCase 
(
	id bigint,
	CodeM CHAR(6),
	CodeSMO CHAR(5),	
	AmountPayment decimal(11,2), 	
	AmountPaymentAccept decimal(11,2),
	AmountPaymentAccepted decimal(11,2),
	PeopleId BIGINT	
	)

INSERT #tCase( id, AmountPayment,CodeM,CodeSMO)
SELECT t.id,t.AmountPayment,CodeM,rf_idSMO
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
		WHERE a.Letter='O' AND mu.MUGroupCode=70 AND MUUnGroupCode=3 AND f.DateRegistration>=@dateBegin AND f.DateRegistration<=@dateEnd	
				
		) t
GROUP BY t.id,t.Step,t.AmountPayment,CodeM,rf_idSMO


UPDATE c SET c.PeopleID=p.IDPeople
FROM #tCase c INNER JOIN dbo.t_People_Case p ON
				c.id=p.rf_idCase
-----------------------------------RAK-------------------------------------------------------------------
UPDATE c1 SET c1.AmountPaymentAccept=c1.AmountPayment-p.AmountDeduction
FROM #tCase c1 INNER JOIN (
						  SELECT c.rf_idCase
								,SUM(ISNULL(c.AmountEKMP,0)+ISNULL(c.AmountMEE,0)+ISNULL(c.AmountMEK,0)) AS AmountDeduction
						  from ExchangeFinancing.dbo.t_AFileIn f INNER JOIN ExchangeFinancing.dbo.t_DocumentOfCheckup d ON
											f.id=d.rf_idAFile											
															INNER JOIN ExchangeFinancing.dbo.t_CheckedAccount a ON
											d.id=a.rf_idDocumentOfCheckup
											AND a.ReportYear=@reportYear
											AND a.ReportMonth>=1 AND a.ReportMonth<=@reportMonth
															INNER JOIN ExchangeFinancing.dbo.t_CheckedCase c ON
											a.id=c.rf_idCheckedAccount
						  WHERE DateRegistration>=@dateBegin AND DateRegistration<=@dateEnd AND a.Account LIKE '%O'
						  GROUP BY rf_idCase
						  UNION ALL--иногородние
						  SELECT rf_idCase,SUM(AmountDeduction)
						  FROM dbo.vw_AFileInSMO34
						  WHERE DateRegistration>=@dateBegin AND DateRegistration<=@dateEnd AND Letter LIKE 'O'
						  GROUP BY rf_idCase
						  ) p ON
				c1.id=p.rf_idCase	
---------------------------------Payment--------------------------------------------------------------------
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
							WHERE a.Account LIKE '%O' AND f.DateRegistration>=@dateBegin AND f.DateRegistration<=@dateEnd
							GROUP BY sc.rf_idCase
							UNION ALL--иногородние 
							SELECT rf_idCase,SUM(AmountPayment)
							FROM dbo.vw_DFileInSMO34 
							WHERE Letter LIKE 'O' AND DateRegistration>=@dateBegin AND DateRegistration<=@dateEnd
							GROUP BY rf_idCase
						) c1 ON c.id=c1.rf_idCase			

SELECT l.CodeM,l.NameS
		,COUNT(DISTINCT c.PeopleId) AS col3
		,COUNT(distinct CASE WHEN ISNULL(c.AmountPaymentAccept,0)>0 THEN c.PeopleId ELSE null END) AS col4
		,COUNT(distinct CASE WHEN ISNULL(c.AmountPaymentAccept,1)>0 THEN c.PeopleId ELSE null END) AS col5
		,COUNT(DISTINCT CASE WHEN ISNULL(c.AmountPaymentAccepted,0)>0 THEN PeopleID	ELSE NULL END) AS col16			
FROM #tCase c RIGHT JOIN (@LPU t INNER JOIN dbo.vw_sprT001 l ON l.CodeM=t.CodeM) ON
		c.CodeM=l.CodeM	
GROUP BY l.CodeM,l.NameS
ORDER BY l.CodeM

DROP TABLE #tCase
GO