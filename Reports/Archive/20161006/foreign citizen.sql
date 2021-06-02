USE AccountOMS
GO
SELECT  t.id ,
        t.Fam ,
        t.Im ,
        t.ot ,
        t.DR ,
        t.dateUchet ,
        t.DateDS ,
        t.DateEnd ,
        t.Step
INTO #tmpCase
FROM tmpCanserPeople t 		
WHERE NOT EXISTS(SELECT * FROM PolicyRegister.dbo.PEOPLE p WHERE t.Fam=p.FAM AND t.IM=p.IM AND t.Ot=p.OT AND t.DR=p.DR)	


--SELECT f.CodeM,a.rf_idSMO, a.Account, c.idRecordCase,a.ReportMonth,a.ReportYear,c.id AS rf_idCase, /*c1.PID,*/ c.rf_idV006, c.rf_idV002,c.rf_idDoctor,c.DateBegin,c.DateEnd,
--		d.DS1, CASE WHEN d.DS2 LIKE 'R%' THEN d.DS2 ELSE NULL END AS DS2,c.AmountPayment,c.AmountPayment AS AmountPaymentAcc
--		,r.NumberPolis,r.AttachLPU,c1.Step AS isTypeCanser
--		,pc.dateUchet ,pc.DateDS ,pc.DateEnd AS DateEndUchet
----INTO #tmpPeople
--FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
--			f.id=a.rf_idFiles				
--				INNER JOIN dbo.t_RecordCasePatient r ON
--		a.id=r.rf_idRegistersAccounts				
--				INNER JOIN dbo.t_Case c  ON
--		r.id=c.rf_idRecordCasePatient
--				INNER JOIN dbo.t_RegisterPatient p ON
--		r.id=p.rf_idRecordCase
--		AND f.id=p.rf_idFiles              
--				INNER JOIN 	#tmpCase c1 ON
--		p.Fam=c1.Fam AND p.Im=c1.Im AND p.BirthDay=c1.DR          
--				INNER JOIN dbo.vw_Diagnosis d ON
--		c.id=d.rf_idCase								
--				INNER JOIN RegisterCases.dbo.vw_sprV010 v10 ON
--		c.rf_idV010=v10.id	
--				INNER JOIN dbo.tmpCanserPeople pc ON
--		c1.id=pc.id																					  		
--WHERE f.DateRegistration>='20160101' AND f.DateRegistration<'20160906' AND a.ReportYear=2016 AND c.rf_idV006 IN(1,3,4)
--		AND d.DS1 LIKE 'C%'


SELECT count(DISTINCT CASE WHEN c.rf_idV006=1 THEN c.id ELSE NULL END) AS Stacionar,
		count(DISTINCT CASE WHEN c.rf_idV006=3 THEN c.id ELSE NULL END) AS Outpatient,
		count(DISTINCT CASE WHEN c.rf_idV006=4 THEN c.id ELSE NULL END) AS Ambulance
--INTO #tmpPeople
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles				
				INNER JOIN dbo.t_RecordCasePatient r ON
		a.id=r.rf_idRegistersAccounts				
				INNER JOIN dbo.t_Case c  ON
		r.id=c.rf_idRecordCasePatient
				INNER JOIN dbo.t_RegisterPatient p ON
		r.id=p.rf_idRecordCase
		AND f.id=p.rf_idFiles              
				INNER JOIN 	#tmpCase c1 ON
		p.Fam=c1.Fam AND p.Im=c1.Im AND p.BirthDay=c1.DR          
				INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase								
				INNER JOIN RegisterCases.dbo.vw_sprV010 v10 ON
		c.rf_idV010=v10.id	
				INNER JOIN dbo.tmpCanserPeople pc ON
		c1.id=pc.id																					  		
WHERE f.DateRegistration>='20160101' AND f.DateRegistration<'20160906' AND a.ReportYear=2016 AND c.rf_idV006 IN(1,3,4) AND a.rf_idSMO='34'
		AND d.DS1 LIKE 'C%'
GROUP BY a.rf_idSMO
--SELECT * FROM #tmpCase
GO
DROP TABLE #tmpCase