use	AccountOMS
GO
--������� ������� ������� �.� �������� ���������� �������
SELECT * INTO tmp_MagalazKireeva_34002 FROM dbo.vw_MagalazKireeva_34002
GO
SELECT * INTO tmp_MagalazKireeva_34001 FROM dbo.vw_MagalazKireeva_34001
go
----������� �������
DROP TABLE tmp_MagalazKireeva_34001
DROP TABLE tmp_MagalazKireeva_34002