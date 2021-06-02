USE AccountOMS
GO
--CREATE VIEW vw_LN_Total
--as
WITH cteDiag
AS(
SELECT t.rf_idV002 AS PROFIL,COUNT(id) AS Col2,0 AS Col3,'' AS Col4,0 AS Col5,0 AS Col6,0 AS Col7,0 AS Col8,0 AS Col9,0 AS Col10
FROM dbo.T_ZAPROS_18_04_2018 t 
GROUP BY t.rf_idV002
UNION ALL
SELECT z.rf_idV002,0,COUNT(z.id) AS Col3,l.DS_OSN AS Col4,0 AS Col5,0 AS Col6,0 AS Col7,0 AS Col8,0 AS Col9,0 AS Col10
FROM dbo.T_ZAPROS_18_04_2018 z INNER JOIN dbo.Table_LN l ON
			z.rf_idV002=l.PROFIL
			AND z.DS=l.DS_OSN
WHERE z.kol>l.SROK1
GROUP BY z.rf_idV002,l.DS_OSN
UNION ALL
SELECT z.rf_idV002,0,COUNT(z.id) AS Col3,'' AS Col4,COUNT(DISTINCT z.id) AS Col5,0 AS Col6,0 AS Col7,0 AS Col8,0 AS Col9,0 AS Col10
FROM dbo.T_ZAPROS_18_04_2018 z INNER JOIN dbo.Table_LN l ON
			z.rf_idV002=l.PROFIL
			AND z.DS=l.DS_OSN
							INNER JOIN dbo.t_PaymentAcceptedCase2 p ON
			z.id=p.rf_idCase                          
WHERE z.kol>l.SROK1 AND p.TypeCheckup>1
GROUP BY z.rf_idV002
UNION ALL
SELECT z.rf_idV002,0,0 AS Col3,'' AS Col4,0 AS Col5,COUNT(DISTINCT z.id) AS Col6,0 AS Col7,0 AS Col8,0 AS Col9,0 AS Col10
FROM dbo.T_ZAPROS_18_04_2018 z INNER JOIN dbo.t_PaymentAcceptedCase2 p ON
			z.id=p.rf_idCase                          
WHERE p.AmountDeduction>0
GROUP BY z.rf_idV002
UNION ALL
SELECT z.rf_idV002,0,0 AS Col3,'' AS Col4,0 AS Col5,0 AS Col6,COUNT(DISTINCT z.id) AS Col7,0 AS Col8,0 AS Col9,0 AS Col10
FROM dbo.T_ZAPROS_18_04_2018 z INNER JOIN dbo.t_PaymentAcceptedCase2 p ON
			z.id=p.rf_idCase                      
								INNER JOIN dbo.vw_sprReasonDenialPayment r ON
			p.idAkt=r.idAkt
			AND p.rf_idCase=r.rf_idCase
WHERE p.AmountDeduction>0 AND r.CodeReason LIKE '3.%'
GROUP BY z.rf_idV002
UNION ALL
SELECT z.rf_idV002,0,0 AS Col3,'' AS Col4,0 AS Col5,0 AS Col6,0 AS Col7,COUNT(DISTINCT z.id) AS Col8,0 AS Col9,0 AS Col10
FROM dbo.T_ZAPROS_18_04_2018 z INNER JOIN dbo.t_PaymentAcceptedCase2 p ON
			z.id=p.rf_idCase                      
								INNER JOIN dbo.vw_sprReasonDenialPayment r ON
			p.idAkt=r.idAkt
			AND p.rf_idCase=r.rf_idCase
WHERE p.AmountDeduction>0 AND r.CodeReason LIKE '3.2.3.'
GROUP BY z.rf_idV002
UNION ALL
SELECT z.rf_idV002,0,0 AS Col3,'' AS Col4,0 AS Col5,0 AS Col6,0 AS Col7,0 AS Col8,COUNT(DISTINCT z.id) AS Col9,0 AS Col10
FROM dbo.T_ZAPROS_18_04_2018 z INNER JOIN dbo.t_PaymentAcceptedCase2 p ON
			z.id=p.rf_idCase                      
								INNER JOIN dbo.vw_sprReasonDenialPayment r ON
			p.idAkt=r.idAkt
			AND p.rf_idCase=r.rf_idCase
WHERE p.AmountDeduction>0 AND r.CodeReason LIKE '3.6.'
GROUP BY z.rf_idV002
)
SELECT TOP 100 PERCENT v2.id,v2.name AS PROFIL ,
        SUM(Col2) AS Col2 ,
        SUM(Col3) AS Col3 ,
        Col4 ,
        sum(Col5) as Col5,
        sum(Col6) as Col6,
        sum(Col7) as Col7,
        sum(Col8) as Col8,
        sum(Col9) as Col9,
		sum(Col7)-sum(Col8)-sum(Col9) AS Col10        
FROM cteDiag c INNER JOIN RegisterCases.dbo.vw_sprV002 v2 ON
		   c.PROFIL=v2.id
GROUP BY v2.id,v2.name,Col4
ORDER BY v2.id