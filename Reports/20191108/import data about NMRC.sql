USE AccountOMS
GO
TRUNCATE TABLE dbo.tmp_InformationNMRC

INSERT dbo.tmp_InformationNMRC
(
    NumberPolicy,
    CodeM,
    DateConsultation,
    idRow
)
SELECT NumberPolicy,CodeM,DateConsultation,idRow
FROM [srv-cnt-db1].Consultation_NMRC.dbo.t_InformationNMRC WHERE LEN(NumberPolicy)>12
go