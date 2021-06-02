USE AccountOMS
GO

DECLARE @dtStart DATETIME='20140101',
		@dtEnd DATETIME='20150127 23:59:59',
		@reportYear SMALLINT=2014
									   
CREATE TABLE #tPeople(rf_idCase BIGINT,
					  CodeM CHAR(6),
					  AmountPayment DECIMAL(11,2), 
					  IsChild tinyint,
					  MES VARCHAR(12),
					  DS VARCHAR(9),
					  V002 SMALLINT	,
					  MUSurgery VARCHAR(16)
					  )
					  
INSERT #tPeople( rf_idCase ,CodeM ,AmountPayment ,IsChild ,MES ,DS ,V002)
SELECT c.id,f.CodeM,c.AmountPayment,CASE WHEN c.Age<18 THEN 1 ELSE 2 END,MES,d.DiagnosisCode,c.rf_idV002
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN (VALUES ('103001'),('103002'),('103003'),('185905'),('381001'),('451001'),('601001'))l(CodeM) ON
			f.CodeM=l.CodeM
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN (VALUES (60),(18),(76)) v(rf_idV002) ON
			c.rf_idV002=v.rf_idV002
					INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase							
					INNER JOIN dbo.t_Diagnosis d ON
			c.id=d.rf_idCase
			AND d.TypeDiagnosis=1
WHERE f.DateRegistration>@dtStart AND f.DateRegistration<@dtEnd AND a.ReportYear=@reportYear AND c.rf_idV006=1 AND c.rf_idV008<>32

INSERT #tPeople( rf_idCase ,CodeM ,AmountPayment ,IsChild ,MES ,DS ,V002)
SELECT c.id,f.CodeM,c.AmountPayment,CASE WHEN c.Age<18 THEN 1 ELSE 2 END,MES,d.DiagnosisCode,c.rf_idV002
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles					
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient					
					INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase							
					INNER JOIN dbo.t_Diagnosis d ON
			c.id=d.rf_idCase
			AND d.TypeDiagnosis=1
WHERE f.DateRegistration>@dtStart AND f.DateRegistration<@dtEnd AND a.ReportYear=@reportYear AND c.rf_idV006=1 AND c.rf_idV008<>32 AND f.CodeM='103001'
	AND  c.rf_idV002=12

UPDATE p SET p.MUSurgery=m.MUSurgery
FROM #tPeople p INNER JOIN(SELECT rf_idCase,MUSurgery FROM dbo.t_Meduslugi m WHERE m.MUSurgery LIKE 'A16.%') m ON
		p.rf_idCase=m.rf_idCase


UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tPeople p INNER JOIN (
							SELECT  sc.rf_idCase, SUM(ISNULL(sc.AmountEKMP, 0) + ISNULL(sc.AmountMEE, 0) + ISNULL(sc.AmountMEK, 0)) AS AmountDeduction
							FROM ExchangeFinancing.dbo.t_AFileIn f INNER JOIN ExchangeFinancing.dbo.t_DocumentOfCheckup p ON 
														f.id = p.rf_idAFile 
																	INNER JOIN ExchangeFinancing.dbo.t_CheckedAccount a ON 
														p.id = a.rf_idDocumentOfCheckup 
																	INNER JOIN ExchangeFinancing.dbo.t_CheckedCase sc ON 
														a.id = sc.rf_idCheckedAccount
							WHERE f.DateRegistration>=@dtStart AND f.DateRegistration<@dtEnd
							GROUP BY sc.rf_idCase
							) r ON						
			p.rf_idCase=r.rf_idCase
			
--SELECT  p.rf_idCase ,
--		l.NAMES AS LPU,
--        p.CodeM ,
--        p.AmountPayment ,
--        p.IsChild ,
--        p.MES ,
--        p.DS ,
--        p.V002 ,
--        p.MUSurgery
--INTO tmp_SvodStacionar        
--FROM #tPeople p INNER JOIN dbo.vw_sprT001 l ON
--		p.CodeM=l.CodeM		

