USE AccountOMS
go
DECLARE @dtStart DATETIME ='20180101',		
		@dtEnd DATETIME='20180611',
		@reportYear smallint=2018,
		@reportMonth tinyint=1,
		@dtStartMM DATE,
		@dtEndMM DATE

SET @dtStartMM=CAST(@reportYear AS CHAR(4))+RTRIM('0'+CAST(@reportMonth AS CHAR(2)))+'01'
SET @dtEndMM=dateadd(day,-1, convert(char(6), dateadd(month,1,@dtStartMM),112)+'01');

CREATE TABLE #tDS(ID VARCHAR(10), DS VARCHAR(8))



INSERT #tDS( ID, DS )
select '1.', v.DS from (values('I00'),('I01'),('I02'),('I05'),('I06'),('I07'),('I08'),('I09'),('I10'),('I11'),('I12'),('I13'),('I15'),('I20'),('I21'),('I22'),('I23'),('I24'),('I25'),('I26'),('I27'),('I28'),('I30'),('I31'),('I32'),('I33'),('I34'),('I35'),('I36'),('I37'),('I38'),('I39'),('I40'),('I41'),('I42'),('I43'),('I44'),('I45'),('I46'),('I47'),('I48'),('I49'),('I50'),('I51'),('I52'),('I60'),('I61'),('I62'),('I63'),('I64'),('I65'),('I66'),('I67'),('I68'),('I69'),('I70'),('I71'),('I72'),('I73'),('I74'),('I77'),('I78'),('I79'),('I80'),('I81'),('I82'),('I83'),('I84'),('I85'),('I86'),('I87'),('I88'),('I89'),('I95'),('I97'),('I98'),('I99')) v(DS)
union all select '1.1', v.DS from (values('I00'),('I01'),('I02')) v(DS)
union all select '1.2', v.DS from (values('I05'),('I06'),('I07'),('I08'),('I09')) v(DS)
union all select '1.3', v.DS from (values('I11')) v(DS)
union all select '1.4', v.DS from (values('I12')) v(DS)
union all select '1.5', v.DS from (values('I13')) v(DS)
union all select '1.6', v.DS from (values('I10')) v(DS)
union all select '1.7', v.DS from (values('I21')) v(DS)
union all select '1.8', v.DS from (values('I22')) v(DS)
union all select '1.9', v.DS from (values('I25')) v(DS)
union all select '1.10', v.DS from (values('I26'),('I27'),('I28')) v(DS)
union all select '1.11', v.DS from (values('I30'),('I31'),('I32'),('I33'),('I34'),('I35'),('I36'),('I37'),('I38'),('I39'),('I40'),('I41'),('I42'),('I43'),('I44'),('I45'),('I46'),('I47'),('I48'),('I49'),('I50'),('I51')) v(DS)
union all select '1.12', v.DS from (values('I30')) v(DS)
union all select '1.13', v.DS from (values('I33')) v(DS)
union all select '1.14', v.DS from (values('I40')) v(DS)
union all select '1.15', v.DS from (values('I42')) v(DS)
union all select '1.16', v.DS from (values('I44'),('I45'),('I46'),('I47'),('I48'),('I49'),('I50'),('I51')) v(DS)
union all select '1.17', v.DS from (values('I60')) v(DS)
union all select '1.18', v.DS from (values('I61'),('I62')) v(DS)
union all select '1.19', v.DS from (values('I63')) v(DS)
union all select '1.20', v.DS from (values('I64')) v(DS)
union all select '1.21', v.DS from (values('I65'),('I66')) v(DS)
union all select '1.22', v.DS from (values('I67'),('I68'),('I69')) v(DS)
union all select '1.23', v.DS from (values('I70')) v(DS)
union all select '1.24', v.DS from (values('I71'),('I72'),('I73'),('I74'),('I77'),('I78'),('I79')) v(DS)
union all select '1.25', v.DS from (values('I80'),('I81'),('I82')) v(DS)
union all select '1.26', v.DS from (values('I83'),('I84'),('I85'),('I86'),('I87'),('I88'),('I89')) v(DS)
union all select '1.27', v.DS from (values('I95'),('I97'),('I98'),('I99')) v(DS)
union all select '2.', v.DS from (values('C00'),('C01'),('C02'),('C03'),('C04'),('C05'),('C06'),('C07'),('C08'),('C09'),('C10'),('C11'),('C12'),('C13'),('C14'),('C15'),('C16'),('C17'),('C18'),('C19'),('C20'),('C21'),('C22'),('C23'),('C24'),('C25'),('C26'),('C30'),('C31'),('C32'),('C33'),('C34'),('C37'),('C38'),('C39'),('C40'),('C41'),('C43'),('C44'),('C45'),('C46'),('C47'),('C48'),('C49'),('C50'),('C51'),('C52'),('C53'),('C54'),('C55'),('C56'),('C57'),('C58'),('C60'),('C61'),('C62'),('C63'),('C64'),('C65'),('C66'),('C67'),('C68'),('C69'),('C70'),('C71'),('C72'),('C73'),('C74'),('C75'),('C76'),('C77'),('C78'),('C79'),('C80'),('C81'),('C82'),('C83'),('C84'),('C85'),('C86'),('C88'),('C90'),('C91'),('C92'),('C93'),('C94'),('C95'),('C96'),('C97'),('D00'),('D01'),('D02'),('D03'),('D04'),('D05'),('D06'),('D07'),('D09'),('D10'),('D11'),('D12'),('D13'),('D14'),('D15'),('D16'),('D17'),('D18'),('D19'),('D20'),('D21'),('D22'),('D23'),('D24'),('D25'),('D26'),('D27'),('D28'),('D29'),('D30'),('D31'),('D32'),('D33'),('D34'),('D35'),('D36'),('D37'),('D38'),('D39'),('D40'),('D41'),('D42'),('D43'),('D44'),('D45'),('D46'),('D47'),('D48')) v(DS)
union all select '2.1', v.DS from (values('C00'),('C01'),('C02'),('C03'),('C04'),('C05'),('C06'),('C07'),('C08'),('C09'),('C10'),('C11'),('C12'),('C13'),('C14')) v(DS)
union all select '2.2', v.DS from (values('C15')) v(DS)
union all select '2.3', v.DS from (values('C16')) v(DS)
union all select '2.4', v.DS from (values('C17')) v(DS)
union all select '2.5', v.DS from (values('C18')) v(DS)
union all select '2.6', v.DS from (values('C19'),('C20'),('C21')) v(DS)
union all select '2.7', v.DS from (values('C22')) v(DS)
union all select '2.8', v.DS from (values('C25')) v(DS)
union all select '2.9', v.DS from (values('C23'),( 'C24'),( 'C26')) v(DS)
union all select '2.10', v.DS from (values('C32')) v(DS)
union all select '2.11', v.DS from (values('C33'),('C34')) v(DS)
union all select '2.12', v.DS from (values('C30'),('C31'),('C37'),('C38'),('C39')) v(DS)
union all select '2.13', v.DS from (values('C40'),('C41')) v(DS)
union all select '2.14', v.DS from (values( 'C43')) v(DS)
union all select '2.15', v.DS from (values( 'C44')) v(DS)
union all select '2.16', v.DS from (values('C45'),('C46'),('C47'),('C48'),('C49')) v(DS)
union all select '2.17', v.DS from (values( 'C50')) v(DS)
union all select '2.18', v.DS from (values( 'C53')) v(DS)
union all select '2.19', v.DS from (values('C54'),('C55')) v(DS)
union all select '2.20', v.DS from (values( 'C56')) v(DS)
union all select '2.21', v.DS from (values('C51'),('C52'),('C57'),('C58')) v(DS)
union all select '2.22', v.DS from (values( 'C61')) v(DS)
union all select '2.23', v.DS from (values('C60'),('C62'),('C63')) v(DS)
union all select '2.24', v.DS from (values( 'C64')) v(DS)
union all select '2.25', v.DS from (values( 'C67')) v(DS)
union all select '2.26', v.DS from (values('C65'),('C66'),('C68')) v(DS)
union all select '2.27', v.DS from (values ('C70'),('C71'),('C72')) v(DS)
union all select '2.28', v.DS from (values ('C69'),('C73'),('C74'),('C75'),('C76'),('C77'),('C78'),('C79'),('C80'),('C97')) v(DS)
union all select '2.29', v.DS from (values( 'C81')) v(DS)
union all select '2.30', v.DS from (values('C82'),('C83'),('C84'),('C85')) v(DS)
union all select '2.31', v.DS from (values ('C90')) v(DS)
union all select '2.32', v.DS from (values ('C91'),('C92'),('C93'),('C94'),('C95')) v(DS)
union all select '2.33', v.DS from (values ('C88'),('C96')) v(DS)
union all select '2.34', v.DS from (values('D00'),('D01'),('D02'),('D03'),('D04'),('D05'),('D06'),('D07'),('D09'),('D10'),('D11'),('D12'),('D13'),('D14'),('D15'),('D16'),('D17'),('D18'),('D19'),('D20'),('D21'),('D22'),('D23'),('D24'),('D25'),('D26'),('D27'),('D28'),('D29'),('D30'),('D31'),('D32'),('D33'),('D34'),('D35'),('D36'),('D37'),('D38'),('D39'),('D40'),('D41'),('D42'),('D43'),('D44'),('D45'),('D46'),('D47'),('D48')) v(DS)
union all select '3.', v.DS from (values('G00'),('G01'),('G02'),('G03'),('G04'),('G05'),('G06'),('G07'),('G08'),('G09'),('G10'),('G11'),('G12'),('G13'),('G14'),('G20'),('G21'),('G22'),('G23'),('G24'),('G25'),('G26'),('G30'),('G31'),('G32'),('G35'),('G36'),('G37'),('G40'),('G41'),('G43'),('G44'),('G45'),('G46'),('G47'),('G50'),('G51'),('G52'),('G53'),('G54'),('G55'),('G56'),('G57'),('G58'),('G59'),('G60'),('G61'),('G62'),('G63'),('G64'),('G70'),('G71'),('G72'),('G73'),('G80'),('G81'),('G82'),('G83'),('G90'),('G91'),('G92'),('G93'),('G94'),('G95'),('G96'),('G97'),('G98')) v(DS)
union all select '3.1', v.DS from (values('G00'),('G03')) v(DS)
union all select '3.2', v.DS from (values('G04'),('G06'),( 'G08'),( 'G09')) v(DS)
union all select '3.3', v.DS from (values('G20'),('G21')) v(DS)
union all select '3.4', v.DS from (values( 'G30')) v(DS)
union all select '3.5', v.DS from (values( 'G35')) v(DS)
union all select '3.6', v.DS from (values('G40'),( 'G41')) v(DS)
union all select '3.7', v.DS from (values( 'G80')) v(DS)
union all select '3.8', v.DS from (values('G31'),( 'G36'),( 'G37'),( 'G47'),( 'G10'),('G11'),('G12'),('G23'),('G24'),('G25'),('G43'),('G44'),('G45'),('G50'),('G51'),('G52'),('G53'),('G54'),('G55'),('G56'),('G57'),('G58'),('G59'),('G60'),('G61'),('G62'),('G63'),('G64'),('G70'),('G71'),('G72'),('G81'),('G82'),('G83'),('G90'),('G91'),('G92'),('G93'),('G94'),('G95'),('G96'),('G97'),('G98')) v(DS)
union all select '4.', v.DS from (values('J00'),('J01'),('J02'),('J03'),('J04'),('J05'),('J06'),('J09'),('J10'),('J11'),('J12'),('J13'),('J14'),('J15'),('J16'),('J17'),('J18'),('J20'),('J21'),('J22'),('J30'),('J31'),('J32'),('J33'),('J34'),('J35'),('J36'),('J37'),('J38'),('J39'),('J40'),('J41'),('J42'),('J43'),('J44'),('J45'),('J46'),('J47'),('J60'),('J61'),('J62'),('J63'),('J64'),('J65'),('J66'),('J67'),('J68'),('J69'),('J70'),('J80'),('J81'),('J82'),('J84'),('J85'),('J86'),('J90'),('J91'),('J92'),('J93'),('J94'),('J95'),('J96'),('J98'),('J99')) v(DS)
union all select '4.1', v.DS from (values('J00'),('J01'),('J02'),('J03'),('J04'),('J05'),('J06')) v(DS)
union all select '4.2', v.DS from (values( 'J04')) v(DS)
union all select '4.3', v.DS from (values( 'J05')) v(DS)
union all select '4.4', v.DS from (values('J09'),('J10'),('J11')) v(DS)
union all select '4.5', v.DS from (values( 'J12')) v(DS)
union all select '4.6', v.DS from (values('J13'),('J14'),('J15')) v(DS)
union all select '4.7', v.DS from (values( 'J16')) v(DS)
union all select '4.8', v.DS from (values( 'J18')) v(DS)
union all select '4.9', v.DS from (values('J20'),('J21'),('J22')) v(DS)
union all select '4.10', v.DS from (values( 'J40')) v(DS)
union all select '4.11', v.DS from (values( 'J43')) v(DS)
union all select '4.12', v.DS from (values('J41'),('J42'),('J44')) v(DS)
union all select '4.13', v.DS from (values('J45'),('J46')) v(DS)
union all select '4.14', v.DS from (values( 'J47')) v(DS)
union all select '4.15', v.DS from (values('J60'),('J61'),('J62'),('J63'),('J64'),('J65'),('J66'),('J67'),('J68'),('J69'),('J70')) v(DS)
union all select '4.16', v.DS from (values('J80'),('J81'),('J82'),('J84')) v(DS)
union all select '4.17', v.DS from (values('J85'),('J86')) v(DS)
union all select '4.18', v.DS from (values('J85')) v(DS)
union all select '4.19', v.DS from (values('J30'),('J31'),('J32'),('J33'),('J34'),('J35'),('J36'),('J37'),('J38'),('J39'),('J90'),('J91'),('J92'),('J93'),('J94'),('J95'),('J96'),('J98'),('J99')) v(DS)
union all select '5.', v.DS from (values('K00'),('K01'),('K02'),('K03'),('K04'),('K05'),('K06'),('K07'),('K08'),('K09'),('K10'),('K11'),('K12'),('K13'),('K14'),('K20'),('K21'),('K22'),('K23'),('K25'),('K26'),('K27'),('K28'),('K29'),('K30'),('K31'),('K35'),('K36'),('K37'),('K38'),('K40'),('K41'),('K42'),('K43'),('K44'),('K45'),('K46'),('K50'),('K51'),('K52'),('K55'),('K56'),('K57'),('K58'),('K59'),('K60'),('K61'),('K62'),('K63'),('K64'),('K65'),('K66'),('K67'),('K70'),('K71'),('K72'),('K73'),('K74'),('K75'),('K76'),('K77'),('K80'),('K81'),('K82'),('K83'),('K85'),('K86'),('K87'),('K90'),('K91'),('K92'),('K93')) v(DS)
union all select '5.1', v.DS from (values('K25')) v(DS)
union all select '5.2', v.DS from (values('K26')) v(DS)
union all select '5.3', v.DS from (values('K27')) v(DS)
union all select '5.4', v.DS from (values('K29')) v(DS)
union all select '5.5', v.DS from (values('K35'),('K36'),('K37'),('K38')) v(DS)
union all select '5.6', v.DS from (values('K40'),('K41'),('K42'),('K43'),('K44'),('K45'),('K46')) v(DS)
union all select '5.7', v.DS from (values('K50'),('K51'),('K52')) v(DS)
union all select '5.8', v.DS from (values('K56')) v(DS)
union all select '5.9', v.DS from (values('K70')) v(DS)
union all select '5.10', v.DS from (values('K74')) v(DS)
union all select '5.11', v.DS from (values('K71'),('K72'),('K73'),('K75'),('K76')) v(DS)
union all select '5.12', v.DS from (values('K80')) v(DS)
union all select '5.13', v.DS from (values('K81')) v(DS)
union all select '5.14', v.DS from (values('K85'),('K86')) v(DS)
union all select '5.15', v.DS from (values('K28'),( 'K55'),( 'K82'),( 'K83'),('K00'),('K01'),('K02'),('K03'),('K04'),('K05'),('K06'),('K07'),('K08'),('K09'),('K10'),('K11'),('K12'),('K13'),('K14'),('K20'),('K21'),('K22'),('K23'),('K30'),('K31'),('K90'),('K91'),('K92'),('K93'),('K57'),('K58'),('K59'),('K60'),('K61'),('K62'),('K63'),('K64'),('K65'),('K66')) v(DS)




