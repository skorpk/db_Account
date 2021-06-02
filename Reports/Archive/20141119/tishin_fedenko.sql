USE AccountOMS
GO
CREATE TABLE #t
(
	CodeFilial TINYINT,
	CodeM CHAR(6),
	LPU varchar(250),
	Col4 decimal(11,2),
	Col5 decimal(11,2),
	Col6 decimal(11,2),
	Col7 decimal(11,2),
	Col8 decimal(11,2),
	Col9 decimal(11,2),
	Col10 decimal(11,2),
	Col11 decimal(11,2),
)
----------------таблица-------------------------
INSERT #t (CodeFilial,CodeM,LPU) 
SELECT filialCode,CodeM,NAMES  FROM dbo.vw_sprT001 WHERE pfa=1


CREATE TABLE #exceptCases(rf_idCase BIGINT)

INSERT #exceptCases( rf_idCase )
SELECT c.id
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
			AND a.rf_idSMO<>'34'				 					
					INNER JOIN (VALUES('D'),('O'),('R'),('F'),('V'),('I'),('U'),('T'),('K'),('G')) v(letter) ON
			a.Letter=v.letter
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts	
					INNER JOIN #t l1 ON
			r.AttachLPU=l1.CodeM				
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
			AND c.rf_idV006=3		
WHERE f.DateRegistration>'20140101' AND f.DateRegistration<'20141107' AND a.ReportMonth>0 AND a.ReportMonth<11 AND a.ReportYear=2014

--------------------------------t_MES---------------------------------
INSERT #exceptCases( rf_idCase )
SELECT  DISTINCT c.id
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
			AND a.rf_idSMO<>'34'				 									
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts	
					INNER JOIN #t l1 ON
			r.AttachLPU=l1.CodeM				
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
			AND c.rf_idV006=3
					INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase
					INNER JOIN (VALUES('2.78.26'),('2.78.30'),('2.78.21')) v(MES) ON
			m.MES=v.MES
WHERE f.DateRegistration>'20140101' AND f.DateRegistration<'20141107' AND a.ReportMonth>0 AND a.ReportMonth<11 AND a.ReportYear=2014

INSERT #exceptCases( rf_idCase )
SELECT  DISTINCT c.id
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
			AND a.rf_idSMO<>'34'				 									
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts	
					INNER JOIN #t l1 ON
			r.AttachLPU=l1.CodeM				
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
			AND c.rf_idV006=3
					INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase					
WHERE f.DateRegistration>'20140101' AND f.DateRegistration<'20141107' AND a.ReportMonth>0 AND a.ReportMonth<11 AND a.ReportYear=2014 AND m.MES LIKE '2.89.%'
		
----------------------------------t_Meduslugi----------------------------

INSERT #exceptCases( rf_idCase )
SELECT  DISTINCT c.id
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
			AND a.rf_idSMO<>'34'				 									
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts	
					INNER JOIN #t l1 ON
			r.AttachLPU=l1.CodeM				
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
			AND c.rf_idV006=3
					INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase
					INNER JOIN (VALUES(2,79,13),(2,80,8),(2,79,47),(2,88,33),(2,79,49),(2,82,7),(2,80,5),
										(2,80,16),(2,88,27),(2,88,38),(2,82,4)) v(MUGroupCode,MUUnGroupCode,MUCode) ON
			m.MUGroupCode=v.MUGroupCode AND m.MUUnGroupCode=v.MUUnGroupCode AND m.MUCode=v.MUCode
WHERE f.DateRegistration>'20140101' AND f.DateRegistration<'20141107' AND a.ReportMonth>0 AND a.ReportMonth<11 AND a.ReportYear=2014

INSERT #exceptCases( rf_idCase )
SELECT  DISTINCT c.id
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
			AND a.rf_idSMO<>'34'				 									
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts	
					INNER JOIN #t l1 ON
			r.AttachLPU=l1.CodeM				
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
			AND c.rf_idV006=3
					INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase
					INNER JOIN (VALUES(2,76),(2,81)) v(MUGroupCode,MUUnGroupCode) ON
			m.MUGroupCode=v.MUGroupCode
			AND m.MUUnGroupCode=v.MUUnGroupCode
WHERE f.DateRegistration>'20140101' AND f.DateRegistration<'20141107' AND a.ReportMonth>0 AND a.ReportMonth<11 AND a.ReportYear=2014 
		AND MU NOT in ('2.81.6')  

