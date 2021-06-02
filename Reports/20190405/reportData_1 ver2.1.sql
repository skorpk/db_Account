USE AccountOMS
GO
DECLARE @dateStart DATETIME='20190101',	--всегда с начало года
		@dateEnd DATETIME='20190509',
		@reportYear SMALLINT=2019,
		@dateEndAkt DATETIME='20190506'		

SELECT DiagnosisCode INTO #tD FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'D0_' OR MainDS LIKE 'C__'	
AND MainDS NOT IN('C80','C81','C82','C83','C84','C85','C86','C88','C90', 'C91','C92','C93','C94','C95','C96')

----берем с диагнозом из списка
SELECT DISTINCT c.id AS rf_idCase,r.id AS rf_idRecordCasePatient, c.AmountPayment,ps.ENP, c.AmountPayment AS AmountPay, dd1.DS_ONK AS DS_ONK, d.DS1,f.TypeFile, c.C_ZAB
			,a.rf_idSMO AS CodeSMO, a.ReportMonth
INTO #tCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
					INNER JOIN dbo.t_Case c  ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.vw_Diagnosis d ON
			c.id=d.rf_idCase
					INNER JOIN #tD dd ON
			d.DS1=dd.DiagnosisCode     										     
					INNER JOIN dbo.t_PatientSMO ps ON
			r.id=ps.rf_idRecordCasePatient	
					INNER JOIN t_DS_ONK_REAB dd1 ON
			c.id=dd1.rf_idCase 												   					  					      
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=@reportYear AND c.rf_idV006<4 AND f.TypeFile='H'
UNION ALL
SELECT DISTINCT c.id AS rf_idCase,r.id AS rf_idRecordCasePatient, c.AmountPayment,ps.ENP, c.AmountPayment AS AmountPay,dd1.DS_ONK AS DS_ONK, d.DiagnosisCode, f.TypeFile, c.C_ZAB
		,a.rf_idSMO AS CodeSMO,a.ReportMonth
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
					INNER JOIN dbo.t_Case c  ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_Diagnosis d ON
			c.id=d.rf_idCase
					INNER JOIN #tD dd ON
			d.DiagnosisCode=dd.DiagnosisCode     										     
					INNER JOIN dbo.t_PatientSMO ps ON
			r.id=ps.rf_idRecordCasePatient	
					INNER JOIN t_DS_ONK_REAB dd1 ON
			c.id=dd1.rf_idCase 													   					  					      
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=@reportYear AND c.rf_idV006<4 AND f.TypeFile='F'
------берем с DS_ONK=1
CREATE UNIQUE NONCLUSTERED INDEX QU_Temp ON #tCases(rf_idRecordCasePatient) WITH IGNORE_DUP_KEY

INSERT #tCases
SELECT DISTINCT c.id AS rf_idCase,r.id AS rf_idRecordCasePatient, c.AmountPayment,ps.ENP, c.AmountPayment AS AmountPay,dd.DS_ONK, d.DS1	,f.TypeFile, c.C_ZAB
		,a.rf_idSMO AS CodeSMO,a.ReportMonth
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
					INNER JOIN dbo.t_Case c  ON
			r.id=c.rf_idRecordCasePatient													     
					INNER JOIN dbo.t_PatientSMO ps ON
			r.id=ps.rf_idRecordCasePatient													   					  					      
					INNER JOIN t_DS_ONK_REAB dd ON
			c.id=dd.rf_idCase 
					INNER JOIN dbo.vw_Diagnosis d ON
			c.id=d.rf_idCase                  
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=@reportYear AND c.rf_idV006<4 AND dd.DS_ONK=1


UPDATE p SET p.AmountPay=p.AmountPay-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndAkt	 
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase


---------------------------------От Антоновой---------------------------------------------
SELECT SUM(Col7) AS Col7,SUM(Col8) AS Col8,SUM(Col9) AS Col9,SUM(Col7) AS Col10,SUM(Col11) AS Col11,SUM(Col12) AS Col12,SUM(Col13) AS Col13
	,SUM(Col14),SUM(Col15) ,SUM(Col16)
