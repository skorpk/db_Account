USE AccountOMSReports
GO
alter VIEW vw_PaymentAcceptedCaseReason2019
as
SELECT p.rf_idCase,p.DateRegistration,p.DocumentNumber+' - '+CONVERT(VARCHAR(10),p.DocumentDate,104) AS DocNumDate,p.TypeCheckup,p.AmountDeduction , f.Reason
FROM dbo.t_PaymentAcceptedCase2 p LEFT JOIN dbo.t_ReasonDenialPayment r ON
			p.rf_idCase = r.rf_idCase
			AND p.idAkt = r.idAkt
									LEFT JOIN oms_NSI.dbo.sprF014 f ON
			r.CodeReason=f.ID                                  
WHERE DateRegistration>='20190101'