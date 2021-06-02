USE Consultation_NMRC
GO
SELECT idRow,NumberPolicy,CodeM,DateConsultation
FROM dbo.t_InformationNMRC WHERE LEN(NumberPolicy)>12