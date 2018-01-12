create or replace PROCEDURE TGRJ_DML_RJADM00017(
    P_ORIGEM    NUMBER,
    P_DESTINO   NUMBER,
    P_DT_TRANSF DATE,
    P_OBS       VARCHAR2)
IS
  P_ID_EXEC NUMBER         := 0;
  P_HEADER  VARCHAR2(400)  := 'Transferência de Setor em Lote';
  P_PARAM   VARCHAR2(4000) := 'Setor Origem: '||P_ORIGEM||' Setor Destino: '||P_DESTINO||' Data Transferência: '||P_DT_TRANSF||' OBS: '||P_OBS;
  V_EF EVENTO_FUNC%ROWTYPE;
  V_EX EXERCICIOS%ROWTYPE;
  V_VANT PGOV_VANTAGENS_TEMP%ROWTYPE;  --VANTAGENS%ROWTYPE;
  V_REGISTROS_VAN     NUMBER         := 0;
  V_FECHADOS_VAN      NUMBER         := 0;
  V_CRIADOS_VAN       NUMBER         := 0;
  V_ERROS_VAN         NUMBER         := 0;
  V_REGISTROS_EF      NUMBER         := 0;
  V_FECHADOS_EF       NUMBER         := 0;
  V_CRIADOS_EF        NUMBER         := 0;
  V_ERROS_EF          NUMBER         := 0;
  V_REGISTROS_EX      NUMBER         := 0;
  V_FECHADOS_EX       NUMBER         := 0;
  V_CRIADOS_EX        NUMBER         := 0;
  V_ERROS_EX          NUMBER         := 0;
  V_ERROS             NUMBER         := 0;
  V_ERR_TXT_VAN       VARCHAR2(2000) := NULL;
  V_ERR_TXT_VAN_FECHA VARCHAR2(2000) := NULL;
  V_ERR_TXT_EVENT     VARCHAR2(2000) := NULL;
  V_ERR_TXT_EXER      VARCHAR2(2000) := NULL;
  --V_EXCEPTION   NUMBER := 0;
  --V_EXC_ERRO   VARCHAR2(2000);
  -- CURSOR QUE BUSCA OS FUNCIONARIOS QUE FARÃO AS MIGRAÇÕES --
  CURSOR C0
  IS
    SELECT NUMFUNC,
      NUMVINC
    FROM EVENTO_FUNC
    WHERE SETOR = P_ORIGEM
    AND (DTFIM IS NULL
    OR DTFIM   >= P_DT_TRANSF)
  UNION
  SELECT NUMFUNC,
    NUMVINC
  FROM EXERCICIOS
  WHERE SETOR = P_ORIGEM
  AND (DTFIM IS NULL
  OR DTFIM   >= P_DT_TRANSF);
  -- CURSOR DE EVENTO --
  CURSOR C1(PC_NUMFUNC NUMBER, PC_NUMVINC NUMBER)
  IS
    SELECT *
    FROM EVENTO_FUNC
    WHERE SETOR = P_ORIGEM
    AND (DTFIM IS NULL
    OR DTFIM   >= P_DT_TRANSF)
    AND NUMFUNC = PC_NUMFUNC
    AND NUMVINC = PC_NUMVINC;
  -- CURSOR DE EXERCICIO --
  CURSOR C2(PC_NUMFUNC NUMBER, PC_NUMVINC NUMBER)
  IS
    SELECT *
    FROM EXERCICIOS
    WHERE SETOR = P_ORIGEM
    AND (DTFIM IS NULL
    OR DTFIM   >= P_DT_TRANSF)
    AND NUMFUNC = PC_NUMFUNC
    AND NUMVINC = PC_NUMVINC;
  -- CURSOR DE FECHAMENTO DE GEE --
  CURSOR C3(PC_NUMFUNC NUMBER, PC_NUMVINC NUMBER)
  IS
    SELECT *
    FROM VANTAGENS V
    WHERE V.NUMFUNC = PC_NUMFUNC
    AND V.NUMVINC   = PC_NUMVINC
    AND (V.DTFIM   IS NULL
       OR V.DTFIM >= P_DT_TRANSF)
    AND EXISTS
      (SELECT NULL
      FROM TIPO_VANTAGEM TV
      WHERE TV.FLEX_CAMPO_01 = 'S'
      AND TV.VANTAGEM        = V.VANTAGEM
      );
  -- CURSOR DE ABERTURA DE GEE --
  CURSOR C4(PC_NUMFUNC NUMBER, PC_NUMVINC NUMBER)
  IS
    SELECT *
    FROM PGOV_VANTAGENS_TEMP V
    WHERE V.NUMFUNC = PC_NUMFUNC
    AND V.NUMVINC   = PC_NUMVINC;
