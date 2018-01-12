SET SCAN OFF
ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY HH24:MI:SS';
ALTER SESSION SET NLS_NUMERIC_CHARACTERS = '.,';
EXEC EXEC_SQL_HADES('ALTER TABLE ROTINAS DISABLE ALL TRIGGERS')
INSERT INTO ROTINAS
(ARQUIVO, DESCRICAO, FLEX_CAMPO_01, FLEX_CAMPO_02, FLEX_CAMPO_03, FLEX_CAMPO_04, FLEX_CAMPO_05, FLEX_CAMPO_06, FLEX_CAMPO_07, FLEX_CAMPO_08, FLEX_CAMPO_09, FLEX_CAMPO_10, GRUPO, INIBE_ACIONAMENTO, LOGGING, ROTINA, SIS, TIPO)
SELECT * FROM (
SELECT ARQUIVO,DESCRICAO,FLEX_CAMPO_01,FLEX_CAMPO_02,FLEX_CAMPO_03,FLEX_CAMPO_04,FLEX_CAMPO_05,FLEX_CAMPO_06,FLEX_CAMPO_07,FLEX_CAMPO_08,FLEX_CAMPO_09,FLEX_CAMPO_10,GRUPO,INIBE_ACIONAMENTO,LOGGING,ROTINA,SIS,TIPO FROM ROTINAS WHERE 1=0 UNION ALL
SELECT 'PGOV_ASSOCIA_CARGO_DISCIP', 'Rotina de Combina��o de Cargos v�lidos � Categoria e Subcategoria informada', '', '', '', '', '', '', '', '', '', '', 'RJERGNG', 'N', 'N', 'Combina Cargos a Categoria', 'C_Ergon', 'B' FROM DUAL
) TEMP_20160923101539
WHERE (GRUPO,SIS,ROTINA) NOT IN
  (SELECT GRUPO,SIS,ROTINA FROM ROTINAS)
/
COMMIT;
EXEC EXEC_SQL_HADES('ALTER TABLE ROTINAS ENABLE ALL TRIGGERS')
SET SCAN ON