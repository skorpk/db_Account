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
					  V002 SMALLINT						 
					  )
					  
INSERT #tPeople( rf_idCase ,CodeM ,AmountPayment ,IsChild ,MES ,DS ,V002)
SELECT c.id,f.CodeM,c.AmountPayment,CASE WHEN c.Age<18 THEN 1 ELSE 2 END,MES,d.DiagnosisCode,c.rf_idV002
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN (VALUES ('103001'),('103002'),('103003'),('451001'),('601001'))l(CodeM) ON
			f.CodeM=l.CodeM
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN (VALUES (60),(18)) v(rf_idV002) ON
			c.rf_idV002=v.rf_idV002
					INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase							
					INNER JOIN dbo.t_Diagnosis d ON
			c.id=d.rf_idCase
			AND d.TypeDiagnosis=1
WHERE f.DateRegistration>@dtStart AND f.DateRegistration<@dtEnd AND a.ReportYear=@reportYear AND c.rf_idV006=2

INSERT #tPeople( rf_idCase ,CodeM ,AmountPayment ,IsChild ,MES ,DS ,V002)
SELECT c.id,f.CodeM,c.AmountPayment,CASE WHEN c.Age<18 THEN 1 ELSE 2 END,MES,d.DiagnosisCode,c.rf_idV002
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles	
					INNER JOIN (VALUES ('103001'),('103002'),('103003'))l(CodeM) ON
			f.CodeM=l.CodeM				
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient					
					INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase							
					INNER JOIN dbo.t_Diagnosis d ON
			c.id=d.rf_idCase
			AND d.TypeDiagnosis=1
WHERE f.DateRegistration>@dtStart AND f.DateRegistration<@dtEnd AND a.ReportYear=@reportYear AND c.rf_idV006=2 AND  c.rf_idV002=12

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
	adultSum10 decimal(11,2) not null default 0
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
-----------------------Удалить------------------------------------------------
INSERT #total( codeM ,child2 ,adult2 ,childSum2 ,adultSum2 )
SELECT CodeM
		,COUNT(CASE WHEN IsChild=1 then  rf_idCase ELSE null END) AS ChildCount
		,COUNT(CASE WHEN IsChild=2 then  rf_idCase ELSE null END) AS AdultCount
		,SUM(CASE WHEN IsChild=1 then  AmountPayment ELSE 0 END)
		,SUM(CASE WHEN IsChild=2 then  AmountPayment ELSE 0 END)
FROM #tPeople			
WHERE AmountPayment>0  
GROUP BY CodeM
------------------------------------------------------------------------
INSERT #total( codeM ,child3 ,adult3 ,childSum3 ,adultSum3)
SELECT CodeM
		,COUNT(CASE WHEN IsChild=1 then  rf_idCase ELSE null END) AS ChildCount
		,COUNT(CASE WHEN IsChild=2 then  rf_idCase ELSE null END) AS AdultCount
		,SUM(CASE WHEN IsChild=1 then  AmountPayment ELSE 0 END)
		,SUM(CASE WHEN IsChild=2 then  AmountPayment ELSE 0 END)
FROM #tPeople			
WHERE AmountPayment>0  AND DS IN ('С91.0', 'С92.0', 'С92.4', 'С92.5', 'C92.6', 'C92.8', 'С93.0', 'C93.3', 'С94.0', 'С94.2', 'C95.0')
GROUP BY CodeM
------------------------------------------------------------------------
INSERT #total( codeM ,child4 ,adult4 ,childSum4 ,adultSum4)
SELECT CodeM
		,COUNT(CASE WHEN IsChild=1 then  rf_idCase ELSE null END) AS ChildCount
		,COUNT(CASE WHEN IsChild=2 then  rf_idCase ELSE null END) AS AdultCount
		,SUM(CASE WHEN IsChild=1 then  AmountPayment ELSE 0 END)
		,SUM(CASE WHEN IsChild=2 then  AmountPayment ELSE 0 END)