create table #total
( 
	codeM varchar(6),
	child1 int not null default 0,
	adult1 int not null default 0,
	childSum1 decimal(11,2) not null default 0,
	adultSum1 decimal(11,2) not null default 0,
	-----------------------
	child2 int not null default 0,
	adult2 int not null default 0,
	childSum2 decimal(11,2) not null default 0,
	adultSum2 decimal(11,2) not null default 0,
	-----------------------
	child3 int not null default 0,
	adult3 int not null default 0,
	childSum3 decimal(11,2) not null default 0,
	adultSum3 decimal(11,2) not null default 0,
	----------------------
	child4 int not null default 0,
	adult4 int not null default 0,
	childSum4 decimal(11,2) not null default 0,
	adultSum4 decimal(11,2) not null default 0,
	-----------------------
	child5 int not null default 0,
	adult5 int not null default 0,
	childSum5 decimal(11,2) not null default 0,
	adultSum5 decimal(11,2) not null default 0,
	----------------------
	child6 int not null default 0,
	adult6 int not null default 0,
	childSum6 decimal(11,2) not null default 0,
	adultSum6 decimal(11,2) not null default 0,
	----------------------
	child7 int not null default 0,
	adult7 int not null default 0,
	childSum7 decimal(11,2) not null default 0,
	adultSum7 decimal(11,2) not null default 0,
	----------------------
	child8 int not null default 0,
	adult8 int not null default 0,
	childSum8 decimal(11,2) not null default 0,
	adultSum8 decimal(11,2) not null default 0,
	----------------------
	child9 int not null default 0,
	adult9 int not null default 0,
	childSum9 decimal(11,2) not null default 0,
	adultSum9 decimal(11,2) not null default 0,
	----------------------	
	child10 int not null default 0,
	adult10 int not null default 0,
	childSum10 decimal(11,2) not null default 0,
	adultSum10 decimal(11,2) not null default 0,
	-----------------------
	child11 int not null default 0,
	adult11 int not null default 0,
	childSum11 decimal(11,2) not null default 0,
	adultSum11 decimal(11,2) not null default 0,
	-----------------------
	child12 int not null default 0,
	adult12 int not null default 0,
	childSum12 decimal(11,2) not null default 0,
	adultSum12 decimal(11,2) not null default 0,
	-----------------------
	child13 int not null default 0,
	adult13 int not null default 0,
	childSum13 decimal(11,2) not null default 0,
	adultSum13 decimal(11,2) not null default 0,
	-----------------------
	child14 int not null default 0,
	adult14 int not null default 0,
	childSum14 decimal(11,2) not null default 0,
	adultSum14 decimal(11,2) not null default 0,
	-----------------------
	child15 int not null default 0,
	adult15 int not null default 0,
	childSum15 decimal(11,2) not null default 0,
	adultSum15 decimal(11,2) not null default 0,
	-----------------------
	child16 int not null default 0,
	adult16 int not null default 0,
	childSum16 decimal(11,2) not null default 0,
	adultSum16 decimal(11,2) not null default 0,
	-----------------------
	child17 int not null default 0,
	adult17 int not null default 0,
	childSum17 decimal(11,2) not null default 0,
	adultSum17 decimal(11,2) not null default 0,
	-----------------------
	child18 int not null default 0,
	adult18 int not null default 0,
	childSum18 decimal(11,2) not null default 0,
	adultSum18 decimal(11,2) not null default 0 
)
INSERT #total( codeM ,child1 ,adult1 ,childSum1 ,adultSum1 )
SELECT CodeM
		,COUNT(CASE WHEN IsChild=1 then  rf_idCase ELSE null END) AS ChildCount
		,COUNT(CASE WHEN IsChild=2 then  rf_idCase ELSE null END) AS AdultCount
		,SUM(CASE WHEN IsChild=1 then  AmountPayment ELSE 0 END) AS ChildSum		
		,SUM(CASE WHEN IsChild=2 then  AmountPayment ELSE 0 END) AS AdultSum
