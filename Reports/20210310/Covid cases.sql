USE AccountOMS
GO
DECLARE @dateStart DATETIME='20200101',
		@dateEnd DATETIME='20210116',
		@dateEndPay DATETIME='20210119'

CREATE TABLE #tDiag(DiagnosisCode CHAR(5))
INSERT #tDiag VALUES('U07.1'),('U07.2')

SELECT DISTINCT c.id AS rf_idCase,cc.id AS rf_idCompletedCase, f.CodeM, cc.AmountPayment, cc.AmountPayment AS AmmPay,ENP,c.rf_idV006 AS USL_OK,a.Letter,a.rf_idSMO AS CodeSMO
,CASE WHEN d.TypeDiagnosis=3 AND d.DiagnosisCode ='U07.1' THEN d.DiagnosisCode ELSE NULL END AS DS2
INTO #tCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO ps ON
            r.id=ps.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient	
					INNER JOIN dbo.t_Diagnosis d ON
			c.id=d.rf_idCase					
					JOIN #tDiag dd ON
            d.DiagnosisCode=dd.DiagnosisCode
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2020 AND d.TypeDiagnosis IN(1,3) 

		
UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndPay
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

DELETE FROM #tCases WHERE (CASE WHEN AmmPay>0.0 AND AmountPayment=0.0 THEN 1 WHEN AmmPay=0.0 AND AmountPayment<0.0 THEN 1 ELSE 0 END)=1


/*
SELECT ROW_NUMBER() OVER(PARTITION BY p.Fam,p.im,p.ot, p.BirthDay ORDER BY c1.DateEnd ) AS idRow, f.CodeM,a.Account,a.DateRegister,a.Letter,cc.idRecordCase AS NumCase,a.rf_idSMO AS CodeSMO,
c.rf_idCompletedCase, cc.id AS rf_idCase,c.ENP,p.Fam,p.im,p.ot, p.BirthDay,d.NumberDocument,d.SNILS,c1.DateEnd,c1.DateBegin,p.rf_idV005,cc.rf_idV006 AS USL_OK
INTO #Total
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO ps ON
            r.id=ps.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case cc ON
			r.id=cc.rf_idRecordCasePatient
			INNER JOIN dbo.t_CompletedCase c1 ON
			r.id=c1.rf_idRecordCasePatient
					INNER join #tCases c ON
			cc.id=c.rf_idCase           
					INNER JOIN dbo.t_RegisterPatient p ON
			r.id=p.rf_idRecordCase
					LEFT JOIN t_RegisterPatientDocument d ON
			p.id=d.rf_idRegisterPatient

SELECT * FROM #t WHERE idRow>1 AND CodeSMO='34'
SELECT COUNT(DISTINCT ENP)
FROM #t t JOIN PolicyRegister.dbo.temp2_2 p ON
		t.ENP=p.F17

BEGIN TRANSACTION
UPDATE p SET p.ENP_Account=t.enp
FROM #t t JOIN PolicyRegister.dbo.temp2_2 p ON
		t.Fam=p.FAm
		AND t.Im=p.IM
		AND ISNULL(t.ot,'bla')=ISNULL(p.ot,'bla')
		AND t.BirthDay=p.BirthDate
WHERE p.F17 IS NULL AND t.CodeSMO='34' and idRow=1
commit
*/
--SELECT COUNT(DISTINCT rf_idCompletedCase),COUNT(DISTINCT ENP) FROM #tCases WHERE USL_OK=1

--SELECT COUNT(DISTINCT rf_idCompletedCase),COUNT(DISTINCT ENP) FROM #tCases c JOIN PolicyRegister.dbo.temp2_2 t ON c.ENP=t.F17 WHERE USL_OK=1


