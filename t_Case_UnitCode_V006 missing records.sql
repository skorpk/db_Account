USE AccountOMS
GO
SELECT c.id
INTO #t
FROM dbo.t_Case c
WHERE DateEnd>'20180101' AND NOT EXISTS(SELECT * FROM dbo.t_Case_UnitCode_V006 WHERE rf_idCase=c.id)

SELECT MU,beginDate,endDate,unitCode,ChildUET,AdultUET INTO #tmpMU1 FROM RegisterCases.dbo.vw_sprMU WHERE unitCode IS NOT NULL --AND calculationType=1

SELECT CSGCode AS MU,beginDate,endDate,UnitCode,ChildUET, AdultUET INTO #tmpMU2  FROM oms_nsi.dbo.vw_CSGPlanUnit WHERE unitCode IS NOT NULL --AND calculationType=2

SELECT a.rf_idSMO, m.MES , c.DateEnd, t1.beginDate, t1.endDate, c.id
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles				
				INNER JOIN dbo.t_RecordCasePatient r ON
		a.id=r.rf_idRegistersAccounts				
				INNER JOIN dbo.t_Case c  ON
		r.id=c.rf_idRecordCasePatient
				INNER JOIN #t t on
		c.id=t.id
				INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase 
				INNER JOIN #tmpMU1 t1  ON
		m.MES=t1.MU		  
WHERE DateRegistration<'20181128' --AND c.DateEnd>= t1.beginDate AND c.DateEnd<=t1.endDate
--GROUP BY a.rf_idSMO, m.MES , c.DateEnd, t1.beginDate, t1.endDate
ORDER BY c.id
GO

DROP TABLE #t
DROP TABLE #tmpMU1
DROP TABLE #tmpMU2