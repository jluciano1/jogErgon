CREATE OR REPLACE FUNCTION ttgrj_rjadm00073(
    p_empresa    IN VARCHAR2,
    p_subempresa IN VARCHAR2,
    p_dtini      IN DATE,
    p_dtfim      IN DATE,
    p_tp_grupo   IN VARCHAR2,
    p_operador   IN VARCHAR2)
  RETURN ttgrj_typ_rjadm00073_tab PIPELINED
IS
  CURSOR c1
  IS
    SELECT a.transacao,
      a.tabela,
      SUM(DECODE (a.operacao, 'I',1,0)) Inclusao,
      SUM(DECODE (a.operacao, 'U',1,0)) Alteracao,
      SUM(DECODE (a.operacao, 'D',1,0)) Exclusao,
      (SUM(DECODE (a.operacao, 'I',1,0)) + SUM(DECODE (a.operacao, 'U',1,0)) + SUM(DECODE (a.operacao, 'D',1,0))) Total
    FROM erg_auditoria a,
      usuario u,
      itemtabela i
    WHERE a.usuario                                                  = u.usuario
    AND ((flag_pack.get_empresa                                     <> 77
    AND ((flag_pack.get_empresa                                      = 1
    AND pack_ergon.get_subempresa_func(a.numfunc, a.numvinc,sysdate) = p_subempresa
    AND a.emp_codigo                                                 = u.emp_codigo
    AND u.flex_campo_10                                             IS NULL
    AND u.privil                                                     = 'N')
    OR (a.emp_codigo                                                 = p_empresa
    AND p_empresa                                                   <> 1
    AND a.emp_codigo                                                 = u.emp_codigo
    AND u.flex_campo_10                                             IS NULL
    AND u.privil                                                     = 'N')))
    OR (p_empresa                                                    = 77
    AND u.flex_campo_10                                              = 'SIM'
    AND u.privil                                                     = 'N')) --VALIDO
    AND a.usuario NOT                                               IN ('zeus', 'PRODUCAO','MIGRA')
    AND i.tab                                                        = 'PGOV_AUDITORIA_NIV1'
    AND a.transacao                                                  = i.item
    AND TRUNC(a.DATAHORA) BETWEEN p_dtini AND p_dtfim
    AND ((a.tabela IN ('ERG_APOSENTADORIA','EVENTO_FUNC')
    AND p_tp_grupo  = 'Com_CAD')
    OR (a.tabela   IN ('FOL_MOVIMENTOS_PE','PENSIONISTAS','REGRAS_PENSAO','VANT_PENS')
    AND p_tp_grupo  = 'Com_PENS')
    OR (a.tabela   IN ('VINCULOS','CESSOES','EXERCICIOS')
    AND p_tp_grupo  = 'Com_VINC')
    OR (a.tabela   IN ('FOL_MOVIMENTOS','VANTAGENS')
    AND p_tp_grupo  = 'Com_PAG')
    OR (a.tabela   IN ('FREQUENCIAS')
    AND p_tp_grupo  = 'Com_FREQ')
    OR --FREQUENCIA
      (a.tabela   IN ('AVERB_OQUE_CONTA','PRE_CONTA','PERAQLICESP','LIC_ESP','AVERBACOES_CONTA')
    AND p_tp_grupo = 'Com_BENEF')
    OR --DEPENDENTES. Em análise.
      (a.tabela   IN ('DEPENDENCIAS','REGRAS_PENSAO_AL','VANT_DEP')
    AND p_tp_grupo = 'Com_DEP'))
    GROUP BY a.tabela,
      a.transacao
    ORDER BY a.tabela,
      a.transacao;
  /*Pesquisa por Operador*/
  CURSOR c2
  IS
    SELECT DISTINCT a.usuario,
      a.transacao,
      a.tabela,
      SUM(DECODE (a.operacao, 'I',1,0)) Inclusao,
      SUM(DECODE (a.operacao, 'U',1,0)) Alteracao,
      SUM(DECODE (a.operacao, 'D',1,0)) Exclusao,
      (SUM(DECODE (a.operacao, 'I',1,0)) + SUM(DECODE (a.operacao, 'U',1,0)) + SUM(DECODE (a.operacao, 'D',1,0))) Total
    FROM ERG_AUDITORIA A,
      ITEMTABELA I
    WHERE((flag_pack.get_empresa                                     = 1
    AND pack_ergon.get_subempresa_func(a.numfunc, a.numvinc,sysdate) = p_subempresa)
    OR (a.emp_codigo                                                 = p_empresa
    AND a.emp_codigo                                                <> 1)
    OR (p_empresa                                                    = 77))
    AND a.usuario                                                    = p_operador
    AND TRUNC(a.DATAHORA) BETWEEN p_dtini AND p_dtfim
    AND i.tab       = 'PGOV_AUDITORIA_NIV1'
    AND a.transacao = i.item
    AND a.tabela   IN ('EVENTO_FUNC','ERG_APOSENTADORIA','CESSOES','FOL_MOVIMENTOS_PE','PENSIONISTAS','REGRAS_PENSAO','VANT_PENS','VINCULOS', 'EXERCICIOS','FOL_MOVIMENTOS','VANTAGENS','AVERB_OQUE_CONTA','PRE_CONTA','PERAQLICESP','LIC_ESP','AVERBACOES_CONTA','DEPENDENCIAS', 'REGRAS_PENSAO_AL','VANT_DEP','FREQUENCIAS') -- FREQUENCIA
    GROUP BY a.usuario,
      a.tabela,
      a.transacao
    ORDER BY a.usuario,
      a.tabela,
      a.transacao;
BEGIN
  IF p_operador IS NULL THEN
    FOR x IN c1
    LOOP
      pipe row ( ttgrj_typ_rjadm00073(x.transacao,x.tabela,x.inclusao,x.alteracao,x.exclusao,x.total) ) ;
    END LOOP;
    --
  ELSE
    FOR y IN c2
    LOOP
      pipe row ( ttgrj_typ_rjadm00073(y.transacao,y.tabela,y.inclusao,y.alteracao,y.exclusao,y.total) ) ;
    END LOOP;
    --
  END IF;
RETURN;
END;
/