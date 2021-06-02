USE AccountOMSReports
GO
DECLARE @t AS TABLE(id BIGINT,CodeM CHAR(6),Account VARCHAR(15),AmountPayment DECIMAL(11,2))

INSERT @t
SELECT c.id,f.CodeM,a.Account,c.AmountPayment
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
		f.id=a.rf_idFiles
				INNER JOIN dbo.t_RecordCasePatient r ON
		a.id=r.rf_idRegistersAccounts
				INNER JOIN dbo.t_Case c ON
		r.id=c.rf_idRecordCasePatient
				INNER JOIN dbo.t_MES m ON
		c.id=m.rf_idCase
				INNER JOIN dbo.vw_sprMUCompletedCase mu ON
		m.MES=mu.MU
				INNER JOIN [oms_NSI].[dbo].[vw_sprT001] l ON
		f.CodeM=l.CodeM
WHERE f.DateRegistration>'20130501' AND f.DateRegistration<'20140201 23:59:59' AND a.Letter='O' AND a.ReportYear=2013 AND mu.MUGroupCode=70 AND MUUnGroupCode=3
		AND a.PrefixNumberRegister IN ('34001','34002')

SELECT pc.IDPeople
FROM dbo.t_PaymentAcceptedCase p INNER JOIN @t t ON
			p.rf_idCase=t.id
				inner JOIN dbo.t_People_Case pc ON
			t.id=pc.rf_idCase
WHERE p.DateRegistration<'20140201 23:59:59' AND (t.AmountPayment-p.AmountDeduction)>0
GROUP BY pc.IDPeople
HAVING COUNT(*)>1


SELECT COUNT(t2.rf_idCase)
FROM (
SELECT pc.IDPeople
FROM dbo.t_PaymentAcceptedCase p INNER JOIN @t t ON
			p.rf_idCase=t.id
				inner JOIN dbo.t_People_Case pc ON
			t.id=pc.rf_idCase
WHERE p.DateRegistration<'20140201 23:59:59' AND (t.AmountPayment-p.AmountDeduction)>0
GROUP BY pc.IDPeople
HAVING COUNT(*)>1
	) t INNER JOIN (SELECT p.rf_idCase,pc.IDPeople
					FROM dbo.t_PaymentAcceptedCase p INNER JOIN @t t ON
								p.rf_idCase=t.id
									left JOIN dbo.t_People_Case pc ON
								t.id=pc.rf_idCase
					WHERE p.DateRegistration<'20140201 23:59:59' AND (t.AmountPayment-p.AmountDeduction)>0
					) t2 ON
	t.IDPeople=t2.IDPeople

