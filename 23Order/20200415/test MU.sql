USE AccountOMSReports
GO
declare	@reportYear SMALLINT=2020,
		@dateStart DATETIME='20200101',--всегда с начало года берутся случаи
		@dateEnd DATE=GETDATE(),		
		@dateStartPay DATETIME='20200310',--всегда с 10 числа отчетного месяца. В сентябре 2017 конечная дата изменилась, теперь нужно брать с 6 числа и по 10 число следующего месяца
		@dateEndPay DATETIME='20200410'

CREATE TABLE #tPeople(
					  rf_idCase BIGINT,					 
					  AmountPayment DECIMAL(11,2) NOT NULL DEFAULT(0), 
					  CodeM CHAR(6),
					  rf_idV006 TINYINT,
					  rf_idV002 SMALLINT,
					  DateBegin DATE,
					  DateEnd DATE,
					  AmountPaymentAccepted decimal(11,2),
					   AmountPaymentAcceptedZSL decimal(11,2),
					  rf_idDepartmentMO VARCHAR(6) ,					  
					  TypeCases TINYINT,
					  IDSP TINYINT
					  )

/*
09.02.2019
случаи оказания медицинской помощи в дневном стационаре, в которых применяется способ оплаты 33, за исключением случаев, в которых применяются следующие коды КСГ
*/
INSERT #tPeople( rf_idCase ,CodeM ,rf_idV006 ,rf_idV002,DateBegin,DateEnd, AmountPaymentAccepted,rf_idDepartmentMO,TypeCases,IDSP,AmountPaymentAcceptedZSL)
SELECT c.id,c.rf_idMO ,c.rf_idV006 ,c.rf_idV002, c.DateBegin,c.DateEnd,c.AmountPayment, CAST(c.rf_idDepartmentMO AS VARCHAR(6)), 9,c.rf_idV010,0.0
FROM dbo.t_Case c INNER JOIN dbo.t_CompletedCase cc ON
			c.rf_idRecordCasePatient=cc.rf_idRecordCasePatient                  
WHERE c.DateEnd>@dateStart AND c.DateEnd<@dateEnd AND NOT EXISTS(SELECT 1 FROM dbo.t_Meduslugi m WHERE m.MUGroupCode=60 AND m.MUUnGroupCode=3 AND m.rf_idCase=c.id)
	AND c.rf_idV010 =33 AND c.rf_idV006<3

/*
09.02.2019
- начиная с отчетного периода 2018 год случаи проведения заместительной почечной терапии в условиях стационара (USL_OK=1), 
дневного стационара (USL_OK=2) и амбулаторно (USL_OK=3): случаи, содержащие на уровне услуг хотя бы одну услугу с кодом группы 60.3.*, 
способ оплаты по данным случаям – 4 лечебно-диагностическая процедура или 33, или 28.
*/
	INSERT #tPeople( rf_idCase ,CodeM ,rf_idV006 ,rf_idV002,DateBegin,DateEnd, AmountPaymentAccepted,rf_idDepartmentMO,TypeCases,IDSP,AmountPaymentAcceptedZSL)
	SELECT distinct c.id,c.rf_idMO ,c.rf_idV006 ,c.rf_idV002, c.DateBegin,c.DateEnd,c.AmountPayment, CAST(c.rf_idDepartmentMO AS VARCHAR(6)), 10,CASE WHEN c.rf_idV010=43 THEN 33 ELSE c.rf_idV010 END, 0.0
	FROM dbo.t_Case c INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase
						INNER JOIN dbo.t_CompletedCase cc ON
			c.rf_idRecordCasePatient=cc.rf_idRecordCasePatient
	WHERE c.rf_idV010 IN(33,28) AND c.rf_idV006<4 AND c.DateEnd>=@dateStart AND c.DateEnd<@dateEnd AND m.MUGroupCode=60 AND m.MUUnGroupCode=3--указан 43 способ оплаты т.к ДС оплачивается в основном по нем если есть КСГ
--END 
 