SELECT c.id AS rf_idCase,c.AmountPayment, dd.id, 3 AS TypeCol,c.AmountPayment AS AmountDeduction, c.Age
INTO #tmpPeople
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles				
				INNER JOIN dbo.t_RecordCasePatient r ON
		a.id=r.rf_idRegistersAccounts								
				INNER JOIN dbo.t_Case c  ON
		r.id=c.rf_idRecordCasePatient	
				INNER JOIN dbo.t_MES m ON                
		c.id=m.rf_idCase              
				INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase
				INNER JOIN vw_sprMKB10 mkb ON
		d.DS1=mkb.DiagnosisCode
				INNER JOIN #tDS dd ON
		mkb.MainDS=dd.DS              
WHERE f.DateRegistration>=@dtStart AND f.DateRegistration<@dtEnd AND a.ReportYear=@reportYear AND a.ReportMonth=@reportMonth AND m.MES LIKE '2.78.%' AND c.Age>17 AND a.rf_idSMO<>'34'
		AND c.DateEnd>=@dtStartMM AND c.DateEnd<=@dtEndMM


INSERT #tmpPeople (rf_idCase,AmountPayment,id,TypeCol, AmountDeduction, age) 
SELECT c.id AS rf_idCase,c.AmountPayment, dd.id, 4 AS TypeCol,c.AmountPayment AS AmountDeduction,c.Age
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles				
				INNER JOIN dbo.t_RecordCasePatient r ON
		a.id=r.rf_idRegistersAccounts								
				INNER JOIN dbo.t_Case c  ON
		r.id=c.rf_idRecordCasePatient	
				INNER JOIN dbo.t_Meduslugi m ON                
		c.id=m.rf_idCase              
				INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase
				INNER JOIN vw_sprMKB10 mkb ON
		d.DS1=mkb.DiagnosisCode
				INNER JOIN #tDS dd ON
		mkb.MainDS=dd.DS              
