USE AccountOMS
GO
DECLARE @dateStart DATETIME='20200301',
		@dateEnd DATETIME=GETDATE() ,
		@dateEndRAK DATETIME=GETDATE(),
		@reportMonth TINYINT=5

--услуги при проф мероприятиях и услуги при 125901 и 805965
CREATE TABLE #tMU(MU VARCHAR(20), typeMU tinyint)
INSERT #tMU VALUES  ('4.17.785',1),('4.17.786',2)

CREATE TABLE #tLPU_Lab(CodeM CHAR(6),id tinyint)

INSERT #tLPU_Lab values('125901',1),('805965',2),('185905',3),('255627',4),('158202',5),('711001',6)


--отбираем людей 
SELECT DISTINCT p.ENP,cc.DateBegin,cc.DateEnd,c.id AS rf_idCase,f.CodeM,c.rf_idRecordCasePatient,cc.AmountPayment
INTO #tStac
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles			
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_CompletedCase cc ON
            cc.rf_idRecordCasePatient = r.id
					INNER JOIN dbo.t_PatientSMO p ON
			r.id=p.rf_idRecordCasePatient											                 																						
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd  AND a.ReportYear=2020 AND a.ReportMonth=@reportMonth AND c.rf_idV006=1 --AND f.CodeM='176001'
/*-----------------------------Стационар Экспертиза------------------------------------------*/
UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tStac p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndRAK
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

/*-----------------------------Лабораторные исследования------------------------------------------
Берем все. И за текущий отчетный месяц и за предыдущий
*/

SELECT p.ENP,m.DateHelpBegin AS DateBegin ,m.DateHelpEnd as DateEnd,c.id AS rf_idCase,f.CodeM,mm.typeMU,cc.AmountPayment,SUM(m.Quantity) AS Quantity,l.id AS IdLPU/*,c.rf_idDirectMO*/,dd.DirectionDate
INTO #tCKDL
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN #tLPU_Lab l ON
            f.CodeM=l.CodeM
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_CompletedCase cc ON
            cc.rf_idRecordCasePatient = r.id
					INNER JOIN dbo.t_PatientSMO p ON
			r.id=p.rf_idRecordCasePatient											                 													
					INNER JOIN (SELECT DISTINCT enp FROM #tStac) s ON
            p.ENP=s.ENP
					INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase
					INNER JOIN #tMU mm on
			m.MU=mm.MU
					LEFT JOIN dbo.t_DirectionDate dd ON
           c.id=dd.rf_idCase
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd  AND a.ReportYear=2020 AND Letter='K' AND a.ReportMonth <=@reportMonth 
GROUP BY p.ENP,m.DateHelpBegin ,m.DateHelpEnd,c.id,f.CodeM,mm.typeMU,cc.AmountPayment,l.id,c.rf_idDirectMO,dd.DirectionDate

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCKDL p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndRAK
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
-----------------------------------------------------------------------------------------
/*
SELECT DISTINCT c.enp,k.DateBegin,k.DateEnd,k.rf_idCase,k.CodeM,k.typeMU,k.AmountPayment,
             k.Quantity,k.IdLPU,k.DirectionDate
FROM #tStac c left JOIN #tCKDL k ON
		c.ENP=k.ENP
		AND k.DateBegin>=c.DateBegin AND k.DateEnd<=c.DateEnd
WHERE C.codem='141023' AND c.AmountPayment>0 AND k.AmountPayment>0 AND k.CodeM='185905'
ORDER BY k.CodeM,k.rf_idCase
*/


;with cteIntersection
AS(
SELECT DISTINCT c.CodeM AS CodeM_Stac,c.enp AS ENP_STAC,k.rf_idCase
		,CASE WHEN k.typeMU=1 AND k.IdLPU=1 THEN k.Quantity ELSE 0 END AS Col4
		,CASE WHEN k.typeMU=2 AND k.IdLPU=1 THEN k.Quantity ELSE 0 END AS Col5
		-----------------------------------------------------------------------
		,CASE WHEN k.typeMU=1 AND k.IdLPU=2 THEN k.Quantity ELSE 0 END AS Col6
		,CASE WHEN k.typeMU=2 AND k.IdLPU=2 THEN k.Quantity ELSE 0 END AS Col7
		-----------------------------------------------------------------------
		,CASE WHEN k.typeMU=1 AND k.IdLPU=3 THEN k.Quantity ELSE 0 END AS Col8
		,CASE WHEN k.typeMU=2 AND k.IdLPU=3 THEN k.Quantity ELSE 0 END AS Col9
		-----------------------------------------------------------------------
		,CASE WHEN k.typeMU=1 AND k.IdLPU=4 THEN k.Quantity ELSE 0 END AS Col10
		,CASE WHEN k.typeMU=2 AND k.IdLPU=4 THEN k.Quantity ELSE 0 END AS Col11
		-----------------------------------------------------------------------
		,CASE WHEN k.typeMU=1 AND k.IdLPU=5 THEN k.Quantity ELSE 0 END AS Col12
		,CASE WHEN k.typeMU=2 AND k.IdLPU=5 THEN k.Quantity ELSE 0 END AS Col13
		-----------------------------------------------------------------------
		,CASE WHEN k.typeMU=1 AND k.IdLPU=6 THEN k.Quantity ELSE 0 END AS Col14
		,CASE WHEN k.typeMU=2 AND k.IdLPU=6 THEN k.Quantity ELSE 0 END AS Col15
FROM #tStac c left JOIN #tCKDL k ON
		c.ENP=k.ENP
		AND k.DateBegin>=c.DateBegin AND k.DateEnd<=c.DateEnd
		AND k.DirectionDate>=c.DateBegin AND k.DirectionDate<=c.DateEnd
WHERE c.AmountPayment>0 and ISNULL(k.AmountPayment,1)>0
)
SELECT c.CodeM_Stac,l.NAMES AS LPU,COUNT(DISTINCT c.ENP_STAC)
		,cast(SUM(c.Col4) as int) AS col4,cast(SUM(c.Col5) as int) AS col5
		,cast(SUM(c.Col6) as int) AS col6,cast(SUM(c.Col7) as int) AS col7
		,cast(SUM(c.Col8) as int) AS col8,cast(SUM(c.Col9) as int) AS col9
		,cast(SUM(c.Col10)as int) AS col10,cast(SUM(c.Col11)as int) AS col11
		,cast(SUM(c.Col12)as int) AS col12,cast(SUM(c.Col13)as int) AS col13
		,cast(SUM(c.Col14)as int) AS col14,cast(SUM(c.Col15)as int) AS col15
FROM cteIntersection c INNER JOIN dbo.vw_sprT001 l ON
		c.CodeM_Stac=l.CodeM
GROUP BY c.CodeM_Stac,l.NAMES 
ORDER BY c.CodeM_Stac

go
DROP TABLE #tMU
DROP TABLE #tCKDL
DROP TABLE #tLPU_Lab
drop TABLE #tStac
