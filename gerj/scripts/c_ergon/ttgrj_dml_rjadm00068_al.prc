create or replace procedure ttgrj_dml_rjadm00068_al
( 
    p_oper in varchar2,
    p_rowid_reg in out varchar2,
    p_lista_col in had_typ_array_varchar2 default null,
    pb_base in regras_pensao_al.base%type default null,
    pb_chavepa in regras_pensao_al.chavepa%type default null,
    pb_dtfim in regras_pensao_al.dtfim%type default null,
    pb_dtini in regras_pensao_al.dtini%type default null,
    pb_emp_codigo in regras_pensao_al.emp_codigo%type default null,
    pb_numdep in regras_pensao_al.numdep%type default null,
    pb_numfunc in regras_pensao_al.numfunc%type default null,
    pb_numsalfam in regras_pensao_al.numsalfam%type default null,
    pb_numvinc in regras_pensao_al.numvinc%type default null,
    pb_obs in regras_pensao_al.obs%type default null,    
    pb_vl_saldo in pgov_saldo_bloq_ms605.vl_saldo%type default null,
    pb_dtatualizacao in pgov_saldo_bloq_ms605.dtatualizacao%type default null, 
    pb_numpens in regras_pensao.numpens%type default null,
    pb_paga_13 in regras_pensao_al.paga_13%type default null,
    pb_paga_abono in regras_pensao_al.paga_abono%type default null,
    pb_paga_abono_const in regras_pensao_al.paga_abono_const%type default null,
    pb_paga_adiant_fer in regras_pensao_al.paga_adiant_fer%type default null,
    pb_percentual in regras_pensao_al.percentual%type default null,
    pb_pontlei in regras_pensao_al.pontlei%type default null,
    pb_pontpubl in regras_pensao_al.pontpubl%type default null,
    pb_tiporeaj in regras_pensao_al.tiporeaj%type default null,
    pb_flex_campo_01 in regras_pensao_al.flex_campo_01%type default null,
    pb_flex_campo_02 in regras_pensao_al.flex_campo_02%type default null,
    pb_flex_campo_03 in regras_pensao_al.flex_campo_03%type default null,
    pb_flex_campo_04 in regras_pensao_al.flex_campo_04%type default null,
    pb_flex_campo_05 in regras_pensao_al.flex_campo_05%type default null,
    pb_flex_campo_06 in regras_pensao_al.flex_campo_06%type default null,
    pb_flex_campo_07 in regras_pensao_al.flex_campo_07%type default null,
    pb_flex_campo_08 in regras_pensao_al.flex_campo_08%type default null,
    pb_flex_campo_09 in regras_pensao_al.flex_campo_09%type default null,
    pb_flex_campo_10 in regras_pensao_al.flex_campo_10%type default null,
    pb_flex_campo_11 in regras_pensao_al.flex_campo_11%type default null,
    pb_flex_campo_12 in regras_pensao_al.flex_campo_12%type default null,
    pb_flex_campo_13 in regras_pensao_al.flex_campo_13%type default null,
    pb_flex_campo_14 in regras_pensao_al.flex_campo_14%type default null,
    pb_flex_campo_15 in regras_pensao_al.flex_campo_15%type default null,
    pb_flex_campo_16 in regras_pensao_al.flex_campo_16%type default null,
    pb_flex_campo_17 in regras_pensao_al.flex_campo_17%type default null,
    pb_flex_campo_18 in regras_pensao_al.flex_campo_18%type default null,
    pb_flex_campo_19 in regras_pensao_al.flex_campo_19%type default null,
    pb_flex_campo_20 in regras_pensao_al.flex_campo_20%type default null,
    pb_flex_campo_21 in regras_pensao_al.flex_campo_21%type default null,
    pb_flex_campo_22 in regras_pensao_al.flex_campo_22%type default null,
    pb_flex_campo_23 in regras_pensao_al.flex_campo_23%type default null,
    pb_flex_campo_24 in regras_pensao_al.flex_campo_24%type default null,
    pb_flex_campo_25 in regras_pensao_al.flex_campo_25%type default null,
    pb_flex_campo_26 in regras_pensao_al.flex_campo_26%type default null,
    pb_flex_campo_27 in regras_pensao_al.flex_campo_27%type default null,
    pb_flex_campo_28 in regras_pensao_al.flex_campo_28%type default null,
    pb_flex_campo_29 in regras_pensao_al.flex_campo_29%type default null,
    pb_flex_campo_30 in regras_pensao_al.flex_campo_30%type default null,
    pb_flex_campo_31 in regras_pensao_al.flex_campo_31%type default null,
    pb_flex_campo_32 in regras_pensao_al.flex_campo_32%type default null,
    pb_flex_campo_33 in regras_pensao_al.flex_campo_33%type default null,
    pb_flex_campo_34 in regras_pensao_al.flex_campo_34%type default null,
    pb_flex_campo_35 in regras_pensao_al.flex_campo_35%type default null,
    pb_flex_campo_36 in regras_pensao_al.flex_campo_36%type default null,
    pb_flex_campo_37 in regras_pensao_al.flex_campo_37%type default null,
    pb_flex_campo_38 in regras_pensao_al.flex_campo_38%type default null,
    pb_flex_campo_39 in regras_pensao_al.flex_campo_39%type default null,
    pb_flex_campo_40 in regras_pensao_al.flex_campo_40%type default null,
    pb_flex_campo_41 in regras_pensao_al.flex_campo_41%type default null,
    pb_flex_campo_42 in regras_pensao_al.flex_campo_42%type default null,
    pb_flex_campo_43 in regras_pensao_al.flex_campo_43%type default null,
    pb_flex_campo_44 in regras_pensao_al.flex_campo_44%type default null,
    pb_flex_campo_45 in regras_pensao_al.flex_campo_45%type default null,
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
    v_chavepa number;
    v_saldo_count number;
    v_rowid rowid;
begin
    if p_oper = 'I' then
        v_chavepa := REGRAS_PENSAO_AL_SEQ.nextval;       
        insert into regras_pensao_al (numfunc, numvinc, numdep, base, dtini, dtfim, percentual, flex_campo_12, chavepa, obs)
            values (pb_numfunc, pb_numvinc, pb_numdep, pb_base, pb_dtini, pb_dtfim, pb_percentual, pb_flex_campo_12, v_chavepa, pb_obs)
        returning rowid into v_rowid;
        
        p_rowid_reg := rowidtochar(v_rowid);  
        
        select count(*) into v_saldo_count from pgov_saldo_bloq_ms605 where numfunc = pb_numfunc and numvinc = pb_numvinc and numdep = pb_numdep and nome_beneficio = pb_base;
        if v_saldo_count > 0 then
            update pgov_saldo_bloq_ms605 set nome_beneficio = pb_base, vl_saldo = pb_vl_saldo, dt_ini = pb_dtini, dt_fim = pb_dtfim, dtatualizacao = pb_dtatualizacao
                 where numfunc = pb_numfunc
                  and numvinc = pb_numvinc
                  and numdep = pb_numdep
                  and nome_beneficio = pb_base;
        else
            insert into pgov_saldo_bloq_ms605 (numfunc, numvinc, numdep, nome_beneficio, vl_saldo, dt_ini, dt_fim, dtatualizacao)
                values (pb_numfunc, pb_numvinc, pb_numdep, pb_base, pb_vl_saldo, pb_dtini, pb_dtfim, pb_dtatualizacao);
        end if;
    elsif p_oper = 'U' then
        update regras_pensao_al set base = pb_base, dtini = pb_dtini, dtfim = pb_dtfim, percentual = pb_percentual, flex_campo_12 = pb_flex_campo_12, obs = pb_obs
            where numfunc = pb_numfunc
              and numvinc = pb_numvinc
              and numdep = pb_numdep;              
        select count(*) into v_saldo_count from pgov_saldo_bloq_ms605 where numfunc = pb_numfunc and numvinc = pb_numvinc and numdep = pb_numdep and nome_beneficio = pb_base;
        if v_saldo_count > 0 then
            update pgov_saldo_bloq_ms605 set nome_beneficio = pb_base, vl_saldo = pb_vl_saldo, dt_ini = pb_dtini, dt_fim = pb_dtfim, dtatualizacao = pb_dtatualizacao
                 where numfunc = pb_numfunc
                  and numvinc = pb_numvinc
                  and numdep = pb_numdep
                  and nome_beneficio = pb_base;
        else
            insert into pgov_saldo_bloq_ms605 (numfunc, numvinc, numdep, nome_beneficio, vl_saldo, dt_ini, dt_fim, dtatualizacao)
                values (pb_numfunc, pb_numvinc, pb_numdep, pb_base, pb_vl_saldo, pb_dtini, pb_dtfim, pb_dtatualizacao);
        end if;
    elsif p_oper = 'D' then
        delete from regras_pensao_al
            where numfunc = pb_numfunc
              and numvinc = pb_numvinc
              and numdep = pb_numdep;
        delete from pgov_saldo_bloq_ms605 
             where numfunc = pb_numfunc
              and numvinc = pb_numvinc
              and numdep = pb_numdep
			  and nome_beneficio = pb_base;
    end if;
    commit;
end;
/