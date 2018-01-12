prompt ***ATENÇÃO!!!*** Objeto GRJ_EPA__PENSIONISTAS não possui replace e deve ser mesclado manualmente com a versão existente no banco.
create FUNCTION GRJ_EPA__PENSIONISTAS (P_ROW_NEW   IN OUT NOCOPY PENSIONISTAS%ROWTYPE,
                                P_ROW_OLD   IN     PENSIONISTAS%ROWTYPE,
                                P_INSERTING IN     BOOLEAN,
                                P_UPDATING  IN     BOOLEAN,
                                P_DELETING  IN     BOOLEAN,
                                P_MENS         OUT NOCOPY VARCHAR2) RETURN BOOLEAN IS
  V_NUMERO    NUMBER;
  V_TRANSACAO VARCHAR2(200);
  VCONTADOR   NUMBER;
  v_cpf_unico                   HAD_OPCOES_ITENS.OPCAO%TYPE;
  V_COUNT                       NUMBER;
  v_erro      varchar2(2000);

BEGIN

  IF FLAG_PACK.GET_USUARIO = 'migra' THEN
    RETURN (TRUE);
  END IF;

  --Bernardo SGD 2273 Início
  IF P_INSERTING  THEN

   BEGIN
     SELECT COUNT(*)
     INTO V_COUNT
     FROM PENSIONISTAS
     WHERE LTRIM(REPLACE(FLEX_CAMPO_32,'-',''),'0') = LTRIM(REPLACE(P_ROW_NEW.FLEX_CAMPO_32,'-',''),'0');
   EXCEPTION
     WHEN OTHERS THEN
       V_COUNT := 0;
   END;

   IF V_COUNT > 0 THEN
     P_MENS := 'Não é permitido novo cadastro de matrícula SAPE já existente.';
     RETURN (TRUE);
   END IF;

  END IF;
  --Bernardo SGD 2273 Fim


  /* ====================================================================================
  Data: 11/11/2014
     Por: Luciana Ferreira - TECHNE
   Regra: Validar CPF duplicado conforme opção genérica especifica criada para a tabela
  ====================================================================================*/
  /*-----------------------------------------------------------------
    Para a transação do MS605 CPF não será tratado aqui.
    LUANA 09/09/2015 - SGD 1543.
    -----------------------------------------------------------------*/
 IF NVL(FLAG_PACK.GET_TRANSACAO,'XX') NOT IN ('Dados Gerais MS605', 'RJadm00067') THEN

   IF (P_UPDATING OR P_INSERTING) THEN
       v_cpf_unico := NVL(PACK_HADES.GET_OPCAO ('C_Ergon', 'GOVRJ', 'CPF_UNICO_PENS'), 'N');
       IF v_cpf_unico = 'S' AND P_ROW_NEW.cpf is not null THEN
          PRC_VALID_CPF (P_ROW_NEW.cpf, P_ROW_NEW.numfunc, P_ROW_NEW.numvinc, 'PENSIONISTAS');
       END IF;
   END IF;
 END IF;--LUANA 09/09/2015 - SGD 1543.

  /*-----------------------------------------------------------------
    --Tratamento CPF e CNPJ para o MS605.
    CPF ou CNPJ deverão ser preenchidos. LUANA 28/07/2015 - SGD 1543.
    FLEX_CAMPO_33 IGUAL A CNPJ. LUANA 28/07/2015 - SGD 1543.
    -----------------------------------------------------------------*/
  IF (P_INSERTING OR P_UPDATING) THEN

     IF NVL(FLAG_PACK.GET_TRANSACAO,'XX') IN ('Dados Gerais MS605', 'RJadm00067') THEN
        --
        IF P_ROW_NEW.CPF IS NULL AND P_ROW_NEW.FLEX_CAMPO_33 IS NULL THEN
           P_MENS := ' O preenchimento do campo CPF / CNPJ é obrigatório!';
           RETURN(TRUE);
        ELSIF P_ROW_NEW.CPF IS NOT NULL AND P_ROW_NEW.FLEX_CAMPO_33 IS NOT NULL THEN
           P_MENS := ' Somente um dos campos deverá ser preenchido CPF OU CNPJ!';
           RETURN(TRUE);
         --Verificado com o Gerente Egidio que, no MS605 não é preciso verificar se CPF já está cadastrado. Luana 16/06/2016. SGD1543.           
        /*ELSIF P_ROW_NEW.CPF IS NOT NULL THEN 
           IF P_INSERTING THEN--Aqui só será inserção, pois já existe tratamento para alteração caso o CPF informado já exista.
              --
              PRC_VALID_CPF (P_ROW_NEW.cpf, P_ROW_NEW.numfunc, P_ROW_NEW.numvinc, 'PENSIONISTAS');
              --
           END IF;*/
        ELSIF P_ROW_NEW.FLEX_CAMPO_33 IS NOT NULL THEN
           IF P_INSERTING OR P_UPDATING THEN
              --
              PGOV_PRC_VALID_CNPJ (P_ROW_NEW.flex_campo_33, P_ROW_NEW.numfunc, P_ROW_NEW.numvinc, 'PENSIONISTAS', v_erro);
              --
           END IF;
        END IF;
        --
     END IF;--LUANA 28/07/2015 - SGD 1543.
  END IF;
  --
  /*
  Acrescentado "RJadm00040" na verificação abaixo, pois essa regra foi pensada para o Ergon Forms. No Ergon NG,
  a transação é "RJadm00040" e não "Regras de Pensão Previdenciária".
  */
  IF P_INSERTING AND NVL(FLAG_PACK.GET_TRANSACAO,'XX') NOT IN ('Regras de Pensão Previdenciária', 'RJadm00040') THEN
     IF P_ROW_NEW.FLEX_CAMPO_04 IS NULL THEN
       /*-----------------------------------------------------------------
         CPF e CNPJ para MS605 já estão sendo verificados na validação acima.
         LUANA 29/07/2015 - SGD 1543.
         -----------------------------------------------------------------*/
       IF NVL(FLAG_PACK.GET_TRANSACAO,'XX') NOT IN ('Dados Gerais MS605', 'RJadm00067') THEN
        IF P_ROW_NEW.CPF     IS NULL THEN
           P_MENS             := ' O preenchimento do campo CPF é obrigatório';
           RETURN(TRUE);