-----снятия смотрим по законченному случаю
UPDATE p SET p.AmountPaymentAcceptedZSL=p.AmountPaymentAccepted-r.AmountDeduction
FROM #tPeople p INNER JOIN (
							SELECT t.rf_idCase,SUM(p.AmountDeduction) AS AmountDeduction
							FROM dbo.t_PaymentAcceptedCase2 p INNER  JOIN #tPeople t ON			
												p.rf_idCase=t.rf_idCase
							WHERE p.DateRegistration>=@dateStartPay AND p.DateRegistration<@dateEndPay	 
							GROUP BY t.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

--------------------------------------------------------------------------------------------------------------------------
;WITH UnitOfHosp
AS
(
SELECT rf_idCase,p.DateBegin,p.DateEnd
	,CASE WHEN p.rf_idDepartmentMO IS NULL THEN p.CodeM+'.'+CAST(p.rf_idV006 AS VARCHAR(3))+'.'+CAST(p.rf_idV002 AS VARCHAR(5))
			ELSE p.CodeM+'.'+p.rf_idDepartmentMO+'.'+CAST(p.rf_idV006 AS VARCHAR(3)) END AS UnitOfHospital
	,TypeCases,IDSP, AmountPaymentAcceptedZSL
FROM #tPeople p 
WHERE AmountPaymentAcceptedZSL>0
),
data_Send AS (
SELECT DISTINCT c.id AS rf_idCase,c.rf_idMO AS CodeM,a.rf_idMO,a.ReportMonth,a.ReportYear,r.rf_idF008,c.rf_idV006,r.SeriaPolis,r.NumberPolis,p.BirthDay,p.rf_idV005
		,c.idRecordCase,c.rf_idV014,u.UnitOfHospital,c.DateBegin,c.DateEnd,
		d.DS1, d.DS2, d.DS3,c.rf_idV009
		,m.MES,0 AS IsDelete
		,c.AmountPayment,mu.id AS idMU, mu.MUSurgery
		,c.Age,CASE WHEN c.Age>0 AND c.Age<4 THEN 4
					WHEN c.age>3 AND c.Age<18 THEN 5
					WHEN c.Age>17 AND c.Age<60 THEN 6
					WHEN c.Age>59 AND c.Age<75 THEN 7
					WHEN c.Age>74 THEN 8
					WHEN c.Age=0 AND DATEDIFF(DAY,p.BirthDay,c.DateBegin)>28 AND DATEDIFF(DAY,p.BirthDay,c.DateBegin)<91 THEN 2
					WHEN c.Age=0 AND DATEDIFF(DAY,p.BirthDay,c.DateBegin)>90 THEN 3
					WHEN c.Age=0 AND DATEDIFF(DAY,p.BirthDay,c.DateBegin)<29 THEN 1
				/*ELSE 3*/ END AS VZST
		,CASE WHEN csg.codePGR IS NOT NULL THEN csg.codePGR ELSE csg.codeMinZdrav END AS K_KSG
		,CASE WHEN csg.codePGR IS NOT NULL THEN 1 ELSE 0 END AS KSG_PG
		,c.IT_SL,ps.ENP,TypeCases, NULL AS Quantity, NULL AS TotalPriceMU, csg.NoLevelCoefficient AS UR_K
		,cc.AmountPayment AS AmountPaymentZSL,u.IDSP
FROM UnitOfHosp u INNER JOIN dbo.t_Case c ON
		u.rf_idCase=c.id
					INNER JOIN dbo.t_RecordCasePatient r ON
		r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient
					INNER JOIN dbo.t_RegistersAccounts a ON
		a.id=r.rf_idRegistersAccounts					                  
					INNER JOIN dbo.t_RegisterPatient p ON --vw_RegisterPatient
		r.id=p.rf_idRecordCase                 
					INNER JOIN dbo.vw_Diagnosis d ON 
		c.id=d.rf_idCase
					INNER JOIN dbo.t_MES m ON
		c.id=m.rf_idCase
					INNER JOIN dbo.vw_sprCSG csg ON
		m.MES=csg.code		
					INNER JOIN dbo.t_PatientSMO ps ON
		r.id=ps.rf_idRecordCasePatient                  
					LEFT JOIN (SELECT rf_idCase,MUSurgery,id 
								FROM dbo.t_Meduslugi m1 INNER JOIN oms_nsi.dbo.tCSGMU csg1 ON
											csg1.CodeMU=m1.MUSurgery
							  ) mu ON
		c.id=mu.rf_idCase     
WHERE TypeCases=9 
UNION ALL
SELECT DISTINCT c.id AS rf_idCase,c.rf_idMO AS CodeM,a.rf_idMO,a.ReportMonth,a.ReportYear,r.rf_idF008,c.rf_idV006,r.SeriaPolis,r.NumberPolis,p.BirthDay,p.rf_idV005
		,c.idRecordCase,c.rf_idV014,u.UnitOfHospital,c.DateBegin,c.DateEnd,
		d.DS1, d.DS2, d.DS3,c.rf_idV009
		,mes.MES AS MES,0 IsDelete--не учитываются случаи реабилитации
		,c.AmountPayment,m.id AS idMU
		,m.MUSurgery ---2020-04-16
		,c.Age,CASE WHEN c.Age>0 AND c.Age<4 THEN 4
					WHEN c.age>3 AND c.Age<18 THEN 5
					WHEN c.Age>17 AND c.Age<60 THEN 6
					WHEN c.Age>59 AND c.Age<75 THEN 7
					WHEN c.Age>74 THEN 8
					WHEN c.Age=0 AND DATEDIFF(DAY,p.BirthDay,c.DateBegin)>28 AND DATEDIFF(DAY,p.BirthDay,c.DateBegin)<91 THEN 2
					WHEN c.Age=0 AND DATEDIFF(DAY,p.BirthDay,c.DateBegin)>90 THEN 3
					WHEN c.Age=0 AND DATEDIFF(DAY,p.BirthDay,c.DateBegin)<29 THEN 1
				/*ELSE 3*/ END AS VZST
		,CASE WHEN IDSP IN(4,28) THEN 'DIAL' ELSE NULL END AS K_KSG
		,0 AS KSG_PG
		,c.IT_SL,ps.ENP,TypeCases,CAST(m.Quantity AS INT) AS Quantity, m.TotalPrice,ISNULL(NULL,0) AS NoLevelCoefficient
		,cc.AmountPayment AS AmountPaymentZSL,u.IDSP
FROM UnitOfHosp u INNER JOIN dbo.t_Case c ON
		u.rf_idCase=c.id
					INNER JOIN dbo.t_RecordCasePatient r ON
		r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient
					INNER JOIN dbo.t_RegistersAccounts a ON
		a.id=r.rf_idRegistersAccounts					                  
					INNER JOIN dbo.t_RegisterPatient p ON --vw_RegisterPatient
		r.id=p.rf_idRecordCase                 					
					INNER JOIN dbo.vw_Diagnosis d ON 
		c.id=d.rf_idCase										
					INNER JOIN dbo.t_PatientSMO ps ON
		r.id=ps.rf_idRecordCasePatient                  
					INNER JOIN dbo.t_Meduslugi m ON
		c.id=m.rf_idCase     		                 
					LEFT JOIN t_Mes mes ON
		c.id=mes.rf_idCase
		AND mes.TypeMES=2        
WHERE TypeCases=10 AND IDSP =28	 AND m.MUGroupCode=60 AND m.MUUnGroupCode=3/*сюда отбор случаев у которых не должно быть VID_VME ксгшных. Но таких нету т.к медуслуги мы заменяем*/
UNION ALL
SELECT DISTINCT c.id AS rf_idCase,c.rf_idMO AS CodeM,a.rf_idMO,a.ReportMonth,a.ReportYear,r.rf_idF008,c.rf_idV006,r.SeriaPolis,r.NumberPolis,p.BirthDay,p.rf_idV005
		,c.idRecordCase,c.rf_idV014,u.UnitOfHospital,c.DateBegin,c.DateEnd,
		d.DS1, d.DS2, d.DS3,c.rf_idV009
		,mes.MES AS MES,0 IsDelete--не учитываются случаи реабилитации
		,c.AmountPayment,m.id AS idMU
		,m.MUSurgery--2020-04-16
		,c.Age,CASE WHEN c.Age>0 AND c.Age<4 THEN 4
					WHEN c.age>3 AND c.Age<18 THEN 5
					WHEN c.Age>17 AND c.Age<60 THEN 6
					WHEN c.Age>59 AND c.Age<75 THEN 7
					WHEN c.Age>74 THEN 8
					WHEN c.Age=0 AND DATEDIFF(DAY,p.BirthDay,c.DateBegin)>28 AND DATEDIFF(DAY,p.BirthDay,c.DateBegin)<91 THEN 2
					WHEN c.Age=0 AND DATEDIFF(DAY,p.BirthDay,c.DateBegin)>90 THEN 3
					WHEN c.Age=0 AND DATEDIFF(DAY,p.BirthDay,c.DateBegin)<29 THEN 1
				/*ELSE 3*/ END AS VZST		
		,CASE WHEN csg.codePGR IS NOT NULL THEN csg.codePGR ELSE csg.codeMinZdrav END AS K_KSG
		,CASE WHEN csg.codePGR IS NOT NULL THEN 1 ELSE 0 END AS KSG_PG
		,c.IT_SL,ps.ENP,TypeCases,CAST(m.Quantity AS INT) AS Quantity, m.TotalPrice,ISNULL(NULL,0) AS NoLevelCoefficient
		,cc.AmountPayment AS AmountPaymentZSL,u.IDSP
FROM UnitOfHosp u INNER JOIN dbo.t_Case c ON
		u.rf_idCase=c.id
					INNER JOIN dbo.t_RecordCasePatient r ON
		r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient
					INNER JOIN dbo.t_RegistersAccounts a ON
		a.id=r.rf_idRegistersAccounts					                  
					INNER JOIN dbo.t_RegisterPatient p ON --vw_RegisterPatient
		r.id=p.rf_idRecordCase                 					
					INNER JOIN dbo.vw_Diagnosis d ON 
		c.id=d.rf_idCase										
					INNER JOIN dbo.t_PatientSMO ps ON
		r.id=ps.rf_idRecordCasePatient                  
					INNER JOIN dbo.t_Meduslugi m ON
		c.id=m.rf_idCase     		                    
					INNER JOIN t_Mes mes ON
		c.id=mes.rf_idCase
		AND mes.TypeMES=2 
					INNER JOIN dbo.vw_sprCSG csg ON
		mes.MES=csg.code						   
WHERE TypeCases=10 AND IDSP=33	AND m.MUGroupCode=60 AND m.MUUnGroupCode=3	            
---------------------------Берем услуги у которыг VID_VME есть для диализа, но которые не диализ---------------------------------------
UNION ALL
SELECT DISTINCT c.id AS rf_idCase,c.rf_idMO AS CodeM,a.rf_idMO,a.ReportMonth,a.ReportYear,r.rf_idF008,c.rf_idV006,r.SeriaPolis,r.NumberPolis,p.BirthDay,p.rf_idV005
		,c.idRecordCase,c.rf_idV014,u.UnitOfHospital,c.DateBegin,c.DateEnd,
		d.DS1, d.DS2, d.DS3,c.rf_idV009
		,mes.MES AS MES,0 IsDelete--не учитываются случаи реабилитации
		,c.AmountPayment,mu1.id AS idMU, mu1.MUSurgery
		,c.Age,CASE WHEN c.Age>0 AND c.Age<4 THEN 4
					WHEN c.age>3 AND c.Age<18 THEN 5
					WHEN c.Age>17 AND c.Age<60 THEN 6
					WHEN c.Age>59 AND c.Age<75 THEN 7
					WHEN c.Age>74 THEN 8
					WHEN c.Age=0 AND DATEDIFF(DAY,p.BirthDay,c.DateBegin)>28 AND DATEDIFF(DAY,p.BirthDay,c.DateBegin)<91 THEN 2
					WHEN c.Age=0 AND DATEDIFF(DAY,p.BirthDay,c.DateBegin)>90 THEN 3
					WHEN c.Age=0 AND DATEDIFF(DAY,p.BirthDay,c.DateBegin)<29 THEN 1
				/*ELSE 3*/ END AS VZST		
		,CASE WHEN csg.codePGR IS NOT NULL THEN csg.codePGR ELSE csg.codeMinZdrav END AS K_KSG
		,CASE WHEN csg.codePGR IS NOT NULL THEN 1 ELSE 0 END AS KSG_PG
		,c.IT_SL,ps.ENP,TypeCases,NULL AS Quantity, NULL,ISNULL(NULL,0) AS NoLevelCoefficient
		,cc.AmountPayment AS AmountPaymentZSL,u.IDSP
FROM UnitOfHosp u INNER JOIN dbo.t_Case c ON
		u.rf_idCase=c.id
					INNER JOIN dbo.t_RecordCasePatient r ON
		r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient
					INNER JOIN dbo.t_RegistersAccounts a ON
		a.id=r.rf_idRegistersAccounts					                  
					INNER JOIN dbo.t_RegisterPatient p ON --vw_RegisterPatient
		r.id=p.rf_idRecordCase                 					
					INNER JOIN dbo.vw_Diagnosis d ON 
		c.id=d.rf_idCase										
					INNER JOIN dbo.t_PatientSMO ps ON
		r.id=ps.rf_idRecordCasePatient                  
					INNER JOIN dbo.t_Meduslugi m ON
		c.id=m.rf_idCase    
		AND m.MUGroupCode=60 AND m.MUUnGroupCode=3 					                      
					INNER JOIN t_Mes mes ON
		c.id=mes.rf_idCase
		AND mes.TypeMES=2 
					INNER JOIN dbo.vw_sprCSG csg ON
		mes.MES=csg.code	
					INNER JOIN dbo.t_Meduslugi mu1 ON
		c.id=mu1.rf_idCase       
		AND mu1.MUSurgery IS NOT NULL		
WHERE TypeCases=10 AND IDSP=33	
)
SELECT  DENSE_RANK() OVER(ORDER BY rf_idCase ,ReportYear,ReportMonth) AS id, rf_idCase ,CodeM ,rf_idMO ,CAST(MONTH(@dateStartPay) AS TINYINT) AS ReportMonth 
		,CAST(YEAR(@dateStart) AS SMALLINT) AS ReportYear,
        rf_idF008 ,rf_idV006 ,SeriaPolis ,NumberPolis ,BirthDay ,rf_idV005 ,idRecordCase ,rf_idV014 ,UnitOfHospital ,
        DateBegin ,DateEnd ,DS1 ,DS2 ,DS3 ,rf_idV009 ,MES ,AmountPayment ,idMU ,MUSurgery ,Age ,VZST ,K_KSG ,KSG_PG,0 PVT,0 AS IsDisableCheck,IT_SL,ENP,TypeCases,Quantity
		,TotalPriceMU, UR_K,IDSP,AmountPaymentZSL
