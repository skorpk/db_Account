USE AccountOMS
GO
DECLARE @dateStartReg DATETIME='20180101',
		@dateEndReg DATETIME='20190122',
		@reportYear SMALLINT=2018,
		@dateStartReg2 DATETIME='20190101',
		@dateEndReg2 DATETIME='20200118',
		@reportYear2 SMALLINT=2019

DECLARE @dateBegCase DATE='20180101',
		@dateEndCase date='20181231'


SELECT c.id AS rf_idCase, c.AmountPayment AS AmountPayment2,c.AmountPayment,a.ReportYear,c.Age,1 AS Quantity
INTO #t
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient					
					--INNER JOIN dbo.t_Meduslugi m ON
     --        c.id=m.rf_idCase
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND rf_idV006=4 AND c.DateEnd BETWEEN @dateBegCase AND @dateEndCase
GROUP BY c.id, c.AmountPayment,a.ReportYear,c.Age

SELECT @dateEndCase=DATEADD(YEAR,1,@dateEndCase),@dateBegCase=DATEADD(YEAR,1,@dateBegCase)

INSERT INTO #t
SELECT c.id AS rf_idCase, c.AmountPayment AS AmountPayment2,c.AmountPayment,a.ReportYear,c.Age,1 AS Quantity
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient					
					--INNER JOIN dbo.t_Meduslugi m ON
     --        c.id=m.rf_idCase
WHERE f.DateRegistration>=@dateStartReg2 AND f.DateRegistration<@dateEndReg2  AND a.ReportYear=@reportYear2 AND rf_idV006=4 AND c.DateEnd BETWEEN @dateBegCase AND @dateEndCase
GROUP BY c.id, c.AmountPayment,a.ReportYear,c.Age

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #t p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStartReg AND c.DateRegistration<'20190123'
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
WHERE ReportYear=2018

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #t p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStartReg2 AND c.DateRegistration<'20200121'
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
WHERE ReportYear=2019

SELECT '1'
		----child 2018
		,SUM(CASE WHEN ReportYear=2018 AND Age<18 THEN Quantity ELSE 0 END) AS Col3
		,SUM(CASE WHEN ReportYear=2018 AND Age<18 THEN AmountPayment2 ELSE 0 END) AS Col4
		----Adult 2018
		,SUM(CASE WHEN ReportYear=2018 AND Age>17 AND Age<65 THEN Quantity ELSE 0 END) AS Col5
		, SUM(CASE WHEN ReportYear=2018 AND Age>17 AND Age<65 THEN AmountPayment2 ELSE 0 END) AS Col6
		---------------Retiree 2018
		,SUM(CASE WHEN ReportYear=2018 AND Age>64 THEN Quantity ELSE 0 END) AS Col7
		,SUM(CASE WHEN ReportYear=2018 AND Age>64 THEN AmountPayment2 ELSE 0 END) AS Col8
		----child 2019
		,SUM(CASE WHEN ReportYear=2019 AND Age<18 THEN Quantity ELSE 0 END) AS Col9
		,SUM(CASE WHEN ReportYear=2019 AND Age<18 THEN AmountPayment2 ELSE 0 END) AS Col10
		----Adult 2019
		,SUM(CASE WHEN ReportYear=2019 AND Age>17 AND Age<65 THEN Quantity ELSE 0 END) AS Col11
		,SUM(CASE WHEN ReportYear=2019  AND Age>17 AND Age<65 THEN AmountPayment2 ELSE 0 END) AS Col12
		---------------Retiree 2019
		,SUM(CASE WHEN ReportYear=2019 AND Age>64 THEN Quantity ELSE 0 END) AS Col13
		,SUM(CASE WHEN ReportYear=2019 AND Age>64 THEN AmountPayment2 ELSE 0 END) AS Col14
FROM #t
WHERE (CASE WHEN AmountPayment2>0 AND AmountPayment>0 THEN 1 WHEN AmountPayment2=0 AND AmountPayment=0 THEN 1 ELSE 0 END)=1
GO
DROP TABLE #t
GO
-------------------------------------------------------------------------------------------------------------------------------
DECLARE @dateStartReg DATETIME='20180101',
		@dateEndReg DATETIME='20190122',
		@reportYear SMALLINT=2018,
		@dateStartReg2 DATETIME='20190101',
		@dateEndReg2 DATETIME='20200118',
		@reportYear2 SMALLINT=2019

DECLARE @dateBegCase DATE='20180101',
		@dateEndCase date='20181231'
