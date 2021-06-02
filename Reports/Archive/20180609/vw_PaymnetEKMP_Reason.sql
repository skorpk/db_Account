USE AccountOMS
go
CREATE VIEW vw_PaymnetEKMP_Reason
as
SELECT DateRegistration,p.rf_idCase,f.Reason
FROM dbo.t_PaymentAcceptedCase2 p  LEFT JOIN dbo.t_ReasonDenialPayment r ON
				p.rf_idCase=r.rf_idCase
				AND p.idAkt=r.idAkt
							LEFT JOIN oms_nsi.dbo.sprF014 f ON
				r.CodeReason=f.ID                          
WHERE TypeCheckup=3