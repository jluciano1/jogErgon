CREATE OR REPLACE 
PROCEDURE TGRJ_EXEC_RELAT_LOTE(p_mes_ano       IN  DATE
                              ,p_subemp_array  IN  HAD_TYP_ARRAY_NUMBER
                              ,p_relat_array   IN  HAD_TYP_ARRAY_VARCHAR2
                              ,p_ativo         IN  VARCHAR2
                              ,p_inativo       IN  VARCHAR2
                              ,p_lote          OUT NUMBER
                              ,p_mens          OUT VARCHAR2)

AS

  array_param       had_typ_array_varchar2;
  array_valor       had_typ_array_varchar2;
  v_out             BOOLEAN := TRUE;
  v_sit             VARCHAR2(20);
  i                 NUMBER;
  v_ret             NUMBER;
  v_arquivo         VARCHAR2(200);
  v_mens            VARCHAR2(4000);

CURSOR c1 (p_nome_rel IN varchar2)
  IS  SELECT REL.ARQUIVO, REL.NOME, HPR.PARAMETRO, HPR.VALOR_DEFAULT
      FROM GRUPO_RELATORIOS GRE,
           RELATORIOS       REL,
           HAD_PARAM_RELAT  HPR
      WHERE GRE.CODIGO = REL.GRUPO_CODIGO
      AND REL.NOME = HPR.RELATORIO
      AND GRE.SISTEMA = 'C_Ergon'
      AND GRE.CODIGO in ('08 - Folha Mensal', 
                         '14 - Erro Bradesco', 
                         '18 - Relat�rios de Auditoria - P�s-Processamento', 
                         '08 - Folha Mensal Pensionista')
      AND REL.nome = p_nome_rel
      AND HPR.PARAMETRO LIKE 'P_%';

  BEGIN
    -- Nome dos par�metros dos relat�rios
    array_param := had_typ_array_varchar2();
    -- Valor dos par�metros dos relat�rios
    array_valor := had_typ_array_varchar2();

    -- Verifica se o M�s/Ano foi informado
    IF p_mes_ano IS NULL THEN
      p_mens := 'Favor informar o "m�s ano folha� caso nenhuma folha estiver selecionada.';
      RETURN;
    END IF;
    
    -- Verifica se ao menos uma das situa��es foi marcada
    IF p_ativo = 'N' AND p_inativo = 'N' THEN
      p_mens := 'Favor informar pelo menos uma situa��o.';
      RETURN;
    END IF;
    
    -- Verifica se ao menos uma subempresa foi selecionada
    IF p_subemp_array.count = 0 THEN
      p_mens := 'Ao menos uma empresa deve ser selecionada para execu��o em lote.';
      RETURN;
    END IF;

    -- Verificar se ao menos um relat�rio foi selecionado
    IF p_relat_array.count = 0 THEN
      p_mens := 'Ao menos um relat�rio deve ser selecionado para execu��o em lote.';
      RETURN;
    END IF;


    -- N�mero do lote da execu��o
    p_lote := tgrj_relat_util.get_next_lote_seq();
    
    -- Controle de execu��o para situa��o ativo e inativo.
    WHILE v_out LOOP

      IF p_ativo = 'S' and p_inativo = 'N'  THEN
        v_sit := 'ATIVO';
        v_out := FALSE ;
      ELSIF p_inativo = 'S' and p_ativo = 'N' THEN
        v_sit := 'INATIVO';
        v_out := FALSE;
      ELSE
        IF v_sit = 'INATIVO' THEN
          v_out := FALSE;
        ELSE
           v_sit := 'ATIVO';
        END IF;
      END IF;
      

      BEGIN
        -- Controle de execu��o por subempresa
        FOR sub IN 1..p_subemp_array.last LOOP

          -- Controle de execu��o por relat�rios
          FOR r IN 1..p_relat_array.last LOOP
           
            -- Vari�vel de controle do array de par�metros
            i := 0;
            
            -- Preenche os arrays de par�metros e valores
            FOR p IN c1 (p_relat_array(r)) LOOP
              
              i := i + 1;
              array_param.extend();
              array_valor.extend();      
              array_param(i) := p.parametro;
              v_arquivo := p.arquivo;

              -- Preenche par�metros em comum  
              CASE p.parametro
                  WHEN 'P_SISTEMA' THEN 
                    array_valor(i) := 'C_Ergon';
                  WHEN 'P_SITUACAO' THEN      
                    array_valor(i) := v_sit;
                  WHEN 'P_EMPRESA' THEN       
                    array_valor(i) := v_sit;
                  WHEN 'P_MES_ANO' THEN 
                    array_valor(i) := p_mes_ano;
                  WHEN 'P_MES_ANO_FOLHA' THEN 
                    array_valor(i) := p_mes_ano;
                  WHEN 'P_SECRETARIA' THEN 
                    array_valor(i) := p_subemp_array(sub);
                  ELSE 
                    -- Preenche valor padr�o (se existir) ou remove da lista de par�metros
                    IF (p.VALOR_DEFAULT IS NOT NULL) THEN
                      array_valor(i) :=  p.VALOR_DEFAULT;
                    ELSE
                      array_param.trim();
                      array_valor.trim();
                      i := i - 1;
                    END IF;
              END CASE;            

            END LOOP;

            -- Gera agendamento do relat�rio
            v_ret := TGRJ_RELAT_UTIL.GERA_REQ_AGENDA_REP(1,                       -- P_REPETICAO   NUMBER,
                                                         flag_pack.get_usuario(), -- P_USUARIO     VARCHAR2,
                                                         p_relat_array(r),        -- P_RELATORIO   VARCHAR2,
                                                         sysdate,                 -- P_DATA_AGENDA DATE,
                                                         flag_pack.get_empresa(), -- P_EMPRESA     VARCHAR2,
                                                         1,                       -- P_EXPIRACAO   NUMBER,
                                                         v_arquivo,               -- P_ARQUIVO     VARCHAR2,
                                                         array_param,             -- P_PARAMETRO HAD_TYP_ARRAY_VARCHAR2 DEFAULT NULL,
                                                         array_valor,             -- P_VALOR HAD_TYP_ARRAY_VARCHAR2 DEFAULT NULL,
                                                         v_mens);                 -- P_MENS OUT VARCHAR2

            IF v_mens IS NOT NULL OR v_ret IS NULL THEN
              P_MENS := 'Erro ao agendar o relat�rio '||p_relat_array(r)||' ERRO:'||v_mens;
              ROLLBACK;
              RETURN;
            END IF;

            -- Insere registro de agendamento no lote
            INSERT INTO TGRJ_LOTE_REPORT (ID_LOTE, ID_AGENDA, SIS, TRANS) 
            VALUES (p_lote, v_ret, 'C_Ergon', 'RJadm00026');

            array_param.DELETE;
            array_valor.DELETE;
          END LOOP;

        END LOOP;
        COMMIT;
      EXCEPTION
        WHEN OTHERS THEN
          ROLLBACK;
          ergon_erro_pack.trata_erro(99, 'Erro ao executar agendamento em lote');
      END;

      -- controle a ativos ou inativos
      v_sit := 'INATIVO';
    END LOOP;

  END TGRJ_EXEC_RELAT_LOTE;
/
