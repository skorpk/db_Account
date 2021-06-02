USE AccountOMS
GO
declare @dateStartReg DATETIME='20160101',
		@dateEndReg DATETIME='20170120 23:59:59',
		@reportYear SMALLINT=2016,
		@reportMonthStart TINYINT=1,
		@reportMonthEnd TINYINT=12

CREATE TABLE #tmpCases(PID INT,rf_idCase BIGINT,DateSetCanser DATE,rf_idV015 int)
CREATE NONCLUSTERED INDEX IX1 on #tmpCases(rf_idCase) INCLUDE(rf_idV015,pid)
--переделать на таблицу в PeopleAttach
INSERT #tmpCases( PID, rf_idCase,DateSetCanser,rf_idV015)
SELECT c.PID,c.rf_idCase,p.DD,cc.rf_idV015
FROM PeopleAttach.dbo.sk p INNER JOIN dbo.t_Case_PID_ENP c ON
		p.pid=c.PID 
							INNER JOIN PeopleAttach.dbo.t_CGS cc ON
		p.cgs=cc.id  
WHERE p.PID IS NOT NULL and c.ReportYear=@reportYear 

;WITH cteDisp
AS
(
SELECT TOP 1 WITH TIES c1.PID,c.id AS rf_idCase,a.Letter
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles				
				INNER JOIN dbo.t_RecordCasePatient r ON
		a.id=r.rf_idRegistersAccounts				
				INNER JOIN dbo.t_Case c  ON
		r.id=c.rf_idRecordCasePatient
				INNER JOIN 	#tmpCases c1 ON
		c.id=c1.rf_idCase              				
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg AND a.ReportYear=@reportYear 
		AND a.ReportMonth>=@reportMonthStart AND a.ReportMonth<=@reportMonthEnd 
		AND a.Letter IN ('O','R','V','I','U','D','F')
ORDER BY ROW_NUMBER() OVER(PARTITION BY c1.pid ORDER BY c.DateEnd DESC) 
)
SELECT DISTINCT PID ,CASE WHEN Letter IN ('O','R','V','I','U','D','F') THEN 1 ELSE 0 END AS IsDisp INTO #tmpPeople FROM cteDisp


SELECT TOP 1 WITH TIES c1.PID,c.rf_idV004, DATEDIFF(MONTH,c.DateEnd,c1.DateSetCanser) AS DateMonth
INTO #tmpPeople2
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles				
				INNER JOIN dbo.t_RecordCasePatient r ON
		a.id=r.rf_idRegistersAccounts				
				INNER JOIN dbo.t_Case c  ON
		r.id=c.rf_idRecordCasePatient
				INNER JOIN 	#tmpCases c1 ON
		c.id=c1.rf_idCase              	   
		AND c.rf_idV004=c1.rf_idV015
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg AND a.ReportYear=@reportYear 
		AND a.ReportMonth>=@reportMonthStart AND a.ReportMonth<=@reportMonthEnd 
ORDER BY ROW_NUMBER() OVER(PARTITION BY c1.pid ORDER BY c.DateEnd DESC)

;WITH cteTotal
AS(
SELECT p.pid,ISNULL(s.Fam,'')+' '+ISNULL(s.Im,'')+' '+ISNULL(s.Ot,'') AS FIO,CONVERT(DATE,s.DR,104) as DR, CASE WHEN s.W=2 THEN 'Ж' ELSE 'М' END AS Sex,
		p.IsDisp,0 AS rf_idV004 ,NULL as Col1,NULL as Col2,NULL as Col3,NULL as Col4
FROM #tmpPeople p INNER JOIN PeopleAttach.dbo.sk s ON
		p.pid=s.PID 
UNION ALL
SELECT p.pid,ISNULL(s.Fam,'')+' '+ISNULL(s.Im,'')+' '+ISNULL(s.Ot,'') AS FIO,CONVERT(DATE,s.DR,104) as DR, CASE WHEN s.W=2 THEN 'Ж' ELSE 'М' END AS Sex,
		0,rf_idV004,CASE WHEN DateMonth<1 THEN 1 ELSE NULL END, CASE WHEN DateMonth>=1 AND DateMonth<3 THEN 1 ELSE NULL END, CASE WHEN DateMonth>=3 AND DateMonth<6 THEN 1 ELSE NULL END,
		 CASE WHEN DateMonth>=6 AND DateMonth<=12 THEN 1 ELSE NULL END
FROM #tmpPeople2 p INNER JOIN PeopleAttach.dbo.sk s ON
		p.pid=s.PID 					
)
SELECT  PId,FIO ,DR,sex,SUM(IsDisp) AS Disp,v4.name,COUNT(Col1) AS Month1,COUNT(Col2) AS Month2,COUNT(Col3) AS Month3,COUNT(Col4) AS Month4
FROM cteTotal FROM cte c left JOIN oms_nsi.dbo.sprV015 v4 ON
		c.rf_idV004=v4.CODE
GROUP BY PID,FIO ,DR,sex
ORDER BY fio,DR
GO
DROP TABLE #tmpCases
DROP TABLE #tmpPeople
DROP TABLE #tmpPeople2