--- RJadm 00053 28/07/2017 Arnaldo
CREATE OR REPLACE FORCE 
VIEW TTGRJ_RJADM00053_TP_BF_PARENTE AS
SELECT t.TIPO,
		t.PARENTESCO,
		t.PARENTESCO || ' - ' || (SELECT descr FROM ITEMTABELA WHERE tab = 'Parentesco' and item = t.PARENTESCO) as PARENTESCO_DESC,
		rowidtochar(rowid) as ROWID_REG 
FROM TGRJ_TIPO_BENEF_PARENTESCO t
ORDER BY 2
/