INTO #t
FROM data_Send 
WHERE IsDelete=0 AND NOT EXISTS(SELECT * FROM dbo.t_SendingDataIntoFFOMS WHERE rf_idCase=data_Send.rf_idCase AND ReportMonth<3)--включение случая происходит только один раз проверяем март

UPDATE f SET f.MUSurgery=NULL, f.idMU=NULL
FROM #t f INNER JOIN oms_NSI.dbo.v001 v1 ON
				f.MUSurgery=v1.IDRB
WHERE v1.isTelemedicine=1


UPDATE s SET s.MUSurgery=v.MU
FROM #t s INNER JOIN (VALUES ('B01.001.006.001','B01.001.006'),('B01.001.009.001','B01.001.009 '),('A11.20.025','A11.20.027')) v(MU_E, MU) ON
			s.MUSurgery=v.MU_E
--список случаев которые есть в основной таблице, но нет во временой
SELECT DISTINCT s.rf_idCase
FROM dbo.t_SendingDataIntoFFOMS s
WHERE s.ReportMonth=3 and NOT EXISTS(SELECT 1 FROM #t t WHERE t.rf_idCase=s.rf_idCase)
-- наоборот
SELECT DISTINCT s.*
FROM  #t  s INNER JOIN dbo.t_Meduslugi m ON
		s.rf_idCase=m.rf_idCase
WHERE NOT EXISTS(SELECT 1 FROM dbo.t_SendingDataIntoFFOMS t WHERE t.rf_idCase=s.rf_idCase)
GO
DROP TABLE #t
go
DROP TABLE #tPeople