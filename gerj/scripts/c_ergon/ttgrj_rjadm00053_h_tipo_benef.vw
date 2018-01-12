--- RJadm 00053 28/07/2017 Arnaldo
CREATE OR REPLACE FORCE 
VIEW TTGRJ_RJADM00053_H_TIPO_BENEF AS
SELECT t.TIPO,
		t.DTINI,
		t.DTFIM,
		t.DECRETO,
		t.IDADE,
		t.CONDICAO,
		CASE t.CONDICAO WHEN 'M' THEN 'Masculino' WHEN 'F' THEN 'Feminino'  ELSE 'Ambos' END CONDICAO_DESC,
		t.IDADE_EXT,
		t.RECADASTRAMENTO,
		t.QTDE_MIN_DOC,
		rowidtochar(rowid) as ROWID_REG 
FROM TGRJ_HIST_TIPO_BENEF t
ORDER BY 2
/