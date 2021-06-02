USE AccountOMS
GO
DROP TABLE tmp_Raschet_9_mu
DROP TABLE tmp_Raschet_9_mes

SELECT f.DateRegistration, a.ReportYear, a.ReportMonth,a.Letter, ISNULL(r.AttachLPU,'000000') AS AttachLPU
	  ,c.id, m.MUGroupCode,m.MUUnGroupCode,m.MUCode, f.CodeM, a.rf_idSMO, m.Quantity, m.Price	 
INTO tmp_Raschet_9_mu
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles				
			AND  a.rf_idSMO<>'34'
				INNER JOIN dbo.t_RecordCasePatient r ON
		a.id=r.rf_idRegistersAccounts
				INNER JOIN dbo.t_Case c  ON
		r.id=c.rf_idRecordCasePatient
		AND c.IsCompletedCase=0				
				INNER JOIN dbo.t_Meduslugi m on
			c.id=m.rf_idCase				
WHERE f.DateRegistration>'20130101' AND f.DateRegistration<'20131008' AND c.rf_idV006=3 AND a.ReportYear=2013
		AND a.ReportMonth>=1 AND a.ReportMonth<10

SELECT f.DateRegistration, a.ReportYear, a.ReportMonth, a.Letter, ISNULL(r.AttachLPU,'000000') AS AttachLPU
	  ,c.id, m.MES, f.CodeM, a.rf_idSMO, m.Tariff
INTO tmp_Raschet_9_mes
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles				
			AND  a.rf_idSMO<>'34'
				INNER JOIN dbo.t_RecordCasePatient r ON
		a.id=r.rf_idRegistersAccounts
				INNER JOIN dbo.t_Case c  ON
		r.id=c.rf_idRecordCasePatient
		AND c.IsCompletedCase=1			
				INNER JOIN dbo.t_MES m on
			c.id=m.rf_idCase				
WHERE f.DateRegistration>'20130101' AND f.DateRegistration<'20131008' AND c.rf_idV006=3 AND a.ReportYear=2013
		AND a.ReportMonth>=1 AND a.ReportMonth<10
-----------------------------------------------------------------------------------------------------------------
SELECT SUM(SumMU)
FROM (
		SELECT SUM(Quantity*Price) AS SumMU FROM tmp_Raschet_9_mu
		UNION all
		SELECT SUM(Tariff) FROM tmp_Raschet_9_mes
	) t
/*
delete from tmp_Raschet_9_mes where MES like '70.3.%'
delete from tmp_Raschet_9_mes where MES like '70.5.%'
delete from tmp_Raschet_9_mes where MES like '70.6.%'
delete from tmp_Raschet_9_mes where MES like '72.%'

delete from tmp_Raschet_9_mu where MUGroupCode=2 and MUUnGroupCode in (83,84,85,86,87)
delete from tmp_Raschet_9_mu where MUGroupCode=57
delete from tmp_Raschet_9_mu where MUGroupCode=60 and MUUnGroupCode =2 and MUCode=5

delete from tmp_Raschet_9_mu where MUGroupCode=2 and MUUnGroupCode =78 and MUCode=5
delete from tmp_Raschet_9_mu where MUGroupCode=2 and MUUnGroupCode =79 and MUCode=6
delete from tmp_Raschet_9_mu where MUGroupCode=2 and MUUnGroupCode =81 and MUCode=5

*/