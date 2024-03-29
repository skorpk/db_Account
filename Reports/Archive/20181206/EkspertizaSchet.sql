USE AccountOMS
GO
DECLARE @dateStart DATETIME='20180901',
		@dateEnd DATETIME='20181217',
		@dateEndPay DATETIME='20181217',
		@reportYear SMALLINT=2018
CREATE TABLE #tCases
(
	rf_idCases BIGINT,
	CodeM CHAR(6),
	N013 TINYINT,
	AmountPayment DECIMAL(15,2),
	idSchet int
)		
--CREATE UNIQUE CLUSTERED INDEX QU_IdCase ON #tCases(rf_idCases) --WITH IGNORE_DUP_KEY

INSERT #tCases( rf_idCases, CodeM,AmountPayment ,idSchet)
SELECT c.id, f.CodeM, c.AmountPayment,a.id
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
			AND a.rf_idSMO<>'34'
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient							
					inner JOIN dbo.t_DS_ONK_REAB d ON
			c.id=d.rf_idCase																		
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd  AND a.ReportMonth=11 AND a.ReportYear=@reportYear AND c.rf_idV006<>4 AND d.DS_ONK=1

INSERT #tCases( rf_idCases, CodeM,AmountPayment ,idSchet)
SELECT c.id, f.CodeM, c.AmountPayment,a.id
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
			AND a.rf_idSMO<>'34'
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.vw_Diagnosis dd ON
			c.id=dd.rf_idCase																								
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportMonth=11 AND a.ReportYear=@reportYear AND c.rf_idV006<>4 AND dd.DS1 LIKE 'C%'
AND NOT EXISTS(SELECT * FROM #tCases WHERE rf_idCases=c.id)

INSERT #tCases( rf_idCases, CodeM,AmountPayment ,idSchet)
SELECT c.id, f.CodeM, c.AmountPayment,a.id
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
			AND a.rf_idSMO<>'34'
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient						
					inner JOIN dbo.t_DispInfo d ON
			c.id=d.rf_idCase																			
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportMonth=11 AND a.ReportYear=@reportYear AND c.rf_idV006<>4 AND d.IsOnko=1
AND NOT EXISTS(SELECT * FROM #tCases WHERE rf_idCases=c.id)

UPDATE c SET c.N013=1
FROM #tCases c INNER JOIN dbo.t_ONK_USL u ON
		c.rf_idCases=u.rf_idCase              
WHERE u.rf_idN013=2


SELECT  sum(col3 ),
        sum(Col5 ),
        sum(Col6 ),
        sum(Col7 ),
        sum(Col8 ),
        sum(Col9 ),
        sum(Col10) ,
        sum(Col11) ,
        sum(Col12) ,
        sum(Col13) ,
        sum(Col14) ,
        sum(Col15) ,
        sum(Col16) ,
        sum(Col17) ,
        sum(Col18) ,
        sum(Col19)
FROM (
SELECT  0 AS col3,COUNT(DISTINCT c.idSchet) AS Col5
		,COUNT(CASE WHEN p.TypeCheckup=2 THEN p.idAkt ELSE NULL END) AS Col6
		,COUNT(CASE WHEN p.TypeCheckup=2 AND c.n013=1 THEN p.idAkt ELSE NULL END) AS Col7
		,COUNT(CASE WHEN p.TypeCheckup=3 THEN p.idAkt ELSE NULL END) AS Col8
		,COUNT(CASE WHEN p.TypeCheckup=3 AND c.n013=1 THEN p.idAkt ELSE NULL END) AS Col9
		---------------------------------------------------------------------------------
		,COUNT(DISTINCT CASE WHEN p.TypeCheckup=1 and p.AmountDeduction>0 THEN c.rf_idCases ELSE NULL END) AS Col10
		,COUNT(DISTINCT CASE WHEN p.TypeCheckup=2 and p.AmountDeduction>0 THEN c.rf_idCases ELSE NULL END) AS Col11
		,COUNT(DISTINCT CASE WHEN p.TypeCheckup=2 and p.AmountDeduction>0 AND c.n013=1 THEN c.rf_idCases ELSE NULL END) AS Col12
		,COUNT(DISTINCT CASE WHEN p.TypeCheckup=3 and p.AmountDeduction>0 THEN c.rf_idCases ELSE NULL END) AS Col13
		,COUNT(DISTINCT CASE WHEN p.TypeCheckup=3 and p.AmountDeduction>0 AND c.n013=1 THEN c.rf_idCases ELSE NULL END) AS Col14
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
UNION ALL
SELECT COUNT(DISTINCT idSchet) AS col3, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 FROM #tCases 
) T 
GO
DROP TABLE #tCases			  		