FROM #tPeople			
WHERE AmountPayment>0
GROUP BY CodeM
-----------------------------------------------------------------------
INSERT #total( codeM ,child2 ,adult2 ,childSum2 ,adultSum2 )
SELECT CodeM
		,COUNT(CASE WHEN IsChild=1 then  rf_idCase ELSE null END) AS ChildCount
		,COUNT(CASE WHEN IsChild=2 then  rf_idCase ELSE null END) AS AdultCount
		,SUM(CASE WHEN IsChild=1 then  AmountPayment ELSE 0 END)
		,SUM(CASE WHEN IsChild=2 then  AmountPayment ELSE 0 END)
FROM #tPeople			
WHERE AmountPayment>0  AND mes IN ('1200077', '1200078','1200079')
GROUP BY CodeM
--UNION ALL
--SELECT CodeM
--		,COUNT(CASE WHEN IsChild=1 then  rf_idCase ELSE null END) AS ChildCount
--		,COUNT(CASE WHEN IsChild=2 then  rf_idCase ELSE null END) AS AdultCount
--		,SUM(CASE WHEN IsChild=1 then  AmountPayment ELSE 0 END)
--		,SUM(CASE WHEN IsChild=2 then  AmountPayment ELSE 0 END)
--FROM #tPeople			
--WHERE AmountPayment>0  AND mes NOT IN ('1200077', '1200078','1200079') AND V002=76
--GROUP BY CodeM
------------------------------------------------------------------------
INSERT #total( codeM ,child3 ,adult3 ,childSum3 ,adultSum3)
SELECT CodeM
		,COUNT(CASE WHEN IsChild=1 then  rf_idCase ELSE null END) AS ChildCount
		,COUNT(CASE WHEN IsChild=2 then  rf_idCase ELSE null END) AS AdultCount
		,SUM(CASE WHEN IsChild=1 then  AmountPayment ELSE 0 END)
		,SUM(CASE WHEN IsChild=2 then  AmountPayment ELSE 0 END)
FROM #tPeople			
WHERE AmountPayment>0  AND mes IN ('1100031','1100074','1100075','1100076')
GROUP BY CodeM
------------------------------------------------------------------------
INSERT #total( codeM ,child4 ,adult4 ,childSum4 ,adultSum4)
SELECT CodeM
		,COUNT(CASE WHEN IsChild=1 then  rf_idCase ELSE null END) AS ChildCount
		,COUNT(CASE WHEN IsChild=2 then  rf_idCase ELSE null END) AS AdultCount
		,SUM(CASE WHEN IsChild=1 then  AmountPayment ELSE 0 END)
		,SUM(CASE WHEN IsChild=2 then  AmountPayment ELSE 0 END)
FROM #tPeople			
WHERE AmountPayment>0  AND mes IN ('1100031','1100074')
GROUP BY CodeM
------------------------------------------------------------------------
INSERT #total( codeM ,child5 ,adult5 ,childSum5 ,adultSum5)
SELECT CodeM
		,COUNT(CASE WHEN IsChild=1 then  rf_idCase ELSE null END) AS ChildCount
		,COUNT(CASE WHEN IsChild=2 then  rf_idCase ELSE null END) AS AdultCount
		,SUM(CASE WHEN IsChild=1 then  AmountPayment ELSE 0 END)
		,SUM(CASE WHEN IsChild=2 then  AmountPayment ELSE 0 END)
FROM #tPeople			
WHERE AmountPayment>0  AND mes ='1100075' AND DS LIKE 'C%'
GROUP BY CodeM
------------------------------------------------------------------------
INSERT #total( codeM ,child6 ,adult6 ,childSum6 ,adultSum6)
SELECT CodeM
		,COUNT(CASE WHEN IsChild=1 then  rf_idCase ELSE null END) AS ChildCount
		,COUNT(CASE WHEN IsChild=2 then  rf_idCase ELSE null END) AS AdultCount
		,SUM(CASE WHEN IsChild=1 then  AmountPayment ELSE 0 END)
		,SUM(CASE WHEN IsChild=2 then  AmountPayment ELSE 0 END)
