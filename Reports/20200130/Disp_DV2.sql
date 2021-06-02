USE AccountOMS
GO
DECLARE @dateStart DATETIME='20190101',
		@dateEnd DATETIME='20200121',
		@reportYear SMALLINT=2019

SELECT c.id AS rf_idCase, ps.ENP,c.AmountPayment,f.CodeM,a.Account,f.DateRegistration,c.DateEnd,c.idRecordCase,a.DateRegister,d.TypeDisp
INTO #tCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient				
					INNER JOIN dbo.t_PatientSMO ps ON
			r.id=ps.rf_idRecordCasePatient
					INNER JOIN dbo.t_DispInfo d ON
            c.id=d.rf_idCase
WHERE f.DateRegistration>=@dateStart AND f.DateRegistration<@dateEnd  AND a.ReportYear=@reportYear 	AND a.rf_idSMO='34' AND f.TypeFile='F'


UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
							FROM dbo.t_PaymentAcceptedCase2 c
							WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEnd
							GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

--����� ���������� ������� �� ��2 �������� � ������
SELECT l.CodeM+' - '+l.NAMES AS LPU,c.TypeDisp,COUNT(DISTINCT c.rf_idCase) AS CountCase, COUNT(DISTINCT ENP) AS CountENP
FROM #tCases c INNER JOIN dbo.vw_sprT001 l ON
		c.CodeM=l.CodeM
WHERE c.AmountPayment>0
GROUP BY l.CodeM+' - '+l.NAMES ,c.TypeDisp
ORDER BY LPU,c.TypeDisp
GO
DROP TABLE #tCases