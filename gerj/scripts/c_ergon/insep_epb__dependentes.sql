SET SCAN OFF
ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY HH24:MI:SS';
ALTER SESSION SET NLS_NUMERIC_CHARACTERS = '.,';
EXEC EXEC_SQL_HADES('ALTER TABLE HAD_CAD_MULT_EPS DISABLE ALL TRIGGERS')
INSERT INTO HAD_CAD_MULT_EPS
(AUDITAR, EP, EXEC, ORDEM, SINTAXE, SPROC)
SELECT * FROM (
SELECT AUDITAR,EP,EXEC,ORDEM,SINTAXE,SPROC FROM HAD_CAD_MULT_EPS WHERE 1=0 UNION ALL
SELECT 'N', 'TTGRJ_EPB__DEPENDENTES', 'S', TO_NUMBER('1'), 'BEGIN'||CHR(10)||' IF TTGRJ_EPB__DEPENDENTES(PCK_DEPENDENTES.V_ROW_NEW,PCK_DEPENDENTES.V_ROW_OLD,:1=''S'',:2=''S'',:3=''S'',:4) THEN '||CHR(10)||'   :5 := ''S'';'||CHR(10)||' ELSE '||CHR(10)||'   :5 := ''N''; '||CHR(10)||' END IF;'||CHR(10)||'END;', 'EPB__DEPENDENTES' FROM DUAL
) TEMP_20160901155631
WHERE (SPROC,EP) NOT IN
  (SELECT SPROC,EP FROM HAD_CAD_MULT_EPS)
/
COMMIT;
EXEC EXEC_SQL_HADES('ALTER TABLE HAD_CAD_MULT_EPS ENABLE ALL TRIGGERS')
SET SCAN ON