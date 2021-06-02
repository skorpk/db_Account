USE Consultation_NMRC
GO
SELECT InitiatorLPU,DateConsultation,NumberPolicy, idRow
FROM dbo.t_InformationNMRC
WHERE rf_idF008=3 AND LEN(NumberPolicy)>10