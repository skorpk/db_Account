USE AccountOMS
GO
DECLARE @startDateReg DATETIME='20180110',
		@endDateReg DATETIME='20180714',
		@reportYear smallint=2018,
		@reportMonth TINYINT=6

;WITH cte
AS
(
SELECT rr.ENP ,rr.Date_I ,rr.METHOD,r.id
--INTO #tPeople
from dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
		f.id=a.rf_idFiles				             
				inner JOIN dbo.t_RecordCasePatient r ON
		a.id=r.rf_idRegistersAccounts
				INNER JOIN dbo.t_PatientSMO p ON
		r.id=p.rf_idRecordCasePatient           		
				INNER JOIN dbo.t_Case c ON
		r.id=c.rf_idRecordCasePatient		              
				INNER JOIN dbo.t_DispInfo d ON
		c.id=d.rf_idCase
				INNER JOIN dbo.t_R03_ENP_DVN rr ON
		rr.ENP=p.ENP
WHERE f.DateRegistration>@startDateReg AND f.DateRegistration<=@endDateReg AND a.ReportMonth<=@reportMonth AND a.ReportYear=@reportYear 
		AND c.DateEnd>='20180101' AND c.DateEnd<'20180701' AND a.Letter='O' AND d.TypeDisp IN ('ÄÂ1','ÄÂ3') AND a.rf_idSMO<>'34'
)
SELECT rr.SMO,rr.ENP,rr.Date_I ,rr.METHOD, c.id
INTO #tPeople
FROM  dbo.t_R03_ENP_DVN rr LEFT JOIN cte c ON
			rr.ENP=c.ENP				  
SELECT s.smocod, s.sNameS, COUNT(ENP) AS Col3
		,COUNT(CASE WHEN p.id IS NOT NULL THEN ENP ELSE NULL END) AS Col4
		,COUNT(CASE WHEN p.METHOD=3 and p.id is not null THEN ENP ELSE NULL End) AS col5
		,COUNT(CASE WHEN p.METHOD=1 and p.id is not null THEN ENP ELSE NULL End) AS col6
		,COUNT(CASE WHEN p.METHOD=4 and p.id is not null THEN ENP ELSE NULL End) AS col7
		,COUNT(CASE WHEN p.METHOD=8 and p.id is not null THEN ENP ELSE NULL End) AS col8
		,COUNT(CASE WHEN p.METHOD=2 and p.id is not null THEN ENP ELSE NULL End) AS col9
		,COUNT(CASE WHEN p.METHOD=9 and p.id is not null THEN ENP ELSE NULL End) AS col10
		,COUNT(CASE WHEN p.METHOD IN(5,6,7) and p.id is not null  THEN ENP ELSE NULL End) AS col11
FROM #tPeople p INNER JOIN dbo.vw_sprSMO s ON
		p.SMO=s.smocod	
GROUP BY s.smocod, s.sNameS
ORDER BY  s.smocod
GO
DROP TABLE #tPeople			