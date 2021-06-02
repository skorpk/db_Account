USE AccountOMSReports
GO
alter PROCEDURE usp_selectReport_ShymeikoOnkologia
		@codeSMO CHAR(5),
		@dateStart DATETIME,
		@dateEnd DATETIME,
		@dateEndRAK DATETIME,
		@reportYearStart SMALLINT,
		@reportYearEnd SMALLINT,
		@reportMonthStart TINYINT,
		@reportMonthEnd TINYINT
as
DECLARE @startPeriod INT=CAST(CAST(@reportYearStart AS VARCHAR(4))+RIGHT('0'+CAST(@reportMonthStart AS VARCHAR(2)),2) AS INT),
		@endPeriod int=CAST(CAST(@reportYearEnd AS VARCHAR(4))+RIGHT('0'+CAST(@reportMonthEnd AS VARCHAR(2)),2) AS INT)

declare	@dateStart1 DATE,
		@dateEnd1 DATE
	

set @dateStart1=CAST(@reportYearStart AS CHAR(4))+RIGHT('0'+CAST(@reportMonthStart AS VARCHAR(2)),2)+'01'
set	@dateEnd1=DATEADD(MONTH,1,CAST((CAST(@reportYearEnd AS CHAR(4))+RIGHT('0'+CAST(@reportMonthEnd AS VARCHAR(2)),2)+'01') AS DATE))
SELECT distinct DiagnosisCode INTO #tD FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'D0_' OR MainDS LIKE 'C__'	
AND MainDS NOT IN('C80','C81','C82','C83','C84','C85','C86','C88','C90', 'C91','C92','C93','C94','C95','C96')

CREATE UNIQUE CLUSTERED INDEX IX_tmp ON #tD(DiagnosisCode)

SET STATISTICS TIME ON

SELECT c.id AS rf_idCase,r.id AS rf_idRecordCasePatient, c.AmountPayment,c.AmountPayment AS AmountPay, 0 as rf_idN013
			,a.rf_idSMO AS CodeSMO,c.rf_idV002
INTO #tmpPeople
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
			AND d.TypeDiagnosis=1					
			--		left JOIN dbo.t_ONK_USL u ON
			--c.id=u.rf_idCase                  
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYearMonth>=@startPeriod AND a.ReportYearMonth<=@endPeriod AND a.rf_idSMO=@codeSMo AND c.rf_idV006<4	
		and c.DateEnd>=@dateStart1 AND c.DateEnd<@dateEnd1 

PRINT('--------------------------------------------------------------------')
INSERT #tmpPeople (rf_idCase,rf_idRecordCasePatient,AmountPayment,AmountPay,rf_idN013,CodeSMO,rf_idV002) 
SELECT c.id AS rf_idCase,r.id AS rf_idRecordCasePatient, cc.AmountPayment, cc.AmountPayment AS AmountPay, 0 AS rf_idN013
			,a.rf_idSMO AS CodeSMO,c.rf_idV002
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
				INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient						
					INNER JOIN dbo.t_Case c  ON
			r.id=c.rf_idRecordCasePatient													     																   					  					      
					INNER JOIN t_DS_ONK_REAB dd ON
			c.id=dd.rf_idCase 	
			--		left JOIN dbo.t_ONK_USL u ON
			--c.id=u.rf_idCase				               
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYearMonth>=@startPeriod AND a.ReportYearMonth<=@endPeriod AND dd.DS_ONK=1 AND a.rf_idSMO=@codeSMO
	  AND c.rf_idV006<4  and c.DateEnd>=@dateStart1 AND c.DateEnd<@dateEnd1

PRINT('--------------------------------------------------------------------')
UPDATE p SET rf_idN013=2
FROM #tmpPeople p INNER JOIN dbo.t_ONK_USL u ON
		p.rf_idCase=u.rf_idCase
WHERE u.rf_idN013=2
PRINT('--------------------------------------------------------------------')

UPDATE p SET p.AmountPay=p.AmountPayment-r.AmountDeduction
FROM #tmpPeople p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.TypeCheckup=1 and c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndRAK
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

