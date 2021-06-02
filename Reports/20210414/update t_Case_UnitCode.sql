use AccountOMS
GO
/*
select sum(m.Quantity)
from t_File f inner join t_RegistersAccounts ra on f.id=ra.rf_idFiles
              join t_RecordCasePatient rcp on rcp.rf_idRegistersAccounts=ra.id
              join t_case c on c.rf_idRecordCasePatient=rcp.id                                            
              join t_Meduslugi m on m.rf_idCase=c.id
			  JOIN RegisterCases.dbo.vw_sprMU mm ON
              m.MU=mm.MU
			   AND c.DateEnd BETWEEN mm.beginDate AND mm.endDate
where c.rf_idV006=3 and   ra.ReportYear=2021 and ra.ReportMonth<4 and m.MUGroupCode=2 and m.MUUnGroupCode in (79,81,88)
	AND f.DateRegistration between '20210101' AND '20210411'

select c.id
from t_File f inner join t_RegistersAccounts ra on f.id=ra.rf_idFiles
              join t_RecordCasePatient rcp on rcp.rf_idRegistersAccounts=ra.id
              join t_case c on c.rf_idRecordCasePatient=rcp.id                                            
              join t_Meduslugi m on m.rf_idCase=c.id
			  JOIN RegisterCases.dbo.vw_sprMU mm ON
              m.MU=mm.MU
			   AND c.DateEnd BETWEEN mm.beginDate AND mm.endDate
where c.rf_idV006=3 and   ra.ReportYear=2021 and ra.ReportMonth<4 and m.MUGroupCode=2 and m.MUUnGroupCode in (79,81,88)
	AND f.DateRegistration between '20210101' AND '20210411'
	AND NOT EXISTS(select 1 FROM dbo.t_Case_UnitCode_V006 v WHERE v.rf_idCase=c.id)

;WITH cte
AS(
select  c.id , sum(m.Quantity) AS mQuantity
from t_File f inner join t_RegistersAccounts ra on f.id=ra.rf_idFiles
              join t_RecordCasePatient rcp on rcp.rf_idRegistersAccounts=ra.id
              join t_case c on c.rf_idRecordCasePatient=rcp.id                                            
              join t_Meduslugi m on m.rf_idCase=c.id			  
where c.rf_idV006=3 and   ra.ReportYear=2021 and ra.ReportMonth<4 and m.MUGroupCode=2 and m.MUUnGroupCode in (79,81,88)
	AND f.DateRegistration between '20210101' AND '20210411'
GROUP BY c.id
)
	SELECT c.id,c.mQuantity,v.Qunatity
	FROM cte c JOIN dbo.t_Case_UnitCode_V006 v on 
			c.id=v.rf_idCase 
	WHERE c.mQuantity!=v.Qunatity

	*/
BEGIN TRANSACTION	
;WITH cte
AS(
select  c.id , sum(m.Quantity) AS mQuantity
from t_File f inner join t_RegistersAccounts ra on f.id=ra.rf_idFiles
              join t_RecordCasePatient rcp on rcp.rf_idRegistersAccounts=ra.id
              join t_case c on c.rf_idRecordCasePatient=rcp.id                                            
              join t_Meduslugi m on m.rf_idCase=c.id			  
where c.rf_idV006=3 and   ra.ReportYear=2021 and ra.ReportMonth<4 and m.MUGroupCode=2 and m.MUUnGroupCode in (79,81,88)
	AND f.DateRegistration between '20210101' AND '20210411'
GROUP BY c.id
)
	UPDATE v SET v.Qunatity=c.mQuantity
	FROM cte c JOIN dbo.t_Case_UnitCode_V006 v on 
			c.id=v.rf_idCase 
	WHERE c.mQuantity!=v.Qunatity

;WITH cte
AS(
select  c.id , sum(m.Quantity) AS mQuantity
from t_File f inner join t_RegistersAccounts ra on f.id=ra.rf_idFiles
              join t_RecordCasePatient rcp on rcp.rf_idRegistersAccounts=ra.id
              join t_case c on c.rf_idRecordCasePatient=rcp.id                                            
              join t_Meduslugi m on m.rf_idCase=c.id			  
where c.rf_idV006=3 and   ra.ReportYear=2021 and ra.ReportMonth<4 and m.MUGroupCode=2 and m.MUUnGroupCode in (79,81,88)
	AND f.DateRegistration between '20210101' AND '20210411'
GROUP BY c.id
)
	SELECT c.id,c.mQuantity,v.Qunatity
	FROM cte c JOIN dbo.t_Case_UnitCode_V006 v on 
			c.id=v.rf_idCase 
	WHERE c.mQuantity!=v.Qunatity
commit
/*
select COUNT (distinct c.id ),  sum(m.Quantity),m.MU
from t_File f inner join t_RegistersAccounts ra on f.id=ra.rf_idFiles
              join t_RecordCasePatient rcp on rcp.rf_idRegistersAccounts=ra.id
              join t_case c on c.rf_idRecordCasePatient=rcp.id                                            
              join t_Meduslugi m on m.rf_idCase=c.id			  
where c.rf_idV006=3 and   ra.ReportYear=2021 and ra.ReportMonth<4 and m.MUGroupCode=2 and m.MUUnGroupCode in (79,81,88)
		AND NOT EXISTS(SELECT 1 FROM RegisterCases.dbo.vw_sprMU mm WHERE m.MU=mm.MU AND c.DateEnd BETWEEN mm.beginDate AND mm.endDate)
	AND f.DateRegistration between '20210101' AND '20210411'
GROUP BY m.MU

;WITH cte
AS(
select  c.id , sum(m.Quantity) AS mQuantity
from t_File f inner join t_RegistersAccounts ra on f.id=ra.rf_idFiles
              join t_RecordCasePatient rcp on rcp.rf_idRegistersAccounts=ra.id
              join t_case c on c.rf_idRecordCasePatient=rcp.id                                            
              join t_Meduslugi m on m.rf_idCase=c.id			  
where c.rf_idV006=3 and   ra.ReportYear=2021 and ra.ReportMonth<4 and m.MUGroupCode=2 and m.MUUnGroupCode in (79,81,88)
	AND f.DateRegistration between '20210101' AND '20210411'
GROUP BY c.id
)
	SELECT SUM(c.mQuantity),SUM(v.Qunatity)	
	FROM cte c JOIN dbo.t_Case_UnitCode_V006 v on 
	c.id=v.rf_idCase 
*/
