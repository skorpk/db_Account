USE AccountOMS
GO
DECLARE @mkb AS TABLE(DiagnosisCode VARCHAR(3),Diagnosis VARCHAR(250))
INSERT @mkb 
VALUES ('C00','Злокачественное новообразование губы'),
('C01','Зно основания языка'),
('C02','Злокачественное новообразование других и неуточненных частей языка'),
('C03','Злокачественное новообразование десны'),
('C04','Злокачественное новообразование дна полости рта'),
('C05','Злокачественное новообразование неба'),
('C06','Злокачественное новообразование других и неуточненных отделов рта'),
('C07','Зно околоушной слюнной железы'),
('C08','Злокачественное новообразование других и неуточненных больших слюнных желез'),
('C09','Злокачественное новообразование миндалины'),
('C10','Злокачественное новообразование ротоглотки'),
('C11','Злокачественное новообразование носоглотки'),
('C12','Зно грушевидного синуса'),
('C13','Злокачественное новообразование нижней части глотки'),
('C14','Злокачественное новообразование других и неточно обозначенных локализаций губы, полости рта и глотки'),
('C15','Злокачественное новообразование пищевода'),
('C16','Злокачественное новообразование желудка'),
('C17','Злокачественное новообразование тонкого кишечника'),
('C18','Злокачественное новообразование ободочной кишки'),
('C19','Зно ректосигмоидного соединения'),
('C20','Зно прямой кишки'),
('C21','Злокачественное новообразование заднего прохода [ануса] и анального канала'),
('C22','Злокачественное новообразование печени и внутрипеченочных желчных протоков'),
('C23','Зно желчного пузыря'),
('C24','Злокачественное новообразование других и неуточненных частей желчевыводящих путей'),
('C25','Злокачественное новообразование поджелудочной железы'),
('C26','Злокачественное новообразование других и неточно обозначенных органов пищеварения'),
('C30','Злокачественное новообразование полости носа и среднего уха'),
('C31','Злокачественное новообразование придаточных пазух'),
('C32','Злокачественное новообразование гортани'),
('C33','Зно трахеи'),
('C34','Злокачественное новообразование бронхов и легких'),
('C37','Зно вилочковой железы'),
('C38','Злокачественное новообразование сердца, средостенения и плевры'),
('C39','Злокачественное новообразование других и неточно обозначенных локализаций органов дыхания и внутригрудных органов'),
('C40','Злокачественное новообразование костей и суставных хрящей конечностей'),
('C41','Злокачественное новообразование костей и суставных хрящей других и неуточненных локализаций'),
('C43','Злокачественная мелонома кожи'),
('C44','Другие злокачественные новообразования кожи'),
('C45','Мезотелиома'),
('C46','Саркома капоши'),
('C47','Злокачественное новообразование периферических нервов и вегетативной нервной системы'),
('C48','Злокачественное новообразование забрюшиного пространства и брюшины'),
('C49','Злокачественное новообразование других типов соединительной и мягких тканей'),
('C50','Злокачественное новообразование молочной железы'),
('C51','Злокачественное новообразование вульвы'),
('C52','Зно влагалища'),
('C53','Злокачественное новообразование шейки матки'),
('C54','Злокачественное новообразование тела матки'),
('C55','Зно матки неуточненной локализации'),
('C56','Зно яичника'),
('C57','Злокачественное новообразование других и неуточненных женских половых органов'),
('C58','Зно плаценты'),
('C60','Злокачественное новообразование полового члена'),
('C61','Зно предстательной железы'),
('C62','Злокачественное новообразование яичка'),
('C63','Злокачественное новообразование других и неуточненных мужских половых органов'),
('C64','Зно почки, кроме почечной лоханки'),
('C65','Зно почечной лоханки'),
('C66','Зно мочеточника'),
('C67','Злокачественное новообразование мочевого пузыря'),
('C68','Злокачественное новообразование других и неуточненных мочевых органов'),
('C69','Злокачественное новообразование глаза и его придаточного аппарата'),
('C70','Злокачественное новообразование мозговых оболочек'),
('C71','Злокачественное новообразование головного мозга'),
('C72','Злокачественное новообразование спинного мозга, черепных нервов и других отделов центральной нервной системы'),
('C73','Злокачественное новообразование щитовидной железы'),
('C74','Злокачественное новообразование надпочечника'),
('C75','Злокачественное новообразование других эндокринных желез и родственных структур'),
('C76','Злокачественное новообразование других и неточно обозначенных локализаций'),
('C77','Вторичное и неточное злокачественное новообразование лимфатических узлов'),
('C78','Вторичное злокачественное новообразование органов дыхания и пищеварения'),
('C79','Вторичное злокачественное новообразование других локализаций'),
('C80','Зно без уточнения локализации'),
('C81','Болезнь ходжкина [лимфогранулематоз]'),
('C82','Фолликулярная [нодулярная] неходжскинская лимфома'),
('C83','Диффузная неходжкинская лимфома'),
('C84','Периферические и кожные т-клеточные лимфомы'),
('C85','Другие неуточненные типы неходжкинской лимфомы'),
('C88','Злокачественные иммунопролиферативные болезни'),
('C90','Множественная миелома и злокачественные плазмоклеточные новообразования'),
('C91','Лимфоидный лейкоз [лимфолейкоз]'),
('C92','Миелоидный лейкоз [миелолейкоз]'),
('C93','Моноцитарный лейкоз'),
('C94','Другой лейкоз уточненного клеточного типа'),
('C95','Лейкоз неуточненного клеточного типа'),
('C96','Другие и неуточненные злокачественные новообразования лимфоидной, кроветворной и родственных им тканей'),
('C97','Злокачественные новообразования самостоятельных (первичных) множественных локализаций')


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