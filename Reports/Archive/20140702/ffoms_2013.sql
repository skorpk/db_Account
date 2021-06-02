USE AccountOMS
GO

CREATE TABLE #tPeople(rf_idCase BIGINT,
					  DateBegin DATE, 
					  DateEnd DATE,
					  CodeM CHAR(6),
					  Account VARCHAR(15),
					  IdPeople BIGINT,
					  NumberCase BIGINT,
					  DS VARCHAR(10),
					  AmountPayment DECIMAL(11,2),
					  AmountRAK DECIMAL(11,2)					  
					  )					

INSERT #tPeople( rf_idCase ,DateBegin ,DateEnd ,CodeM ,Account ,IdPeople,NumberCase,AmountPayment)
SELECT c.id,c.DateBegin,c.DateEnd,f.CodeM,a.Account,pc.IDPeople,c.idRecordCase,c.AmountPayment		
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
			AND a.Letter IN ('A','G')
			AND a.rf_idSMO='34002'
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
			AND c.DateEnd>'20130101'										
			AND c.DateEnd<'20140101'
			--AND c.rf_idV006=3
					INNER JOIN dbo.t_People_Case pc ON
			c.id=pc.rf_idCase	
					INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase				
WHERE f.DateRegistration>'20130101' AND f.DateRegistration<'20140125' AND a.ReportMonth>0 AND a.ReportMonth<13 AND a.ReportYear=2013
		AND m.MES LIKE '2.78.%'
-------------------------------------------update block----------------------------------
UPDATE p SET p.DS=DiagnosisCode
FROM #tPeople p INNER JOIN dbo.t_Diagnosis d ON
		p.rf_idCase=d.rf_idCase
WHERE d.TypeDiagnosis=1


UPDATE p SET p.AmountRAK=p.AmountPayment-r.AmountDeduction
FROM #tPeople p INNER JOIN (SELECT rf_idCase,SUM(AmountDeduction) AS AmountDeduction 
							FROM dbo.t_PaymentAcceptedCase a INNER JOIN (VALUES('A'),('G')) l(Letter) ON
														a.Letter=l.Letter 
							WHERE DateRegistration>='20130101' AND DateRegistration<'20140702'
							GROUP BY rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
					
SELECT /*distinct  t.CodeM2 ,
		l.NAMES AS LPU2,
        t.Acount2 ,
        t.NumberCase2 ,
        t.DS2 +' - '+m.Diagnosis AS DS2,
        t.DateBegin2 ,
        t.DateEnd2 ,
        t.CodeM ,
        l2.NAMES AS LPU ,
        t.Account ,
        t.NumberCase ,
        t.DS +' - '+m.Diagnosis AS DS,
        t.DateBegin ,
        t.DateEnd ,
        t.IdPeople
        */        
        COUNT(DISTINCT rf_idCase)
FROM(
	SELECT  t.CodeM AS CodeM2					
					,t.Account AS Acount2
					,t.NumberCase AS NumberCase2
					,RTRIM(t.DS) AS DS2
					,t.DateBegin as DateBegin2 
					,t.DateEnd AS DateEnd2
					,t1.CodeM					
					,t1.Account 
					,t1.NumberCase 
					,RTRIM(t1.DS) AS DS
					,t1.DateBegin 
					,t1.DateEnd,
					t1.IdPeople
					,t1.rf_idCase 
	
	FROM #tPeople t INNER JOIN #tPeople t1 ON
			t.IdPeople=t1.IdPeople
			AND t.DS=t1.DS
			AND t.rf_idCase<>t1.rf_idCase						
	WHERE t1.DateBegin>t.DateBegin AND t1.DateBegin<=DATEADD(dd,30,t.DateEnd) AND ISNULL(t.AmountRAK,'-1')>0 AND ISNULL(t1.AmountRAK,'-1')>0 
	) t /*INNER JOIN dbo.vw_sprT001 l ON
			t.CodeM2=l.CodeM
					INNER JOIN dbo.vw_sprT001 l2 ON
			t.CodeM=l2.CodeM
					INNER JOIN dbo.vw_sprMKB10 m ON
			t.DS2=m.DiagnosisCode
					INNER JOIN dbo.vw_sprMKB10 m2 ON
			t.DS=m2.DiagnosisCode		
		  */
go
DROP TABLE #tPeople
--DROP TABLE #t
