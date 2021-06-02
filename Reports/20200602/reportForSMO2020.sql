USE AccountOMS
go
DECLARE @dateStartReg DATETIME='20200101',
		@dateStartRegRAK DATETIME='20200101',
		@dateEndRegRAK DATETIME='20200525',
		@reportYear SMALLINT=2020,
		@codeSMO CHAR(5)='34007'
		
CREATE TABLE #tDateEnd(reportMonth TINYINT, dateEnd DATETIME)
INSERT #tDateEnd(reportMonth,dateEnd) VALUES(1,'20200216'),(2,'20200316')


SELECT DISTINCT c.id AS rf_idCase, cc.AmountPayment,f.CodeM,p.ENP, c.rf_idV006,cc.AmountPayment AS AmountPaymentMO,a.rf_idSMO,cc.id, a.ReportMonth, 0 AS Posechenie, 0 AS Obrashenie, 0 AS Prof,1 AS TypeQuery, 0 AS Skor
INTO #tCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient			
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient
					INNER JOIN #tDateEnd de ON
            a.ReportMonth=de.reportMonth
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<de.dateEnd  AND a.ReportYear=@reportYear AND c.rf_idV006 IN(1,2,3) 
AND a.rf_idSMO=@codeSMO
------------------------------Скорая-------------------------------
INSERT #tCases
SELECT c.id AS rf_idCase, cc.AmountPayment,f.CodeM,p.ENP, c.rf_idV006,cc.AmountPayment AS AmountPaymentMO,a.rf_idSMO,cc.id, a.ReportMonth, 0 AS Posechenie, 0 AS Obrashenie, 0 AS Prof,1 AS TypeQuery,SUM(m.Quantity)
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient			
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient
					INNER JOIN #tDateEnd de ON
            a.ReportMonth=de.reportMonth
					INNER JOIN dbo.t_Meduslugi m ON
            c.id=m.rf_idCase
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<de.dateEnd  AND a.ReportYear=@reportYear AND c.rf_idV006=4
AND a.rf_idSMO=@codeSMO
GROUP BY c.id , cc.AmountPayment,f.CodeM,p.ENP, c.rf_idV006,cc.AmountPayment ,a.rf_idSMO,cc.id, a.ReportMonth
------------------------------Посещение-------------------
insert #tCases
SELECT c.id AS rf_idCase, cc.AmountPayment,f.CodeM,p.ENP, c.rf_idV006,cc.AmountPayment AS AmountPaymentMO,a.rf_idSMO,cc.id, a.ReportMonth, SUM(m.Quantity),0,0,2,0
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient			
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case_UnitCode_V006 u ON
            c.id=u.rf_idCase
					INNER JOIN #tDateEnd de ON
            a.ReportMonth=de.reportMonth
					INNER JOIN dbo.t_Meduslugi m ON
            c.id=m.rf_idCase
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<de.dateEnd  AND a.ReportYear=@reportYear AND c.rf_idV006 =3 AND u.UnitCode in(30, 31, 38, 145, 146)
AND a.rf_idSMO=@codeSMO
GROUP BY c.id , cc.AmountPayment,f.CodeM,p.ENP, c.rf_idV006,cc.AmountPayment ,a.rf_idSMO,cc.id, a.ReportMonth
---------------------------Обращение----------------------------------
insert #tCases
SELECT DISTINCT c.id AS rf_idCase, cc.AmountPayment,f.CodeM,p.ENP, c.rf_idV006,cc.AmountPayment AS AmountPaymentMO,a.rf_idSMO,cc.id, a.ReportMonth,0,cc.id,0,2,0
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient			
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case_UnitCode_V006 u ON
            c.id=u.rf_idCase
					INNER JOIN #tDateEnd de ON
            a.ReportMonth=de.reportMonth					
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<de.dateEnd  AND a.ReportYear=@reportYear AND c.rf_idV006 =3 AND u.UnitCode in(32, 147, 205)
AND a.rf_idSMO=@codeSMO
---------------------------Профы----------------------------------
insert #tCases
SELECT DISTINCT c.id AS rf_idCase, cc.AmountPayment,f.CodeM,p.ENP, c.rf_idV006,cc.AmountPayment AS AmountPaymentMO,a.rf_idSMO,cc.id, a.ReportMonth,0,0,cc.id,2,0
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient			
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case_UnitCode_V006 u ON
            c.id=u.rf_idCase
					INNER JOIN #tDateEnd de ON
            a.ReportMonth=de.reportMonth					
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<de.dateEnd  AND a.ReportYear=@reportYear AND c.rf_idV006 =3 AND u.UnitCode in( 260, 261, 262)
AND a.rf_idSMO=@codeSMO