WHERE f.DateRegistration>=@dtStart AND f.DateRegistration<@dtEnd AND a.ReportYear=@reportYear AND a.ReportMonth=@reportMonth AND m.MUGroupCode=2 AND m.MUUnGroupCode=88 AND c.Age>17  AND a.rf_idSMO<>'34'
AND c.DateEnd>=@dtStartMM AND c.DateEnd<=@dtEndMM

INSERT #tmpPeople (rf_idCase,AmountPayment,id,TypeCol, AmountDeduction, Age) 
SELECT c.id AS rf_idCase,c.AmountPayment, dd.id, 5 AS TypeCol,c.AmountPayment AS AmountDeduction, c.Age
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles				
				INNER JOIN dbo.t_RecordCasePatient r ON
		a.id=r.rf_idRegistersAccounts								         
				INNER JOIN dbo.t_Case c  ON
		r.id=c.rf_idRecordCasePatient			
				INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase
				INNER JOIN vw_sprMKB10 mkb ON
		d.DS1=mkb.DiagnosisCode
				INNER JOIN #tDS dd ON
		mkb.MainDS=dd.DS              
WHERE f.DateRegistration>=@dtStart AND f.DateRegistration<@dtEnd AND a.ReportYear=@reportYear AND a.ReportMonth=@reportMonth AND c.rf_idV006=1 AND c.rf_idV014=3 AND c.Age>17 AND a.rf_idSMO<>'34'
AND c.DateEnd>=@dtStartMM AND c.DateEnd<=@dtEndMM