--      ELSIF P_ROW_NEW.FLEX_CAMPO_28 IS NULL THEN
--         P_MENS                      := ' O preenchimento do campo Raca é obrigatório';
--         RETURN(TRUE);
--      ELSIF P_ROW_NEW.FLEX_CAMPO_27 IS NULL THEN
--         P_MENS                      := ' O preenchimento do campo Email é obrigatório';
--         RETURN(TRUE);
--      ELSIF P_ROW_NEW.FLEX_CAMPO_26 IS NULL THEN
--         P_MENS                      := ' O preenchimento do campo PISPASEP é obrigatório';
--         RETURN(TRUE);
--      ELSIF P_ROW_NEW.FLEX_CAMPO_21 IS NULL THEN
--         P_MENS                      := ' O preenchimento do campo Naturalidade é obrigatório';
--         RETURN(TRUE);
--      ELSIF P_ROW_NEW.FLEX_CAMPO_22 IS NULL THEN
--         P_MENS                      := ' O preenchimento do campo UF Nascimento é obrigatório';
--         RETURN(TRUE);
--      ELSIF P_ROW_NEW.FLEX_CAMPO_23 IS NULL THEN
--         P_MENS                      := ' O preenchimento do campo Nome do Pai é obrigatório';
--         RETURN(TRUE);
        ELSIF P_ROW_NEW.FLEX_CAMPO_24 IS NULL THEN
           P_MENS                      := ' O preenchimento do campo Nome do Mãe é obrigatório';
           RETURN(TRUE);
        ELSIF P_ROW_NEW.FLEX_CAMPO_25 IS NULL THEN
           P_MENS                      := ' O preenchimento do campo Nacionalidade é obrigatório';
           RETURN(TRUE);
