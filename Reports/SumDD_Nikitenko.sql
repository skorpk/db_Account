USE ExchangeFinancing
GO
CREATE TABLE #tAccount(Account VARCHAR(15),ReportYear SMALLINT,ReportMonth TINYINT,CodeM CHAR(6),CodeSMO VARCHAR(5))
INSERT #tAccount
		( Account ,
		  ReportYear ,
		  ReportMonth ,
		  CodeM ,
		  CodeSMO
		)
VALUES('34001-42-0D',2013,5,'101002','34001'),
('34001-479-1D',2013,5,'145516','34001'),
('34001-478-1D',2013,5,'145516','34001'),
('34002-479-1D',2013,5,'145516','34002'),
('34001-43-0D',2013,5,'101002','34001'),
('34001-478-2D',2013,5,'145516','34001'),
('34001-57-1D',2013,5,'361001','34001'),
('34002-13770-1D',2013,5,'251008','34002'),
('34001-13770-1D',2013,5,'251008','34001'),
('34001-57-0D',2013,5,'391003','34001'),
('34001-68-0D',2013,5,'431001','34001'),
('34002-68-0D',2013,5,'431001','34002'),
('34001-96-1D',2013,5,'185515','34001'),
('34001-133-1D',2013,5,'165525','34001'),
('34002-133-1D',2013,5,'165525','34002'),
('34001-42-0D',2013,5,'124530','34001'),
('34002-42-0D',2013,5,'124530','34002'),
('34002-58-0D',2013,5,'361001','34002'),
('34001-97-0D',2013,5,'185515','34001'),
('34002-97-0D',2013,5,'185515','34002'),
('34001-44-1D',2013,5,'481001','34001'),
('34001-45-0D',2013,6,'481001','34001'),
('34002-44-1D',2013,5,'481001','34002'),
('34002-45-0D',2013,6,'481001','34002'),
('34001-68-0D',2013,5,'135509','34001'),
('34002-68-0D',2013,5,'135509','34002'),
('34001-159-0D',2013,5,'145526','34001'),
('34002-159-0D',2013,5,'145526','34002'),
('34001-81-0D',2013,5,'591001','34001'),
('34002-81-0D',2013,5,'591001','34002'),
('34002-44-2D',2013,5,'481001','34002'),
('34001-96-2D',2013,5,'185515','34001'),
('34001-57-1D',2013,5,'131020','34001'),
('34001-58-0D',2013,5,'131020','34001'),
('34001-36-1D',2013,5,'175627','34001'),
('34002-36-1D',2013,5,'175627','34002'),
('34001-30-0D',2013,5,'155601','34001'),
('34002-30-0D',2013,5,'155601','34002'),
('34002-13770-2D',2013,5,'251008','34002'),
('34001-13770-2D',2013,5,'251008','34001'),
('34002-133-2D',2013,5,'165525','34002'),
('34002-58-0D',2013,5,'391003','34002'),
('34001-50-1D',2013,5,'601001','34001'),
('34001-51-1D',2013,6,'601001','34001'),
('34002-50-1D',2013,5,'601001','34002'),
('34002-51-1D',2013,6,'601001','34002'),
('34001-46-1D',2013,5,'611001','34001'),
('34002-46-1D',2013,5,'611001','34002'),
('34001-54-0D',2013,5,'541001','34001'),
('34002-54-0D',2013,5,'541001','34002'),
('34002-52-0D',2013,5,'601001','34002'),
('34001-91-1D',2013,5,'115506','34001'),
('34002-91-1D',2013,5,'115506','34002'),
('34001-46-0D',2013,5,'121018','34001'),
('34002-46-0D',2013,5,'121018','34002'),
('34001-69-0D',2013,5,'431001','34001'),
('34002-70-0D',2013,5,'431001','34002'),
('34001-31-0D',2013,5,'155601','34001'),
('34002-31-0D',2013,5,'155601','34002'),
('34001-52-1D',2013,5,'451002','34001'),
('34002-52-1D',2013,5,'451002','34002'),
('34001-63-1D',2013,5,'561001','34001'),
('34002-63-2D',2013,5,'561001','34002'),
('34002-63-1D',2013,5,'561001','34002'),
('34001-165-2D',2013,5,'145526','34001'),
('34001-44-1D',2013,5,'101002','34001'),
('34002-44-1D',2013,5,'101002','34002'),
('34002-44-2D',2013,5,'101002','34002'),
('34001-91-2D',2013,5,'115506','34001'),
('34002-46-2D',2013,5,'611001','34002'),
('34001-36-2D',2013,5,'175627','34001'),
('34001-41-0D',2013,5,'531001','34001'),
('34002-41-0D',2013,5,'531001','34002'),
('34002-38-0D',2013,5,'175627','34002'),
('34002-50-2D',2013,5,'601001','34002'),
('34001-13-0D',2013,5,'125505','34001'),
('34002-13-0D',2013,5,'125505','34002'),
('34002-59-0D',2013,5,'131020','34002'),
('34001-60-0D',2013,5,'131020','34001'),
('34001-13400-1D',2013,5,'255601','34001'),
('34001-55-0D',2013,5,'341001','34001'),
('34002-55-0D',2013,5,'341001','34002'),
('34001-52-2D',2013,5,'451002','34001'),
('34001-13410-0D',2013,5,'255601','34001'),
('34002-53-1D',2013,5,'451002','34002'),
('34001-45-0D',2013,6,'101002','34001'),
('34002-45-0D',2013,6,'101002','34002'),
('34001-100058-0D',2013,5,'621001','34001'),
('34002-100058-0D',2013,5,'621001','34002'),
('34002-53-2D',2013,5,'451002','34002'),
('34002-59-0D',2013,5,'255627','34002'),
('34001-59-0D',2013,5,'255627','34001'),
('34001-60-0D',2013,5,'255627','34001'),
('34002-13440-1D',2013,5,'441001','34002'),
('34001-100-1D',2013,5,'185515','34001'),
('34001-13440-1D',2013,5,'441001','34001'),
('34001-13460-0D',2013,5,'441001','34001'),
('34002-60-0D',2013,5,'255627','34002'),
('34002-48-0D',2013,5,'611001','34002'),
('34001-63-0D',2013,5,'361001','34001'),
('34001-101-1D',2013,6,'185515','34001'),
('34002-101-1D',2013,6,'185515','34002'),
('34001-62-1D',2013,5,'255627','34001'),
('34002-100059-0D',2013,5,'621001','34002'),
('34001-100-2D',2013,5,'185515','34001'),
('34001-13400-2D',2013,5,'255601','34001'),
('34001-62-2D',2013,5,'255627','34001'),
('34002-83-0D',2013,5,'591001','34002'),
('34002-13470-0D',2013,5,'441001','34002')--) v(Accont,ReportYear,ReportMonth,CodeM,CodeSMO)


SELECT DISTINCT CodeSMO FROM #tAccount

SELECT a.CodeM, l.NAMES,l.filialName,a.CodeSMO, s.sNameS,a.Account,a.ReportMonth,a1.AmountPayment,SUM(ISNULL(sa.AmountPaymentSum,0))
FROM #tAccount a INNER JOIN dbo.vw_AccountMO a1 ON
		a.CodeM=a1.CodeM
		AND a.CodeSMO=a1.rf_idSMO
		AND a.Account=a1.Account
		AND a.ReportYear=a1.ReportYear
				INNER JOIN dbo.vw_sprT001 l ON
		a.CodeM=l.CodeM				
				INNER JOIN dbo.vw_sprSMO s ON
		a.CodeSMO=s.smocod
				LEFT JOIN dbo.vw_SettledAccount sa ON
		a.CodeM=sa.CodeM
		AND a.CodeSMO=sa.CodeSMO
		AND a.Account=sa.Account
		AND a.ReportYear=sa.ReportYear
GROUP BY a.CodeM, l.NAMES,l.filialName,a.CodeSMO, s.sNameS,a.Account,a.ReportMonth,a1.AmountPayment
ORDER BY a.CodeM,a.CodeSMO
go
DROP TABLE #tAccount