USE AccountOMS
GO
ALTER VIEW vw_DFileInSMO34
AS
SELECT ec.rf_idCase		    
	  ,b.DatePP AS DateRegistration
	  ,pd.S_SL AS AmountPayment
	  ,f.CodeM
	  ,a.Letter	 
FROM expertAccounts.dbo.t_ExpertCase ec INNER JOIN expertAccounts.dbo.t_ExpertAccount ea ON 
					ea.id = ec.rf_idExpertAccount
										INNER JOIN expertAccounts.dbo.t_Case c ON 
					ec.rf_idCase = c.id        
										INNER JOIN expertAccounts.dbo.t_RegistersAccounts A ON 
					ea.rf_idAccount = A.id		
										INNER JOIN expertAccounts.dbo.t_File f ON
					a.rf_idFiles=f.id			    
										INNER JOIN expertAccounts.dbo.t_ExpertAct act ON
					ea.id = act.rf_idExpertAccount									
										INNER JOIN expertAccounts.dbo.t_ExpertPays ep ON 
					act.rf_idExpertAccount = ep.rf_idExpertAccount
										INNER JOIN expertAccounts.dbo.t_BuhPay b ON 
					ep.rf_idBuhPay = b.id
										INNER JOIN expertAccounts.dbo.t_PDCase pd ON 
					c.id = pd.rf_idCase
WHERE a.Letter IS NOT null


GO