INSERT #tmpPeople (rf_idCase,AmountPayment,id,TypeCol, AmountDeduction, Age) 
SELECT c.id AS rf_idCase,c.AmountPayment, dd.id, 6 AS TypeCol,c.AmountPayment AS AmountDeduction, c.Age
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles				
				INNER JOIN dbo.t_RecordCasePatient r ON
		a.id=r.rf_idRegistersAccounts								         
				INNER JOIN dbo.t_Case c  ON
		r.id=c.rf_idRecordCasePatient			
				INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase
				INNER JOIN vw_sprMKB10 mkb ON
		d.DS1=mkb.DiagnosisCode
				INNER JOIN #tDS dd ON
		mkb.MainDS=dd.DS              
WHERE f.DateRegistration>=@dtStart AND f.DateRegistration<@dtEnd AND a.ReportYear=@reportYear AND a.ReportMonth=@reportMonth AND c.rf_idV006=1 AND c.rf_idV014<3  AND c.Age>17	AND a.rf_idSMO<>'34'
AND c.DateEnd>=@dtStartMM AND c.DateEnd<=@dtEndMM

INSERT #tmpPeople (rf_idCase,AmountPayment,id,TypeCol, AmountDeduction, age) 
SELECT c.id AS rf_idCase,c.AmountPayment, dd.id, 7 AS TypeCol,c.AmountPayment AS AmountDeduction, c.Age
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles				
				INNER JOIN dbo.t_RecordCasePatient r ON
		a.id=r.rf_idRegistersAccounts								         
				INNER JOIN dbo.t_Case c  ON
		r.id=c.rf_idRecordCasePatient			
				INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase
				INNER JOIN vw_sprMKB10 mkb ON
		d.DS1=mkb.DiagnosisCode
				INNER JOIN #tDS dd ON
		mkb.MainDS=dd.DS              
