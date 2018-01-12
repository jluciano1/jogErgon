create or replace view ttgrj_rjadm00009_vw_rub_aux as
select mes_ano_folha,
       num_folha,
       lancamento,
       numfunc,
       numvinc,
       numpens,
       mes_ano_direito,
       rubrica,
       tipo_rubrica,
       desc_vant,
       complemento,
       valor,
       tipo_folha,
       tipo_calculo,
       data_consol,
       (select c.nome_abrev from cerg_vw_rubricas c where c.rubrica = erg_erg0046_fichas_financ_aux.rubrica) as nome_abrev,
       decode( pck_folhas.eh_consolidada (mes_ano_folha, num_folha),1,'S','N') as consolidada,
       flex_campo_01,
       flex_campo_02,
       flex_campo_03,
       flex_campo_04,
       flex_campo_05,
       flex_campo_06,
       flex_campo_07,
       flex_campo_08,
       flex_campo_09,
       flex_campo_10,
       null as linha,
       emp_codigo
  from erg_erg0046_fichas_financ_aux
union
select fv.mes_ano_folha,
       fv.num_folha,
       fv.ficha lancamento,
       fv.numfunc,
       fv.numvinc,
       fv.numpens,
       fr.mes_ano_direito,
       fr.rubrica,
       decode(fr.correcao, null, fr.tipo_rubrica, 0, fr.tipo_rubrica, 3) tipo_rubrica,
       fr.desc_vant,
       fr.complemento,
       decode(fr.correcao, null, fr.valor, 0, fr.valor, fr.correcao) valor,
       f.tipo_folha,
       f.tipo_calculo,
       f.data_consol,
       (select c.nome_abrev from cerg_vw_rubricas c where c.rubrica = fr.rubrica) as nome_abrev,
       decode( pck_folhas.eh_consolidada (fv.mes_ano_folha, fv.num_folha),1,'S','N') as consolidada,
       null flex_campo_01,
       null flex_campo_02,
       null flex_campo_03,
       null flex_campo_04,
       null flex_campo_05,
       null flex_campo_06,
       null flex_campo_07,
       null flex_campo_08,
       null flex_campo_09,
       null flex_campo_10,
       null as linha,
       f.emp_codigo
  from fichas_vinculos fv, fichas_rubricas fr, folhas_emp f
 where f.emp_codigo = 77
   and fv.mes_ano_folha = f.mes_ano
   and fv.num_folha = f.numero
   and fv.ficha = fr.ficha
   and mostra_ficha(flag_pack.get_usuario, fv.mes_ano_folha, fv.num_folha, 77) = 1;
/