PRINT('--------------------------------------------------------------------')
------------------------------1----------------------------
SELECT 1 AS ColName, 'Случаи по профилю онкология всего ' AS Col1,COUNT(c.rf_idCase) AS Col3,COUNT(DISTINCT r.rf_idCase) AS Col4,0 AS Col5,'' AS Col6,SUM(c.AmountPayment) AS Col7, SUM(c.AmountPay) AS Col8,SUM(c.AmountPayment)-SUM(c.AmountPay) AS Col9
INTO #tCases
from #tmpPeople	c LEFT JOIN dbo.t_PaymentAcceptedCase2 p ON
		c.rf_idCase=p.rf_idCase
				  LEFT JOIN dbo.t_ReasonDenialPayment r ON
		p.rf_idCase=r.rf_idCase
		AND p.idAkt=r.idAkt
WHERE AmountPay>0
UNION ALL
-----------------------------1.1-----------------------------
SELECT 2 ,'в т.ч. случаи лечения ХТ',COUNT(distinct c.rf_idCase) AS Col3,COUNT(DISTINCT r.rf_idCase) AS Col4,0 AS Col5,'' AS Col6,SUM(c.AmountPayment) AS Col7, SUM(c.AmountPay) AS Col8,SUM(c.AmountPayment)-SUM(c.AmountPay) AS Col9
from #tmpPeople	c LEFT JOIN dbo.t_PaymentAcceptedCase2 p ON
		c.rf_idCase=p.rf_idCase
				  LEFT JOIN dbo.t_ReasonDenialPayment r ON
		p.rf_idCase=r.rf_idCase
		AND p.idAkt=r.idAkt
WHERE AmountPay>0 AND rf_idN013=2
UNION all
-----------------------------2------------------------------
SELECT 3,'Проведено контрольно - экспертных мероприятий  по случаям с профилем онкология всего ',COUNT(DISTINCT c.rf_idCase) AS Col3,COUNT(DISTINCT r.rf_idCase) AS Col4,COUNT(r.id) AS Col5,isnull(RTRIM(f14.Reason),'')  AS Col6,0.0 AS Col7, 0.0 AS Col8,SUM(p.AmountDeduction) AS Col9
from #tmpPeople	c INNER JOIN dbo.t_PaymentAcceptedCase2 p ON
		c.rf_idCase=p.rf_idCase
				  LEFT JOIN dbo.t_ReasonDenialPayment r ON
		p.rf_idCase=r.rf_idCase
		AND p.idAkt=r.idAkt
					LEFT JOIN oms_NSI.dbo.sprF014 f14 ON
		r.CodeReason=f14.ID  
GROUP BY f14.Reason		                
-----------------------------2.1------------------------------
UNION all
SELECT 4,'МЭК',COUNT(DISTINCT c.rf_idCase) AS Col3,COUNT(DISTINCT r.rf_idCase) AS Col4,COUNT(r.id) AS Col5,isnull(RTRIM(f14.Reason),'')  AS Col6,0.0 AS Col7, 0.0 AS Col8,SUM(p.AmountDeduction) AS Col9
from #tmpPeople	c INNER JOIN dbo.t_PaymentAcceptedCase2 p ON
		c.rf_idCase=p.rf_idCase
				  LEFT JOIN dbo.t_ReasonDenialPayment r ON
		p.rf_idCase=r.rf_idCase
		AND p.idAkt=r.idAkt
				LEFT JOIN oms_NSI.dbo.sprF014 f14 ON
		r.CodeReason=f14.ID   					           
WHERE TypeCheckup=1	  GROUP BY f14.Reason
UNION all
-----------------------------2.2------------------------------
SELECT 5,'МЭЭ',COUNT(DISTINCT c.rf_idCase) AS Col3,COUNT(DISTINCT r.rf_idCase) AS Col4,COUNT(r.id) AS Col5, isnull(RTRIM(f14.Reason),'')  AS Col6,0.0 AS Col7, 0.0 AS Col8,SUM(p.AmountDeduction) AS Col9
from #tmpPeople	c INNER JOIN dbo.t_PaymentAcceptedCase2 p ON
		c.rf_idCase=p.rf_idCase
				  LEFT JOIN dbo.t_ReasonDenialPayment r ON
		p.rf_idCase=r.rf_idCase
		AND p.idAkt=r.idAkt
				LEFT JOIN oms_NSI.dbo.sprF014 f14 ON
		r.CodeReason=f14.ID   