FROM (
		SELECT COUNT(DISTINCT ENP) AS Col7, 0 AS Col8,0 AS Col9,0 AS Col11,0 AS Col12, 0 AS Col13, 0 AS Col14, 0 AS Col15,0 AS Col16 FROM #tCases WHERE AmountPay>0
		UNION all
		SELECT 0,COUNT(DISTINCT ENP) AS Col8,0,0,0,0,0,0,0 
		FROM #tCases cc
		WHERE AmountPay>0 AND DS_ONK=1 AND NOT EXISTS(SELECT 1 FROM #tD WHERE DiagnosisCode=DS1)
				AND NOT EXISTS (SELECT 1
								FROM #tCases c INNER JOIN #tD d ON
										c.DS1=d.DiagnosisCode
								WHERE AmountPay>0 AND c.ENP=cc.ENP
								)
		UNION all
		SELECT 0,0,COUNT(DISTINCT ENP) AS Col9,0,0,0,0,0,0
		FROM #tCases c INNER JOIN #tD d ON
				c.DS1=d.DiagnosisCode
		WHERE AmountPay>0 				  
		UNION all
		SELECT 0,0,0,COUNT(DISTINCT ENP) AS Col11,0,0,0,0,0
		FROM (
				SELECT ENP
				FROM #tCases c INNER JOIN #tD d ON
						c.DS1=d.DiagnosisCode
				WHERE c.TypeFile='H' AND c.C_ZAB=2 AND AmountPay>0
				UNION ALL
				SELECT ENP
				FROM #tCases c INNER JOIN dbo.t_Diagnosis dd ON
						c.rf_idCase=dd.rf_idCase      
							  INNER JOIN #tD d ON
						c.DS1=d.DiagnosisCode
				WHERE c.TypeFile='F' AND AmountPay>0 AND EXISTS(SELECT 1 FROM dbo.t_Case WHERE id=c.rf_idCase AND IsFirstDS=1
												UNION ALL
												SELECT 1 FROM dbo.t_DS2_Info ds WHERE c.rf_idCase=ds.rf_idCase AND IsFirst=1)
			) t
		UNION all
		SELECT 0,0,0,0,COUNT(DISTINCT ENP) AS Col12,0,0,0,0
		FROM (			
				SELECT ENP
				FROM #tCases c INNER JOIN dbo.t_Diagnosis dd ON
						c.rf_idCase=dd.rf_idCase      
							  INNER JOIN #tD d ON
						dd.DiagnosisCode=d.DiagnosisCode
				WHERE c.TypeFile='F' AND AmountPay>0 AND EXISTS(SELECT 1 FROM dbo.t_Case WHERE id=c.rf_idCase AND IsFirstDS=1
																UNION ALL
																SELECT 1 FROM dbo.t_DS2_Info ds WHERE c.rf_idCase=ds.rf_idCase AND IsFirst=1
																)
			) t
		UNION all
		SELECT 0,0,0,0,0,COUNT(DISTINCT ENP) AS Col13,0,0,0
		FROM (
				SELECT ENP
				FROM #tCases c INNER JOIN #tD d ON
						c.DS1=d.DiagnosisCode
				WHERE c.TypeFile='H' AND c.C_ZAB=2 AND AmountPay>0 AND CodeSMO='34'
				UNION ALL
				SELECT ENP
				FROM #tCases c INNER JOIN dbo.t_Diagnosis dd ON
						c.rf_idCase=dd.rf_idCase      
							  INNER JOIN #tD d ON
						c.DS1=d.DiagnosisCode
				WHERE c.TypeFile='F' AND CodeSMO='34' AND AmountPay>0 AND EXISTS(SELECT 1 FROM dbo.t_Case WHERE id=c.rf_idCase AND IsFirstDS=1
												UNION ALL
												SELECT 1 FROM dbo.t_DS2_Info ds WHERE c.rf_idCase=ds.rf_idCase AND IsFirst=1)
			) t
		UNION ALL
		SELECT 0,0,0,0,0,0,COUNT(DISTINCT ENP),0,0
		FROM (      
				SELECT c.ENP
				FROM #tCases c INNER JOIN t_PurposeOfVisit p ON
						c.rf_idCase=p.rf_idCase
								INNER JOIN t_Case cc ON
						c.rf_idCase=cc.id                      
				WHERE c.TypeFile='H' AND AmountPay>0  AND cc.rf_idV006=3 AND p.rf_idV025='1.3' AND p.DN IN(1,2)
				UNION ALL
				SELECT c.ENP
				FROM #tCases c INNER JOIN dbo.t_Diagnosis dd ON
						c.rf_idCase=dd.rf_idCase      
							   INNER JOIN #tD d ON
						c.DS1=d.DiagnosisCode
				 			  INNER JOIN t_Case cc ON
						c.rf_idCase=cc.id 
								LEFT JOIN dbo.t_DS2_Info di ON
						cc.id=di.rf_idCase                     
				WHERE c.TypeFile='F' AND AmountPay>0 AND (cc.IsNeedDisp IN (1,2) OR ISNULL(di.IsNeedDisp,9) IN(1,2))
			)t
			UNION ALL
			SELECT 0,0,0,0,0,0,0,COUNT(DISTINCT ENP),0
			FROM (      
					SELECT c.ENP
					FROM #tCases c INNER JOIN t_PurposeOfVisit p ON
							c.rf_idCase=p.rf_idCase
									INNER JOIN t_Case cc ON
							c.rf_idCase=cc.id                      
					WHERE c.TypeFile='H' AND AmountPay>0  AND cc.rf_idV006=3 AND p.rf_idV025='1.3' AND p.DN =1
					UNION ALL
					SELECT c.ENP
					FROM #tCases c INNER JOIN dbo.t_Diagnosis dd ON
							c.rf_idCase=dd.rf_idCase      
								   INNER JOIN #tD d ON
							c.DS1=d.DiagnosisCode
					 			  INNER JOIN t_Case cc ON
							c.rf_idCase=cc.id 
									LEFT JOIN dbo.t_DS2_Info di ON
							cc.id=di.rf_idCase                     
					WHERE c.TypeFile='F' AND AmountPay>0 AND (cc.IsNeedDisp =1 OR ISNULL(di.IsNeedDisp,9) =1)
				)t
			UNION ALL
			SELECT 0,0,0,0,0,0,0,0,COUNT(DISTINCT ENP)
			FROM (      
					SELECT c.ENP
					FROM #tCases c INNER JOIN t_PurposeOfVisit p ON
							c.rf_idCase=p.rf_idCase
									INNER JOIN t_Case cc ON
							c.rf_idCase=cc.id                      
					WHERE c.TypeFile='H' AND AmountPay>0  AND cc.rf_idV006=3 AND p.rf_idV025='1.3' AND p.DN =1 AND c.ReportMonth=3
					UNION ALL
					SELECT c.ENP
					FROM #tCases c INNER JOIN dbo.t_Diagnosis dd ON
							c.rf_idCase=dd.rf_idCase      
								   INNER JOIN #tD d ON
							c.DS1=d.DiagnosisCode
					 			  INNER JOIN t_Case cc ON
							c.rf_idCase=cc.id 
									LEFT JOIN dbo.t_DS2_Info di ON
							cc.id=di.rf_idCase                     
					WHERE c.TypeFile='F' AND AmountPay>0 AND (cc.IsNeedDisp =1 OR ISNULL(di.IsNeedDisp,9) =1) AND c.ReportMonth=3
				)t
		      
	)t
---------------------------Колесов-----------------------------

CREATE TABLE #tKSG(ksg VARCHAR(15))
INSERT #tKSG( ksg ) VALUES  ( 'ds08.001'),('st08.001')
INSERT #tKSG( ksg )
SELECT code
FROM RegisterCases.dbo.vw_sprCSG WHERE code between 'ds19.018' AND 'ds19.027'
UNION all
SELECT code
FROM RegisterCases.dbo.vw_sprCSG WHERE code between 'st19.027' AND 'st19.036'


CREATE TABLE #tmpKolesov(Col39 INT NOT NULL DEFAULT 0,Col40 INT NOT NULL DEFAULT 0,Col41 INT NOT NULL DEFAULT 0,Col42 INT NOT NULL DEFAULT 0,Col43 INT NOT NULL DEFAULT 0,Col44 INT NOT NULL DEFAULT 0
						  ,Col55 INT NOT NULL DEFAULT 0,Col56 INT NOT NULL DEFAULT 0,Col57 INT NOT NULL DEFAULT 0,Col58 INT NOT NULL DEFAULT 0,Col59 INT NOT NULL DEFAULT 0,Col60 INT NOT NULL DEFAULT 0
						  ,Col71 INT NOT NULL DEFAULT 0,Col72 INT NOT NULL DEFAULT 0,Col73 INT NOT NULL DEFAULT 0,Col74 INT NOT NULL DEFAULT 0,Col75 INT NOT NULL DEFAULT 0,Col76 INT NOT NULL DEFAULT 0
						  ,Col87 VARCHAR(300),Col88 VARCHAR(300),Col89 VARCHAR(300),Col90 VARCHAR(300),Col91 VARCHAR(300),Col92 VARCHAR(300))
 -----------------------MEK------------------------
INSERT #tmpKolesov( Col39 )
SELECT COUNT(DISTINCT c.rf_idCase)
FROM #tCases c INNER JOIN dbo.t_PaymentAcceptedCase2 p ON
		c.rf_idCase=p.rf_idCase
WHERE p.DateRegistration>@dateStart AND p.DateRegistration<@dateEnd AND p.TypeCheckup=1	AND c.CodeSMO='34'

INSERT #tmpKolesov( Col40 )
SELECT COUNT(DISTINCT c.rf_idCase)
FROM #tCases c INNER JOIN dbo.t_PaymentAcceptedCase2 p ON
		c.rf_idCase=p.rf_idCase
				INNER JOIN dbo.t_MES m ON
		c.rf_idCase=m.rf_idCase              
				INNER JOIN #tKSG kk ON
		m.Mes=kk.ksg              
