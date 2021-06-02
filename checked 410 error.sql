USE AccountOMS
GO
SELECT a.ReportMonth,c.id,c.IsNeedDisp,d2.IsNeedDisp, c.GUID_Case, a.Account, f.CodeM, f.FileNameHR
from t_File f INNER JOIN dbo.t_RegistersAccounts a ON
		f.id=a.rf_idFiles
		AND a.ReportYear=2018
			  inner join dbo.t_RecordCasePatient r on
		a.id=r.rf_idRegistersAccounts
			  inner join t_Case c on
		r.id=c.rf_idRecordCasePatient					
		AND c.DateEnd>='20180101'
			LEFT JOIN (SELECT rf_idCase,SUM(IsNeedDisp) AS IsNeedDisp from dbo.t_DS2_Info GROUP BY rf_idCase) d2 ON
		c.id=d2.rf_idCase          
where f.DateRegistration>'20180321' AND a.Letter='O'  AND c.rf_idV009 IN(355,356) AND (ISNULL(c.IsNeedDisp,0)<1 and ISNULL(d2.IsNeedDisp,0)<1)
ORDER BY a.ReportMonth DESC

SELECT d2.*
from t_File f INNER JOIN dbo.t_RegistersAccounts a ON
		f.id=a.rf_idFiles
		AND a.ReportYear=2018
			  inner join dbo.t_RecordCasePatient r on
		a.id=r.rf_idRegistersAccounts
			  inner join t_Case c on
		r.id=c.rf_idRecordCasePatient					
		AND c.DateEnd>='20180101'
			LEFT JOIN dbo.t_DS2_Info d2 ON
		c.id=d2.rf_idCase          
where c.GUID_Case='765E6B0B-CC25-F23A-E2A4-8DB1B57608E7'
ORDER BY a.ReportMonth desc