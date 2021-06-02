USE AccountOMSReports
GO
alter VIEW dbo.vw_ReasonDenial
AS
WITH t1
AS(
SELECT p.rf_idCase,p.idAkt, RTRIM(f.Reason) AS Reason,row_number() over(partition by p.rf_idCase,p.idAkt order by p.rf_idCase,p.idAkt) rn
FROM dbo.t_PaymentAcceptedCase2 AS p INNER JOIN dbo.t_ReasonDenialPayment AS r ON 
		p.rf_idCase = r.rf_idCase 
		AND p.idAkt = r.idAkt 
				INNER JOIN oms_nsi.dbo.sprF014 AS f ON 
		r.CodeReason = f.ID
WHERE p.DateRegistration>'20190101'
),
tr(rf_idCase,idAkt, Reason,lev) as
	(select t1.rf_idCase,idAkt, cast(t1.Reason as nvarchar) , 2 from t1 where t1.rn = 1
	union all
	select t1.rf_idCase, t1.idAkt,cast(tr.Reason +','+t1.Reason as nvarchar), lev + 1
	from t1 join tr on (t1.rf_idCase = tr.rf_idCase AND t1.idAkt = tr.idAkt and t1.rn = tr.lev
	)
)
select rf_idCase,idAkt, max(Reason) names from tr group by rf_idCase , idakt