WHERE p.DateRegistration>@dateStart AND p.DateRegistration<@dateEnd AND p.TypeCheckup=1 AND m.TypeMES=2	AND c.CodeSMO='34'
-----------------------MEE------------------------
INSERT #tmpKolesov( Col41 )
SELECT COUNT(DISTINCT c.rf_idCase)
FROM #tCases c INNER JOIN dbo.t_PaymentAcceptedCase2 p ON
		c.rf_idCase=p.rf_idCase
WHERE p.DateRegistration>@dateStart AND p.DateRegistration<@dateEnd AND p.TypeCheckup=2	AND c.CodeSMO='34'

INSERT #tmpKolesov( Col42 )
SELECT COUNT(DISTINCT c.rf_idCase)
FROM #tCases c INNER JOIN dbo.t_PaymentAcceptedCase2 p ON
		c.rf_idCase=p.rf_idCase
				INNER JOIN dbo.t_MES m ON
		c.rf_idCase=m.rf_idCase              
				INNER JOIN #tKSG kk ON
		m.Mes=kk.ksg              
WHERE p.DateRegistration>@dateStart AND p.DateRegistration<@dateEnd AND p.TypeCheckup=2 AND m.TypeMES=2 AND c.CodeSMO='34'
-----------------------EKMP------------------------
INSERT #tmpKolesov( Col43 )
SELECT COUNT(DISTINCT c.rf_idCase)
FROM #tCases c INNER JOIN dbo.t_PaymentAcceptedCase2 p ON
		c.rf_idCase=p.rf_idCase
WHERE p.DateRegistration>@dateStart AND p.DateRegistration<@dateEnd AND p.TypeCheckup=3	AND c.CodeSMO='34'

INSERT #tmpKolesov( Col44 )
SELECT COUNT(DISTINCT c.rf_idCase)
FROM #tCases c INNER JOIN dbo.t_PaymentAcceptedCase2 p ON
		c.rf_idCase=p.rf_idCase
				INNER JOIN dbo.t_MES m ON
		c.rf_idCase=m.rf_idCase              
				INNER JOIN #tKSG kk ON
		m.Mes=kk.ksg              
WHERE p.DateRegistration>@dateStart AND p.DateRegistration<@dateEnd AND p.TypeCheckup=3 AND m.TypeMES=2	AND c.CodeSMO='34'

CREATE TABLE #F014(id tinyint,TypeCheckup TINYINT)         
INSERT #F014( id, TypeCheckup )
VALUES  (50,1),(51,1),(52,1),(53,1),(54,1),(55,1),(56,1),(58,1),(59,1),(60,1),(61,1),(62,1),(64,1),(65,1),(66,1),(67,1),(68,1),(69,1),(70,1),(71,1),(72,1),(73,1),(74,1),(75,1)
,(1  ,2),(8  ,2),(9  ,2),(25 ,2),(26 ,2),(27 ,2),(28 ,2),(29 ,2),(30 ,2),(32 ,2),(33 ,2),(34 ,2),(34 ,2),(35 ,2),(35 ,2),(36 ,2),(38 ,2),(39 ,2),(41 ,2),(42 ,2),(43 ,2),(44 ,2),
(45 ,2),(46 ,2),(47 ,2),(48 ,2),(53 ,2),(63 ,2),(71 ,2),(127,2),(128,2),
(1  ,3),(8  ,3),(9  ,3),(24 ,3),(25 ,3),(26 ,3),(27 ,3),(28 ,3),(29 ,3),(30 ,3),(32 ,3),(33 ,3),(34 ,3),(34 ,3),(35 ,3),(35 ,3),(36 ,3),(38 ,3),
(40 ,3),(41 ,3),(43 ,3),(44 ,3),(45 ,3),(46 ,3),(47 ,3),(48 ,3),(50 ,3),(51 ,3),(52 ,3),(53 ,3),(54 ,3),(55 ,3),(56 ,3),(57 ,3),(58 ,3),(59 ,3),
(60 ,3),(61 ,3),(62 ,3),(63 ,3),(64 ,3),(65 ,3),(66 ,3),(67 ,3),(68 ,3),(69 ,3),(70 ,3),(71 ,3),(71 ,3),(72 ,3),(73 ,3),(74 ,3),(75 ,3),(127,3),(128,3)

 -----------------------MEK------------------------
INSERT #tmpKolesov( Col55 )
SELECT COUNT(DISTINCT c.rf_idCase)
FROM #tCases c INNER JOIN dbo.t_PaymentAcceptedCase2 p ON
		c.rf_idCase=p.rf_idCase	
				INNER JOIN dbo.t_ReasonDenialPayment r ON
		p.rf_idCase=r.rf_idCase
		AND p.idAkt=r.idAkt              
				INNER JOIN #F014 f14 ON
		r.CodeReason=f14.id		              
WHERE p.DateRegistration>@dateStart AND p.DateRegistration<@dateEnd AND p.TypeCheckup=1 AND f14.TypeCheckup=1 AND c.CodeSMO='34'

INSERT #tmpKolesov( Col56 )
SELECT COUNT(DISTINCT c.rf_idCase)
FROM #tCases c INNER JOIN dbo.t_PaymentAcceptedCase2 p ON
		c.rf_idCase=p.rf_idCase
				INNER JOIN dbo.t_MES m ON
		c.rf_idCase=m.rf_idCase              
				INNER JOIN #tKSG kk ON
		m.Mes=kk.ksg            
				INNER JOIN dbo.t_ReasonDenialPayment r ON
		p.rf_idCase=r.rf_idCase
		AND p.idAkt=r.idAkt              
				INNER JOIN #F014 f14 ON
		r.CodeReason=f14.id		               
WHERE p.DateRegistration>@dateStart AND p.DateRegistration<@dateEnd AND p.TypeCheckup=1 AND m.TypeMES=2 AND f14.TypeCheckup=1 AND c.CodeSMO='34'
-----------------------MEE------------------------
INSERT #tmpKolesov( Col57 )
SELECT COUNT(DISTINCT c.rf_idCase)
FROM #tCases c INNER JOIN dbo.t_PaymentAcceptedCase2 p ON
		c.rf_idCase=p.rf_idCase
								INNER JOIN dbo.t_ReasonDenialPayment r ON
		p.rf_idCase=r.rf_idCase
		AND p.idAkt=r.idAkt              
				INNER JOIN #F014 f14 ON
		r.CodeReason=f14.id		              
WHERE p.DateRegistration>@dateStart AND p.DateRegistration<@dateEnd AND p.TypeCheckup=2 AND f14.TypeCheckup=2 AND c.CodeSMO='34'

