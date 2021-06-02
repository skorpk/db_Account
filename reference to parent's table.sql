USE RegisterCases 
GO
ALTER TABLE dbo.t_DispInfo  WITH CHECK ADD  CONSTRAINT FK_DispInfo_Cases FOREIGN KEY(rf_idCase)
REFERENCES dbo.t_Case (id)
ON DELETE CASCADE
GO

ALTER TABLE dbo.t_DispInfo CHECK CONSTRAINT FK_DispInfo_Cases
GO

ALTER TABLE dbo.t_DS2_Info  WITH CHECK ADD  CONSTRAINT FK_DS2_Info_Cases FOREIGN KEY(rf_idCase)
REFERENCES dbo.t_Case (id)
ON DELETE CASCADE
GO

ALTER TABLE dbo.t_DS2_Info CHECK CONSTRAINT FK_DS2_Info_Cases
GO
ALTER TABLE dbo.t_Prescriptions  WITH CHECK ADD  CONSTRAINT FK_Prescriptions_Info_Cases FOREIGN KEY(rf_idCase)
REFERENCES dbo.t_Case (id)
ON DELETE CASCADE
GO

ALTER TABLE dbo.t_Prescriptions CHECK CONSTRAINT FK_Prescriptions_Info_Cases
GO 

ALTER TABLE dbo.t_Coefficient  WITH CHECK ADD  CONSTRAINT FK_Coefficient_Cases FOREIGN KEY(rf_idCase)
REFERENCES dbo.t_Case (id)
ON DELETE CASCADE
GO

ALTER TABLE dbo.t_Coefficient CHECK CONSTRAINT FK_Coefficient_Cases
GO 