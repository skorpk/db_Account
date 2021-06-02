USE AccountOMS
GO
SET STATISTICS TIME ON

CREATE TABLE #tPeople
(
	rf_idCase BIGINT,
	PeopleID INT,
	GUID_Case UNIQUEIDENTIFIER,
	FIO VARCHAR(60),
	BirthDay DATE,		
	AttachLPU CHAR(6),
	codeSMO CHAR(5),
	Account VARCHAR(15),
	NumberCase BIGINT,
	DateAccount DATE,
	V009 SMALLINT,
	DateBegin DATE,
	DateEnd DATE,
	AmountPayment DECIMAL(11,2),
	CodeM CHAR(6),
	AmountPaymentAccept DECIMAL(11,2),
	DS date	
)		
INSERT #tPeople( rf_idCase , PeopleID, GUID_Case,FIO ,BirthDay ,AttachLPU ,codeSMO ,Account ,NumberCase ,DateAccount 
				,V009 ,DateBegin ,DateEnd ,AmountPayment ,CodeM,DS )
SELECT c.id,pid.PID, c.GUID_Case,p.Fam+' '+p.Im+' '+ISNULL(p.Ot,''),p.BirthDay,r.AttachLPU, a.rf_idSMO,a.Account,c.idRecordCase,a.DateRegister,c.rf_idV009,
		c.DateBegin,c.DateEnd,c.AmountPayment,f.CodeM,pr.DS
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
		f.id=a.rf_idFiles		
		AND a.ReportYear=2014
		AND a.ReportMonth<7
		AND a.Letter IN ('O','R')
					INNER JOIN dbo.t_RecordCasePatient r ON
		a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c/* WITH (INDEX(IX_Case_idRecordCasePatient))*/ ON 
		r.id=c.rf_idRecordCasePatient					
					INNER JOIN dbo.t_RegisterPatient p ON
		r.id=p.rf_idRecordCase
		AND f.id=p.rf_idFiles									
					INNER JOIN dbo.t_Case_PID_ENP pid ON
		c.id=pid.rf_idCase
		AND pid.PID IS NOT NULL
					INNER JOIN PolicyRegister.dbo.PEOPLE pr ON
		pid.PID=pr.ID					
WHERE f.DateRegistration>'20140101' AND f.DateRegistration<'20141001' AND a.rf_idSMO<>'34' AND pr.DS<c.DateEnd
		

UPDATE c1 SET c1.AmountPaymentAccept=c1.AmountPayment-p.AmountDeduction
FROM #tPeople c1 INNER JOIN (
							SELECT rf_idCase,SUM(ISNULL(AmountDeduction,0)) AS AmountDeduction
							FROM [srvsql1-st2].AccountOMSReports.dbo.t_PaymentAcceptedCase 
							WHERE DateRegistration>='20140101' AND DateRegistration<='20141001' -- AND Letter LIKE '%O'        
							GROUP BY rf_idCase
							) p ON
                    c1.rf_idCase=p.rf_idCase     		

SELECT DISTINCT PeopleID ,rf_idCase ,GUID_Case,FIO ,BirthDay ,AttachLPU, l.NAMES , s.sNameS ,Account ,NumberCase ,DateAccount ,CAST(V009 AS VARCHAR(3))+' '+v009.name
		,CONVERT(VARCHAR(10),DateBegin,104)+' - '+CONVERT(VARCHAR(10),p.DateEnd,104),CAST(AmountPayment AS MONEY) ,p.CodeM, l1.NAMES, DS
FROM #tPeople  p INNER JOIN dbo.vw_sprT001 l ON
			p.AttachLPU=l.CodeM
				 INNER JOIN dbo.vw_sprT001 l1 ON
			p.CodeM=l1.CodeM
				INNER JOIN dbo.vw_sprSMO_Report s ON
			p.codeSMO=s.smocod
				INNER JOIN RegisterCases.dbo.vw_sprV009 v009 ON
			p.V009=v009.id
WHERE AmountPaymentAccept>0			

SET STATISTICS TIME OFF                    
GO
DROP TABLE #tPeople