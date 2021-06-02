USE AccountOMS
GO
DECLARE @startDateReg DATETIME,
		@endDateReg DATETIME='20180119',
		@reportYear smallint=2017,
		@reportMont TINYINT=12,
		@caseStart DATE,
		@caseEnd DATE ='20181231'--отчетный период в случаях

--SET @caseEnd='20180630'
--SET @reportMont=6
--SET @endDateReg='20180711'

SELECT @startDateReg=CAST(@reportYear AS CHAR(4))+'0101',@caseStart=CAST(@reportYear AS CHAR(4))+'0101'

CREATE TABLE #tDiag(Diagnosis varchar(8))
CREATE UNIQUE CLUSTERED index IX_Diag ON #tDiag(Diagnosis)

INSERT #tDiag( Diagnosis )
SELECT m.DiagnosisCode
FROM dbo.vw_sprMKB10 m INNER JOIN (values('I00'),('I01'),('I02'),('I05'),('I06'),('I07'),('I08'),('I09'),('I10'),('I11'),('I12'),('I13'),('I15'),('I20'),('I21')
		,('I22'),('I23'),('I24'),('I25'),('I26'),('I27'),('I28'),('I30'),('I31'),('I32'),('I33'),('I34'),('I35'),('I36'),('I37'),
		('I38'),('I39'),('I40'),('I41'),('I42'),('I43'),('I44'),('I45'),('I46'),('I47'),('I48'),('I49'),('I50'),('I51'),('I52'),
		('I60'),('I61'),('I62'),('I63'),('I64'),('I65'),('I66'),('I67'),('I68'),('I69'),('I70'),('I71'),('I72'),('I73'),('I74'),
		('I77'),('I78'),('I79'),('I80'),('I81'),('I82'),('I83'),('I84'),('I85'),('I86'),('I87'),('I88'),('I89'),('I95'),('I97'),('I98'),('I99')) v(DS) on
		m.MainDS=v.ds

SELECT c.id AS rf_idCase, c.AmountPayment, c.AmountPayment AS AmountDeduction, c.rf_idV006, d.DS1, c.rf_idV008
INTO #tPeople
from dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
		f.id=a.rf_idFiles				             
				inner JOIN dbo.t_RecordCasePatient r ON
		a.id=r.rf_idRegistersAccounts
				INNER JOIN dbo.t_PatientSMO p ON
		r.id=p.rf_idRecordCasePatient           		
				INNER JOIN dbo.t_Case c ON
		r.id=c.rf_idRecordCasePatient	
				INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase			              
				INNER JOIN #tDiag m ON
		d.DS1=m.Diagnosis            				 
WHERE f.DateRegistration>@startDateReg AND f.DateRegistration<=@endDateReg AND a.ReportYear=@reportYear AND a.ReportMonth<=@reportMont AND c.DateEnd>=@caseStart AND c.DateEnd<=@caseEnd  

UPDATE p SET p.AmountDeduction=p.AmountPayment-r.AmountDeduction
FROM #tPeople p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@startDateReg AND c.DateRegistration<@endDateReg 
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase


ALTER TABLE #tPeople ADD Col_71_3 TINYINT NULL
ALTER TABLE #tPeople ADD Col_A_1 TINYINT NULL
ALTER TABLE #tPeople ADD Col_A_2 TINYINT NULL
ALTER TABLE #tPeople ADD Col_A_3 TINYINT NULL

UPDATE p SET Col_71_3=1
FROM #tPeople p INNER JOIN dbo.t_Meduslugi m ON
		p.rf_idCase=m.rf_idCase              
WHERE p.rf_idV006=4 AND m.MUGroupCode=71 AND m.MUUnGroupCode=3

UPDATE p SET Col_A_1=1
FROM #tPeople p INNER JOIN dbo.t_Meduslugi m ON
		p.rf_idCase=m.rf_idCase              
WHERE p.rf_idV006=1 AND m.MUSurgery='A25.30.036.001'

UPDATE p SET Col_A_3=1
FROM #tPeople p INNER JOIN dbo.t_Meduslugi m ON
		p.rf_idCase=m.rf_idCase              
WHERE p.rf_idV006=1 AND m.MUSurgery='A25.30.036.003'

UPDATE p SET Col_A_2=1
FROM #tPeople p INNER JOIN dbo.t_Meduslugi m ON
		p.rf_idCase=m.rf_idCase              