INSERT #tmpKolesov( Col58 )
SELECT COUNT(DISTINCT c.rf_idCase)
FROM #tCases c INNER JOIN dbo.t_PaymentAcceptedCase2 p ON
		c.rf_idCase=p.rf_idCase
				INNER JOIN dbo.t_MES m ON
		c.rf_idCase=m.rf_idCase              
				INNER JOIN #tKSG kk ON
		m.Mes=kk.ksg     
						INNER JOIN dbo.t_ReasonDenialPayment r ON
		p.rf_idCase=r.rf_idCase
		AND p.idAkt=r.idAkt              
				INNER JOIN #F014 f14 ON
		r.CodeReason=f14.id		                       
WHERE p.DateRegistration>@dateStart AND p.DateRegistration<@dateEnd AND p.TypeCheckup=2 AND m.TypeMES=2 AND f14.TypeCheckup=2 AND c.CodeSMO='34'
-----------------------EKMP------------------------
INSERT #tmpKolesov( Col59 )
SELECT COUNT(DISTINCT c.rf_idCase)
FROM #tCases c INNER JOIN dbo.t_PaymentAcceptedCase2 p ON
		c.rf_idCase=p.rf_idCase
								INNER JOIN dbo.t_ReasonDenialPayment r ON
		p.rf_idCase=r.rf_idCase
		AND p.idAkt=r.idAkt              
				INNER JOIN #F014 f14 ON
		r.CodeReason=f14.id		              
WHERE p.DateRegistration>@dateStart AND p.DateRegistration<@dateEnd AND p.TypeCheckup=3 AND f14.TypeCheckup=3 AND c.CodeSMO='34'

INSERT #tmpKolesov( Col60 )
SELECT COUNT(DISTINCT c.rf_idCase)
FROM #tCases c INNER JOIN dbo.t_PaymentAcceptedCase2 p ON
		c.rf_idCase=p.rf_idCase
				INNER JOIN dbo.t_MES m ON
		c.rf_idCase=m.rf_idCase              
				INNER JOIN #tKSG kk ON
		m.Mes=kk.ksg              
								INNER JOIN dbo.t_ReasonDenialPayment r ON
		p.rf_idCase=r.rf_idCase
		AND p.idAkt=r.idAkt              
				INNER JOIN #F014 f14 ON
		r.CodeReason=f14.id		              
WHERE p.DateRegistration>@dateStart AND p.DateRegistration<@dateEnd AND p.TypeCheckup=3 AND m.TypeMES=2 AND f14.TypeCheckup=3  AND c.CodeSMO='34'
-------------------------------------Дефекты--------------------------
-----------------------MEK------------------------
INSERT #tmpKolesov( Col71 )
SELECT COUNT(r.id)
FROM #tCases c INNER JOIN dbo.t_PaymentAcceptedCase2 p ON
		c.rf_idCase=p.rf_idCase	
				INNER JOIN dbo.t_ReasonDenialPayment r ON
		p.rf_idCase=r.rf_idCase
		AND p.idAkt=r.idAkt              
				INNER JOIN #F014 f14 ON
		r.CodeReason=f14.id		              
WHERE p.DateRegistration>@dateStart AND p.DateRegistration<@dateEnd AND p.TypeCheckup=1 AND f14.TypeCheckup=1 AND c.CodeSMO='34'

INSERT #tmpKolesov( Col72 )
SELECT COUNT(r.id)
FROM #tCases c INNER JOIN dbo.t_PaymentAcceptedCase2 p ON
		c.rf_idCase=p.rf_idCase
				INNER JOIN dbo.t_MES m ON
		c.rf_idCase=m.rf_idCase              
				INNER JOIN #tKSG kk ON
		m.Mes=kk.ksg            
				INNER JOIN dbo.t_ReasonDenialPayment r ON
		p.rf_idCase=r.rf_idCase
		AND p.idAkt=r.idAkt              
				INNER JOIN #F014 f14 ON
		r.CodeReason=f14.id		               
WHERE p.DateRegistration>@dateStart AND p.DateRegistration<@dateEnd AND p.TypeCheckup=1 AND m.TypeMES=2 AND f14.TypeCheckup=1 AND c.CodeSMO='34'
-----------------------MEE------------------------
INSERT #tmpKolesov( Col73 )
SELECT COUNT(r.id)
FROM #tCases c INNER JOIN dbo.t_PaymentAcceptedCase2 p ON
		c.rf_idCase=p.rf_idCase
								INNER JOIN dbo.t_ReasonDenialPayment r ON
		p.rf_idCase=r.rf_idCase
		AND p.idAkt=r.idAkt              
				INNER JOIN #F014 f14 ON
		r.CodeReason=f14.id		              
WHERE p.DateRegistration>@dateStart AND p.DateRegistration<@dateEnd AND p.TypeCheckup=2 AND f14.TypeCheckup=2 AND c.CodeSMO='34'

INSERT #tmpKolesov( Col74 )
SELECT COUNT(r.id)
FROM #tCases c INNER JOIN dbo.t_PaymentAcceptedCase2 p ON
		c.rf_idCase=p.rf_idCase
				INNER JOIN dbo.t_MES m ON
		c.rf_idCase=m.rf_idCase              
				INNER JOIN #tKSG kk ON
		m.Mes=kk.ksg     
						INNER JOIN dbo.t_ReasonDenialPayment r ON
		p.rf_idCase=r.rf_idCase
		AND p.idAkt=r.idAkt              
				INNER JOIN #F014 f14 ON
		r.CodeReason=f14.id		                       
WHERE p.DateRegistration>@dateStart AND p.DateRegistration<@dateEnd AND p.TypeCheckup=2 AND m.TypeMES=2 AND f14.TypeCheckup=2 AND c.CodeSMO='34'
-----------------------EKMP------------------------
INSERT #tmpKolesov( Col75 )
SELECT COUNT(r.id)
FROM #tCases c INNER JOIN dbo.t_PaymentAcceptedCase2 p ON
		c.rf_idCase=p.rf_idCase
								INNER JOIN dbo.t_ReasonDenialPayment r ON
		p.rf_idCase=r.rf_idCase
		AND p.idAkt=r.idAkt              
				INNER JOIN #F014 f14 ON
		r.CodeReason=f14.id		              
WHERE p.DateRegistration>@dateStart AND p.DateRegistration<@dateEnd AND p.TypeCheckup=3 AND f14.TypeCheckup=3 AND c.CodeSMO='34'

INSERT #tmpKolesov( Col76 )
SELECT COUNT(r.id)
FROM #tCases c INNER JOIN dbo.t_PaymentAcceptedCase2 p ON
		c.rf_idCase=p.rf_idCase
				INNER JOIN dbo.t_MES m ON
		c.rf_idCase=m.rf_idCase              
				INNER JOIN #tKSG kk ON
		m.Mes=kk.ksg              
								INNER JOIN dbo.t_ReasonDenialPayment r ON
		p.rf_idCase=r.rf_idCase
		AND p.idAkt=r.idAkt              
				INNER JOIN #F014 f14 ON
		r.CodeReason=f14.id		              
