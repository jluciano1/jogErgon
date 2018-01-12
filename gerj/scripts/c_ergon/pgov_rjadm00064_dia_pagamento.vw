CREATE OR REPLACE VIEW pgov_rjadm00064_dia_pagamento
AS 
SELECT rowidtochar(p.rowid) rowid_reg,
  p.dia_ativo,
  p.dia_inativo,
  p.id_dia_pagamento,
  p.emp_codigo,
  e.empresa
  || ' - '
  || e.nome descricao
FROM pgov_dia_pagamento p,
  empresas e
WHERE p.emp_codigo = e.empresa
ORDER BY dia_ativo
/