SELECT p.rf_idCase,r.AmountDeduction,p.AmountPayment-r.AmountDeduction AS AmountAll
INTO #tExpertiseMEK
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
							FROM dbo.t_PaymentAcceptedCase2 c
							WHERE c.DateRegistration>=@dateStartRegRAK AND c.DateRegistration<@dateEndRegRAK AND c.TypeCheckup=1
							GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase


;WITH cte
AS(
SELECT distinct c.rf_idSMO,c.id
		-----------------------------------------------03---------------------------------------
		,CASE when reportMonth=1 and c.rf_idV006=1 THEN enp ELSE NULL END AS ColStacENP1
		,CASE when reportMonth=1 and c.rf_idV006=1 THEN id ELSE NULL END AS ColStacID1
		,CASE when reportMonth=1 and c.rf_idV006=1 THEN c.AmountPayment ELSE 0.0 END AS ColStacAmount1		
		,CASE WHEN reportMonth=1 and c.rf_idV006=1 AND e.AmountAll=0 THEN c.id else NULL END AS CountMEKStac1
		,CASE WHEN reportMonth=1 and c.rf_idV006=1 AND e.AmountAll=0 THEN e.AmountDeduction else 0.0 END AS AmountMEKStac1
		-----------------------1--------Dnevnoi------------------------------------
		,CASE when reportMonth=1 and c.rf_idV006=2 THEN enp ELSE NULL END AS ColDnStacENP1
		,CASE when reportMonth=1 and c.rf_idV006=2 THEN id ELSE NULL END AS ColDnStacID1
		,CASE when reportMonth=1 and c.rf_idV006=2 THEN c.AmountPayment ELSE 0.0 END AS ColDnStacAmount1
		,CASE WHEN reportMonth=1 and c.rf_idV006=2 AND e.AmountAll=0 THEN c.id else NULL END AS CountMEKDnStac1
		,CASE WHEN reportMonth=1 and c.rf_idV006=2 AND e.AmountAll=0 THEN e.AmountDeduction else 0.0 END AS AmountMEKDnStac1
		-----------------------1--------Ambulatorka------------------------------------
		,CASE when reportMonth=1 and c.rf_idV006=3 AND TypeQuery=1 THEN enp ELSE NULL END AS ColAmbENP1		
		,CASE when reportMonth=1 and c.rf_idV006=3 THEN c.Posechenie ELSE 0 END AS ColAmbPoseshenie1
		,CASE when reportMonth=1 and c.rf_idV006=3 THEN c.Obrashenie ELSE NULL END AS ColAmbObrashenie1
		,CASE when reportMonth=1 and c.rf_idV006=3 THEN c.Prof ELSE NULL END AS ColAmbID1 ----профмероприятия
		,CASE when reportMonth=1 and c.rf_idV006=3 and TypeQuery=1 THEN c.AmountPayment ELSE 0.0 END AS ColAmbAmount1
		,CASE WHEN reportMonth=1 and c.rf_idV006=3 and TypeQuery=1 AND e.AmountAll=0 THEN c.id else NULL END AS CountMEKAmb1
		,CASE WHEN reportMonth=1 and c.rf_idV006=3 and TypeQuery=1 AND e.AmountAll=0 THEN e.AmountDeduction else 0.0 END AS AmountMEKAmb1
		-----------------------1--------Skoray------------------------------------
		,CASE when reportMonth=1 and c.rf_idV006=4 THEN enp ELSE NULL END AS ColSkorayENP1
		,CASE when reportMonth=1 and c.rf_idV006=4 THEN c.Skor ELSE 0 END AS ColSkorayID1
		,CASE when reportMonth=1 and c.rf_idV006=4 THEN c.AmountPayment ELSE 0.0 END AS ColSkorayAmount1
		,CASE WHEN reportMonth=1 and c.rf_idV006=4 AND e.AmountAll<0 THEN c.id else NULL END AS CountMEKSkoray1
		,CASE WHEN reportMonth=1 and c.rf_idV006=4 AND e.AmountAll<0 THEN e.AmountDeduction else 0.0 END AS AmountMEKSkoray1
		
		-------------------------------------------02--------------------------------------------
		,CASE when reportMonth=2 and c.rf_idV006=1 THEN enp ELSE NULL END AS ColStacENP2
		,CASE when reportMonth=2 and c.rf_idV006=1 THEN id ELSE NULL END AS ColStacID2
		,CASE when reportMonth=2 and c.rf_idV006=1 THEN c.AmountPayment ELSE 0.0 END AS ColStacAmount2		
		,CASE WHEN reportMonth=2 and c.rf_idV006=1 AND e.AmountAll=0 THEN c.id else NULL END AS CountMEKStac2
		,CASE WHEN reportMonth=2 and c.rf_idV006=1 AND e.AmountAll=0 THEN e.AmountDeduction else 0.0 END AS AmountMEKStac2
		--------------------------------Dnevnoi------------------------------------
		,CASE when reportMonth=2 and c.rf_idV006=2 THEN enp ELSE NULL END AS ColDnStacENP2
		,CASE when reportMonth=2 and c.rf_idV006=2 THEN id ELSE NULL END AS ColDnStacID2
		,CASE when reportMonth=2 and c.rf_idV006=2 THEN c.AmountPayment ELSE 0.0 END AS ColDnStacAmount2
		,CASE WHEN reportMonth=2 and c.rf_idV006=2 AND e.AmountAll=0 THEN c.id else NULL END AS CountMEKDnStac2
		,CASE WHEN reportMonth=2 and c.rf_idV006=2 AND e.AmountAll=0 THEN e.AmountDeduction else 0.0 END AS AmountMEKDnStac2
		--------------------------------Ambulatorka------------------------------------
		,CASE when reportMonth=2 and c.rf_idV006=3 AND TypeQuery=1  THEN enp ELSE NULL END AS ColAmbENP2
		,CASE when reportMonth=2 and c.rf_idV006=3 THEN c.Posechenie ELSE 0 END AS ColAmbPoseshenie2
		,CASE when reportMonth=2 and c.rf_idV006=3 THEN c.Obrashenie ELSE NULL END AS ColAmbObrashenie2
		,CASE when reportMonth=2 and c.rf_idV006=3 THEN c.Prof ELSE NULL END AS ColAmbID2
		,CASE when reportMonth=2 and c.rf_idV006=3 AND TypeQuery=1  THEN c.AmountPayment ELSE 0.0 END AS ColAmbAmount2
		,CASE WHEN reportMonth=2 and c.rf_idV006=3 AND TypeQuery=1  AND e.AmountAll=0 THEN c.id else NULL END AS CountMEKAmb2
		,CASE WHEN reportMonth=2 and c.rf_idV006=3 AND TypeQuery=1  AND e.AmountAll=0 THEN e.AmountDeduction else 0.0 END AS AmountMEKAmb2
		--------------------------------Skoray------------------------------------
		,CASE when reportMonth=2 and c.rf_idV006=4 THEN enp ELSE NULL END AS ColSkorayENP2
		,CASE when reportMonth=2 and c.rf_idV006=4 THEN c.Skor ELSE 0 END AS ColSkorayID2
		,CASE when reportMonth=2 and c.rf_idV006=4 THEN c.AmountPayment ELSE 0.0 END AS ColSkorayAmount2
		,CASE WHEN reportMonth=2 and c.rf_idV006=4 AND e.AmountAll<0 THEN c.id else NULL END AS CountMEKSkoray2
		,CASE WHEN reportMonth=2 and c.rf_idV006=4 AND e.AmountAll<0 THEN e.AmountDeduction else 0.0 END AS AmountMEKSkoray2		
FROM #tCases c LEFT JOIN #tExpertiseMEK e ON
		c.rf_idCase=e.rf_idCase
)
SELECT c.rf_idSMO
		-------------------------Stacionar 01-------------------------------
		,COUNT(DISTINCT c.ColStacENP1) AS ColStacENP1
		,COUNT(DISTINCT c.ColStacID1) ColStacID1
		,SUM(c.ColStacAmount1) AS ColStacAmount1
		,COUNT(DISTINCT c.CountMEKStac1) AS CountMEKStac1,0
		,SUM(c.AmountMEKStac1) AS AmountMEKStac1,0
		-------------------------DnStacionar 01-------------------------------
		,COUNT(DISTINCT c.ColDnStacENP1) AS ColDnStacENP1
		,COUNT(DISTINCT c.ColDnStacID1) ColDnStacID1
		,SUM(c.ColDnStacAmount1) AS ColDnStacAmount1
		,COUNT(DISTINCT c.CountMEKDnStac1) AS CountMEKDnStac1,0
		,SUM(c.AmountMEKDnStac1) AS AmountMEKDnStac1,0
		-------------------------Ambulator 01-------------------------------
		,COUNT(DISTINCT c.ColAmbENP1) AS ColAmbENP1
		,SUM(c.ColAmbPoseshenie1) AS ColAmbPoseshenie1
		,COUNT(DISTINCT c.ColAmbObrashenie1) AS ColAmbObrashenie1
		,COUNT(DISTINCT c.ColAmbID1) ColAmbID1
		,SUM(c.ColAmbAmount1) AS ColAmbAmount1
		,SUM(c.AmountMEKAmb1) AS AmountMEKAmb1,0
		-------------------------Skoray 01-------------------------------
		,COUNT(DISTINCT c.ColSkorayENP1) AS ColSkorayENP1
		,SUM(c.ColSkorayID1) ColSkorayID1
		,SUM(c.ColSkorayAmount1) AS ColSkorayAmount1
		, COUNT(DISTINCT c.CountMEKSkoray1) AS CountMEKSkoray1
		, SUM(c.AmountMEKSkoray1) AS AmountMEKSkoray1
		
		-------------------------Stacionar 02-------------------------------
		,COUNT(DISTINCT c.ColStacENP2) AS ColStacENP2
		,COUNT(DISTINCT c.ColStacID2) ColStacID2
		,SUM(c.ColStacAmount2) AS ColStacAmount2
		, COUNT(DISTINCT c.CountMEKStac2) AS CountMEKStac2,0
		, SUM(c.AmountMEKStac2) AS AmountMEKStac2,0
		-------------------------DnStacionar 02-------------------------------
		,COUNT(DISTINCT c.ColDnStacENP2) AS ColDnStacENP2
		,COUNT(DISTINCT c.ColDnStacID2) ColDnStacID2
		,SUM(c.ColDnStacAmount2) AS ColDnStacAmount2
		, COUNT(DISTINCT c.CountMEKDnStac2) AS CountMEKDnStac2,0
		, SUM(c.AmountMEKDnStac2) AS AmountMEKDnStac2,0
		-------------------------Ambulator 02-------------------------------
		,COUNT(DISTINCT c.ColAmbENP2) AS ColAmbENP2
		,SUM(c.ColAmbPoseshenie2) AS ColAmbPoseshenie2
		, COUNT(c.ColAmbObrashenie2) AS ColAmbObrashenie2
		,COUNT(DISTINCT c.ColAmbID2) ColAmbID2
		,SUM(c.ColAmbAmount2) AS ColAmbAmount2
		,SUM(c.AmountMEKAmb2) AS AmountMEKAmb2,0
		-------------------------Skoray 02-------------------------------
		,COUNT(DISTINCT c.ColSkorayENP2) AS ColSkorayENP2
		,Sum(c.ColSkorayID2) ColSkorayID2,SUM(c.ColSkorayAmount2) AS ColSkorayAmount2, COUNT(DISTINCT c.CountMEKSkoray2) AS CountMEKSkoray2, SUM(c.AmountMEKSkoray2) AS AmountMEKSkoray2

FROM cte c
GROUP BY c.rf_idSMO
GO
DROP TABLE #tCases
GO
DROP TABLE #tDateEnd
GO
DROP TABLE #tExpertiseMEK