WHERE p.DateRegistration>@dateStart AND p.DateRegistration<@dateEnd AND p.TypeCheckup=3 AND m.TypeMES=2 AND f14.TypeCheckup=3 AND c.CodeSMO='34'
-------------------------------------Дефекты перечисления--------------------------
-----------------------MEK------------------------
DECLARE @p VARCHAR(4000)=''
DECLARE @pHim VARCHAR(4000)=''

;WITH cte 
AS(
SELECT DISTINCT f.Reason
FROM #tCases c INNER JOIN dbo.t_PaymentAcceptedCase2 p ON
		c.rf_idCase=p.rf_idCase	
				INNER JOIN dbo.t_ReasonDenialPayment r ON
		p.rf_idCase=r.rf_idCase
		AND p.idAkt=r.idAkt              
				INNER JOIN #F014 f14 ON
		r.CodeReason=f14.id	
				INNER JOIN oms_nsi.dbo.sprF014 f ON
		r.CodeReason=f.id	              
WHERE p.DateRegistration>@dateStart AND p.DateRegistration<@dateEnd AND p.TypeCheckup=1 AND f14.TypeCheckup=1  AND c.CodeSMO='34'
)
SELECT @p=@p+reason+';' FROM cte

UPDATE #tmpKolesov SET Col87=@p

;WITH cte 
AS(
SELECT DISTINCT f.Reason
FROM #tCases c INNER JOIN dbo.t_PaymentAcceptedCase2 p ON
		c.rf_idCase=p.rf_idCase
				INNER JOIN dbo.t_MES m ON
		c.rf_idCase=m.rf_idCase              
				INNER JOIN #tKSG kk ON
		m.Mes=kk.ksg            
				INNER JOIN dbo.t_ReasonDenialPayment r ON
		p.rf_idCase=r.rf_idCase
		AND p.idAkt=r.idAkt              
				INNER JOIN #F014 f14 ON
		r.CodeReason=f14.id		  
				INNER JOIN oms_nsi.dbo.sprF014 f ON
		r.CodeReason=f.id	             
WHERE p.DateRegistration>@dateStart AND p.DateRegistration<@dateEnd AND p.TypeCheckup=1 AND m.TypeMES=2 AND f14.TypeCheckup=1 AND c.CodeSMO='34'
)
SELECT @pHim=@pHim+reason+';' FROM cte

UPDATE #tmpKolesov SET Col88=@pHim
-----------------------MEE------------------------
SET @p=''
SET @pHim=''
;WITH cte 
AS(
SELECT DISTINCT f.Reason
FROM #tCases c INNER JOIN dbo.t_PaymentAcceptedCase2 p ON
		c.rf_idCase=p.rf_idCase
								INNER JOIN dbo.t_ReasonDenialPayment r ON
		p.rf_idCase=r.rf_idCase
		AND p.idAkt=r.idAkt              
				INNER JOIN #F014 f14 ON
		r.CodeReason=f14.id	
		INNER JOIN oms_nsi.dbo.sprF014 f ON
		r.CodeReason=f.id		              
WHERE p.DateRegistration>@dateStart AND p.DateRegistration<@dateEnd AND p.TypeCheckup=2 AND f14.TypeCheckup=2  AND c.CodeSMO='34'
)
SELECT @p=@p+reason+';' FROM cte

UPDATE #tmpKolesov SET Col89=@p

;WITH cte 
AS(
SELECT DISTINCT f.Reason
FROM #tCases c INNER JOIN dbo.t_PaymentAcceptedCase2 p ON
		c.rf_idCase=p.rf_idCase
				INNER JOIN dbo.t_MES m ON
		c.rf_idCase=m.rf_idCase              
				INNER JOIN #tKSG kk ON
		m.Mes=kk.ksg     
						INNER JOIN dbo.t_ReasonDenialPayment r ON
		p.rf_idCase=r.rf_idCase
		AND p.idAkt=r.idAkt              
				INNER JOIN #F014 f14 ON
		r.CodeReason=f14.id	
				INNER JOIN oms_nsi.dbo.sprF014 f ON
		r.CodeReason=f.id		                       
WHERE p.DateRegistration>@dateStart AND p.DateRegistration<@dateEnd AND p.TypeCheckup=2 AND m.TypeMES=2 AND f14.TypeCheckup=2 AND c.CodeSMO='34'
)
SELECT @pHim=@pHim+reason+';' FROM cte

UPDATE #tmpKolesov SET Col90=@pHim
-----------------------EKMP------------------------
SET @p=''
SET @pHim=''
;WITH cte 
AS(
SELECT DISTINCT f.Reason
FROM #tCases c INNER JOIN dbo.t_PaymentAcceptedCase2 p ON
		c.rf_idCase=p.rf_idCase
								INNER JOIN dbo.t_ReasonDenialPayment r ON
		p.rf_idCase=r.rf_idCase
		AND p.idAkt=r.idAkt              
				INNER JOIN #F014 f14 ON
		r.CodeReason=f14.id	
				INNER JOIN oms_nsi.dbo.sprF014 f ON
		r.CodeReason=f.id		              
WHERE p.DateRegistration>@dateStart AND p.DateRegistration<@dateEnd AND p.TypeCheckup=3 AND f14.TypeCheckup=3 AND c.CodeSMO='34'
)
SELECT @p=@p+reason+';' FROM cte

UPDATE #tmpKolesov SET Col91=@p

;WITH cte 
AS(
SELECT DISTINCT f.Reason
FROM #tCases c INNER JOIN dbo.t_PaymentAcceptedCase2 p ON
		c.rf_idCase=p.rf_idCase
				INNER JOIN dbo.t_MES m ON
		c.rf_idCase=m.rf_idCase              
				INNER JOIN #tKSG kk ON
		m.Mes=kk.ksg              
								INNER JOIN dbo.t_ReasonDenialPayment r ON
		p.rf_idCase=r.rf_idCase
		AND p.idAkt=r.idAkt              
				INNER JOIN #F014 f14 ON
		r.CodeReason=f14.id	
			INNER JOIN oms_nsi.dbo.sprF014 f ON
		r.CodeReason=f.id		              
WHERE p.DateRegistration>@dateStart AND p.DateRegistration<@dateEnd AND p.TypeCheckup=3 AND m.TypeMES=2 AND f14.TypeCheckup=3 AND c.CodeSMO='34'
)
SELECT @pHim=@pHim+reason+';' FROM cte

UPDATE #tmpKolesov SET Col92=@pHim


SELECT SUM(Col39) AS Col39,SUM(Col40) AS Col40,SUM(Col41) AS Col41,SUM(Col42) AS Col42,SUM(Col43) AS Col43,SUM(Col44) AS Col44
		,SUM(Col55) AS Col55,SUM(Col56) AS Col56,SUM(Col57) AS Col57,SUM(Col58) AS Col58,SUM(Col57) AS Col59,SUM(Col60) AS Col60
		,SUM(Col71) AS Col71,SUM(Col72) AS Col72,SUM(Col73) AS Col73,SUM(Col74) AS Col74,SUM(Col75) AS Col75,SUM(Col76) AS Col76
		,Col87,Col88,Col89,Col90,Col91,Col92