/*
CREATE TABLE #Total(ColName TINYINT,col2 INT NOT NULL DEFAULT 0,col3 INT NOT NULL DEFAULT 0,col4 DECIMAL(15,2) NOT NULL DEFAULT 0.0,col5 DECIMAL(15,2) NOT NULL DEFAULT 0.0
				,col6 INT NOT NULL DEFAULT 0,col7 INT NOT NULL DEFAULT 0,col8 DECIMAL(15,2) NOT NULL DEFAULT 0.0,col9 DECIMAL(15,2) NOT NULL DEFAULT 0.0
				,col10 INT NOT NULL DEFAULT 0,col11 INT NOT NULL DEFAULT 0,col12 DECIMAL(15,2) NOT NULL DEFAULT 0.0,col13 DECIMAL(15,2) NOT NULL DEFAULT 0.0)

INSERT #total(ColName,Col2,Col4)
SELECT 3,COUNT(DISTINCT c.rf_idCompletedCase) AS Col2,ISNULL(SUM(c.AmountPayment),0.0) 
FROM (SELECT DISTINCT ENP,CodeM,rf_idCompletedCase,AmountPayment,Letter,USL_OK from #tCases WHERE CodeSMO<>'34') c JOIN PolicyRegister.dbo.temp2_2 t ON
		c.enp=t.F17
			  JOIN vw_sprT001 l ON
        c.CodeM=l.CodeM
WHERE c.USL_OK=3 AND (((ISNULL(l.pfa,0)=1 OR ISNULL(l.pfv,0)=1) AND c.Letter<>'A') OR (ISNULL(l.pfa,0)=0 and ISNULL(l.pfv,0)=0) )

INSERT #total(ColName,Col2,Col4)
SELECT 4,COUNT(DISTINCT c.rf_idCompletedCase) AS Col2,ISNULL(SUM(c.AmountPayment),0.0) AS Col4
FROM (SELECT DISTINCT ENP,CodeM,rf_idCompletedCase,AmountPayment,Letter,USL_OK from #tCases WHERE CodeSMO<>'34') c JOIN PolicyRegister.dbo.temp2_2 t ON
		c.enp=t.F17			 
WHERE c.USL_OK=4 AND c.AmountPayment>0.0

INSERT #total(ColName,Col2,Col4)
SELECT 5,COUNT(DISTINCT c.rf_idCompletedCase) AS Col2,ISNULL(SUM(c.AmountPayment),0.0) 
FROM (SELECT DISTINCT ENP,CodeM,rf_idCompletedCase,AmountPayment,Letter,USL_OK from #tCases WHERE CodeSMO<>'34') c JOIN PolicyRegister.dbo.temp2_2 t ON
		c.enp=t.F17
			  JOIN vw_sprT001 l ON
        c.CodeM=l.CodeM
WHERE c.USL_OK=1 AND ISNULL(l.pfv,0)<>1
---------------------------Иногородние
INSERT #total(ColName,Col2,Col4)
SELECT 7,COUNT(DISTINCT c.rf_idCompletedCase) AS Col2,ISNULL(SUM(c.AmountPayment),0.0) 
FROM (SELECT DISTINCT ENP,CodeM,rf_idCompletedCase,AmountPayment,Letter,USL_OK from #tCases WHERE CodeSMO='34') c JOIN PolicyRegister.dbo.temp2_2 t ON
		c.enp=t.F17			 
WHERE c.USL_OK=3 

INSERT #total(ColName,Col2,Col4)
SELECT 8,COUNT(DISTINCT c.rf_idCompletedCase) AS Col2,ISNULL(SUM(c.AmountPayment),0.0) 
FROM (SELECT DISTINCT ENP,CodeM,rf_idCompletedCase,AmountPayment,Letter,USL_OK from #tCases WHERE CodeSMO='34') c JOIN PolicyRegister.dbo.temp2_2 t ON
		c.enp=t.F17			 
WHERE c.USL_OK=4

INSERT #total(ColName,Col2,Col4)
SELECT 9,COUNT(DISTINCT c.rf_idCompletedCase) AS Col2,ISNULL(SUM(c.AmountPayment),0.0) 
FROM (SELECT DISTINCT ENP,CodeM,rf_idCompletedCase,AmountPayment,Letter,USL_OK from #tCases WHERE CodeSMO='34') c JOIN PolicyRegister.dbo.temp2_2 t ON
		c.enp=t.F17			 
WHERE c.USL_OK=1 
--------------------------------------------------------------------------------------------
INSERT #Total(ColName,Col3,Col5)
SELECT 3,COUNT(DISTINCT c.rf_idCompletedCase) AS Col3,ISNULL(SUM(c.AmountPayment),0.0)
FROM (SELECT DISTINCT ENP,CodeM,rf_idCompletedCase,AmountPayment,Letter,USL_OK from #tCases WHERE CodeSMO<>'34') c JOIN PolicyRegister.dbo.temp2_2 t ON
		c.enp=t.F17
			  JOIN vw_sprT001 l ON
        c.CodeM=l.CodeM
WHERE c.USL_OK=3 AND ((ISNULL(l.pfa,0)=1 OR ISNULL(l.pfv,0)=1) AND c.Letter='A') 

INSERT #Total(ColName,Col3,Col5)
SELECT 4,COUNT(DISTINCT c.rf_idCompletedCase) AS Col3,ISNULL(SUM(c.AmountPayment),0.0)
FROM (SELECT DISTINCT ENP,CodeM,rf_idCompletedCase,AmountPayment,Letter,USL_OK from #tCases WHERE CodeSMO<>'34') c JOIN PolicyRegister.dbo.temp2_2 t ON
		c.enp=t.F17			  
WHERE c.USL_OK=4 AND c.AmountPayment=0.0

INSERT #Total(ColName,Col3,Col5)
SELECT 5,COUNT(DISTINCT c.rf_idCompletedCase) AS Col3,ISNULL(SUM(c.AmountPayment),0.0)
FROM (SELECT DISTINCT ENP,CodeM,rf_idCompletedCase,AmountPayment,Letter,USL_OK from #tCases WHERE CodeSMO<>'34') c JOIN PolicyRegister.dbo.temp2_2 t ON
		c.enp=t.F17
			  JOIN vw_sprT001 l ON
        c.CodeM=l.CodeM
WHERE c.USL_OK=1 AND ISNULL(l.pfv,0)=1
------------------------------------------------------------------------------------------------------
-----------------------------------Раздел с 10-13------------------
INSERT #total(ColName,Col10,Col12)
SELECT 3,COUNT(DISTINCT c.rf_idCompletedCase) AS Col2,ISNULL(SUM(c.AmountPayment),0.0) 
FROM (SELECT DISTINCT ENP,CodeM,rf_idCompletedCase,AmountPayment,Letter,USL_OK from #tCases WHERE CodeSMO<>'34') c 
			  JOIN vw_sprT001 l ON
        c.CodeM=l.CodeM
WHERE c.USL_OK=3 AND (((ISNULL(l.pfa,0)=1 OR ISNULL(l.pfv,0)=1) AND c.Letter<>'A') OR (ISNULL(l.pfa,0)=0 and ISNULL(l.pfv,0)=0) )
	AND NOT EXISTS(SELECT 1 FROM PolicyRegister.dbo.temp2_2 t where	c.enp=t.F17)

INSERT #total(ColName,Col10,Col12)
SELECT 4,COUNT(DISTINCT c.rf_idCompletedCase) AS Col2,ISNULL(SUM(c.AmountPayment),0.0) 
FROM (SELECT DISTINCT ENP,CodeM,rf_idCompletedCase,AmountPayment,Letter,USL_OK from #tCases WHERE CodeSMO<>'34') c 
WHERE c.USL_OK=4 AND c.AmountPayment>0.0 
			AND NOT EXISTS(SELECT 1 FROM PolicyRegister.dbo.temp2_2 t where	c.enp=t.F17)

INSERT #total(ColName,Col10,Col12)
SELECT 5,COUNT(DISTINCT c.rf_idCompletedCase) AS Col2,ISNULL(SUM(c.AmountPayment),0.0) 
FROM (SELECT DISTINCT ENP,CodeM,rf_idCompletedCase,AmountPayment,Letter,USL_OK from #tCases WHERE CodeSMO<>'34') c 
			  JOIN vw_sprT001 l ON
        c.CodeM=l.CodeM
WHERE c.USL_OK=1 AND ISNULL(l.pfv,0)<>1 
		AND NOT EXISTS(SELECT 1 FROM PolicyRegister.dbo.temp2_2 t where	c.enp=t.F17)
---------------------------Иногородние---------------------------------------
INSERT #total(ColName,Col10,Col12)
SELECT 7,COUNT(DISTINCT c.rf_idCompletedCase) AS Col2,ISNULL(SUM(c.AmountPayment),0.0) 
FROM (SELECT DISTINCT ENP,CodeM,rf_idCompletedCase,AmountPayment,Letter,USL_OK from #tCases WHERE CodeSMO='34') c
WHERE c.USL_OK=3 AND NOT EXISTS(SELECT 1 FROM PolicyRegister.dbo.temp2_2 t WHERE c.enp=t.F17)

INSERT #total(ColName,Col10,Col12)
SELECT 8,COUNT(DISTINCT c.rf_idCompletedCase) AS Col2,ISNULL(SUM(c.AmountPayment),0.0) 
FROM (SELECT DISTINCT ENP,CodeM,rf_idCompletedCase,AmountPayment,Letter,USL_OK from #tCases WHERE CodeSMO='34') c 
WHERE c.USL_OK=4 AND NOT EXISTS(SELECT 1 FROM PolicyRegister.dbo.temp2_2 t where	c.enp=t.F17)

INSERT #total(ColName,Col10,Col12)
SELECT 9,COUNT(DISTINCT c.rf_idCompletedCase) AS Col2,ISNULL(SUM(c.AmountPayment),0.0) 
FROM (SELECT DISTINCT ENP,CodeM,rf_idCompletedCase,AmountPayment,Letter,USL_OK from #tCases WHERE CodeSMO='34') c 
WHERE c.USL_OK=1 AND NOT EXISTS(SELECT 1 FROM PolicyRegister.dbo.temp2_2 t where	c.enp=t.F17)
--------------------------------------------------------------------------------------------
INSERT #total(ColName,Col11,Col13)
SELECT 3,COUNT(DISTINCT c.rf_idCompletedCase) AS Col3,ISNULL(SUM(c.AmountPayment),0.0)
FROM (SELECT DISTINCT ENP,CodeM,rf_idCompletedCase,AmountPayment,Letter,USL_OK from #tCases WHERE CodeSMO<>'34') c 
			  JOIN vw_sprT001 l ON
        c.CodeM=l.CodeM
WHERE c.USL_OK=3 AND ((ISNULL(l.pfa,0)=1 OR ISNULL(l.pfv,0)=1) AND c.Letter='A') 
AND NOT EXISTS(SELECT 1 FROM PolicyRegister.dbo.temp2_2 t where	c.enp=t.F17)

INSERT #total(ColName,Col11,Col13)
SELECT 4,COUNT(DISTINCT c.rf_idCompletedCase) AS Col3,ISNULL(SUM(c.AmountPayment),0.0)
FROM (SELECT DISTINCT ENP,CodeM,rf_idCompletedCase,AmountPayment,Letter,USL_OK from #tCases WHERE CodeSMO<>'34') c 
WHERE c.USL_OK=4 AND c.AmountPayment=0.0 AND NOT EXISTS(SELECT 1 FROM PolicyRegister.dbo.temp2_2 t where	c.enp=t.F17)

INSERT #total(ColName,Col11,Col13)
SELECT 5,COUNT(DISTINCT c.rf_idCompletedCase) AS Col3,ISNULL(SUM(c.AmountPayment),0.0)
FROM (SELECT DISTINCT ENP,CodeM,rf_idCompletedCase,AmountPayment,Letter,USL_OK from #tCases WHERE CodeSMO<>'34') c 
			  JOIN vw_sprT001 l ON
        c.CodeM=l.CodeM
WHERE c.USL_OK=1 AND ISNULL(l.pfv,0)=1 AND NOT EXISTS(SELECT 1 FROM PolicyRegister.dbo.temp2_2 t where	c.enp=t.F17)

SELECT ColName,SUM(Col2) AS Col2, SUM(Col3) AS Col3, cast(SUM(Col4) as money) AS Col4, cast(SUM(Col5) as money) AS Col5
			  ,SUM(Col6)  AS Col6, SUM(Col7)  AS Col7, cast(SUM(Col8) as money) AS Col8, cast(SUM(Col9) as money) AS Col9
			  ,SUM(Col10) AS Col10,SUM(Col11) AS Col11,cast(SUM(Col12)as money) AS Col12,cast(SUM(Col13)as money)  AS Col13
FROM #Total
GROUP BY ColName
*/
-----сведения для аналитики----------------------------

