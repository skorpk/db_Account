USE ExchangeFinancing
GO
DECLARE @dateBegin DATETIME='20160101',
		@dateEndRAC DATETIME=GETDATE()

SELECT 	f.DateRegistration,c.rf_idCase, TypeCheckup,OrderCheckup,c.AmountDeduction
FROM ExchangeFinancing.dbo.t_AFileIn f INNER JOIN ExchangeFinancing.dbo.t_DocumentOfCheckup d ON
					f.id=d.rf_idAFile
							INNER JOIN ExchangeFinancing.dbo.t_CheckedAccount a ON
					d.id=a.rf_idDocumentOfCheckup
									INNER JOIN ExchangeFinancing.dbo.t_CheckedCase c ON
					a.id=c.rf_idCheckedAccount									
WHERE f.DateRegistration>@dateBegin AND f.DateRegistration<@dateEndRAC AND d.TypeCheckup=1
GO
--SELECT * FROM dbo.vw_sprTypeCheckup
--SELECT * FROM dbo.vw_sprOrderCheckup
