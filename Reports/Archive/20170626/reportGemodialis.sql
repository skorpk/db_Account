USE AccountOMS
GO
DECLARE @dtBegin DATETIME='20160101',	
		@dtEndReg DATETIME='20170120 23:59:59',
		@dtEndRegRAK DATETIME='20170626 23:59:59',
		@reportYear SMALLINT=2016,
		@reportMonth TINYINT=12

SELECT *
INTO #csg
FROM (
		SELECT code
		FROM dbo.vw_sprCSG WHERE code LIKE '____91[6-8]'
		UNION ALL
		SELECT code
		FROM dbo.vw_sprCSG WHERE code LIKE '____90[125]'
	) t
				
SELECT f.CodeM,c.id AS rf_idCase,c.AmountPayment,pc.IDPeople--,rp.FAM+ISNULL(rp.im,'')+CAST(rp.BirthDay AS VARCHAR(10)) AS FIO
INTO #tmp
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts							
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase		
					INNER JOIN #csg cs  ON
			m.MES=cs.code                  
					inner JOIN dbo.t_People_Case pc ON
			c.id=pc.rf_idCase       
			--		INNER JOIN dbo.vw_RegisterPatient rp ON
			--f.id=rp.rf_idFiles
			--AND r.id=rp.rf_idRecordCase           
WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<=@dtEndReg AND a.ReportYear=@reportYear AND a.ReportMonth<=@reportMonth 
	AND a.rf_idSMO IN('34007','34006','34002','34001') 	 AND c.rf_idV006 IN(1,2)


UPDATE c SET c.AmountPayment=c.AmountPayment-p.AmountDeduction
from #tmp c INNER JOIN ( SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
						 FROM ExchangeFinancing.dbo.t_AFileIn f INNER JOIN  ExchangeFinancing.dbo.t_DocumentOfCheckup d ON
														f.id=d.rf_idAFile
																	INNER JOIN ExchangeFinancing.dbo.t_CheckedAccount a ON
														d.id=a.rf_idDocumentOfCheckup
															INNER JOIN ExchangeFinancing.dbo.t_CheckedCase c ON
														a.id=c.rf_idCheckedAccount
															INNER JOIN #tmp cc ON
														c.rf_idCase=cc.rf_idCase 																							
								WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<=@dtEndRegRAK
								GROUP BY c.rf_idCase 
							) p ON
			c.rf_idCase=p.rf_idCase 

;WITH cteMU
AS
(
SELECT COUNT(DISTINCT IDPeople) AS TotalPeople,0 AS MU, SUM(t.AmountPayment) AS AmountPayment
FROM #tmp t 
WHERE t.AmountPayment>0
UNION ALL
SELECT 0 AS TotalPeople,SUM(m.Quantity) AS MU, 0.0 AS AmountPayment
FROM #tmp t INNER JOIN dbo.t_Meduslugi m ON
		t.rf_idCase=m.rf_idCase
			INNER JOIN (VALUES('A18.05.002'),('A18.05.002.001'),('A18.05.002.002'),('A18.05.002.003'),('A18.05.002.005')) v(MUSurgery) ON
		m.MUSurgery=v.MUSurgery           
WHERE t.AmountPayment>0
)
SELECT 2016,SUM(TotalPeople) ,SUM(MU) ,SUM(AmountPayment) FROM cteMU

go			   
DROP TABLE #tmp
DROP TABLE #csg