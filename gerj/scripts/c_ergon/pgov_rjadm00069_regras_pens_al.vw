CREATE OR REPLACE FORCE VIEW pgov_rjadm00069_regras_pens_al
AS 
  SELECT al.numdep, d.nome, al.dtini, al.dtfim, al.percentual, al.numfunc, al.numvinc, rowidtochar(al.rowid) rowid_reg
     FROM regras_pensao_al al 
LEFT JOIN dependentes d ON d.numfunc = al.numfunc
                       AND d.numero = al.numdep
/