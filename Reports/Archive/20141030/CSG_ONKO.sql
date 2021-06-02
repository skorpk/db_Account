USE AccountOMS
GO
DECLARE @mkb AS TABLE(DiagnosisCode VARCHAR(3),Diagnosis VARCHAR(250))
INSERT @mkb 
VALUES ('C00','��������������� ��������������� ����'),
('C01','��� ��������� �����'),
('C02','��������������� ��������������� ������ � ������������ ������ �����'),
('C03','��������������� ��������������� �����'),
('C04','��������������� ��������������� ��� ������� ���'),
('C05','��������������� ��������������� ����'),
('C06','��������������� ��������������� ������ � ������������ ������� ���'),
('C07','��� ���������� ������� ������'),
('C08','��������������� ��������������� ������ � ������������ ������� ������� �����'),
('C09','��������������� ��������������� ���������'),
('C10','��������������� ��������������� ����������'),
('C11','��������������� ��������������� ����������'),
('C12','��� ������������ ������'),
('C13','��������������� ��������������� ������ ����� ������'),
('C14','��������������� ��������������� ������ � ������� ������������ ����������� ����, ������� ��� � ������'),
('C15','��������������� ��������������� ��������'),
('C16','��������������� ��������������� �������'),
('C17','��������������� ��������������� ������� ���������'),
('C18','��������������� ��������������� ��������� �����'),
('C19','��� ���������������� ����������'),
('C20','��� ������ �����'),
('C21','��������������� ��������������� ������� ������� [�����] � ��������� ������'),
('C22','��������������� ��������������� ������ � ���������������� ������� ��������'),
('C23','��� �������� ������'),
('C24','��������������� ��������������� ������ � ������������ ������ �������������� �����'),
('C25','��������������� ��������������� ������������� ������'),
('C26','��������������� ��������������� ������ � ������� ������������ ������� �����������'),
('C30','��������������� ��������������� ������� ���� � �������� ���'),
('C31','��������������� ��������������� ����������� �����'),
('C32','��������������� ��������������� �������'),
('C33','��� ������'),
('C34','��������������� ��������������� ������� � ������'),
('C37','��� ���������� ������'),
('C38','��������������� ��������������� ������, ������������� � ������'),
('C39','��������������� ��������������� ������ � ������� ������������ ����������� ������� ������� � ������������� �������'),
('C40','��������������� ��������������� ������ � ��������� ������ �����������'),
('C41','��������������� ��������������� ������ � ��������� ������ ������ � ������������ �����������'),
('C43','��������������� �������� ����'),
('C44','������ ��������������� ��������������� ����'),
('C45','�����������'),
('C46','������� ������'),
('C47','��������������� ��������������� �������������� ������ � ������������ ������� �������'),
('C48','��������������� ��������������� ����������� ������������ � �������'),
('C49','��������������� ��������������� ������ ����� �������������� � ������ ������'),
('C50','��������������� ��������������� �������� ������'),
('C51','��������������� ��������������� ������'),
('C52','��� ���������'),
('C53','��������������� ��������������� ����� �����'),
('C54','��������������� ��������������� ���� �����'),
('C55','��� ����� ������������ �����������'),
('C56','��� �������'),
('C57','��������������� ��������������� ������ � ������������ ������� ������� �������'),
('C58','��� ��������'),
('C60','��������������� ��������������� �������� �����'),
('C61','��� �������������� ������'),
('C62','��������������� ��������������� �����'),
('C63','��������������� ��������������� ������ � ������������ ������� ������� �������'),
('C64','��� �����, ����� �������� �������'),
('C65','��� �������� �������'),
('C66','��� �����������'),
('C67','��������������� ��������������� �������� ������'),
('C68','��������������� ��������������� ������ � ������������ ������� �������'),
('C69','��������������� ��������������� ����� � ��� ������������ ��������'),
('C70','��������������� ��������������� �������� ��������'),
('C71','��������������� ��������������� ��������� �����'),
('C72','��������������� ��������������� �������� �����, �������� ������ � ������ ������� ����������� ������� �������'),
('C73','��������������� ��������������� ���������� ������'),
('C74','��������������� ��������������� ������������'),
('C75','��������������� ��������������� ������ ����������� ����� � ����������� ��������'),
('C76','��������������� ��������������� ������ � ������� ������������ �����������'),
('C77','��������� � �������� ��������������� ��������������� ������������� �����'),
('C78','��������� ��������������� ��������������� ������� ������� � �����������'),
('C79','��������� ��������������� ��������������� ������ �����������'),
('C80','��� ��� ��������� �����������'),
('C81','������� �������� [�����������������]'),
('C82','������������� [����������] �������������� �������'),
('C83','��������� ������������� �������'),
('C84','�������������� � ������ �-��������� �������'),
('C85','������ ������������ ���� ������������� �������'),
('C88','��������������� ��������������������� �������'),
('C90','������������� ������� � ��������������� ��������������� ���������������'),
('C91','���������� ������ [�����������]'),
('C92','���������� ������ [�����������]'),
('C93','������������ ������'),
('C94','������ ������ ����������� ���������� ����'),
('C95','������ ������������� ���������� ����'),
('C96','������ � ������������ ��������������� ��������������� ����������, ������������ � ����������� �� ������'),
('C97','��������������� ��������������� ��������������� (���������) ������������� �����������')