-----------------------------2018
SELECT c.id AS rf_idCase, c.AmountPayment AS AmountPayment2,c.AmountPayment,a.ReportYear,c.Age,SUM(m.Quantity) AS Quantity
INTO #t
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient					
					INNER JOIN dbo.t_Meduslugi m ON
             c.id=m.rf_idCase
					INNER JOIN dbo.t_Case_UnitCode_V006  u ON
             c.id=u.rf_idCase
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND u.UnitCode IN(30,38,145,317) AND c.DateEnd BETWEEN @dateBegCase AND @dateEndCase
GROUP BY c.id, c.AmountPayment,a.ReportYear,c.Age

INSERT INTO #t
SELECT c.id AS rf_idCase, c.AmountPayment AS AmountPayment2,c.AmountPayment,a.ReportYear,c.Age,0 AS Quantity
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case_UnitCode_V006  u ON
             c.id=u.rf_idCase										
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND u.UnitCode IN(33,69,153,206) AND c.DateEnd BETWEEN @dateBegCase AND @dateEndCase
GROUP BY c.id, c.AmountPayment,a.ReportYear,c.Age
-----------------------------2019
SELECT @dateEndCase=DATEADD(YEAR,1,@dateEndCase),@dateBegCase=DATEADD(YEAR,1,@dateBegCase)
INSERT INTO #t
SELECT c.id AS rf_idCase, c.AmountPayment AS AmountPayment2,c.AmountPayment,a.ReportYear,c.Age,1 AS Quantity
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case_UnitCode_V006  u ON
             c.id=u.rf_idCase										
WHERE f.DateRegistration>=@dateStartReg2 AND f.DateRegistration<@dateEndReg2  AND a.ReportYear=@reportYear2 AND u.UnitCode IN(260,261,262) AND c.DateEnd BETWEEN @dateBegCase AND @dateEndCase
GROUP BY c.id, c.AmountPayment,a.ReportYear,c.Age
INSERT INTO #t
SELECT c.id AS rf_idCase, c.AmountPayment AS AmountPayment2,c.AmountPayment,a.ReportYear,c.Age,0 AS Quantity
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case_UnitCode_V006  u ON
             c.id=u.rf_idCase										
WHERE f.DateRegistration>=@dateStartReg2 AND f.DateRegistration<@dateEndReg2  AND a.ReportYear=@reportYear2 AND u.UnitCode IN(33,69,153,206) AND c.DateEnd BETWEEN @dateBegCase AND @dateEndCase
GROUP BY c.id, c.AmountPayment,a.ReportYear,c.Age

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #t p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStartReg AND c.DateRegistration<'20190123'
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
WHERE ReportYear=@reportYear

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #t p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStartReg2 AND c.DateRegistration<'20200121'
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
WHERE ReportYear=@reportYear2
SELECT '2.1'
	----child 2018
		,SUM(CASE WHEN ReportYear=2018 AND Age<18 THEN Quantity ELSE 0 END) AS Col3
		,SUM(CASE WHEN ReportYear=2018 AND Age<18 THEN AmountPayment2 ELSE 0 END) AS Col4
		----Adult 2018
		,SUM(CASE WHEN ReportYear=2018 AND Age>17 AND Age<65 THEN Quantity ELSE 0 END) AS Col5
		, SUM(CASE WHEN ReportYear=2018 AND Age>17 AND Age<65 THEN AmountPayment2 ELSE 0 END) AS Col6
		---------------Retiree 2018
		,SUM(CASE WHEN ReportYear=2018 AND Age>64 THEN Quantity ELSE 0 END) AS Col7
		,SUM(CASE WHEN ReportYear=2018 AND Age>64 THEN AmountPayment2 ELSE 0 END) AS Col8
		----child 2019
		,SUM(CASE WHEN ReportYear=2019 AND Age<18 THEN Quantity ELSE 0 END) AS Col9
		,SUM(CASE WHEN ReportYear=2019 AND Age<18 THEN AmountPayment2 ELSE 0 END) AS Col10
		----Adult 2019
		,SUM(CASE WHEN ReportYear=2019 AND Age>17 AND Age<65 THEN Quantity ELSE 0 END) AS Col11
		,SUM(CASE WHEN ReportYear=2019  AND Age>17 AND Age<65 THEN AmountPayment2 ELSE 0 END) AS Col12
		---------------Retiree 2019
		,SUM(CASE WHEN ReportYear=2019 AND Age>64 THEN Quantity ELSE 0 END) AS Col13
		,SUM(CASE WHEN ReportYear=2019 AND Age>64 THEN AmountPayment2 ELSE 0 END) AS Col14