FROM #tPeople			
WHERE AmountPayment>0  AND mes ='1100076' AND DS LIKE 'C50.%'
GROUP BY CodeM
------------------------------------------------------------------------
INSERT #total( codeM ,child7 ,adult7 ,childSum7 ,adultSum7)
SELECT CodeM
		,COUNT(CASE WHEN IsChild=1 then  rf_idCase ELSE null END) AS ChildCount
		,COUNT(CASE WHEN IsChild=2 then  rf_idCase ELSE null END) AS AdultCount
		,SUM(CASE WHEN IsChild=1 then  AmountPayment ELSE 0 END)
		,SUM(CASE WHEN IsChild=2 then  AmountPayment ELSE 0 END)
FROM #tPeople			
WHERE AmountPayment>0  AND mes ='1100076' AND DS LIKE 'C34.%'
GROUP BY CodeM
------------------------------------------------------------------------
INSERT #total( codeM ,child8 ,adult8 ,childSum8 ,adultSum8)
SELECT CodeM
		,COUNT(CASE WHEN IsChild=1 then  rf_idCase ELSE null END) AS ChildCount
		,COUNT(CASE WHEN IsChild=2 then  rf_idCase ELSE null END) AS AdultCount
		,SUM(CASE WHEN IsChild=1 then  AmountPayment ELSE 0 END)
		,SUM(CASE WHEN IsChild=2 then  AmountPayment ELSE 0 END)
FROM #tPeople			
WHERE AmountPayment>0  AND mes ='1100076' AND DS LIKE 'C18.%'
GROUP BY CodeM
------------------------------------------------------------------------
INSERT #total( codeM ,child9 ,adult9 ,childSum9 ,adultSum9)
SELECT CodeM
		,COUNT(CASE WHEN IsChild=1 then  rf_idCase ELSE null END) AS ChildCount
		,COUNT(CASE WHEN IsChild=2 then  rf_idCase ELSE null END) AS AdultCount
		,SUM(CASE WHEN IsChild=1 then  AmountPayment ELSE 0 END)
		,SUM(CASE WHEN IsChild=2 then  AmountPayment ELSE 0 END)
FROM #tPeople			
WHERE AmountPayment>0  AND mes ='1100076' AND DS LIKE 'C16.%'
GROUP BY CodeM
------------------------------------------------------------------------
INSERT #total( codeM ,child10 ,adult10 ,childSum10 ,adultSum10)
SELECT CodeM
		,COUNT(CASE WHEN IsChild=1 then  rf_idCase ELSE null END) AS ChildCount
		,COUNT(CASE WHEN IsChild=2 then  rf_idCase ELSE null END) AS AdultCount
		,SUM(CASE WHEN IsChild=1 then  AmountPayment ELSE 0 END)
		,SUM(CASE WHEN IsChild=2 then  AmountPayment ELSE 0 END)
FROM #tPeople			
WHERE AmountPayment>0  AND mes ='1100076' AND DS ='C61'
GROUP BY CodeM
------------------------------------------------------------------------
INSERT #total( codeM ,child11 ,adult11 ,childSum11 ,adultSum11)
SELECT CodeM
		,COUNT(CASE WHEN IsChild=1 then  rf_idCase ELSE null END) AS ChildCount
		,COUNT(CASE WHEN IsChild=2 then  rf_idCase ELSE null END) AS AdultCount
		,SUM(CASE WHEN IsChild=1 then  AmountPayment ELSE 0 END)
		,SUM(CASE WHEN IsChild=2 then  AmountPayment ELSE 0 END)
