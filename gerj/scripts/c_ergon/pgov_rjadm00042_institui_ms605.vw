CREATE OR REPLACE FORCE VIEW "C_ERGON"."PGOV_RJADM00042_INSTITUI_MS605" ("NUMFUNC", "NUMERO", "NUMVINC", "FLEX_CAMPO_04", "NOME", "CPF",
"FLEX_CAMPO_21", "EMP_CODIGO", "MATRICULA", "CATEGORIA", "DESC_FLEX_CAMPO_21", "DTAPOSENT", "TIPOAPOS") AS
  SELECT v.numfunc,
       v.numero,
       p.numvinc,
       p.flex_campo_04,
       f.nome,
       f.cpf,
       f.flex_campo_21,
       v.emp_codigo,
       v.matricula,
       v.categoria,
       decode(f.flex_campo_25,
              'P',
              'Paridade',
              'I',
              'Índice RGPS') as desc_flex_campo_21,
       v.dtaposent,
       v.tipoapos
  FROM vinculos v, funcionarios f, pensionistas p
 where v.numfunc = f.numero
   and v.numfunc = p.numfunc
   and v.numero  = p.numvinc
/