FROM #tmpKolesov
GROUP BY Col87,Col88,Col89,Col90,Col91,Col92
         
---------------------------Скрябина----------------------------
SELECT DISTINCT c.id AS rf_idCase,r.id AS rf_idRecordCasePatient, c.AmountPayment,ps.ENP, c.AmountPayment AS AmountPay, u.rf_idN013
			,a.rf_idSMO AS CodeSMO
INTO #tCases2
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
					INNER JOIN dbo.t_Case c  ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.vw_Diagnosis d ON
			c.id=d.rf_idCase
					INNER JOIN #tD dd ON
			d.DS1=dd.DiagnosisCode     										     
					INNER JOIN dbo.t_PatientSMO ps ON
			r.id=ps.rf_idRecordCasePatient	
					left JOIN dbo.t_ONK_USL u ON
			c.id=u.rf_idCase                  
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=@reportYear AND c.rf_idV006<4 AND a.rf_idSMO<>'34'
union all
--новое от 09.04.2019
SELECT DISTINCT c.id AS rf_idCase,r.id AS rf_idRecordCasePatient, c.AmountPayment,ps.ENP, c.AmountPayment AS AmountPay, u.rf_idN013
			,a.rf_idSMO AS CodeSMO
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
					INNER JOIN dbo.t_Case c  ON
			r.id=c.rf_idRecordCasePatient													     
					INNER JOIN dbo.t_PatientSMO ps ON
			r.id=ps.rf_idRecordCasePatient													   					  					      
					INNER JOIN t_DS_ONK_REAB dd ON
			c.id=dd.rf_idCase 	
					left JOIN dbo.t_ONK_USL u ON
			c.id=u.rf_idCase				               
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=@reportYear AND c.rf_idV006<4 AND dd.DS_ONK=1 AND a.rf_idSMO<>'34'

SELECT @@ROWCOUNT
-------------------------Колонки 33-38----------------------------------
CREATE TABLE #tmpSkrybina(Col33 INT NOT NULL DEFAULT 0,Col34 INT NOT NULL DEFAULT 0,Col35 INT NOT NULL DEFAULT 0,Col36 INT NOT NULL DEFAULT 0,Col37 INT NOT NULL DEFAULT 0,Col38 INT NOT NULL DEFAULT 0
						  ,Col49 INT NOT NULL DEFAULT 0,Col50 INT NOT NULL DEFAULT 0,Col51 INT NOT NULL DEFAULT 0,Col52 INT NOT NULL DEFAULT 0,Col53 INT NOT NULL DEFAULT 0,Col54 INT NOT NULL DEFAULT 0
						  ,Col65 INT NOT NULL DEFAULT 0,Col66 INT NOT NULL DEFAULT 0,Col67 INT NOT NULL DEFAULT 0,Col68 INT NOT NULL DEFAULT 0,Col69 INT NOT NULL DEFAULT 0,Col70 INT NOT NULL DEFAULT 0
						  ,Col81 VARCHAR(300),Col82 VARCHAR(300),Col83 VARCHAR(300),Col84 VARCHAR(300),Col85 VARCHAR(300),Col86 VARCHAR(300))
----------------------MEK--------------------------------
INSERT #tmpSkrybina(Col33)        
SELECT COUNT(DISTINCT c.rf_idCase) AS Col33
FROM #tCases2 c INNER JOIN dbo.t_PaymentAcceptedCase2 p ON
		c.rf_idCase=p.rf_idCase
WHERE p.DateRegistration>@dateStart AND p.DateRegistration<@dateEnd AND p.TypeCheckup=1

INSERT #tmpSkrybina(Col34)
SELECT COUNT(DISTINCT c.rf_idCase) AS Col34
FROM #tCases2 c INNER JOIN dbo.t_PaymentAcceptedCase2 p ON
		c.rf_idCase=p.rf_idCase
WHERE p.DateRegistration>@dateStart AND p.DateRegistration<@dateEnd AND p.TypeCheckup=1 AND c.rf_idN013=2
---------------------MEE----------------------------------
INSERT #tmpSkrybina(Col35)
SELECT COUNT(DISTINCT rf_idCase) AS Col35
FROM (
	SELECT c.rf_idCase, c.AmountPay-SUM(p.AmountDeduction) AS AmountPay
	FROM #tCases2 c INNER JOIN dbo.t_PaymentAcceptedCase2 p ON
			c.rf_idCase=p.rf_idCase
	WHERE p.DateRegistration>@dateStart AND p.DateRegistration<@dateEnd AND p.TypeCheckup=2
	GROUP BY c.rf_idCase,c.AmountPay
	) t
--WHERE t.AmountPay>0

INSERT #tmpSkrybina(Col36)
SELECT COUNT(DISTINCT rf_idCase) AS Col36
FROM (
	SELECT c.rf_idCase, c.AmountPay-SUM(p.AmountDeduction) AS AmountPay
	FROM #tCases2 c INNER JOIN dbo.t_PaymentAcceptedCase2 p ON
			c.rf_idCase=p.rf_idCase
	WHERE p.DateRegistration>@dateStart AND p.DateRegistration<@dateEnd AND p.TypeCheckup=2 AND c.rf_idN013=2
	GROUP BY c.rf_idCase,c.AmountPay
	) t
--WHERE t.AmountPay>0 
---------------------EKMP----------------------------------
INSERT #tmpSkrybina(Col37)
SELECT COUNT(DISTINCT rf_idCase) AS Col37
FROM (
	SELECT c.rf_idCase, c.AmountPay-SUM(p.AmountDeduction) AS AmountPay
	FROM #tCases2 c INNER JOIN dbo.t_PaymentAcceptedCase2 p ON
			c.rf_idCase=p.rf_idCase
	WHERE p.DateRegistration>@dateStart AND p.DateRegistration<@dateEnd AND p.TypeCheckup=3
	GROUP BY c.rf_idCase,c.AmountPay
	)t
--WHERE t.AmountPay>0

INSERT #tmpSkrybina(Col38)
SELECT COUNT(DISTINCT rf_idCase) AS Col38
FROM (
	SELECT c.rf_idCase, c.AmountPay-SUM(p.AmountDeduction) AS AmountPay
	FROM #tCases2 c INNER JOIN dbo.t_PaymentAcceptedCase2 p ON
			c.rf_idCase=p.rf_idCase
	WHERE p.DateRegistration>@dateStart AND p.DateRegistration<@dateEnd AND p.TypeCheckup=3 AND c.rf_idN013=2
	GROUP BY c.rf_idCase,c.AmountPay
	)t
--WHERE t.AmountPay>0
-------------------------Колонки 49-54----------------------------------

----------------------MEK Дефеты--------------------------------
INSERT #tmpSkrybina(Col49)
SELECT COUNT(DISTINCT c.rf_idCase) AS Col49
FROM #tCases2 c INNER JOIN dbo.t_PaymentAcceptedCase2 p ON
		c.rf_idCase=p.rf_idCase								
				INNER JOIN dbo.t_ReasonDenialPayment r ON
		p.rf_idCase=r.rf_idCase
		AND p.idAkt=r.idAkt              
