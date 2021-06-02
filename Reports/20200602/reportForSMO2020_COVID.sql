USE AccountOMS
go
DECLARE @dateStartReg DATETIME='20200101',
		@dateStartRegRAK DATETIME='20200101',
		@dateEndRegRAK DATETIME='20200525',
		@reportYear SMALLINT=2020,
		@codeSMO CHAR(5)='34002'
		
CREATE TABLE #tDateEnd(reportMonth TINYINT, dateEnd DATETIME)
INSERT #tDateEnd(reportMonth,dateEnd) VALUES(3,'20200408'),(4,'20200516')


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
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<de.dateEnd  AND a.ReportYear=@reportYear AND c.rf_idV006 =3 AND u.UnitCode in(32, 147, 205,322,323)
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

ALTER TABLE #tCases ADD IsCovid TINYINT NULL

UPDATE c SET c.IsCovid=1
FROM #tCases c INNER JOIN dbo.t_Diagnosis d ON
		c.rf_idCase=d.rf_idCase
WHERE d.TypeDiagnosis IN(1,3) AND d.DiagnosisCode IN('U07.1','U07.2')


SELECT p.rf_idCase,r.AmountDeduction,p.AmountPayment-r.AmountDeduction AS AmountAll
INTO #tExpertiseMEK
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
							FROM dbo.t_PaymentAcceptedCase2 c
							WHERE c.DateRegistration>=@dateStartRegRAK AND c.DateRegistration<@dateEndRegRAK AND c.TypeCheckup=1
							GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase


