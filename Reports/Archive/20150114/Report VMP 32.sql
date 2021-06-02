USE AccountOMS
GO
CREATE TABLE #t(Account VARCHAR(15),ReportMonth tinyint,rf_idCase BIGINT, AmountPayment DECIMAL(11,2), AmountRAK DECIMAL(11,2) NOT NULL DEFAULT 0, AmountRPD DECIMAL(11,2) NOT NULL DEFAULT 0)

INSERT #t( Account,ReportMonth,rf_idCase ,AmountPayment)
SELECT a.Account,a.ReportMonth,c.id,c.AmountPayment
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
			AND f.CodeM='101801'
			AND a.rf_idSMO<>'34'			
				  INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
				  INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
WHERE f.DateRegistration>'20140101' AND f.DateRegistration<'20150114' AND a.ReportYear=2014 AND c.rf_idV006=1 AND c.rf_idV008=32

UPDATE t SET AmountRPD=a.AmountPaymentSum
FROM #t t INNER JOIN (
					SELECT c.rf_idCase,SUM(c.AmountPayment) AS AmountPaymentSum
					FROM ExchangeFinancing.dbo.t_DFileIn f INNER JOIN ExchangeFinancing.dbo.t_PaymentDocument p ON
								f.id=p.rf_idDFile
										INNER JOIN ExchangeFinancing.dbo.t_SettledAccount a ON
								p.id=a.rf_idPaymentDocument
										INNER JOIN ExchangeFinancing.dbo.t_SettledCase c ON
								a.id=c.rf_idSettledAccount
					WHERE f.DateRegistration>'20140101' AND f.DateRegistration<'20150114' AND f.CodeM='101801'
					GROUP BY c.rf_idCase
					) a ON
			t.rf_idCase=a.rf_idCase
			
UPDATE t SET AmountRAK=t.AmountPayment-a.AmountDeduction
FROM #t t INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountMEK+c.AmountMEE+c.AmountMEK )AS AmountDeduction
					  FROM ExchangeFinancing.dbo.t_AFileIn f INNER join ExchangeFinancing.dbo.t_DocumentOfCheckup d ON
										f.id=d.rf_idAFile
													INNER JOIN ExchangeFinancing.dbo.t_CheckedAccount a ON
										d.id=a.rf_idDocumentOfCheckup
													INNER JOIN ExchangeFinancing.dbo.t_CheckedCase c ON
										a.id=c.rf_idCheckedAccount
						WHERE f.DateRegistration>'20140101' AND f.DateRegistration<'20150114' AND f.CodeM='101801'
						GROUP BY c.rf_idCase							
					) a	ON
			t.rf_idCase=a.rf_idCase


SELECT * from #t --WHERE AmountRAK=AmountRPD AND AmountRAK>0 

SELECT * 
INTO dbo.tmpMissingCase
FROM [SRVSQL1-ST2].AccountOMSReports.dbo.t_Order17CaseIdList o 
WHERE o.LPU='340200' AND NOT EXISTS(SELECT * from #t WHERE rf_idCase=o.rf_idCase)

SELECT  o.rf_idCase ,
        o.ReportMonth ,
        o.ReportYear ,
        o.yearmonth ,
        o.sum ,
        o.fileType ,
        o.SMO_OK ,
        o.W ,
        o.VZST ,
        o.IDCASE ,
        o.VID_HMP ,
        o.METOD_HMP ,
        o.LPU ,
        o.DATE_I ,
        o.DS,t.AmountRPD,t.AmountRAK 
INTO dbo.tmpEqualCase
FROM [SRVSQL1-ST2].AccountOMSReports.dbo.t_Order17CaseIdList o INNER JOIN #t t ON
					o.rf_idCase=t.rf_idCase
WHERE o.LPU='340200' 
GO
DROP TABLE #t
			