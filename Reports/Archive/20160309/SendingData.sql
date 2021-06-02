USE AccountOMS
GO
--IF OBJECT_ID('t_SendingDataIntoFFOMS') IS NOT NULL
--		DROP TABLE t_SendingDataIntoFFOMS
--go
DECLARE @reportYear SMALLINT=2016,
		@dateStart DATETIME='20160101',--всегда с начало года берутся случаи
		@dateEnd DATE='20160210',
		@dateStartPay DATETIME='20160110',--всегда с 10 числа отчетного месяца
		@dateEndPay DATETIME='20160209 23:59:59'

CREATE TABLE #tPeople(
					  rf_idCase BIGINT,					 
					  AmountPayment DECIMAL(11,2) NOT NULL DEFAULT(0), 
					  CodeM CHAR(6),
					  rf_idV006 TINYINT,
					  rf_idV002 SMALLINT,
					  DateBegin DATE,
					  DateEnd DATE,
					  IDPeople int ,
					  AmountPaymentAccepted decimal(11,2) 
					  )
INSERT #tPeople( rf_idCase ,CodeM ,rf_idV006 ,rf_idV002,DateBegin,DateEnd, IDPeople,AmountPaymentAccepted)
SELECT c.id,c.rf_idMO ,c.rf_idV006 ,c.rf_idV002, c.DateBegin,c.DateEnd,p.IDPeople,c.AmountPayment
FROM dbo.t_Case c INNER JOIN (VALUES(1,33),(2,43)) v(v006,v010) ON
			c.rf_idv006=v.v006
			AND c.rf_idv010=v.v010  
				 INNER JOIN dbo.t_People_Case p ON
			c.id=p.rf_idCase               
WHERE c.DateEnd>@dateStart AND c.DateEnd<@dateEnd


--------------------------------------Update information about RPD---------------------------
UPDATE p SET p.AmountPayment=r.AmountPayment
FROM #tPeople p INNER JOIN (
							SELECT t.rf_idCase,SUM(p.AmountPaymentAccept) AS AmountPayment
							FROM [SRVSQL1-ST2].AccountOMSReports.dbo.t_PaidCase p INNER  JOIN #tPeople t ON			
												p.rf_idCase=t.rf_idCase
							WHERE p.DateRegistration>=@dateStartPay AND p.DateRegistration<@dateEndPay	 
							GROUP BY t.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

UPDATE p SET p.AmountPaymentAccepted=p.AmountPaymentAccepted-r.AmountDeduction
FROM #tPeople p INNER JOIN (
							SELECT t.rf_idCase,SUM(p.AmountDeduction) AS AmountDeduction
							FROM [SRVSQL1-ST2].AccountOMSReports.dbo.t_PaymentAcceptedCase p INNER  JOIN #tPeople t ON			
												p.rf_idCase=t.rf_idCase
							WHERE p.DateRegistration>=@dateStart AND p.DateRegistration<@dateEndPay	 
							GROUP BY t.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase




;WITH UnitOfHosp
AS
(
SELECT rf_idCase,p.DateBegin,p.DateEnd,p.CodeM+'.'+CAST(p.rf_idV006 AS varchar(3))+'.'+CAST(p.rf_idV002 AS varchar(5)) AS UnitOfHospital,IDPeople
FROM #tPeople p 
WHERE AmountPayment=AmountPaymentAccepted AND AmountPaymentAccepted>0--полная оплата
),
data_Send AS (
SELECT DISTINCT IDPeople,c.id AS rf_idCase,c.rf_idMO AS CodeM,a.rf_idMO,a.ReportMonth,a.ReportYear,r.rf_idF008,c.rf_idV006,r.SeriaPolis,r.NumberPolis,p.BirthDay,p.rf_idV005,c.idRecordCase,c.rf_idV014,u.UnitOfHospital,c.DateBegin,c.DateEnd,
		d.DS1, d.DS2, d.DS3,c.rf_idV009
		,m.MES,case when SUBSTRING(m.MES,3,1)='2' THEN 1 ELSE 0 END IsDelete--не учитываются случаи реабилитации
		,c.AmountPayment,mu.id AS idMU, mu.MUSurgery
		,c.Age,CASE WHEN c.Age>0 AND c.Age<18 THEN 4
					WHEN c.age>17 AND c.Age<75 THEN 5
					WHEN c.Age>74 THEN 6
					WHEN c.Age=0 AND DATEDIFF(DAY,p.BirthDay,c.DateBegin)>28 AND DATEDIFF(DAY,p.BirthDay,c.DateBegin)<91 THEN 2
					WHEN c.Age=0 AND DATEDIFF(DAY,p.BirthDay,c.DateBegin)<29 THEN 1
				ELSE 3 END AS VZST
		,CASE WHEN g.codePGR IS NOT null THEN g.codePGR ELSE g.code END AS K_KSG
		,CASE WHEN g.codePGR IS NOT null THEN 1 ELSE 0 END AS KSG_PG
--INTO t_SendingDataIntoFFOMS
FROM UnitOfHosp u INNER JOIN dbo.t_Case c ON
		u.rf_idCase=c.id
					INNER JOIN dbo.t_RecordCasePatient r ON
		r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_RegistersAccounts a ON
		a.id=r.rf_idRegistersAccounts					                  
					INNER JOIN dbo.t_RegisterPatient p ON
		r.id=p.rf_idRecordCase                 
					INNER JOIN dbo.vw_Diagnosis d ON 
		c.id=d.rf_idCase
					INNER JOIN dbo.t_MES m ON
		c.id=m.rf_idCase
					INNER JOIN dbo.vw_sprCSG csg ON
		m.MES=csg.code
					INNER JOIN [SRVSQL1-ST2].oms_NSI.dbo.tCSGroupPGR_2015 g ON
		m.MES=g.codeCSG                  
					LEFT JOIN (SELECT rf_idCase,MUSurgery,id FROM dbo.t_Meduslugi WHERE MUSurgery IS NOT NULL ) mu ON
		c.id=mu.rf_idCase                 
--WHERE mu.MUSurgery IS NOT NULL 
)
SELECT ROW_NUMBER() OVER(ORDER BY ReportYear,ReportMonth) AS id, IDPeople ,rf_idCase ,CodeM ,rf_idMO ,ReportMonth ,ReportYear ,
        rf_idF008 ,rf_idV006 ,SeriaPolis ,NumberPolis ,BirthDay ,rf_idV005 ,idRecordCase ,rf_idV014 ,UnitOfHospital ,
        DateBegin ,DateEnd ,DS1 ,DS2 ,DS3 ,rf_idV009 ,MES ,AmountPayment ,idMU ,MUSurgery ,Age ,VZST ,K_KSG ,KSG_PG,0 PVT,0 AS IsDisableCheck 
INTO t_SendingDataIntoFFOMS 
FROM data_Send WHERE IsDelete=0
--произвести расчет PVT


GO
DROP TABLE #tPeople