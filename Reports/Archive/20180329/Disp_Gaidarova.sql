USE AccountOMS
GO
CREATE TABLE #LPU(CodeM CHAR(6))
INSERT #LPU( CodeM )
VALUES  ('114504'),('121018'),('124528'),('124530'),('134505'),('141016'),('141022'),('141023'),('141024'),('154602'),('154620'),('161007'),('161015'),('174601'),('184512'),
		('184603'),('251001'),('251002'),('251003'),('254505'),('301001'),('311001'),('321001'),('331001'),('341001'),('351001'),('361001'),('371001'),('381001'),('391001'),
		('391002'),('401001'),('411001'),('421001'),('431001'),('441001'),('451001'),('461001'),('471001'),('481001'),('491001'),('501001'),('511001'),('521001'),('531001'),
		('541001'),('551001'),('561001'),('571001'),('581001'),('591001'),('601001'),('611001'),('621001'),('711001')

SELECT c.id AS rf_idCase,c.AmountPayment,f.CodeM,p.ENP
INTO #tPeople
from dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
		f.id=a.rf_idFiles
				INNER JOIN #LPU l ON
		f.CodeM=l.CodeM              
				inner JOIN dbo.t_RecordCasePatient r ON
		a.id=r.rf_idRegistersAccounts
				INNER JOIN dbo.t_PatientSMO p ON
		r.id=p.rf_idRecordCasePatient              
				INNER JOIN dbo.t_Case c ON
		r.id=c.rf_idRecordCasePatient
				INNER JOIN dbo.t_MES m ON
		c.id=m.rf_idCase
				INNER JOIN (VALUES('70.3.138'),('70.3.139'),('70.3.101')) v(MU) ON
		m.MES=v.mu		  
				INNER JOIN dbo.t_DispInfo d ON
		c.id=d.rf_idCase            
WHERE f.DateRegistration>'20180101' AND f.DateRegistration<='20180309' AND a.ReportMonth<3 AND a.ReportYear=2018 
		AND c.DateEnd>='20180101' AND c.DateEnd<='20180301' AND a.Letter='O' AND d.TypeDisp='ÄÂ3'

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tPeople p INNER JOIN (
							SELECT t.rf_idCase,SUM(p.AmountDeduction) AS AmountDeduction
							FROM dbo.t_PaymentAcceptedCase2 p INNER  JOIN #tPeople t ON			
												p.rf_idCase=t.rf_idCase
							WHERE p.DateRegistration>='20180101' AND p.DateRegistration<GETDATE()	 
							GROUP BY t.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

SELECT p.CodeM,l.NAMES,COUNT(ENP) AS PeopleCount
FROM #tPeople p INNER JOIN dbo.vw_sprT001 l ON
		p.CodeM=l.CodeM
GROUP BY p.CodeM,l.NAMES
ORDER BY p.CodeM
GO
DROP TABLE #LPU
DROP TABLE #tPeople