create or replace procedure ttgrj_dml_rjadm00068
  (
    p_oper in varchar2,
    p_rowid_reg in out varchar2,
    p_lista_col in had_typ_array_varchar2 default null,
    pb_dtfim in regras_pensao.dtfim%type default null,
    pb_dtini in regras_pensao.dtini%type default null,
    pb_emp_codigo in regras_pensao.emp_codigo%type default null,
    pb_id_proc_pes in regras_pensao.id_proc_pes%type default null,
    pb_isento_ir in regras_pensao.isento_ir%type default null,
    pb_numfunc in regras_pensao.numfunc%type default null,
    pb_numpens in regras_pensao.numpens%type default null,
    pb_numvinc in regras_pensao.numvinc%type default null,
    pb_obs in regras_pensao.obs%type default null,
    pb_percentual in regras_pensao.percentual%type default null,
    pb_pontlei in regras_pensao.pontlei%type default null,
    pb_pontpubl in regras_pensao.pontpubl%type default null,
    pb_tipopens in regras_pensao.tipopens%type default null,
    pb_vl_saldo in pgov_saldo_bloq_ms605.vl_saldo%type default null,
    pb_dtatualizacao in pgov_saldo_bloq_ms605.dtatualizacao%type default null,
    pb_numdep in pgov_saldo_bloq_ms605.numdep%type default null,
    pb_flex_campo_01 in regras_pensao.flex_campo_01%type default null,
    pb_flex_campo_02 in regras_pensao.flex_campo_02%type default null,
    pb_flex_campo_03 in regras_pensao.flex_campo_03%type default null,
    pb_flex_campo_04 in regras_pensao.flex_campo_04%type default null,
    pb_flex_campo_05 in regras_pensao.flex_campo_05%type default null,
    pb_flex_campo_06 in regras_pensao.flex_campo_06%type default null,
    pb_flex_campo_07 in regras_pensao.flex_campo_07%type default null,
    pb_flex_campo_08 in regras_pensao.flex_campo_08%type default null,
    pb_flex_campo_09 in regras_pensao.flex_campo_09%type default null,
    pb_flex_campo_10 in regras_pensao.flex_campo_10%type default null,
    pb_flex_campo_11 in regras_pensao.flex_campo_11%type default null,
    pb_flex_campo_12 in regras_pensao.flex_campo_12%type default null,
    pb_flex_campo_13 in regras_pensao.flex_campo_13%type default null,
    pb_flex_campo_14 in regras_pensao.flex_campo_14%type default null,
    pb_flex_campo_15 in regras_pensao.flex_campo_15%type default null,
    pb_flex_campo_16 in regras_pensao.flex_campo_16%type default null,
    pb_flex_campo_17 in regras_pensao.flex_campo_17%type default null,
    pb_flex_campo_18 in regras_pensao.flex_campo_18%type default null,
    pb_flex_campo_19 in regras_pensao.flex_campo_19%type default null,
    pb_flex_campo_20 in regras_pensao.flex_campo_20%type default null,
    pb_flex_campo_21 in regras_pensao.flex_campo_21%type default null,
    pb_flex_campo_22 in regras_pensao.flex_campo_22%type default null,
    pb_flex_campo_23 in regras_pensao.flex_campo_23%type default null,
    pb_flex_campo_24 in regras_pensao.flex_campo_24%type default null,
    pb_flex_campo_25 in regras_pensao.flex_campo_25%type default null,
    pb_flex_campo_26 in regras_pensao.flex_campo_26%type default null,
    pb_flex_campo_27 in regras_pensao.flex_campo_27%type default null,
    pb_flex_campo_28 in regras_pensao.flex_campo_28%type default null,
    pb_flex_campo_29 in regras_pensao.flex_campo_29%type default null,
    pb_flex_campo_30 in regras_pensao.flex_campo_30%type default null,
    pp_autoridade in had_publicacoes.autoridade%type default null,
    pp_datado in had_publicacoes.datado%type default null,
    pp_datapubl in had_publicacoes.datapubl%type default null,
    pp_extratocabecpubl in had_publicacoes.extratocabecpubl%type default null,
    pp_extratopubl in had_publicacoes.extratopubl%type default null,
    pp_extratorodappubl in had_publicacoes.extratorodappubl%type default null,
    pp_motivo in had_publicacoes.motivo%type default null,
    pp_numero_processo in had_publicacoes.numero_processo%type default null,
    pp_numpubl in had_publicacoes.numpubl%type default null,
    pp_obs in had_publicacoes.obs%type default null,
    pp_pont in had_publicacoes.pont%type default null,
    pp_situacao in had_publicacoes.situacao%type default null,
    pp_template_ato in had_publicacoes.template_ato%type default null,
    pp_tipodo in had_publicacoes.tipodo%type default null,
    pp_tipopubl in had_publicacoes.tipopubl%type default null,
    pp_usuario in had_publicacoes.usuario%type default null,
    pp_usuarioass in had_publicacoes.usuarioass%type default null,
    pp_usuarioaut in had_publicacoes.usuarioaut%type default null,
    pp_flex_campo_01 in had_publicacoes.flex_campo_01%type default null,
    pp_flex_campo_02 in had_publicacoes.flex_campo_02%type default null,
    pp_flex_campo_03 in had_publicacoes.flex_campo_03%type default null,
    pp_flex_campo_04 in had_publicacoes.flex_campo_04%type default null,
    pp_flex_campo_05 in had_publicacoes.flex_campo_05%type default null,
    pp_flex_campo_06 in had_publicacoes.flex_campo_06%type default null,
    pp_flex_campo_07 in had_publicacoes.flex_campo_07%type default null,
    pp_flex_campo_08 in had_publicacoes.flex_campo_08%type default null,
    pp_flex_campo_09 in had_publicacoes.flex_campo_09%type default null,
    pp_flex_campo_10 in had_publicacoes.flex_campo_10%type default null,
    p_mens out varchar2
)
is
    v_saldo_count number;
    v_rowid rowid;
    
