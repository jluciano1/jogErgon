CREATE OR REPLACE FORCE VIEW pgov_rjadm00070_email_acao 
AS 
SELECT e.id_email_acao, e.numfunc, f.nome, e.acao, e.email, rowidtochar(e.rowid) rowid_reg
FROM pgov_email_acao e
INNER JOIN funcionarios f ON f.numero = e.numfunc
/