WHERE p.rf_idV006=1 AND m.MUSurgery='A25.30.036.002'
--------------------------------------------------------------
SELECT 1,'Скорая медицинская помощь (условие оказания 4)' AS Col1
	,COUNT(rf_idCase) AS Col2,CAST(SUM(AmountPayment) as money) AS Col3
	,count(CASE WHEN Col_71_3=1 THEN rf_idCase ELSE NULL END) AS Col4
	,CAST(sum(CASE WHEN Col_71_3=1 THEN AmountPayment ELSE 0 END) AS MONEY) AS Col5
FROM #tPeople WHERE rf_idV006=4 AND (CASE WHEN AmountPayment>0 AND AmountDeduction>0 THEN 1 WHEN AmountPayment=0 and AmountDeduction=0 THEN 1 ELSE 0 END)=1

UNION ALL
SELECT 2, 'В амбулаторных условиях (условие оказания 3)',COUNT(rf_idCase) AS Col2,CAST(SUM(AmountPayment) AS MONEY) AS Col3	,0 Col4	,0 AS Col5
FROM #tPeople WHERE rf_idV006=3	AND (CASE WHEN AmountPayment>0 AND AmountDeduction>0 THEN 1 WHEN AmountPayment=0 and AmountDeduction=0 THEN 1 ELSE 0 END)=1
UNION ALL
SELECT 3, 'В условиях дневного стационара (2)',COUNT(rf_idCase) AS Col2,CAST(SUM(AmountPayment) AS money) AS Col3,0 Col4,0 AS Col5
FROM #tPeople WHERE rf_idV006=2 AND (CASE WHEN AmountPayment>0 AND AmountDeduction>0 THEN 1 WHEN AmountPayment=0 and AmountDeduction=0 THEN 1 ELSE 0 END)=1
UNION ALL
SELECT 4,'В стационарных условиях (1)' AS Col1
	,COUNT(rf_idCase) AS Col2,CAST(SUM(AmountPayment) AS money) AS Col3
	,count(CASE WHEN Col_A_1=1 THEN rf_idCase ELSE NULL END) AS Col4
	,CAST(sum(CASE WHEN Col_A_1=1 THEN AmountPayment ELSE 0 END) AS MONEY) AS Col5
FROM #tPeople WHERE rf_idV006=1 AND (CASE WHEN AmountPayment>0 AND AmountDeduction>0 THEN 1 WHEN AmountPayment=0 and AmountDeduction=0 THEN 1 ELSE 0 END)=1
UNION ALL
SELECT 4,'В стационарных условиях (1)' AS Col1
	,COUNT(rf_idCase) AS Col2,CAST(SUM(AmountPayment) AS money) AS Col3
	,count(CASE WHEN Col_A_2=1 THEN rf_idCase ELSE NULL END) AS Col4
	,CAST(sum(CASE WHEN Col_A_2=1 THEN AmountPayment ELSE 0 END) AS MONEY) AS Col5
FROM #tPeople WHERE rf_idV006=1 AND (CASE WHEN AmountPayment>0 AND AmountDeduction>0 THEN 1 WHEN AmountPayment=0 and AmountDeduction=0 THEN 1 ELSE 0 END)=1
UNION ALL
SELECT 4,'В стационарных условиях (1)' AS Col1
	,COUNT(rf_idCase) AS Col2,CAST(SUM(AmountPayment) AS money) AS Col3
	,count(CASE WHEN Col_A_3=1 THEN rf_idCase ELSE NULL END) AS Col4
	,CAST(sum(CASE WHEN Col_A_3=1 THEN AmountPayment ELSE 0 END) AS MONEY) AS Col5
FROM #tPeople WHERE rf_idV006=1 AND (CASE WHEN AmountPayment>0 AND AmountDeduction>0 THEN 1 WHEN AmountPayment=0 and AmountDeduction=0 THEN 1 ELSE 0 END)=1
UNION all
SELECT 5,'В том числе ВМП (из стационарных)' AS Col1
	,COUNT(CASE WHEN rf_idV008=32 THEN rf_idCase ELSE null END ) AS Col2
	,CAST(SUM(CASE WHEN rf_idV008=32 THEN AmountPayment ELSE 0.0 END) AS MONEY) AS Col3
	,0 AS Col4
	,0 AS Col5
FROM #tPeople WHERE rf_idV006=1 AND (CASE WHEN AmountPayment>0 AND AmountDeduction>0 THEN 1 WHEN AmountPayment=0 and AmountDeduction=0 THEN 1 ELSE 0 END)=1		 
go 
DROP TABLE #tDiag
DROP TABLE #tPeople
