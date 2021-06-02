USE AccountOMS
GO
BEGIN TRANSACTION
UPDATE r SET r.AttachLPU='611001'
FROM dbo.t_Case c INNER JOIN dbo.t_RecordCasePatient r ON
		c.rf_idRecordCasePatient=r.id				
WHERE c.DateEnd>='20170101'  AND r.AttachLPU='61001'

UPDATE r SET r.AttachLPU='511001'
FROM dbo.t_Case c INNER JOIN dbo.t_RecordCasePatient r ON
		c.rf_idRecordCasePatient=r.id				
WHERE c.DateEnd>='20170101'  AND r.AttachLPU='51001'
commit