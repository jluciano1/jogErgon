prompt ***ATENÇÃO!!!*** Objeto TGRJ_EPB__FUNCIONARIOS não possui replace e deve ser mesclado manualmente com a versão existente no banco.
create FUNCTION TGRJ_EPB__FUNCIONARIOS (
      P_ROW_NEW   IN OUT NOCOPY FUNCIONARIOS%ROWTYPE,
      P_ROW_OLD   IN FUNCIONARIOS%ROWTYPE,
      P_INSERTING IN BOOLEAN,
      P_UPDATING  IN BOOLEAN,
      P_DELETING  IN BOOLEAN,
      P_MENS OUT NOCOPY VARCHAR2 )
    RETURN BOOLEAN
  IS
    --
    v_padaces padusuario.padaces%TYPE;
    v_nome funcionarios.nome%type;
    v_tam_campo  NUMBER;
    v_contador   NUMBER;
    v_achou      NUMBER;
    v_erro_letra NUMBER;
    V_nome_aux funcionarios.nome%type;
    v_nome_a  VARCHAR2(2000);
    v_nome_v  VARCHAR2(2000);
    v_nome_at VARCHAR2(2000);
    v_nome_vt VARCHAR2(2000);
    V_EGE_LIVRE VARCHAR2(1);
    V_PRIVILEG_LIVRE VARCHAR2(1);
    V_PRIVILEG       CHAR(1);
    v_valida_titulo  VARCHAR2(2);
    --
    V_CONTA_LETRA    NUMBER;
    V_PIS_EXIGE      VARCHAR2(1);
    v_count_situacao NUMBER;
    v_caracter       VARCHAR2(1);
    V_RESTO          NUMBER;
    V_CRITICA        NUMBER;
    v_transacao      VARCHAR2(2000);
    --
    v_verifica_campo funcionarios.nome%type;
    v_mail           FUNCIONARIOS.E_MAIL%TYPE; --SGD-1692
    v_existe_certidao number default 0;
    v_count_pensionista number := 0; --SGD 2465    



    PROCEDURE P_ATUALIZA_EMAIL_PORTAL IS

       V_SERVER_HOST VARCHAR2(200);
       V_SERVER_HOST_PRODUCAO VARCHAR2(200); 
       V_SQL         VARCHAR2(2000);
       V_DBLINK      NUMBER := 1;

       v_cod number := 0 ;
       
     BEGIN

       /* Pegar directory de acordo com o servidor */
       select SYS_CONTEXT('USERENV', 'SERVER_HOST')
         into V_SERVER_HOST
         from dual;

       select pack_hades.get_opcao('C_Ergon', 'Geral', 'SERVER_HOST_PROD') into  V_server_host_producao from dual;
       --
       --Atualiza ou insere a base do Portal ADM Servidor
       IF V_SERVER_HOST = V_server_host_producao THEN

         --Verifica se os campos de e-mail foram alterados. Caso alterados verificar se algum outro campo foi alterado.
         --Caso apenas e-mail tenha sido alterado verificar se a conexão com TEGUI está funcionando.
         --Caso não esteja funcionando parar o processo de atualização de e-mail e mostrar mensagem para o usuario.
         --Reinaldo Mesquita 10/04/2014 SGD 1358
         IF NVL(P_ROW_OLD.E_MAIL,'XXXX') <> NVL(P_ROW_NEW.E_MAIL,'XXXX') OR
            NVL(P_ROW_OLD.FLEX_CAMPO_35,'XXXX') <> NVL(P_ROW_NEW.FLEX_CAMPO_35,'XXXX')THEN
           
           IF 
             P_ROW_OLD.NUMERO             = P_ROW_NEW.NUMERO             AND P_ROW_OLD.NOME             = P_ROW_NEW.NOME AND 
             P_ROW_OLD.SEXO               = P_ROW_NEW.SEXO               AND P_ROW_OLD.DTNASC           = P_ROW_NEW.DTNASC AND 
             P_ROW_OLD.CIDNASC            = P_ROW_NEW.CIDNASC            AND P_ROW_OLD.UFNASC           = P_ROW_NEW.UFNASC AND 
             P_ROW_OLD.G_SANGUINEO        = P_ROW_NEW.G_SANGUINEO        AND P_ROW_OLD.PAI              = P_ROW_NEW.PAI AND 
             P_ROW_OLD.MAE                = P_ROW_NEW.MAE                AND P_ROW_OLD.ESTCIVIL         = P_ROW_NEW.ESTCIVIL AND 
             P_ROW_OLD.ESCOLARIDADE       = P_ROW_NEW.ESCOLARIDADE       AND P_ROW_OLD.NACIONALIDADE    = P_ROW_NEW.NACIONALIDADE AND 
             P_ROW_OLD.CHEGBRASIL         = P_ROW_NEW.CHEGBRASIL         AND P_ROW_OLD.UFEMPANT         = P_ROW_NEW.UFEMPANT AND 
             P_ROW_OLD.ANOPRIMEMP         = P_ROW_NEW.ANOPRIMEMP         AND P_ROW_OLD.NUMRG            = P_ROW_NEW.NUMRG AND 
             P_ROW_OLD.TIPORG             = P_ROW_NEW.TIPORG             AND P_ROW_OLD.ORGAORG          = P_ROW_NEW.ORGAORG AND 
             P_ROW_OLD.UFRG               = P_ROW_NEW.UFRG               AND P_ROW_OLD.CPF              = P_ROW_NEW.CPF AND 
             P_ROW_OLD.NUMCARTPRO         = P_ROW_NEW.NUMCARTPRO         AND P_ROW_OLD.SERCARTPRO       = P_ROW_NEW.SERCARTPRO AND 
             P_ROW_OLD.UFCARTPRO          = P_ROW_NEW.UFCARTPRO          AND P_ROW_OLD.NUMTITEL         = P_ROW_NEW.NUMTITEL AND 
             P_ROW_OLD.ZONATITEL          = P_ROW_NEW.ZONATITEL          AND P_ROW_OLD.SECTITEL         = P_ROW_NEW.SECTITEL AND 
             P_ROW_OLD.UFTITEL            = P_ROW_NEW.UFTITEL            AND P_ROW_OLD.NUMDOCMILI       = P_ROW_NEW.NUMDOCMILI AND 
             P_ROW_OLD.SERDOCMILI         = P_ROW_NEW.SERDOCMILI         AND P_ROW_OLD.CATMILI          = P_ROW_NEW.CATMILI AND 
             P_ROW_OLD.CNH                = P_ROW_NEW.CNH                AND P_ROW_OLD.CATCNH           = P_ROW_NEW.CATCNH AND 
             P_ROW_OLD.VALIDCNH           = P_ROW_NEW.VALIDCNH           AND P_ROW_OLD.UFCNH            = P_ROW_NEW.UFCNH AND 
             P_ROW_OLD.PISPASEP           = P_ROW_NEW.PISPASEP           AND P_ROW_OLD.DATAPIS          = P_ROW_NEW.DATAPIS AND 
             P_ROW_OLD.BANCOPIS           = P_ROW_NEW.BANCOPIS           AND P_ROW_OLD.INFORMARBB       = P_ROW_NEW.INFORMARBB AND 
             P_ROW_OLD.IDENTPROF          = P_ROW_NEW.IDENTPROF          AND P_ROW_OLD.TIPOIDPROF       = P_ROW_NEW.TIPOIDPROF AND 
             P_ROW_OLD.TIPOLOGENDER       = P_ROW_NEW.TIPOLOGENDER       AND P_ROW_OLD.NOMELOGENDER     = P_ROW_NEW.NOMELOGENDER AND 
             P_ROW_OLD.NUMENDER           = P_ROW_NEW.NUMENDER           AND P_ROW_OLD.COMPLENDER       = P_ROW_NEW.COMPLENDER AND 
             P_ROW_OLD.BAIRROENDER        = P_ROW_NEW.BAIRROENDER        AND P_ROW_OLD.CIDADEENDER      = P_ROW_NEW.CIDADEENDER AND 
             P_ROW_OLD.UFENDER            = P_ROW_NEW.UFENDER            AND P_ROW_OLD.CEPENDER         = P_ROW_NEW.CEPENDER AND 
             P_ROW_OLD.TELEFONE           = P_ROW_NEW.TELEFONE           AND P_ROW_OLD.BANCO            = P_ROW_NEW.BANCO AND 
             P_ROW_OLD.AGENCIA            = P_ROW_NEW.AGENCIA            AND P_ROW_OLD.CONTA            = P_ROW_NEW.CONTA AND 
             P_ROW_OLD.TIPOPAG            = P_ROW_NEW.TIPOPAG            AND P_ROW_OLD.FOTO             = P_ROW_NEW.FOTO AND 
             P_ROW_OLD.PONTPUBL           = P_ROW_NEW.PONTPUBL           AND P_ROW_OLD.NUM_CERT         = P_ROW_NEW.NUM_CERT AND 
             P_ROW_OLD.LIVRO_A_CERT       = P_ROW_NEW.LIVRO_A_CERT       AND P_ROW_OLD.FOLHA_CERT       = P_ROW_NEW.FOLHA_CERT AND 
             P_ROW_OLD.CARTORIO_CERT      = P_ROW_NEW.CARTORIO_CERT      AND P_ROW_OLD.RAMAL            = P_ROW_NEW.RAMAL AND 
             P_ROW_OLD.TRATAMENTO         = P_ROW_NEW.TRATAMENTO         AND P_ROW_OLD.DT_RECADAST      = P_ROW_NEW.DT_RECADAST AND 
             P_ROW_OLD.NUMTEL_CELULAR     = P_ROW_NEW.NUMTEL_CELULAR     AND 
             P_ROW_OLD.FLEX_CAMPO_01      = P_ROW_NEW.FLEX_CAMPO_01      AND P_ROW_OLD.FLEX_CAMPO_02    = P_ROW_NEW.FLEX_CAMPO_02 AND 
             P_ROW_OLD.FLEX_CAMPO_03      = P_ROW_NEW.FLEX_CAMPO_03      AND P_ROW_OLD.FLEX_CAMPO_04    = P_ROW_NEW.FLEX_CAMPO_04 AND 
             P_ROW_OLD.FLEX_CAMPO_05      = P_ROW_NEW.FLEX_CAMPO_05      AND P_ROW_OLD.FLEX_CAMPO_06    = P_ROW_NEW.FLEX_CAMPO_06 AND 
             P_ROW_OLD.FLEX_CAMPO_07      = P_ROW_NEW.FLEX_CAMPO_07      AND P_ROW_OLD.FLEX_CAMPO_08    = P_ROW_NEW.FLEX_CAMPO_08 AND 
             P_ROW_OLD.FLEX_CAMPO_09      = P_ROW_NEW.FLEX_CAMPO_09      AND P_ROW_OLD.FLEX_CAMPO_10    = P_ROW_NEW.FLEX_CAMPO_10 AND 
             P_ROW_OLD.FLEX_CAMPO_11      = P_ROW_NEW.FLEX_CAMPO_11      AND P_ROW_OLD.FLEX_CAMPO_12    = P_ROW_NEW.FLEX_CAMPO_12 AND 
             P_ROW_OLD.FLEX_CAMPO_13      = P_ROW_NEW.FLEX_CAMPO_13      AND P_ROW_OLD.FLEX_CAMPO_14    = P_ROW_NEW.FLEX_CAMPO_14 AND 
             P_ROW_OLD.FLEX_CAMPO_15      = P_ROW_NEW.FLEX_CAMPO_15      AND P_ROW_OLD.FLEX_CAMPO_16    = P_ROW_NEW.FLEX_CAMPO_16 AND 
             P_ROW_OLD.FLEX_CAMPO_17      = P_ROW_NEW.FLEX_CAMPO_17      AND P_ROW_OLD.FLEX_CAMPO_18    = P_ROW_NEW.FLEX_CAMPO_18 AND 
             P_ROW_OLD.FLEX_CAMPO_19      = P_ROW_NEW.FLEX_CAMPO_19      AND P_ROW_OLD.FLEX_CAMPO_20    = P_ROW_NEW.FLEX_CAMPO_20 AND 
             P_ROW_OLD.FLEX_CAMPO_21      = P_ROW_NEW.FLEX_CAMPO_21      AND P_ROW_OLD.FLEX_CAMPO_22    = P_ROW_NEW.FLEX_CAMPO_22 AND 
             P_ROW_OLD.FLEX_CAMPO_23      = P_ROW_NEW.FLEX_CAMPO_23      AND P_ROW_OLD.FLEX_CAMPO_24    = P_ROW_NEW.FLEX_CAMPO_24 AND 
             P_ROW_OLD.FLEX_CAMPO_25      = P_ROW_NEW.FLEX_CAMPO_25      AND P_ROW_OLD.FLEX_CAMPO_26    = P_ROW_NEW.FLEX_CAMPO_26 AND 
             P_ROW_OLD.FLEX_CAMPO_27      = P_ROW_NEW.FLEX_CAMPO_27      AND P_ROW_OLD.FLEX_CAMPO_28    = P_ROW_NEW.FLEX_CAMPO_28 AND 
             P_ROW_OLD.FLEX_CAMPO_29      = P_ROW_NEW.FLEX_CAMPO_29      AND P_ROW_OLD.FLEX_CAMPO_30    = P_ROW_NEW.FLEX_CAMPO_30 AND 
             P_ROW_OLD.FLEX_CAMPO_31      = P_ROW_NEW.FLEX_CAMPO_31      AND P_ROW_OLD.FLEX_CAMPO_32    = P_ROW_NEW.FLEX_CAMPO_32 AND 
             P_ROW_OLD.FLEX_CAMPO_33      = P_ROW_NEW.FLEX_CAMPO_33      AND P_ROW_OLD.FLEX_CAMPO_34    = P_ROW_NEW.FLEX_CAMPO_34 AND 
             P_ROW_OLD.FLEX_CAMPO_36      = P_ROW_NEW.FLEX_CAMPO_36      AND 
             P_ROW_OLD.FLEX_CAMPO_37      = P_ROW_NEW.FLEX_CAMPO_37      AND P_ROW_OLD.FLEX_CAMPO_38    = P_ROW_NEW.FLEX_CAMPO_38 AND 
             P_ROW_OLD.FLEX_CAMPO_39      = P_ROW_NEW.FLEX_CAMPO_39      AND P_ROW_OLD.FLEX_CAMPO_40    = P_ROW_NEW.FLEX_CAMPO_40 AND 
             P_ROW_OLD.RACA               = P_ROW_NEW.RACA               AND P_ROW_OLD.DEFICIENTE       = P_ROW_NEW.DEFICIENTE AND 
             P_ROW_OLD.FLAG_WEB           = P_ROW_NEW.FLAG_WEB           AND P_ROW_OLD.UF_CART          = P_ROW_NEW.UF_CART AND 
             P_ROW_OLD.MUNICIPIO_CART     = P_ROW_NEW.MUNICIPIO_CART     AND P_ROW_OLD.TIPODOC_CERT     = P_ROW_NEW.TIPODOC_CERT AND 
             P_ROW_OLD.UF_IDENTPROF       = P_ROW_NEW.UF_IDENTPROF       AND P_ROW_OLD.TIPODOC_CERT_FIM = P_ROW_NEW.TIPODOC_CERT_FIM AND 
             P_ROW_OLD.DT_CERT_FIM        = P_ROW_NEW.DT_CERT_FIM        AND P_ROW_OLD.NUM_CERT_FIM     = P_ROW_NEW.NUM_CERT_FIM AND 
             P_ROW_OLD.LIVRO_CERT_FIM     = P_ROW_NEW.LIVRO_CERT_FIM     AND P_ROW_OLD.FOLHA_CERT_FIM   = P_ROW_NEW.FOLHA_CERT_FIM AND 
             P_ROW_OLD.CARTORIO_CERT_FIM  = P_ROW_NEW.CARTORIO_CERT_FIM  AND P_ROW_OLD.UF_CART_FIM      = P_ROW_NEW.UF_CART_FIM AND 
             P_ROW_OLD.MUNICIPIO_CART_FIM = P_ROW_NEW.MUNICIPIO_CART_FIM AND P_ROW_OLD.EXPEDRG          = P_ROW_NEW.EXPEDRG AND 
             P_ROW_OLD.ORGAOMILI          = P_ROW_NEW.ORGAOMILI          AND P_ROW_OLD.UFDOCMILI        = P_ROW_NEW.UFDOCMILI AND 
             P_ROW_OLD.TIPODEFIC          = P_ROW_NEW.TIPODEFIC          AND P_ROW_OLD.FLEX_CAMPO_41    = P_ROW_NEW.FLEX_CAMPO_41 AND 
             P_ROW_OLD.FLEX_CAMPO_42      = P_ROW_NEW.FLEX_CAMPO_42      AND P_ROW_OLD.FLEX_CAMPO_43    = P_ROW_NEW.FLEX_CAMPO_43 AND 
             P_ROW_OLD.FLEX_CAMPO_44      = P_ROW_NEW.FLEX_CAMPO_44      AND P_ROW_OLD.FLEX_CAMPO_45    = P_ROW_NEW.FLEX_CAMPO_45 AND 
             P_ROW_OLD.GERA_PASEP         = P_ROW_NEW.GERA_PASEP         AND P_ROW_OLD.FLEX_CAMPO_46    = P_ROW_NEW.FLEX_CAMPO_46 AND 
             P_ROW_OLD.FLEX_CAMPO_47      = P_ROW_NEW.FLEX_CAMPO_47      AND P_ROW_OLD.FLEX_CAMPO_48    = P_ROW_NEW.FLEX_CAMPO_48 AND 
             P_ROW_OLD.FLEX_CAMPO_49      = P_ROW_NEW.FLEX_CAMPO_49      AND P_ROW_OLD.FLEX_CAMPO_50    = P_ROW_NEW.FLEX_CAMPO_50 AND 
             P_ROW_OLD.ID_REG             = P_ROW_NEW.ID_REG             AND P_ROW_OLD.MATRICULA_CERT   = P_ROW_NEW.MATRICULA_CERT AND 
             P_ROW_OLD.MATRICULA_CERT_FIM = P_ROW_NEW.MATRICULA_CERT_FIM AND P_ROW_OLD.US               = P_ROW_NEW.US
           THEN
                    
             BEGIN
                /*
                SELECT 1 INTO V_DBLINK FROM DUAL@DBL_PORTAL_ADM;
                */
                SELECT 1 INTO V_DBLINK FROM DUAL@DBL_PORTAL_ADM;
             EXCEPTION
               WHEN OTHERS THEN
                 V_DBLINK := 0;
                 P_MENS :=('Não foi possível atualizar o campo e-mail, tente novamente após alguns instantes.');
             END;
                    
           ELSE
             V_DBLINK := 1;
           END IF; 
        
          IF P_ROW_NEW.E_MAIL IS NOT NULL THEN

                IF NVL(P_ROW_OLD.E_MAIL,'XXXX') <> NVL(P_ROW_NEW.E_MAIL,'XXXX') THEN

                   IF P_ROW_NEW.E_MAIL IS NOT NULL THEN
                      --begin
                          IF NOT PGOV_VALIDA_EMAIL(P_ROW_NEW.E_MAIL) THEN
                             P_MENS :=('Formatação do Email incorreto, favor verificar.');
                          END IF;
                      --exception
                      --   when others then
                      --         p_mens := 'Erro ao validar email...';
                      --end ;
                   END IF;

                    IF V_DBLINK = 1 THEN
                    
                      BEGIN
                        
                        V_SQL := 'UPDATE funcionario@DBL_PORTAL_ADM FU
                                     SET EMAIL     ='''|| P_ROW_NEW.E_MAIL||''',
                                      WHERE IDFUNC = SUBSTR('||P_ROW_NEW.NUMERO||',1, LENGTH('||P_ROW_NEW.NUMERO||') - 1)';


                       pack_hades.EXECUTA_SQL(V_SQL);
                      
                       EXCEPTION

                         WHEN OTHERS THEN
                           P_MENS :=('Erro atualizar o Email no portal ADM... '||sqlerrm(sqlcode));
                      END;
                    END IF;
                END IF;

           ELSE

                IF NVL(P_ROW_OLD.FLEX_CAMPO_35,'XXXX') <> NVL(P_ROW_NEW.FLEX_CAMPO_35,'XXXX') THEN

                  IF P_ROW_NEW.FLEX_CAMPO_35 IS NOT NULL THEN

                    IF NOT PGOV_VALIDA_EMAIL(P_ROW_NEW.FLEX_CAMPO_35) THEN
                     P_MENS := ('Formatação do Email incorreto, favor verificar.');

                    END IF;

                  END IF;

                   IF V_DBLINK = 1 THEN
                  
                     BEGIN

                        V_SQL := 'UPDATE funcionario@DBL_PORTAL_ADM FU
                                     SET EMAIL     ='''|| P_ROW_NEW.FLEX_CAMPO_35||'''
                                      WHERE IDFUNC = SUBSTR('||P_ROW_NEW.NUMERO||',1, LENGTH('||P_ROW_NEW.NUMERO||') - 1)';



                        pack_hades.EXECUTA_SQL(V_SQL);

                     EXCEPTION
                         WHEN OTHERS THEN
                           P_MENS := ('Problema ao atualizar o Email no portal ADM.....'||sqlerrm(sqlcode));

                     END;
                   END IF;
                END IF;
              END IF;
           END IF;
           
           --SGD-1692 Início 
           IF (p_updating) THEN
               V_SQL := 'UPDATE funcionario@DBL_PORTAL_ADM FU SET';
               IF v_mail IS NOT NULL THEN
                  V_SQL := V_SQL || ' EMAIL  ='''|| v_mail ||''',';         
               ELSIF v_mail IS NULL OR v_mail = '' THEN 
                     V_SQL := V_SQL || ' EMAIL  = NULL, ';
               END IF;
            
               V_SQL := V_SQL || 'DT_NASCIMENTO ='''|| P_ROW_NEW.DTNASC ||''','|| 
                                 '     NOME  ='''|| P_ROW_NEW.NOME   ||''','||
                                 '  NOME_MAE ='''|| P_ROW_NEW.MAE    ||''','||
                                 '      CPF  ='|| P_ROW_NEW.CPF    ||','||
                                 ' DT_UPDATE  ='''|| SYSDATE || 
                                 ''' WHERE IDFUNC = SUBSTR('||P_ROW_NEW.NUMERO||',1, LENGTH('||P_ROW_NEW.NUMERO||') - 1)';      
               begin
                   pack_hades.EXECUTA_SQL(V_SQL); --Bernardo 09/12/2014
               exception
                    WHEN OTHERS THEN
                         P_MENS := ('Problema ao atualizar o E_mail no portal ADM.....'||sqlerrm(sqlcode));
               end;
                 
             
           END IF;
           --SGD-1692 Fim
           
       END IF;

     EXCEPTION
         WHEN OTHERS THEN
              P_MENS := ('Erro na gravação do Portal.'||sqlerrm(sqlcode));
     END;
   
   
   --PRAGMA AUTONOMOUS_TRANSACTION;
  
  
  ---- INICIO DA EPB ---
  
  BEGIN
  
   
    IF(P_UPDATING OR P_INSERTING) AND ('Instituidor de Pensão' = flag_pack.get_transacao) THEN
    
      begin
        
        if 'SIM' = pack_hades.get_opcao ('C_Ergon', 'PENS_PREV', 'DUPLICIDADE_CERTIDAO_OBITO') then

          select count(1)
          into v_existe_certidao
          from funcionarios f
          where f.numero <> p_row_new.numero
          and f.matricula_cert_fim = p_row_new.matricula_cert_fim;
          
          if v_existe_certidao > 0 then
            p_mens := 'Atenção! Já existe número de matrícula de certidão cadastrado no sistema. '||nvl(p_row_new.numero, p_row_old.numero)||' - '||nvl(p_row_new.matricula_cert_fim, p_row_old.matricula_cert_fim);
          end if;
        
        end if;
        
        if 'SIM' = pack_hades.get_opcao ('C_Ergon', 'PENS_PREV', 'VALIDADE_CERTIDAO_OBITO') then
          p_mens := tgrj_valida_certidao_obito(p_row_new.matricula_cert_fim);          
        end if;
        
      end;
      
    end if;
  
  
    BEGIN
      SELECT 'S'
      INTO v_padaces
      FROM padusuario
      WHERE USUARIO = FLAG_PACK.GET_USUARIO
      AND PADACES   = 'ALT_NOME_CPF'
      AND ROWNUM    = 1;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        V_PADACES := 'N';
    END;

    BEGIN
      SELECT 'S'
      INTO V_EGE_LIVRE
      FROM padusuario
      WHERE USUARIO = FLAG_PACK.GET_USUARIO
      AND PADACES   = 'EGE_LIVRE'
      AND ROWNUM    = 1;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        V_EGE_LIVRE := 'N';
    END;

    BEGIN
      SELECT 'S'
      INTO V_PRIVILEG_LIVRE
      FROM padusuario
      WHERE USUARIO = FLAG_PACK.GET_USUARIO
      AND PADACES   = 'PRIVILEG_LIVRE'
      AND ROWNUM    = 1;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        V_PRIVILEG_LIVRE := 'N';
    END;
    --
    BEGIN
      SELECT nvl(privil,'N')
      INTO V_PRIVILEG
      FROM usuario
      WHERE USUARIO = FLAG_PACK.GET_USUARIO;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        V_PRIVILEG := 'N';
    END;

    --alteracao emergencial a pedido de egidio.
    select flag_pack.get_transacao into v_transacao from dual;
    --
    
    --SGD 2465  -- Feito por Ismael -- 01/12/2015
    IF v_transacao not in ('Dados Gerais MS605', 'RJadm00067', 'Vacância') THEN -- LUANA
    if p_inserting or p_updating then

      begin
        select count(1)
          into v_count_pensionista
          from pensionistas 
         where flex_campo_04 = P_ROW_new.Numero;
      exception when others then
        v_count_pensionista := 0;
      end;     

     if V_PRIVILEG_LIVRE = 'N' then  
       if v_transacao <> 'Pensionistas' then --SGD 2938 em 02/08/2016
        if P_ROW_NEW.Cidnasc is null then
          p_mens := 'Informe o campo "Naturalidade".';
          return(true);
        end if;	

        IF P_ROW_NEW.Nacionalidade = 20 and P_ROW_NEW.Ufnasc is not null THEN
          p_mens := 'Campo "UF" não deve ser preenchido para "Nacionalidade" = Naturalizado.';
          return(true);
        ELSIF P_ROW_NEW.Nacionalidade = 10 and P_ROW_NEW.Ufnasc is null THEN	
          p_mens := 'Campo "UF" deve ser preenchido para "Nacionalidade" = Brasileira.';
          return(true);	
        END IF;
        
       end if;-- fim SGD 2938 em 02/08/2016 
     end if;
    end if;  
  END IF;  
    --SGD 2465     

    if v_transacao not in ('TGRJ_INTERFACE_ALTERACOES_FUNC', 'Dados Gerais MS605', 'RJadm00067') then
      --Modificado por Rodrigo Machado em 15/05/2015.
      --Não validar quando for diferente de 10 - Brasileira
      --e 20 - naturalizada.
      --if  p_row_new.nacionalidade IN (10,20) THEN
         -- Opção generica desabilitada, pois interferia na tela de Pensionista Previdenciario.
         -- Reinaldo Mesquita, SGD(2085), 01/07/2015
         --v_valida_titulo := PACK_HADES.GET_OPCAO ('Ergon', 'GERAL', 'VALIDA_TITULO_ELEITOR');
         --v_valida_titulo := 'S';
      --else
         --v_valida_titulo := 'N';      
      --end if;
        /*-----------------------------------------------------------------------------------------------------
          Comentado a parte de cima, pois o que irá prevalecer será a alteração abaixo.
          Quando for (10) Brasileira e (20) Naturalizado validar titulo. 
          Quando for diferente de (10) Brasileira e (20) Naturalizado informar mensagem. 
          Regra definida por Solange Morais. Luana 29/09/2015. SGD 2355.
        -------------------------------------------------------------------------------------------------------*/ 
        if p_row_new.nacionalidade IN (10,20) then
           v_valida_titulo := 'S'; 
        elsif p_row_new.nacionalidade NOT IN (10,20) then
          if V_PRIVILEG_LIVRE = 'N' then --SGD 2465
            if v_count_pensionista < 1 then --SGD 2465   
              p_mens := 'Problema com a Nacionalidade - Entre em contato com a SEPLAG/SUSIG e informe o tipo de vínculo a ser ingressado.';
              return(true);
            end if;         
          end if;  
        end if;        
    else
       v_valida_titulo := 'N';
    end if;
    
    --
    -- Titulo de Eleitor não deve ser validado para Instituidores de Pensão e Pensionista Previdenciário
    -- Verificado com a usuária Rosangela que Titulo de Eleitor não deve ser validado para Dados Gerais MS605 (e a página do Ergon NG: RJadm00067). LUANA 27/08/2015. SGD 1543.
    --
    IF V_TRANSACAO IN ('Instituidor de Pensão', 'Pensionista Previdenciário', 'Dados Gerais MS605', 'RJadm00067',
       'Pensionistas') THEN -- Incluído por Giselle da Silva em 28/12/2015 / SGD 2548
       V_VALIDA_TITULO := 'N';
    END IF;
    --
  
    -- Ricardo Nunes - +2x - 07/10/2014
    -- SGD 1639 - Verifica se os campos nome , nome do pai e nome da mae possuem
    -- caracteres especiais, possuem somente letras ou possuem mais de 1 espaço em branco entre as palavras
    IF (P_UPDATING) OR (P_INSERTING) THEN 
           --        
           v_verifica_campo := pgov_verifica_somente_letras(p_row_new.nome);
           --
           --p_mens := 'novo: '||p_row_new.nome||' old: '||p_row_old.nome;
           --return(true);
        
           if v_verifica_campo is not null then
              p_mens := 'Problema no campo NOME - '||v_verifica_campo;
              return(true);
           end if;
           -- 
           v_verifica_campo := pgov_verifica_somente_letras(p_row_new.pai);
           --
           if v_verifica_campo is not null then
              p_mens := 'Problema no campo nome do PAI - '||v_verifica_campo;
              return(true);
           end if;
           -- 
           v_verifica_campo := pgov_verifica_somente_letras(p_row_new.mae);
           --
           if v_verifica_campo is not null then
              p_mens := 'Problema no campo nome da MÃE - '||v_verifica_campo;
              return(true);
           end if;
           --         
        
    END IF;
    
    -- Ricardo Nunes - 15/02/2017
    -- TRELLO Cartao 536 - Somente usuario  privilegiado podera incluir ou alterar os campos
    -- NOME SOCIAL e NUMERO DO PROCESSO da aba DADOS GERAIS
    IF (P_UPDATING) OR (P_INSERTING) and V_TRANSACAO = 'Funcionários' THEN 
           --        
           --
           if ((p_row_old.flex_campo_03 <> p_row_new.flex_campo_03) or
               (p_row_old.flex_campo_03 is null and p_row_new.flex_campo_03 is not null) or
               (p_row_old.flex_campo_03 is not null and p_row_new.flex_campo_03 is null)) and V_PRIVILEG = 'N'  then
              p_mens := 'Usuário não possui permissão para inserir ou alterar o campo NUMERO DO PROCESSO';
              return(true);
           end if;
           --    
           --
           if ((p_row_old.flex_campo_04 <> p_row_new.flex_campo_04) or
               (p_row_old.flex_campo_04 is null and p_row_new.flex_campo_04 is not null) or
               (p_row_old.flex_campo_04 is not null and p_row_new.flex_campo_04 is null)) and V_PRIVILEG = 'N'  then
              p_mens := 'Usuário não possui permissão para inserir ou alterar o campo NOME SOCIAL';
              return(true);
           end if;
           --         
        
    END IF;  
    --
    -- Retorna o nome do Funcionario, Pai e M?e em maiusculo
    -- Dagoberto (Techne) - 15/10/2009
    --
    p_row_new.nome := formata_nome_maiusc(p_row_new.nome);
    p_row_new.pai  := formata_nome_maiusc(p_row_new.pai);
    p_row_new.mae  := formata_nome_maiusc(p_row_new.mae);

    --foi alterado o parametro PIS_OBRIG para 'N' e retirado o tratamento pelo produto e sim customizavel.
    --Feito por: Bruno, solicitado pela vera, SGD: 939
    IF (P_UPDATING) OR (P_INSERTING) THEN
      IF V_PRIVILEG_LIVRE = 'N' AND V_EGE_LIVRE = 'N' THEN

        IF (p_row_new.numtitel IS NULL OR p_row_new.ZONATITEL is null
         OR p_row_new.SECTITEL is null OR p_row_new.uftitel is null ) THEN
           IF v_valida_titulo = 'S' THEN
              IF P_ROW_NEW.FLEX_CAMPO_21 IS NULL THEN 
                P_MENS := 'Preencher os dados referente ao Título Eleitor corretamente.';
                RETURN (TRUE);
              END IF;
           ELSE 
             RETURN (TRUE);
           END IF;
        END IF;

        --Não será obrigatório informar PIS para também as transações ('Dados Gerais MS605', 'RJadm00067', 'Pensionista Previdenciário', 'Pensionistas'). 
        --Verificado com o Gerente Egidio. Luana 29/09/2015. 
        --if v_transacao not in ('TGRJ_INTERFACE_ALTERACOES_FUNC','Instituidor de Pensão') then
        if v_transacao not in ('TGRJ_INTERFACE_ALTERACOES_FUNC','Instituidor de Pensão', 'Dados Gerais MS605', 'RJadm00067', 'Pensionista Previdenciário', 'Pensionistas') then
          IF P_ROW_NEW.PISPASEP IS NULL THEN
            IF P_ROW_NEW.FLEX_CAMPO_21 IS NULL THEN
              P_MENS := 'Informe o PIS.';
              RETURN (TRUE);
            END IF;
              
          -- PROIBIR o cadastramento do número do NIT no campo do PIS.
          -- Inserido na EPB por não estar funcionando a opção genérica PIS_PERMITE_NIT = N
          -- Reinaldo Mesquita, SGD 2017, dia 09/06/2015  
          ELSIF P_ROW_NEW.PISPASEP <> P_ROW_OLD.PISPASEP THEN
            IF P_ROW_NEW.FLEX_CAMPO_21 IS NULL THEN
              IF (P_ROW_NEW.PISPASEP BETWEEN 10900000000 AND 11999999999)
              OR (P_ROW_NEW.PISPASEP BETWEEN 16700000000 AND 16899999999)
              OR (P_ROW_NEW.PISPASEP BETWEEN 26700000000 AND 26799999999) THEN
                P_MENS := 'O valor informado no campo PIS corresponde a um NIT. Não é permitido inserir um NIT no campo PIS.';
                RETURN (TRUE);
              END IF;
            END IF;            
          END IF;
        end if;
        
      END IF;
    END IF;
    
    --foi alterado o parametro PIS_OBRIG para 'N' e retirado o tratamento pelo produto e sim customizavel.
    --Feito por: Bruno, solicitado pela vera, SGD: 939
    IF (P_UPDATING) OR (P_INSERTING) THEN
       /*----------------------------------------------------------------------------------
         Foi verificado com a usuária Rosangela que no cadastro de Funcionários não será 
         obrigatório o número do CPF para o MS605. LUANA 28/07/2015 - SGD 1543.
        ------------------------------------------------------------------------------------*/
       IF (v_transacao NOT IN ('Dados Gerais MS605', 'RJadm00067'))THEN
          IF V_PRIVILEG_LIVRE = 'N' THEN
             IF V_TRANSACAO NOT IN ('Instituidor de Pensão') THEN
                IF p_row_new.cpf IS NULL THEN
                  
                   P_MENS := 'Informe o CPF.';
                   RETURN (TRUE);

                END IF;
             END IF;
          END IF;
          
       END IF;
    END IF;    
    
       
    /*IF P_ROW_NEW.E_MAIL IS NOT NULL THEN
       v_mail := P_ROW_NEW.E_MAIL;
    ELSIF P_ROW_NEW.FLEX_CAMPO_35 IS NOT NULL THEN
          v_mail := P_ROW_NEW.FLEX_CAMPO_35;
    ELSIF (P_ROW_NEW.E_MAIL IS NULL AND P_ROW_NEW.FLEX_CAMPO_35 IS NULL) THEN
           v_mail := NULL;   
    END IF;       */
     
    ---- ATUALIZA O E_MAIL NO PORTAL QUANDO DA INSERCAO DE NOVO FUNCINOARIO -----
    
     --Feito por Ismael Silva em 05/02/2015 sob o SGD 1857
     --Mudança feita para que seja feita a inserção dos dados do funcionário no TEGUI, pois só estava sendo feita
     --a inserção no TEGUI se estivesse sendo realizado um update.        
     /*
     IF p_inserting THEN
     
           DECLARE

             V_SERVER_HOST VARCHAR2(200);
             V_SERVER_HOST_PRODUCAO VARCHAR2(200); 
             V_SQL_I         VARCHAR2(2000);
             

           BEGIN

              --Pegar directory de acordo com o servidor 
             select SYS_CONTEXT('USERENV', 'SERVER_HOST')
               into V_SERVER_HOST
               from dual;

             select pack_hades.get_opcao('C_Ergon', 'Geral', 'SERVER_HOST_PROD') into  V_server_host_producao from dual;
             --
             --insere a base do Portal ADM Servidor
             IF V_SERVER_HOST = V_server_host_producao THEN
                 
             V_SQL_I := 'INSERT INTO funcionario@DBL_PORTAL_ADM FU
                       (IDFUNC,
                        DT_NASCIMENTO,
                        NOME, 
                        NOME_MAE, 
                        CPF, 
                        EMAIL, 
                        DT_INSERT) 
                        VALUES '||'(SUBSTR('||P_ROW_NEW.NUMERO||',1, LENGTH('||P_ROW_NEW.NUMERO||') - 1)' ||','''
                                || P_ROW_NEW.DTNASC ||''','''
                                || P_ROW_NEW.NOME   ||''','''
                                || P_ROW_NEW.MAE    ||''','
                                || P_ROW_NEW.CPF    ||','''
                                || v_mail           ||''','''
                                || SYSDATE ||''')';
                                 
                             
               pack_hades.EXECUTA_SQL(V_SQL_I);
                 
               END IF;
           END;
     END IF;*/

    --
    IF (P_UPDATING) THEN --OR (P_INSERTING) THEN

      -- Impede que o CPF seja alterado por perfis diferentes de ALTERA_NOME_CPF
      -- Dagoberto - 31/07/2012
      -- Solicitação: 75583
      IF V_PRIVILEG_LIVRE = 'N' THEN
        IF NVL(P_ROW_NEW.cpf,0) <> NVL(P_ROW_OLD.cpf,0) THEN
          IF v_padaces    = 'S' THEN
            P_MENS       := NULL;
          ELSE
            P_MENS := 'CPF não pode ser alterado.';
            RETURN (TRUE);
          END IF;
        END IF;
      END IF;
    
      --
      --As Condições abaixo verificarão erros de letras e alterações no nome.
      IF P_MENS IS NULL THEN
        -- Regras de validação dos nomes
        v_nome_aux := RTRIM(UPPER(P_ROW_NEW.NOME));
        SELECT LENGTH(v_nome_aux) INTO V_TAM_CAMPO FROM DUAL;
        V_CONTADOR := 0;
        --*******************************************************************************
        --Rotina abaixo foi criada mediante portaria seplag/subre Nº044 15/03/2010.     *
        --Validação do nome do servidor.                                                *
        --*******************************************************************************
        WHILE V_TAM_CAMPO > V_CONTADOR
        LOOP
          V_CONTADOR                      := V_CONTADOR + 1;
          IF ASCII(SUBSTR(v_nome_aux,1,1)) = 32 THEN --Neste momento se verifica a primeira posicao do nome com espaço em branco.
            P_MENS                        := 'Nome contém espaço em branco na primeira posição!';
          ELSIF (ASCII(SUBSTR(v_nome_aux,V_CONTADOR,1))) BETWEEN 48 AND 57 THEN --Neste momento se identifica NUMEROS NO NOME.
            P_MENS                                                                                                         := 'Nome contém numeros!';
          ELSIF (ASCII(SUBSTR(v_nome_aux,V_CONTADOR,1)) NOT BETWEEN 65 AND 90) AND (ASCII(SUBSTR(v_nome_aux,V_CONTADOR,1)) <> 32) THEN--Neste momento se identifica o espaço em branco no nome.
            P_MENS                                                                                                         := 'Existe caracter especial no nome!';
          ELSIF ASCII(SUBSTR(v_nome_aux,V_CONTADOR,1))                                                                      = 32 THEN
            IF ASCII(SUBSTR(v_nome_aux,V_CONTADOR+1,1))                                                                     = 32 THEN--Neste momento se verifica se o proximo caracter é espaço em branco.
              p_mens                                                                                                       := 'Existe mais de um espaço em branco no nome do servidor!';
            END IF;
          END IF;
        END LOOP;
        IF P_MENS IS NULL THEN
          IF ASCII(P_ROW_NEW.NOME) BETWEEN 65 AND 90 THEN -- Checa se pelo menos existe uma letra informada no nome novo.
            V_CONTADOR   := 1;
            v_erro_letra := 0;
            V_CRITICA    := 0;
            --
            --Retirando as preposiçoes POIS AS MESMAS NÃO FAZEM PARTE DO CONTROLE DE INCLUSAO OU EXCLUSAO DAS LETRAS NO NOME.
            v_nome_a := '#'||REPLACE(RTRIM(LTRIM(UPPER(P_ROW_NEW.NOME))),' ', '#')||'#'; --nome atual
            v_nome_a := REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(v_nome_a, '#DAS#', '#'), '#DOS#', '#'),'#DA#', '#'),'#DO#' , '#'),'#DE#','#'),'#D#', '#'),'#DI#','#'),'#E#','#');
            v_nome_a := REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(v_nome_a, '#Q#' , '#'), '#W#' , '#'),'#E#' , '#'),'#R#' , '#'),'#T#' ,'#'),'#Y#', '#'),'#U#' ,'#'),'#I#','#');
            v_nome_a := REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(v_nome_a, '#O#' , '#'), '#P#' , '#'),'#A#' , '#'),'#S#' , '#'),'#D#' ,'#'),'#F#', '#'),'#G#' ,'#'),'#H#','#');
            v_nome_a := REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(v_nome_a, '#J#' , '#'), '#K#' , '#'),'#L#' , '#'),'#Z#' , '#'),'#X#' ,'#'),'#C#', '#'),'#V#' ,'#'),'#B#','#');
            v_nome_a := REPLACE(REPLACE(v_nome_a, '#N#', '#'), '#M#', '#');
            --
            v_nome_v := '#'||REPLACE(RTRIM(LTRIM(UPPER(P_ROW_OLD.NOME))),' ', '#')||'#'; --nome velho
            v_nome_v := REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(v_nome_v, '#DAS#', '#'), '#DOS#', '#'),'#DA#', '#'),'#DO#', '#'),'#DE#','#'),'#D#', '#'),'#DI#','#'),'#E#','#');
            v_nome_v := REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(v_nome_v, '#Q#' , '#'), '#W#' , '#'),'#E#' , '#'),'#R#' , '#'),'#T#' ,'#'),'#Y#', '#'),'#U#' ,'#'),'#I#','#');
            v_nome_v := REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(v_nome_v, '#O#' , '#'), '#P#' , '#'),'#A#' , '#'),'#S#' , '#'),'#D#' ,'#'),'#F#', '#'),'#G#' ,'#'),'#H#','#');
            v_nome_v := REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(v_nome_v, '#J#' , '#'), '#K#' , '#'),'#L#' , '#'),'#Z#' , '#'),'#X#' ,'#'),'#C#', '#'),'#V#' ,'#'),'#B#','#');
            v_nome_v := REPLACE(REPLACE(v_nome_v, '#N#', '#'), '#M#', '#');
            --
            --Verificação das alterações das letras do nome.
            WHILE INSTR(v_nome_a, '#', 1,V_CONTADOR) > 0
            LOOP
              IF INSTR(v_nome_a, '#', 1,V_CONTADOR+1) = 0 THEN--Caso não haja mais LETRA para formar aborta-se o loop.
                EXIT;
              ELSE
                --Neste momento separa-se o nome em trechos para serem validados separadamente.
                v_nome_at := SUBSTR(v_nome_a, instr(v_nome_a, '#', 1,v_contador)+1,(instr(v_nome_a, '#', 1,v_contador+1)-instr(v_nome_a, '#', 1,v_contador))-1);
                v_nome_vt := SUBSTR(v_nome_v, instr(v_nome_v, '#', 1,v_contador)+1,(instr(v_nome_v, '#', 1,v_contador+1)-instr(v_nome_v, '#', 1,v_contador))-1);
              END IF;
              --*****************************************************************************
              --Verifica conteudo da primeira palavra do nome.                              *
              --*****************************************************************************
              IF V_CONTADOR           = 1 THEN
                IF LENGTH(v_nome_vt) <= 5 THEN
                  --Regra de primeira palavra. Palavra com ate 5 letras.
                  V_CONTA_LETRA := 0;
                  v_erro_letra  := 0;
                  V_CRITICA     := 0;
                  v_RESTO       := ABS(LENGTH(v_nome_at) - LENGTH(v_nome_vt));
                  -- Necessario este valor pois quando a palavra sofre acrescimo ou reducao devemos saber
                  -- quanto aumentou ou diminui para somas as possiveis letras com erro na expressao.
                  --No loop abaixo se verifica se alguma palavra sofreu modificação em relação a origem.
                  WHILE LENGTH(v_nome_vt) > V_CONTA_LETRA
                  LOOP
                    V_CONTA_LETRA                          := V_CONTA_LETRA +1;
                    IF SUBSTR(v_nome_at, V_CONTA_LETRA, 1) <> SUBSTR(v_nome_vt, V_CONTA_LETRA, 1) THEN
                      v_erro_letra                         := v_erro_letra + 1;
                    END IF;
                  END LOOP;
                  --Erros de letras serão somadas ao resto pois pode haver reducao ou acrescimo na primeira palavra.
                  IF V_ERRO_LETRA < v_RESTO THEN
                    v_erro_letra := v_RESTO+V_ERRO_LETRA;
                  END IF;
                  --Caso a palavra de primeiro nome tenha mais de 1 alteração deve proibir a alteração.
                  IF V_ERRO_LETRA > 1 THEN
                    P_MENS       := 'Primeira palavra do nome sofreu mais de 1 alteração. Verifique: '||'['||v_nome_at||']'||' ['||v_nome_vt||']';
                    V_CRITICA    := 1;
                    EXIT;
                  END IF;
                ELSIF LENGTH(v_nome_vt) > 5 THEN
                  --Regra de primeira palavra. Palavra com + 5 letras.
                  V_CONTA_LETRA := 0;
                  v_erro_letra  := 0;
                  V_CRITICA     := 0;
                  v_RESTO       := ABS(LENGTH(v_nome_at) - LENGTH(v_nome_vt));
                  --
                  WHILE LENGTH(v_nome_vt) > V_CONTA_LETRA
                  LOOP
                    V_CONTA_LETRA                          := V_CONTA_LETRA +1;
                    IF SUBSTR(v_nome_at, V_CONTA_LETRA, 1) <> SUBSTR(v_nome_vt, V_CONTA_LETRA, 1) THEN
                      v_erro_letra                         := v_erro_letra + 1;
                    END IF;
                  END LOOP;
                  --Erros de letras serão somadas ao resto pois pode haver reducao ou acrescimo na primeira palavra.
                  IF V_ERRO_LETRA < v_RESTO THEN
                    v_erro_letra := v_RESTO+V_ERRO_LETRA;--Ocorre a soma quando um dos nomes variou em tamanho e deve-se somar a variacao aos erros encontrados na expressao.
                  END IF;
                  IF V_ERRO_LETRA > 2 THEN
                    P_MENS       := 'Primeira palavra do nome sofreu mais de 2 alterações. Verifique: '||'['||v_nome_at||']'||' ['||v_nome_vt||']';
                    V_CRITICA    := 1;
                    EXIT;
                  END IF;
                END IF;
              ELSE
                --******************************************************************************
                --REGRA DE VALIDAÇÃO DAS OUTRAS PALAVRAS DO NOME EXCETO PRIMEIRA PALAVRA.      *
                --******************************************************************************
                IF P_ROW_NEW.SEXO       = 'M' THEN
                  IF LENGTH(v_nome_vt) <= 5 THEN
                    --Regra de primeira palavra. Palavra com ate 5 letras.
                    V_CONTA_LETRA := 0;
                    v_erro_letra  := 0;
                    V_CRITICA     := 0;
                    v_RESTO       := ABS(LENGTH(v_nome_at) - LENGTH(v_nome_vt));
                    -- Necessario este valor pois quando a palavra sofre acrescimo ou reducao devemos saber
                    -- quanto aumentou ou diminui para somar as possiveis letras com erro na expressao.
                    --No loop abaixo se verifica se alguma palavra sofreu modificação em relação a origem.
                    WHILE LENGTH(v_nome_vt) > V_CONTA_LETRA
                    LOOP
                      V_CONTA_LETRA                          := V_CONTA_LETRA +1;
                      IF SUBSTR(v_nome_at, V_CONTA_LETRA, 1) <> SUBSTR(v_nome_vt, V_CONTA_LETRA, 1) THEN
                        v_erro_letra                         := v_erro_letra + 1;
                      END IF;
                    END LOOP;
                    --Erros de letras serão somadas ao resto pois pode haver reducao ou acrescimo na primeira palavra.
                    IF V_ERRO_LETRA < v_RESTO THEN
                      v_erro_letra := v_RESTO+V_ERRO_LETRA;
                    END IF;
                    --Caso a palavra de primeiro nome tenha mais de 1 alteração deve proibir a alteração.
                    IF V_ERRO_LETRA > 1 THEN
                      P_MENS       := 'Palavra do nome sofreu mais de 1 alteração. Verifique: '||'['||v_nome_at||']'||' ['||v_nome_vt||']';
                      V_CRITICA    := 1;
                      EXIT;
                    END IF;
                  ELSIF LENGTH(v_nome_vt) > 5 THEN
                    --Regra de primeira palavra. Palavra com + 5 letras.
                    V_CONTA_LETRA := 0;
                    v_erro_letra  := 0;
                    V_CRITICA     := 0;
                    v_RESTO       := ABS(LENGTH(v_nome_at) - LENGTH(v_nome_vt));
                    --
                    WHILE LENGTH(v_nome_vt) > V_CONTA_LETRA
                    LOOP
                      V_CONTA_LETRA                          := V_CONTA_LETRA +1;
                      IF SUBSTR(v_nome_at, V_CONTA_LETRA, 1) <> SUBSTR(v_nome_vt, V_CONTA_LETRA, 1) THEN
                        v_erro_letra                         := v_erro_letra + 1;
                      END IF;
                    END LOOP;
                    --Erros de letras serão somadas ao resto pois pode haver reducao ou acrescimo na primeira palavra.
                    IF V_ERRO_LETRA < v_RESTO THEN
                      v_erro_letra := v_RESTO+V_ERRO_LETRA;--Ocorre a soma quando um dos nomes variou em tamanho e deve-se soma a variacao aos erros encontrados na expressao.
                    END IF;
                    IF V_ERRO_LETRA > 2 THEN
                      P_MENS       := 'Palavra do nome sofreu mais de 2 alterações. Verifique: '||'['||v_nome_at||']'||' ['||v_nome_vt||']';
                      V_CRITICA    := 1;
                      EXIT;
                    END IF;
                  END IF;
                END IF;
              END IF;
              V_CONTADOR := V_CONTADOR + 1;
            END LOOP;
            IF (INSTR((SUBSTR(P_ROW_NEW.NOME,LENGTH(P_ROW_NEW.NOME)-1,2)),' ',1) > 0) OR (INSTR((SUBSTR(P_ROW_OLD.NOME,LENGTH(P_ROW_OLD.NOME)-1,2)),' ',1) > 0) THEN --Esse if contempla as abreviações que terminam no final do nome.
              NULL;
            END IF;
          END IF;
        END IF;
        IF V_CRITICA   > 0 THEN--Neste caso a regra da portaria de nome foi violada.
          IF v_padaces = 'S' THEN
            P_MENS    := NULL;
          END IF;
        END IF;
        --Tratamento cpf
        IF V_PRIVILEG_LIVRE = 'N' THEN
          IF P_ROW_NEW.cpf IN (11111111111, 22222222222, 33333333333, 44444444444,55555555555, 66666666666, 77777777777, 88888888888,99999999999) OR (P_ROW_NEW.cpf = 191) OR (P_ROW_NEW.cpf = 19100)
            --          or (P_ROW_NEW.cpf IS NULL)
            THEN
            p_mens := 'Cpf inválido.';
          END IF;
        END IF;
      END IF;
      
      --Tipo de sexo.
      IF P_MENS               IS NULL THEN
        IF V_PRIVILEG_LIVRE = 'N' THEN
          IF P_ROW_NEW.SEXO NOT IN ('M', 'F') THEN
            IF P_ROW_NEW.FLEX_CAMPO_21 IS NULL THEN
         p_mens              := 'Sexo inválido.';
      END IF;
          END IF;
        ELSE
          p_mens              := NULL;
        END IF;
      END IF;      
      
      --Tipo de Estado Civil
      IF P_MENS IS NULL THEN
        BEGIN
          SELECT 1
          INTO V_ACHOU
          FROM TABELA T,
            ITEMTABELA I
          WHERE T.TAB = 'ERG_ESTCIVIL'
          AND I.TAB   = T.TAB
          AND I.ITEM  = P_ROW_NEW.ESTCIVIL;
        EXCEPTION
        WHEN OTHERS THEN
          IF P_ROW_NEW.FLEX_CAMPO_21 IS NULL THEN
             p_mens := 'Estado Civil inválido. ';
        --WHEN no_data_found THEN
        --  IF P_ROW_NEW.FLEX_CAMPO_21 IS NULL THEN
        --     p_mens := 'Estado Civil inválido.';
      END IF;
        END;
      END IF;
   
      --Tipo de Nacionalidade
      IF P_MENS IS NULL THEN
        BEGIN
          SELECT 1
          INTO V_ACHOU
          FROM TABELA T,
            ITEMTABELA I
          WHERE T.TAB = 'ERG_NACIONALIDADE'
          AND I.TAB   = T.TAB
          AND I.ITEM  = P_ROW_NEW.NACIONALIDADE;
        EXCEPTION
        WHEN OTHERS THEN
          IF V_PRIVILEG_LIVRE = 'N' THEN
             IF P_ROW_NEW.FLEX_CAMPO_21 IS NULL THEN
                p_mens := 'Nacionalidade  inválida.';
             END IF;
          ELSE
            p_mens := NULL;
          END IF;
        END;
      END IF;
      
      --Tipo de Raça
      IF P_MENS               IS NULL THEN
        IF P_ROW_NEW.RACA NOT IN (1,2,4,6,8,9) THEN
           IF P_ROW_NEW.FLEX_CAMPO_21 IS NULL THEN
              p_mens              := 'Raça inválida.';
       END IF;
        END IF;
      END IF;
      
      --Tipo de Deficiencia
      IF P_MENS                     IS NULL THEN
        IF P_ROW_NEW.DEFICIENTE NOT IN ('N', 'S') THEN
           IF P_ROW_NEW.FLEX_CAMPO_21 IS NULL THEN
              p_mens                    := 'Informação se é ou não deficiente difere de <S> ou <N>.';
           END IF;
        END IF;
      END IF;
      
      --AQUI SE VALIDA O MUNICIPIO NO CASO DE ESTADO RIO DE JANEIRO.
      IF P_ROW_NEW.UFENDER = 'RJ' THEN
        BEGIN
          SELECT COUNT(1)
          INTO V_ACHOU
          FROM MUNICIPIO
          WHERE NOME   = UPPER(P_ROW_NEW.CIDADEENDER)
          AND UF_SIGLA = P_ROW_NEW.UFENDER;
        EXCEPTION
        WHEN OTHERS THEN
          V_ACHOU := 0;
        END;
        IF V_ACHOU = 0 THEN
           IF P_ROW_NEW.FLEX_CAMPO_21 IS NULL THEN
              p_mens  := 'MUNICIPIO INVÁLIDO.';
       END IF;
        END IF;
      END IF;
      
      --Tratamento DO PISPASEP
      -- NOVO TRATAMENTO SOLICITADO PELA VERA SGD 939      
      --Não será obrigatório informar PIS para também as transações ('Dados Gerais MS605', 'RJadm00067', 'Pensionista Previdenciário' e 'Pensionistas'). 
      --Verificado com o Gerente Egidio. Luana 29/09/2015. 
      --if v_transacao not in ('TGRJ_INTERFACE_ALTERACOES_FUNC','Instituidor de Pensão') then
      if v_transacao not in ('TGRJ_INTERFACE_ALTERACOES_FUNC', 'Instituidor de Pensão', 'Dados Gerais MS605', 'RJadm00067', 'Pensionista Previdenciário', 'Pensionistas') then
          IF (V_EGE_LIVRE = 'N' AND V_PRIVILEG_LIVRE = 'N') THEN
            IF P_ROW_NEW.PISPASEP    IS NOT NULL THEN
              v_caracter             := SUBSTR(P_ROW_NEW.PISPASEP, 1,1);
              IF (P_ROW_NEW.PISPASEP IN ('10101010101','00000000191','10000000081', '116','940','12121212126')) OR (SUBSTR(P_ROW_NEW.PISPASEP, 1,1) = v_caracter AND SUBSTR(P_ROW_NEW.PISPASEP, 2,1) = v_caracter AND SUBSTR(P_ROW_NEW.PISPASEP, 3,1) = v_caracter AND SUBSTR(P_ROW_NEW.PISPASEP, 4,1) = v_caracter AND SUBSTR(P_ROW_NEW.PISPASEP, 5,1) = v_caracter AND SUBSTR(P_ROW_NEW.PISPASEP, 6,1) = v_caracter AND SUBSTR(P_ROW_NEW.PISPASEP, 7,1) = v_caracter AND SUBSTR(P_ROW_NEW.PISPASEP, 8,1) = v_caracter AND SUBSTR(P_ROW_NEW.PISPASEP, 9,1) = v_caracter) THEN-- Esta sequencia verifica se as 9 primeiras posicões sao identicas
                 IF P_ROW_NEW.FLEX_CAMPO_21 IS NULL THEN 
                    p_mens               := 'Pispasep Inválido.';
           END IF;
              END IF;
            ELSIF P_ROW_NEW.PISPASEP IS NULL THEN
              -- Retornando o PIS_EXIGE cadastrado.
              v_pis_exige   := PACK_HADES.GET_OPCAO('C_Ergon','GOVRJ','PIS_EXIGE');
              IF v_pis_exige = 'S' THEN
                IF P_INSERTING THEN
                   IF P_ROW_NEW.FLEX_CAMPO_21 IS NULL THEN
                      p_mens := 'O PIS/PASEP do servidor é obrigatório.';
           END IF;
                ELSIF P_UPDATING THEN -- Se for updating
                  --Este select retorna a quantidade de vínculos ATIVOS do funcionário
                  BEGIN
                    SELECT COUNT(1)
                    INTO v_count_situacao
                    FROM VINCULOS V
                    WHERE V.NUMFUNC                                                      = P_ROW_NEW.NUMERO
                    AND PACK_ERGON.GET_SITUACAO_FUNC(V.NUMFUNC, V.NUMERO, NULL, SYSDATE) = 'ATIVO';
                  EXCEPTION
                  WHEN OTHERS THEN
                    p_mens := 'Houve um erro na consulta da situação funcional. Erro: '||SQLERRM;
                  END;
                  -- Se o servidor possui algum vínculo de ativo...
                  IF v_count_situacao > 0 and P_ROW_NEW.FLEX_CAMPO_21 is NULL THEN
                    p_mens           := 'O PIS/PASEP do servidor é obrigatório.';
                  END IF;
                END IF;
              END IF;
            END IF;
          END IF;
      end if;
      
      --Atualiza email no portal servidor caso necessário, somente se estiver no
      --banco de produção, após sgd 2048 será feito na TGRJ_EPA__FUNCIONARIOS
    
    --- checar se p_mens esta vazia para so executar se vazia  
    
    
    --IF P_ROW_NEW.FLEX_CAMPO_21 IS NULL and p_mens is null THEN
    --   P_ATUALIZA_EMAIL_PORTAL;
    --END IF;

    END IF;

    IF (P_UPDATING OR P_INSERTING) THEN
        IF P_INSERTING OR (P_UPDATING AND
          (NVL(P_ROW_NEW.FLEX_CAMPO_24,'x') <> NVL(P_ROW_OLD.FLEX_CAMPO_24,'x') )) THEN
           IF FLAG_PACK.GET_TRANSACAO IN ('Instituidor de Pensão') THEN

              IF P_ROW_NEW.FLEX_CAMPO_24 IS NOT NULL THEN
                 IF P_ROW_NEW.FLEX_CAMPO_22 IS NULL THEN
                    P_MENS  := 'Forma de Vacância é obrigatória para a CATEGORIA:'||P_ROW_NEW.FLEX_CAMPO_24||'.';
                 END IF;
              END IF;
              IF P_ROW_NEW.FLEX_CAMPO_24 IS NOT NULL THEN
                 IF P_ROW_NEW.FLEX_CAMPO_21 IS NULL THEN
                    P_MENS  := 'Data de Óbito é obrigatória para a CATEGORIA:'||P_ROW_NEW.FLEX_CAMPO_24||'.';
                 END IF;
              END IF;
           END IF;
        END IF;
    END IF;
    
    
    IF (P_UPDATING OR P_INSERTING) THEN
      IF REGEXP_LIKE(P_ROW_NEW.NUMRG,'[.,-/ +*]') THEN
        P_MENS  := 'O campo "Número do Registro Geral" não pode conter (, . - / + *) nem espaço em branco.';
      END IF;  
    END IF;
    /*
    --Atualiza ou insere a base do Portal ADM Servidor
    IF P_UPDATING and p_mens is null THEN

      IF P_ROW_NEW.E_MAIL IS NOT NULL THEN

           IF NVL(P_ROW_NEW.E_MAIL,'XXXX') <> NVL(P_ROW_OLD.E_MAIL,'XXXX') THEN

              IF NOT PGOV_VALIDA_EMAIL(P_ROW_NEW.E_MAIL) THEN
                p_mens := 'Formatação do Email incorreto, favor verificar.';
                RETURN (TRUE);
              END IF;

              begin 
               UPDATE funcionario@DBL_PORTAL_ADM FU
                 SET EMAIL = P_ROW_NEW.E_MAIL,
                     DT_UPDATE = SYSDATE
               WHERE IDFUNC = SUBSTR(P_ROW_NEW.NUMERO,1, LENGTH(P_ROW_NEW.NUMERO) - 1);
              exception
                 when others then
                 IF SQL%NOTFOUND THEN
                    p_mens := 'Problema ao atualizar o Email no portal ADM';
                 END IF;
              end ;
              
           END IF;

      ELSE

           IF NVL(P_ROW_NEW.FLEX_CAMPO_35,'XXXX') <> NVL(P_ROW_OLD.FLEX_CAMPO_35,'XXXX') THEN

               IF NOT PGOV_VALIDA_EMAIL(P_ROW_NEW.FLEX_CAMPO_35) THEN
                 p_mens := 'Formatação do Email incorreto, favor verificar.';
                 RETURN (TRUE);
               END IF;

               begin
                  UPDATE funcionario@DBL_PORTAL_ADM FU
                     SET EMAIL = P_ROW_NEW.FLEX_CAMPO_35,
                         DT_UPDATE = SYSDATE
                   WHERE IDFUNC = SUBSTR(P_ROW_NEW.NUMERO,1, LENGTH(P_ROW_NEW.NUMERO) - 1);
               exception
                 when others then
                      IF SQL%NOTFOUND THEN
                         p_mens := 'Problema ao atualizar o Email no portal ADM';
                      END IF;
               end ;
               
           END IF;

      END IF;

    END IF;
    */
    
    -- Início SGD 2423
    -- Feito por Ismael Lauro em 07/04/2016
    if P_DELETING and flag_pack.get_transacao = 'Funcionários' then
      
      declare
      
        v_count_biometria number := 0;
        v_count_pens      number := 0;
        
        cursor c1 is
         select numfunc,
                numvinc,
                numero
           from pensionistas 
          where flex_campo_04 = P_ROW_old.Numero;
        
      begin
        
         begin
          
          select count(1)
            into v_count_biometria
            from pgov_situacao_biometria 
           where numfunc = P_ROW_old.Numero;
         exception when others then
            p_mens := 'Erro ao encontrar funcionário da tabela PGOV_SITUACAO_BIOMETRIA.';
            return(true);
         end;
          
         if v_count_biometria > 0 then
           
           begin
                
             delete from pgov_situacao_biometria where numfunc = P_ROW_old.Numero;
           exception when others then
               p_mens := 'Erro ao excluir funcionário da tabela PGOV_SITUACAO_BIOMETRIA.';
               return(true);
           end;
                       
         end if; 
         
         begin
          
          select count(1)
            into v_count_pens
            from pensionistas 
           where flex_campo_04 = P_ROW_old.Numero;
         exception when no_data_found then
            p_mens := 'Erro ao encontrar funcionário da tabela Pensionistas.';
            return(true);
         end;
          
         if v_count_pens > 0 then
           
           for r1 in c1 loop
             p_mens := 'Esse ID é pensionista de número: '||r1.numero||', atrelado ao instituidor: '||r1.numfunc||' vínculo: '||r1.numvinc||'.';
             return(true);
           end loop; 
                       
         end if;   
      
      end; 
    end if;
    --Fim SGD 2423
    
    -- SGD 2887 -- Feito por Ismael Lauro em 22/07/2016
    if (P_INSERTING or (P_UPDATING and (P_ROW_NEW.Nome <> P_ROW_OLD.Nome     or 
                                        P_ROW_NEW.Cpf <> P_ROW_OLD.Cpf       or 
                                        P_ROW_NEW.Dtnasc <> P_ROW_OLD.Dtnasc or 
                                        P_ROW_NEW.PISPASEP <> P_ROW_OLD.Pispasep))) then
    
      P_ROW_NEW.Flex_Campo_65 := 'N';
     
    end if;                                    
    -- Fim SGD 2887

    RETURN (TRUE);
    
  END;
/