FROM #tPeople			
WHERE AmountPayment>0  AND mes ='1100076' AND (DS NOT LIKE 'C18.%' and DS NOT LIKE 'C50.%' AND DS NOT LIKE 'C16.%' and DS<>'C61' and DS NOT LIKE 'C34.%')
GROUP BY CodeM
------------------------------Surgery------------------------------------------
INSERT #total( codeM ,child12 ,adult12 ,childSum12 ,adultSum12)
SELECT CodeM
		,COUNT(CASE WHEN IsChild=1 then  rf_idCase ELSE null END) AS ChildCount
		,COUNT(CASE WHEN IsChild=2 then  rf_idCase ELSE null END) AS AdultCount
		,SUM(CASE WHEN IsChild=1 then  AmountPayment ELSE 0 END)
		,SUM(CASE WHEN IsChild=2 then  AmountPayment ELSE 0 END)
FROM #tPeople			
WHERE AmountPayment>0  AND MUSurgery IS NOT NULL AND MUSurgery LIKE 'A16.%'	AND Mes NOT IN ('1200077',  '1200078', '1200079', '1100031',  '1100074',  '1100075',  '1100076')
GROUP BY CodeM
------------------------------------------------------------------------
INSERT #total( codeM ,child13 ,adult13 ,childSum13 ,adultSum13)
SELECT CodeM
		,COUNT(CASE WHEN IsChild=1 then  rf_idCase ELSE null END) AS ChildCount
		,COUNT(CASE WHEN IsChild=2 then  rf_idCase ELSE null END) AS AdultCount
		,SUM(CASE WHEN IsChild=1 then  AmountPayment ELSE 0 END)
		,SUM(CASE WHEN IsChild=2 then  AmountPayment ELSE 0 END)
FROM #tPeople			
WHERE AmountPayment>0  AND MUSurgery IS NOT NULL AND MUSurgery LIKE 'A16.%' AND DS LIKE 'C50.%'
		AND Mes NOT IN ('1200077',  '1200078', '1200079', '1100031',  '1100074',  '1100075',  '1100076') 
GROUP BY CodeM
------------------------------------------------------------------------
INSERT #total( codeM ,child14 ,adult14 ,childSum14 ,adultSum14)
SELECT CodeM
		,COUNT(CASE WHEN IsChild=1 then  rf_idCase ELSE null END) AS ChildCount
		,COUNT(CASE WHEN IsChild=2 then  rf_idCase ELSE null END) AS AdultCount
		,SUM(CASE WHEN IsChild=1 then  AmountPayment ELSE 0 END)
		,SUM(CASE WHEN IsChild=2 then  AmountPayment ELSE 0 END)
FROM #tPeople			
WHERE AmountPayment>0  AND MUSurgery IS NOT NULL AND MUSurgery LIKE 'A16.%' AND DS LIKE 'C34.%'
	AND Mes NOT IN ('1200077',  '1200078', '1200079', '1100031',  '1100074',  '1100075',  '1100076')
GROUP BY CodeM
------------------------------------------------------------------------
INSERT #total( codeM ,child15 ,adult15 ,childSum15 ,adultSum15)
SELECT CodeM
		,COUNT(CASE WHEN IsChild=1 then  rf_idCase ELSE null END) AS ChildCount
		,COUNT(CASE WHEN IsChild=2 then  rf_idCase ELSE null END) AS AdultCount
		,SUM(CASE WHEN IsChild=1 then  AmountPayment ELSE 0 END)
		,SUM(CASE WHEN IsChild=2 then  AmountPayment ELSE 0 END)
FROM #tPeople			
WHERE AmountPayment>0  AND MUSurgery IS NOT NULL AND MUSurgery LIKE 'A16.%' AND DS LIKE 'C18.%'
		AND Mes NOT IN ('1200077',  '1200078', '1200079', '1100031',  '1100074',  '1100075',  '1100076')
