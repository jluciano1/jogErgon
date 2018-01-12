create or replace FUNCTION "TGRJ_EPB__ERG_INGRESSO_02"(
    P_ROW_NEW   IN OUT NOCOPY ERG_INGRESSO%ROWTYPE,
    P_ROW_OLD  IN ERG_INGRESSO%ROWTYPE,
    P_INSERTING IN BOOLEAN,
    P_UPDATING  IN BOOLEAN,
    P_DELETING  IN BOOLEAN,
    P_MENS OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN
IS
  v_vinc_ant   NUMBER := 0;
  v_dtvac      DATE;
  no_data      NUMBER := 0;
  v_empresa    NUMBER := 0;
  v_emp_logada NUMBER := flag_pack.get_empresa;
  v_data_posse DATE;
  v_count      NUMBER;                 --Bernardo Cámera SGD-875
  v_plano vinculos.flex_campo_16%type; --Bernardo Cámera SGD-875
  v_existe_cargo NUMBER := 0;
  v_qtde_cargo   NUMBER := 0; --Bernardo 13/07/2015
  v_dtaposent    DATE;        --Bernardo 03/08/2015
  -- SGD 2635 22/02/2016
  v_emp_codigo empresas.empresa%type;
  --
BEGIN
  IF P_INSERTING OR P_UPDATING THEN
    BEGIN
      --Bernardo 03/08/2015 Início
      BEGIN
        SELECT dtaposent
        INTO v_dtaposent
        FROM vinculos
        WHERE numfunc = P_ROW_NEW.numfunc
        AND numero    = P_ROW_NEW.numvinc;
      EXCEPTION
      WHEN no_data_found THEN
        v_dtaposent := NULL;
      WHEN OTHERS THEN
        v_dtaposent := NULL;
      END;
      BEGIN
        SELECT dtvac
        INTO v_dtvac
        FROM vinculos
        WHERE numfunc = P_ROW_NEW.numfunc
        AND numero    = P_ROW_NEW.numvinc;
      EXCEPTION
      WHEN no_data_found THEN
        v_dtvac := NULL;
      WHEN OTHERS THEN
        v_dtvac := NULL;
      END;
      --Bernardo 03/08/2015 Fim
      IF (v_dtaposent IS NOT NULL) OR (v_dtvac IS NOT NULL) THEN
        NULL;
      elsif (v_dtaposent IS NULL) AND (v_dtvac IS NULL) THEN
        --Bernardo 13/07/2015 Início
        BEGIN
          SELECT COUNT(1)
          INTO v_qtde_cargo
          FROM cargos_
          WHERE categoria LIKE '01 MAGISTERIO'
          AND cargo = P_ROW_NEW.cargo;
        EXCEPTION
        WHEN OTHERS THEN
          v_qtde_cargo := 0;
        END;
        IF v_qtde_cargo = 1 AND P_ROW_NEW.flex_campo_09 IS NULL THEN
          p_mens := 'Quando a Categoria é igual a MAGISTERIO , é obrigatório informar a Disciplina de Ingresso!';
          RETURN (true);
        END IF;
        --Bernardo 13/07/2015 Fim
      END IF; --Bernardo 03/08/2015
      --Bernardo 30/06/2015 Início
      BEGIN
        SELECT 1
        INTO v_existe_cargo
        FROM rh_atividade_ a,
          rh_ativ_cargo ac
        WHERE a.codigo       = ac.atividade
        AND ac.cargo         = P_ROW_NEW.CARGO
        AND a.flex_campo_02 IN ('INGRESSO','ING/EXEC');
      EXCEPTION
      WHEN no_data_found THEN
        v_existe_cargo := 0;
      WHEN OTHERS THEN
        v_existe_cargo := 0;
      END;
      IF v_existe_cargo = 1 AND P_ROW_NEW.FLEX_CAMPO_01 IS NULL THEN
        p_mens := 'Para este Cargo do Ingresso é Necessário informar a Atividade/Especialidade.';
        RETURN (true);
      END IF;
      --Bernardo 30/06/2015 Fim
      --Bernardo 30/06/2015 Início
      IF to_date(P_ROW_NEW.dtposse,'dd/mm/yyyy') >= to_date('04/09/2013','dd/mm/yyyy') THEN -- A Data de Posse é SUPERIOR à 04/09/2013
        IF (P_ROW_NEW.regimejur                       = 'ESTATUTO CIVIL')                       --regime jurídico é ESTATUTO CIVIL
          AND (P_ROW_NEW.tipovinc                     = 'CONCURSO PUBLICO') THEN                --vínculo é igual à CONCURSO PUBLICO
          IF P_ROW_NEW.FLEX_CAMPO_26                 IS NULL THEN                               -- Informar se teve vínculo ininterrupto
            p_mens := 'Para data de exercício maior que 04/09/2013 é obrigatório informar se teve vínculo estatutário ininterrúpto.';
            RETURN (true);
          END IF;
          IF P_ROW_NEW.FLEX_CAMPO_26    = 'SIM' THEN -- VALIDAÇÃO SE TEVE VINCULO ININTERRUPTO
            IF P_ROW_NEW.FLEX_CAMPO_28 IS NULL THEN
              p_mens := 'Para quem teve vínculo ininterrúpto tem que informar o Órgão do mesmo na aba Vínculo Anterior.';
              RETURN (true);
            END IF;
            --
            IF P_ROW_NEW.FLEX_CAMPO_29 IS NULL THEN
              p_mens := 'Para quem teve vínculo ininterrúpto tem que informar a Data de Posse do mesmo na aba Vínculo Anterior.';
              RETURN (true);
            END IF;
            IF P_ROW_NEW.FLEX_CAMPO_30 IS NULL THEN
              p_mens := 'Para quem teve vínculo ininterrúpto tem que informar se teve Previdência Complementar na aba Vínculo Anterior.';
              RETURN (true);
            END IF;
            IF P_ROW_NEW.FLEX_CAMPO_24 IS NULL THEN
              p_mens := 'Para quem teve vínculo ininterrúpto tem que informar o Tipo de Órgão na aba Vínculo Anterior.';
              RETURN (true);
            ELSIF P_ROW_NEW.FLEX_CAMPO_24 = 'ADMINISTRACAO DIRETA' THEN
              flag_pack.set_empresa(1);
              BEGIN
                SELECT numero,
                  dtvac
                INTO v_vinc_ant,
                  v_dtvac
                FROM vinculos
                WHERE numfunc  = P_ROW_NEW.NUMFUNC
                AND (formavac IS NULL
                OR formavac   <> 'EXCLUS VINC INDEVIDO')
                AND dtposse    = to_date(P_ROW_NEW.FLEX_CAMPO_29,'dd/mm/yyyy'); --Bernardo 03/07/20125
                --and pack_cergon.PGOV__GET_SUBEMPRESA_NOME(pack_ergon.get_subempresa_func(numfunc,numero,sysdate),flag_pack.get_empresa,'N') = P_ROW_NEW.FLEX_CAMPO_28;
              EXCEPTION
              WHEN no_data_found THEN
                v_dtvac := NULL;
                no_data := 1;
              WHEN OTHERS THEN
                p_mens := 'Erro ao executar: '||sqlerrm(SQLCODE);
                RETURN (true);
                flag_pack.set_empresa(v_emp_logada);
              END;
              flag_pack.set_empresa(v_emp_logada);
              IF no_data = 1 THEN --VINCULO NÃO ENCONTRADO
                p_mens := 'O Vínculo anterior não encontrado';
                RETURN (true);
              elsif (v_vinc_ant > 0) AND (v_dtvac IS NULL) THEN -- INICIO DA VALIDAÇÃO DE FREQUENCIA
                -- select inserido para tratar os casos de frequência do grupo AFAST PERMITEM ACUM
                -- esses casos tratar como vacanciado e utilizar a data de inicio da frequência como data de vacância
                -- Reinaldo Mesquita e Rodrigo Machado - 19/01/2014 (SGD 875 e 1316)
                flag_pack.set_empresa(1);
                BEGIN
                  SELECT numvinc,
                    dtini
                  INTO v_vinc_ant,
                    v_dtvac
                  FROM frequencias f
                  WHERE f.codfreq IN
                    (SELECT gf.codfreq
                    FROM erg_gruposfreq_codfreq gf
                    WHERE gf.grupofreq = 'AFAST PERMITEM ACUM'
                    AND sysdate       <= NVL(gf.dtfim,pack_hades.DATA_MAXIMA)
                    AND gf.emp_codigo  = flag_pack.get_empresa
                    )
                  AND (f.dtfim IS NULL
                  OR f.dtfim    > sysdate)
                  AND f.dtini  IN
                    (SELECT MAX(f1.dtini)
                    FROM frequencias f1
                    WHERE f1.numfunc = f.numfunc
                    AND f1.numvinc   = f.numvinc
                    AND f1.codfreq   = f.codfreq
                    )
                  AND EXISTS
                    (SELECT 1
                    FROM vinculos v
                    WHERE v.numfunc                                                                                                                     = f.numfunc
                    AND v.numero                                                                                                                        = f.numvinc
                    AND v.numfunc                                                                                                                       = P_ROW_NEW.NUMFUNC
                    AND v.dtposse                                                                                                                       = to_date(P_ROW_NEW.FLEX_CAMPO_29, 'dd/mm/yyyy')
                    AND pack_cergon.PGOV__GET_SUBEMPRESA_NOME(pack_ergon.get_subempresa_func(v.numfunc, v.numero, sysdate), flag_pack.get_empresa, 'N') = P_ROW_NEW.FLEX_CAMPO_28
                    );
                EXCEPTION
                WHEN no_data_found THEN
                  v_dtvac := NULL;
                  no_data := 2;
                WHEN OTHERS THEN
                  flag_pack.set_empresa(v_emp_logada);
                  p_mens := 'Erro ao executar: ' ||sqlerrm(SQLCODE);
                  RETURN (true);
                END;
                flag_pack.set_empresa(v_emp_logada);
                --
                IF V_VINC_ANT > 0 AND v_dtvac IS NULL THEN
                  p_mens := 'Vínculo ininterrúpto deve ser Vacanciado antes de efetuar um novo Ingresso.';
                  RETURN (true);
                END IF;
              END IF;                                        -- Fim do Vínculo Ininterrúpto não encontrado
              IF (V_VINC_ANT > 0) AND (v_dtvac IS NULL) THEN --Se data de vacancia não encontrada na freq e no vinculo
                p_mens := 'Vínculo ininterrúpto deve ser Vacanciado antes de efetuar um novo Ingresso.';
                RETURN (true);
              elsif (V_VINC_ANT > 0) AND (v_dtvac = to_date(P_ROW_NEW.DTPOSSE,'dd/mm/yyyy'))
                /*-1  --VALIDA DATA DE VACANCIA IGUAL A DATA DO INGRESSO*/
                THEN
                --Bernardo Cámera 17/03/2015 (SGD 875) Início
                --trecho inserido para verificar que o(s) vínculo(s) é(são) ininterrupto(s)
                -- VALIDAÇÕES DE PLANO DE VINCULO ININTERRUPTO (17-04/2015 - BERNARDO E EVELYN)
                BEGIN
                  SELECT flex_campo_16
                  INTO v_plano
                  FROM vinculos
                  WHERE numfunc = P_ROW_NEW.NUMFUNC
                    --and numero    = P_ROW_NEW.flex_campo_25;
                  AND numero = v_vinc_ant;
                EXCEPTION
                WHEN OTHERS THEN
                  p_mens := 'Erro nao esperado SELECT VINCULOS: ' || sqlerrm(SQLCODE);
                  RETURN (true);
                END;
                IF (v_plano                = 'RIOPREV PREVID') THEN
                  P_ROW_NEW.flex_campo_27 := 'RIOPREV PREVID';
                ELSE                                      -- SE PLANO FOR FINANC
                  IF P_ROW_NEW.flex_campo_30 = 'NAO' THEN --Não teve previdência complementar
                    P_ROW_NEW.flex_campo_27 := 'RIOPREV FINANC';
                  ELSE --Teve previdência complementar
                    P_ROW_NEW.flex_campo_27 := 'RIOPREV PREVID';
                  END IF; --De se teve ou não previdência complementar
                END IF;   --Do PLANO do vínculo anterior informado na tela
              ELSE        -- DATA DE POSSE FOR DIFERENTE DA VACANCIA DO VINCULO ININTERRUPTO
                p_mens := 'O vínculo não é ininterrupto, pois a data de posse é diferente da data de vacância do vínculo anterior';
                RETURN (true);
              END IF; -- FIM DA VALIDAÇÃO DE VACANCIA E DATA DE POSSE
              P_ROW_NEW.FLEX_CAMPO_25 := v_vinc_ant;
              ---
              -- Valdação da Tipo de Órgão FUNDAÇÃO E AUTARQUIA
            ELSIF P_ROW_NEW.flex_campo_24 IN ('FUNDACAO','AUTARQUIA') THEN
              flag_pack.set_empresa(v_emp_logada);
              BEGIN
                SELECT numero,
                  dtvac
                INTO v_vinc_ant,
                  v_dtvac
                FROM vinculos
                WHERE numfunc  = P_ROW_NEW.NUMFUNC
                AND (formavac IS NULL
                OR formavac   <> 'EXCLUS VINC INDEVIDO') --Bernardo 03/07/2015
                AND dtposse    = to_date(P_ROW_NEW.FLEX_CAMPO_29,'dd/mm/yyyy');
                --and pack_cergon.PGOV__GET_SUBEMPRESA_NOME(pack_ergon.get_subempresa_func(numfunc,numero,sysdate),flag_pack.get_empresa,'N') = P_ROW_NEW.FLEX_CAMPO_28;
              EXCEPTION
              WHEN no_data_found THEN
                v_dtvac := NULL;
                no_data := 1;
              WHEN OTHERS THEN
                p_mens := 'Erro ao executar: '||sqlerrm(SQLCODE);
                flag_pack.set_empresa(v_emp_logada);
                RETURN (true);
                --RAISE FORM_TRIGGER_FAILURE;
              END;
              --flag_pack.set_empresa(v_emp_logada);
              IF no_data = 1 THEN --VINCULO NÃO ENCONTRADO
                p_mens := 'O Vínculo anterior não encontrado';
                RETURN (true);
              ELSE                                         --VINCULO ENCONTRADO
                IF v_vinc_ant > 0 AND v_dtvac IS NULL THEN -- INICIO DA VALIDAÇÃO DE FREQUENCIA
                  -- select inserido para tratar os casos de frequência do grupo AFAST PERMITEM ACUM
                  -- esses casos tratar como vacanciado e utilizar a data de inicio da frequência como data de vacância
                  -- Reinaldo Mesquita e Rodrigo Machado - 19/01/2014 (SGD 875 e 1316)
                  flag_pack.set_empresa(v_emp_logada);
                  IF P_INSERTING THEN
                    -- Incluído por Giselle da Silva em 22/02/2016 SGD 2635
                    -- Trazer a empresa do vínculo anterior
                    BEGIN
                      SELECT v.emp_codigo
                      INTO v_emp_codigo
                      FROM vinculos v
                      WHERE v.numfunc = P_ROW_NEW.NUMFUNC
                      AND v.numero    = P_ROW_NEW.FLEX_CAMPO_25;
                    EXCEPTION
                    WHEN no_data_found THEN
                      v_emp_codigo := NULL;
                    WHEN OTHERS THEN
                      flag_pack.set_empresa(v_emp_logada);
                      p_mens := 'Erro ao executar): ' ||sqlerrm(SQLCODE);
                      RETURN (true);
                    END;
                    --
                  END IF;
                  BEGIN
                    SELECT numvinc,
                      dtini
                    INTO v_vinc_ant,
                      v_dtvac
                    FROM frequencias f
                    WHERE f.codfreq IN
                      (SELECT gf.codfreq
                      FROM erg_gruposfreq_codfreq gf
                      WHERE gf.grupofreq = 'AFAST PERMITEM ACUM'
                      AND sysdate       <= NVL(gf.dtfim,pack_hades.DATA_MAXIMA)
                      AND gf.emp_codigo  = flag_pack.get_empresa
                      )
                    AND (f.dtfim IS NULL
                    OR f.dtfim    > sysdate)
                    AND f.dtini  IN
                      (SELECT MAX(f1.dtini)
                      FROM frequencias f1
                      WHERE f1.numfunc = f.numfunc
                      AND f1.numvinc   = f.numvinc
                      AND f1.codfreq   = f.codfreq
                      )
                    AND EXISTS
                      (SELECT 1
                      FROM vinculos v
                      WHERE v.numfunc = f.numfunc
                      AND v.numero    = f.numvinc
                      AND v.numfunc   = P_ROW_NEW.NUMFUNC
                      AND v.dtposse   = to_date(P_ROW_NEW.FLEX_CAMPO_29, 'dd/mm/yyyy')
                        -- Alterado por Giselle da Silva em 22/02/2016 SGD 2635
                        -- Buscar pela empresa do vínculo anterior
                        /*and pack_cergon.PGOV__GET_SUBEMPRESA_NOME(pack_ergon.get_subempresa_func(v.numfunc, v.numero, sysdate),
                        flag_pack.get_empresa, 'N') =
                        P_ROW_NEW.FLEX_CAMPO_28);*/
                      AND pack_ergon.GET_NOME_EMPRESA(v_emp_codigo) = P_ROW_NEW.FLEX_CAMPO_28
                      );
                    --
                  EXCEPTION
                  WHEN no_data_found THEN
                    v_dtvac := NULL;
                    no_data := 2;
                  WHEN OTHERS THEN
                    flag_pack.set_empresa(v_emp_logada);
                    p_mens := 'Erro ao executar: ' ||sqlerrm(SQLCODE);
                    RETURN (true);
                  END;
                  flag_pack.set_empresa(v_emp_logada);
                  --
                  IF (V_VINC_ANT > 0) AND (v_dtvac IS NULL) THEN
                    p_mens := 'Vínculo ininterrupto deve ser Vacanciado antes de efetuar um novo Ingresso.';
                    RETURN (true);
                  END IF;
                END IF;                                    --Fim do If da Frequencia
              END IF;                                      -- Fim do Vínculo Ininterrúpto não encontrado
              IF (V_VINC_ANT > 0) AND v_dtvac IS NULL THEN --Se data de vacancia não encontrada na freq e no vinculo
                p_mens := 'Vínculo ininterrupto deve ser Vacanciado antes de efetuar um novo Ingresso.';
                RETURN (true);
              elsif (V_VINC_ANT > 0) AND (v_dtvac = to_date(P_ROW_NEW.DTPOSSE,'dd/mm/yyyy'))
                /*-1  --VALIDA DATA DE VACANCIA IGUAL A DATA DO INGRESSO*/
                THEN
                --Bernardo Cámera 17/03/2015 (SGD 875) Início
                --trecho inserido para verificar que o(s) vínculo(s) é(são) ininterrupto(s)
                -- VALIDAÇÕES DE PLANO DE VINCULO ININTERRUPTO (17-04/2015 - BERNARDO E EVELYN)
                BEGIN
                  SELECT flex_campo_16
                  INTO v_plano
                  FROM vinculos
                  WHERE numfunc = P_ROW_NEW.NUMFUNC
                  AND dtposse   = to_date(P_ROW_NEW.FLEX_CAMPO_29,'dd/mm/yyyy')
                  AND numero    = v_vinc_ant;
                  --and numero    = P_ROW_NEW.flex_campo_25;
                EXCEPTION
                WHEN OTHERS THEN
                  p_mens := 'Erro nao esperado SELECT VINCULOS: ' || sqlerrm(SQLCODE);
                  RETURN (true);
                END;
                IF (v_plano                = 'RIOPREV PREVID') THEN
                  P_ROW_NEW.flex_campo_27 := 'RIOPREV PREVID';
                ELSE                                      -- SE PLANO FOR FINANC
                  IF P_ROW_NEW.flex_campo_30 = 'NAO' THEN --Não teve previdência complementar
                    P_ROW_NEW.flex_campo_27 := 'RIOPREV FINANC';
                  ELSE --Teve previdência complementar
                    P_ROW_NEW.flex_campo_27 := 'RIOPREV PREVID';
                  END IF; --De se teve ou não previdência complementar
                END IF;   --Do PLANO do vínculo anterior informado na tela
              ELSE        -- DATA DE POSSE FOR DIFERENTE DA VACANCIA DO VINCULO ININTERRUPTO
                p_mens := 'O vínculo não é ininterrupto, pois a data de posse é diferente da data de vacância do vínculo anterior';
                RETURN (true);
              END IF; -- FIM DA VALIDAÇÃO DE VACANCIA E DATA DE POSSE
              P_ROW_NEW.FLEX_CAMPO_25 := v_vinc_ant;
            ELSIF -- Início crítica de órgão federal 08/05/2015 Bernardo
              P_ROW_NEW.flex_campo_24 IN ('LEGISLATIVO FEDERAL','EXECUTIVO MUNICIPAL', 'EXECUTIVO FEDERAL','INICIATIVA PRIVADA','JUDICIÁRIO ESTADUAL','LEGISLATIVO ESTADUAL', 'JUDICIÁRIO FEDERAL', 'LEGISLATIVO MUNICIPAL','EXECUTIVO ESTADUAL') AND P_ROW_NEW.flex_campo_28 NOT IN ('MINISTÉRIO PÚBLICO - PROCURADORIA GERAL DE JUSTICA DO RJ', 'TRIBUNAL DE JUSTIÇA DO ESTADO DO RIO DE JANEIRO', 'TRIBUNAL DE CONTAS DO ESTADO DO RIO DE JANEIRO', 'ASSEMBLÉIA LEGISLATIVA DO RIO DE JANEIRO') THEN
              IF P_ROW_NEW.flex_campo_30 IS NULL THEN
                p_mens := 'É Necessário informar se teve ou não Previdência Complementar.';
                RETURN (true);
              END IF;
              /*
              if P_ROW_NEW.flex_campo_29 is null then
              end if;
              */
              --
              IF P_ROW_NEW.flex_campo_30 = 'NAO' THEN --Não teve previdência complementar
                --Controle de si possui um dos atributos RJPREV FACUL PL PREV ou RJPREV PATROCINADA
                BEGIN
                  SELECT 1
                  INTO v_count
                  FROM vantagens
                  WHERE numfunc = P_ROW_NEW.NUMFUNC
                  AND numvinc   = P_ROW_NEW.NUMVINC
                  AND vantagem IN ('RJPREV FACUL PL PREV', 'RJPREV PATROCINADA')
                  AND dtfim    IS NULL;
                EXCEPTION
                WHEN no_data_found THEN
                  v_count := 0;
                WHEN too_many_rows THEN
                  v_count := 1;
                WHEN OTHERS THEN
                  v_count := 0;
                END;
                IF v_count = 1 THEN
                  p_mens := 'Os atributos de Previdência Complementar devem ser fechados para que o plano possa ser alterado';
                  RETURN (true);
                END IF;
                --
                P_ROW_NEW.flex_campo_27 := 'RIOPREV FINANC';
              ELSE --Teve previdência complementar
                --Controle de si possui um dos atributos RJPREV FACUL PL PREV ou RJPREV PATROCINADA
                BEGIN
                  SELECT 1
                  INTO v_count
                  FROM vantagens
                  WHERE numfunc = P_ROW_NEW.NUMFUNC
                  AND numvinc   = P_ROW_NEW.NUMVINC
                  AND vantagem IN ('RJPREV FACUL PL PREV', 'RJPREV PATROCINADA')
                  AND dtfim    IS NULL;
                EXCEPTION
                WHEN no_data_found THEN
                  v_count := 0;
                WHEN too_many_rows THEN
                  v_count := 1;
                WHEN OTHERS THEN
                  v_count := 0;
                END;
                IF v_count = 1 THEN
                  p_mens := 'Os atributos de Previdência Complementar devem ser fechados para que o plano possa ser alterado';
                  RETURN (true);
                END IF;
                --
                P_ROW_NEW.flex_campo_27 := 'RIOPREV PREVID';
              END IF; --De se teve ou não previdência complementar
              -- Fim crítica de órgão "FEDERAL"  19/05/2015 Bernardo
            ELSIF P_ROW_NEW.FLEX_CAMPO_24 IN ('JUDICIÁRIO ESTADUAL','LEGISLATIVO ESTADUAL') THEN--VALIDAÇÃO DO FLEX CAMPO 24
              IF P_ROW_NEW.flex_campo_28  IN ('MINISTÉRIO PÚBLICO - PROCURADORIA GERAL DE JUSTICA DO RJ', 'TRIBUNAL DE JUSTIÇA DO ESTADO DO RIO DE JANEIRO', 'TRIBUNAL DE CONTAS DO ESTADO DO RIO DE JANEIRO', 'ASSEMBLÉIA LEGISLATIVA DO RIO DE JANEIRO') THEN
                IF to_date(P_ROW_NEW.FLEX_CAMPO_29,'dd/mm/yyyy') < to_date('04/09/2013','dd/mm/yyyy') THEN -- DATA DE POSSE VINCULO ININTERUPTO
                  --Controle de se possui atributo Facultativo PATROCINADO
                  BEGIN
                    SELECT 1
                    INTO v_count
                    FROM vantagens
                    WHERE numfunc = P_ROW_NEW.NUMFUNC
                    AND numvinc   = P_ROW_NEW.NUMVINC
                    AND vantagem IN ('RJPREV FACUL PL PREV', 'RJPREV PATROCINADA')
                    AND dtfim    IS NULL;
                  EXCEPTION
                  WHEN no_data_found THEN
                    v_count := 0;
                  WHEN too_many_rows THEN
                    v_count := 1;
                  WHEN OTHERS THEN
                    v_count := 0;
                  END;
                  IF v_count = 1 THEN
                    p_mens := 'Os atributos de Previdência Complementar devem ser fechados para que o plano possa ser alterado';
                    RETURN (true);
                  END IF;
                  --
                  P_ROW_NEW.flex_campo_27 := 'RIOPREV FINANC';
                ELSE -- Data de posse do vínculo ininterrupto >= 04/09/2013
                  --Controle de se possui atributo Facultativo PATROCINADO
                  BEGIN
                    SELECT 1
                    INTO v_count
                    FROM vantagens
                    WHERE numfunc = P_ROW_NEW.NUMFUNC
                    AND numvinc   = P_ROW_NEW.NUMVINC
                    AND vantagem IN ('RJPREV FACUL PL PREV', 'RJPREV PATROCINADA')
                    AND dtfim    IS NULL;
                  EXCEPTION
                  WHEN no_data_found THEN
                    v_count := 0;
                  WHEN too_many_rows THEN
                    v_count := 1;
                  WHEN OTHERS THEN
                    v_count := 0;
                  END;
                  IF v_count = 1 THEN
                    p_mens := 'Os atributos de Previdência Complementar devem ser fechados para que o plano possa ser alterado';
                    RETURN (true);
                  END IF;
                  --
                  P_ROW_NEW.flex_campo_27 := 'RIOPREV PREVID';
                END IF; -- FIM DA DATA DE POSSE VINCULO ININTERRUPTO
              END IF;   -- FIM DA VALIDAÇÃO DO FLEX CAMPO 28
            END IF;     -- FIM DA VALIDAÇÃO DE CONCURSO PUBLICO E ESTATUTO CIVIL
          ELSE          --SENÃO DA PERGUNTA SOBRE SE TEVE VINCULO ESTATUTÁRIO ININTERRUPTO
            P_ROW_NEW.FLEX_CAMPO_28 := NULL;
            P_ROW_NEW.FLEX_CAMPO_29 := NULL;
            P_ROW_NEW.FLEX_CAMPO_30 := NULL;
            P_ROW_NEW.FLEX_CAMPO_24 := NULL;
            P_ROW_NEW.FLEX_CAMPO_25 := NULL;
            P_ROW_NEW.FLEX_CAMPO_27 := 'RIOPREV PREVID';
          END IF;                                                                                 --FIM DA VALIDAÇÃO DO VINCULO ININTERRUPTO
        END IF;                                                                                   --FIM DA VALIDAÇÃO ED ESTATUTO CIVIL E CONCURSO PUBLICO
      elsif to_date(P_ROW_NEW.dtposse,'dd/mm/yyyy') < to_date('04/09/2013','dd/mm/yyyy') THEN --Se data de Posse for Menor que 04/09/2013
        IF P_ROW_NEW.FLEX_CAMPO_26                     IS NOT NULL THEN
          P_ROW_NEW.FLEX_CAMPO_26                      := NULL;
        END IF;
        IF (P_ROW_NEW.regimejur = 'ESTATUTO CIVIL') AND (P_ROW_NEW.tipovinc = 'CONCURSO PUBLICO') THEN
          --
          BEGIN
            SELECT 1
            INTO v_count
            FROM vantagens
            WHERE numfunc = P_ROW_NEW.NUMFUNC
            AND numvinc   = P_ROW_NEW.NUMVINC
            AND vantagem IN ('RJPREV FACUL PL PREV', 'RJPREV PATROCINADA')
            AND dtfim    IS NULL;
          EXCEPTION
          WHEN no_data_found THEN
            v_count := 0;
          WHEN too_many_rows THEN
            v_count := 1;
          WHEN OTHERS THEN
            v_count := 0;
          END;
          IF v_count = 1 THEN
            p_mens := 'Os atributos de Previdência Complementar devem ser fechados para que o plano possa ser alterado';
            RETURN (true);
          ELSE
            P_ROW_NEW.FLEX_CAMPO_27 := 'RIOPREV FINANC';
          END IF;
          --
        ELSE
          --REGRA ANTIGA--
          DECLARE
          v_categoria cargos.categoria%type;
          BEGIN
            SELECT CATEGORIA INTO V_CATEGORIA FROM CARGOS WHERE CARGO = P_ROW_NEW.CARGO;


            SELECT DECODE (planoprev_padrao, 'RPPS', 'RIOPREV FINANC', planoprev_padrao)
            INTO P_ROW_NEW.FLEX_CAMPO_27
            FROM erg_tipovinc_valid
            WHERE tipovinc = P_ROW_NEW.TIPOVINC
            AND regimejur  = P_ROW_NEW.REGIMEJUR
           AND categoria  = V_CATEGORIA;
          EXCEPTION
          WHEN no_data_found THEN
            P_ROW_NEW.FLEX_CAMPO_27 := NULL;
          WHEN OTHERS THEN
            p_mens := 'Erro ao executar: '||sqlerrm(SQLCODE);
            RETURN (true);
          END;
        END IF; -- fim da validação de est civil e regimejur
        P_ROW_NEW.FLEX_CAMPO_28 := NULL;
        P_ROW_NEW.FLEX_CAMPO_29 := NULL;
        P_ROW_NEW.FLEX_CAMPO_30 := NULL;
        P_ROW_NEW.FLEX_CAMPO_24 := NULL;
        P_ROW_NEW.FLEX_CAMPO_25 := NULL;
      END IF; -- Fim da validação de Data 04/09/2013
      --            BEGIN
      --                dbg.indent('FORM','PRE-INSERT', 20000 );
      --
      -- Chama procedimento relacionado com auditoria
      --
      --pre_INSERT_trigger(:SYSTEM.TRIGGER_BLOCK, flag_pack.get_usuario, flag_pack.get_machine);
      --dbg.unindent;
      --            EXCEPTION
      --                WHEN OTHERS THEN
      --                dbg.unindent;
      --                RAISE;
      --            END;
    END;
  END IF;
  RETURN (TRUE);
END TGRJ_EPB__ERG_INGRESSO_02;
/