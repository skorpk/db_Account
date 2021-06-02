USE AccountOMS
go
CREATE TABLE #tDS(ID VARCHAR(10), DS VARCHAR(8))  
CREATE TABLE #tName(Id VARCHAR(10), NameSTR VARCHAR(250), DsName VARCHAR(150))

INSERT #tDS( ID, DS )
select '1.', v.DS from (values('I00'),('I01'),('I02'),('I05'),('I06'),('I07'),('I08'),('I09'),('I10'),('I11'),('I12'),('I13'),('I15'),('I20'),('I21'),('I22'),('I23'),('I24'),('I25'),('I26'),('I27'),('I28'),('I30'),('I31'),('I32'),('I33'),('I34'),('I35'),('I36'),('I37'),('I38'),('I39'),('I40'),('I41'),('I42'),('I43'),('I44'),('I45'),('I46'),('I47'),('I48'),('I49'),('I50'),('I51'),('I52'),('I60'),('I61'),('I62'),('I63'),('I64'),('I65'),('I66'),('I67'),('I68'),('I69'),('I70'),('I71'),('I72'),('I73'),('I74'),('I77'),('I78'),('I79'),('I80'),('I81'),('I82'),('I83'),('I84'),('I85'),('I86'),('I87'),('I88'),('I89'),('I95'),('I97'),('I98'),('I99')) v(DS)
union all select '1.1', v.DS from (values('I00'),('I01'),('I02')) v(DS)
union all select '1.2', v.DS from (values('I05'),('I06'),('I07'),('I08'),('I09')) v(DS)
union all select '1.3', v.DS from (values('I11')) v(DS)
union all select '1.4', v.DS from (values('I12')) v(DS)
union all select '1.5', v.DS from (values('I13')) v(DS)
union all select '1.6', v.DS from (values('I10')) v(DS)
union all select '1.7', v.DS from (values('I21')) v(DS)
union all select '1.8', v.DS from (values('I22')) v(DS)
union all select '1.9', v.DS from (values('I25')) v(DS)
union all select '1.10', v.DS from (values('I26'),('I27'),('I28')) v(DS)
union all select '1.11', v.DS from (values('I30'),('I31'),('I32'),('I33'),('I34'),('I35'),('I36'),('I37'),('I38'),('I39'),('I40'),('I41'),('I42'),('I43'),('I44'),('I45'),('I46'),('I47'),('I48'),('I49'),('I50'),('I51')) v(DS)
union all select '1.12', v.DS from (values('I30')) v(DS)
union all select '1.13', v.DS from (values('I33')) v(DS)
union all select '1.14', v.DS from (values('I40')) v(DS)
union all select '1.15', v.DS from (values('I42')) v(DS)
union all select '1.16', v.DS from (values('I44'),('I45'),('I46'),('I47'),('I48'),('I49'),('I50'),('I51')) v(DS)
union all select '1.17', v.DS from (values('I60')) v(DS)
union all select '1.18', v.DS from (values('I61'),('I62')) v(DS)
union all select '1.19', v.DS from (values('I63')) v(DS)
union all select '1.20', v.DS from (values('I64')) v(DS)
union all select '1.21', v.DS from (values('I65'),('I66')) v(DS)
union all select '1.22', v.DS from (values('I67'),('I68'),('I69')) v(DS)
union all select '1.23', v.DS from (values('I70')) v(DS)
union all select '1.24', v.DS from (values('I71'),('I72'),('I73'),('I74'),('I77'),('I78'),('I79')) v(DS)
union all select '1.25', v.DS from (values('I80'),('I81'),('I82')) v(DS)
union all select '1.26', v.DS from (values('I83'),('I84'),('I85'),('I86'),('I87'),('I88'),('I89')) v(DS)
union all select '1.27', v.DS from (values('I95'),('I97'),('I98'),('I99')) v(DS)
union all select '2.', v.DS from (values('C00'),('C01'),('C02'),('C03'),('C04'),('C05'),('C06'),('C07'),('C08'),('C09'),('C10'),('C11'),('C12'),('C13'),('C14'),('C15'),('C16'),('C17'),('C18'),('C19'),('C20'),('C21'),('C22'),('C23'),('C24'),('C25'),('C26'),('C30'),('C31'),('C32'),('C33'),('C34'),('C37'),('C38'),('C39'),('C40'),('C41'),('C43'),('C44'),('C45'),('C46'),('C47'),('C48'),('C49'),('C50'),('C51'),('C52'),('C53'),('C54'),('C55'),('C56'),('C57'),('C58'),('C60'),('C61'),('C62'),('C63'),('C64'),('C65'),('C66'),('C67'),('C68'),('C69'),('C70'),('C71'),('C72'),('C73'),('C74'),('C75'),('C76'),('C77'),('C78'),('C79'),('C80'),('C81'),('C82'),('C83'),('C84'),('C85'),('C86'),('C88'),('C90'),('C91'),('C92'),('C93'),('C94'),('C95'),('C96'),('C97'),('D00'),('D01'),('D02'),('D03'),('D04'),('D05'),('D06'),('D07'),('D09'),('D10'),('D11'),('D12'),('D13'),('D14'),('D15'),('D16'),('D17'),('D18'),('D19'),('D20'),('D21'),('D22'),('D23'),('D24'),('D25'),('D26'),('D27'),('D28'),('D29'),('D30'),('D31'),('D32'),('D33'),('D34'),('D35'),('D36'),('D37'),('D38'),('D39'),('D40'),('D41'),('D42'),('D43'),('D44'),('D45'),('D46'),('D47'),('D48')) v(DS)
union all select '2.1', v.DS from (values('C00'),('C01'),('C02'),('C03'),('C04'),('C05'),('C06'),('C07'),('C08'),('C09'),('C10'),('C11'),('C12'),('C13'),('C14')) v(DS)
union all select '2.2', v.DS from (values('C15')) v(DS)
union all select '2.3', v.DS from (values('C16')) v(DS)
union all select '2.4', v.DS from (values('C17')) v(DS)
union all select '2.5', v.DS from (values('C18')) v(DS)
union all select '2.6', v.DS from (values('C19'),('C20'),('C21')) v(DS)
union all select '2.7', v.DS from (values('C22')) v(DS)
union all select '2.8', v.DS from (values('C25')) v(DS)
union all select '2.9', v.DS from (values('C23'),( 'C24'),( 'C26')) v(DS)
union all select '2.10', v.DS from (values('C32')) v(DS)
union all select '2.11', v.DS from (values('C33'),('C34')) v(DS)
union all select '2.12', v.DS from (values('C30'),('C31'),('C37'),('C38'),('C39')) v(DS)
union all select '2.13', v.DS from (values('C40'),('C41')) v(DS)
union all select '2.14', v.DS from (values( 'C43')) v(DS)
union all select '2.15', v.DS from (values( 'C44')) v(DS)
union all select '2.16', v.DS from (values('C45'),('C46'),('C47'),('C48'),('C49')) v(DS)
union all select '2.17', v.DS from (values( 'C50')) v(DS)
union all select '2.18', v.DS from (values( 'C53')) v(DS)
union all select '2.19', v.DS from (values('C54'),('C55')) v(DS)
union all select '2.20', v.DS from (values( 'C56')) v(DS)
union all select '2.21', v.DS from (values('C51'),('C52'),('C57'),('C58')) v(DS)
union all select '2.22', v.DS from (values( 'C61')) v(DS)
union all select '2.23', v.DS from (values('C60'),('C62'),('C63')) v(DS)
union all select '2.24', v.DS from (values( 'C64')) v(DS)
union all select '2.25', v.DS from (values( 'C67')) v(DS)
union all select '2.26', v.DS from (values('C65'),('C66'),('C68')) v(DS)
union all select '2.27', v.DS from (values ('C70'),('C71'),('C72')) v(DS)
union all select '2.28', v.DS from (values ('C69'),('C73'),('C74'),('C75'),('C76'),('C77'),('C78'),('C79'),('C80'),('C97')) v(DS)
union all select '2.29', v.DS from (values( 'C81')) v(DS)
union all select '2.30', v.DS from (values('C82'),('C83'),('C84'),('C85')) v(DS)
union all select '2.31', v.DS from (values ('C90')) v(DS)
union all select '2.32', v.DS from (values ('C91'),('C92'),('C93'),('C94'),('C95')) v(DS)
union all select '2.33', v.DS from (values ('C88'),('C96')) v(DS)
union all select '2.34', v.DS from (values('D00'),('D01'),('D02'),('D03'),('D04'),('D05'),('D06'),('D07'),('D09'),('D10'),('D11'),('D12'),('D13'),('D14'),('D15'),('D16'),('D17'),('D18'),('D19'),('D20'),('D21'),('D22'),('D23'),('D24'),('D25'),('D26'),('D27'),('D28'),('D29'),('D30'),('D31'),('D32'),('D33'),('D34'),('D35'),('D36'),('D37'),('D38'),('D39'),('D40'),('D41'),('D42'),('D43'),('D44'),('D45'),('D46'),('D47'),('D48')) v(DS)
union all select '3.', v.DS from (values('G00'),('G01'),('G02'),('G03'),('G04'),('G05'),('G06'),('G07'),('G08'),('G09'),('G10'),('G11'),('G12'),('G13'),('G14'),('G20'),('G21'),('G22'),('G23'),('G24'),('G25'),('G26'),('G30'),('G31'),('G32'),('G35'),('G36'),('G37'),('G40'),('G41'),('G43'),('G44'),('G45'),('G46'),('G47'),('G50'),('G51'),('G52'),('G53'),('G54'),('G55'),('G56'),('G57'),('G58'),('G59'),('G60'),('G61'),('G62'),('G63'),('G64'),('G70'),('G71'),('G72'),('G73'),('G80'),('G81'),('G82'),('G83'),('G90'),('G91'),('G92'),('G93'),('G94'),('G95'),('G96'),('G97'),('G98')) v(DS)
union all select '3.1', v.DS from (values('G00'),('G03')) v(DS)
union all select '3.2', v.DS from (values('G04'),('G06'),( 'G08'),( 'G09')) v(DS)
union all select '3.3', v.DS from (values('G20'),('G21')) v(DS)
union all select '3.4', v.DS from (values( 'G30')) v(DS)
union all select '3.5', v.DS from (values( 'G35')) v(DS)
union all select '3.6', v.DS from (values('G40'),( 'G41')) v(DS)
union all select '3.7', v.DS from (values( 'G80')) v(DS)
union all select '3.8', v.DS from (values('G31'),( 'G36'),( 'G37'),( 'G47'),( 'G10'),('G11'),('G12'),('G23'),('G24'),('G25'),('G43'),('G44'),('G45'),('G50'),('G51'),('G52'),('G53'),('G54'),('G55'),('G56'),('G57'),('G58'),('G59'),('G60'),('G61'),('G62'),('G63'),('G64'),('G70'),('G71'),('G72'),('G81'),('G82'),('G83'),('G90'),('G91'),('G92'),('G93'),('G94'),('G95'),('G96'),('G97'),('G98')) v(DS)
union all select '4.', v.DS from (values('J00'),('J01'),('J02'),('J03'),('J04'),('J05'),('J06'),('J09'),('J10'),('J11'),('J12'),('J13'),('J14'),('J15'),('J16'),('J17'),('J18'),('J20'),('J21'),('J22'),('J30'),('J31'),('J32'),('J33'),('J34'),('J35'),('J36'),('J37'),('J38'),('J39'),('J40'),('J41'),('J42'),('J43'),('J44'),('J45'),('J46'),('J47'),('J60'),('J61'),('J62'),('J63'),('J64'),('J65'),('J66'),('J67'),('J68'),('J69'),('J70'),('J80'),('J81'),('J82'),('J84'),('J85'),('J86'),('J90'),('J91'),('J92'),('J93'),('J94'),('J95'),('J96'),('J98'),('J99')) v(DS)
union all select '4.1', v.DS from (values('J00'),('J01'),('J02'),('J03'),('J04'),('J05'),('J06')) v(DS)
union all select '4.2', v.DS from (values( 'J04')) v(DS)
union all select '4.3', v.DS from (values( 'J05')) v(DS)
union all select '4.4', v.DS from (values('J09'),('J10'),('J11')) v(DS)
union all select '4.5', v.DS from (values( 'J12')) v(DS)
union all select '4.6', v.DS from (values('J13'),('J14'),('J15')) v(DS)
union all select '4.7', v.DS from (values( 'J16')) v(DS)
union all select '4.8', v.DS from (values( 'J18')) v(DS)
union all select '4.9', v.DS from (values('J20'),('J21'),('J22')) v(DS)
union all select '4.10', v.DS from (values( 'J40')) v(DS)
union all select '4.11', v.DS from (values( 'J43')) v(DS)
union all select '4.12', v.DS from (values('J41'),('J42'),('J44')) v(DS)
union all select '4.13', v.DS from (values('J45'),('J46')) v(DS)
union all select '4.14', v.DS from (values( 'J47')) v(DS)
union all select '4.15', v.DS from (values('J60'),('J61'),('J62'),('J63'),('J64'),('J65'),('J66'),('J67'),('J68'),('J69'),('J70')) v(DS)
union all select '4.16', v.DS from (values('J80'),('J81'),('J82'),('J84')) v(DS)
union all select '4.17', v.DS from (values('J85'),('J86')) v(DS)
union all select '4.18', v.DS from (values('J85')) v(DS)
union all select '4.19', v.DS from (values('J30'),('J31'),('J32'),('J33'),('J34'),('J35'),('J36'),('J37'),('J38'),('J39'),('J90'),('J91'),('J92'),('J93'),('J94'),('J95'),('J96'),('J98'),('J99')) v(DS)
union all select '5.', v.DS from (values('K00'),('K01'),('K02'),('K03'),('K04'),('K05'),('K06'),('K07'),('K08'),('K09'),('K10'),('K11'),('K12'),('K13'),('K14'),('K20'),('K21'),('K22'),('K23'),('K25'),('K26'),('K27'),('K28'),('K29'),('K30'),('K31'),('K35'),('K36'),('K37'),('K38'),('K40'),('K41'),('K42'),('K43'),('K44'),('K45'),('K46'),('K50'),('K51'),('K52'),('K55'),('K56'),('K57'),('K58'),('K59'),('K60'),('K61'),('K62'),('K63'),('K64'),('K65'),('K66'),('K67'),('K70'),('K71'),('K72'),('K73'),('K74'),('K75'),('K76'),('K77'),('K80'),('K81'),('K82'),('K83'),('K85'),('K86'),('K87'),('K90'),('K91'),('K92'),('K93')) v(DS)
union all select '5.1', v.DS from (values('K25')) v(DS)
union all select '5.2', v.DS from (values('K26')) v(DS)
union all select '5.3', v.DS from (values('K27')) v(DS)
union all select '5.4', v.DS from (values('K29')) v(DS)
union all select '5.5', v.DS from (values('K35'),('K36'),('K37'),('K38')) v(DS)
union all select '5.6', v.DS from (values('K40'),('K41'),('K42'),('K43'),('K44'),('K45'),('K46')) v(DS)
union all select '5.7', v.DS from (values('K50'),('K51'),('K52')) v(DS)
union all select '5.8', v.DS from (values('K56')) v(DS)
union all select '5.9', v.DS from (values('K70')) v(DS)
union all select '5.10', v.DS from (values('K74')) v(DS)
union all select '5.11', v.DS from (values('K71'),('K72'),('K73'),('K75'),('K76')) v(DS)
union all select '5.12', v.DS from (values('K80')) v(DS)
union all select '5.13', v.DS from (values('K81')) v(DS)
union all select '5.14', v.DS from (values('K85'),('K86')) v(DS)
union all select '5.15', v.DS from (values('K28'),( 'K55'),( 'K82'),( 'K83'),('K00'),('K01'),('K02'),('K03'),('K04'),('K05'),('K06'),('K07'),('K08'),('K09'),('K10'),('K11'),('K12'),('K13'),('K14'),('K20'),('K21'),('K22'),('K23'),('K30'),('K31'),('K90'),('K91'),('K92'),('K93'),('K57'),('K58'),('K59'),('K60'),('K61'),('K62'),('K63'),('K64'),('K65'),('K66')) v(DS)

