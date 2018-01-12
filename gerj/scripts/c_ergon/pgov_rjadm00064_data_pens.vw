CREATE OR REPLACE FORCE VIEW PGOV_RJADM00064_DATA_PENS
AS 
    select e.id_data_pens, (case mes_ref when 'JANEIRO' then '01' when 'FEVEREIRO' then '02' when 'MARÇO' then '03' when 'ABRIL' then '04' when 'MAIO' then '05' when 'JULHO' then '06' when 'JUNHO' then '07' when 'AGOSTO' then '08' when 'SETEMBRO' then '09' when 'OUTUBRO' then '10' when 'NOVEMBRO' then '11' when 'DEZEMBRO' then '12' end) mes,
			e.mes_ref, e.grupo_1, e.grupo_2, e.grupo_3, e.grupo_4, e.grupo_5, rowidtochar(e.rowid) rowid_reg
      from pgov_data_pens e
/