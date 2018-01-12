SET SCAN OFF
ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY HH24:MI:SS';
ALTER SESSION SET NLS_NUMERIC_CHARACTERS = '.,';
EXEC EXEC_SQL_HADES('ALTER TABLE HAD_CAD_MULT_EPS DISABLE ALL TRIGGERS')
INSERT INTO HAD_CAD_MULT_EPS
(AUDITAR, EP, EXEC, ORDEM, SINTAXE, SPROC)
SELECT * FROM (
SELECT AUDITAR,EP,EXEC,ORDEM,SINTAXE,SPROC FROM HAD_CAD_MULT_EPS WHERE 1=0 UNION ALL
SELECT 'N', 'TTGRJ_EPB__REGRAS_PENSAO_02', 'S', TO_NUMBER('3'), 'BEGIN'||CHR(10)||' IF TTGRJ_EPB__REGRAS_PENSAO_02(PCK_REGRAS_PENSAO.V_ROW_NEW,PCK_REGRAS_PENSAO.V_ROW_OLD,:1=''S'',:2=''S'',:3=''S'',:4) THEN '||CHR(10)||'   :5 := ''S'';'||CHR(10)||' ELSE '||CHR(10)||'   :5 := ''N''; '||CHR(10)||' END IF;'||CHR(10)||'END;', 'EPB__REGRAS_PENSAO' FROM DUAL
) TEMP_20171019161522
WHERE (SPROC,EP) NOT IN
  (SELECT SPROC,EP FROM HAD_CAD_MULT_EPS)
/
COMMIT;
INSERT INTO HAD_CAD_MULT_EPS
(AUDITAR, EP, EXEC, ORDEM, SINTAXE, SPROC)
SELECT * FROM (
SELECT AUDITAR,EP,EXEC,ORDEM,SINTAXE,SPROC FROM HAD_CAD_MULT_EPS WHERE 1=0 UNION ALL
SELECT 'N', 'TTGRJ_EPB__REGRAS_PENSAO_03', 'S', TO_NUMBER('4'), 'BEGIN'||CHR(10)||' IF TTGRJ_EPB__REGRAS_PENSAO_03(PCK_REGRAS_PENSAO.V_ROW_NEW,PCK_REGRAS_PENSAO.V_ROW_OLD,:1=''S'',:2=''S'',:3=''S'',:4) THEN '||CHR(10)||'   :5 := ''S'';'||CHR(10)||' ELSE '||CHR(10)||'   :5 := ''N''; '||CHR(10)||' END IF;'||CHR(10)||'END;', 'EPB__REGRAS_PENSAO' FROM DUAL
) TEMP_20171019161522
WHERE (SPROC,EP) NOT IN
  (SELECT SPROC,EP FROM HAD_CAD_MULT_EPS)
/
COMMIT;
INSERT INTO HAD_CAD_MULT_EPS
(AUDITAR, EP, EXEC, ORDEM, SINTAXE, SPROC)
SELECT * FROM (
SELECT AUDITAR,EP,EXEC,ORDEM,SINTAXE,SPROC FROM HAD_CAD_MULT_EPS WHERE 1=0 UNION ALL
SELECT 'N', 'TTGRJ_EPB__REGRAS_PENSAO_04', 'S', TO_NUMBER('5'), 'BEGIN'||CHR(10)||' IF TTGRJ_EPB__REGRAS_PENSAO_04(PCK_REGRAS_PENSAO.V_ROW_NEW,PCK_REGRAS_PENSAO.V_ROW_OLD,:1=''S'',:2=''S'',:3=''S'',:4) THEN '||CHR(10)||'   :5 := ''S'';'||CHR(10)||' ELSE '||CHR(10)||'   :5 := ''N''; '||CHR(10)||' END IF;'||CHR(10)||'END;', 'EPB__REGRAS_PENSAO' FROM DUAL
) TEMP_20171019161522
WHERE (SPROC,EP) NOT IN
  (SELECT SPROC,EP FROM HAD_CAD_MULT_EPS)