WHERE p.DateRegistration>@dateStart AND p.DateRegistration<@dateEnd AND p.TypeCheckup=1  

INSERT #tmpSkrybina(Col50)
SELECT COUNT(DISTINCT c.rf_idCase) AS Col50
FROM #tCases2 c INNER JOIN dbo.t_PaymentAcceptedCase2 p ON
		c.rf_idCase=p.rf_idCase
				INNER JOIN dbo.t_ReasonDenialPayment r ON
		p.rf_idCase=r.rf_idCase
		AND p.idAkt=r.idAkt              
WHERE p.DateRegistration>@dateStart AND p.DateRegistration<@dateEnd AND p.TypeCheckup=1 AND c.rf_idN013=2

---------------------MEE Дефекты----------------------------------
INSERT #tmpSkrybina(Col51)
SELECT COUNT(DISTINCT c.rf_idCase) AS Col51
FROM #tCases2 c INNER JOIN dbo.t_PaymentAcceptedCase2 p ON
		c.rf_idCase=p.rf_idCase
		--		INNER JOIN #tCaseMEE mee ON
		--c.rf_idCase=mee.rf_idCase              
				INNER JOIN dbo.t_ReasonDenialPayment r ON
		p.rf_idCase=r.rf_idCase
		AND p.idAkt=r.idAkt 
WHERE p.DateRegistration>@dateStart AND p.DateRegistration<@dateEnd AND p.TypeCheckup =2

INSERT #tmpSkrybina(Col52)
SELECT COUNT(DISTINCT c.rf_idCase) AS Col52
FROM #tCases2 c INNER JOIN dbo.t_PaymentAcceptedCase2 p ON
		c.rf_idCase=p.rf_idCase
		--		INNER JOIN #tCaseMEE mee ON
		--c.rf_idCase=mee.rf_idCase
				INNER JOIN dbo.t_ReasonDenialPayment r ON
		p.rf_idCase=r.rf_idCase
		AND p.idAkt=r.idAkt 
WHERE p.DateRegistration>@dateStart AND p.DateRegistration<@dateEnd AND p.TypeCheckup =2 AND c.rf_idN013=2
---------------------EKMP Дефекты----------------------------------
INSERT #tmpSkrybina(Col53)
SELECT COUNT(DISTINCT c.rf_idCase) AS Col53
FROM #tCases2 c INNER JOIN dbo.t_PaymentAcceptedCase2 p ON
		c.rf_idCase=p.rf_idCase
		--		INNER JOIN #tCaseEKMP mee ON
		--c.rf_idCase=mee.rf_idCase
				INNER JOIN dbo.t_ReasonDenialPayment r ON
		p.rf_idCase=r.rf_idCase
		AND p.idAkt=r.idAkt 
WHERE p.DateRegistration>@dateStart AND p.DateRegistration<@dateEnd AND p.TypeCheckup=3

INSERT #tmpSkrybina(Col54)
SELECT COUNT(DISTINCT c.rf_idCase) AS Col54
FROM #tCases2 c INNER JOIN dbo.t_PaymentAcceptedCase2 p ON
		c.rf_idCase=p.rf_idCase
		--		INNER JOIN #tCaseEKMP mee ON
		--c.rf_idCase=mee.rf_idCase
				INNER JOIN dbo.t_ReasonDenialPayment r ON
		p.rf_idCase=r.rf_idCase
		AND p.idAkt=r.idAkt 
WHERE p.DateRegistration>@dateStart AND p.DateRegistration<@dateEnd AND p.TypeCheckup=3 AND c.rf_idN013=2

-------------------------Колонки 65-70----------------------------------

----------------------MEK Дефеты--------------------------------
INSERT #tmpSkrybina(Col65)
SELECT COUNT(DISTINCT r.id) AS Col65
FROM #tCases2 c INNER JOIN dbo.t_PaymentAcceptedCase2 p ON
		c.rf_idCase=p.rf_idCase								
				INNER JOIN dbo.t_ReasonDenialPayment r ON
		p.rf_idCase=r.rf_idCase
		AND p.idAkt=r.idAkt              
WHERE p.DateRegistration>@dateStart AND p.DateRegistration<@dateEnd AND p.TypeCheckup=1  

INSERT #tmpSkrybina(Col66)
SELECT COUNT(DISTINCT r.id) AS Col66
FROM #tCases2 c INNER JOIN dbo.t_PaymentAcceptedCase2 p ON
		c.rf_idCase=p.rf_idCase
				INNER JOIN dbo.t_ReasonDenialPayment r ON
		p.rf_idCase=r.rf_idCase
		AND p.idAkt=r.idAkt              
WHERE p.DateRegistration>@dateStart AND p.DateRegistration<@dateEnd AND p.TypeCheckup=1 AND c.rf_idN013=2
---------------------MEE Дефекты----------------------------------
INSERT #tmpSkrybina(Col67)
SELECT COUNT(r.id) AS Col67
FROM #tCases2 c INNER JOIN dbo.t_PaymentAcceptedCase2 p ON
		c.rf_idCase=p.rf_idCase
		--		INNER JOIN #tCaseMEE mee ON
		--c.rf_idCase=mee.rf_idCase
				INNER JOIN dbo.t_ReasonDenialPayment r ON
		p.rf_idCase=r.rf_idCase
		AND p.idAkt=r.idAkt 
WHERE p.DateRegistration>@dateStart AND p.DateRegistration<@dateEnd AND p.TypeCheckup =2

INSERT #tmpSkrybina(Col68)
SELECT COUNT(DISTINCT c.rf_idCase) AS Col68
FROM #tCases2 c INNER JOIN dbo.t_PaymentAcceptedCase2 p ON
		c.rf_idCase=p.rf_idCase
		--		INNER JOIN #tCaseMEE mee ON
		--c.rf_idCase=mee.rf_idCase
				INNER JOIN dbo.t_ReasonDenialPayment r ON
		p.rf_idCase=r.rf_idCase
		AND p.idAkt=r.idAkt 
WHERE p.DateRegistration>@dateStart AND p.DateRegistration<@dateEnd AND p.TypeCheckup =2 AND c.rf_idN013=2
---------------------EKMP Дефекты----------------------------------
INSERT #tmpSkrybina(Col69)
SELECT COUNT(DISTINCT r.id) AS Col69
FROM #tCases2 c INNER JOIN dbo.t_PaymentAcceptedCase2 p ON
		c.rf_idCase=p.rf_idCase
		--		INNER JOIN #tCaseEKMP mee ON
		--c.rf_idCase=mee.rf_idCase
				INNER JOIN dbo.t_ReasonDenialPayment r ON
		p.rf_idCase=r.rf_idCase
		AND p.idAkt=r.idAkt 
WHERE p.DateRegistration>@dateStart AND p.DateRegistration<@dateEnd AND p.TypeCheckup=3

