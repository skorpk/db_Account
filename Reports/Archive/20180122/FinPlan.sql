USE AccountOMS
GO		
CREATE PROCEDURE usp_InsertIntoCaseFinancePlan
		@dtBegin DATETIME,	
		@reportYear SMALLINT
as
DECLARE @dtEndReg DATE=GETDATE()
CREATE TABLE #tmpCases(id INT,DateRegistration DATETIME,CodeM CHAR(6), rf_idCase bigint,AmountPayment decimal(15,2),DateEnd date,rf_idV006 tinyint, Quantity INT,UnitCode int)
/*ЗС и КСГ*/
INSERT #tmpCases( id ,DateRegistration ,CodeM ,rf_idCase ,AmountPayment ,DateEnd ,rf_idV006 ,Quantity,UnitCode)
SELECT f.id,f.DateRegistration,f.CodeM,c.id AS rf_idCase,c.AmountPayment, c.DateEnd,c.rf_idV006,
		CASE WHEN c.IsChildTariff=1 THEN m.Quantity*t1.ChildUET ELSE m.Quantity*t1.AdultUET END ,unitCode
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient															
					INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase            
					INNER JOIN (SELECT MU,beginDate,endDate,unitCode,ChildUET,AdultUET FROM dbo.vw_sprMU WHERE calculationType=1 
								UNION ALL 
								SELECT CSGCode,beginDate,endDate,UnitCode,ChildUET, AdultUET FROM oms_nsi.dbo.vw_CSGPlanUnit WHERE calculationType=1
								) t1 ON
		m.MES=t1.MU			
		AND t1.unitCode IS NOT NULL
WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<=@dtEndReg AND a.ReportYear=@reportYear AND c.DateEnd>= t1.beginDate AND c.DateEnd<=t1.endDate
	AND NOT EXISTS(SELECT 1 FROM dbo.t_CaseFinancePlan WHERE id=f.id)

INSERT #tmpCases( id ,DateRegistration ,CodeM ,rf_idCase ,AmountPayment ,DateEnd ,rf_idV006 ,Quantity,UnitCode)
SELECT f.id,f.DateRegistration,f.CodeM,c.id AS rf_idCase,c.AmountPayment, c.DateEnd,c.rf_idV006,1,unitCode
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient															
					INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase            
					INNER JOIN (SELECT MU,beginDate,endDate,unitCode,ChildUET,AdultUET FROM dbo.vw_sprMU WHERE calculationType=2 
								UNION ALL 
								SELECT CSGCode,beginDate,endDate,UnitCode,ChildUET, AdultUET FROM oms_nsi.dbo.vw_CSGPlanUnit WHERE calculationType=2
								) t1 ON
		m.MES=t1.MU			
		AND t1.unitCode IS NOT NULL
WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<=@dtEndReg AND a.ReportYear=@reportYear AND c.DateEnd>= t1.beginDate AND c.DateEnd<=t1.endDate
		AND NOT EXISTS(SELECT 1 FROM dbo.t_CaseFinancePlan WHERE id=f.id)
/*Медуслуги*/
INSERT #tmpCases( id ,DateRegistration ,CodeM ,rf_idCase ,AmountPayment ,DateEnd ,rf_idV006 ,Quantity,UnitCode)
SELECT f.id,f.DateRegistration,f.CodeM,c.id AS rf_idCase,c.AmountPayment, c.DateEnd,c.rf_idV006,
		CASE WHEN c.IsChildTariff=1 THEN m.Quantity*t1.ChildUET ELSE m.Quantity*t1.AdultUET END ,unitCode
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient															
					INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase            
					INNER JOIN dbo.vw_sprMU t1 ON
		m.MU=t1.MU
		AND t1.unitCode IS NOT NULL
WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<=@dtEndReg AND a.ReportYear=@reportYear AND c.DateEnd>= t1.beginDate AND c.DateEnd<=t1.endDate AND t1.calculationType=1
		AND NOT EXISTS(SELECT 1 FROM dbo.t_CaseFinancePlan WHERE id=f.id)

INSERT #tmpCases( id ,DateRegistration ,CodeM ,rf_idCase ,AmountPayment ,DateEnd ,rf_idV006 ,Quantity,UnitCode)
SELECT f.id,f.DateRegistration,f.CodeM,c.id AS rf_idCase,c.AmountPayment, c.DateEnd,c.rf_idV006,1,unitCode
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient															
					INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase            
					INNER JOIN dbo.vw_sprMU t1 ON
		m.MU=t1.MU			
		AND t1.unitCode IS NOT NULL
WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<=@dtEndReg AND a.ReportYear=@reportYear AND c.DateEnd>= t1.beginDate AND c.DateEnd<=t1.endDate AND t1.calculationType=2
		AND NOT EXISTS(SELECT 1 FROM dbo.t_CaseFinancePlan WHERE id=f.id)

INSERT dbo.t_CaseFinancePlan( id ,DateRegistration ,CodeM ,rf_idCase ,AmountPayment ,DateEnd ,rf_idV006 ,Quantity ,UnitCode)
SELECT id ,DateRegistration ,CodeM ,rf_idCase ,AmountPayment ,DateEnd ,rf_idV006 ,Quantity ,UnitCode FROM #tmpCases

DELETE FROM dbo.t_CaseFinancePlan WHERE NOT EXISTS(SELECT  1 FROM dbo.t_File f WHERE f.id=id)
DROP TABLE #tmpCases