GROUP BY CodeM
------------------------------------------------------------------------
INSERT #total( codeM ,child16 ,adult16 ,childSum16 ,adultSum16)
SELECT CodeM
		,COUNT(CASE WHEN IsChild=1 then  rf_idCase ELSE null END) AS ChildCount
		,COUNT(CASE WHEN IsChild=2 then  rf_idCase ELSE null END) AS AdultCount
		,SUM(CASE WHEN IsChild=1 then  AmountPayment ELSE 0 END)
		,SUM(CASE WHEN IsChild=2 then  AmountPayment ELSE 0 END)
FROM #tPeople			
WHERE AmountPayment>0  AND MUSurgery IS NOT NULL AND MUSurgery LIKE 'A16.%' AND DS LIKE 'C16.%'
		AND Mes NOT IN ('1200077',  '1200078', '1200079', '1100031',  '1100074',  '1100075',  '1100076')
GROUP BY CodeM
------------------------------------------------------------------------
INSERT #total( codeM ,child17 ,adult17 ,childSum17 ,adultSum17)
SELECT CodeM
		,COUNT(CASE WHEN IsChild=1 then  rf_idCase ELSE null END) AS ChildCount
		,COUNT(CASE WHEN IsChild=2 then  rf_idCase ELSE null END) AS AdultCount
		,SUM(CASE WHEN IsChild=1 then  AmountPayment ELSE 0 END)
		,SUM(CASE WHEN IsChild=2 then  AmountPayment ELSE 0 END)
FROM #tPeople			
WHERE AmountPayment>0  AND MUSurgery IS NOT NULL AND MUSurgery LIKE 'A16.%' AND DS='C61'
		AND Mes NOT IN ('1200077',  '1200078', '1200079', '1100031',  '1100074',  '1100075',  '1100076')
GROUP BY CodeM
------------------------------------------------------------------------
INSERT #total( codeM ,child18 ,adult18 ,childSum18 ,adultSum18)
SELECT CodeM
		,COUNT(CASE WHEN IsChild=1 then  rf_idCase ELSE null END) AS ChildCount
		,COUNT(CASE WHEN IsChild=2 then  rf_idCase ELSE null END) AS AdultCount
		,SUM(CASE WHEN IsChild=1 then  AmountPayment ELSE 0 END)
		,SUM(CASE WHEN IsChild=2 then  AmountPayment ELSE 0 END)
FROM #tPeople			
WHERE AmountPayment>0  AND MUSurgery IS NOT NULL AND MUSurgery LIKE 'A16.%'
		AND (DS NOT LIKE 'C18.%' and DS NOT LIKE 'C50.%' and DS NOT LIKE 'C16.%' and DS<>'C61' and DS NOT LIKE 'C34.%')
		AND Mes NOT IN ('1200077',  '1200078', '1200079', '1100031',  '1100074',  '1100075',  '1100076')
GROUP BY CodeM