FROM #tPeople			
WHERE AmountPayment>0  AND DS IN ('C77.0', 'C77.1', 'C77.2', 'C77.3', 'C77.4', 'C77.5', 'C77.8', 'C77.9', 'C81.0', 'C81.1', 'C81.2', 'C81.3', 'C81.4', 'C81.7', 'C81.9', 'C82.0', 'C82.1', 'C82.2', 'C82.3', 'C82.4', 'C82.5', 'C82.6', 'C82.7', 'C82.9', 'C83.0', 'C83.1', 'C83.3', 'C83.5', 'C83.7', 'C83.8', 'C83.9', 'C84.0', 'C84.1', 'C84.4', 'C84.5', 'C84.6', 'C84.7', 'C84.8', 'C84.9', 'C85.1', 'C85.2', 'C85.7', 'C85.9', 'C86.0', 'C86.1', 'C86.2', 'C86.3', 'C86.4', 'C86.5', 'C86.6', 'C88.0', 'C88.1', 'C88.2', 'C88.3', 'C88.4', 'C88.7', 'C88.9', 'C90.0', 'C90.1', 'C90.2', 'C90.3', 'C91.1', 'C91.3', 'C91.4', 'C91.5', 'C91.6', 'C91.7', 'C91.8', 'C91.9', 'C92.1', 'C92.2', 'C92.3', 'C92.7', 'C92.9', 'C93.1', 'C93.7', 'C93.9', 'C94.3', 'C94.4', 'C94.6', 'C94.7', 'C95.1', 'C95.7', 'C95.9', 'C96.0', 'C96.2', 'C96.4', 'C96.5', 'C96.6', 'C96.7', 'C96.8', 'C96.9')
GROUP BY CodeM
------------------------------------------------------------------------
INSERT #total( codeM ,child5 ,adult5 ,childSum5 ,adultSum5)
SELECT CodeM
		,COUNT(CASE WHEN IsChild=1 then  rf_idCase ELSE null END) AS ChildCount
		,COUNT(CASE WHEN IsChild=2 then  rf_idCase ELSE null END) AS AdultCount
		,SUM(CASE WHEN IsChild=1 then  AmountPayment ELSE 0 END)
		,SUM(CASE WHEN IsChild=2 then  AmountPayment ELSE 0 END)
FROM #tPeople			
WHERE AmountPayment>0  AND DS LIKE 'C50.%'
GROUP BY CodeM
------------------------------------------------------------------------
INSERT #total( codeM ,child6 ,adult6 ,childSum6 ,adultSum6)
SELECT CodeM
		,COUNT(CASE WHEN IsChild=1 then  rf_idCase ELSE null END) AS ChildCount
		,COUNT(CASE WHEN IsChild=2 then  rf_idCase ELSE null END) AS AdultCount
		,SUM(CASE WHEN IsChild=1 then  AmountPayment ELSE 0 END)
		,SUM(CASE WHEN IsChild=2 then  AmountPayment ELSE 0 END)
FROM #tPeople			
WHERE AmountPayment>0  AND DS LIKE 'C34.%'
GROUP BY CodeM
------------------------------------------------------------------------
INSERT #total( codeM ,child7 ,adult7 ,childSum7 ,adultSum7)
SELECT CodeM
		,COUNT(CASE WHEN IsChild=1 then  rf_idCase ELSE null END) AS ChildCount
		,COUNT(CASE WHEN IsChild=2 then  rf_idCase ELSE null END) AS AdultCount
		,SUM(CASE WHEN IsChild=1 then  AmountPayment ELSE 0 END)
		,SUM(CASE WHEN IsChild=2 then  AmountPayment ELSE 0 END)
FROM #tPeople			
WHERE AmountPayment>0  AND DS LIKE 'C18.%'
GROUP BY CodeM
------------------------------------------------------------------------
INSERT #total( codeM ,child8 ,adult8 ,childSum8 ,adultSum8)
SELECT CodeM
		,COUNT(CASE WHEN IsChild=1 then  rf_idCase ELSE null END) AS ChildCount
		,COUNT(CASE WHEN IsChild=2 then  rf_idCase ELSE null END) AS AdultCount
		,SUM(CASE WHEN IsChild=1 then  AmountPayment ELSE 0 END)
		,SUM(CASE WHEN IsChild=2 then  AmountPayment ELSE 0 END)
