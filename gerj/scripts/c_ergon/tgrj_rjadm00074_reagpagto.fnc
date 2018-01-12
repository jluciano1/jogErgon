CREATE OR REPLACE 
FUNCTION TGRJ_RJADM00074_REAGPAGTO (P_MES_ANO_FOLHA      IN DATE
                                   ,P_NUM_FOLHA          IN NUMBER
                                   ,P_TIPO_ACAO          IN VARCHAR2)
RETURN TGRJ_TYP_RJADM00074REPAGTO_TAB
PIPELINED
IS
  TYPE refCurso IS REF CURSOR;

  vc     refCurso;    
  v_sql  VARCHAR2(4000);

  v_rec  TGRJ_TYP_RJADM00074REPAGTO := TGRJ_TYP_RJADM00074REPAGTO( NULL
                                                                  ,NULL
                                                                  ,NULL
                                                                  ,NULL
                                                                  ,NULL
                                                                  ,NULL
                                                                  ,NULL
                                                                  ,NULL
                                                                  ,NULL
                                                                  ,NULL
                                                                  ,NULL
                                                                  ,NULL
                                                                  ,NULL
                                                                  ,NULL
                                                                  ,NULL
                                                                  ,NULL
                                                                  ,NULL
                                                                  ,NULL
                                                                  ,NULL
                                                                  ,NULL);
BEGIN

  v_sql := 'SELECT DISTINCT PF.NUMFUNC,                          '||
                           ',PF.NUMVINC,                         '||
                           ',PF.NUMDEPEN,                        '||
                           ',PF.NUMPENS,                         '||
                           ',PF.NUMREP,                          '||
                           ',PF.VALORLIQ,                        '||
                           ',PF.EMP_CODIGO,                      '||
                           ',PF.SUBEMP_CODIGO,                   '||
                           ',PF.VALOR,                           '||
                           ',PF.PERCENTUAL,                      '||
                           ',PF.NUMFITA,                         '||
                           ',PF.LANCAMENTO,                      '||
                           ',PF.MES_ANO,                         '||
                           ',PF.NUMERO,                          '||
                           ',PF.AGENCIA_SALARIO,                 '||
                           ',PF.CONTA_SALARIO,                   '||
                           ',PF.AGENCIA,                         '||
                           ',PF.CONTA,                           '||
                           ',PF.NOME,                            '||
                           ',PF.SITUACAO                         '||
           'FROM PGOV_FITABANCO_CREDITOS PF,                     '||
           '      TGRJ_ARQUIVO_RETORNO    AR,                    '||
           '      TGRJ_DETALHE_RETORNO    DR                     '||
           ' WHERE AR.ID_ARQUIVO_RETORNO = DR.ID_ARQUIVO_RETORNO '||
           '   AND AR.MES_ANO_FOLHA = PF.MES_ANO                 '||
           '   AND AR.NUM_FOLHA     = PF.NUMERO                  '||
           '   AND DR.NIVEL_INF_RETORNO <> ''3''                 '||
           '   AND PF.NUMFUNC BETWEEN ( SELECT MIN(numero) FROM funcionarios ) AND (SELECT MAX(numero) FROM funcionarios) '||
           '   AND DR.LANCAMENTO = PF.LANCAMENTO    '||
           '   AND DR.MES_ANO_SIGRH = PF.MES_ANO    '||
           '   AND DR.NUM_FOLHA_SIGRH = PF.NUMERO   '||
           '   AND PF.EMP_CODIGO = flag_pack.get_empresa()       '||
           '   AND PF.NUMERO = :1                   '||
           '   AND PF.MES_ANO = :2 ';
           
  IF P_TIPO_ACAO  = 'R' THEN	
    v_sql := v_sql || ' AND NOT EXISTS (SELECT 1 FROM TGRJ_DETALHE_RETORNO DR1  '||
                                       'WHERE DR1.LANCAMENTO = PF.LANCAMENTO    '||
                                          'AND (DR1.RETORNO_1 = ''BW'' OR (DR1.RETORNO_1 = ''BT'' AND DR1.DATA_CRED = TRUNC(SYSDATE)))) '||
                       'AND EXISTS (SELECT 1 FROM TGRJ_ARQUIVO_REMESSA AR '||
                                   'WHERE AR.NUMFITA = PF.NUMFITA)';
  ELSIF P_TIPO_ACAO  = 'B' THEN
    v_sql := v_sql || ' AND EXISTS (SELECT 1 FROM TGRJ_DETALHE_RETORNO DR1 '||
                                   'WHERE DR1.LANCAMENTO = PF.LANCAMENTO   '||
                                     'AND DR1.RETORNO_1 = ''BT'' AND DR1.DATA_CRED >= TRUNC(SYSDATE))';	
  END IF;
           

  if vc%isopen then
    close vc;
  end if;

  open vc for v_sql
  using P_NUM_FOLHA, P_MES_ANO_FOLHA;

    fetch vc into v_rec.NUMFUNC
                 ,v_rec.NUMVINC
                 ,v_rec.NUMDEPEN
                 ,v_rec.NUMPENS
                 ,v_rec.NUMREP
                 ,v_rec.VALORLIQ
                 ,v_rec.EMP_CODIGO
                 ,v_rec.SUBEMP_CODIGO
                 ,v_rec.VALOR
                 ,v_rec.PERCENTUAL
                 ,v_rec.NUMFITA
                 ,v_rec.LANCAMENTO
                 ,v_rec.MES_ANO
                 ,v_rec.NUMERO
                 ,v_rec.AGENCIA_SALARIO
                 ,v_rec.CONTA_SALARIO
                 ,v_rec.AGENCIA
                 ,v_rec.CONTA
                 ,v_rec.NOME
                 ,v_rec.SITUACAO;
  loop

  exit when vc%notfound;

    pipe row (v_rec);

    fetch vc into v_rec.NUMFUNC
                 ,v_rec.NUMVINC
                 ,v_rec.NUMDEPEN
                 ,v_rec.NUMPENS
                 ,v_rec.NUMREP
                 ,v_rec.VALORLIQ
                 ,v_rec.EMP_CODIGO
                 ,v_rec.SUBEMP_CODIGO
                 ,v_rec.VALOR
                 ,v_rec.PERCENTUAL
                 ,v_rec.NUMFITA
                 ,v_rec.LANCAMENTO
                 ,v_rec.MES_ANO
                 ,v_rec.NUMERO
                 ,v_rec.AGENCIA_SALARIO
                 ,v_rec.CONTA_SALARIO
                 ,v_rec.AGENCIA
                 ,v_rec.CONTA
                 ,v_rec.NOME
                 ,v_rec.SITUACAO;

  end loop;

  if vc%isopen then
    close vc;
  end if;

  RETURN;

EXCEPTION
  WHEN OTHERS THEN

    if vc%isopen then
      close vc;
    end if;

    RETURN;

END TGRJ_RJADM00074_REAGPAGTO;
/                                      