FROM #t
WHERE (CASE WHEN AmountPayment2>0 AND AmountPayment>0 THEN 1 WHEN AmountPayment2=0 AND AmountPayment=0 THEN 1 ELSE 0 END)=1
GO
DROP TABLE #t
GO
-------------------------------------------------------------------------------------------------------------------------------
DECLARE @dateStartReg DATETIME='20180101',
		@dateEndReg DATETIME='20190122',
		@reportYear SMALLINT=2018,
		@dateStartReg2 DATETIME='20190101',
		@dateEndReg2 DATETIME='20200118',
		@reportYear2 SMALLINT=2019

DECLARE @dateBegCase DATE='20180101',
		@dateEndCase date='20181231'
-----------------------------2018
SELECT c.id AS rf_idCase, c.AmountPayment AS AmountPayment2,c.AmountPayment,a.ReportYear,c.Age,SUM(m.Quantity) AS Quantity
INTO #t
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient					
					INNER JOIN dbo.t_Meduslugi m ON
             c.id=m.rf_idCase
					INNER JOIN dbo.t_Case_UnitCode_V006  u ON
             c.id=u.rf_idCase
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND u.UnitCode IN(131,146) AND c.DateEnd BETWEEN @dateBegCase AND @dateEndCase
GROUP BY c.id, c.AmountPayment,a.ReportYear,c.Age
-----------------------------2019
SELECT @dateEndCase=DATEADD(YEAR,1,@dateEndCase),@dateBegCase=DATEADD(YEAR,1,@dateBegCase)
INSERT INTO #t
SELECT c.id AS rf_idCase, c.AmountPayment AS AmountPayment2,c.AmountPayment,a.ReportYear,c.Age,SUM(m.Quantity) AS Quantity
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient					
					INNER JOIN dbo.t_Meduslugi m ON
             c.id=m.rf_idCase
					INNER JOIN dbo.t_Case_UnitCode_V006  u ON
             c.id=u.rf_idCase								
WHERE f.DateRegistration>=@dateStartReg2 AND f.DateRegistration<@dateEndReg2  AND a.ReportYear=@reportYear2 AND u.UnitCode IN (131,146) AND c.DateEnd BETWEEN @dateBegCase AND @dateEndCase
GROUP BY c.id, c.AmountPayment,a.ReportYear,c.Age


UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #t p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStartReg AND c.DateRegistration<'20190123'
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
WHERE ReportYear=@reportYear

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #t p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStartReg2 AND c.DateRegistration<'20200121'
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
WHERE ReportYear=@reportYear2
SELECT '2.2'
		----child 2018
		,SUM(CASE WHEN ReportYear=2018 AND Age<18 THEN Quantity ELSE 0 END) AS Col3
		,SUM(CASE WHEN ReportYear=2018 AND Age<18 THEN AmountPayment2 ELSE 0 END) AS Col4
		----Adult 2018
		,SUM(CASE WHEN ReportYear=2018 AND Age>17 AND Age<65 THEN Quantity ELSE 0 END) AS Col5
		, SUM(CASE WHEN ReportYear=2018 AND Age>17 AND Age<65 THEN AmountPayment2 ELSE 0 END) AS Col6
		---------------Retiree 2018
		,SUM(CASE WHEN ReportYear=2018 AND Age>64 THEN Quantity ELSE 0 END) AS Col7
		,SUM(CASE WHEN ReportYear=2018 AND Age>64 THEN AmountPayment2 ELSE 0 END) AS Col8
		----child 2019
		,SUM(CASE WHEN ReportYear=2019 AND Age<18 THEN Quantity ELSE 0 END) AS Col9
		,SUM(CASE WHEN ReportYear=2019 AND Age<18 THEN AmountPayment2 ELSE 0 END) AS Col10
		----Adult 2019
		,SUM(CASE WHEN ReportYear=2019 AND Age>17 AND Age<65 THEN Quantity ELSE 0 END) AS Col11
		,SUM(CASE WHEN ReportYear=2019  AND Age>17 AND Age<65 THEN AmountPayment2 ELSE 0 END) AS Col12
		---------------Retiree 2019
		,SUM(CASE WHEN ReportYear=2019 AND Age>64 THEN Quantity ELSE 0 END) AS Col13
		,SUM(CASE WHEN ReportYear=2019 AND Age>64 THEN AmountPayment2 ELSE 0 END) AS Col14
