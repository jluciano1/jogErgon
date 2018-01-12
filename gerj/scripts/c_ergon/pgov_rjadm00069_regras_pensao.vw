CREATE OR REPLACE FORCE VIEW pgov_rjadm00069_regras_pensao
AS 
  SELECT rp.numpens, p.nome, rp.dtini, rp.dtfim, rp.percentual, rp.numfunc, rp.numvinc, rowidtochar(rp.rowid) rowid_reg
     FROM regras_pensao rp
LEFT JOIN pensionistas p ON p.numfunc = rp.numfunc 
                        AND p.numvinc = rp.numvinc
                        AND p.numero = rp.numpens
/