SELECT t.codeM+' - '+l.NAMES
		,SUM(child1),SUM(adult1) 
		,SUM(childSum1)/(case when SUM(child1)=0 then 1 else SUM(child1) end) 
		,SUM(adultSum1)/(case when SUM(adult1)=0 then 1 else SUM(adult1) end)
		,SUM(child2),SUM(adult2) 
		,SUM(childSum2)/(case when SUM(child2)=0 then 1 else SUM(child2) end) 
		,SUM(adultSum2)/(case when SUM(adult2)=0 then 1 else SUM(adult2) end)
		,SUM(child3),SUM(adult3) 
		,SUM(childSum3)/(case when SUM(child3)=0 then 1 else SUM(child3) end) 
		,SUM(adultSum3)/(case when SUM(adult3)=0 then 1 else SUM(adult3) end)
		,SUM(child4),SUM(adult4) 
		,SUM(childSum4)/(case when SUM(child4)=0 then 1 else SUM(child4) end) 
		,SUM(adultSum4)/(case when SUM(adult4)=0 then 1 else SUM(adult4) end)
		,SUM(child5),SUM(adult5) 
		,SUM(childSum5)/(case when SUM(child5)=0 then 1 else SUM(child5) end) 
		,SUM(adultSum5)/(case when SUM(adult5)=0 then 1 else SUM(adult5) end)
		,SUM(child6),SUM(adult6) 
		,SUM(childSum6)/(case when SUM(child6)=0 then 1 else SUM(child6) end) 
		,SUM(adultSum6)/(case when SUM(adult6)=0 then 1 else SUM(adult6) end)		
		,SUM(child7),SUM(adult7) 
		,SUM(childSum7)/(case when SUM(child7)=0 then 1 else SUM(child7) end) 
		,SUM(adultSum7)/(case when SUM(adult7)=0 then 1 else SUM(adult7) end)
		,SUM(child8),SUM(adult8) 
		,SUM(childSum8)/(case when SUM(child8)=0 then 1 else SUM(child8) end) 
		,SUM(adultSum8)/(case when SUM(adult8)=0 then 1 else SUM(adult8) end)
		,SUM(child9),SUM(adult9) 
		,SUM(childSum9)/(case when SUM(child9)=0 then 1 else SUM(child9) end) 
		,SUM(adultSum9)/(case when SUM(adult9)=0 then 1 else SUM(adult9) end)
		,SUM(child10),SUM(adult10) 
		,SUM(childSum10)/(case when SUM(child10)=0 then 1 else SUM(child10) end) 
		,SUM(adultSum10)/(case when SUM(adult10)=0 then 1 else SUM(adult10) end)
		,SUM(child11),SUM(adult11) 
		,SUM(childSum11)/(case when SUM(child11)=0 then 1 else SUM(child11) end) 
		,SUM(adultSum11)/(case when SUM(adult11)=0 then 1 else SUM(adult11) end)
		,SUM(child12),SUM(adult12) 
		,SUM(childSum12)/(case when SUM(child12)=0 then 1 else SUM(child12) end) 
		,SUM(adultSum12)/(case when SUM(adult12)=0 then 1 else SUM(adult12) end)
		,SUM(child13),SUM(adult13) 
		,SUM(childSum13)/(case when SUM(child13)=0 then 1 else SUM(child13) end) 
		,SUM(adultSum13)/(case when SUM(adult13)=0 then 1 else SUM(adult13) end)
		,SUM(child14),SUM(adult14) 
		,SUM(childSum14)/(case when SUM(child14)=0 then 1 else SUM(child14) end) 
		,SUM(adultSum14)/(case when SUM(adult14)=0 then 1 else SUM(adult14) end)
		,SUM(child15),SUM(adult15) 
		,SUM(childSum15)/(case when SUM(child15)=0 then 1 else SUM(child15) end) 
		,SUM(adultSum15)/(case when SUM(adult15)=0 then 1 else SUM(adult15) end)
		,SUM(child16),SUM(adult16) 
		,SUM(childSum16)/(case when SUM(child16)=0 then 1 else SUM(child16) end) 
		,SUM(adultSum16)/(case when SUM(adult16)=0 then 1 else SUM(adult16) end)
		,SUM(child17),SUM(adult17) 
		,SUM(childSum17)/(case when SUM(child17)=0 then 1 else SUM(child17) end)
		 ,SUM(adultSum17)/(case when SUM(adult17)=0 then 1 else SUM(adult17) end)
		,SUM(child18),SUM(adult18) 
		,SUM(childSum18)/(case when SUM(child18)=0 then 1 else SUM(child18) end) 
		,SUM(adultSum18)/(case when SUM(adult18)=0 then 1 else SUM(adult18) end)
FROM #total t INNER JOIN dbo.vw_sprT001 l ON
		t.CodeM=l.CodeM
GROUP BY t.codeM+' - '+l.NAMES
ORDER BY t.codeM+' - '+l.NAMES



GO
DROP TABLE #tPeople
DROP TABLE #total