FROM #tPeople			
WHERE AmountPayment>0  AND DS LIKE 'C16.%'
GROUP BY CodeM
------------------------------------------------------------------------
INSERT #total( codeM ,child9 ,adult9 ,childSum9 ,adultSum9)
SELECT CodeM
		,COUNT(CASE WHEN IsChild=1 then  rf_idCase ELSE null END) AS ChildCount
		,COUNT(CASE WHEN IsChild=2 then  rf_idCase ELSE null END) AS AdultCount
		,SUM(CASE WHEN IsChild=1 then  AmountPayment ELSE 0 END)
		,SUM(CASE WHEN IsChild=2 then  AmountPayment ELSE 0 END)
FROM #tPeople			
WHERE AmountPayment>0  AND DS ='C61'
GROUP BY CodeM
------------------------------------------------------------------------
INSERT #total( codeM ,child10 ,adult10 ,childSum10 ,adultSum10)
SELECT CodeM
		,COUNT(CASE WHEN IsChild=1 then  rf_idCase ELSE null END) AS ChildCount
		,COUNT(CASE WHEN IsChild=2 then  rf_idCase ELSE null END) AS AdultCount
		,SUM(CASE WHEN IsChild=1 then  AmountPayment ELSE 0 END)
		,SUM(CASE WHEN IsChild=2 then  AmountPayment ELSE 0 END)
FROM #tPeople			
WHERE AmountPayment>0  AND (DS NOT LIKE 'C18.%' and DS NOT LIKE 'C50.%' and DS NOT LIKE 'C16.%' and DS<>'C61' and DS NOT LIKE 'C34.%' AND
				DS IN ('C77.0', 'C77.1', 'C77.2', 'C77.3', 'C77.4', 'C77.5', 'C77.8', 'C77.9', 'C81.0', 'C81.1', 'C81.2', 'C81.3', 'C81.4', 'C81.7', 'C81.9', 'C82.0', 'C82.1', 'C82.2', 'C82.3', 'C82.4', 'C82.5', 'C82.6', 'C82.7', 'C82.9', 'C83.0', 'C83.1', 'C83.3', 'C83.5', 'C83.7', 'C83.8', 'C83.9', 'C84.0', 'C84.1', 'C84.4', 'C84.5', 'C84.6', 'C84.7', 'C84.8', 'C84.9', 'C85.1', 'C85.2', 'C85.7', 'C85.9', 'C86.0', 'C86.1', 'C86.2', 'C86.3', 'C86.4', 'C86.5', 'C86.6', 'C88.0', 'C88.1', 'C88.2', 'C88.3', 'C88.4', 'C88.7', 'C88.9', 'C90.0', 'C90.1', 'C90.2', 'C90.3', 'C91.1', 'C91.3', 'C91.4', 'C91.5', 'C91.6', 'C91.7', 'C91.8', 'C91.9', 'C92.1', 'C92.2', 'C92.3', 'C92.7', 'C92.9', 'C93.1', 'C93.7', 'C93.9', 'C94.3', 'C94.4', 'C94.6', 'C94.7', 'C95.1', 'C95.7', 'C95.9', 'C96.0', 'C96.2', 'C96.4', 'C96.5', 'C96.6', 'C96.7', 'C96.8', 'C96.9')
				and DS IN ('С91.0', 'С92.0', 'С92.4', 'С92.5', 'C92.6', 'C92.8', 'С93.0', 'C93.3', 'С94.0', 'С94.2', 'C95.0'))
GROUP BY CodeM
------------------------------------------------------------------------
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
FROM #total t INNER JOIN dbo.vw_sprT001 l ON
		t.CodeM=l.CodeM
GROUP BY t.codeM+' - '+l.NAMES
ORDER BY t.codeM+' - '+l.NAMES



GO
DROP TABLE #tPeople
DROP TABLE #total