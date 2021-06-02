USE AccountOMS
GO
--SELECT SUM(SumMU)
--FROM (
--		SELECT SUM(Quantity*Price) AS SumMU FROM tmp_Raschet_9_mu
--		UNION all
--		SELECT SUM(Tariff) FROM tmp_Raschet_9_mes
--	) t

/* --общая сумма
SELECT SUM(c.AmountPayment)
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
		f.id=a.rf_idFiles				
		AND  a.rf_idSMO<>'34' 
				INNER JOIN dbo.t_RecordCasePatient r ON
		a.id=r.rf_idRegistersAccounts
				INNER JOIN dbo.t_Case c  ON
		r.id=c.rf_idRecordCasePatient
WHERE a.ReportYear=2013 AND a.ReportMonth>=1 AND a.ReportMonth<10  AND f.DateRegistration>'20130101' AND f.DateRegistration<'20131008' AND c.rf_idV006=3
*/
SELECT 'Диспансеризация',CAST(SUM(SumDisp) AS MONEY) AS Disp
FROM (
	SELECT SUM(c.AmountPayment) AS SumDisp
	FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles				
			AND  a.rf_idSMO<>'34' 
						INNER JOIN (VALUES('D'),('R'),('O'),('F'),('V'),('U'),('I')) v(Letter) ON											
			a.Letter=v.Letter				
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c  ON
			r.id=c.rf_idRecordCasePatient
	WHERE a.ReportYear=2013 AND a.ReportMonth>=1 AND a.ReportMonth<10 AND f.DateRegistration>'20130101' AND f.DateRegistration<'20131008' 
	UNION ALL 
	SELECT SUM(c.AmountPayment)
	FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles				
			AND  a.rf_idSMO<>'34' 					
			AND a.Letter='A'
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c  ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN t_mes mes ON
			c.id=mes.rf_idCase			
	WHERE a.ReportYear=2013 AND a.ReportMonth>=1 AND a.ReportMonth<10 AND f.DateRegistration>'20130101' AND f.DateRegistration<'20131008' AND mes.Mes LIKE '70.5.%'
	) t
-------------------------------------------------------------------------------
UNION ALL
SELECT 'Стоматология',CAST(SUM(m.Quantity*m.Price) AS MONEY) AS Sum57
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles				
			AND  a.rf_idSMO<>'34' 										
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c  ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase
			AND m.MUGroupCode=57			
WHERE a.ReportYear=2013 AND a.ReportMonth>=1 AND a.ReportMonth<10  AND f.DateRegistration>'20130101' AND f.DateRegistration<'20131008' 
UNION ALL
-------------------------------------------------------------------------------
SELECT 'Гемодиализ',CAST(SUM(m.Quantity*m.Price)  AS MONEY) AS Sum60
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles				
			AND  a.rf_idSMO<>'34' 										
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c  ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase
			AND m.MUGroupCode=60
			AND m.MUUnGroupCode=2
			AND m.MUCode=5
WHERE a.ReportYear=2013 AND a.ReportMonth>=1 AND a.ReportMonth<10  AND f.DateRegistration>'20130101' AND f.DateRegistration<'20131008' 
UNION ALL
-------------------------------------------------------------------------------
SELECT 'Дерматология',CAST(SUM(m.Quantity*m.Price) AS MONEY) AS SumDermat
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles				
			AND  a.rf_idSMO<>'34' 										
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c  ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase
					INNER JOIN (SELECT MUGroupCode,MUUnGroupCode,MUCode FROM dbo.vw_sprMU WHERE MUGroupCode=2 AND MUUnGroupCode=78 AND MUCode=5
								UNION ALL 
								SELECT MUGroupCode,MUUnGroupCode,MUCode FROM dbo.vw_sprMU WHERE MUGroupCode=2 AND MUUnGroupCode=79 AND MUCode=6
								UNION ALL 
								SELECT MUGroupCode,MUUnGroupCode,MUCode FROM dbo.vw_sprMU WHERE MUGroupCode=2 AND MUUnGroupCode=81 AND MUCode=6
								) sprMU on
			m.MUGroupCode=sprMU.MUGroupCode
			AND m.MUUnGroupCode=sprMU.MUUnGroupCode
			AND m.MUCode=sprMU.MUCode
WHERE a.ReportYear=2013 AND a.ReportMonth>=1 AND a.ReportMonth<10  AND f.DateRegistration>'20130101' AND f.DateRegistration<'20131008' 