WHERE f.DateRegistration>=@dtStart AND f.DateRegistration<@dtEnd AND a.ReportYear=@reportYear AND a.ReportMonth=@reportMonth AND c.rf_idV006=2 AND c.Age>17 AND a.rf_idSMO<>'34'
AND c.DateEnd>=@dtStartMM AND c.DateEnd<=@dtEndMM

INSERT #tmpPeople (rf_idCase,AmountPayment,id,TypeCol, AmountDeduction, Age) 
SELECT c.id AS rf_idCase,c.AmountPayment, dd.id, 8 AS TypeCol,c.AmountPayment AS AmountDeduction,c.Age
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles				
				INNER JOIN dbo.t_RecordCasePatient r ON
		a.id=r.rf_idRegistersAccounts								         
				INNER JOIN dbo.t_Case c  ON
		r.id=c.rf_idRecordCasePatient			
				INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase
				INNER JOIN vw_sprMKB10 mkb ON
		d.DS1=mkb.DiagnosisCode
				INNER JOIN #tDS dd ON
		mkb.MainDS=dd.DS              
WHERE f.DateRegistration>=@dtStart AND f.DateRegistration<@dtEnd AND a.ReportYear=@reportYear AND a.ReportMonth=@reportMonth AND c.rf_idV006=4 AND c.Age>17	AND a.rf_idSMO<>'34'
AND c.DateEnd>=@dtStartMM AND c.DateEnd<=@dtEndMM

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tmpPeople p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dtStart AND c.DateRegistration<@dtEnd
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

