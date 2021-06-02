USE AccountOMS
GO
DECLARE @dtBegin DATETIME='20180101',	
		@dtEnd DATETIME=GETDATE(),
		@reportYear SMALLINT=2018

SELECT MU,beginDate,endDate,unitCode,ChildUET,AdultUET INTO #tCSG_MUUnitCode FROM RegisterCases.dbo.vw_sprMU WHERE unitCode IS NOT NULL 
UNION ALL 
SELECT CSGCode,beginDate,endDate,UnitCode,ChildUET, AdultUET FROM oms_nsi.dbo.vw_CSGPlanUnit  WHERE unitCode IS NOT NULL 

CREATE NONCLUSTERED INDEX IX_MU1 ON #tCSG_MUUnitCode(MU,beginDate,endDate) INCLUDE(unitCode)	

SELECT DISTINCT c.id AS rf_idCase,t1.unitCode, c.rf_idV006
INTO #tCase_UnitCode
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
					INNER JOIN dbo.t_PatientSMO ps ON
			r.id=ps.rf_idRecordCasePatient                  
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient										
					INNER JOIN t_Mes m ON
			c.id=m.rf_idCase			
					INNER JOIN #tCSG_MUUnitCode t1 ON
			m.MES=t1.MU					
WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<@dtEnd AND ReportYear >=@reportYear
		AND c.DateEnd>= t1.beginDate AND c.DateEnd<=t1.endDate AND NOT EXISTS(SELECT 1 FROM dbo.t_Case_UnitCode_V006 u WHERE u.rf_idCase=c.id AND u.UnitCode=t1.unitCode)

INSERT #tCase_UnitCode 														
SELECT DISTINCT c.id AS rf_idCase,t1.unitCode, c.rf_idV006
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
					INNER JOIN dbo.t_PatientSMO ps ON
			r.id=ps.rf_idRecordCasePatient                  
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient										
					INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase			
					INNER JOIN #tCSG_MUUnitCode t1 ON
			m.MU=t1.MU					
WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<@dtEnd AND ReportYear >=@reportYear
		AND c.DateEnd>= t1.beginDate AND c.DateEnd<=t1.endDate AND NOT EXISTS(SELECT 1 FROM dbo.t_Case_UnitCode_V006 u WHERE u.rf_idCase=c.id AND u.UnitCode=t1.unitCode)

go
INSERT dbo.t_Case_UnitCode_V006( rf_idCase, UnitCode, V006 )
SELECT rf_idCase,unitCode, rf_idV006 FROM #tCase_UnitCode
GO
DROP TABLE #tCSG_MUUnitCode
DROP TABLE #tCase_UnitCode