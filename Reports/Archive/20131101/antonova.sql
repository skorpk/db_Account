USE AccountOMS
GO
DECLARE @reportYear SMALLINT=2013,
		@dateBegin DATETIME='20130501',
		@dateEnd DATETIME='20131101',
		@letter CHAR(1)='R'

CREATE table #tCase 
(
	CodeM CHAR(6),
	CodeSMO VARCHAR(5),
	Account VARCHAR(15),
	DateAccount date,
	id bigint,
	NumberCase INT,
	DateBeginCase DATE,
	DateStartLicense DATE,
	AmountPayment decimal(11,2),
	AmountPaymentAccepted DECIMAL(15,2)
)
CREATE TABLE #tDateLicense(CodeM CHAR(6),DateStart DATE)
INSERT #tDateLicense
        ( CodeM, DateStart )
SELECT v.CodeM,DATEADD(DAY,-2,CAST(cast(v.DateStart AS datetime) AS DATE))
FROM (values('101003',41481), ('114504',41460),('114506',41459),('121018',41492),('124501',41515),
			('124528',41491),('124530',41458),('134505',41474),('134510',41484),('141016',41480),
			('141022',41481),('141023',41467),('141024',41467),('154602',41456),('154608',41484),
			('154620',41488),('161007',41480),('161015',41487),('174601',41473),('175709',41449),
			('184512',41456),('184603',41456),('251001',41468),('251002',41460),('251003',41485),
			('254504',41460),('254505',41466),('255802',41458),('301001',41485),('311001',41499),
			('321001',41488),('331001',41464),('341001',41488),('351001',41485),('361001',41487),
			('371001',41491),('381001',41515),('391001',41488),('391002',41488),('401001',41487),
			('411001',41468),('421001',41492),('431001',41495),('441001',41495),('451001',41491),
			('461001',41473),('471001',41472),('481001',41487),('491001',41488),('501001',41492),
			('511001',41495),('521001',41471),('531001',41479),('541001',41499),('551001',41495),
			('561001',41472),('571001',41488),('571002',41515),('581001',41466),('591001',41485),
			('601001',41495),('611001',41488),('621001',41491),('711001',41486)) v(CodeM,DateStart)


INSERT #tCase( CodeM, CodeSMO,Account,DateAccount,id,NumberCase, AmountPayment,DateBeginCase,DateStartLicense )
SELECT f.CodeM,a.rf_idSMO,a.Account,a.DateRegister,c.id,c.idRecordCase,c.AmountPayment,c.DateBegin,dl.DateStart
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
					f.id=a.rf_idFiles												
					AND a.ReportYear=@reportYear
						  INNER JOIN dbo.t_RecordCasePatient r ON
					a.id=r.rf_idRegistersAccounts
						  INNER JOIN dbo.t_RegisterPatient p ON
					f.id=p.rf_idFiles
					AND r.id=p.rf_idRecordCase
						  INNER JOIN dbo.t_Case c ON
					r.id=c.rf_idRecordCasePatient					
					AND c.DateEnd<=@dateEnd
					AND c.DateEnd>='20130101'	
							INNER JOIN #tDateLicense dl ON
					f.CodeM=dl.CodeM
					AND c.DateBegin<dl.DateStart						
WHERE a.Letter=@letter AND f.DateRegistration>=@dateBegin AND f.DateRegistration<=@dateEnd		
				
UPDATE c SET c.AmountPaymentAccepted=p.AmountPaymentAccept
FROM #tCase c INNER JOIN (
						  SELECT c.rf_idCase,SUM(c.AmountPaymentAccept) AS AmountPaymentAccept
						  from ExchangeFinancing.dbo.t_AFileIn f INNER JOIN ExchangeFinancing.dbo.t_DocumentOfCheckup d ON
											f.id=d.rf_idAFile
															INNER JOIN ExchangeFinancing.dbo.t_CheckedAccount a ON
											d.id=a.rf_idDocumentOfCheckup
															INNER JOIN ExchangeFinancing.dbo.t_CheckedCase c ON
											a.id=c.rf_idCheckedAccount
						  WHERE DateRegistration>'20130501' AND DateRegistration<getdate() AND a.Account LIKE '%'+@letter
						  GROUP BY rf_idCase
						  ) p ON
				c.id=p.rf_idCase
WHERE c.CodeSMO<>'34'

SELECT l.CodeM,l.NameS,CodeSMO,Account,DateAccount,
		NumberCase,DateBeginCase,DateStartLicense,CAST(AmountPayment AS MONEY) AmountPayment
		,CAST(ISNULL(AmountPaymentAccepted,0.0) AS MONEY) AS AmountPaymentAccepted
		,CASE WHEN AmountPaymentAccepted IS NOT NULL THEN 1 ELSE 0 END 			
FROM #tCase c INNER JOIN vw_sprT001 l ON
		c.CodeM=l.CodeM	  
WHERE CodeSMO='34001'
ORDER BY l.CodeM

go
DROP TABLE #tCase	
DROP TABLE #tDateLicense	
	
		