FROM #t
WHERE (CASE WHEN AmountPayment2>0 AND AmountPayment>0 THEN 1 WHEN AmountPayment2=0 AND AmountPayment=0 THEN 1 ELSE 0 END)=1
GO
DROP TABLE #t
GO
-------------------------------------------------------------------------------------------------------------------------------
DECLARE @dateStartReg DATETIME='20180101',
		@dateEndReg DATETIME='20190122',
		@reportYear SMALLINT=2018,
		@dateStartReg2 DATETIME='20190101',
		@dateEndReg2 DATETIME='20200118',
		@reportYear2 SMALLINT=2019

DECLARE @dateBegCase DATE='20180101',
		@dateEndCase date='20181231'
-----------------------------2018
SELECT DISTINCt c.id AS rf_idCase, c.AmountPayment AS AmountPayment2,c.AmountPayment,a.ReportYear,c.Age,1 AS Quantity
INTO #t
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient										
					INNER JOIN dbo.t_Case_UnitCode_V006  u ON
             c.id=u.rf_idCase
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND u.UnitCode IN (32,147,205) AND c.DateEnd BETWEEN @dateBegCase AND @dateEndCase

-----------------------------2019
SELECT @dateEndCase=DATEADD(YEAR,1,@dateEndCase),@dateBegCase=DATEADD(YEAR,1,@dateBegCase)

INSERT INTO #t
SELECT DISTINCt c.id AS rf_idCase, c.AmountPayment AS AmountPayment2,c.AmountPayment,a.ReportYear,c.Age,1 AS Quantity
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient										
					INNER JOIN dbo.t_Case_UnitCode_V006  u ON
             c.id=u.rf_idCase								
WHERE f.DateRegistration>=@dateStartReg2 AND f.DateRegistration<@dateEndReg2  AND a.ReportYear=@reportYear2 AND u.UnitCode IN (32,147,205) AND c.DateEnd BETWEEN @dateBegCase AND @dateEndCase



UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #t p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStartReg AND c.DateRegistration<'20190123'
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
WHERE ReportYear=@reportYear

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #t p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStartReg2 AND c.DateRegistration<'20200121'
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
WHERE ReportYear=@reportYear2
SELECT '2.3'
		----child 2018
		,SUM(CASE WHEN ReportYear=2018 AND Age<18 THEN Quantity ELSE 0 END) AS Col3
		,SUM(CASE WHEN ReportYear=2018 AND Age<18 THEN AmountPayment2 ELSE 0 END) AS Col4
		----Adult 2018
		,SUM(CASE WHEN ReportYear=2018 AND Age>17 AND Age<65 THEN Quantity ELSE 0 END) AS Col5
		, SUM(CASE WHEN ReportYear=2018 AND Age>17 AND Age<65 THEN AmountPayment2 ELSE 0 END) AS Col6
		---------------Retiree 2018
		,SUM(CASE WHEN ReportYear=2018 AND Age>64 THEN Quantity ELSE 0 END) AS Col7
		,SUM(CASE WHEN ReportYear=2018 AND Age>64 THEN AmountPayment2 ELSE 0 END) AS Col8
		----child 2019
		,SUM(CASE WHEN ReportYear=2019 AND Age<18 THEN Quantity ELSE 0 END) AS Col9
		,SUM(CASE WHEN ReportYear=2019 AND Age<18 THEN AmountPayment2 ELSE 0 END) AS Col10
		----Adult 2019
		,SUM(CASE WHEN ReportYear=2019 AND Age>17 AND Age<65 THEN Quantity ELSE 0 END) AS Col11
		,SUM(CASE WHEN ReportYear=2019  AND Age>17 AND Age<65 THEN AmountPayment2 ELSE 0 END) AS Col12
		---------------Retiree 2019
		,SUM(CASE WHEN ReportYear=2019 AND Age>64 THEN Quantity ELSE 0 END) AS Col13
		,SUM(CASE WHEN ReportYear=2019 AND Age>64 THEN AmountPayment2 ELSE 0 END) AS Col14
FROM #t
WHERE (CASE WHEN AmountPayment2>0 AND AmountPayment>0 THEN 1 WHEN AmountPayment2=0 AND AmountPayment=0 THEN 1 ELSE 0 END)=1
GO
DROP TABLE #t
GO
-----------------------------------------------------------------------------------------------------------------------------------------------
DECLARE @dateStartReg DATETIME='20180101',
		@dateEndReg DATETIME='20190122',
		@reportYear SMALLINT=2018,
		@dateStartReg2 DATETIME='20190101',
		@dateEndReg2 DATETIME='20200118',
		@reportYear2 SMALLINT=2019