CREATE TABLE #tPeople
(	id BIGINT,
	AmountPayment DECIMAL(11,2), 
	CodeSMO VARCHAR(5),
	AmountRAK DECIMAL(11,2),
	rf_idV006 TINYINT,
	DiagnosisCode VARCHAR(3),
	PID int
)

INSERT #tPeople( id, AmountPayment, CodeSMO,rf_idV006,DiagnosisCode )
SELECT c.id,c.AmountPayment,a.rf_idSMO,c.rf_idV006,mkb.DiagnosisCode
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
			AND a.ReportYear=2014
			AND a.ReportMonth>0 
			AND a.ReportMonth<10
					INNER JOIN (VALUES ('103001'),('103002'),('103003'),('451001'),('601001') ) l(CodeM) ON
			f.CodeM=l.CodeM
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts	
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient  					
					INNER JOIN dbo.t_MES mes ON
			c.id=mes.rf_idCase
					INNER JOIN (VALUES ('1100031'),('1119031'),('1100074'),('1119074'),('1100075'),('1119075'),('11100076'),('1119076')) csg(code) ON
			mes.MES=csg.code
					INNER JOIN dbo.t_Diagnosis d ON
			c.id=d.rf_idCase
			AND d.TypeDiagnosis=1
					INNER JOIN @mkb mkb ON
			LEFT(d.DiagnosisCode,3)=mkb.DiagnosisCode
WHERE f.DateRegistration>'20140101'	AND f.DateRegistration<'20141025' AND c.rf_idV006=1
UNION ALL
SELECT c.id,c.AmountPayment,a.rf_idSMO,c.rf_idV006,mkb.DiagnosisCode
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
			AND a.ReportYear=2014
			AND a.ReportMonth>0 
			AND a.ReportMonth<10
					INNER JOIN (VALUES ('103001'),('103002'),('103003'),('451001'),('601001') ) l(CodeM) ON
			f.CodeM=l.CodeM
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts	
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient  					
					INNER JOIN ( VALUES(18),(60)) v002(id) ON
			c.rf_idV002=v002.id		
					INNER JOIN dbo.t_Diagnosis d ON
			c.id=d.rf_idCase
			AND d.TypeDiagnosis=1
					INNER JOIN @mkb mkb ON
			LEFT(d.DiagnosisCode,3)=mkb.DiagnosisCode								
WHERE f.DateRegistration>'20140101'	AND f.DateRegistration<'20141025' AND c.rf_idV006=2

---------------------------------------Update information about PID---------------------------------
UPDATE p SET p.pid=pid.IDPeople
FROM #tPeople p INNER JOIN [SRVSQL1-ST2].AccountOMSReports.dbo.t_People_Case pid ON
		p.id=pid.rf_idCase
				

--------------------------------------Update information about RAK---------------------------
UPDATE p SET p.AmountRAK=p.AmountPayment-r.AmountDeduction
FROM #tPeople p INNER JOIN (SELECT rf_idCase,SUM(c.AmountEKMP+c.AmountMEE+c.AmountMEK) AS AmountDeduction
							FROM ExchangeFinancing.dbo.t_AFileIn f INNER JOIN  ExchangeFinancing.dbo.t_DocumentOfCheckup d ON
													f.id=d.rf_idAFile													
																INNER JOIN ExchangeFinancing.dbo.t_CheckedAccount a ON
													d.id=a.rf_idDocumentOfCheckup
														INNER JOIN ExchangeFinancing.dbo.t_CheckedCase c ON
													a.id=c.rf_idCheckedAccount 														
							WHERE f.DateRegistration>='20140101' AND f.DateRegistration<'20141025' 
							GROUP BY rf_idCase
							) r ON
			p.id=r.rf_idCase

	

