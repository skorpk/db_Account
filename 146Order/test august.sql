USE AccountOMS
go

DECLARE @codem CHAR(6)='395301'
SELECT f.CodeM,SUM(case when m.IsChildTariff=1 then m.Quantity*t1.ChildUET else m.Quantity*t1.AdultUET end) as Quantity
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient								
					INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase
					INNER JOIN dbo.vw_sprMU t1 ON
			m.MUGroupCode=t1.MUGroupCode
			AND m.MUUnGroupCode=t1.MUUnGroupCode
			AND m.MUCode=t1.MUCode
			AND t1.unitCode IS NOT NULL					                  
WHERE f.DateRegistration>'20160801' AND f.DateRegistration<'20160911' AND a.ReportYear=2016 /*AND a.ReportMonth=8 AND c.DateEnd>='20160801'*/ AND f.CodeM=@codem
GROUP BY f.CodeM

SELECT f.CodeM,SUM(case when c.IsChildTariff=1 then m.Quantity*t1.ChildUET else m.Quantity*t1.AdultUET end) as Quantity
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient								
					INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase
					INNER JOIN dbo.vw_sprMU t1 ON
			m.MES=t1.MU			
			AND t1.unitCode IS NOT NULL					                  
WHERE f.DateRegistration>'20160801' AND f.DateRegistration<'20160911' AND a.ReportYear=2016 /*AND a.ReportMonth=8 AND c.DateEnd>='20160801'*/ AND f.CodeM=@codem
GROUP BY f.CodeM

SELECT f.CodeM,SUM(case when m.IsChildTariff=1 then m.Quantity*t1.ChildUET else m.Quantity*t1.AdultUET end) as Quantity
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient								
					INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase
					INNER JOIN dbo.vw_sprDentalUET t1 ON
			m.MUSurgery=t1.code
WHERE f.DateRegistration>'20160801' AND f.DateRegistration<'20160911' AND a.ReportYear=2016 /*AND a.ReportMonth=8 AND c.DateEnd>='20160801'*/ AND f.CodeM=@codem
GROUP BY f.CodeM