BEGIN
  P_ID_EXEC := LOG_PACK.INSERE_LOG_HEADER (P_HEADER,P_PARAM);
  LOG_PACK.INSERE_LOG_DETAIL (P_ID_EXEC, 'Processo Iniciado.');
  COMMIT;
  FOR R0 IN C0
  LOOP
    -- LIMPA VARIAVEIS DE ERRO --
    V_ERR_TXT_VAN       := NULL;
    V_ERR_TXT_VAN_FECHA := NULL;
    V_ERR_TXT_EVENT     := NULL;
    V_ERR_TXT_EXER      := NULL;
    -- LIMPA A PGOV_VANTAGENS_TEMP --
    DELETE FROM PGOV_VANTAGENS_TEMP;
    -- LOOP PARA FECHAR AS GEE'S --
    FOR R3 IN C3(R0.NUMFUNC,R0.NUMVINC)
    LOOP
      V_REGISTROS_VAN := V_REGISTROS_VAN +1;
      -- GRAVA A GEE NA PGOV_VANTAGENS_TEMP PARA ABRIR UMA IGUAL APOS AS MIGRAÇÕES --
      BEGIN
        INSERT INTO PGOV_VANTAGENS_TEMP (VANTAGEM, DTINI, CHAVEVANT) VALUES (R3.VANTAGEM, R3.DTINI, R3.CHAVEVANT);

      -- select * FROM PGOV_VANTAGENS_TEMP;
       -- desc PGOV_VANTAGENS_TEMP;
      EXCEPTION
      WHEN OTHERS THEN
        V_ERROS_VAN := V_ERROS_VAN +1;
        --LOG_PACK.INSERE_LOG_DETAIL (P_ID_EXEC, 'Erro ao fechar atributo: ID: '||R3.NUMFUNC||'-'||R3.NUMVINC||' Atributo: '||R3.VANTAGEM||' Info: '||R3.INFO||' Dt. Início: '||R3.DTINI||' Dt. Fim: '||R3.DTFIM||' Erro: '||SQLERRM);
        V_ERR_TXT_VAN := 'Erro ao fechar atributo: ID: '||R3.NUMFUNC||'-'||R3.NUMVINC||' Atributo: '||R3.VANTAGEM||' Info: '||R3.INFO||' Dt. Início: '||R3.DTINI||' Dt. Fim: '||R3.DTFIM||' Erro: '||SQLERRM;
      END;
      IF SQL%ROWCOUNT > 0 THEN
        -- SE GRAVOU, VERIFICA SE A DTINI = DTFIM
        IF R3.DTINI = P_DT_TRANSF THEN
          -- FECHA A GEE COM DTFIM = P_DT_TRANSF --
          BEGIN
            DELETE VANTAGENS WHERE CHAVEVANT = R3.CHAVEVANT;
          EXCEPTION
          WHEN OTHERS THEN
            V_ERROS_VAN := V_ERROS_VAN +1;
            --LOG_PACK.INSERE_LOG_DETAIL (P_ID_EXEC, 'Erro ao Excluir atributo: ID: '||R3.NUMFUNC||'-'||R3.NUMVINC||' Atributo: '||R3.VANTAGEM||' Info: '||R3.INFO||' Dt. Início: '||R3.DTINI||' Dt. Fim: '||R3.DTFIM||' Erro: '||SQLERRM);
            V_ERR_TXT_VAN_FECHA := 'Erro ao Excluir atributo: ID: '||R3.NUMFUNC||'-'||R3.NUMVINC||' Atributo: '||R3.VANTAGEM||' Info: '||R3.INFO||' Dt. Início: '||R3.DTINI||' Dt. Fim: '||R3.DTFIM||' Erro: '||SQLERRM;
          END;
          IF SQL%ROWCOUNT   > 0 THEN
            V_FECHADOS_VAN := V_FECHADOS_VAN +1;
            LOG_PACK.INSERE_LOG_DETAIL (P_ID_EXEC, 'Excluido o atributo. ID: '||R3.NUMFUNC||'-'||R3.NUMVINC||' Atributo: '||R3.VANTAGEM||' Info: '||R3.INFO||' Dt. Início: '||R3.DTINI||' Dt. Fim: '||P_DT_TRANSF);
          END IF;
        ELSE
          -- FECHA A GEE COM DTFIM = P_DT_TRANSF -1 --
          BEGIN
            UPDATE VANTAGENS SET DTFIM = P_DT_TRANSF -1 WHERE CHAVEVANT = R3.CHAVEVANT;
          EXCEPTION
          WHEN OTHERS THEN
            V_ERROS_VAN := V_ERROS_VAN +1;
            --LOG_PACK.INSERE_LOG_DETAIL (P_ID_EXEC, 'Erro ao fechar atributo: ID: '||R3.NUMFUNC||'-'||R3.NUMVINC||' Atributo: '||R3.VANTAGEM||' Info: '||R3.INFO||' Dt. Início: '||R3.DTINI||' Dt. Fim: '||R3.DTFIM||' Erro: '||SQLERRM);
            V_ERR_TXT_VAN_FECHA := 'Erro ao fechar atributo: ID: '||R3.NUMFUNC||'-'||R3.NUMVINC||' Atributo: '||R3.VANTAGEM||' Info: '||R3.INFO||' Dt. Início: '||R3.DTINI||' Dt. Fim: '||R3.DTFIM||' Erro: '||SQLERRM;
          END;
          IF SQL%ROWCOUNT   > 0 THEN
            V_FECHADOS_VAN := V_FECHADOS_VAN                                                                                                                                                                      +1;
            LOG_PACK.INSERE_LOG_DETAIL (P_ID_EXEC, 'Fechado o atributo. ID: '||R3.NUMFUNC||'-'||R3.NUMVINC||' Atributo: '||R3.VANTAGEM||' Info: '||R3.INFO||' Dt. Início: '||R3.DTINI||' Dt. Fim: '||(P_DT_TRANSF -1));
          END IF;
        END IF;
      END IF;
    END LOOP; -- FIM DO FECHAMENTO DAS GEE'S --
    -- INICIO DO TRATAMENTO DAS MIGRAÇÕES NA EVENTO_FUNC --
    FOR R1 IN C1(R0.NUMFUNC,R0.NUMVINC)
    LOOP
      V_REGISTROS_EF := V_REGISTROS_EF +1;
      V_EF           := R1;
      -- FECHA EVENTO COM DTFIM = P_DT_TRANSF-1 --
      BEGIN
        UPDATE EVENTO_FUNC
        SET DTFIM       = P_DT_TRANSF -1,
          FLEX_CAMPO_06 = 'Fechado pela transação Transferência de Setor em Lote.'
        WHERE NUMEV     = V_EF.NUMEV;
      EXCEPTION
      WHEN OTHERS THEN
        V_ERROS_EF := V_ERROS_EF +1;
        --LOG_PACK.INSERE_LOG_DETAIL (P_ID_EXEC, 'Erro no fechamento do evento de cargo: ID: '||R1.NUMFUNC||'-'||R1.NUMVINC||' Tipo de Evento: '||R1.TIPOEVENTO||' Espécie de Evento: '||R1.FORMAPROV||' Setor: '||R1.SETOR||' Dt. Início: '||R1.DTINI||' Dt. Fim: '||R1.DTFIM||' Erro: '||SQLERRM);
        V_ERR_TXT_EVENT := 'Erro no fechamento do evento de cargo: ID: '||R1.NUMFUNC||'-'||R1.NUMVINC||' Tipo de Evento: '||R1.TIPOEVENTO||' Espécie de Evento: '||R1.FORMAPROV||' Setor: '||R1.SETOR||' Dt. Início: '||R1.DTINI||' Dt. Fim: '||R1.DTFIM||' Erro: '||SQLERRM;
      END;
      IF SQL%ROWCOUNT  > 0 THEN
        V_FECHADOS_EF := V_FECHADOS_EF +1;
        LOG_PACK.INSERE_LOG_DETAIL (P_ID_EXEC, 'Fechado evento de cargo. ID: '||V_EF.NUMFUNC||'-'||V_EF.NUMVINC||' Tipo de Evento: '||V_EF.TIPOEVENTO||' Espécie de Evento: '||V_EF.FORMAPROV||' Setor: '||V_EF.SETOR||' Dt. Início: '||V_EF.DTINI||' Dt. Fim: '||V_EF.DTFIM);
        -- SE FECHAR O EVENTO ANTERIOR, ABRE EVENTO DE 'ALTERACAO ESTRUTURA' COM DTINI = P_DT_TRANSF E DTFIM ORIGINAL (SE NULA CONTINUA NULA, SE PREENCHIDA PERMANECE O VALOR PREENCHIDO NA DTFIM)--
        V_EF.NUMEV                         := NULL;
        V_EF.ID_REG                        := NULL;
        V_EF.PONTPUBL                      := NULL;
        V_EF.SETOR                         := P_DESTINO;
        V_EF.DTINI                         := P_DT_TRANSF;
        V_EF.FORMAPROV                     := 'ALTERACAO ESTRUTURA';
        V_EF.FLEX_CAMPO_06                 := 'Aberto pela transação Transferência de Setor em Lote.';
        IF LENGTH(V_EF.OBS||CHR(10)||P_OBS) < 2000 THEN
          V_EF.OBS                         := P_OBS||CHR(10)||V_EF.OBS;
        ELSE
          V_EF.OBS := P_OBS;
        END IF;
        BEGIN
          INSERT INTO EVENTO_FUNC (NUMEV, ID_REG, PONTPUBL, SETOR, DTINI, FORMAPROV, FLEX_CAMPO_06) VALUES (R1.NUMEV, R1.ID_REG, R1.PONTPUBL, R1.SETOR, R1.DTINI, R1.FORMAPROV, R1.FLEX_CAMPO_06);

           --  select * from evento_func;
          --  desc evento_func;
        EXCEPTION
        WHEN OTHERS THEN
          V_ERROS_EF := V_ERROS_EF +1;
          --LOG_PACK.INSERE_LOG_DETAIL (P_ID_EXEC, 'Erro na criação do evento de cargo: ID: '||R1.NUMFUNC||'-'||R1.NUMVINC||' Tipo de Evento: '||R1.TIPOEVENTO||' Espécie de Evento: '||R1.FORMAPROV||' Setor: '||R1.SETOR||' Dt. Início: '||R1.DTINI||' Dt. Fim: '||R1.DTFIM||' Erro: '||SQLERRM);
          V_ERR_TXT_EVENT := 'Erro na criação do evento de cargo: ID: '||R1.NUMFUNC||'-'||R1.NUMVINC||' Tipo de Evento: '||R1.TIPOEVENTO||' Espécie de Evento: '||R1.FORMAPROV||' Setor: '||R1.SETOR||' Dt. Início: '||R1.DTINI||' Dt. Fim: '||R1.DTFIM||' Erro: '||SQLERRM;
        END;
        IF SQL%ROWCOUNT > 0 THEN
          V_CRIADOS_EF := V_CRIADOS_EF +1;
          LOG_PACK.INSERE_LOG_DETAIL (P_ID_EXEC, 'Criado evento de cargo. ID: '||V_EF.NUMFUNC||'-'||V_EF.NUMVINC||' Tipo de Evento: '||V_EF.TIPOEVENTO||' Espécie de Evento: '||V_EF.FORMAPROV||' Setor: '||V_EF.SETOR||' Dt. Início: '||V_EF.DTINI||' Dt. Fim: '||V_EF.DTFIM);
        END IF;
      END IF;
    END LOOP; -- FIM DO TRATAMENTO DAS MIGRAÇÕES NA EVENTO_FUNC --
    -- INICIO DO TRATAMENTO DAS MIGRAÇÕES NA EXERCICIOS --
    FOR R2 IN C2
    (
      R0.NUMFUNC,R0.NUMVINC
    )
    LOOP
      V_REGISTROS_EX := V_REGISTROS_EX +1;
      V_EX           := R2;
      -- FECHA EXERCICIO COM DTFIM = P_DT_TRANSF-1 --
      BEGIN
        UPDATE EXERCICIOS
        SET DTFIM       = P_DT_TRANSF -1,
          FLEX_CAMPO_04 = 'Fechado pela transação Transferência de Setor em Lote.'
        WHERE CHAVE     = V_EX.CHAVE
        AND NUMFUNC     = V_EX.NUMFUNC
        AND NUMVINC     = V_EX.NUMVINC;
      EXCEPTION
      WHEN OTHERS THEN
        V_ERROS_EX := V_ERROS_EX +1;
        --LOG_PACK.INSERE_LOG_DETAIL (P_ID_EXEC, 'Erro no fechamento do exercício: ID: '||R2.NUMFUNC||'-'||R2.NUMVINC||' Setor: '||R2.SETOR||' Dt. Início: '||R2.DTINI||' Dt. Fim: '||R2.DTFIM||' Erro: '||SQLERRM);
        V_ERR_TXT_EXER := 'Erro no fechamento do exercício: ID: '||R2.NUMFUNC||'-'||R2.NUMVINC||' Setor: '||R2.SETOR||' Dt. Início: '||R2.DTINI||' Dt. Fim: '||R2.DTFIM||' Erro: '||SQLERRM;
      END;
      IF SQL%ROWCOUNT  > 0 THEN
        V_FECHADOS_EX := V_FECHADOS_EX                                                                                                                                             +1;
        LOG_PACK.INSERE_LOG_DETAIL (P_ID_EXEC, 'Fechado exercício. ID: '||R2.NUMFUNC||'-'||R2.NUMVINC||' Setor: '||R2.SETOR||' Dt. Início: '||R2.DTINI||' Dt. Fim: '||(P_DT_TRANSF -1));
        -- SE FECHAR O EXERCÍCIO ANTERIOR, ABRE UM NOVO EXERCÍCIO COM NOVO SETOR COM DTINI = P_DT_TRANSF
        V_EX.CHAVE                         := NULL;
        V_EX.ID_REG                        := NULL;
        V_EX.PONTPUBL                      := NULL;
        V_EX.SETOR                         := P_DESTINO;
        V_EX.DTINI                         := P_DT_TRANSF;
        V_EX.FLEX_CAMPO_04                 := 'Aberto pela transação Transferência de Setor em Lote.'||CHR(10)||V_EF.FLEX_CAMPO_04;
        IF LENGTH(P_OBS||CHR(10)||V_EX.OBS) < 2000 THEN
          V_EX.OBS                         := P_OBS||CHR(10)||V_EX.OBS;
        ELSE
          V_EX.OBS := P_OBS;
        END IF;
        BEGIN
          INSERT INTO EXERCICIOS (CHAVE, ID_REG, PONTPUBL, SETOR, DTINI, FLEX_CAMPO_04) VALUES  (R2.CHAVE, R2.ID_REG, R2.PONTPUBL, R2.SETOR, R2.DTINI, R2.FLEX_CAMPO_04);

       --   select * from exercicios;
        --  desc exercicios;
        EXCEPTION
        WHEN OTHERS THEN
          V_ERROS_EX := V_ERROS_EX +1;
          --LOG_PACK.INSERE_LOG_DETAIL (P_ID_EXEC, 'Erro na criação do evento de cargo: ID: '||R2.NUMFUNC||'-'||R2.NUMVINC||' Setor: '||R2.SETOR||' Dt. Início: '||R2.DTINI||' Dt. Fim: '||R2.DTFIM||' Erro: '||SQLERRM);
          V_ERR_TXT_EXER := 'Erro na criação do evento de cargo: ID: '||R2.NUMFUNC||'-'||R2.NUMVINC||' Setor: '||R2.SETOR||' Dt. Início: '||R2.DTINI||' Dt. Fim: '||R2.DTFIM||' Erro: '||SQLERRM;
        END;
        IF SQL%ROWCOUNT > 0 THEN
          V_CRIADOS_EX := V_CRIADOS_EX +1;
          LOG_PACK.INSERE_LOG_DETAIL (P_ID_EXEC, 'Criado exercício. ID: '||V_EX.NUMFUNC||'-'||V_EX.NUMVINC||' Setor: '||V_EX.SETOR||' Dt. Início: '||V_EX.DTINI||' Dt. Fim: '||V_EX.DTFIM);
        END IF;
      END IF;
    END LOOP; -- FIM DO TRATAMENTO DAS MIGRAÇÕES NA EXERCICIOS --
    -- ABRE AS GEE'S QUE ESTÃO NA PGOV_VANTAGENS_TEMP QUE FORAM FECHADAS PARA PODER FAZER AS MIGRAÇÕES --
    FOR R4 IN C4
    (
      R0.NUMFUNC,R0.NUMVINC
    )
    LOOP
      V_VANT     := R4;
      IF R4.DTINI = P_DT_TRANSF THEN
        -- RECRIA O ATRIBUTO QUE POSSUI DTINI = P_DT_TRANSF COLOCANDO A DTFIM ORIGINAL DO ATRIBUTO --
        V_VANT.CHAVEVANT := NULL;
        V_VANT.ID_REG    := NULL;
        V_VANT.PONTPUBL  := NULL;
        BEGIN
          INSERT INTO VANTAGENS (CHAVEVANT, ID_REG, PONTPUBL) VALUES (R4.CHAVEVANT, R4.ID_REG, R4.PONTPUBL);
        EXCEPTION
        WHEN OTHERS THEN
          V_ERROS_VAN := V_ERROS_VAN +1;
          --LOG_PACK.INSERE_LOG_DETAIL (P_ID_EXEC, 'Erro ao reabrir atributo: ID: '||R4.NUMFUNC||'-'||R4.NUMVINC||' Atributo: '||R4.VANTAGEM||' Info: '||R4.INFO||' Dt. Início: '||R4.DTINI||' Dt. Fim: '||R4.DTFIM||' Erro: '||SQLERRM);
          V_ERR_TXT_VAN := 'Erro ao reabrir atributo: ID: '||R4.NUMFUNC||'-'||R4.NUMVINC||' Atributo: '||R4.VANTAGEM||' Info: '||R4.INFO||' Dt. Início: '||R4.DTINI||' Dt. Fim: '||R4.DTFIM||' Erro: '||SQLERRM;
        END;
        IF SQL%ROWCOUNT  > 0 THEN
          V_CRIADOS_VAN := V_CRIADOS_VAN +1;
          LOG_PACK.INSERE_LOG_DETAIL (P_ID_EXEC, 'Criado o atributo. ID: '||R4.NUMFUNC||'-'||R4.NUMVINC||' Atributo: '||R4.VANTAGEM||' Info: '||R4.INFO||' Dt. Início: '||R4.DTINI||' Dt. Fim: '||R4.DTFIM);
        END IF;
      ELSE
        -- CRIA A GEE COM DTINI = P_DT_TRANSF E DTFIM ORIGINAL (SE NULA CONTINUA NULA, SE PREENCHIDA PERMANECE O VALOR PREENCHIDO NA DTFIM)--
        V_VANT.CHAVEVANT := NULL;
        V_VANT.ID_REG    := NULL;
        V_VANT.PONTPUBL  := NULL;
        V_VANT.DTINI     := P_DT_TRANSF;
        BEGIN
          INSERT INTO VANTAGENS (CHAVEVANT, ID_REG, PONTPUBL, DTINI) VALUES (R4.CHAVEVANT, R4.ID_REG, R4.PONTPUBL, R4.DTINI);
        EXCEPTION
        WHEN OTHERS THEN
          V_ERROS_VAN := V_ERROS_VAN +1;
          --LOG_PACK.INSERE_LOG_DETAIL (P_ID_EXEC, 'Erro ao criar atributo: ID: '||R4.NUMFUNC||'-'||R4.NUMVINC||' Atributo: '||R4.VANTAGEM||' Info: '||R4.INFO||' Dt. Início: '||R4.DTINI||' Dt. Fim: '||R4.DTFIM||' Erro: '||SQLERRM);
          V_ERR_TXT_VAN := 'Erro ao criar atributo: ID: '||R4.NUMFUNC||'-'||R4.NUMVINC||' Atributo: '||R4.VANTAGEM||' Info: '||R4.INFO||' Dt. Início: '||R4.DTINI||' Dt. Fim: '||R4.DTFIM||' Erro: '||SQLERRM;
        END;
        IF SQL%ROWCOUNT  > 0 THEN
          V_CRIADOS_VAN := V_CRIADOS_VAN +1;
          LOG_PACK.INSERE_LOG_DETAIL (P_ID_EXEC, 'Criado atributo. ID: '||V_VANT.NUMFUNC||'-'||V_VANT.NUMVINC||' Atributo: '||V_VANT.VANTAGEM||' Info: '||V_VANT.INFO||' Dt. Início: '||V_VANT.DTINI||' Dt. Fim: '||V_VANT.DTFIM);
        END IF;
      END IF;
    END LOOP;
    -- SE DEU TUDO CERTO E AS VARIAVEIS DE ERRO NÃO ESTÃO SUJAS, DA COMMIT, SENÃO, DA ROLLBACK E ESCREVE NA AUDITORIA --
    IF V_ERR_TXT_VAN IS NULL AND V_ERR_TXT_EVENT IS NULL AND V_ERR_TXT_EXER IS NULL AND V_ERR_TXT_VAN_FECHA IS NULL THEN
      COMMIT;
    ELSE
      ROLLBACK;
      IF V_ERR_TXT_VAN_FECHA IS NOT NULL THEN
        LOG_PACK.INSERE_LOG_DETAIL (P_ID_EXEC, V_ERR_TXT_VAN_FECHA);
      END IF;
      IF V_ERR_TXT_VAN IS NOT NULL THEN
        LOG_PACK.INSERE_LOG_DETAIL (P_ID_EXEC, V_ERR_TXT_VAN);
      END IF;
      IF V_ERR_TXT_EVENT IS NOT NULL THEN
        LOG_PACK.INSERE_LOG_DETAIL (P_ID_EXEC, V_ERR_TXT_EVENT);
      END IF;
      IF V_ERR_TXT_EXER IS NOT NULL THEN
        LOG_PACK.INSERE_LOG_DETAIL (P_ID_EXEC, V_ERR_TXT_EXER);
      END IF;
      COMMIT;
    END IF;
  END LOOP;
  V_ERROS := V_ERROS_EF+V_ERROS_EX+V_ERROS_VAN;
  LOG_PACK.INSERE_LOG_DETAIL (P_ID_EXEC, 'Total de Atributos Encontrados  : '||V_REGISTROS_VAN);
  LOG_PACK.INSERE_LOG_DETAIL (P_ID_EXEC, 'Total de Atributos Fechados     : '||V_FECHADOS_VAN);
  LOG_PACK.INSERE_LOG_DETAIL (P_ID_EXEC, 'Total de Atributos Criados      : '||V_CRIADOS_VAN);
  LOG_PACK.INSERE_LOG_DETAIL (P_ID_EXEC, 'Erros de Atributos Ocorridos    : '||V_ERROS_VAN);
  LOG_PACK.INSERE_LOG_DETAIL (P_ID_EXEC, 'Total de Eventos Encontrados    : '||V_REGISTROS_EF);
  LOG_PACK.INSERE_LOG_DETAIL (P_ID_EXEC, 'Total de Eventos Fechados       : '||V_FECHADOS_EF);
  LOG_PACK.INSERE_LOG_DETAIL (P_ID_EXEC, 'Total de Eventos Criados        : '||V_CRIADOS_EF);
  LOG_PACK.INSERE_LOG_DETAIL (P_ID_EXEC, 'Erros de Eventos Ocorridos      : '||V_ERROS_EF);
  LOG_PACK.INSERE_LOG_DETAIL (P_ID_EXEC, 'Total de Exercícios Encontrados : '||V_REGISTROS_EX);
  LOG_PACK.INSERE_LOG_DETAIL (P_ID_EXEC, 'Total de Exercícios Fechados    : '||V_FECHADOS_EX);
  LOG_PACK.INSERE_LOG_DETAIL (P_ID_EXEC, 'Total de Exercícios Criados     : '||V_CRIADOS_EX);
  LOG_PACK.INSERE_LOG_DETAIL (P_ID_EXEC, 'Erros de Exercícios Ocorridos   : '||V_ERROS_EX);
  LOG_PACK.INSERE_LOG_DETAIL (P_ID_EXEC, 'Total de Erros Ocorridos        : '||V_ERROS);
  LOG_PACK.INSERE_LOG_DETAIL (P_ID_EXEC, 'Processo Finalizado.');
  COMMIT;
  IF V_ERROS = 0 THEN
   ergon_erro_pack.trata_erro(99,'Processo registrado na Auditoria de Processos Nº '||P_ID_EXEC||'. Nome: '||P_HEADER);
  ELSE
    ergon_erro_pack.trata_erro(99,'Ocorreram '||V_ERROS||' erros. Verificar Auditoria do Processos Nº '||P_ID_EXEC||'. Nome: '||P_HEADER);
  END IF;
END;
/
