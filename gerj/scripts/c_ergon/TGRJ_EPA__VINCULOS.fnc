prompt ***ATENÇÃO!!!*** Objeto TGRJ_EPA__VINCULOS não possui replace e deve ser mesclado manualmente com a versão existente no banco.
--
--  EP com get_transacao. 
--  Não altere essa função. Ela deverá ser alterado no cliente.
--
create FUNCTION TGRJ_EPA__VINCULOS(P_ROW_NEW   IN OUT NOCOPY VINCULOS%ROWTYPE,
                                                P_ROW_OLD   IN VINCULOS%ROWTYPE,
                                                P_INSERTING IN BOOLEAN,
                                                P_UPDATING  IN BOOLEAN,
                                                P_DELETING  IN BOOLEAN,
                                                P_MENS      OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN IS
  --
  v_contador       NUMBER(3);
  V_CONTA          NUMBER;
  v_numvinc        NUMBER(6);
  v_dtini_1        DATE;
  v_dtfim_1        DATE;
  v_dtini_2        DATE;
  v_dtfim_2        DATE;
  V_JORNADA        NUMBER := 0;
  V_QTDE           NUMBER := 0;
  V_COUNT_V        number := 0;
  V_COUNT_MILITAR  NUMBER := 0;
  V_COUNT_USUARIO  NUMBER := 0;
  V_CONTA_FERIAS   NUMBER := 0;
  V_MAX_DTFIM      DATE;
  V_MAX_DTFIM_CONC DATE;
  V_VAC            VARCHAR2(1):='N';
  --
  v_qtd_dias       NUMBER := 0;
  --
  v_count          number := 0;
  --
  v_nome_transacao varchar2(1000) := flag_pack.get_transacao;
  v_usuario        varchar2(100)  := flag_pack.get_usuario;
  --
  v_setor_pens     HAD_OPCOES_ITENS.OPCAO%TYPE;
  v_formaprov_pens HAD_OPCOES_ITENS.OPCAO%TYPE;

  reg_eve          evento_func%rowtype;
  --
  v_nat_principal  tipo_evento.natureza_principal%type;
  --
  v_tipo_vinc      vinculos.tipovinc%type := null;

  v_pontodoerro    Varchar2(100) := Null ;

  --Bernardo 03/08/2015 Início
  v_dtaposent      number:=0;
  v_dtvac          number:=0;
  V_QTDE_REGRA     NUMBER;
  --Bernardo 03/08/2015 Fim

  v_dtini_cessao   cessoes.dtini%type; -- 07/10/2015

  v_perfil_usu     perf_set_usu.perfil%type; -- Giselle 28/03/2016 - SGD 2707


BEGIN

--Bernardo 26/06/2015 Início

  if (P_INSERTING or P_UPDATING) and flag_pack.get_transacao not in ('Vacância','Instituidor de Pensão','Aposentadoria Temporal')  then --Bernardo 03/08/2015


     --Bernardo 03/08/2015 Início
     BEGIN
      --SELECT to_char(DTAPOSENT,'dd/mm/yyyy')
      SELECT 1
      INTO v_dtaposent
      FROM VINCULOS
      WHERE NUMFUNC = P_ROW_NEW.NUMFUNC
      AND NUMERO = P_ROW_NEW.NUMERO
      AND DTAPOSENT IS NOT NULL;
     EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_dtaposent := 0;
      WHEN OTHERS THEN
        v_dtaposent := 0;
     END;


     BEGIN
      --SELECT to_char(DTVAC,'dd/mm/yyyy')
      SELECT 1
      INTO v_dtvac
      FROM VINCULOS
      WHERE NUMFUNC = P_ROW_NEW.NUMFUNC
      AND NUMERO = P_ROW_NEW.NUMERO
      AND DTVAC IS NOT NULL;
     EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_dtvac := 0;
      WHEN OTHERS THEN
        v_dtvac := 0;
     END;


     --P_MENS := 'EPB Entrou na validação para informar a disciplina, numfunc : '|| P_ROW_NEW.NUMFUNC || ' numvinc : ' || P_ROW_NEW.NUMERO
     --          ||' Data Vacância: '|| to_char(v_dtvac) ||
     --          ' Data Aposentadoria : ' || to_char(v_dtaposent);



     if (v_dtaposent is not null) or (v_dtvac is not null) then
       null;
     elsif (v_dtaposent is null) and (v_dtvac is null) then
     --Bernardo 03/08/2015 Fim

       if PCK_VINCULOS.V_ROW_NEW.CATEGORIA
          in ('01 MAGISTERIO')
          and PCK_VINCULOS.V_ROW_NEW.FLEX_CAMPO_05 is null then

              P_MENS := 'Para vínculos da educação é necessário informar a disciplina.';

       end if;

     end if;


  end if;

  --Bernardo 26/06/2015 Fim
  IF p_updating THEN
    IF P_ROW_NEW.DTEXERC > TO_DATE('01/01/2011','DD/MM/YYYY') THEN
   --IF P_ROW_OLD.DTEXERC IS NOT NULL THEN
     IF P_ROW_NEW.DTEXERC > P_ROW_OLD.DTEXERC THEN
       SELECT COUNT(1)
         INTO V_CONTA
         FROM FICHAS_FINANCEIRAS FF
        WHERE FF.NUMFUNC = P_ROW_NEW.NUMFUNC
          AND FF.NUMVINC = P_ROW_NEW.NUMERO
          AND ROWNUM = 1;

        IF V_CONTA > 0 THEN
          P_MENS := 'Não é permitido a troca de data, pois o funcionários possui folha calculada.';
          return(true);
        END IF;

     END IF;
   END IF;
  END IF;


  -- Cristian Alves - 20/03/2015
  -- Manter a da data de vacância de falecimento do funcionário sincronizado com o vínculo.
 IF ((p_inserting) OR (p_updating))
 AND NVL(P_ROW_NEW.FORMAVAC,P_ROW_OLD.FORMAVAC) = 'FALECIMENTO'
 and FLAG_PACK.GET_TRANSACAO  NOT IN ('Instituidor de Pensão')
 THEN
    -- Se tiver removendo um falecimento
    IF P_ROW_NEW.DTVAC IS NULL AND P_ROW_OLD.DTVAC IS NOT NULL
    THEN
      SELECT COUNT(1) INTO v_count
      FROM REGRAS_PENSAO RP
      WHERE RP.TIPOPENS = 'PENSÃO PREVID'
      AND RP.NUMFUNC = P_ROW_NEW.NUMFUNC
      AND RP.NUMVINC = P_ROW_NEW.NUMERO;

      IF v_count > 0
      THEN
        p_mens := 'Não é possivel remover o falecimento porque existem regras de Pensão Previdênciária. Remova primeiro as regras de Pensão Previdênciária!';
        return(true);
      END IF;

      UPDATE FUNCIONARIOS F
      SET F.FLEX_CAMPO_21 = NULL,     -- DATA DE ÓBITO
          F.FLEX_CAMPO_22 = NULL,     -- MOTIVO PARA VAC.
          F.FLEX_CAMPO_23 = NULL,     -- SITUAÇÃO DO FUNCIONÁRIO
          F.TIPODOC_CERT_FIM = NULL,  -- TIPO DOCUMENTO (DESAPARECIMENTO, ÓBITO)
          F.MATRICULA_CERT_FIM = NULL -- MATRÍCULA DA CERTIDÃO
      WHERE F.NUMERO = P_ROW_NEW.NUMFUNC;
      --p_mens := 'Removendo Forma de vacância: '||NVL(P_ROW_NEW.FORMAVAC,P_ROW_OLD.FORMAVAC)||' - '||P_ROW_NEW.DTVAC||' - '||P_ROW_OLD.DTVAC;
    -- Se tiver alterando a data do falecimento
    ELSIF P_ROW_NEW.DTVAC IS NOT NULL
        AND P_ROW_NEW.DTVAC <> NVL(P_ROW_OLD.DTVAC, PACK_HADES.DATA_MAXIMA)
    THEN
      SELECT COUNT(1) INTO v_count
      FROM REGRAS_PENSAO RP
      WHERE RP.TIPOPENS = 'PENSÃO PREVID'
      AND RP.NUMFUNC = P_ROW_NEW.NUMFUNC
      AND RP.NUMVINC = P_ROW_NEW.NUMERO
      AND RP.DTINI < P_ROW_NEW.DTVAC;

      IF v_count > 0
      THEN
        p_mens := 'Não é possivel alterar a data do falecimento porque existem regras de Pensão Previdênciária anterior a data sendo alterada. Remova ou ajuste as regras de Pensão Previdênciária!';
        return(true);
      END IF;

      UPDATE FUNCIONARIOS F
      SET F.FLEX_CAMPO_21 = TO_CHAR(P_ROW_NEW.DTVAC,'DD/MM/YYYY'), -- DATA DE ÓBITO
      F.FLEX_CAMPO_22 = P_ROW_NEW.FORMAVAC                         -- MOTIVO PARA VAC.
      WHERE F.NUMERO = P_ROW_NEW.NUMFUNC;
      --p_mens := 'Alterando Forma de vacância: '||NVL(P_ROW_NEW.FORMAVAC,P_ROW_OLD.FORMAVAC)||' - '||P_ROW_NEW.DTVAC||' - '||P_ROW_OLD.DTVAC;
    END IF;
  END IF;
  --
  --
  IF (p_inserting) OR (p_updating) THEN
    IF P_ROW_NEW.Tipovinc = 'PREST TAREFA T CERTO' THEN

         SELECT COUNT(1)
           INTO V_COUNT_MILITAR
           FROM VINCULOS VI
          WHERE NUMFUNC   =  P_ROW_NEW.NUMFUNC
            AND REGIMEJUR = 'ESTATUTO MILITAR'
            AND 'INATIVO' IN  (SELECT PACK_ERGON.GET_SITUACAO_FUNC(TAB.NUMFUNC, TAB.NUMERO ,NULL,SYSDATE) SITUACAO
                                 FROM (SELECT VI.NUMFUNC, VI.NUMERO
                                         FROM VINCULOS VI
                                        WHERE VI.NUMFUNC   = P_ROW_NEW.NUMFUNC
                                          AND VI.REGIMEJUR = 'ESTATUTO MILITAR') TAB);


         IF V_COUNT_MILITAR = 0 THEN
            p_mens := 'Tipo de vínculo PREST TAREFA T CERTO só pode ser criado ou atualizado se '||
                     'servidor possuir outro vínculo Regime Jurídico ESTATUTO MILITAR e Situação Inativo.';
            return(true);
         END IF;

      END IF;
    end if;

  IF (p_inserting) OR (p_updating) THEN
    /* Execução da rotina tgrj_decimo_terceiro_prc com o objetivo de acertar os avos e
       pagar o 13º encerramento de folha.
    -- Allan Barbosa - 23/06/2014
    -- Solicitado pela Vera SGD  1509 */
    IF p_row_new.dtvac IS NOT NULL THEN
      tgrj_decimo_terceiro_prc(to_date(trunc(p_row_new.dtvac,'year')),p_row_new.numfunc,p_row_new.numero,null);
    END IF;
    --************************************************************************
    --Tratamento de acumulação de cargos no tipo de vinculo                  *
    --Celio Paulo. 22/05/2013.Solicitação conforme SGD 780  - Vera           *
    --************************************************************************
     IF V_NOME_TRANSACAO IN ('Ingresso','Eventos de Cargo','Vínculo') THEN
       BEGIN
         SELECT COUNT(1)
           INTO V_COUNT_V
              FROM VINCULOS
                 WHERE
                         NUMFUNC = p_row_new.NUMFUNC
                     AND TIPOVINC NOT IN ('CARGO EFETIVO');
       END;
       --
       IF V_COUNT_V > 1 THEN

         SELECT PGOV_RETORNA_ACUMULA_CARGO(p_row_new.NUMFUNC,
                                           p_row_new.NUMERO ,
                                           p_row_new.DTEXERC,
                                           p_row_new.DTVAC  ,
                                           p_row_new.TIPOVINC)
         INTO P_MENS FROM DUAL;

       END IF;
     END IF;
    --
    -- Remove periodo aquisitivo em determinadas situações de vacância.
    -- Allan Barbosa -
    -- Solicitado pela Vera 17/12/2013 que fossem aceitos todos os tipos
    -- de vinculo e todos os tipos de vacância.

    IF p_row_new.dtvac IS NOT NULL THEN
      IF (p_row_old.tipovinc IS NOT NULL) THEN

        IF (p_row_new.formavac IS NOT NULL) THEN


          v_qtd_dias := (p_row_new.dtvac - p_row_old.dtexerc);
          v_tipo_vinc:= p_row_old.tipovinc;

          SELECT COUNT(1)
           INTO V_CONTA_FERIAS
           FROM FERIAS
          WHERE numfunc = p_row_new.numfunc
            AND numvinc = p_row_new.numero
            AND DTFIM >= p_row_new.dtvac;

          IF V_CONTA_FERIAS >= 1 THEN
            P_MENS := 'O funcionario possui férias marcadas para um período após a data do desligamento.';
            RETURN(TRUE);
          END IF;

          IF (v_qtd_dias < 365) THEN
            IF (v_tipo_vinc <> 'REQUISICAO EXTERNA' AND
               v_tipo_vinc <> 'REQUISICAO INTERNA') THEN
              DELETE peraqfer p
               WHERE p.numfunc = p_row_new.numfunc
                 AND p.numvinc = p_row_new.numero;
            END IF;
          ELSE
            DELETE peraqfer p
             WHERE p.numfunc = p_row_new.numfunc
               AND p.numvinc = p_row_new.numero
               AND trunc(p.dtini, 'year') >
                   trunc(p_row_new.dtvac - 1, 'year');
          END IF;
        END IF;
      END IF;
    END IF;
    --

    --Verifica se a agencia e conta após modificação já se encontra cadastada na base e não deixa atualizar.
    IF (p_row_new.Agencia <> p_row_old.agencia) or
       (p_row_new.conta <> p_row_old.conta) then
      BEGIN
        SELECT DISTINCT NUMFUNC
          INTO V_QTDE
          FROM VINCULOS
         WHERE AGENCIA = LPAD(p_row_new.Agencia, 4, 0)
           AND CONTA = LPAD(p_row_new.conta, 9, 0)
           AND NUMFUNC <> p_row_new.Numfunc
           AND ROWNUM = 1;

        -- Se agÊncia por padrão não validar.
        IF V_QTDE > 0  AND p_row_new.Agencia <>  '0000' THEN
          P_MENS := 'Conta e agência já cadastrada para outro servidor. Atualização não concluída. ID. Funcional: ' ||
                    V_QTDE;
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
      END;

    END IF;

    --**********************************************************************************
    --Rotina que verifica se o banco digitado difere do banco padrao                   *
    --Celio Paulo. 13/01/2012.                                                         *
    --**********************************************************************************
    -- Teste de usuario incluido por Horacio em 16/01/2012 pois os dados importados ainda est?o com banco 341.
    if flag_pack.get_usuario like 'migra' then
      null;
    else
      if pack_hades.get_opcao('C_Ergon', 'GOVRJ', 'BANCO_PADRAO') <>
         p_row_new.banco then
        p_mens := 'Banco informado: ' || '[' || p_row_new.banco || ']' ||
                  ' e invalido!';
      end if;
    end if;
    -- Se estiver lancando aposentadoria deve fechar atributos que n?o s?o validos para inativo
    --
    IF NVL(p_row_new.NUMVINCANT, 0) <> NVL(p_row_old.NUMVINCANT, 0) THEN
      --
      BEGIN
        --
        SELECT v.DTEXERC, v.DTVAC
          INTO v_dtini_1, v_dtfim_1
          FROM vinculos v
         WHERE v.NUMFUNC = p_row_new.NUMFUNC
           AND v.NUMERO = p_row_new.NUMERO;
      EXCEPTION
        WHEN OTHERS THEN
          p_mens := 'Erro ao verificar existencia concomitancia entre os vinculos';
      END;
      --
      IF NVL(p_row_new.NUMVINCANT, 0) <> 0 THEN
        v_numvinc := NVL(p_row_new.NUMVINCANT, 0);
      ELSE
        v_numvinc := NVL(p_row_old.NUMVINCANT, 0);
      END IF;
      --
      BEGIN
        --
        SELECT v.DTEXERC, v.DTVAC
          INTO v_dtini_2, v_dtfim_2
          FROM vinculos v
         WHERE v.NUMFUNC = p_row_new.NUMFUNC
           AND v.NUMERO = v_numvinc;
      EXCEPTION
        WHEN OTHERS THEN
          p_mens := 'Erro ao verificar existencia concomitancia entre os vinculos';
      END;
      --
      SELECT NVL(pack_hades.EH_CONCOMITANTE(v_dtini_1,
                                            v_dtfim_1,
                                            v_dtini_2,
                                            v_dtfim_2),
                 0)
        INTO v_contador
        FROM DUAL;
      IF v_contador = 1 THEN
        BEGIN
          --
          DELETE FROM vinculo_que_conta vqc
           WHERE vqc.NUMFUNC = p_row_new.NUMFUNC
             AND vqc.NUMVINC = NVL(p_row_new.NUMVINCANT, 0);
        END;
        --
        BEGIN
          --
          DELETE FROM vinculo_que_conta vqc
           WHERE vqc.NUMFUNC = p_row_new.NUMFUNC
             AND vqc.NUMVINC = NVL(p_row_old.NUMVINCANT, 0);
        END;
        --
        IF NVL(p_row_new.NUMVINCANT, 0) <> 0 THEN
          BEGIN
            --
            INSERT INTO vinculo_que_conta
              (NUMFUNC, NUMVINC, NUMVINC_CONTA, EMP_CODIGO)
            VALUES
              (p_row_new.NUMFUNC,
               p_row_new.NUMVINCANT,
               p_row_new.NUMERO,
               p_row_new.EMP_CODIGO);
            /*  EXCEPTION
            WHEN OTHERS THEN
            p_mens := 'Erro ao inserir na tabela VINCULO_QUE_CONTA'||SQLERRM; */
          END;
        END IF;
      END IF;
    END IF;
    --
    --
    -- Encerra atributos, frequencias, exercicios e eventos quando do desligamento do servidor.
    -- Dagoberto 04/01/2011
    --
    IF p_row_new.flex_campo_11 <> p_row_old.flex_campo_11 THEN
      p_row_new.flex_campo_11 := UPPER(NVL(p_row_new.flex_campo_11, 'N'));
    END IF;

    --
    -- Encerra atributos caso seja dada vacancia para o servidor
    --
    IF p_row_new.dtvac IS NOT NULL AND p_row_old.dtvac IS NULL THEN
      FOR r1 IN (SELECT v.ROWID, v.dtini, NVL(t.FALECIDO, 'N') FALECIDO, V.VANTAGEM, v.info
                   FROM vantagens v, tipo_VANTAGEM T
                  WHERE v.numfunc = p_row_new.numfunc
                    AND v.numvinc = p_row_new.numero
                    AND v.vantagem = t.vantagem
                    AND (v.dtfim IS NULL OR v.dtfim >= p_row_new.dtvac)) LOOP
        BEGIN

          IF (r1.vantagem = 'SUSPENSAO PAGTO' AND  p_row_new.dtvac < r1.dtini
              AND (r1.info in( '075 Pedido de Exoneração','165 Abandono Contrato Temporario','065 Abandono de Serviço','000 Afastamento Indefinido'))) THEN
            P_MENS := 'A data do desligamento é diferente da data do código 75. Regularize a situação.';
            RETURN TRUE;
          END IF;

          IF (r1.vantagem = 'SUSPENSAO PAGTO' AND r1.dtini = p_row_new.dtvac
              AND (r1.info in( '075 Pedido de Exoneração','165 Abandono Contrato Temporario','065 Abandono de Serviço','000 Afastamento Indefinido')) ) THEN
              DELETE FROM vantagens
               WHERE ROWID = r1.ROWID;
          ELSE
            -- Cristian em 10/06/2013
            IF (p_row_new.formavac =
               PACK_HADES.GET_OPCAO('Ergon', 'ERGON', 'VAC_FALEC') AND
               r1.FALECIDO = 'N') -- Fechar apenas os atributos não permitidos após falecimento conforme cadastro em TIPO_VANTAGEM.
               OR (p_row_new.formavac <>
               PACK_HADES.GET_OPCAO('Ergon', 'ERGON', 'VAC_FALEC')) -- Fechar todos os atributos se for desligamento.
             THEN
              Begin
                  UPDATE vantagens
                     SET dtfim = p_row_new.dtvac - 1
                   WHERE ROWID = r1.ROWID;
              Exception
                   When Others Then
                        P_MENS := 'Erro ao Atualizar Vantagens.';
              End ;
            END IF;
          END IF;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            p_mens := 'Erro ao encerrar atributos do servidor';
        END;
      END LOOP;
      /*
      FOR r1 IN (SELECT v.ROWID
                   FROM vantagens v
                  WHERE v.numfunc = p_row_new.numfunc
                    AND v.numvinc = p_row_new.numero
                    AND (v.dtfim IS NULL OR v.dtfim >= p_row_new.dtvac)) LOOP
        BEGIN
          UPDATE vantagens
             SET dtfim = p_row_new.dtvac - 1
           WHERE rowid = r1.rowid;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            p_mens := 'Erro ao encerrar atributos do servidor';
        END;
      END LOOP;*/
      --
      -- Encerra frequencia caso seja dada vacancia para o servidor
      --
      FOR r1 IN (SELECT f.ROWID, F.DTINI, F.CODFREQ
                   FROM frequencias f
                  WHERE f.numfunc = p_row_new.numfunc
                    AND f.numvinc = p_row_new.numero
                    AND (f.dtfim IS NULL OR f.dtfim >= p_row_new.dtvac)) LOOP

       IF (r1.codfreq in (75, 65, 165) AND r1.dtini = p_row_new.dtvac) THEN
          BEGIN
              INSERT INTO PASTAS_FUNCIONAIS (NUMFUNC,NUMVINC,DATA, ASSUNTO, TEXTO)
              VALUES (P_ROW_NEW.NUMFUNC, P_ROW_NEW.NUMERO, SYSDATE, 'OCORR APOSENT/VACAN','Código: '||r1.codfreq||'  Data Início: '||TO_CHAR(r1.DTINI,'DD/MM/YYYY')||' - USUARIO: '||FLAG_PACK.GET_USUARIO );
          EXCEPTION
            WHEN OTHERS THEN
              P_MENS := 'Não foi possível incluir registro na tabela de Pastas Funcionais.'||', Erro = '|| had_formata_msg_erro(sqlerrm);
              RETURN TRUE;
          END;

          BEGIN
            DELETE FROM FREQUENCIAS
            WHERE ROWID = r1.ROWID;
          EXCEPTION
            WHEN OTHERS THEN
              P_MENS := 'Não foi possível excluir registro na tabela de Frequencias.'||', Erro = '|| had_formata_msg_erro(sqlerrm);
              RETURN TRUE;
          END;
        ELSIF (r1.codfreq in (75, 65, 165) AND r1.dtini <> p_row_new.dtvac) THEN
           P_MENS := 'A data do desligamento é diferente da data do código '||r1.codfreq||'. Regularize a situação.';
           RETURN TRUE;

        ELSE
          BEGIN
            UPDATE frequencias
               SET dtfim = p_row_new.dtvac - 1
             WHERE ROWID = r1.ROWID;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
                 p_mens := 'Erro ao encerrar frequencia do servidor';
            When Others Then
                 p_mens := 'Erro ao encerrar frequencia do servidor.';
              End ;
        END IF;
      END LOOP;
      --
      -- Encerra exercicios caso seja dada vacancia para o servidor
      --
      FOR r1 IN (SELECT ex.ROWID
                   FROM exercicios ex
                  WHERE ex.numfunc = p_row_new.numfunc
                    AND ex.numvinc = p_row_new.numero
                    AND (ex.dtfim IS NULL OR ex.dtfim >= p_row_new.dtvac)) LOOP
        BEGIN
          UPDATE exercicios
             SET dtfim = p_row_new.dtvac - 1
           WHERE rowid = r1.rowid;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            p_mens := 'Erro ao encerrar exercicios do servidor';
        END;
      END LOOP;
      --
      -- Encerra cessoes caso seja dada vacancia para o servidor
      --
      FOR r1 IN (SELECT cc.ROWID
                   FROM cessoes cc
                  WHERE cc.numfunc = p_row_new.numfunc
                    AND cc.numvinc = p_row_new.numero
                    AND (cc.dtfim IS NULL OR cc.dtfim >= p_row_new.dtvac)
                    AND p_row_new.formavac =
                        PACK_HADES.GET_OPCAO('Ergon', 'ERGON', 'VAC_FALEC')) LOOP
        BEGIN
          UPDATE cessoes
             SET dtfim = p_row_new.dtvac - 1
           WHERE rowid = r1.rowid;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            p_mens := 'Erro ao encerrar cessoes do servidor';
        END;
      END LOOP;


      -- Retirada esta parte para a inclusao do codigo do SGD-1250 lgoo abaixo ---
      --
      -- Encerra eventos caso seja dada vacancia para o servidor
      --
      FOR r1 IN (SELECT ef.rowid, ef.formaprov, ef.dtini, ef.setor
                   FROM evento_func ef
                  WHERE ef.numfunc = p_row_new.numfunc
                    AND ef.numvinc = p_row_new.numero
                    AND (ef.dtfim IS NULL OR ef.dtfim >= p_row_new.dtvac)) LOOP

        IF ((r1.formaprov = 'AFASTAMENTO' OR ((SUBSTR(r1.setor,(length(r1.setor)-2),3)) = '777')) AND p_row_new.dtvac < r1.dtini) THEN
          P_MENS := 'A data do desligamento é diferente da data de um dos códigos: 65, 75 ou 165. Regularize a situação.';
          RETURN TRUE;
        END IF;

        IF ((r1.formaprov = 'AFASTAMENTO' OR ((SUBSTR(r1.setor,(length(r1.setor)-2),3)) = '777'))
          AND r1.dtini = p_row_new.dtvac) THEN

          BEGIN
            DELETE FROM evento_func
            WHERE ROWID = r1.ROWID;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              p_mens := 'Erro ao encerrar eventos do servidor';
              RETURN TRUE;
          END;

        ELSE
          BEGIN
            UPDATE evento_func
               SET dtfim = p_row_new.dtvac - 1
             WHERE rowid = r1.rowid;
          EXCEPTION
               WHEN others THEN
                    p_mens := 'Erro ao encerrar evento...: '
                    ||TRANSLATE(
                    HADES_ERRO_PACK.TRATA_MSG_ERRO_BANCO(sqlerrm),(chr(13) || chr(10)),
                    '  ');
                    return(true);
          END;
        END IF;
      END LOOP;
      --
      --------------------------------------------------------------------------
      --- Encerra eventos caso seja dada vacancia para o servidor            ---
      --- SGD-1250 - POR: Luiz Roberto Amorim - Techne - 12/02/2014          ---
      --------------------------------------------------------------------------

      FOR r1 IN (SELECT ef.*
                   FROM evento_func ef
                  WHERE ef.numfunc = p_row_new.numfunc
                    AND ef.numvinc = p_row_new.numero
                    AND (ef.dtfim IS NULL OR ef.dtfim >= p_row_new.dtvac)
                  order by dtini desc) LOOP
          BEGIN

              reg_eve := r1;

              -- para eventos posteriores a data de vacancia
              -- se servidor vai deixar evento de insituidor de pensao
              --    então
              --        tem que manter o evento e trocar o setor
              -- se servidor não vai deixar evento de instituidor de pensão
              --    entao
              --        remover o evento posterior

              v_pontodoerro := 'A1';

              CERG_SETOR_PENS(P_ROW_NEW, P_ROW_OLD, v_setor_pens);

              v_pontodoerro := 'A2';
              v_setor_pens := nvl(v_setor_pens,
                                  PACK_HADES.GET_OPCAO('Ergon',
                                                       'ERGON',
                                                       'SETPENS'));

              v_pontodoerro := 'A3';
              --v_formaprov_pens := nvl (CERG_FORMAPROV_PENS(P_ROW_NEW.NUMFUNC, P_ROW_NEW.NUMERO), PACK_HADES.GET_OPCAO ('Ergon', 'ERGON', 'FORMAPROVPENS'));
              v_formaprov_pens := nvl(C_ERGON.CERG_FORMAPROV_PENS_01(P_ROW_NEW.NUMFUNC,
                                                             P_ROW_NEW.NUMERO,
                                                             P_ROW_NEW.DTVAC),
                                      PACK_HADES.GET_OPCAO('Ergon',
                                                           'ERGON',
                                                           'FORMAPROVPENS')); --Teste Anderson Cardoso
              v_pontodoerro := 'A4';
              --
              -- VERIFICAR SE TEM QUE GRAVAR O EVENTO DE INSTITUIDOR DE PENSAO

              BEGIN
                  SELECT upper(natureza_principal)
                    INTO v_nat_principal
                    FROM tipo_evento
                   WHERE tipoevento = R1.TIPOEVENTO;
              EXCEPTION
                   WHEN OTHERS THEN
                        v_nat_principal := Null;
              END;

              --- Eventos Posteriores a Vancancia
              if r1.dtini >= p_row_new.dtvac then

                -- Se desligamento <> FALECIMENTO remover registro
                if  p_row_new.formavac <> PACK_HADES.GET_OPCAO('Ergon', 'ERGON', 'VAC_FALEC') then
                    Begin
                        update had_opcoes_itens
                           set valor = 'S'
                         where sis   = 'Ergon'
                           and grupo = 'ERGON'
                           and opcao = 'VAC_AUT' ;
                    End ;
                else -- Se desligamento = FALECIMENTO
                   -- alterar o setor? o produto vai tentar incluir novo evento de falecido?
                   --IF  v_nat_principal = 'PROVIMENTO' or   ??? PRECISA DESTA CONDICAO ???
                   IF (p_row_new.regimejur = 'CLT' and p_row_new.dtaposent is not null) then
                       Begin
                           update had_opcoes_itens
                              set valor = 'N'
                            where sis   = 'Ergon'
                              and grupo = 'ERGON'
                              and opcao = 'VAC_AUT' ;
                       End ;
                   else
                       Begin
                           update had_opcoes_itens
                              set valor = 'N'
                            where sis   = 'Ergon'
                              and grupo = 'ERGON'
                              and opcao = 'VAC_AUT' ;
                       End ;
                   end if;
                end if;

              else

                 --- Eventos Anteriores a Vancancia
                 -- para os eventos iniciados antes de dtvac e formavac FALECIMENTO
                 -- verificar se vai ter instuidor de pensão

                 if p_row_new.formavac =
                    PACK_HADES.GET_OPCAO('Ergon', 'ERGON', 'VAC_FALEC')         and
                    p_row_new.regimejur = 'CLT' and p_row_new.dtaposent is null and
                    PACK_HADES.GET_OPCAO('Ergon', 'ERGON', 'VAC_AUT') = 'S' then

                    Begin
                        update had_opcoes_itens
                           set valor = 'N'
                         where sis = 'Ergon'
                           and grupo = 'ERGON'
                           and opcao = 'VAC_AUT';
                    End;
                 else
                    BEGIN
                        UPDATE evento_func
                           SET dtfim = p_row_new.dtvac - 1
                         WHERE numev = r1.numev ;
                    EXCEPTION
                         WHEN others THEN
                              p_mens := 'Erro ao encerrar evento: '
                              ||TRANSLATE(
                              HADES_ERRO_PACK.TRATA_MSG_ERRO_BANCO(sqlerrm),(chr(13) || chr(10)),
                              '  ');
                               RETURN(true);
                    END;

                    /*
                       --VERIFICAR SE É CLT APOSENTADO
                       -- se for falecimento, inclui o evento de instituidor
                       -- na data do falecimento
                       IF  v_nat_principal = 'PROVIMENTO' or
                           (p_row_new.regimejur = 'CLT' and p_row_new.dtaposent is not null) then
                           reg_eve.formaprov := v_formaprov_pens;
                           reg_eve.setor     := v_setor_pens;
                           reg_eve.dtini     := p_row_new.dtvac;
                           reg_eve. numev    := null;
                           reg_eve. pontlei  := null;
                           reg_eve. pontpubl := null;
                           reg_eve. id_reg   := null;
                           --
                           begin
                               insert into evento_func
                               values reg_eve;
                           EXCEPTION
                                WHEN NO_DATA_FOUND THEN
                                     p_mens := 'Erro ao encerrar eventos do servidor';
                           end;
                       end if;
                    */

                 end if;

              end if;

          END;

      END LOOP;

      --------------------------------------------------------------------------
      --- FIM DAS ALTERACOES SGD-1250
      --------------------------------------------------------------------------


    END IF;


    -- Permitir que seja atribuida uma vacância, mesmo que a conta e agencia estejam nulas
    -- mas impedir remover a vacância esm estar com a conta e agencia preenchidas.
    -- Reinaldo Mesquita - 14/08/2013
    if v_nome_transacao = 'Vacância' then

      if p_row_new.dtvac is null then
        -- quando remove uma vacância:
        --Somente se o tipo de pagamento for SEMCC que a conta e agência podem ser nulas
        if P_ROW_NEW.TIPOPAG <> 'SEMCC' then

          IF P_ROW_NEW.CONTA IS NULL AND P_ROW_NEW.FLEX_CAMPO_20 IS NULL THEN
            p_mens := 'Conta Corrente ou Salário Obrigatórias para esse tipo de pagamento.';
          END IF;
          --
          IF P_ROW_NEW.AGENCIA IS NULL AND P_ROW_NEW.FLEX_CAMPO_19 IS NULL THEN
            p_mens := 'Agência Corrente ou Salário Obrigatórias para esse tipo de pagamento.';
          END IF;

        END IF;

      END IF;
      --
        --Inserido por Rodrigo Machado em 24/08/2015 para atender SGD 1069
        --Inclusão de um novo tratamento para que a vacância só seja encerrada quando não existir data da regra,
        --Este tratamento abaixo não deverá atender ao MS605, pois para o caso do MS605 a regra é diferente.
        --LUANA. 31/08/2015. SGD 1543.

        SELECT COUNT(1)
          INTO V_QTDE_REGRA
          FROM DEPENDENTES      DE,
               REGRAS_PENSAO_AL RP,
               ITEMTABELA       IT
         WHERE DE.NUMFUNC = RP.NUMFUNC
           AND DE.NUMERO  = RP.NUMDEP
           AND RP.BASE    = IT.ITEM
           AND IT.TAB     = 'CERG_BASE_PENSAO_AL'
           AND RP.NUMFUNC = P_ROW_NEW.NUMFUNC
           AND RP.NUMVINC = P_ROW_NEW.NUMERO
           AND RP.DTFIM   IS NULL;

      IF V_QTDE_REGRA > 0 THEN

         UPDATE REGRAS_PENSAO_AL
            SET DTFIM   = P_ROW_NEW.DTVAC - 1
          WHERE NUMFUNC = P_ROW_NEW.NUMFUNC
            AND NUMVINC = P_ROW_NEW.NUMERO
            AND BASE NOT IN ('PENSÃO AL MS605', 'BLOQ JUD MS605')
            AND DTFIM IS NULL;
         --
      END IF;
      --
      --Este tratamento é para encerrar regra do MS605 ('PENSÃO AL MS605' e 'BLOQ JUD MS605')
      --para FALECIMENTO. LUANA 01/09/2015. SGD 1543.
      IF (P_ROW_NEW.FORMAVAC = 'FALECIMENTO' OR P_ROW_OLD.FORMAVAC = 'FALECIMENTO') THEN

         IF P_ROW_NEW.DTVAC IS NOT NULL THEN--OR P_ROW_NEW.DTVAC IS NULL THEN
            BEGIN
               SELECT MAX(DTFIM)
                 INTO V_MAX_DTFIM
                 FROM REGRAS_PENSAO_AL
                WHERE NUMFUNC = P_ROW_NEW.NUMFUNC
                  AND NUMVINC = P_ROW_NEW.NUMERO
                  AND BASE IN ('PENSÃO AL MS605', 'BLOQ JUD MS605');
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  V_MAX_DTFIM := NULL;
            END;
            --
            BEGIN
               SELECT MAX(DT_FIM)
                 INTO V_MAX_DTFIM_CONC
                 FROM PGOV_CONC_BENEF_MS605
                WHERE NUMFUNC = P_ROW_NEW.NUMFUNC
                  AND NUMVINC = P_ROW_NEW.NUMERO
                  AND TIPO IN ('MENSAL MS605', 'ATRASADO MS605');
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  V_MAX_DTFIM_CONC := NULL;
            END;
            --
            IF V_MAX_DTFIM > P_ROW_NEW.DTVAC  THEN

               p_mens := 'Existe Regra encerrada com data posterior à Vacância!';

            ELSIF V_MAX_DTFIM_CONC  > P_ROW_NEW.DTVAC  THEN

               p_mens := 'Existe Concessão encerrada com data posterior à Vacância!';

            ELSE

               --IF P_ROW_NEW.DTVAC IS NOT NULL THEN

                  UPDATE REGRAS_PENSAO_AL
                     SET DTFIM         = P_ROW_NEW.DTVAC,
                         FLEX_CAMPO_24 = 'S' --Indica vacância gerada
                   WHERE NUMFUNC = P_ROW_NEW.NUMFUNC
                     AND NUMVINC = P_ROW_NEW.NUMERO
                     AND BASE IN ('PENSÃO AL MS605', 'BLOQ JUD MS605')
                     AND ((DTFIM IS NULL AND NVL(FLEX_CAMPO_24, 'N') = 'N')
                     OR    FLEX_CAMPO_24 = 'S');
                  --
                  UPDATE PGOV_CONC_BENEF_MS605
                     SET DT_FIM            = P_ROW_NEW.DTVAC,
                         FLAG_DESLIGAMENTO = 'S' --Indica vacância gerada
                   WHERE NUMFUNC  = P_ROW_NEW.NUMFUNC
                     AND NUMVINC  = P_ROW_NEW.NUMERO
                     AND ((DT_FIM IS NULL AND NVL(FLAG_DESLIGAMENTO, 'N') = 'N')
                     OR    FLAG_DESLIGAMENTO = 'S');
            END IF;

         ELSIF  P_ROW_NEW.DTVAC IS NULL THEN

            UPDATE REGRAS_PENSAO_AL
               SET DTFIM         = P_ROW_NEW.DTVAC,
                   FLEX_CAMPO_24 = NULL --Para inserir null
             WHERE NUMFUNC = P_ROW_NEW.NUMFUNC
               AND NUMVINC = P_ROW_NEW.NUMERO
               AND BASE IN ('PENSÃO AL MS605', 'BLOQ JUD MS605')
               AND FLEX_CAMPO_24 = 'S';--Indica vacância gerada
               --
               UPDATE PGOV_CONC_BENEF_MS605
                  SET DT_FIM            = P_ROW_NEW.DTVAC,
                      FLAG_DESLIGAMENTO = NULL
                WHERE NUMFUNC           = P_ROW_NEW.NUMFUNC
                  AND NUMVINC           = P_ROW_NEW.NUMERO
                  AND FLAG_DESLIGAMENTO = 'S';
               --
         END IF;
     END IF;--LUANA 01/09/2015.

    ELSE

     SELECT COUNT(1)
         INTO V_COUNT_USUARIO
         FROM ITEMTABELA IT
        WHERE IT.ITEM = V_USUARIO
          AND IT.TAB = 'PGOV_LIBERA_CHEQUEOP';

     IF V_COUNT_USUARIO = 0 THEN

      --Somente se o tipo de pagamento for SEMCC que a conta e agência podem ser nulas
      IF P_ROW_NEW.TIPOPAG <> 'SEMCC' THEN

        IF P_ROW_NEW.CONTA IS NULL AND P_ROW_NEW.FLEX_CAMPO_20 IS NULL THEN
          p_mens := 'Conta Corrente ou Salário Obrigatórias para esse tipo de pagamento.';
        END IF;
        --
        IF P_ROW_NEW.AGENCIA IS NULL AND P_ROW_NEW.FLEX_CAMPO_19 IS NULL THEN
          p_mens := 'Agência Corrente ou Salário Obrigatórias para esse tipo de pagamento.';
        END IF;

      END IF;

      END IF;

    END IF;
     --Comentado conforme solicitação do SGD 1466 por Rodrigo Machado em 09/06/2014.
    /*
    --Verifica o perfil caso permita pode modificar os campos responsáveis pela
    --agencia e conta salário
    if nvl(p_row_new.flex_campo_19, 'XXXXX') <>
       NVL(P_ROW_OLD.Flex_Campo_19, 'XXXXX') then

      SELECT COUNT(1)
        INTO v_count
        FROM padusuario p
       where p.padaces = 'Com_CONTA SAL'
         and p.usuario = FLAG_PACK.get_usuario;

      if v_count = 0 then
        p_mens := 'Usuário não possui perfil para incluir ou atualizar o campo Agência Salário.';
        RETURN(TRUE);
      end if;

    end if;
    --
    if NVL(p_row_new.flex_campo_20, 'XXXXX') <>
       NVL(P_ROW_OLD.Flex_Campo_20, 'XXXXX') then

      SELECT COUNT(1)
        INTO v_count
        FROM padusuario p
       where p.padaces = 'Com_CONTA SAL'
         and p.usuario = FLAG_PACK.get_usuario;

      if v_count = 0 then
        p_mens := 'Usuário não possui perfil para incluir ou atualizar o campo Conta Salário.';
        RETURN(TRUE);
      end if;

    end if;
    */
    --
    if p_row_new.flex_campo_20 is not null and
       p_row_new.flex_campo_19 is not null then
      p_row_new.flex_campo_09 := 'CSAL';
    end if;

    -- Cristian em 09/07/2013 - Gravar registro de encerramento de 13º Salário.
    IF nvl(p_row_new.dtvac, pack_hades.data_maxima) <>
       nvl(p_row_old.dtvac, pack_hades.data_maxima) THEN
      tgrj_decimo_terceiro_prc(nvl(p_row_new.dtvac, p_row_old.dtvac),
                               p_row_new.numfunc,
                               p_row_new.numero,
                               null);
    END IF;

  ELSIF (p_deleting) THEN
    --
    -- Se o registro for apagado, atualiza a tabela vinculo que conta
    BEGIN
      --
      DELETE FROM vinculo_que_conta vqc
       WHERE vqc.NUMFUNC = p_row_old.NUMFUNC
         AND vqc.NUMVINC = NVL(p_row_old.NUMVINCANT, 0);
      --
    END;
  END IF;

-- Módulo de Integração SIGRH x RIOPREVIDENCIA - Auditoria da tabela de Vinculos
-- Bloco abaixo comentado por que a tabela TGRJ_INTE_VINCULOS_AUDIT não existe.
-- Segundo Cristian esse bloco ainda não deveria estar em produção.
/*
DECLARE
  V_DML  CHAR(1) DEFAULT NULL;
  V_CONT NUMBER DEFAULT 0;
  V_ID_EXEC LOG_PROCESSO_HEADER.ID_EXEC%TYPE DEFAULT 0;
  V_SIGLA LOG_PROCESSO_HEADER.SIGLA%TYPE DEFAULT 'Auditoria de Integração SIGRH x RIOPREVIDENCIA - TGRJ_EPA__VINCULOS';
  V_MSG_NEW  VARCHAR2(500) DEFAULT ' - Numfunc: '||P_ROW_NEW.NUMFUNC||' - Numvinc: '||P_ROW_NEW.NUMERO;
  V_MSG_OLD  VARCHAR2(500) DEFAULT ' - Numfunc: '||P_ROW_OLD.NUMFUNC||' - Numvinc: '||P_ROW_OLD.NUMERO;
  VORIGEM    VARCHAR2(01) := 'S';
  VIDREG     NUMBER DEFAULT 0;
  VDTRIOPREV DATE;
BEGIN
  BEGIN
     SELECT ID_EXEC
       INTO V_ID_EXEC
       FROM LOG_PROCESSO_HEADER
      WHERE SIGLA = V_SIGLA;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    V_ID_EXEC := 0;
  END;
  --
  IF V_ID_EXEC = 0 THEN
    V_ID_EXEC := LOG_PACK.INSERE_LOG_HEADER_ASYNC(V_SIGLA, '') ;
  ELSE
     DELETE
       FROM LOG_PROCESSO_DETAIL
      WHERE ID_EXEC = V_ID_EXEC;
  END IF;
  IF P_INSERTING THEN
    V_DML := 'I';
  END IF;
  IF P_UPDATING THEN
    V_DML := 'U';
  END IF;
  IF P_DELETING THEN
    V_DML := 'D';
  END IF;
  --
  IF NVL(FLAG_PACK.GET_TRANSACAO, 'XXX') = 'Integração RIOPREVIDENCIA' THEN
    VORIGEM                             := 'R'; -- Rioprevidencia
    VDTRIOPREV                          := SYSDATE;
  ELSE
    VORIGEM    := 'S'; -- SIGRH
    VDTRIOPREV := NULL;
  END IF;
  --
  IF V_DML = 'I' THEN
     SELECT COUNT(1)
       INTO V_CONT
       FROM TGRJ_INTE_VINCULOS_AUDIT AD

      WHERE AD.NUMFUNC = P_ROW_NEW.NUMFUNC
      AND AD.NUMERO    = P_ROW_NEW.NUMERO
      AND AD.ORIGEM    = VORIGEM
      AND AD.DTEVENTO  = TRUNC(SYSDATE)
      AND AD.DTENVIO  IS NULL;
  ELSE
     SELECT COUNT(1)
       INTO V_CONT
       FROM TGRJ_INTE_VINCULOS_AUDIT AD
      WHERE AD.NUMFUNC = P_ROW_OLD.NUMFUNC
      AND AD.NUMERO    = P_ROW_OLD.NUMERO
      AND AD.ORIGEM    = VORIGEM
      AND AD.DTEVENTO  = TRUNC(SYSDATE)
      AND AD.DTENVIO  IS NULL;
  END IF;
  --
   SELECT NVL(MAX(ID_AUDIT), 0) + 1
     INTO VIDREG
     FROM TGRJ_INTE_VINCULOS_AUDIT;
  --
  IF(V_CONT = 0) THEN
    BEGIN
      IF V_DML = 'D' THEN
         INSERT
           INTO TGRJ_INTE_VINCULOS_AUDIT
          (
            NUMFUNC
          , NUMERO
          , ORIGEM
          , DTEVENTO
          , DTENVIO
          , DTCONFIRMACAO
          , DTENVIO_CONFIRMACAO
          , EVENTO_DML
          , ID_AUDIT
          )
          VALUES
          (
            P_ROW_OLD.NUMFUNC
          , P_ROW_OLD.NUMERO
          , VORIGEM
          , TRUNC(SYSDATE)
          , VDTRIOPREV
          , NULL
          , NULL
          , V_DML
          , VIDREG
          ) ;
        LOG_PACK.INSERE_LOG_DETAIL_ASYNC(V_ID_EXEC, '001 DML: '||V_DML||V_MSG_OLD||' Inserido...') ;
      ELSE
         INSERT
           INTO TGRJ_INTE_VINCULOS_AUDIT
          (
            NUMFUNC
          , NUMERO
          , ORIGEM
          , DTEVENTO
          , DTENVIO
          , DTCONFIRMACAO
          , DTENVIO_CONFIRMACAO
          , EVENTO_DML
          , ID_AUDIT
          )
          VALUES
          (
            P_ROW_NEW.NUMFUNC
          , P_ROW_NEW.NUMERO
          , VORIGEM
          , TRUNC(SYSDATE)
          , VDTRIOPREV
          , NULL
          , NULL
          , V_DML
          , VIDREG
          ) ;
        LOG_PACK.INSERE_LOG_DETAIL_ASYNC(V_ID_EXEC, '001 DML: '||V_DML||V_MSG_NEW||' Inserido...') ;
      END IF;
    EXCEPTION
    WHEN OTHERS THEN
      LOG_PACK.INSERE_LOG_DETAIL_ASYNC(V_ID_EXEC, '100 DML: '||V_DML||V_MSG_NEW||' - Erro ao inserir: '||SQLERRM) ;
    END;
  ELSIF(V_CONT > 0 AND V_DML = 'I') THEN
    BEGIN
       DELETE
         FROM TGRJ_INTE_VINCULOS_AUDIT AD
        WHERE AD.NUMFUNC = P_ROW_NEW.NUMFUNC
        AND AD.NUMERO    = P_ROW_NEW.NUMERO
        AND AD.ORIGEM    = VORIGEM
        AND AD.DTEVENTO  = TRUNC(SYSDATE)
        AND AD.DTENVIO  IS NULL;
      LOG_PACK.INSERE_LOG_DETAIL_ASYNC(V_ID_EXEC, '002 DML: '||V_DML||V_MSG_NEW||' - Deletado para Re-Inserir...') ;
      BEGIN
         INSERT
           INTO TGRJ_INTE_VINCULOS_AUDIT
          (
            NUMFUNC
          , NUMERO
          , ORIGEM
          , DTEVENTO
          , DTENVIO
          , DTCONFIRMACAO
          , DTENVIO_CONFIRMACAO
          , EVENTO_DML
          , ID_AUDIT
          )
          VALUES
          (
            P_ROW_NEW.NUMFUNC
          , P_ROW_NEW.NUMERO
          , VORIGEM
          , TRUNC(SYSDATE)
          , VDTRIOPREV
          , NULL
          , NULL
          , V_DML
          , VIDREG
          ) ;
        LOG_PACK.INSERE_LOG_DETAIL_ASYNC(V_ID_EXEC, '003 DML: '||V_DML||V_MSG_NEW||' Inserido...') ;
      EXCEPTION
      WHEN OTHERS THEN
        LOG_PACK.INSERE_LOG_DETAIL_ASYNC(V_ID_EXEC, '300 DML: '||V_DML||V_MSG_NEW||' - Erro ao inserir: '||SQLERRM) ;
      END;
    EXCEPTION
    WHEN OTHERS THEN
      LOG_PACK.INSERE_LOG_DETAIL_ASYNC(V_ID_EXEC, '200 DML: '||V_DML||V_MSG_OLD||' - Erro ao deletar para inserir: '||
      SQLERRM) ;
    END;
  ELSIF(V_CONT > 0 AND V_DML = 'U') THEN
    BEGIN
       UPDATE TGRJ_INTE_VINCULOS_AUDIT AD
      SET AD.NUMFUNC     = P_ROW_NEW.NUMFUNC
      , AD.NUMERO        = P_ROW_NEW.NUMERO
        WHERE AD.NUMFUNC = P_ROW_OLD.NUMFUNC
        AND AD.NUMERO    = P_ROW_OLD.NUMERO
        AND AD.ORIGEM    = VORIGEM
        AND AD.DTEVENTO  = TRUNC(SYSDATE)
        AND AD.DTENVIO  IS NULL;
      LOG_PACK.INSERE_LOG_DETAIL_ASYNC(V_ID_EXEC, '004 DML: '||V_DML||V_MSG_NEW||' - Atualizado para Inserir...') ;
    EXCEPTION
    WHEN OTHERS THEN
      LOG_PACK.INSERE_LOG_DETAIL_ASYNC(V_ID_EXEC, '400 DML: '||V_DML||V_MSG_OLD||' - Erro ao atualizar: '||SQLERRM) ;
    END;
  ELSIF(V_CONT > 0 AND V_DML = 'D') THEN
    BEGIN
       DELETE
         FROM TGRJ_INTE_VINCULOS_AUDIT AD
        WHERE AD.NUMFUNC = P_ROW_OLD.NUMFUNC
        AND AD.NUMERO    = P_ROW_OLD.NUMERO
        AND AD.ORIGEM    = VORIGEM
        AND AD.DTEVENTO  = TRUNC(SYSDATE)
        AND AD.DTENVIO  IS NULL;
      LOG_PACK.INSERE_LOG_DETAIL_ASYNC(V_ID_EXEC, '005 DML: '||V_DML||V_MSG_OLD||' - Deletado...') ;
    EXCEPTION
    WHEN OTHERS THEN
      LOG_PACK.INSERE_LOG_DETAIL_ASYNC(V_ID_EXEC, '500 DML: '||V_DML||V_MSG_OLD||' - Erro ao deletar: '||SQLERRM) ;
    END;
  END IF;
END;
*/
  --
  -- jair.caponi 09/09/2015 SGD 1586
  --
  -- Comentado em 23/03/2016, porque a tabela
  /*
  if (P_ROW_NEW.DTVAC IS NULL AND P_ROW_OLD.DTVAC IS NOT NULL) OR (P_ROW_OLD.DTVAC IS NULL AND P_ROW_NEW.DTVAC IS NOT NULL)
     OR (P_ROW_NEW.DTAPOSENT IS NULL AND P_ROW_OLD.DTAPOSENT IS NOT NULL) OR (P_ROW_OLD.DTAPOSENT IS NULL AND P_ROW_NEW.DTAPOSENT IS NOT NULL) then
     tgrj_pgto_ferias(NVL(P_ROW_NEW.NUMFUNC,P_ROW_OLD.NUMFUNC)
                     ,NVL(P_ROW_NEW.NUMERO,P_ROW_OLD.NUMERO)
                     ,NULL);
  end if;   */
  --


  -- Incluído por Giselle da Silva em 07/10/2015 / SGD 2221
  -- Não permitir inserir/atualizar data de início: da aba Requisição diferente da data de exercício da aba Ingresso
  if p_inserting or P_UPDATING then

   if p_row_new.tipovinc = 'REQUISICAO INTERNA' then

      if P_ROW_NEW.Dtini_Cessao <> P_ROW_NEW.Dtexerc then
        p_mens := 'A data de início da requisição interna, deve ser igual a data de exercício do vínculo.';
      end if;
      --
      -- Giselle da Silva 09/10/2015 - Realizar o tratamento abaixo para transação diferente de Vacância
      -- Não permitir inserir/atualizar data de início da requisição diferente da data de início da cessão do vínculo de origem
      if v_nome_transacao not in  ('Vacância') THEN

          begin
        select c.dtini
          into v_dtini_cessao
          from vinculos v, cessoes c
         where v.numfunc = c.numfunc
           and v.flex_campo_08 = c.numvinc
           and c.numvinc = P_ROW_NEW.Flex_Campo_08
           and v.numfunc = P_ROW_NEW.Numfunc
           AND C.DTINI =  P_ROW_NEW.DTINI_CESSAO
           AND V.DTINI_CESSAO = P_ROW_NEW.DTINI_CESSAO;

        exception
          when no_data_found then
            p_mens := 'A cessão não foi encontrada. Favor verificar a informação de cessão da origem deste servidor.';

          WHEN OTHERS THEN
            p_mens := ' Erro inesperado ao carregar a data de início da cessão do vínculo de origem.' ;

        end;

        /*if P_ROW_NEW.Dtini_Cessao <> v_dtini_cessao then
          p_mens := 'A data de início da requisição interna, deve ser igual a data de início da cessão.';

        end if;   */
      end if;
      --
   end if;

  end if;
  --



  RETURN(true);
  --

EXCEPTION
     WHEN OTHERS THEN
          p_mens := 'Erro inesperado na EPA_VINCULOS '||sqlerrm(sqlcode);
          return (true) ;

          -----------------------------------------------------------
          --- Por Luiz Amorim - Techne - em 13/02/2014 - SGD-1250 ---
          --- VOLTA A POSICAO DA VAC_AUT                          ---
          -----------------------------------------------------------

          if (P_INSERTING or P_UPDATING) THEN
              if PCK_VINCULOS.V_ROW_NEW.formavac  = PACK_HADES.GET_OPCAO('Ergon', 'ERGON', 'VAC_FALEC') and
                 PCK_VINCULOS.V_ROW_NEW.regimejur = 'CLT'                                               and
                 PCK_VINCULOS.V_ROW_NEW.dtaposent is null                                               and
                 PACK_HADES.GET_OPCAO('Ergon', 'ERGON', 'VAC_AUT') = 'N'                                then
                 Begin
                     update had_opcoes_itens
                        set valor = 'S'
                      where sis   = 'Ergon'
                        and grupo = 'ERGON'
                        and opcao = 'VAC_AUT' ;
                 End ;
              end if ;
          end if ;

          ----
          --P_MENS := v_pontodoerro || ' - Erro não esperado TGRJ_EPA__VINCULOS (12): ' || sqlerrm(sqlcode);
          --P_MENS := sqlerrm(sqlcode);
    --      RETURN(true);

END;
/