SELECT  t.Col1 ,
        t.Col2 ,
        SUM(t.Col3) ,
        SUM(t.Col4) ,
        SUM(t.Col5) ,
        SUM(t.Col6) ,
        SUM(t.col7) ,
        SUM(t.Col8) ,
        SUM(t.Col9) ,
        SUM(t.Col10) ,
        SUM(t.col11) ,
        SUM(t.col12) ,
        SUM(t.Col13) ,
        SUM(t.col14) ,
        SUM(t.Col15) ,
        SUM(t.Col16) ,
        SUM(t.Col17)
FROM (
		SELECT   t.Col1 ,t.Col2 
				,ISNULL(t.Col3,0) AS Col3 
				,sum(CASE WHEN t.Col4 IS NOT NULL THEN 1 ELSE 0 end) AS Col4
				,CAST(SUM(ISNULL(t.Col5,0)) AS MONEY) AS Col5
				,ISNULL(t.Col6,0) AS Col6 
				,CAST(SUM(ISNULL(t.col7,0)) AS MONEY) AS col7
				,ISNULL(t.col8,0) Col8
				,COUNT(DISTINCT t.col9) AS Col9 
				,ISNULL(t.col10,0) Col10 
				,SUM(CASE WHEN t.Col11 IS NOT NULL THEN 1 ELSE 0 end) AS col11
				,CAST(SUM(ISNULL(t.col12,0)) AS MONEY) AS col12 
				,ISNULL(t.col13,0) Col13
				,CAST(SUM(ISNULL(t.col14,0)) AS MONEY) AS col14 
				,ISNULL(t.col15,0) Col15
				,COUNT(DISTINCT t.col16) Col16
				,ISNULL(t.col17,0) Col17
		FROM ( 
			SELECT mkb.DiagnosisCode AS Col1,mkb.Diagnosis AS Col2,0 AS Col3,id AS Col4,AmountPayment AS Col5,null AS Col6,
					sum(CASE WHEN m.MU IS NOT NULL THEN m.Quantity ELSE 0 END) AS col7
					,null AS col8,
					p.PID AS col9,NULL AS col10,null AS col11,null AS col12,null AS col13,null AS col14,null AS col15,null AS col16,null AS col17
			FROM #tPeople p INNER JOIN @mkb mkb on
					p.DiagnosisCode=mkb.DiagnosisCode
							LEFT JOIN (SELECT rf_idCase,MU,Quantity from dbo.t_Meduslugi WHERE MU='1.11.1') m ON
					p.id=m.rf_idCase
			WHERE p.rf_idV006=1 AND p.AmountRAK>0
			GROUP BY mkb.DiagnosisCode ,mkb.Diagnosis ,id,AmountPayment,p.PID
			UNION ALL
			SELECT mkb.DiagnosisCode,mkb.Diagnosis,NULL AS Col3,null AS Col4,null AS Col5,null AS Col6,null AS col7,null AS col8,
					null AS col9,NULL AS col10,id AS col11,p.AmountPayment AS col12,NULL AS col13
					,sum(CASE WHEN m.MU IS NOT NULL THEN m.Quantity ELSE 0 END) AS col14,
						NULL AS col15,p.PID AS col16,NULL AS col17
			FROM #tPeople p INNER JOIN @mkb mkb on
					p.DiagnosisCode=mkb.DiagnosisCode
							LEFT JOIN (SELECT m.rf_idCase,m.MU,m.Quantity
									   FROM dbo.t_Meduslugi m  INNER JOIN (values('55.1.1'),('55.1.2'),('55.1.3'),('55.1.5'),('55.2.27')
																				,('55.2.31'),('55.3.18'),('55.3.18'))v(MU) ON
												 m.MU=v.MU
										)m ON
					p.id=m.rf_idCase
			WHERE p.rf_idV006=2 AND p.AmountRAK>0		
			GROUP BY mkb.DiagnosisCode ,mkb.Diagnosis ,id,AmountPayment,p.PID
		) t
		GROUP BY  t.Col1 ,t.Col2 ,t.Col3 ,t.Col6 ,t.col8 ,t.col10 ,t.col13 ,t.col15 ,t.col17
) t
GROUP BY t.Col1 ,t.Col2 
ORDER BY t.Col1

GO
DROP TABLE #tPeople