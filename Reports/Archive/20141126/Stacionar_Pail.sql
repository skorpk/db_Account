USE AccountOMS
GO
CREATE TABLE #tPeople(PID BIGINT,rf_idCase BIGINT,DateBegin DATE,DateEnd DATE,IsRepeat TINYINT NOT NULL DEFAULT 0)

DECLARE @dateRegStart DATETIME='20140101',
		@dateRegEnd DATETIME='20141115',
		@codeM CHAR(6)='161007',
		@reportMM TINYINT=10
		
INSERT #tPeople( PID ,rf_idCase ,DateBegin ,DateEnd)
SELECT ce.PID,c.id,c.DateBegin,c.DateEnd
FROM t_file f INNER JOIN dbo.t_RegistersAccounts a ON
		f.id=a.rf_idFiles
			  inner join dbo.t_RecordCasePatient r on
	    a.id=r.rf_idRegistersAccounts
			  inner join t_Case c on
		r.id=c.rf_idRecordCasePatient
			 INNER JOIN (SELECT DISTINCT Pid,rf_idCase from dbo.t_Case_PID_ENP) ce ON 
		c.id=ce.rf_idCase	
			left JOIN (SELECT c.rf_idCase,SUM(c.AmountMEK+c.AmountMEE+c.AmountEKMP) AS AmountDeduction
					   FROM ExchangeFinancing.dbo.t_AFileIn f INNER JOIN  ExchangeFinancing.dbo.t_DocumentOfCheckup d ON
										f.id=d.rf_idAFile
													INNER JOIN ExchangeFinancing.dbo.t_CheckedAccount a ON
										d.id=a.rf_idDocumentOfCheckup
													INNER JOIN ExchangeFinancing.dbo.t_CheckedCase c ON
										a.id=c.rf_idCheckedAccount
													INNER JOIN ExchangeFinancing.dbo.vw_sprTypeCheckup t ON
										d.TypeCheckup=t.id
						WHERE f.DateRegistration>@dateRegStart AND f.CodeM=@codeM
						GROUP BY rf_idCase
					 ) e ON
		c.id=e.rf_idCase
WHERE f.DateRegistration>@dateRegStart AND f.DateRegistration<@dateRegEnd AND a.ReportYear=2014 AND f.CodeM=@codeM AND a.rf_idSMO<>'34'	
		AND a.ReportMonth>0 AND a.ReportMonth<=@reportMM AND c.rf_idV006=1 AND c.AmountPayment-ISNULL(e.AmountDeduction,0)>0

UPDATE t1 SET IsRepeat=1
FROM #tPeople t INNER JOIN #tPeople t1 ON
			t.PID=t1.PID
			AND t.rf_idCase<>t1.rf_idCase						
WHERE t1.DateBegin>t.DateBegin AND t1.DateBegin<=DATEADD(dd,90,t.DateEnd) 

SELECT DISTINCT a.Account,a.DateRegister
		,c.idRecordCase
		,v6.name AS V6
		,v8.Name AS V8
		,f.CodeM
		,l.NAMES AS LPU
		,t.PID		
		,pep.Fam+' '+pep.Im+' '+ISNULL(pep.Ot,'') AS Fio,p.Sex,pep.DR,r.NumberPolis
		,c.DateBegin,c.DateEnd
		,v9.name AS RSLT
		,d.DS1,mkb10.Diagnosis
		,CAST(c.AmountPayment AS MONEY) AS AmountPayment
		,v2.name AS V002
		,m.MES
		,mu.MUName
		,CAST (m.Tariff AS MONEY) AS Tariff
		,c.NumberHistoryCase		
		,v12.name AS ISHOD
		,v4.name AS PRVS
		,v10.name AS V10
		,r.AttachLPU					
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles				
				INNER JOIN dbo.t_RecordCasePatient r ON
		a.id=r.rf_idRegistersAccounts
				INNER JOIN dbo.t_RegisterPatient p ON
		r.id=p.rf_idRecordCase
		AND f.id=p.rf_idFiles		
				INNER JOIN dbo.t_Case c  ON
		r.id=c.rf_idRecordCasePatient	
				INNER JOIN dbo.t_MES m ON
		c.id=m.rf_idCase
				INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase				 
				INNER JOIN #tPeople AS t ON
		c.id=t.rf_idCase
				INNER JOIN dbo.vw_sprMKB10 mkb10 ON
		d.DS1=mkb10.DiagnosisCode			
				INNER JOIN RegisterCases.dbo.vw_sprV009 v9 ON
		c.rf_idV009=v9.id
				INNER JOIN RegisterCases.dbo.vw_sprV012 v12 ON
		c.rf_idV012=v12.id		
				INNER JOIN RegisterCases.dbo.vw_sprV004 v4 ON
		c.rf_idV004=v4.id		
				INNER JOIN RegisterCases.dbo.vw_sprV002 v2 ON
		c.rf_idV002=v2.id
				INNER JOIN RegisterCases.dbo.vw_sprV006 v6 ON
		c.rf_idV006=v6.id
				INNER JOIN RegisterCases.dbo.vw_sprV08 v8 ON
		c.rf_idV008=v8.id
				INNER JOIN dbo.vw_sprT001 l ON
		f.CodeM=l.CodeM
				INNER JOIN RegisterCases.dbo.vw_sprV010 v10 ON
		c.rf_idV010=v10.id	
				INNER JOIN (SELECT MU,MUName FROM RegisterCases.dbo.vw_sprMUCompletedCase
							UNION ALL 
							SELECT code,name FROM RegisterCases.dbo.vw_sprCSG
							) mu ON
		m.MES=mu.MU
				INNER JOIN PolicyRegister.dbo.PEOPLE pep ON
		t.PID=pep.ID
				left JOIN (SELECT c.rf_idCase,SUM(c.AmountMEK+c.AmountMEE+c.AmountEKMP) AS AmountDeduction
							FROM ExchangeFinancing.dbo.t_AFileIn f INNER JOIN  ExchangeFinancing.dbo.t_DocumentOfCheckup d ON
										f.id=d.rf_idAFile
													INNER JOIN ExchangeFinancing.dbo.t_CheckedAccount a ON
										d.id=a.rf_idDocumentOfCheckup
													INNER JOIN ExchangeFinancing.dbo.t_CheckedCase c ON
										a.id=c.rf_idCheckedAccount
													INNER JOIN ExchangeFinancing.dbo.vw_sprTypeCheckup t ON
										d.TypeCheckup=t.id
							WHERE f.DateRegistration>@dateRegStart AND f.CodeM=@codeM
							GROUP BY rf_idCase
							) e ON
		c.id=e.rf_idCase		
WHERE f.DateRegistration>@dateRegStart AND f.DateRegistration<@dateRegEnd AND a.ReportYear=2014 AND f.CodeM=@codeM AND a.rf_idSMO<>'34'	
		AND a.ReportMonth>0 AND a.ReportMonth<=@reportMM	 AND c.rf_idV006=1 AND c.AmountPayment-ISNULL(e.AmountDeduction,0)>0 AND t.IsRepeat=1
ORDER BY t.PID
 GO
DROP TABLE #tPeople