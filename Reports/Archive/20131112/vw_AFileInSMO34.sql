USE AccountOMS
GO
--DROP VIEW vw_AFileSMO34
ALTER VIEW vw_AFileInSMO34
AS
SELECT ec.rf_idCase
		,c.AmountPayment		
		,CASE WHEN actC.sank_mek + actC.sank_mee + actC.sank_ekmp > 0 THEN 
					actC.sank_mek + actC.sank_mee + actC.sank_ekmp
		  ELSE ec.RemovalSumm END AS AmountDeduction	   
    ,act.dakt AS DateRegistration	
    ,a.Letter 	 
FROM  expertAccounts.dbo.t_ExpertCase ec INNER JOIN expertAccounts.dbo.t_ExpertAccount ea ON 
			ea.id = ec.rf_idExpertAccount
					INNER JOIN expertAccounts.dbo.t_Case c ON 
			ec.rf_idCase = c.id		        
					INNER JOIN expertAccounts.dbo.t_RegistersAccounts A ON 
			ea.rf_idAccount = A.id
					INNER JOIN expertAccounts.dbo.t_File f ON 
			A.rf_idFiles = f.id        
					INNER JOIN expertAccounts.dbo.t_ExpertAct act ON 
			ea.id = act.rf_idExpertAccount
					INNER JOIN expertAccounts.dbo.t_ExpertActCase actC ON 
			ec.rf_idCase = actC.rf_idCase 
			AND ec.rf_idExpertAccount = actC.rf_idExpertAccount	
WHERE a.Letter IS NULL								
GO
					
				