DECLARE @dateBegCase DATE='20180101',
		@dateEndCase date='20181231'
-----------------------------2018
SELECT DISTINCT c.id AS rf_idCase, c.AmountPayment AS AmountPayment2,c.AmountPayment,a.ReportYear,c.Age,0 AS Quantity
INTO #t
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient										
					INNER JOIN dbo.t_Case_UnitCode_V006  u ON
             c.id=u.rf_idCase
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND u.UnitCode IN (148,149,150,151,161,162) AND c.DateEnd BETWEEN @dateBegCase AND @dateEndCase
-----------------------------2019
SELECT @dateEndCase=DATEADD(YEAR,1,@dateEndCase),@dateBegCase=DATEADD(YEAR,1,@dateBegCase)
INSERT INTO #t
SELECT DISTINCT c.id AS rf_idCase, c.AmountPayment AS AmountPayment2,c.AmountPayment,a.ReportYear,c.Age,0 AS Quantity
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient										
					INNER JOIN dbo.t_Case_UnitCode_V006  u ON
             c.id=u.rf_idCase								
WHERE f.DateRegistration>=@dateStartReg2 AND f.DateRegistration<@dateEndReg2  AND a.ReportYear=@reportYear2 AND u.UnitCode IN (148,149,150,151,161,162) AND c.DateEnd BETWEEN @dateBegCase AND @dateEndCase


UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #t p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStartReg AND c.DateRegistration<'20190123'
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
WHERE ReportYear=@reportYear

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #t p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStartReg2 AND c.DateRegistration<'20200121'
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
WHERE ReportYear=@reportYear2
SELECT '2.4'
		----child 2018
		,SUM(CASE WHEN ReportYear=2018 AND Age<18 THEN Quantity ELSE 0 END) AS Col3
		,SUM(CASE WHEN ReportYear=2018 AND Age<18 THEN AmountPayment2 ELSE 0 END) AS Col4
		----Adult 2018
		,SUM(CASE WHEN ReportYear=2018 AND Age>17 AND Age<65 THEN Quantity ELSE 0 END) AS Col5
		, SUM(CASE WHEN ReportYear=2018 AND Age>17 AND Age<65 THEN AmountPayment2 ELSE 0 END) AS Col6
		---------------Retiree 2018
		,SUM(CASE WHEN ReportYear=2018 AND Age>64 THEN Quantity ELSE 0 END) AS Col7
		,SUM(CASE WHEN ReportYear=2018 AND Age>64 THEN AmountPayment2 ELSE 0 END) AS Col8
		----child 2019
		,SUM(CASE WHEN ReportYear=2019 AND Age<18 THEN Quantity ELSE 0 END) AS Col9
		,SUM(CASE WHEN ReportYear=2019 AND Age<18 THEN AmountPayment2 ELSE 0 END) AS Col10
		----Adult 2019
		,SUM(CASE WHEN ReportYear=2019 AND Age>17 AND Age<65 THEN Quantity ELSE 0 END) AS Col11
		,SUM(CASE WHEN ReportYear=2019  AND Age>17 AND Age<65 THEN AmountPayment2 ELSE 0 END) AS Col12
		---------------Retiree 2019
		,SUM(CASE WHEN ReportYear=2019 AND Age>64 THEN Quantity ELSE 0 END) AS Col13
		,SUM(CASE WHEN ReportYear=2019 AND Age>64 THEN AmountPayment2 ELSE 0 END) AS Col14
FROM #t
WHERE (CASE WHEN AmountPayment2>0 AND AmountPayment>0 THEN 1 WHEN AmountPayment2=0 AND AmountPayment=0 THEN 1 ELSE 0 END)=1
GO
DROP TABLE #t
GO
-----------------------------------------------Дневной стационар------------------------------------------------------------------------------------------------
DECLARE @dateStartReg DATETIME='20180101',
		@dateEndReg DATETIME='20190122',
		@reportYear SMALLINT=2018,
		@dateStartReg2 DATETIME='20190101',
		@dateEndReg2 DATETIME='20200118',
		@reportYear2 SMALLINT=2019

DECLARE @dateBegCase DATE='20180101',
		@dateEndCase date='20181231'
-----------------------------2018
SELECT distinct c.id AS rf_idCase, c.AmountPayment AS AmountPayment2,c.AmountPayment,a.ReportYear,c.Age,1 AS Quantity
,CASE WHEN c.rf_idV002 IN(18,60,76) THEN 1 ELSE 0 END AS Profil
INTO #t
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient															
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND c.rf_idV006=2 AND c.DateEnd BETWEEN @dateBegCase AND @dateEndCase
-----------------------------2019
SELECT @dateEndCase=DATEADD(YEAR,1,@dateEndCase),@dateBegCase=DATEADD(YEAR,1,@dateBegCase)