SELECT p.id
	, count(CASE WHEN TypeCol=3 THEN p.rf_idCase ELSE NULL END ) AS Col3
	, count(CASE WHEN TypeCol=4 THEN p.rf_idCase ELSE NULL END ) AS Col4
	, count(CASE WHEN TypeCol=5 THEN p.rf_idCase ELSE NULL END ) AS Col5
	, count(CASE WHEN TypeCol=6 THEN p.rf_idCase ELSE NULL END ) AS Col6
	, count(CASE WHEN TypeCol=7 THEN p.rf_idCase ELSE NULL END ) AS Col7
	, count(CASE WHEN TypeCol=8 THEN p.rf_idCase ELSE NULL END ) AS Col8
FROM #tmpPeople p
WHERE (CASE WHEN AmountPayment>0 AND AmountDeduction>0 THEN 1 WHEN AmountPayment=0 and AmountDeduction=0 THEN 1 ELSE 0 END)=1 AND p.Age<61
GROUP BY p.id
ORDER BY id


SELECT p.id
	, count(CASE WHEN TypeCol=3 THEN p.rf_idCase ELSE NULL END ) AS Col3
	, count(CASE WHEN TypeCol=4 THEN p.rf_idCase ELSE NULL END ) AS Col4
	, count(CASE WHEN TypeCol=5 THEN p.rf_idCase ELSE NULL END ) AS Col5
	, count(CASE WHEN TypeCol=6 THEN p.rf_idCase ELSE NULL END ) AS Col6
	, count(CASE WHEN TypeCol=7 THEN p.rf_idCase ELSE NULL END ) AS Col7
	, count(CASE WHEN TypeCol=8 THEN p.rf_idCase ELSE NULL END ) AS Col8
FROM #tmpPeople p
WHERE (CASE WHEN AmountPayment>0 AND AmountDeduction>0 THEN 1 WHEN AmountPayment=0 and AmountDeduction=0 THEN 1 ELSE 0 END)=1 AND p.Age>60
GROUP BY p.id
ORDER BY id

GO
DROP TABLE #tDS
DROP TABLE #tmpPeople