INSERT #tName
VALUES ('1.','������� ������� �������������� �����, �� ���:','I00-I99'),
('1.1','������ ������������� ���������','I00-I02'),
('1.2','����������� ������������� ������� ������','I05-I09'),
('1.3','��������������� ������� � ���������������� ���������� ������','I11'),
('1.4','��������������� ������� � ���������������� ���������� �����','I12'),
('1.5','��������������� ������� � ���������������� ���������� ������ � �����','I13'),
('1.6','������ ����� �����������','I10'),
('1.7','������ ������� ��������','I21'),
('1.8','��������� ������� ��������','I22'),
('1.9','������������������� ������� ������','I25'),
('1.10','�������� ������ � ��������� ��������� ��������������','I26-I28'),
('1.11','������ ������� ������, �� ���','I30-I51'),
('1.12','������ ����������','I30'),
('1.13','������ � ��������� ����������','I33'),
('1.14','������ ���������','I40'),
('1.15','��������������','I42'),
('1.16','������ ������� ������','I26-I28'),
('1.17','����������������� �������������','I60'),
('1.18','�������������� � ������ �������������� �������������','I61-I62'),
('1.19','������� �����','I63'),
('1.20','�������, �� ���������� ��� ������������� ��� �������','I64'),
('1.21','��������� � ������ ���������������, ������������ �������, �� ���������� � �������� ����� ','I65- I66'),
('1.22','������ ������������������ �������','I67-I69'),
('1.23','������������','I70'),
('1.24','������ ������� �������, �������� � ����������','I71-I79'),
('1.25','������ � ������������, �������� � �������','I80-I82'),
('1.26','������ ������� ��� � ������������� �������','I83-I89'),
('1.27','������ � ������������ ������� ������� ��������������','I95-I99'),
('2.','��������������� �����, �� ���:','C00-C97, D00-D48'),
('2.1','��������������� ��������������� ����, ������� ��� � ������','C00-C14'),
('2.2','��������������� ��������������� ��������','C15'),
('2.3','��������������� ��������������� �������','C16'),
('2.4','��������������� ��������������� ������� ���������, ������� ������������������ �����','C17'),
('2.5','��������������� ��������������� ��������� �����','C18'),
('2.6','��������������� ��������������� ������ �����, ���������������� ����������, ������� ������� � ��������� ������','C19-C21'),
('2.7','��������������� ��������������� ������ � ���������������� ������� ��������','C22'),
('2.8','��������������� ��������������� ������������� ������','C25'),
('2.9','��������������� ��������������� ������ � ������� ������������ ����������� ������� �����������','C23, C24, C26'),
('2.10','��������������� ��������������� �������','C32'),
('2.11','��������������� ��������������� ������, �������, ������','C33, C34'),
('2.12','��������������� ��������������� ������ � ������� ������������ ����������� ������� ������� � ������� ������','C30, C31C37-C39'),
('2.13','��������������� ��������������� ������ � ��������� ������','C40, C41'),
('2.14','��������������� �������� ����','C43'),
('2.15','������ ��������������� ��������������� ����','C44'),
('2.16','��������������� ��������������� �������������� � ������ ������','C45-C49'),
('2.17','��������������� ��������������� ������� ������','C50'),
('2.18','��������������� ��������������� ����� �����','C53'),
('2.19','��������������� ��������������� ������ � ������������ ������ �����','C54, C55'),
('2.20','��������������� ��������������� �������','C56'),
('2.21','��������������� ��������������� ������ � ������������ ������� ������� �������','C51, C52, C57, C58'),
('2.22','��������������� ��������������� �������������� ������','C61'),
('2.23','��������������� ��������������� ������ ������� ������� �������','C60, C62, C63'),
('2.24','��������������� ��������������� �����','C64'),
('2.25','��������������� ��������������� �������� ������','C67'),
('2.26','��������������� ��������������� ������ � ������������ ������� �������','C65, C66, C68'),
('2.27','��������������� ��������������� �������� ��������, ��������� �����, �������� �����, �������-�������� ������ � ������ ������ ������� �������','C70-C72'),
('2.28','��������������� ��������������� ���������� ������','C69, C73-C80, C97'),
('2.29','������� ��������','C81'),
('2.30','������������� �������','C82-C85'),
('2.31','������������� ��������� � ��������������� ���������������','C90'),
('2.32','��������','C91-C95'),
('2.33','��������������� ��������������� ������ � ������� ������������, ��������� � ������������ �����������','C88, C96'),
('2.34','��� in situ, ����������������� ��������������� � ������������ ��������� ���������������','D00-D48'),
('3.','������� ������� ������� �����, �� ���:','G00-G98'),
('3.1','��������, �� ����������� ��������� ��� ������������ � ������������ ������������','G00, G03'),
('3.2','������ �������������� ������� ����������� ������� �������','G04, G06, G08, G09'),
('3.3','������� ����������','G20, G21'),
('3.4','������� �����������','G30'),
('3.5','���������� �������','G35'),
('3.6','���������','G40, G41'),
('3.7','������������ �������','G80'),
('3.8','������ ��������� ������� �������','G10-G12, G23-G25, G31, G36, G37, G43-G45, G47, G50-G72, G81-G98'),
('4.','������� ������� ������� �����, �� ���:','J00-J99'),
('4.1','������ ������������� �������� ������� ����������� �����, �� ���','J00-J06'),
('4.2','������ �������� � �������','J04'),
('4.3','������ ������������� �������� [����] � ����������','J05'),
('4.4','�����','J09-J11'),
('4.5','�������� ���������','J12'),
('4.6','������������� ���������','J13-J15'),
('4.7','������ ������ ���������','J16'),
('4.8','��������� ��� ��������� �����������','J18'),
('4.9','������ ������������� �������� ������ ����������� �����','J20-J22'),
('4.10','������� (������������ ��� ������ ��� �����������)','J40'),
('4.11','��������','J43'),
('4.12','������ ����������� ������������� ����������� ������','J42, J41, J44'),
('4.13','�����','J45-J46'),
('4.14','������������������ �������','J47'),
('4.15','������������� � ������ ������� �������, ��������� �������� ��������','J60-J70'),
('4.16','������ ������������� �������, ���������� ������� ������� ���������������� ����� (������ ���� �������, ������������� �����, ��������� ��������, ��������� � �������������� �������� ������, ���������������� ��������� ��� ������ ��������)','J80-J84'),
('4.17','������� � ������������� ��������� ������ ����������� ����� (������� ������� � �����������, �������� � ������ �������, ������� ������� � ���������� �������)','J85-J86'),
('4.18','   �� ���:    ������ ����������','�85'),
('4.19','������ ������� ������� �������','J30-J39,                  J90-J99'),
('5.','������� ������� ����������� �����, �� ���:','K00-K93'),
('5.1','���� �������','K25'),
('5.2','���� ������������������ �����','K26'),
('5.3','����������� ����, ������������ �����������','K27'),
('5.4','������ �������� � ���������','K29'),
('5.5','������� �������������� �������� (����������)','K35-K38'),
('5.6','�����','K40-K46'),
('5.7','�������������� �������� � ������','K50-K52'),
('5.8','�������������� ����� � �������������� ��������� ��� �����','K56'),
('5.9','����������� ������� ������ (�����������: ������, �������, ������)','K70'),
('5.10','������ � ������ ������ (����� ������������)','K74'),
('5.11','������ ������� ������','K71-K73, K75-K76'),
('5.12','������-�������� ������� (����������)','K80'),
('5.13','����������','K81'),
('5.14','������ ���������� � ������ ������� ������������� ������','K85-K86'),
('5.15','������ ������� ������� �����������','K00-K14, K20-K24, R28, K30-K31, K55, R57-K66, K82, K83, K90-K93')