INSERT INTO #t
SELECT DISTINCT c.id AS rf_idCase, c.AmountPayment AS AmountPayment2,c.AmountPayment,a.ReportYear,c.Age,1 AS Quantity
,CASE WHEN c.rf_idV002 IN(18,60,76) THEN 1 ELSE 0 END AS Profil
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient														
WHERE f.DateRegistration>=@dateStartReg2 AND f.DateRegistration<@dateEndReg2  AND a.ReportYear=@reportYear2 AND c.rf_idV006=2 AND c.DateEnd BETWEEN @dateBegCase AND @dateEndCase

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #t p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStartReg AND c.DateRegistration<'20190123'
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
WHERE ReportYear=@reportYear

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #t p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStartReg2 AND c.DateRegistration<'20200121'
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
WHERE ReportYear=@reportYear2
SELECT '3'
		----child 2018
		,SUM(CASE WHEN ReportYear=2018 AND Age<18 THEN Quantity ELSE 0 END) AS Col3
		,SUM(CASE WHEN ReportYear=2018 AND Age<18 THEN AmountPayment2 ELSE 0 END) AS Col4
		----Adult 2018
		,SUM(CASE WHEN ReportYear=2018 AND Age>17 AND Age<65 THEN Quantity ELSE 0 END) AS Col5
		, SUM(CASE WHEN ReportYear=2018 AND Age>17 AND Age<65 THEN AmountPayment2 ELSE 0 END) AS Col6
		---------------Retiree 2018
		,SUM(CASE WHEN ReportYear=2018 AND Age>64 THEN Quantity ELSE 0 END) AS Col7
		,SUM(CASE WHEN ReportYear=2018 AND Age>64 THEN AmountPayment2 ELSE 0 END) AS Col8
		----child 2019
		,SUM(CASE WHEN ReportYear=2019 AND Age<18 THEN Quantity ELSE 0 END) AS Col9
		,SUM(CASE WHEN ReportYear=2019 AND Age<18 THEN AmountPayment2 ELSE 0 END) AS Col10
		----Adult 2019
		,SUM(CASE WHEN ReportYear=2019 AND Age>17 AND Age<65 THEN Quantity ELSE 0 END) AS Col11
		,SUM(CASE WHEN ReportYear=2019  AND Age>17 AND Age<65 THEN AmountPayment2 ELSE 0 END) AS Col12
		---------------Retiree 2019
		,SUM(CASE WHEN ReportYear=2019 AND Age>64 THEN Quantity ELSE 0 END) AS Col13
		,SUM(CASE WHEN ReportYear=2019 AND Age>64 THEN AmountPayment2 ELSE 0 END) AS Col14
FROM #t
WHERE (CASE WHEN AmountPayment2>0 AND AmountPayment>0 THEN 1 WHEN AmountPayment2=0 AND AmountPayment=0 THEN 1 ELSE 0 END)=1 AND Profil=0
UNION ALL
SELECT '3.1'
		----child 2018
		,SUM(CASE WHEN ReportYear=2018 AND Age<18 THEN Quantity ELSE 0 END) AS Col3
		,SUM(CASE WHEN ReportYear=2018 AND Age<18 THEN AmountPayment2 ELSE 0 END) AS Col4
		----Adult 2018
		,SUM(CASE WHEN ReportYear=2018 AND Age>17 AND Age<65 THEN Quantity ELSE 0 END) AS Col5
		, SUM(CASE WHEN ReportYear=2018 AND Age>17 AND Age<65 THEN AmountPayment2 ELSE 0 END) AS Col6
		---------------Retiree 2018
		,SUM(CASE WHEN ReportYear=2018 AND Age>64 THEN Quantity ELSE 0 END) AS Col7
		,SUM(CASE WHEN ReportYear=2018 AND Age>64 THEN AmountPayment2 ELSE 0 END) AS Col8
		----child 2019
		,SUM(CASE WHEN ReportYear=2019 AND Age<18 THEN Quantity ELSE 0 END) AS Col9
		,SUM(CASE WHEN ReportYear=2019 AND Age<18 THEN AmountPayment2 ELSE 0 END) AS Col10
		----Adult 2019
		,SUM(CASE WHEN ReportYear=2019 AND Age>17 AND Age<65 THEN Quantity ELSE 0 END) AS Col11
		,SUM(CASE WHEN ReportYear=2019  AND Age>17 AND Age<65 THEN AmountPayment2 ELSE 0 END) AS Col12
		---------------Retiree 2019
		,SUM(CASE WHEN ReportYear=2019 AND Age>64 THEN Quantity ELSE 0 END) AS Col13
		,SUM(CASE WHEN ReportYear=2019 AND Age>64 THEN AmountPayment2 ELSE 0 END) AS Col14