--      ELSIF P_ROW_NEW.FLEX_CAMPO_29 IS NULL THEN
--         P_MENS                      := ' O preenchimento do campo Deficiente é obrigatório';
--         RETURN(TRUE);
--      ELSIF P_ROW_NEW.FLEX_CAMPO_30 IS NULL AND P_ROW_NEW.FLEX_CAMPO_29 = 'S' THEN
--         P_MENS                      := ' O preenchimento do campo Tipo Deficiencia é obrigatório';
--         RETURN(TRUE);
        END IF;
      END IF;--LUANA 29/07/2015.
        --
        /*-----------------------------------------------------------------------
         Foi verificado com o Cristian que transação não tem mais necessidade
         de ser flegada e que o campo flex_campo_50 não precisará mais ser
         alimentado.
         LUANA 09/09/2015 - SGD 1543.
         ------------------------------------------------------------------------*/
        --V_TRANSACAO := FLAG_PACK.GET_TRANSACAO;

        --FLAG_PACK.SET_TRANSACAO('Instituidor de Pensão');
        --
        SELECT MAX(NUMERO) INTO VCONTADOR
        FROM FUNCIONARIOS
        WHERE CPF = P_ROW_NEW.CPF;
        --
        IF NVL(VCONTADOR,0) = 0 THEN
           BEGIN
             INSERT INTO FUNCIONARIOS
              (NUMERO, NOME, SEXO, DTNASC, CIDNASC, UFNASC, PAI, MAE, ESTCIVIL, NACIONALIDADE,
               NUMRG, TIPORG, ORGAORG, UFRG, CPF, NUMTITEL, ZONATITEL, SECTITEL, UFTITEL,
               PISPASEP, TIPOLOGENDER, NOMELOGENDER, NUMENDER, COMPLENDER, BAIRROENDER,
               CIDADEENDER, UFENDER, CEPENDER, TELEFONE, E_MAIL, RACA, DEFICIENTE, EXPEDRG,
               TIPODEFIC)--, FLEX_CAMPO_50)
               VALUES
              (NULL,
               UPPER(P_ROW_NEW.NOME), P_ROW_NEW.SEXO, P_ROW_NEW.DTNASC, P_ROW_NEW.FLEX_CAMPO_21, P_ROW_NEW.FLEX_CAMPO_22,
               UPPER(P_ROW_NEW.FLEX_CAMPO_23), UPPER(P_ROW_NEW.FLEX_CAMPO_24), P_ROW_NEW.ESTCIVIL, P_ROW_NEW.FLEX_CAMPO_25,  P_ROW_NEW.NUMRG,
               P_ROW_NEW.TIPORG, P_ROW_NEW.ORGAORG, P_ROW_NEW.UFRG, P_ROW_NEW.CPF, P_ROW_NEW.NUMTITEL, P_ROW_NEW.ZONATITEL,
               P_ROW_NEW.SECTITEL, P_ROW_NEW.UFTITEL, P_ROW_NEW.FLEX_CAMPO_26, P_ROW_NEW.TIPOLOGENDER, P_ROW_NEW.NOMELOGENDER,
               P_ROW_NEW.NUMENDER, P_ROW_NEW.COMPLENDER, P_ROW_NEW.BAIRRO, P_ROW_NEW.CIDADE, P_ROW_NEW.UF, P_ROW_NEW.CEPENDER,
               P_ROW_NEW.TELEFONE, P_ROW_NEW.FLEX_CAMPO_27, P_ROW_NEW.FLEX_CAMPO_28, P_ROW_NEW.FLEX_CAMPO_29, P_ROW_NEW.EXPEDRG,
               P_ROW_NEW.FLEX_CAMPO_30)--, 'PENSAO PREVIDENCIARIA')
             RETURNING NUMERO INTO V_NUMERO;
           EXCEPTION
             WHEN OTHERS THEN
                  P_MENS := ' Ocorreu um problema na geração do ID. FUNCIONAL para o Pensionista' || had_formata_msg_erro(SQLERRM);
                  RETURN(TRUE);
           END;
        ELSE
           V_NUMERO := VCONTADOR;
        END IF;
        --
        IF V_NUMERO IS NOT NULL THEN
           BEGIN
             --
             UPDATE PENSIONISTAS
             SET FLEX_CAMPO_04 = V_NUMERO
             WHERE NUMFUNC   = P_ROW_NEW.NUMFUNC
             AND   NUMVINC   = P_ROW_NEW.NUMVINC
             AND   NUMERO    = P_ROW_NEW.NUMERO;
           EXCEPTION
             WHEN OTHERS THEN
                  P_MENS := 'Ocorreu um problema ao gravar o ID. FUNCIONAL para o Pensionista ' || had_formata_msg_erro(SQLERRM);
                  RETURN(TRUE);
           END;
        END IF;
        --
        --FLAG_PACK.SET_TRANSACAO(V_TRANSACAO);
     ELSE
        /*---------------------------------------------------------------------------
         Foi verificado com o Egidio e a Leila que, ao cadastrar um pensionista
         novo que possui cadastro na tabela de funcionários e o mesmo for
         modificado na aba de Dados Pessoais e/ou Documentos (RG e Titulo Eleitoral)
         na tela de pensionistas, será também automaticamente alterado nos dados
         cadastrais de funcionários.
         Foi analisado com o Cristian que esta rotina irá ser liberada para todos os
         cadastros de pensões (Especial, MS605 e Previdenciário). LUANA 11/09/2015 -
         SGD 1543.
         -----------------------------------------------------------------------------*/
         --IF NVL(FLAG_PACK.GET_TRANSACAO,'XX') = 'Dados Gerais MS605' THEN --para teste

            BEGIN
               UPDATE FUNCIONARIOS
                  SET SEXO               = P_ROW_NEW.SEXO                ,
                      NOME               = UPPER(p_row_new.NOME)         ,
                      DTNASC             = p_row_new.DTNASC              ,
                      ESTCIVIL           = P_ROW_NEW.ESTCIVIL            ,
                      NUMRG              = p_row_new.NUMRG               ,
                      TIPORG             = P_ROW_NEW.TIPORG              ,
                      ORGAORG            = P_ROW_NEW.ORGAORG             ,
                      UFRG               = P_ROW_NEW.UFRG                ,
                      EXPEDRG            = P_ROW_NEW.EXPEDRG             ,
                      CPF                = P_ROW_NEW.CPF                 ,
                      NUMTITEL           = P_ROW_NEW.NUMTITEL            ,
                      ZONATITEL          = P_ROW_NEW.ZONATITEL           ,
                      SECTITEL           = P_ROW_NEW.SECTITEL            ,
                      UFTITEL            = P_ROW_NEW.UFTITEL             ,
                      TIPOLOGENDER       = P_ROW_NEW.TIPOLOGENDER        ,
                      NOMELOGENDER       = P_ROW_NEW.NOMELOGENDER        ,
                      NUMENDER           = P_ROW_NEW.NUMENDER            ,
                      COMPLENDER         = P_ROW_NEW.COMPLENDER          ,
                      BAIRROENDER        = P_ROW_NEW.BAIRRO              ,
                      CIDADEENDER        = P_ROW_NEW.CIDADE              ,
                      UFENDER            = P_ROW_NEW.UF                  ,
                      CEPENDER           = P_ROW_NEW.CEPENDER            ,
                      TELEFONE           = P_ROW_NEW.TELEFONE            ,
                      CIDNASC            = P_ROW_NEW.FLEX_CAMPO_21       ,
                      UFNASC             = P_ROW_NEW.FLEX_CAMPO_22       ,
                      E_MAIL             = P_ROW_NEW.FLEX_CAMPO_03       ,
                      PAI                = UPPER(P_ROW_NEW.FLEX_CAMPO_23),
                      MAE                = UPPER(P_ROW_NEW.FLEX_CAMPO_24),
                      NACIONALIDADE      = P_ROW_NEW.FLEX_CAMPO_25       ,
                      --PISPASEP           = P_ROW_NEW.FLEX_CAMPO_26       ,--Verificado com a Marina que não é necessário atualizar campo. LUANA. 21/07/2016.
                      PISPASEP           = P_ROW_NEW.FLEX_CAMPO_26       ,--A página ERGadm00237 requereu a atualização desse campo. TECHNE. 12/09/2016
                      RACA               = P_ROW_NEW.FLEX_CAMPO_28       ,
                      DEFICIENTE         = P_ROW_NEW.FLEX_CAMPO_29       ,
                      TIPODEFIC          = P_ROW_NEW.FLEX_CAMPO_30
                WHERE NUMERO             = P_ROW_NEW.FLEX_CAMPO_04;
            EXCEPTION
               WHEN OTHERS THEN
                  --FLAG_PACK.SET_TRANSACAO(V_TRANSACAO);
                  P_MENS := 'Ocorreu um problema ao atualizar o ID. FUNCIONAL para o Pensionista ' || had_formata_msg_erro(SQLERRM);
                  RETURN(TRUE);
           END;
           --
           --
       --END IF;
     END IF;
  ELSIF P_UPDATING AND NVL(FLAG_PACK.GET_TRANSACAO,'XX') <> 'Regras de Pensão Previdenciária' THEN

     /*------------------------------------------------------------------------
         Foi comentado o if abaixo, pois a atualização na tabela de funcionarios
         deverá ocorrer sempre que surgir a modificação de um dado na pensão. Dado
         este que esteja diferente do cadastro de funcionários.
         LUANA 11/09/2015 - SGD 1543.
         -------------------------------------------------------------------------*/
     --IF P_ROW_NEW.FLEX_CAMPO_04 IS NULL THEN
        --
        --V_TRANSACAO := FLAG_PACK.GET_TRANSACAO;
        --FLAG_PACK.SET_TRANSACAO('Instituidor de Pensão');
        --
        BEGIN
          UPDATE FUNCIONARIOS
          SET SEXO          = P_ROW_NEW.SEXO                 ,
              NOME          = UPPER(p_row_new.NOME)          ,
              DTNASC        = p_row_new.DTNASC               ,
              ESTCIVIL      = P_ROW_NEW.ESTCIVIL             ,
              NUMRG         = p_row_new.NUMRG                ,
              TIPORG        = P_ROW_NEW.TIPORG               ,
              ORGAORG       = P_ROW_NEW.ORGAORG              ,
              UFRG          = P_ROW_NEW.UFRG                 ,
              EXPEDRG       = P_ROW_NEW.EXPEDRG              ,
              CPF           = P_ROW_NEW.CPF                  ,
              NUMTITEL      = P_ROW_NEW.NUMTITEL             ,
              ZONATITEL     = P_ROW_NEW.ZONATITEL            ,
              SECTITEL      = P_ROW_NEW.SECTITEL             ,
              UFTITEL       = P_ROW_NEW.UFTITEL              ,
              TIPOLOGENDER  = P_ROW_NEW.TIPOLOGENDER         ,
              NOMELOGENDER  = P_ROW_NEW.NOMELOGENDER         ,
              NUMENDER      = P_ROW_NEW.NUMENDER             ,
              COMPLENDER    = P_ROW_NEW.COMPLENDER           ,
              BAIRROENDER   = P_ROW_NEW.BAIRRO               ,
              CIDADEENDER   = P_ROW_NEW.CIDADE               ,
              UFENDER       = P_ROW_NEW.UF                   ,
              CEPENDER      = P_ROW_NEW.CEPENDER             ,
              TELEFONE      = P_ROW_NEW.TELEFONE             ,
              CIDNASC       = P_ROW_NEW.FLEX_CAMPO_21        ,
              UFNASC        = P_ROW_NEW.FLEX_CAMPO_22        ,
              PAI           = UPPER(P_ROW_NEW.FLEX_CAMPO_23) ,
              MAE           = UPPER(P_ROW_NEW.FLEX_CAMPO_24) ,
              NACIONALIDADE = P_ROW_NEW.FLEX_CAMPO_25        ,
              --PISPASEP      = P_ROW_NEW.FLEX_CAMPO_26        ,--Verificado com a Marina que não é necessário atualizar campo. LUANA. 21/07/2016.
              PISPASEP           = P_ROW_NEW.FLEX_CAMPO_26   ,--A página ERGadm00237 requereu a atualização desse campo. TECHNE. 12/09/2016
              --E_MAIL        = P_ROW_NEW.FLEX_CAMPO_27        ,--Foi verificado com o gerente Egidio.
              E_MAIL        = P_ROW_NEW.FLEX_CAMPO_03        ,  --Foi verificado com o gerente Egidio.
              RACA          = P_ROW_NEW.FLEX_CAMPO_28        ,
              DEFICIENTE    = P_ROW_NEW.FLEX_CAMPO_29        ,
              TIPODEFIC     = P_ROW_NEW.FLEX_CAMPO_30
          WHERE NUMERO      = P_ROW_OLD.FLEX_CAMPO_04;
        EXCEPTION
          WHEN OTHERS THEN
               P_MENS := 'Ocorreu um problema ao atualizar o ID. FUNCIONAL para o Pensionista ' || had_formata_msg_erro(SQLERRM);
               RETURN(TRUE);
        END;
        --
        --FLAG_PACK.SET_TRANSACAO(V_TRANSACAO);
     --END IF;
  ELSIF P_INSERTING AND NVL(FLAG_PACK.GET_TRANSACAO,'XX') = 'Regras de Pensão Previdenciária' THEN
    BEGIN
        SELECT COUNT(1)
        INTO VCONTADOR
        FROM ERG_FORMAPROV_VALID_ EFV, VINCULOS V
        WHERE EFV.REGIMEJUR = V.REGIMEJUR
        AND EFV.TIPOVINC    = V.TIPOVINC
        AND EFV.FORMAPROV   = PACK_HADES.GET_OPCAO('Ergon', 'ERGON', 'FORMAPROVPENS')
        AND EFV.CATEGORIA   = V.CATEGORIA
        AND V.NUMFUNC       = p_row_new.NUMFUNC
        AND V.NUMERO        = p_row_new.NUMVINC;
    EXCEPTION
    WHEN OTHERS THEN
      P_MENS := 'Problemas ao tentar verificar se o vínculo é apto a concessão de pensão previdênciária';
    END;
    --
    IF NVL(VCONTADOR,0) = 0 THEN
      P_MENS := 'O vínculo selecionado para implantação do pensionista não é apto a concessão de pensão previdênciária';
    END IF;
    --
  END IF;
  --
  /*
  IF (P_INSERTING OR
     P_UPDATING) and FLAG_PACK.GET_USUARIO <> 'migra' THEN
     --
     FOR REG_DOC IN (SELECT TIPO, TIPODOC FROM TGRJ_TIPO_BENEF_DOCUMENTO)  LOOP
       --
       VCONTADOR := 0;
       --
       SELECT COUNT(1) INTO VCONTADOR
       FROM TGRJ_DOC_PENSIONISTA
       WHERE NUMFUNC   = P_ROW_NEW.NUMFUNC
       AND   NUMVINC   = P_ROW_NEW.NUMVINC
       AND   NUMPENS   = P_ROW_NEW.NUMERO
       AND   TIPOBENEF = REG_DOC.TIPO
       AND   TIPODOC   = REG_DOC.TIPODOC;
       --
       IF VCONTADOR = 0 THEN
          BEGIN
            INSERT INTO TGRJ_DOC_PENSIONISTA
                (NUMFUNC, NUMVINC, NUMPENS, TIPOBENEF, TIPODOC, APRESENTOU)
            VALUES
                (P_ROW_NEW.NUMFUNC, P_ROW_NEW.NUMVINC, P_ROW_NEW.NUMERO, REG_DOC.TIPO, REG_DOC.TIPODOC, 'N');
          EXCEPTION
            WHEN OTHERS THEN
                 P_MENS := 'Ocorreu um problema ao carregar os documentos para apresentação do PENSIONISTA ' || had_formata_msg_erro(SQLERRM);
                 RETURN(TRUE);
          END;
       END IF;
       --
     END LOOP;
  END IF;
  */





  --
  -- Módulo de Integração SIGRH x RIOPREVIDENCIA - Auditoria da tabela de Tgrj_Inte_Pensionistas_Audit
  /*
  if FLAG_PACK.GET_USUARIO <> 'migra' then
   DECLARE
    V_DML       CHAR(1)                             DEFAULT NULL;
    V_CONT      NUMBER                              DEFAULT 0;
    V_ID_EXEC   LOG_PROCESSO_HEADER.ID_EXEC%TYPE    DEFAULT 0;
    V_SIGLA     LOG_PROCESSO_HEADER.SIGLA%TYPE      DEFAULT 'Auditoria de Integração SIGRH x RIOPREVIDENCIA - GRJ_EPA__PENSIONISTAS';
    V_MSG_NEW   VARCHAR2(500)                       DEFAULT ' - Numfunc: '||P_ROW_NEW.NUMFUNC||' - Numvinc: '||P_ROW_NEW.NUMVINC||' - Numero: '||P_ROW_NEW.NUMERO;
    V_MSG_OLD   VARCHAR2(500)                       DEFAULT ' - Numfunc: '||P_ROW_OLD.NUMFUNC||' - Numvinc: '||P_ROW_OLD.NUMVINC||' - Numero: '||P_ROW_OLD.NUMERO;
    VORIGEM     VARCHAR2(01) := 'S';
    VIDREG      NUMBER := 0;
    VDTRIOPREV  DATE;
  BEGIN
    BEGIN
      SELECT ID_EXEC INTO V_ID_EXEC
      FROM LOG_PROCESSO_HEADER
      WHERE SIGLA = V_SIGLA;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
           V_ID_EXEC := 0;
    END;
    --
    IF V_ID_EXEC = 0 THEN
       V_ID_EXEC := LOG_PACK.INSERE_LOG_HEADER_ASYNC(V_SIGLA, '');
    ELSE
       DELETE FROM LOG_PROCESSO_DETAIL WHERE ID_EXEC = V_ID_EXEC;
    END IF;

    IF P_INSERTING  THEN V_DML := 'I'; END IF;
    IF P_UPDATING   THEN V_DML := 'U'; END IF;
    IF P_DELETING   THEN V_DML := 'D'; END IF;
    --
    IF NVL(FLAG_PACK.GET_TRANSACAO,'XXX') = 'Integração RIOPREVIDENCIA' THEN
       VORIGEM    := 'R'; -- Rioprevidencia
       VDTRIOPREV := SYSDATE;
    ELSE
       VORIGEM    := 'S'; -- SIGRH
       VDTRIOPREV := NULL;
    END IF;
    --
    IF V_DML = 'I' THEN
       SELECT COUNT(1) INTO V_CONT
       FROM TGRJ_INTE_PENSIONISTAS_AUDIT AD
       where AD.NUMFUNC  = P_ROW_NEW.NUMFUNC
       AND   AD.NUMVINC  = P_ROW_NEW.NUMVINC
       AND   AD.NUMERO   = P_ROW_NEW.NUMERO
       AND   AD.ORIGEM   = VORIGEM
       AND   AD.DTEVENTO = TRUNC(SYSDATE)
       AND   AD.DTENVIO  IS NULL;
    ELSE
       SELECT COUNT(1) INTO V_CONT
       FROM TGRJ_INTE_PENSIONISTAS_AUDIT AD
       where AD.NUMFUNC  = P_ROW_OLD.NUMFUNC
       AND   AD.NUMVINC  = P_ROW_OLD.NUMVINC
       AND   AD.NUMERO   = P_ROW_OLD.NUMERO
       AND   AD.ORIGEM   = VORIGEM
       AND   AD.DTEVENTO = TRUNC(SYSDATE)
       AND   AD.DTENVIO  IS NULL;
    END IF;
    --
    SELECT NVL(MAX(ID_AUDIT),0) + 1 INTO VIDREG
    FROM TGRJ_INTE_PENSIONISTAS_AUDIT;
    --
    IF (V_CONT = 0) THEN
       BEGIN
         IF V_DML = 'D' THEN
            INSERT INTO TGRJ_INTE_PENSIONISTAS_AUDIT
                 (NUMFUNC, NUMVINC, NUMERO, ORIGEM, DTEVENTO, DTENVIO, DTCONFIRMACAO, DTENVIO_CONFIRMACAO, EVENTO_DML, ID_AUDIT)
            VALUES
                 (P_ROW_OLD.NUMFUNC, P_ROW_OLD.NUMVINC, P_ROW_OLD.NUMERO,VORIGEM,TRUNC(SYSDATE),VDTRIOPREV, NULL, NULL,V_DML, VIDREG);
            LOG_PACK.INSERE_LOG_DETAIL_ASYNC(V_ID_EXEC, '001 DML: '||V_DML||V_MSG_OLD||' Inserido...');
         ELSE
            INSERT INTO TGRJ_INTE_PENSIONISTAS_AUDIT
                  (NUMFUNC, NUMVINC, NUMERO, ORIGEM, DTEVENTO, DTENVIO, DTCONFIRMACAO, DTENVIO_CONFIRMACAO, EVENTO_DML, ID_AUDIT)
            VALUES (P_ROW_NEW.NUMFUNC, P_ROW_NEW.NUMVINC, P_ROW_NEW.NUMERO,VORIGEM,TRUNC(SYSDATE), VDTRIOPREV, NULL, NULL,V_DML, VIDREG);

            LOG_PACK.INSERE_LOG_DETAIL_ASYNC(V_ID_EXEC, '001 DML: '||V_DML||V_MSG_NEW||' Inserido...');
         END IF;
       EXCEPTION
         WHEN OTHERS THEN
              LOG_PACK.INSERE_LOG_DETAIL_ASYNC(V_ID_EXEC, '100 DML: '||V_DML||V_MSG_NEW||' - Erro ao inserir: '||SQLERRM);
       END;
    ELSIF (V_CONT > 0 AND V_DML = 'I') THEN
       BEGIN
         DELETE FROM TGRJ_INTE_PENSIONISTAS_AUDIT AD
         WHERE AD.NUMFUNC  = P_ROW_NEW.NUMFUNC
         AND   AD.NUMVINC  = P_ROW_NEW.NUMVINC
         AND   AD.NUMERO   = P_ROW_NEW.NUMERO
         AND   AD.ORIGEM   = VORIGEM
         AND   AD.DTEVENTO = TRUNC(SYSDATE)
         AND   AD.DTENVIO  IS NULL;

         LOG_PACK.INSERE_LOG_DETAIL_ASYNC(V_ID_EXEC, '002 DML: '||V_DML||V_MSG_NEW||' - Deletado para Re-Inserir...');

         BEGIN
           INSERT INTO TGRJ_INTE_PENSIONISTAS_AUDIT
                  (NUMFUNC, NUMVINC, NUMERO, ORIGEM, DTEVENTO, DTENVIO, DTCONFIRMACAO, DTENVIO_CONFIRMACAO, EVENTO_DML, ID_AUDIT)
           VALUES (P_ROW_NEW.NUMFUNC, P_ROW_NEW.NUMVINC, P_ROW_NEW.NUMERO, VORIGEM, TRUNC(SYSDATE), VDTRIOPREV, NULL, NULL, V_DML,VIDREG);
                    LOG_PACK.INSERE_LOG_DETAIL_ASYNC(V_ID_EXEC, '003 DML: '||V_DML||V_MSG_NEW||' Inserido...');
         EXCEPTION
           WHEN OTHERS THEN
                LOG_PACK.INSERE_LOG_DETAIL_ASYNC(V_ID_EXEC, '300 DML: '||V_DML||V_MSG_NEW||' - Erro ao inserir: '||SQLERRM);
         END;
       EXCEPTION
         WHEN OTHERS THEN
              LOG_PACK.INSERE_LOG_DETAIL_ASYNC(V_ID_EXEC, '200 DML: '||V_DML||V_MSG_OLD||' - Erro ao deletar para inserir: '||SQLERRM);
       END;
    ELSIF (V_CONT > 0 AND V_DML = 'U') THEN
       BEGIN
         UPDATE TGRJ_INTE_PENSIONISTAS_AUDIT AD
         set AD.NUMFUNC  = P_ROW_NEW.NUMFUNC,
             AD.NUMVINC  = P_ROW_NEW.NUMVINC,
             AD.NUMERO   = P_ROW_NEW.NUMERO
         where AD.NUMFUNC  = P_ROW_OLD.NUMFUNC
         AND   AD.NUMVINC  = P_ROW_OLD.NUMVINC
         AND   AD.NUMERO   = P_ROW_OLD.NUMERO
         AND   AD.ORIGEM   = VORIGEM
         AND   AD.DTEVENTO = TRUNC(SYSDATE)
         AND   AD.DTENVIO  IS NULL;

         LOG_PACK.INSERE_LOG_DETAIL_ASYNC(V_ID_EXEC, '004 DML: '||V_DML||V_MSG_NEW||' - Atualizado para Inserir...');
       EXCEPTION
         WHEN OTHERS THEN
              LOG_PACK.INSERE_LOG_DETAIL_ASYNC(V_ID_EXEC, '400 DML: '||V_DML||V_MSG_OLD||' - Erro ao atualizar: '||SQLERRM);
       END;
    ELSIF (V_CONT > 0 AND V_DML = 'D') THEN
       BEGIN
         DELETE FROM TGRJ_INTE_PENSIONISTAS_AUDIT AD
         where AD.NUMFUNC  = P_ROW_OLD.NUMFUNC
         AND   AD.NUMVINC  = P_ROW_OLD.NUMVINC
         AND   AD.NUMERO   = P_ROW_OLD.NUMERO
         AND   AD.ORIGEM   = VORIGEM
         AND   AD.DTEVENTO = TRUNC(SYSDATE)
         AND   AD.DTENVIO  IS NULL;
         LOG_PACK.INSERE_LOG_DETAIL_ASYNC(V_ID_EXEC, '005 DML: '||V_DML||V_MSG_OLD||' - Deletado...');
       EXCEPTION
         WHEN OTHERS THEN
              LOG_PACK.INSERE_LOG_DETAIL_ASYNC(V_ID_EXEC, '500 DML: '||V_DML||V_MSG_OLD||' - Erro ao deletar: '||SQLERRM);
       END;
    END IF;
  END;
  end if;
  */
  --


  IF (P_DELETING) THEN
    DELETE FROM TGRJ_DOC_PENSIONISTA
    WHERE NUMFUNC   = P_ROW_NEW.NUMFUNC
    AND   NUMVINC   = P_ROW_NEW.NUMVINC
    AND   NUMPENS   = P_ROW_NEW.NUMERO;
  END IF;


  IF (P_INSERTING OR P_UPDATING ) THEN

     IF  P_ROW_NEW.DT_CERT_FIM IS NOT NULL AND NVL(P_ROW_NEW.DT_CERT_FIM,PACK_HADES.DATA_MAXIMA) <> NVL(P_ROW_OLD.DT_CERT_FIM,PACK_HADES.DATA_MAXIMA) THEN
        UPDATE REGRAS_PENSAO SET DTFIM = (P_ROW_NEW.DT_CERT_FIM-1) , flex_campo_03 = 'Falecimento'
         WHERE NUMFUNC = P_ROW_NEW.NUMFUNC
           AND NUMVINC = P_ROW_NEW.NUMVINC
           AND NUMPENS = P_ROW_NEW.NUMERO;
     END IF;
  END IF;

  RETURN TRUE;

END;
/