DECLARE @reportYear SMALLINT=2018,
		@reportMonth TINYINT=6,
		@reportYearLast SMALLINT=2017,
		@reportMonthLast TINYINT=5

;WITH cte
AS(
SELECT o.CodeM,dd.ID,n.NameSTR, n.DSName
		--------------������� �����----------------------------
		,COUNT(CASE WHEN o.rf_idV006=3 AND AP_Type='�' AND ReportMonth=@reportMonth AND ReportYear=@reportYear THEN o.rf_idCase ELSE NULL END) AS  Col_3_P_MM_ThisYY
		,COUNT(CASE WHEN o.rf_idV006=3 AND AP_Type='�' AND ReportMonth=@reportMonth AND ReportYear=@reportYear THEN o.rf_idCase ELSE NULL END) AS  Col_3_O_MM_ThisYY
		,COUNT(CASE WHEN o.rf_idV006=1 AND Gosp_type=0 AND ReportMonth=@reportMonth AND ReportYear=@reportYear THEN o.rf_idCase ELSE NULL END) AS Col_1_PG_MM_ThisYY
		,COUNT(CASE WHEN o.rf_idV006=1 AND Gosp_type>0 AND ReportMonth=@reportMonth AND ReportYear=@reportYear THEN o.rf_idCase ELSE NULL END) AS Col_1_EG_MM_ThisYY
		,COUNT(CASE WHEN o.rf_idV006=2 AND ReportMonth=@reportMonth AND ReportYear=@reportYear THEN o.rf_idCase ELSE NULL END) AS Col_2_MM_ThisYY
		,COUNT(CASE WHEN o.rf_idV006=4 AND ReportMonth=@reportMonth AND ReportYear=@reportYear THEN o.rf_idCase ELSE NULL END) AS Col_4_MM_ThisYY
		-------------����������� ����� ����������� ����---------
		,0 AS Col_3_P_MM_LastYY
		,0 AS Col_3_O_MM_LastYY
		,0 AS Col_1_PG_MM_LastYY
		,0 AS Col_1_EG_MM_LastYY
		,0 AS Col_2_MM_LastYY
		,0 AS Col_4_MM_LastYY
		--------------�� ������� ����� ����� ����----------------------------
		,COUNT(CASE WHEN o.rf_idV006=3 AND AP_Type='�' AND ReportMonth=@reportMonthLast AND ReportYear=@reportYear THEN o.rf_idCase ELSE NULL END) AS  Col_3_P_LM_ThisYY
		,COUNT(CASE WHEN o.rf_idV006=3 AND AP_Type='�' AND ReportMonth=@reportMonthLast AND ReportYear=@reportYear THEN o.rf_idCase ELSE NULL END) AS  Col_3_O_LM_ThisYY
		,COUNT(CASE WHEN o.rf_idV006=1 AND Gosp_type=0 AND ReportMonth=@reportMonthLast AND ReportYear=@reportYear THEN o.rf_idCase ELSE NULL END) AS Col_1_PG_LM_ThisYY
		,COUNT(CASE WHEN o.rf_idV006=1 AND Gosp_type>0 AND ReportMonth=@reportMonthLast AND ReportYear=@reportYear THEN o.rf_idCase ELSE NULL END) AS Col_1_EG_LM_ThisYY
		,COUNT(CASE WHEN o.rf_idV006=2 AND ReportMonth=@reportMonthLast AND ReportYear=@reportYear THEN o.rf_idCase ELSE NULL END) AS Col_2_LM_ThisYY
		,COUNT(CASE WHEN o.rf_idV006=4 AND ReportMonth=@reportMonthLast AND ReportYear=@reportYear THEN o.rf_idCase ELSE NULL END) AS Col_4_LM_ThisYY
FROM dbo.t_OrderAdult_104_2018 o INNER JOIN dbo.vw_sprMKB10 mkb on
			o.DS1=mkb.DiagnosisCode
						INNER join #tDS dd ON
			mkb.MainDS=dd.DS  
						INNER JOIN #tName n ON
			dd.id=n.id      
WHERE o.age>60--o.Age>17 AND o.Age<61
GROUP BY o.CodeM,dd.ID,n.NameSTR, n.DSName
UNION ALL
SELECT o.CodeM,dd.ID,n.NameSTR, n.DSName
		--------------������� �����----------------------------
		,0 AS  Col_3_P_MM_ThisYY
		,0 AS  Col_3_O_MM_ThisYY
		,0 AS Col_1_PG_MM_ThisYY
		,0 AS Col_1_EG_MM_ThisYY
		,0 AS Col_2_MM_ThisYY
		,0 AS Col_4_MM_ThisYY
		-------------����������� ����� ����������� ����---------
		,COUNT(CASE WHEN o.rf_idV006=3 AND AP_Type='�' AND ReportMonth=@reportMonth AND ReportYear=@reportYearLast THEN o.rf_idCase ELSE NULL END) AS Col_3_P_MM_LastYY
		,COUNT(CASE WHEN o.rf_idV006=3 AND AP_Type='�' AND ReportMonth=@reportMonth AND ReportYear=@reportYearLast THEN o.rf_idCase ELSE NULL END) AS Col_3_O_MM_LastYY
		,COUNT(CASE WHEN o.rf_idV006=1 AND Gosp_type=0 AND ReportMonth=@reportMonth AND ReportYear=@reportYearLast THEN o.rf_idCase ELSE NULL END) AS Col_1_PG_MM_LastYY
		,COUNT(CASE WHEN o.rf_idV006=1 AND Gosp_type>0 AND ReportMonth=@reportMonth AND ReportYear=@reportYearLast THEN o.rf_idCase ELSE NULL END) AS Col_1_EG_MM_LastYY
		,COUNT(CASE WHEN o.rf_idV006=2 AND ReportMonth=@reportMonth AND ReportYear=@reportYearLast THEN o.rf_idCase ELSE NULL END) AS Col_2_MM_LastYY
		,COUNT(CASE WHEN o.rf_idV006=4 AND ReportMonth=@reportMonth AND ReportYear=@reportYearLast THEN o.rf_idCase ELSE NULL END) AS Col_4_MM_LastYY
		--------------�� ������� ����� ����� ����----------------------------
		,0 AS  Col_3_P_LM_ThisYY
		,0 AS  Col_3_O_LM_ThisYY
		,0 AS Col_1_PG_LM_ThisYY
		,0 AS Col_1_EG_LM_ThisYY
		,0 AS Col_2_LM_ThisYY
		,0 AS Col_4_LM_ThisYY
FROM dbo.t_OrderAdult_104_2017 o INNER JOIN dbo.vw_sprMKB10 mkb on
			o.DS1=mkb.DiagnosisCode
						INNER join #tDS dd ON
			mkb.MainDS=dd.DS  
						INNER JOIN #tName n ON
			dd.id=n.id   
WHERE o.age>60--o.Age>17 AND o.Age<61
GROUP BY o.CodeM,dd.ID,n.NameSTR, n.DSName
) 
SELECT c.CodeM+' - '+l.NAMES, c.ID,c.NameSTR, c.DSName
		,sum(Col_3_P_MM_ThisYY ) as Col_3_P_MM_ThisYY  
		,sum(Col_3_O_MM_ThisYY ) as Col_3_O_MM_ThisYY  
		,sum(Col_1_PG_MM_ThisYY) as Col_1_PG_MM_ThisYY 
		,sum(Col_1_EG_MM_ThisYY) as Col_1_EG_MM_ThisYY 
		,sum(Col_2_MM_ThisYY	  ) as Col_2_MM_ThisYY	  
		,sum(Col_4_MM_ThisYY	  ) as Col_4_MM_ThisYY	
		,sum(Col_3_P_MM_LastYY ) as Col_3_P_MM_LastYY 
		,sum(Col_3_O_MM_LastYY ) as Col_3_O_MM_LastYY
		,sum(Col_1_PG_MM_LastYY) as Col_1_PG_MM_LastYY
		,sum(Col_1_EG_MM_LastYY) as Col_1_EG_MM_LastYY
		,sum(Col_2_MM_LastYY   ) as Col_2_MM_LastYY
		,sum(Col_4_MM_LastYY   ) as Col_4_MM_LastYY 
		,sum(Col_3_P_LM_ThisYY) as Col_3_P_LM_ThisYY
		,sum(Col_3_O_LM_ThisYY) as Col_3_O_LM_ThisYY
		,sum(Col_1_PG_LM_ThisYY) as Col_1_PG_LM_ThisYY
		,sum(Col_1_EG_LM_ThisYY) as Col_1_EG_LM_ThisYY
		,sum(Col_2_LM_ThisYY) as Col_2_LM_ThisYY
		,sum(Col_4_LM_ThisYY) as Col_4_LM_ThisYY 
from cte c INNER JOIN dbo.vw_sprT001 l ON
		c.codeM=l.CodeM
GROUP BY c.CodeM+' - '+l.NAMES, c.ID,c.NameSTR, c.DSName

GO
DROP TABLE #tDS
DROP TABLE #tName