FROM #t
WHERE (CASE WHEN AmountPayment2>0 AND AmountPayment>0 THEN 1 WHEN AmountPayment2=0 AND AmountPayment=0 THEN 1 ELSE 0 END)=1 AND Profil=1

GO
DROP TABLE #t
GO
-----------------------------------------------стационар------------------------------------------------------------------------------------------------
DECLARE @dateStartReg DATETIME='20180101',
		@dateEndReg DATETIME='20190122',
		@reportYear SMALLINT=2018,
		@dateStartReg2 DATETIME='20190101',
		@dateEndReg2 DATETIME='20200118',
		@reportYear2 SMALLINT=2019

DECLARE @dateBegCase DATE='20180101',
		@dateEndCase date='20181231'
-----------------------------2018
SELECT distinct c.id AS rf_idCase, c.AmountPayment AS AmountPayment2,c.AmountPayment,a.ReportYear,c.Age,1 AS Quantity
,CASE WHEN c.rf_idV002 IN(18,60,76) THEN 1 WHEN c.rf_idV002=158 THEN 2 ELSE 0 END AS Profil
INTO #t
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient															
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND c.rf_idV006=1 AND c.DateEnd BETWEEN @dateBegCase AND @dateEndCase

-----------------------------2019
SELECT @dateEndCase=DATEADD(YEAR,1,@dateEndCase),@dateBegCase=DATEADD(YEAR,1,@dateBegCase)
INSERT INTO #t
SELECT DISTINCT c.id AS rf_idCase, c.AmountPayment AS AmountPayment2,c.AmountPayment,a.ReportYear,c.Age,1 AS Quantity
,CASE WHEN c.rf_idV002 IN(18,60,76) THEN 1 WHEN c.rf_idV002=158 THEN 2 ELSE 0 END AS Profil
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient														
WHERE f.DateRegistration>=@dateStartReg2 AND f.DateRegistration<@dateEndReg2  AND a.ReportYear=@reportYear2 AND c.rf_idV006=1 AND c.DateEnd BETWEEN @dateBegCase AND @dateEndCase



UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #t p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStartReg AND c.DateRegistration<'20190123'
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
WHERE ReportYear=@reportYear

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #t p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStartReg2 AND c.DateRegistration<'20200121'
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
WHERE ReportYear=@reportYear2
SELECT '4'
		----child 2018
		,SUM(CASE WHEN ReportYear=2018 AND Age<18 THEN Quantity ELSE 0 END) AS Col3
		,SUM(CASE WHEN ReportYear=2018 AND Age<18 THEN AmountPayment2 ELSE 0 END) AS Col4
		----Adult 2018
		,SUM(CASE WHEN ReportYear=2018 AND Age>17 AND Age<65 THEN Quantity ELSE 0 END) AS Col5
		, SUM(CASE WHEN ReportYear=2018 AND Age>17 AND Age<65 THEN AmountPayment2 ELSE 0 END) AS Col6
		---------------Retiree 2018
		,SUM(CASE WHEN ReportYear=2018 AND Age>64 THEN Quantity ELSE 0 END) AS Col7
		,SUM(CASE WHEN ReportYear=2018 AND Age>64 THEN AmountPayment2 ELSE 0 END) AS Col8
		----child 2019
		,SUM(CASE WHEN ReportYear=2019 AND Age<18 THEN Quantity ELSE 0 END) AS Col9
		,SUM(CASE WHEN ReportYear=2019 AND Age<18 THEN AmountPayment2 ELSE 0 END) AS Col10
		----Adult 2019
		,SUM(CASE WHEN ReportYear=2019 AND Age>17 AND Age<65 THEN Quantity ELSE 0 END) AS Col11
		,SUM(CASE WHEN ReportYear=2019  AND Age>17 AND Age<65 THEN AmountPayment2 ELSE 0 END) AS Col12
		---------------Retiree 2019
		,SUM(CASE WHEN ReportYear=2019 AND Age>64 THEN Quantity ELSE 0 END) AS Col13
		,SUM(CASE WHEN ReportYear=2019 AND Age>64 THEN AmountPayment2 ELSE 0 END) AS Col14