/
COMMIT;
INSERT INTO HAD_CAD_MULT_EPS
(AUDITAR, EP, EXEC, ORDEM, SINTAXE, SPROC)
SELECT * FROM (
SELECT AUDITAR,EP,EXEC,ORDEM,SINTAXE,SPROC FROM HAD_CAD_MULT_EPS WHERE 1=0 UNION ALL
SELECT 'N', 'TTGRJ_EPB__REGRAS_PENSAO_05', 'S', TO_NUMBER('6'), 'BEGIN'||CHR(10)||' IF TTGRJ_EPB__REGRAS_PENSAO_05(PCK_REGRAS_PENSAO.V_ROW_NEW,PCK_REGRAS_PENSAO.V_ROW_OLD,:1=''S'',:2=''S'',:3=''S'',:4) THEN '||CHR(10)||'   :5 := ''S'';'||CHR(10)||' ELSE '||CHR(10)||'   :5 := ''N''; '||CHR(10)||' END IF;'||CHR(10)||'END;', 'EPB__REGRAS_PENSAO' FROM DUAL
) TEMP_20171019161522
WHERE (SPROC,EP) NOT IN
  (SELECT SPROC,EP FROM HAD_CAD_MULT_EPS)
/
COMMIT;
INSERT INTO HAD_CAD_MULT_EPS
(AUDITAR, EP, EXEC, ORDEM, SINTAXE, SPROC)
SELECT * FROM (
SELECT AUDITAR,EP,EXEC,ORDEM,SINTAXE,SPROC FROM HAD_CAD_MULT_EPS WHERE 1=0 UNION ALL
SELECT 'N', 'TTGRJ_EPB__REGRAS_PENSAO_06', 'S', TO_NUMBER('7'), 'BEGIN'||CHR(10)||' IF TTGRJ_EPB__REGRAS_PENSAO_06(PCK_REGRAS_PENSAO.V_ROW_NEW,PCK_REGRAS_PENSAO.V_ROW_OLD,:1=''S'',:2=''S'',:3=''S'',:4) THEN '||CHR(10)||'   :5 := ''S'';'||CHR(10)||' ELSE '||CHR(10)||'   :5 := ''N''; '||CHR(10)||' END IF;'||CHR(10)||'END;', 'EPB__REGRAS_PENSAO' FROM DUAL
) TEMP_20171019161522
WHERE (SPROC,EP) NOT IN
  (SELECT SPROC,EP FROM HAD_CAD_MULT_EPS)
/
COMMIT;
INSERT INTO HAD_CAD_MULT_EPS
(AUDITAR, EP, EXEC, ORDEM, SINTAXE, SPROC)
SELECT * FROM (
SELECT AUDITAR,EP,EXEC,ORDEM,SINTAXE,SPROC FROM HAD_CAD_MULT_EPS WHERE 1=0 UNION ALL
SELECT 'N', 'TTGRJ_EPB__REGRAS_PENSAO_07', 'S', TO_NUMBER('8'), 'BEGIN'||CHR(10)||' IF TTGRJ_EPB__REGRAS_PENSAO_07(PCK_REGRAS_PENSAO.V_ROW_NEW,PCK_REGRAS_PENSAO.V_ROW_OLD,:1=''S'',:2=''S'',:3=''S'',:4) THEN '||CHR(10)||'   :5 := ''S'';'||CHR(10)||' ELSE '||CHR(10)||'   :5 := ''N''; '||CHR(10)||' END IF;'||CHR(10)||'END;', 'EPB__REGRAS_PENSAO' FROM DUAL
) TEMP_20171019161522
WHERE (SPROC,EP) NOT IN
  (SELECT SPROC,EP FROM HAD_CAD_MULT_EPS)
/
COMMIT;
INSERT INTO HAD_CAD_MULT_EPS
(AUDITAR, EP, EXEC, ORDEM, SINTAXE, SPROC)
SELECT * FROM (
SELECT AUDITAR,EP,EXEC,ORDEM,SINTAXE,SPROC FROM HAD_CAD_MULT_EPS WHERE 1=0 UNION ALL
SELECT 'N', 'EPB__REGRAS_PENSAO', 'S', TO_NUMBER('2'), 'BEGIN IF TGRJ_EPB__REGRAS_PENSAO (PCK_REGRAS_PENSAO.V_ROW_NEW, PCK_REGRAS_PENSAO.V_ROW_OLD,:1=''S'',:2=''S'',:3=''S'',:4) THEN :5 := ''S''; ELSE :5 := ''N''; END IF;END;', 'EPB__REGRAS_PENSAO' FROM DUAL
) TEMP_20171019161522
WHERE (SPROC,EP) NOT IN
  (SELECT SPROC,EP FROM HAD_CAD_MULT_EPS)
/
COMMIT;
EXEC EXEC_SQL_HADES('ALTER TABLE HAD_CAD_MULT_EPS ENABLE ALL TRIGGERS')
SET SCAN ON