CREATE OR REPLACE FORCE 
VIEW RJADM00056_RUBR_BASE_CALC_PENS 
AS 
  SELECT rowidtochar(t.ROWID) rowid_reg,
         t.ID,
         t.DTINI,
         t.DTFIM,
         t.RUBRICA,
         t.RUBRICA||' - '||r.NOME rubrica_descr,
         t.COMPLEMENTO,
         t.COMPOE_BASE_PENSAO,
         CASE t.COMPOE_BASE_PENSAO
              WHEN 'S' THEN 'SIM'
              WHEN 'N' THEN 'NÃO'
              WHEN 'T' THEN 'TALVEZ'
              ELSE '' END  compoe_base_pensao_descr
    FROM TGRJ_RUBRICA_PENSAO t
  JOIN RUBRICAS r ON r.RUBRICA = t.RUBRICA
/
