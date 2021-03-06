 CREATE OR REPLACE FORCE VIEW "C_ERGON"."TTGRJ_RJADM00053_TIPO_BENEF" ("TIPO", "DESCRICAO", "GRUPO_RATEIO", "FLEX_CAMPO_01", "FLEX_CAMPO_01_DESC", "FLEX_CAMPO_02", "FLEX_CAMPO_03", "FLEX_CAMPO_04", "FLEX_CAMPO_05", "ROWID_REG") AS 
  SELECT t.TIPO,
        t.DESCRICAO,
        t.GRUPO_RATEIO,
        t.FLEX_CAMPO_01,
        CASE t.FLEX_CAMPO_01 WHEN 'S' THEN 'SIM' ELSE 'N�O' END FLEX_CAMPO_01_DESC,
        t.FLEX_CAMPO_02,
        t.FLEX_CAMPO_03,
        t.FLEX_CAMPO_04,
        t.FLEX_CAMPO_05,
		rowidtochar(rowid) as ROWID_REG
FROM TGRJ_TIPO_BENEF t
ORDER BY 2

/