INSERT #tmpSkrybina(Col70)
SELECT COUNT(DISTINCT r.id) AS Col70
FROM #tCases2 c INNER JOIN dbo.t_PaymentAcceptedCase2 p ON
		c.rf_idCase=p.rf_idCase
		--		INNER JOIN #tCaseEKMP mee ON
		--c.rf_idCase=mee.rf_idCase
				INNER JOIN dbo.t_ReasonDenialPayment r ON
		p.rf_idCase=r.rf_idCase
		AND p.idAkt=r.idAkt 
WHERE p.DateRegistration>@dateStart AND p.DateRegistration<@dateEnd AND p.TypeCheckup=3 AND c.rf_idN013=2

-------------------------Колонки 81-86----------------------------------

----------------------MEK Дефеты--------------------------------
SET @p =''
set @pHim =''

;WITH cte 
AS(
SELECT distinct f.Reason
FROM #tCases2 c INNER JOIN dbo.t_PaymentAcceptedCase2 p ON
		c.rf_idCase=p.rf_idCase								
				INNER JOIN dbo.t_ReasonDenialPayment r ON
		p.rf_idCase=r.rf_idCase
		AND p.idAkt=r.idAkt              
				INNER JOIN oms_nsi.dbo.sprF014 f ON
		r.CodeReason=f.ID              
WHERE p.DateRegistration>@dateStart AND p.DateRegistration<@dateEnd AND p.TypeCheckup=1  
)
SELECT @p=@p+reason+';' FROM cte

UPDATE #tmpSkrybina SET Col81=@p

;WITH cte 
AS(
SELECT DISTINCT f.Reason
FROM #tCases2 c INNER JOIN dbo.t_PaymentAcceptedCase2 p ON
		c.rf_idCase=p.rf_idCase
				INNER JOIN dbo.t_ReasonDenialPayment r ON
		p.rf_idCase=r.rf_idCase
		AND p.idAkt=r.idAkt     
				INNER JOIN oms_nsi.dbo.sprF014 f ON
		r.CodeReason=f.ID         
WHERE p.DateRegistration>@dateStart AND p.DateRegistration<@dateEnd AND p.TypeCheckup=1 AND c.rf_idN013=2
)
SELECT @pHim=@pHim+reason+';' FROM cte

UPDATE #tmpSkrybina SET Col82=@pHim

---------------------MEE Дефекты----------------------------------
SET @p=''
;WITH cte 
AS(
	SELECT DISTINCT f.Reason
	FROM #tCases2 c INNER JOIN dbo.t_PaymentAcceptedCase2 p ON
			c.rf_idCase=p.rf_idCase
			--		INNER JOIN #tCaseMEE mee ON
			--c.rf_idCase=mee.rf_idCase
					INNER JOIN dbo.t_ReasonDenialPayment r ON
			p.rf_idCase=r.rf_idCase
			AND p.idAkt=r.idAkt 
					INNER JOIN oms_nsi.dbo.sprF014 f ON
		r.CodeReason=f.ID 
	WHERE p.DateRegistration>@dateStart AND p.DateRegistration<@dateEnd AND p.TypeCheckup =2
)
SELECT @p=@p+reason+';' FROM cte

UPDATE #tmpSkrybina SET Col83=@p

SET @pHim=''
;WITH cte 
AS(
	SELECT DISTINCT f.Reason
	FROM #tCases2 c INNER JOIN dbo.t_PaymentAcceptedCase2 p ON
			c.rf_idCase=p.rf_idCase
			--		INNER JOIN #tCaseMEE mee ON
			--c.rf_idCase=mee.rf_idCase
					INNER JOIN dbo.t_ReasonDenialPayment r ON
			p.rf_idCase=r.rf_idCase
			AND p.idAkt=r.idAkt 
					INNER JOIN oms_nsi.dbo.sprF014 f ON
		r.CodeReason=f.ID 
	WHERE p.DateRegistration>@dateStart AND p.DateRegistration<@dateEnd AND p.TypeCheckup =2 AND c.rf_idN013=2
)
SELECT @pHim=@pHim+reason+';' FROM cte

UPDATE #tmpSkrybina SET Col84=@pHim
---------------------EKMP Дефекты----------------------------------
SET @p=''
;WITH cte 
AS(
	SELECT DISTINCT f.Reason
	FROM #tCases2 c INNER JOIN dbo.t_PaymentAcceptedCase2 p ON
			c.rf_idCase=p.rf_idCase
			--		INNER JOIN #tCaseEKMP mee ON
			--c.rf_idCase=mee.rf_idCase
					INNER JOIN dbo.t_ReasonDenialPayment r ON
			p.rf_idCase=r.rf_idCase
			AND p.idAkt=r.idAkt 
					INNER JOIN oms_nsi.dbo.sprF014 f ON
		r.CodeReason=f.ID 
	WHERE p.DateRegistration>@dateStart AND p.DateRegistration<@dateEnd AND p.TypeCheckup=3
)
SELECT @p=@p+reason+';' FROM cte

UPDATE #tmpSkrybina SET Col85=@p

SET @pHim=''
;WITH cte 
AS(
	SELECT DISTINCT f.Reason
	FROM #tCases2 c INNER JOIN dbo.t_PaymentAcceptedCase2 p ON
			c.rf_idCase=p.rf_idCase
			--		INNER JOIN #tCaseEKMP mee ON
			--c.rf_idCase=mee.rf_idCase
					INNER JOIN dbo.t_ReasonDenialPayment r ON
			p.rf_idCase=r.rf_idCase
			AND p.idAkt=r.idAkt 
					INNER JOIN oms_nsi.dbo.sprF014 f ON
		r.CodeReason=f.ID 
	WHERE p.DateRegistration>@dateStart AND p.DateRegistration<@dateEnd AND p.TypeCheckup=3 AND c.rf_idN013=2
)
SELECT @pHim=@pHim+reason+';' FROM cte

UPDATE #tmpSkrybina SET Col86=@pHim

SELECT SUM(Col33) Col33,SUM(Col34) Col34,SUM(Col35) Col35,SUM(Col36) Col36,SUM(Col37) Col37,SUM(Col38) Col38,
		SUM(Col49) Col49,SUM(Col50) Col50,SUM(Col51) Col51, SUM(Col52) Col52,SUM(Col53) Col53,SUM(Col54) Col54,
		SUM(Col65) Col65,SUM(Col66) Col66,SUM(Col67) Col67, SUM(Col68) Col68,SUM(Col69) Col69,SUM(Col70) Col70,
		Col81,Col82,Col83,Col84,Col85,Col86
FROM #tmpSkrybina
GROUP BY Col81,Col82,Col83,Col84,Col85,Col86


GO
DROP TABLE #tCases
go
DROP TABLE #tCases2
go
DROP TABLE #tD
GO
--DROP TABLE #tCaseMEE
--GO
--DROP TABLE #tCaseEKMP
GO
DROP TABLE #tmpSkrybina
GO 
DROP TABLE #tmpKolesov
go
DROP TABLE #F014
go
DROP TABLE #tKSG