FROM #t
WHERE (CASE WHEN AmountPayment2>0 AND AmountPayment>0 THEN 1 WHEN AmountPayment2=0 AND AmountPayment=0 THEN 1 ELSE 0 END)=1 AND Profil=0
UNION ALL
SELECT '4.1'
		----child 2018
		,SUM(CASE WHEN ReportYear=2018 AND Age<18 THEN Quantity ELSE 0 END) AS Col3
		,SUM(CASE WHEN ReportYear=2018 AND Age<18 THEN AmountPayment2 ELSE 0 END) AS Col4
		----Adult 2018
		,SUM(CASE WHEN ReportYear=2018 AND Age>17 AND Age<65 THEN Quantity ELSE 0 END) AS Col5
		, SUM(CASE WHEN ReportYear=2018 AND Age>17 AND Age<65 THEN AmountPayment2 ELSE 0 END) AS Col6
		---------------Retiree 2018
		,SUM(CASE WHEN ReportYear=2018 AND Age>64 THEN Quantity ELSE 0 END) AS Col7
		,SUM(CASE WHEN ReportYear=2018 AND Age>64 THEN AmountPayment2 ELSE 0 END) AS Col8
		----child 2019
		,SUM(CASE WHEN ReportYear=2019 AND Age<18 THEN Quantity ELSE 0 END) AS Col9
		,SUM(CASE WHEN ReportYear=2019 AND Age<18 THEN AmountPayment2 ELSE 0 END) AS Col10
		----Adult 2019
		,SUM(CASE WHEN ReportYear=2019 AND Age>17 AND Age<65 THEN Quantity ELSE 0 END) AS Col11
		,SUM(CASE WHEN ReportYear=2019  AND Age>17 AND Age<65 THEN AmountPayment2 ELSE 0 END) AS Col12
		---------------Retiree 2019
		,SUM(CASE WHEN ReportYear=2019 AND Age>64 THEN Quantity ELSE 0 END) AS Col13
		,SUM(CASE WHEN ReportYear=2019 AND Age>64 THEN AmountPayment2 ELSE 0 END) AS Col14
FROM #t
WHERE (CASE WHEN AmountPayment2>0 AND AmountPayment>0 THEN 1 WHEN AmountPayment2=0 AND AmountPayment=0 THEN 1 ELSE 0 END)=1 AND Profil=1
UNION ALL
SELECT '4.2'
		----child 2018
		,SUM(CASE WHEN ReportYear=2018 AND Age<18 THEN Quantity ELSE 0 END) AS Col3
		,SUM(CASE WHEN ReportYear=2018 AND Age<18 THEN AmountPayment2 ELSE 0 END) AS Col4
		----Adult 2018
		,SUM(CASE WHEN ReportYear=2018 AND Age>17 AND Age<65 THEN Quantity ELSE 0 END) AS Col5
		, SUM(CASE WHEN ReportYear=2018 AND Age>17 AND Age<65 THEN AmountPayment2 ELSE 0 END) AS Col6
		---------------Retiree 2018
		,SUM(CASE WHEN ReportYear=2018 AND Age>64 THEN Quantity ELSE 0 END) AS Col7
		,SUM(CASE WHEN ReportYear=2018 AND Age>64 THEN AmountPayment2 ELSE 0 END) AS Col8
		----child 2019
		,SUM(CASE WHEN ReportYear=2019 AND Age<18 THEN Quantity ELSE 0 END) AS Col9
		,SUM(CASE WHEN ReportYear=2019 AND Age<18 THEN AmountPayment2 ELSE 0 END) AS Col10
		----Adult 2019
		,SUM(CASE WHEN ReportYear=2019 AND Age>17 AND Age<65 THEN Quantity ELSE 0 END) AS Col11
		,SUM(CASE WHEN ReportYear=2019  AND Age>17 AND Age<65 THEN AmountPayment2 ELSE 0 END) AS Col12
		---------------Retiree 2019
		,SUM(CASE WHEN ReportYear=2019 AND Age>64 THEN Quantity ELSE 0 END) AS Col13
		,SUM(CASE WHEN ReportYear=2019 AND Age>64 THEN AmountPayment2 ELSE 0 END) AS Col14
FROM #t
WHERE (CASE WHEN AmountPayment2>0 AND AmountPayment>0 THEN 1 WHEN AmountPayment2=0 AND AmountPayment=0 THEN 1 ELSE 0 END)=1 AND Profil=2

GO
DROP TABLE #t
GO