---таблица по всем случаям оказания амбулаторки
SELECT c.rf_idMO,r.AttachLPU,a.rf_idSMO,c.AmountPayment,c.id
INTO #tAllCase
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
								f.id=a.rf_idFiles
								AND a.rf_idSMO<>'34'								
										INNER JOIN dbo.t_RecordCasePatient r ON
								a.id=r.rf_idRegistersAccounts
								--		INNER JOIN #t l1 ON
								--f.CodeM=l1.CodeM
										INNER JOIN dbo.t_Case c ON
								r.id=c.rf_idRecordCasePatient
								AND c.rf_idV006=3
WHERE f.DateRegistration>'20140101' AND f.DateRegistration<'20141107' AND a.ReportMonth>0 AND a.ReportMonth<11 AND a.ReportYear=2014


------------------------------column 4,5
UPDATE t SET Col4=l.Sogaz,col5=Kapital
FROM #t t INNER JOIN (
					SELECT l1.CodeM,sum(CASE WHEN c.rf_idSMO='34001' THEN c.AmountPayment ELSE 0 END) AS Kapital,
							SUM(CASE WHEN c.rf_idSMO='34002' THEN c.AmountPayment ELSE 0 END) AS Sogaz
					FROM #tAllCase c INNER JOIN #t l1 ON
									c.AttachLPU=l1.CodeM
					WHERE NOT EXISTS(SELECT * FROM #exceptCases WHERE rf_idCase=c.id) AND c.rf_idMO=c.AttachLPU
					GROUP BY l1.CodeM
					) l ON
		T.CodeM=l.CodeM			
------------------------------column 6,7
UPDATE t SET Col6=l.Sogaz,col7=Kapital
FROM #t t INNER JOIN (
						SELECT l1.CodeM,sum(CASE WHEN c.rf_idSMO='34001' THEN c.AmountPayment ELSE 0 END) AS Kapital,
								SUM(CASE WHEN c.rf_idSMO='34002' THEN c.AmountPayment ELSE 0 END) AS Sogaz
						FROM #tAllCase c INNER JOIN #t l1 ON
									c.AttachLPU=l1.CodeM
						WHERE NOT EXISTS(SELECT * FROM #exceptCases WHERE rf_idCase=c.id)   AND c.rf_idMO<>c.AttachLPU
						GROUP BY l1.CodeM
				) l ON
		T.CodeM=l.CodeM	
------------------------------column 8,9
UPDATE t SET Col8=l.Sogaz,col9=Kapital
FROM #t t INNER JOIN (
					SELECT l1.CodeM,sum(CASE WHEN c.rf_idSMO='34001' THEN c.AmountPayment ELSE 0 END) AS Kapital,
							SUM(CASE WHEN c.rf_idSMO='34002' THEN c.AmountPayment ELSE 0 END) AS Sogaz
					FROM #tAllCase c INNER JOIN #t l1 ON
									c.rf_idMO=l1.CodeM
					GROUP BY l1.CodeM
				) l ON
				T.CodeM=l.CodeM	
------------------------------column 10,11
UPDATE t SET Col10=l.Sogaz,col11=Kapital
FROM #t t INNER JOIN (
						SELECT l1.CodeM,sum(CASE WHEN c.rf_idSMO='34001' THEN ISNULL(c.AmountPayment,0) ELSE 0 END) AS Kapital,
								SUM(CASE WHEN c.rf_idSMO='34002' THEN ISNULL(c.AmountPayment,0) ELSE 0 END) AS Sogaz
						FROM #tAllCase c INNER JOIN #t l1 ON
									c.AttachLPU=l1.CodeM
										INNER JOIN (SELECT DISTINCT rf_idCase from #exceptCases) c1 ON
									c.id=c1.rf_idCase
						--WHERE  c.rf_idMO=c.AttachLPU
						GROUP BY l1.CodeM
				) l ON
			T.CodeM=l.CodeM	

SELECT CodeFilial,CodeM,LPU,Col4,Col5,Col6,Col7,Col8,Col9,ISNULL(Col10,0),ISNULL(Col11,0)
FROM #t 
WHERE Col4 IS NOT NULL AND Col5 IS NOT NULL AND Col6 IS NOT NULL AND Col7 IS NOT NULL 
ORDER BY CodeFilial,CodeM

------------------------не прикрепленные
/*
SELECT SUM(c.AmountPayment)
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
								f.id=a.rf_idFiles
								AND a.rf_idSMO<>'34'					
										INNER JOIN dbo.t_RecordCasePatient r ON
								a.id=r.rf_idRegistersAccounts										
										INNER JOIN dbo.t_Case c ON
								r.id=c.rf_idRecordCasePatient
								AND c.rf_idV006=3
WHERE f.DateRegistration>'20140101' AND f.DateRegistration<'20141107' AND a.ReportMonth>0 AND a.ReportMonth<11 AND a.ReportYear=2014
		AND r.AttachLPU='000000'
*/
GO
DROP TABLE #exceptCases
DROP TABLE #t
DROP TABLE #tAllCase