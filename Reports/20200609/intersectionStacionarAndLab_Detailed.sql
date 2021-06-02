USE AccountOMS
GO
DECLARE @dateStart DATETIME='20200301',
		@dateEnd DATETIME=GETDATE() ,
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
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEnd
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

/*-----------------------------Лабораторные исследования------------------------------------------
Берем все. И за текущий отчетный месяц и за предыдущий
*/

SELECT p.ENP,m.DateHelpBegin AS DateBegin ,m.DateHelpEnd as DateEnd,c.id AS rf_idCase,f.CodeM,mm.typeMU,cc.AmountPayment,SUM(m.Quantity) AS Quantity,l.id AS IdLPU,c.rf_idDirectMO,dd.DirectionDate
	,c.idRecordCase,cc.DateBegin AS DateBegCase,cc.DateEnd AS DateEndCase,a.Account,a.DateRegister,c.NumberHistoryCase,a.rf_idSMO
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
,c.idRecordCase,cc.DateBegin ,cc.DateEnd ,a.Account,a.DateRegister,c.NumberHistoryCase,a.rf_idSMO

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCKDL p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEnd
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
-----------------------------------------------------------------------------------------
--SELECT * FROM #tStac WHERE ENP='3453540892000465'

;WITH cte
AS(
SELECT DISTINCT k.CodeM,k.rf_idSMO,k.ENP,k.NumberHistoryCase,k.DateBegCase,k.DateEndCase,k.Account,k.DateRegister
	,k.idRecordCase,k.AmountPayment,k.rf_idDirectMO,k.DirectionDate,k.rf_idCase		
FROM #tStac c inner JOIN #tCKDL k ON
		c.ENP=k.ENP
		AND k.DateBegin>=c.DateBegin AND k.DateEnd<=c.DateEnd
		AND k.DirectionDate>=c.DateBegin AND k.DirectionDate<=c.DateEnd
WHERE c.AmountPayment>0 and ISNULL(k.AmountPayment,1)>0
)
SELECT ll.CodeM,c.CodeM,l.NAMES,c.rf_idSMO+' - '+s.sNameS AS SMO,c.ENP,c.NumberHistoryCase,c.DateBegCase, c.DateEndCase,d.DS1
       ,c.Account,c.DateRegister,c.idRecordCase, c.AmountPayment,ll.CodeM+' - '+ll.NAMES,
       c.DirectionDate
FROM cte c INNER JOIN dbo.vw_sprT001 l ON
	c.CodeM=l.CodeM
			INNER JOIN dbo.vw_sprT001 ll ON
    c.rf_idDirectMO=ll.mcod
			INNER JOIN dbo.vw_Diagnosis d ON
    c.rf_idCase=d.rf_idCase
			INNER JOIN dbo.vw_sprSMO s ON
     c.rf_idSMO=s.smocod
ORDER BY c.CodeM, c.Account,c.idRecordCase
/*
;WITH cte
AS(
SELECT DISTINCT c.CodeM AS LPU,k.CodeM,k.rf_idSMO,k.ENP,k.NumberHistoryCase,k.DateBegCase,k.DateEndCase,k.Account,k.DateRegister
	,k.idRecordCase,k.AmountPayment,k.rf_idDirectMO,k.DirectionDate,k.rf_idCase		
FROM #tStac c inner JOIN #tCKDL k ON
		c.ENP=k.ENP
		AND k.DateBegin>=c.DateBegin AND k.DateEnd<=c.DateEnd
		AND k.DirectionDate>=c.DateBegin AND k.DirectionDate<=c.DateEnd
WHERE c.AmountPayment>0 and ISNULL(k.AmountPayment,1)>0
),
cteB
AS(
SELECT ROW_NUMBER() OVER(PARTITION BY c.codem,c.Account,c.idRecordCase ORDER BY c.LPU) AS idrow,c.LPU,c.CodeM,l.NAMES,c.rf_idSMO+' - '+s.sNameS AS SMO,c.ENP,c.NumberHistoryCase,c.DateBegCase, c.DateEndCase,d.DS1
       ,c.Account,c.DateRegister,c.idRecordCase, c.AmountPayment,ll.CodeM+' - '+ll.NAMES AS LPUDirect,
       c.DirectionDate
FROM cte c INNER JOIN dbo.vw_sprT001 l ON
	c.CodeM=l.CodeM
			INNER JOIN dbo.vw_sprT001 ll ON
    c.rf_idDirectMO=ll.mcod
			INNER JOIN dbo.vw_Diagnosis d ON
    c.rf_idCase=d.rf_idCase
			INNER JOIN dbo.vw_sprSMO s ON
     c.rf_idSMO=s.smocod
	 )
SELECT c.idrow,
       c.LPU,
       c.CodeM,
       c.NAMES,
       c.SMO,
       c.ENP,
       c.NumberHistoryCase,
       c.DateBegCase,
       c.DateEndCase,
       c.DS1,
       c.Account,
       c.DateRegister,
       c.idRecordCase,
       c.AmountPayment,
       c.LPUDirect,
       c.DirectionDate
FROM cteB c
ORDER BY c.CodeM, c.Account,c.idRecordCase
*/
go
DROP TABLE #tMU
DROP TABLE #tCKDL
DROP TABLE #tLPU_Lab
drop TABLE #tStac