WHERE TypeCheckup=2	  GROUP BY Reason
UNION all
-----------------------------2.3------------------------------
SELECT 6,'ЭКМП', COUNT(DISTINCT c.rf_idCase) AS Col3,COUNT(DISTINCT r.rf_idCase) AS Col4,COUNT(r.id) AS Col5,isnull(RTRIM(f14.Reason),'')  AS Col6,0.0 AS Col7, 0.0 AS Col8,SUM(p.AmountDeduction) AS Col9
from #tmpPeople	c INNER JOIN dbo.t_PaymentAcceptedCase2 p ON
		c.rf_idCase=p.rf_idCase
				  LEFT JOIN dbo.t_ReasonDenialPayment r ON
		p.rf_idCase=r.rf_idCase
		AND p.idAkt=r.idAkt
				LEFT JOIN oms_NSI.dbo.sprF014 f14 ON
		r.CodeReason=f14.ID    
WHERE TypeCheckup=3	 GROUP BY Reason
UNION all
-----------------------------3------------------------------
SELECT 7,'Из них по случаям при проведениии ХТ всего',COUNT(DISTINCT c.rf_idCase) AS Col3,COUNT(DISTINCT r.rf_idCase) AS Col4,COUNT(r.id) AS Col5,isnull(RTRIM(f14.Reason),'')  AS Col6,0.0 AS Col7, 0.0 AS Col8,SUM(p.AmountDeduction) AS Col9
from #tmpPeople	c INNER JOIN dbo.t_PaymentAcceptedCase2 p ON
		c.rf_idCase=p.rf_idCase
				  LEFT JOIN dbo.t_ReasonDenialPayment r ON
		p.rf_idCase=r.rf_idCase
		AND p.idAkt=r.idAkt
				LEFT JOIN oms_NSI.dbo.sprF014 f14 ON
		r.CodeReason=f14.ID   
WHERE rf_idN013=2
GROUP BY Reason
UNION all
-----------------------------3.1------------------------------
SELECT 8,'МЭЭ',COUNT(DISTINCT c.rf_idCase) AS Col3,COUNT(DISTINCT r.rf_idCase) AS Col4,COUNT(r.id) AS Col5,isnull(RTRIM(f14.Reason),'')  AS Col6,0.0 AS Col7, 0.0 AS Col8,SUM(p.AmountDeduction) AS Col9
from #tmpPeople	c INNER JOIN dbo.t_PaymentAcceptedCase2 p ON
		c.rf_idCase=p.rf_idCase
				  LEFT JOIN dbo.t_ReasonDenialPayment r ON
		p.rf_idCase=r.rf_idCase
		AND p.idAkt=r.idAkt
					LEFT JOIN oms_NSI.dbo.sprF014 f14 ON
		r.CodeReason=f14.ID   
WHERE TypeCheckup=2 AND rf_idN013=2
GROUP BY Reason
UNION all
-----------------------------3.2------------------------------
SELECT 9,'ЭКМП',COUNT(DISTINCT c.rf_idCase) AS Col3,COUNT(DISTINCT r.rf_idCase) AS Col4,COUNT(r.id) AS Col5,isnull(RTRIM(f14.Reason),'') AS Col6,0.0 AS Col7, 0.0 AS Col8,SUM(p.AmountDeduction) AS Col9
from #tmpPeople	c INNER JOIN dbo.t_PaymentAcceptedCase2 p ON
		c.rf_idCase=p.rf_idCase
				  LEFT JOIN dbo.t_ReasonDenialPayment r ON
		p.rf_idCase=r.rf_idCase
		AND p.idAkt=r.idAkt
				LEFT JOIN oms_NSI.dbo.sprF014 f14 ON
		r.CodeReason=f14.ID   
WHERE TypeCheckup=3	AND rf_idN013=2
GROUP BY Reason


SELECT ColName,Col1,SUM(Col3),SUM(Col4),SUM(col5),( select Col6+';' as 'data()' from #tCases t2 where t1.ColName=t2.ColName for xml path('') ) AS Col6,SUM(col7),SUM(col8),SUM(col9)
FROM #tCases t1
GROUP BY ColName,Col1
ORDER BY ColName

DROP TABLE #tmpPeople

DROP TABLE #tD

DROP TABLE #tCases
go