SELECT c.rf_idCase,cc.rf_idRecordCasePatient, f.CodeM,a.Account,a.DateRegister AS DateAccount,cc.idRecordCase,c.ENP,cc.DateBegin
,cc.DateEnd,CAST(c.AmountPayment AS MONEY) AS AmountPayment,v6.name AS V006, 1 AS TypeQuery
,p.Fam+' '+ ISNULL(p.im,'')+' '+ISNULL(p.ot,'') AS FIO, p.BirthDay,d.SNILS,r.rf_idF008,r.NumberPolis,cc.rf_idV009 AS RSLT,cc.rf_idV012 AS ISHOD,c.DS2
,case when [rf_idV005]=(1) then 'М' else 'Ж' END AS Sex
INTO #tTotal
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO ps ON
            r.id=ps.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case cc ON
			r.id=cc.rf_idRecordCasePatient
					JOIN vw_sprV006 v6 ON
             cc.rf_idV006=v6.id
					INNER join #tCases c ON
			cc.id=c.rf_idCase           
					INNER JOIN dbo.vw_RegisterPatient p ON
			r.id=p.rf_idRecordCase
					LEFT JOIN t_RegisterPatientDocument d ON
			p.id=d.rf_idRegisterPatient
WHERE NOT EXISTS(SELECT 1 FROM PolicyRegister.dbo.temp2_2 cr WHERE cr.F17=c.ENP)

