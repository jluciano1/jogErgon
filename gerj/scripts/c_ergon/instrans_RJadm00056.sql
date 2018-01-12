SET SCAN OFF
ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY HH24:MI:SS';
ALTER SESSION SET NLS_NUMERIC_CHARACTERS = '.,';
EXEC EXEC_SQL_HADES('ALTER TABLE TRANSACAO DISABLE ALL TRIGGERS')
INSERT INTO TRANSACAO
(CHAVE, FLEX_CAMPO_01, FLEX_CAMPO_02, FLEX_CAMPO_03, FLEX_CAMPO_04, FLEX_CAMPO_05, FLEX_CAMPO_06, FLEX_CAMPO_07, FLEX_CAMPO_08, FLEX_CAMPO_09, FLEX_CAMPO_10, FORMTRANS, FORMTRANSCUST, ITEMMENU, LOGGING, NOMENOMENU, NOMEREDUZIDO, NOMETRANS, PUBLICATRANS, QRY_POS_ROLLBACK, SIS, TRANS)
SELECT * FROM (
SELECT CHAVE,FLEX_CAMPO_01,FLEX_CAMPO_02,FLEX_CAMPO_03,FLEX_CAMPO_04,FLEX_CAMPO_05,FLEX_CAMPO_06,FLEX_CAMPO_07,FLEX_CAMPO_08,FLEX_CAMPO_09,FLEX_CAMPO_10,FORMTRANS,FORMTRANSCUST,ITEMMENU,LOGGING,NOMENOMENU,NOMEREDUZIDO,NOMETRANS,PUBLICATRANS,QRY_POS_ROLLBACK,SIS,TRANS FROM TRANSACAO WHERE 1=0 UNION ALL
SELECT '', '', '', '', '', '', '', '', '', '', '', '', '', 'RJADM00056', 'N', '', '', 'Rubricas Base Calc Pens�o', 'N', '', 'C_Ergon', 'RJadm00035' FROM DUAL
) TEMP_20160920160306
WHERE (SIS,TRANS) NOT IN
  (SELECT SIS,TRANS FROM TRANSACAO)
/
COMMIT;
EXEC EXEC_SQL_HADES('ALTER TABLE TRANSACAO ENABLE ALL TRIGGERS')
SET SCAN ON
