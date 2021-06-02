USE AccountOMS
GO	
--CREATE TABLE [dbo].[t_PaymentAcceptedCase](
--	[rf_idCase] [bigint] NOT NULL,
--	[DateRegistration] [datetime] NOT NULL,
--	[AmountPaymentAccept] [decimal](15, 2) NOT NULL,
--	[CodeM] [char](6) NOT NULL,
--	[Letter] [char](1) NULL,
--	[AmountDeduction] [decimal](12, 2) NULL
--)

DECLARE @d DATETIME='20160101'

TRUNCATE TABLE dbo.t_PaymentAcceptedCase

INSERT dbo.t_PaymentAcceptedCase( rf_idCase ,DateRegistration ,AmountPaymentAccept ,CodeM ,Letter ,AmountDeduction)
SELECT sc.rf_idCase, f.DateRegistration, 0.0 AS AmountPaymentAccept, f.CodeM, RIGHT(a.Account, 1) AS Letter,SUM(sc.AmountEKMP+ sc.AmountMEE+sc.AmountMEK) AS AmountDeduction
FROM ExchangeFinancing.dbo.t_AFileIn f INNER JOIN ExchangeFinancing.dbo.t_DocumentOfCheckup p ON 
							f.id = p.rf_idAFile 
										INNER JOIN ExchangeFinancing.dbo.t_CheckedAccount a ON 
							p.id = a.rf_idDocumentOfCheckup 
										INNER JOIN ExchangeFinancing.dbo.t_CheckedCase sc ON 
							a.id = sc.rf_idCheckedAccount
WHERE f.DateRegistration >@d   
GROUP BY sc.rf_idCase, f.DateRegistration, sc.AmountPaymentAccept, f.CodeM, RIGHT(a.Account, 1)   
UNION ALL
SELECT distinct  a.rf_idCase , a.dakt,0.0 ,a.CodeM ,a.Letter ,a.RemovalSumm 
FROM (
	SELECT distinct ec.rf_idCase , reestr.onDate as dakt,ec.SumCase ,f.CodeM ,a.Letter ,ec.RemovalSumm 
FROM expertAccounts.dbo.t_ExpertCase ec INNER JOIN expertAccounts.dbo.t_ExpertAccount ea ON ea.id = ec.rf_idExpertAccount
										INNER JOIN expertAccounts.dbo.t_Case c ON ec.rf_idCase = c.id
										INNER JOIN expertAccounts.dbo.t_RegistersAccounts A ON ea.rf_idAccount = A.id
										INNER JOIN expertAccounts.dbo.t_File f ON A.rf_idFiles = f.id
										INNER JOIN expertAccounts.dbo.t_ExpertAct act ON ea.id = act.rf_idExpertAccount
										INNER JOIN expertAccounts.dbo.t_ActReestr reestr ON act.rf_idActReestr = reestr.id
										INNER JOIN expertAccounts.dbo.t_ExpertActCase actC ON ec.rf_idCase = actC.rf_idCase
										AND ec.rf_idExpertAccount = actC.rf_idExpertAccount
WHERE ea.rf_typeExpert = 1 AND ea.rf_typek = 1 and actC.sum_v > 0 
		AND reestr.onDate>@d
UNION ALL					
SELECT ec.rf_idCase ,reestr.onDate as dakt, ec.SumCase ,f.CodeM ,a.Letter ,ec.RemovalSumm 
FROM expertAccounts.dbo.t_ExpertCase ec INNER JOIN expertAccounts.dbo.t_ExpertAccount ea ON ea.id = ec.rf_idExpertAccount
										INNER JOIN expertAccounts.dbo.t_Case c ON ec.rf_idCase = c.id
										INNER JOIN expertAccounts.dbo.t_RegistersAccounts A ON ea.rf_idAccount = A.id
										INNER JOIN expertAccounts.dbo.t_File f ON A.rf_idFiles = f.id
										INNER JOIN expertAccounts.dbo.t_ExpertAct act ON ea.id = act.rf_idExpertAccount
										INNER JOIN expertAccounts.dbo.t_ActReestr reestr ON act.rf_idActReestr = reestr.id
										INNER JOIN expertAccounts.dbo.t_ExpertActCase actC ON ec.rf_idCase = actC.rf_idCase
						AND ec.rf_idExpertAccount = actC.rf_idExpertAccount
WHERE ea.rf_typeExpert in (2, 3) AND ea.rf_typek = 1 AND ec.RemovalSumm > 0 
		AND reestr.onDate>@d
UNION ALL
SELECT ec.rf_idCase ,act.dakt,ec.SumCase ,f.CodeM ,a.Letter ,ec.RemovalSumm AS rem
FROM
	expertAccounts.dbo.t_ExpertCase ec
	INNER JOIN expertAccounts.dbo.t_ExpertAccount ea ON ea.id = ec.rf_idExpertAccount
	INNER JOIN expertAccounts.dbo.t_Case c ON ec.rf_idCase = c.id
	INNER JOIN expertAccounts.dbo.t_RegistersAccounts A ON ea.rf_idAccount = A.id
	INNER JOIN expertAccounts.dbo.t_File f ON A.rf_idFiles = f.id
	INNER JOIN expertAccounts.dbo.t_ExpertAct act ON ea.id = act.rf_idExpertAccount
	INNER JOIN expertAccounts.dbo.t_ExpertActCase actC ON ec.rf_idCase = actC.rf_idCase
					AND ec.rf_idExpertAccount = actC.rf_idExpertAccount
	LEFT JOIN expertAccounts.dbo.t_InoRemoval
		   ON ec.rf_idCase = expertAccounts.dbo.t_InoRemoval.rf_idOldCase
			
WHERE
	ea.rf_typeExpert = 1 AND ea.rf_typek = 2 AND ec.RemovalSumm > 0 AND act.dakt>@d
	AND expertAccounts.dbo.t_InoRemoval.rf_idOldCase IS NULL		
UNION ALL
select rf_idCase ,dakt ,SumCase-rem AS AmountPayment, CodeM ,Letter ,rem
from (
	SELECT ec.rf_idCase ,reestr.onDate AS dakt,ec.sum_v as SumCase,f.CodeM ,a.Letter, ec.sank_mek + ec.sank_mee + ec.sank_ekmp AS rem
	FROM expertAccounts.dbo.t_ExpertActCase ec
					INNER JOIN expertAccounts.dbo.t_ExpertAct ea ON ea.id = ec.rf_idExpertAct
					INNER JOIN expertAccounts.dbo.t_ActReestr reestr ON  ea.rf_idActReestr = reestr.id
					INNER JOIN expertAccounts.dbo.t_Case c ON  ec.rf_idCase = c.id
					INNER JOIN expertAccounts.dbo.t_RecordCasePatient p ON c.rf_idRecordCasePatient = p.id
					INNER JOIN expertAccounts.dbo.t_RegistersAccounts A ON A.id = p.rf_idRegistersAccounts
					INNER JOIN expertAccounts.dbo.t_File f ON A.rf_idFiles = f.id 
					INNER JOIN expertAccounts.dbo.t_InoRemoval ON ec.rf_idCase = expertAccounts.dbo.t_InoRemoval.rf_idOldCase
	WHERE
		ea.typek = 2 AND ec.sank_mek + ec.sank_mee + ec.sank_ekmp > 0
		AND reestr.onDate>@d
) t
  ) a