DROP TABLE tmpCovidCases 

SELECT DISTINCT l.CodeM,l.filialCode ,t.CodeM+' - '+l.NAMES AS LPU, t.Account,t.DateAccount,t.idRecordCase,t.DateBegin,t.DateEnd,t.AmountPayment,t.V006
,t.FIO,t.BirthDay,t.Sex,ISNULL(t.SNILS,'') AS SNILS,t.ENP,tt.Name AS TypePolis,t.NumberPolis,d.DS1,t.DS2,v9.name AS RSLT,v12.name AS ISHOD
INTO tmpCovidCases
FROM #tTotal t INNER JOIN dbo.vw_Diagnosis d ON
		t.rf_idCase=d.rf_idCase
				INNER JOIN dbo.vw_sprT001 l ON
        t.CodeM=l.CodeM
				INNER JOIN oms_nsi.dbo.sprInsuranceFactDocumentType tt ON
        t.rf_idF008=tt.Id
				INNER JOIN dbo.vw_sprV009 v9 ON
        t.RSLT=v9.id
				INNER JOIN dbo.vw_sprV012 v12 ON
        t.ISHOD=v12.id

DROP TABLE tmp_FileCovid

SELECT distinct Codem,filialCode INTO tmp_FileCovid FROM dbo.tmpCovidCases
GO
DROP TABLE #tDiag
GO
DROP TABLE #tCases
GO
DROP TABLE #tTotal