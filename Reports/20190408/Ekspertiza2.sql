USE AccountOMS
GO
DECLARE @dateStart DATETIME='20190101',
		@dateEnd DATETIME=GETDATE(),
		@dateEndPay DATETIME=GETDATE(),
		@reportYear SMALLINT=2019,
		@reportMonth TINYINT=1

CREATE TABLE #tCases
(
	rf_idCases BIGINT,
	rf_idCompletedCase INT,
	CodeM CHAR(6),
	N013 TINYINT,
	AmountPayment DECIMAL(15,2),
	CodeSMO VARCHAR(5)
)		
--CREATE UNIQUE CLUSTERED INDEX QU_IdCase ON #tCases(rf_idCases) --WITH IGNORE_DUP_KEY

INSERT #tCases( rf_idCases, CodeM,AmountPayment,rf_idCompletedCase, codeSMO )
SELECT c.id, f.CodeM, c.AmountPayment,rf_idRecordCasePatient, a.rf_idSMO
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
			--AND a.rf_idSMO<>'34'
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient							
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd  AND a.ReportMonth >=@reportMonth AND a.ReportYear=@reportYear

UPDATE c SET c.N013=1
FROM #tCases c INNER JOIN dbo.t_ONK_USL u ON
		c.rf_idCases=u.rf_idCase              
WHERE u.rf_idN013=2


SELECT  sum(col3 ) AS Col3,
		sum(col4 ) AS Col4,
        sum(Col5 ) AS Col5,
        sum(Col6 ) AS Col6,
        sum(Col7 ) AS Col7,
        sum(Col8 ) AS Col8,
        sum(Col9 ) AS Col9,
        sum(Col10) AS Col10 ,
        sum(Col11) AS Col11 ,
        sum(Col12) AS Col12 ,
        sum(Col13) AS Col13 ,
        sum(Col14) AS Col14 ,
        sum(Col15) AS Col15 ,
        sum(Col16) AS Col16 ,
        sum(Col17) AS Col17 ,
        sum(Col18) AS Col18 ,
        sum(Col19) AS Col19
FROM (
SELECT  0 AS col3,0 AS Col4,COUNT(p.rf_idCase) AS Col5
		,COUNT(CASE WHEN p.TypeCheckup=2 THEN p.idAkt ELSE NULL END) AS Col6
		,COUNT(CASE WHEN p.TypeCheckup=2 AND c.n013=1 THEN p.idAkt ELSE NULL END) AS Col7
		,COUNT(DISTINCT CASE WHEN p.TypeCheckup=3 THEN c.rf_idCompletedCase ELSE NULL END) AS Col8
		,COUNT(CASE WHEN p.TypeCheckup=3 AND c.n013=1 THEN p.idAkt ELSE NULL END) AS Col9
		---------------------------------------------------------------------------------
		,COUNT(DISTINCT CASE WHEN p.TypeCheckup=1 and p.AmountDeduction>0 THEN c.rf_idCompletedCase ELSE NULL END) AS Col10
		,COUNT(DISTINCT CASE WHEN p.TypeCheckup=2 and p.AmountDeduction>0 THEN c.rf_idCompletedCase ELSE NULL END) AS Col11
		,COUNT(DISTINCT CASE WHEN p.TypeCheckup=2 and p.AmountDeduction>0 AND c.n013=1 THEN c.rf_idCompletedCase ELSE NULL END) AS Col12
		,COUNT(DISTINCT CASE WHEN p.TypeCheckup=3 and p.AmountDeduction>0 THEN c.rf_idCompletedCase ELSE NULL END) AS Col13
		,COUNT(DISTINCT CASE WHEN p.TypeCheckup=3 and p.AmountDeduction>0 AND c.n013=1 THEN c.rf_idCompletedCase ELSE NULL END) AS Col14
		-----------------------------------------------------------------------------------------------------
		,COUNT(CASE WHEN p.TypeCheckup=1 THEN r.CodeReason ELSE NULL END) AS Col15
		,COUNT(CASE WHEN p.TypeCheckup=2 THEN r.CodeReason ELSE NULL END) AS Col16
		,COUNT(CASE WHEN p.TypeCheckup=2 AND c.N013=1 THEN r.CodeReason ELSE NULL END) AS Col17
		,COUNT(CASE WHEN p.TypeCheckup=3 THEN r.CodeReason ELSE NULL END) AS Col18
		,COUNT(CASE WHEN p.TypeCheckup=3 AND c.N013=1 THEN r.CodeReason ELSE NULL END) AS Col19
FROM #tCases c inner JOIN dbo.t_PaymentAcceptedCase2 p ON
		c.rf_idCases=p.rf_idCase
				LEFT JOIN dbo.t_ReasonDenialPayment r ON
		p.rf_idCase=r.rf_idCase
		AND p.idAkt=r.idAkt	
WHERE CodeSMO<>'34'
UNION ALL
SELECT 0 AS col3,COUNT(rf_idCases) as Col4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 FROM #tCases WHERE CodeSMO='34'
UNION ALL
SELECT COUNT(rf_idCases) AS col3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 FROM #tCases WHERE CodeSMO<>'34'
) T 

SELECT DISTINCT f14.Reason, f14.Name,CASE WHEN TypeCheckup=1 THEN 'Ã› ' WHEN TypeCheckup=2 THEN 'Ã››' ELSE '› Ãœ' end
FROM #tCases c inner JOIN dbo.t_PaymentAcceptedCase2 p ON
		c.rf_idCases=p.rf_idCase
				INNER JOIN dbo.t_ReasonDenialPayment r ON
		p.rf_idCase=r.rf_idCase
		AND p.idAkt=r.idAkt	
				INNER JOIN oms_nsi.dbo.sprF014 f14 ON
		r.CodeReason=f14.id
WHERE p.TypeCheckup<4

SELECT DISTINCT f14.Reason, f14.Name,CASE WHEN TypeCheckup=1 THEN 'Ã› ' WHEN TypeCheckup=2 THEN 'Ã››' ELSE '› Ãœ' end
FROM #tCases c inner JOIN dbo.t_PaymentAcceptedCase2 p ON
		c.rf_idCases=p.rf_idCase
				INNER JOIN dbo.t_ReasonDenialPayment r ON
		p.rf_idCase=r.rf_idCase
		AND p.idAkt=r.idAkt	
				INNER JOIN oms_nsi.dbo.sprF014 f14 ON
		r.CodeReason=f14.id
WHERE c.N013=1
GO
DROP TABLE #tCases			  		
--DROP TABLE #tmp