begin
    if p_oper = 'I' then
        insert into regras_pensao (numfunc, numvinc, numpens, tipopens, dtini, dtfim, flex_campo_03, percentual, flex_campo_14, flex_campo_22, flex_campo_23, flex_campo_20, flex_campo_19, obs)
            values (pb_numfunc, pb_numvinc, pb_numpens, pb_tipopens, pb_dtini, pb_dtfim, pb_flex_campo_03, pb_percentual, pb_flex_campo_19, pb_flex_campo_22, pb_flex_campo_23, pb_flex_campo_20, pb_flex_campo_19, pb_obs)
        returning rowid into v_rowid;
        
        p_rowid_reg := rowidtochar(v_rowid);  
        
        select count(numfunc) into v_saldo_count from pgov_saldo_bloq_ms605 where numfunc = pb_numfunc and numvinc = pb_numvinc and numpens = pb_numpens and nome_beneficio = pb_tipopens;
        if v_saldo_count > 0 then
            update pgov_saldo_bloq_ms605 set nome_beneficio = pb_tipopens, vl_saldo = pb_vl_saldo, dt_ini = pb_dtini, dt_fim = pb_dtfim, dtatualizacao = pb_dtatualizacao
                 where numfunc = pb_numfunc
                  and numvinc = pb_numvinc
                  and numpens = pb_numpens
                  and nome_beneficio = pb_tipopens;
        else
            insert into pgov_saldo_bloq_ms605 (numfunc, numvinc, numpens, nome_beneficio, vl_saldo, dt_ini, dt_fim, dtatualizacao)
                values (pb_numfunc, pb_numvinc, pb_numpens, pb_tipopens, pb_vl_saldo, pb_dtini, pb_dtfim, pb_dtatualizacao);
        end if;
    elsif p_oper = 'U' then
        update regras_pensao set tipopens = pb_tipopens, dtini = pb_dtini, dtfim = pb_dtfim, flex_campo_03 = pb_flex_campo_03, percentual = pb_percentual, flex_campo_14 = pb_flex_campo_14, flex_campo_22 = pb_flex_campo_22, flex_campo_23 = pb_flex_campo_23, flex_campo_20 = pb_flex_campo_20, flex_campo_19 = pb_flex_campo_19, obs = pb_obs
            where numfunc = pb_numfunc
              and numvinc = pb_numvinc
              and numpens = pb_numpens;
        select count(numfunc) into v_saldo_count from pgov_saldo_bloq_ms605 where numfunc = pb_numfunc and numvinc = pb_numvinc and numpens = pb_numpens and nome_beneficio = pb_tipopens;
        if v_saldo_count > 0 then
            update pgov_saldo_bloq_ms605 set nome_beneficio = pb_tipopens, vl_saldo = pb_vl_saldo, dt_ini = pb_dtini, dt_fim = pb_dtfim, dtatualizacao = pb_dtatualizacao
                 where numfunc = pb_numfunc
                  and numvinc = pb_numvinc
                  and numpens = pb_numpens
                  and nome_beneficio = pb_tipopens;
        else
            insert into pgov_saldo_bloq_ms605 (numfunc, numvinc, numpens, nome_beneficio, vl_saldo, dt_ini, dt_fim, dtatualizacao)
                values (pb_numfunc, pb_numvinc, pb_numpens, pb_tipopens, pb_vl_saldo, pb_dtini, pb_dtfim, pb_dtatualizacao);
        end if;
    elsif p_oper = 'D' then
        delete from regras_pensao
            where numfunc = pb_numfunc
              and numvinc = pb_numvinc
              and numpens = pb_numpens;
        delete from pgov_saldo_bloq_ms605
             where numfunc = pb_numfunc
              and numvinc = pb_numvinc
              and numpens = pb_numpens
			  and nome_beneficio = pb_tipopens;
    end if;
    commit;
end;
/