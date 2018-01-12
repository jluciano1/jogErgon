create or replace view ttgrj_rjadm00009_vw_lista_ret as
select fv.mes_ano_folha,
       fv.num_folha,
       fv.ficha lancamento,
       fr.linha,
       fv.numfunc,
       fv.numvinc,
       fv.numpens,
       fr.mes_ano_direito,
       fr.rubrica,
       fr.tipo_rubrica,
       fr.desc_vant,
       fr.complemento,
       fr.valor,
       f.tipo_folha,
       f.tipo_calculo,
       f.data_consol,
       f.emp_codigo,
       decode( pck_folhas.eh_consolidada (fv.mes_ano_folha, fv.num_folha),1,'S','N') as consolidada,
       (select nome_abrev from cerg_vw_rubricas where rubrica = fr.rubrica) as nome_abrev,
       null flex_campo_01,
       null flex_campo_02,
       null flex_campo_03,
       null flex_campo_04,
       null flex_campo_05,
       null flex_campo_06,
       null flex_campo_07,
       null flex_campo_08,
       null flex_campo_09,
       null flex_campo_10
from fichas_vinculos fv,
     fichas_retencao fr,
     folhas_emp f
where f.emp_codigo = flag_pack.get_empresa
  and fv.mes_ano_folha = f.mes_ano
  and fv.num_folha = f.numero
  and fv.emp_codigo = f.emp_codigo
  and fv.ficha = fr.ficha
  and (fr.desc_vant <> 0)
  and ( (fr.tipo_rubrica <> 3 and fr.valor <> 0) or (fr.tipo_rubrica = 3 and fr.correcao <> 0) )
 -- and (pck_folhas.eh_consolidada (f.mes_ano, f.numero, f.emp_codigo) = 1)
  and mostra_ficha( flag_pack.get_usuario, f.mes_ano, f.numero, f.emp_codigo ) = 1
union all
select fv.mes_ano_folha,
       fv.num_folha,
       fv.ficha lancamento,
       fr.linha,
       fv.numfunc,
       fv.numvinc,
       fv.numpens,
       fr.mes_ano_direito,
       fr.rubrica,
       fr.tipo_rubrica,
       fr.desc_vant,
       fr.complemento,
       fr.valor,
       f.tipo_folha,
       f.tipo_calculo,
       f.data_consol,
       f.emp_codigo,
       decode( pck_folhas.eh_consolidada (fv.mes_ano_folha, fv.num_folha),1,'S','N') as consolidada,
       (select nome_abrev from cerg_vw_rubricas where rubrica = fr.rubrica) as nome_abrev,
       null flex_campo_01,
       null flex_campo_02,
       null flex_campo_03,
       null flex_campo_04,
       null flex_campo_05,
       null flex_campo_06,
       null flex_campo_07,
       null flex_campo_08,
       null flex_campo_09,
       null flex_campo_10
from fichas_vinculos fv,
     fichas_retencao fr,
     folhas_emp f
where f.emp_codigo = 77
  and fv.mes_ano_folha = f.mes_ano
  and fv.num_folha = f.numero
  and fv.emp_codigo = f.emp_codigo
  and fv.ficha = fr.ficha
  and (fr.desc_vant <> 0)
  and ( (fr.tipo_rubrica <> 3 and fr.valor <> 0) or (fr.tipo_rubrica = 3 and fr.correcao <> 0) )
 -- and (pck_folhas.eh_consolidada (f.mes_ano, f.numero, f.emp_codigo) = 1)
  and mostra_ficha( flag_pack.get_usuario, f.mes_ano, f.numero, f.emp_codigo ) = 1;
/