--;WITH cte
--AS(
SELECT  DISTINCT c.rf_idSMO,c.id
		-----------------------------------------------03---------------------------------------
		,CASE when reportMonth=3 and c.rf_idV006=1 THEN enp ELSE NULL END AS ColStacENP1
		,CASE when reportMonth=3 and c.rf_idV006=1 AND IsCovid=1 THEN enp ELSE NULL END AS ColStacENP1Covid
		,CASE when reportMonth=3 and c.rf_idV006=1 THEN id ELSE NULL END AS ColStacID1
		,CASE when reportMonth=3 and c.rf_idV006=1 AND IsCovid=1 THEN id ELSE NULL END AS ColStacID1Covid
		,CASE when reportMonth=3 and c.rf_idV006=1 THEN c.AmountPayment ELSE 0.0 END AS ColStacAmount1	
		,CASE when reportMonth=3 and c.rf_idV006=1 AND IsCovid=1 THEN c.AmountPayment ELSE 0.0 END AS ColStacAmount1Covid		
		,CASE WHEN reportMonth=3 and c.rf_idV006=1 AND e.AmountAll=0 THEN c.id else NULL END AS CountMEKStac1
		,CASE WHEN reportMonth=3 and c.rf_idV006=1 AND e.AmountAll=0 AND IsCovid=1 THEN c.id else NULL END AS CountMEKStac1Covid
		,CASE WHEN reportMonth=3 and c.rf_idV006=1 AND e.AmountAll=0 THEN e.AmountDeduction else 0.0 END AS AmountMEKStac1
		,CASE WHEN reportMonth=3 and c.rf_idV006=1 AND e.AmountAll=0 AND IsCovid=1 THEN e.AmountDeduction else 0.0 END AS AmountMEKStac1Covid
		-----------------------1--------Dnevnoi------------------------------------
		,CASE when reportMonth=3 and c.rf_idV006=2 THEN enp ELSE NULL END AS ColDnStacENP1
		,CASE when reportMonth=3 and c.rf_idV006=2 AND IsCovid=1 THEN enp ELSE NULL END AS ColDnStacENP1Covid
		,CASE when reportMonth=3 and c.rf_idV006=2 THEN id ELSE NULL END AS ColDnStacID1
		,CASE when reportMonth=3 and c.rf_idV006=2 AND IsCovid=1 THEN id ELSE NULL END AS ColDnStacID1Covid
		,CASE when reportMonth=3 and c.rf_idV006=2 THEN c.AmountPayment ELSE 0.0 END AS ColDnStacAmount1	
		,CASE when reportMonth=3 and c.rf_idV006=2 AND IsCovid=1 THEN c.AmountPayment ELSE 0.0 END AS ColDnStacAmount1Covid		
		,CASE WHEN reportMonth=3 and c.rf_idV006=2 AND e.AmountAll=0 THEN c.id else NULL END AS CountMEKDnStac1
		,CASE WHEN reportMonth=3 and c.rf_idV006=2 AND e.AmountAll=0 AND IsCovid=1 THEN c.id else NULL END AS CountMEKDnStac1Covid
		,CASE WHEN reportMonth=3 and c.rf_idV006=2 AND e.AmountAll=0 THEN e.AmountDeduction else 0.0 END AS AmountMEKDnStac1
		,CASE WHEN reportMonth=3 and c.rf_idV006=2 AND e.AmountAll=0 AND IsCovid=1 THEN e.AmountDeduction else 0.0 END AS AmountMEKDnStac1Covid
		-------------------------1--------Ambulatorka------------------------------------
	    ,CASE when reportMonth=3 and c.rf_idV006=3 AND TypeQuery=1 THEN enp ELSE NULL END AS ColAmbENP1		
		,CASE when reportMonth=3 and c.rf_idV006=3 AND TypeQuery=1 AND IsCovid=1 THEN enp ELSE NULL END AS ColAmbENP1Covid		
		,CASE when reportMonth=3 and c.rf_idV006=3 THEN c.Posechenie ELSE 0 END AS ColAmbPoseshenie1
		,CASE when reportMonth=3 and c.rf_idV006=3 AND IsCovid=1 THEN c.Posechenie ELSE 0 END AS ColAmbPoseshenie1Covid
		,CASE when reportMonth=3 and c.rf_idV006=3 THEN c.Obrashenie ELSE NULL END AS ColAmbObrashenie1
		,CASE when reportMonth=3 and c.rf_idV006=3 AND IsCovid=1 THEN c.Obrashenie ELSE NULL END AS ColAmbObrashenie1Covid
		,CASE when reportMonth=3 and c.rf_idV006=3 THEN c.Prof ELSE NULL END AS ColAmbID1 ----профмероприятия
		,CASE when reportMonth=3 and c.rf_idV006=3 and TypeQuery=1 THEN c.AmountPayment ELSE 0.0 END AS ColAmbAmount1
		,CASE when reportMonth=3 and c.rf_idV006=3 and TypeQuery=1 AND IsCovid=1 THEN c.AmountPayment ELSE 0.0 END AS ColAmbAmount1Covid
		,CASE WHEN reportMonth=3 and c.rf_idV006=3 and TypeQuery=1 AND e.AmountAll=0 THEN e.AmountDeduction else 0.0 END AS AmountMEKAmb1
		,CASE WHEN reportMonth=3 and c.rf_idV006=3 and TypeQuery=1 AND e.AmountAll=0 AND IsCovid=1 THEN e.AmountDeduction else 0.0 END AS AmountMEKAmb1Covid
		-------------------------1--------Skoray------------------------------------
		,CASE when reportMonth=3 and c.rf_idV006=4 THEN enp ELSE NULL END AS ColSkorayENP1
		,CASE when reportMonth=3 and c.rf_idV006=4 AND IsCovid=1THEN enp ELSE NULL END AS ColSkorayENP1Covid
		,CASE when reportMonth=3 and c.rf_idV006=4 THEN c.Skor ELSE 0 END AS ColSkorayID1
		,CASE when reportMonth=3 and c.rf_idV006=4 AND IsCovid=1 THEN c.Skor ELSE 0 END AS ColSkorayID1Covid
		,CASE when reportMonth=3 and c.rf_idV006=4 THEN c.AmountPayment ELSE 0.0 END AS ColSkorayAmount1
		,CASE when reportMonth=3 and c.rf_idV006=4 AND IsCovid=1 THEN c.AmountPayment ELSE 0.0 END AS ColSkorayAmount1Covid
		,CASE WHEN reportMonth=3 and c.rf_idV006=4 AND e.AmountAll<0 THEN c.id else NULL END AS CountMEKSkoray1
		,CASE WHEN reportMonth=3 and c.rf_idV006=4 AND e.AmountAll<0 AND IsCovid=1 THEN c.id else NULL END AS CountMEKSkoray1Covid
		,CASE WHEN reportMonth=3 and c.rf_idV006=4 AND e.AmountAll<0 THEN e.AmountDeduction else 0.0 END AS AmountMEKSkoray1
		,CASE WHEN reportMonth=3 and c.rf_idV006=4 AND e.AmountAll<0 AND IsCovid=1 THEN e.AmountDeduction else 0.0 END AS AmountMEKSkoray1Covid
		--------------------------Aprill-----------------------------
		,CASE when reportMonth=4 and c.rf_idV006=1 THEN enp ELSE NULL END AS ColStacENP2
		,CASE when reportMonth=4 and c.rf_idV006=1 AND IsCovid=1 THEN enp ELSE NULL END AS ColStacENP2Covid
		,CASE when reportMonth=4 and c.rf_idV006=1 THEN id ELSE NULL END AS ColStacID2
		,CASE when reportMonth=4 and c.rf_idV006=1 AND IsCovid=1 THEN id ELSE NULL END AS ColStacID2Covid
		,CASE when reportMonth=4 and c.rf_idV006=1 THEN c.AmountPayment ELSE 0.0 END AS ColStacAmount2	
		,CASE when reportMonth=4 and c.rf_idV006=1 AND IsCovid=1 THEN c.AmountPayment ELSE 0.0 END AS ColStacAmount2Covid		
		,CASE WHEN reportMonth=4 and c.rf_idV006=1 AND e.AmountAll=0 THEN c.id else NULL END AS CountMEKStac2
		,CASE WHEN reportMonth=4 and c.rf_idV006=1 AND e.AmountAll=0 AND IsCovid=1 THEN c.id else NULL END AS CountMEKStac2Covid
		,CASE WHEN reportMonth=4 and c.rf_idV006=1 AND e.AmountAll=0 THEN e.AmountDeduction else 0.0 END AS AmountMEKStac2
		,CASE WHEN reportMonth=4 and c.rf_idV006=1 AND e.AmountAll=0 AND IsCovid=1 THEN e.AmountDeduction else 0.0 END AS AmountMEKStac2Covid
		-----------------------4--------Dnevnoi------------------------------------
		,CASE when reportMonth=4 and c.rf_idV006=2 THEN enp ELSE NULL END AS ColDnStacENP2
		,CASE when reportMonth=4 and c.rf_idV006=2 AND IsCovid=1 THEN enp ELSE NULL END AS ColDnStacENP2Covid
		,CASE when reportMonth=4 and c.rf_idV006=2 THEN id ELSE NULL END AS ColDnStacID2
		,CASE when reportMonth=4 and c.rf_idV006=2 AND IsCovid=1 THEN id ELSE NULL END AS ColDnStacID2Covid
		,CASE when reportMonth=4 and c.rf_idV006=2 THEN c.AmountPayment ELSE 0.0 END AS ColDnStacAmount2	
		,CASE when reportMonth=4 and c.rf_idV006=2 AND IsCovid=1 THEN c.AmountPayment ELSE 0.0 END AS ColDnStacAmount2Covid		
		,CASE WHEN reportMonth=4 and c.rf_idV006=2 AND e.AmountAll=0 THEN c.id else NULL END AS CountMEKDnStac2
		,CASE WHEN reportMonth=4 and c.rf_idV006=2 AND e.AmountAll=0 AND IsCovid=1 THEN c.id else NULL END AS CountMEKDnStac2Covid
		,CASE WHEN reportMonth=4 and c.rf_idV006=2 AND e.AmountAll=0 THEN e.AmountDeduction else 0.0 END AS AmountMEKDnStac2
		,CASE WHEN reportMonth=4 and c.rf_idV006=2 AND e.AmountAll=0 AND IsCovid=1 THEN e.AmountDeduction else 0.0 END AS AmountMEKDnStac2Covid
		-----------------------4-1--------Ambulatorka------------------------------------
	    ,CASE when reportMonth=4 and c.rf_idV006=3 AND TypeQuery=1 THEN enp ELSE NULL END AS ColAmbENP2		
		,CASE when reportMonth=4 and c.rf_idV006=3 AND TypeQuery=1 AND IsCovid=1 THEN enp ELSE NULL END AS ColAmbENP2Covid		
		,CASE when reportMonth=4 and c.rf_idV006=3 THEN c.Posechenie ELSE 0 END AS ColAmbPoseshenie2
		,CASE when reportMonth=4 and c.rf_idV006=3 AND IsCovid=1 THEN c.Posechenie ELSE 0 END AS ColAmbPoseshenie2Covid
		,CASE when reportMonth=4 and c.rf_idV006=3 THEN c.Obrashenie ELSE NULL END AS ColAmbObrashenie2
		,CASE when reportMonth=4 and c.rf_idV006=3 AND IsCovid=1 THEN c.Obrashenie ELSE NULL END AS ColAmbObrashenie2Covid
		,CASE when reportMonth=4 and c.rf_idV006=3 THEN c.Prof ELSE NULL END AS ColAmbID2 ----профмероприятия
		,CASE when reportMonth=4 and c.rf_idV006=3 and TypeQuery=1 THEN c.AmountPayment ELSE 0.0 END AS ColAmbAmount2
		,CASE when reportMonth=4 and c.rf_idV006=3 and TypeQuery=1 AND IsCovid=1 THEN c.AmountPayment ELSE 0.0 END AS ColAmbAmount2Covid		
		,CASE WHEN reportMonth=4 and c.rf_idV006=3 and TypeQuery=1 AND e.AmountAll=0 THEN e.AmountDeduction else 0.0 END AS AmountMEKAmb2
		,CASE WHEN reportMonth=4 and c.rf_idV006=3 and TypeQuery=1 AND e.AmountAll=0 AND IsCovid=1 THEN e.AmountDeduction else 0.0 END AS AmountMEKAmb2Covid
		-----------------------4-1--------Skoray------------------------------------
		,CASE when reportMonth=4 and c.rf_idV006=4 THEN enp ELSE NULL END AS ColSkorayENP2
		,CASE when reportMonth=4 and c.rf_idV006=4 AND IsCovid=1THEN enp ELSE NULL END AS ColSkorayENP2Covid
		,CASE when reportMonth=4 and c.rf_idV006=4 THEN c.Skor ELSE 0 END AS ColSkorayID2
		,CASE when reportMonth=4 and c.rf_idV006=4 AND IsCovid=1 THEN c.Skor ELSE 0 END AS ColSkorayID2Covid
		,CASE when reportMonth=4 and c.rf_idV006=4 THEN c.AmountPayment ELSE 0.0 END AS ColSkorayAmount2
		,CASE when reportMonth=4 and c.rf_idV006=4 AND IsCovid=1 THEN c.AmountPayment ELSE 0.0 END AS ColSkorayAmount2Covid
		,CASE WHEN reportMonth=4 and c.rf_idV006=4 AND e.AmountAll<0 THEN c.id else NULL END AS CountMEKSkoray2
		,CASE WHEN reportMonth=4 and c.rf_idV006=4 AND e.AmountAll<0 AND IsCovid=1 THEN c.id else NULL END AS CountMEKSkoray2Covid
		,CASE WHEN reportMonth=4 and c.rf_idV006=4 AND e.AmountAll<0 THEN e.AmountDeduction else 0.0 END AS AmountMEKSkoray2
		,CASE WHEN reportMonth=4 and c.rf_idV006=4 AND e.AmountAll<0 AND IsCovid=1 THEN e.AmountDeduction else 0.0 END AS AmountMEKSkoray2Covid
INTO #cte
FROM #tCases c LEFT JOIN #tExpertiseMEK e ON
		c.rf_idCase=e.rf_idCase
--)
SELECT c.rf_idSMO
		-------------------------Stacionar 01-------------------------------
		,COUNT(DISTINCT c.ColStacENP1) AS ColStacENP1
		,COUNT(DISTINCT c.ColStacENP1Covid) AS ColStacENP1Covid
		,COUNT(distinct c.ColStacID1) ColStacID1
		,COUNT(distinct c.ColStacID1Covid) ColStacID1Covid
		,cast(SUM(c.ColStacAmount1) AS MONEY) AS ColStacAmount1
		,cast(SUM(c.ColStacAmount1Covid) AS MONEY) AS ColStacAmount1Covid
		,COUNT(distinct c.CountMEKStac1) AS CountMEKStac1
		,COUNT(distinct c.CountMEKStac1Covid) AS CountMEKStac1Covid,0
		,CAST(SUM(c.AmountMEKStac1) AS MONEY) AS AmountMEKStac1
		,CAST(SUM(c.AmountMEKStac1Covid) AS MONEY) AS AmountMEKStac1Covid,0
		-------------------------DnStacionar 01-------------------------------
		,COUNT(DISTINCT c.ColDnStacENP1) AS ColDnStacENP1
		,COUNT(DISTINCT c.ColDnStacENP1Covid) AS ColDnStacENP1Covid
		,COUNT(distinct c.ColDnStacID1) ColDnStacID1
		,COUNT(distinct c.ColDnStacID1Covid) ColDnStacID1Covid
		,cast(SUM(c.ColDnStacAmount1) AS MONEY) AS ColDnStacAmount1
		,cast(SUM(c.ColDnStacAmount1Covid) AS MONEY) AS ColDnStacAmount1Covid
		,COUNT(distinct c.CountMEKDnStac1) AS CountMEKDnStac1
		,COUNT(distinct c.CountMEKDnStac1Covid) AS CountMEKDnStac1Covid,0
		,CAST(SUM(c.AmountMEKDnStac1) AS MONEY) AS AmountMEKDnStac1
		,CAST(SUM(c.AmountMEKDnStac1Covid) AS MONEY) AS AmountMEKDnStac1Covid,0
		-------------------------Ambulator 01-------------------------------
		,COUNT(DISTINCT c.ColAmbENP1) AS ColAmbENP1
		,COUNT(DISTINCT c.ColAmbENP1Covid) AS ColAmbENP1Covid
		,cast(SUM(c.ColAmbPoseshenie1) AS MONEY) AS ColAmbPoseshenie1
		,cast(SUM(c.ColAmbPoseshenie1Covid) AS MONEY) AS ColAmbPoseshenie1Covid
		,COUNT(distinct c.ColAmbObrashenie1) AS ColAmbObrashenie1
		,COUNT(distinct c.ColAmbObrashenie1Covid) AS ColAmbObrashenie1Covid
		,COUNT(distinct c.ColAmbID1) ColAmbID1
		,cast(SUM(c.ColAmbAmount1) AS MONEY) AS ColAmbAmount1
		,cast(SUM(c.ColAmbAmount1Covid) AS MONEY) AS ColAmbAmount1Covid
		,CAST(SUM(c.AmountMEKAmb1) AS MONEY) AS AmountMEKAmb1
		,CAST(SUM(c.AmountMEKAmb1Covid) AS MONEY) AS AmountMEKAmb1Covid,0
		-------------------------Skoray 01-------------------------------
		,COUNT(DISTINCT c.ColSkorayENP1) AS ColSkorayENP1
		,COUNT(DISTINCT c.ColSkorayENP1Covid) AS ColSkorayENP1Covid
		,SUM(c.ColSkorayID1)  ColSkorayID1
		,SUM(c.ColSkorayID1Covid) ColSkorayID1Covid
		,cast(SUM(c.ColSkorayAmount1) AS MONEY) AS ColSkorayAmount1
		,cast(SUM(c.ColSkorayAmount1Covid) AS MONEY) AS ColSkorayAmount1Covid
		,COUNT(DISTINCT c.CountMEKSkoray1) AS CountMEKSkoray1
		,COUNT(DISTINCT c.CountMEKSkoray1Covid) AS CountMEKSkoray1Covid
		,CAST(SUM(c.AmountMEKSkoray1) AS MONEY) AS AmountMEKSkoray1
		,CAST(SUM(c.AmountMEKSkoray1Covid) AS MONEY) AS AmountMEKSkoray1Covid	
		----------------------------------Aprill----------------------------------------------------------
		-------------------------Stacionar 01-------------------------------
		,COUNT(DISTINCT c.ColStacENP2) AS ColStacENP2
		,COUNT(DISTINCT c.ColStacENP2Covid) AS ColStacENP2Covid
		,COUNT(distinct c.ColStacID2) ColStacID2
		,COUNT(distinct c.ColStacID2Covid) ColStacID2Covid
		,SUM(c.ColStacAmount2) AS ColStacAmount2
		,SUM(c.ColStacAmount2Covid) AS ColStacAmount2Covid
		,COUNT(distinct c.CountMEKStac2) AS CountMEKStac2
		,COUNT(distinct c.CountMEKStac2Covid) AS CountMEKStac2Covid,0
		,CAST(SUM(c.AmountMEKStac2) AS MONEY) AS AmountMEKStac2
		,CAST(SUM(c.AmountMEKStac2Covid) AS MONEY) AS AmountMEKStac2Covid,0
		-------------------------DnStacionar 02-------------------------------
		,COUNT(DISTINCT c.ColDnStacENP2) AS ColDnStacENP2
		,COUNT(DISTINCT c.ColDnStacENP2Covid) AS ColDnStacENP2Covid
		,COUNT(distinct c.ColDnStacID2) ColDnStacID2
		,COUNT(distinct c.ColDnStacID2Covid) ColDnStacID2Covid
		,SUM(c.ColDnStacAmount2) AS ColDnStacAmount2
		,SUM(c.ColDnStacAmount2Covid) AS ColDnStacAmount2Covid
		,COUNT(distinct c.CountMEKDnStac2) AS CountMEKDnStac2
		,COUNT(distinct c.CountMEKDnStac2Covid) AS CountMEKDnStac2Covid,0
		,CAST(SUM(c.AmountMEKDnStac2) AS MONEY) AS AmountMEKDnStac2
		,CAST(SUM(c.AmountMEKDnStac2Covid) AS MONEY) AS AmountMEKDnStac2Covid,0
		-------------------------Ambulator 02-------------------------------
		,COUNT(DISTINCT c.ColAmbENP2) AS ColAmbENP2
		,COUNT(DISTINCT c.ColAmbENP2Covid) AS ColAmbENP2Covid
		,SUM(c.ColAmbPoseshenie2) AS ColAmbPoseshenie2
		,SUM(c.ColAmbPoseshenie2Covid) AS ColAmbPoseshenie2Covid
		,COUNT(distinct c.ColAmbObrashenie2) AS ColAmbObrashenie2
		,COUNT(distinct c.ColAmbObrashenie2Covid) AS ColAmbObrashenie2Covid
		,COUNT(DISTINCT c.ColAmbID2) ColAmbID2
		,SUM(c.ColAmbAmount2) AS ColAmbAmount2
		,SUM(c.ColAmbAmount2Covid) AS ColAmbAmount2Covid
		,cast(SUM(c.AmountMEKAmb2) AS MONEY) AS AmountMEKAmb2
		,cast(SUM(c.AmountMEKAmb2Covid) AS MONEY) AS AmountMEKAmb2Covid,0
		-------------------------Skoray 02-------------------------------
		,COUNT(DISTINCT c.ColSkorayENP2) AS ColSkorayENP2
		,COUNT(DISTINCT c.ColSkorayENP2Covid) AS ColSkorayENP2Covid
		,SUM(c.ColSkorayID2) ColSkorayID2,SUM(c.ColSkorayID2Covid) ColSkorayID2Covid
		,CAST(SUM(c.ColSkorayAmount2)AS MONEY) AS ColSkorayAmount2,CAST(SUM(c.ColSkorayAmount2Covid) AS MONEY) AS ColSkorayAmount2Covid
		,COUNT(DISTINCT c.CountMEKSkoray2) AS CountMEKSkoray2
		,COUNT(DISTINCT c.CountMEKSkoray2Covid) AS CountMEKSkoray2Covid
		,CAST(SUM(c.AmountMEKSkoray2) AS MONEY) AS AmountMEKSkoray2
		,CAST(SUM(c.AmountMEKSkoray2Covid) AS MONEY) AS AmountMEKSkoray2Covid	
FROM #cte c
GROUP BY c.rf_idSMO

GO
DROP TABLE #tCases
GO
DROP TABLE #tDateEnd
GO
DROP TABLE #tExpertiseMEK
GO
DROP TABLE #cte
