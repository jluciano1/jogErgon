prompt ***ATENÇÃO!!!*** Objeto TGRJ_EPB__PENSIONISTAS não possui replace e deve ser mesclado manualmente com a versão existente no banco.
create FUNCTION "TGRJ_EPB__PENSIONISTAS" (
    P_ROW_NEW    IN OUT NOCOPY PENSIONISTAS%ROWTYPE,
    P_ROW_OLD    IN     PENSIONISTAS%ROWTYPE,
    P_INSERTING  IN     BOOLEAN,
    P_UPDATING   IN     BOOLEAN,
    P_DELETING   IN     BOOLEAN,
    P_MENS       OUT    NOCOPY VARCHAR2
  )
    RETURN BOOLEAN IS

    --v_count number := 0;
    V_NUMERO          number;
    v_transacao       varchar(400);
    V_CATEGORIA       VARCHAR2(20);--LUANA.
    V_COUNT           NUMBER := 0;
    V_PRIVILEG_LIVRE  VARCHAR2(1);
    V_CPF_INST        number(11);
    V_CPF_PENS        number(11);
    v_existe          number(1);--LUANA.

    PROCEDURE P_ATUALIZA_EMAIL_PORTAL IS

       V_SERVER_HOST VARCHAR2(200);
       V_SERVER_HOST_PRODUCAO VARCHAR2(200);
       V_SQL          VARCHAR2(2000);

     BEGIN

       /* Pegar directory de acordo com o servidor */
       select SYS_CONTEXT('USERENV', 'SERVER_HOST')
         into V_SERVER_HOST
         from dual;
       --
       select pack_hades.get_opcao('C_Ergon', 'Geral', 'SERVER_HOST_PROD') into  V_server_host_producao from dual;
       --
       IF V_SERVER_HOST = V_server_host_producao THEN

          --Atualiza ou insere a base do Portal ADM Servidor
          IF P_ROW_NEW.FLEX_CAMPO_03 IS NOT NULL THEN

                IF NVL(P_ROW_OLD.FLEX_CAMPO_03,'XXXX') <> NVL(P_ROW_NEW.FLEX_CAMPO_03,'XXXX') THEN

                   IF P_ROW_NEW.FLEX_CAMPO_03 IS NOT NULL THEN

                     IF NOT PGOV_VALIDA_EMAIL(P_ROW_NEW.FLEX_CAMPO_03) THEN
                       P_MENS :=('Formatação do Email incorreto, favor verificar.');

                     END IF;

                   END IF;

                    BEGIN

                      V_SQL := 'UPDATE funcionario@DBL_PORTAL_ADM FU
                                   SET EMAIL     ='''|| P_ROW_NEW.FLEX_CAMPO_03||''',
                                    WHERE IDFUNC = SUBSTR('||P_ROW_NEW.FLEX_CAMPO_04||',1, LENGTH('||P_ROW_NEW.FLEX_CAMPO_04||') - 1)';


                     pack_hades.EXECUTA_SQL(V_SQL);

                     EXCEPTION

                       WHEN OTHERS THEN
                         P_MENS :=('Erro atualizar o Email no portal ADM... '||sqlerrm(sqlcode));

                    END;

                END IF;

         END IF;

       END IF;

     END;

  BEGIN

  --
  -- Jair.caponi SGD 2337 - Inicio
  --
  IF P_ROW_NEW.NOME = 'COTA RESERVADA' AND P_ROW_NEW.PARENTESCO = 'COTISTA' THEN
     RETURN (FALSE);
  END IF;
  --
  -- Jair.caponi SGD 2337 - FIM
  --

  IF FLAG_PACK.GET_USUARIO = 'migra' THEN
    RETURN (TRUE);
  END IF;

  IF P_INSERTING OR
     P_DELETING  OR
     P_UPDATING  THEN
     --
     -- Validação do acesso transversal
     -- Usuários "Previdenciarios" somente poderão atualizar dados de funcinarios inativos ou falecidos
     -- Usuários "Não Previdenciarios" somente poderão atualizar dados de funcinarios ativos
     -- Usuários "Privilegiados" poderão acessar qualquer funcionarios, ou seja, ativos, inativos e falecidos
     --
     DECLARE
       --
       V_DML       CHAR(1)                             DEFAULT NULL;
       --
     BEGIN
       IF P_INSERTING  THEN V_DML := 'I'; END IF;
       IF P_UPDATING   THEN V_DML := 'U'; END IF;
       IF P_DELETING   THEN V_DML := 'D'; END IF;
       --
       P_MENS := VERIFICA_TABELAS_ERGON(V_DML,'PENSIONISTAS',NVL(P_ROW_NEW.NUMFUNC,P_ROW_OLD.NUMFUNC), NVL(P_ROW_NEW.NUMVINC,P_ROW_OLD.NUMVINC), NULL, NULL);
       --
     END;
  END IF;
  --
  v_transacao :=  flag_pack.get_transacao;
  if  p_row_new.TIPOPAG not in ('CONTA') and (v_transacao in ('Pensionista Previdenciário', 'RJadm00039'))
  then
    p_mens := 'Tipo de pagamento CONTA é obrigatório!';
    --return true;
  end if;
  --
  --Inserido por Rodrigo Machado em 22/10/2015 a pedido do SGD 2421
  --pois o banco e a agência devem ser informados, mesmo que a agência seja a padrão 0000.
  --Com essas modificações abaixo não ocorrerá mais erros no envio dos pagamentos.
  if v_transacao in ('Pensionista Previdenciário', 'RJadm00039')then
    
     IF NOT P_DELETING THEN --LUANA SGD 2738. 
        IF P_ROW_NEW.BANCO IS NULL THEN
           P_MENS := 'Número do Banco é Obrigatório.';
        END IF;
     END IF;   
     
     IF p_row_new.TIPOPAG IN ('CONTA','POUPA') AND P_ROW_NEW.AGENCIA IS NULL THEN
       P_MENS := 'Quando o tipo do pagamento for Conta ou Poupança é obrigatório informar a agência, mesmo que seja a agência padrão (0000).'; 
     END IF;
  
    end if;
    --------------------FIM MODIFICAÇÃO DO SGD 2421--------------------------------
  


  if (v_transacao in ('Pensionista Previdenciário', 'RJadm00039')) AND NVL(p_row_new.BANCO,p_row_OLD.BANCO) IS NOT NULL
  THEN
    IF  (p_row_new.FLEX_CAMPO_50 IS NOT NULL AND p_row_new.FLEX_CAMPO_49 IS NULL) and pack_hades.GET_OPCAO ('C_Ergon', 'PENS_PREV', 'CONTA_SALARIO') = 'SIM'
    then
      p_mens := 'Conta Salário é obrigatório';
      --return true;
    END IF;
    --
    IF  (p_row_new.FLEX_CAMPO_49 IS NOT NULL AND p_row_new.FLEX_CAMPO_50 IS NULL) and pack_hades.GET_OPCAO ('C_Ergon', 'PENS_PREV', 'CONTA_SALARIO') = 'SIM'
    then
      p_mens := 'Agência Conta Salário é obrigatório';
      --return true;
    END IF;
  end if;
  --
  --Permitir cadastro de pensionistas com Tipo de Pagamento: Espécie quando vier da transação Dados Gerais MS605. 
  --Verificar se existe regra para o pensionista, pois caso seja feita alguma alteração na tela de funcionários, não ocorrer mensagem 
  --que não é possível atualizar registro como Espécie, caso o pensionista tenha regra de pensao. SGD 1543. Luana 21/12/2015.
  --v_existe = 1 -> Existe regra v_existe <> 0 -> Não existe regra.
  begin
     select 1
       into v_existe
       from regras_pensao rp   
      where rp.numfunc      = p_row_new.numfunc
        and rp.numvinc      = p_row_new.numvinc
        and rp.numpens      = p_row_new.numero       
        and rp.tipopens     = 'PENSÃO MS605'
        and rp.dtfim is null;
  exception
     when no_data_found then
        v_existe := null;     
  end;      
  --   
if nvl(v_existe, 0) <> 1 then
  if p_row_new.TIPOPAG = 'ESPEC' and (flag_pack.get_transacao NOT IN ('Vacância', 'ERGadm00153')) then
    -- Impede atualização de tipo de pagamento em espécie na tela cadastro de Pensionistas
    -- Tarefa no Attask - CRIAR TIPO PAG "CONTA SALÁRIO"
    -- Allan Barbosa da Silva - 24/08/2012
    p_mens := 'Não é mais possível atualizar registros como Espécie!';
    return true;
  end if;
end if;
  if  p_row_new.TIPOPAG not in ('CONTA') and ('Instituidor de Pensão' = flag_pack.get_transacao)
  then
    p_mens := 'Não é mais possível atualizar registros como Espécie!';
    return true;
  end if;

  IF p_inserting OR p_updating THEN
      -- Retorna o nome do Pensionista
      -- Dagoberto (Techne) - 15/10/2009
      --
      p_row_new.nome := formata_nome_maiusc(p_row_new.nome);
      --
      -- Só permite lançar tipo de deficiência de estiver marcado como deficiente
      -- e se marcado deficiente, exige tipo de deficiência
      --
      -- Dagoberto (Techne) - 05/01/2011
      --
      --Inclusão da transação 'Dados Gerais MS605'. Luana 02/12/2015. SGD 1543.
      IF (v_transacao not in ('RJadm00039', 'RJadm00067', 'Pensionista Previdenciário','Instituidor de Pensão', 'Dados Gerais MS605')) THEN

        IF (NVL(p_row_new.flex_campo_29,'N') = 'S') AND (p_row_new.flex_campo_30 IS NULL) THEN
          p_mens := 'O tipo de deficiência é obrigatório quando o pensionista é deficiente';
        END IF;
        --
        IF (NVL(p_row_new.flex_campo_29,'N') = 'N') AND (p_row_new.flex_campo_30 IS NOT NULL) THEN
          p_mens := 'O tipo de deficiência só pode ser preenchido quando o pensionista é deficiente';
        END IF;
      END IF;
      --
      -- Validação do dígito da conta corrente do banco Itau
      -- Dagoberto 09/05/2011
      IF p_row_new.banco IS NOT NULL THEN
        TGRJ_VALIDA_CC_ITAU (p_row_new.banco,p_row_new.agencia, p_row_new.conta, p_row_new.tipopag);
      END IF;
      --

      --Verifica se é necessario atualizar o email do pensionista no portal servidor
      --somente no banco de produção essa rotina é executada.
      P_ATUALIZA_EMAIL_PORTAL;
      /*-------------------------------------------------------------------------
       Já existe esta validação do CPF na EPA de Pensionistas para a transação
       'Dados Gerais MS605' por isso foi colocado esta condição aqui.
       LUANA 07/08/2015. SGD 1543.
       Regra: O cadastro de Pensionistas Especiais MS605 só é permitido para
       categoria de Auditor Fiscal da Fazenda do Estado do Rio de Janeiro.
       LUANA 07/08/2015. SGD 1543.
      --------------------------------------------------------------------------*/

      IF v_transacao not in ('Dados Gerais MS605','RJadm00067') THEN

         --***********************************************************************
         --Alteração para impedir que a pensionista seja cadastrada caSo cpf não *
         --seja informado. SGD   1355.                                           *
         --Célio Paulo                                                           *
         --***********************************************************************

         --Modificado por Rodrigo Machado onde caso seja usuário privilegiado
         --em 30/09/2015
         SELECT COUNT(1)
           INTO V_COUNT
          FROM PADUSUARIO
         WHERE USUARIO = FLAG_PACK.get_usuario
           AND PADACES = 'PRIVILEG_LIVRE';
         --
         IF P_ROW_NEW.CPF IS NULL AND V_COUNT = 0 THEN
            P_MENS := 'CPF NÃO INFORMADO OU INVALIDO!';
         END IF;

      ELSIF v_transacao = 'Dados Gerais MS605' THEN

         BEGIN
              SELECT CATEGORIA
                INTO V_CATEGORIA
                FROM VINCULOS
               WHERE NUMFUNC = P_ROW_NEW.NUMFUNC
                 AND NUMERO  = P_ROW_NEW.NUMVINC;
           EXCEPTION
              WHEN NO_DATA_FOUND THEN
                 V_CATEGORIA := NULL;
           END;
           --
           IF V_CATEGORIA <> '09 AUDITOR FISCAL' THEN
              p_mens := 'O cadastro de Pensionistas Especiais MS605 só é permitido para servidores/impetrantes com categoria de Auditor Fiscal da Fazenda do Estado do Rio de Janeiro.';
              RETURN(TRUE);
           END IF;
      END IF;--LUANA 07/08/2015. SGD 1543.
   END IF;
    --Comentado conforme solicitação do SGD 1466 por Rodrigo Machado em 09/06/2014.
    /*
    --
    --Verifica o perfil caso permita pode modificar os campos responsáveis pela
      --agencia e conta salário
      if nvl(p_row_new.flex_campo_50,'XXXXX') <> NVL(P_ROW_OLD.Flex_Campo_50,'XXXXX') then

         SELECT COUNT(1)
           INTO v_count
           FROM padusuario p
          where p.padaces = 'Com_CONTA SAL'
            and p.usuario = FLAG_PACK.get_usuario;

         if v_count = 0 then
            p_mens := 'Usuário não possui perfil para incluir ou atualizar o campo Agência Salário.';
            RETURN (TRUE);
         end if;

         p_row_new.flex_campo_19 := p_row_new.flex_campo_50;

      end if;
      --
      if NVL(p_row_new.flex_campo_49,'XXXXX') <> NVL(P_ROW_OLD.Flex_Campo_49,'XXXXX') then

         SELECT COUNT(1)
           INTO v_count
           FROM padusuario p
          where p.padaces = 'Com_CONTA SAL'
            and p.usuario = FLAG_PACK.get_usuario;

         if v_count = 0 then
            p_mens := 'Usuário não possui perfil para incluir ou atualizar o campo Conta Salário.';
            RETURN (TRUE);
         end if;

         p_row_new.flex_campo_20 := p_row_new.flex_campo_49;

      end if;
      --
      */

    IF NVL(p_row_new.flex_campo_50,'00000000') <> NVL(P_ROW_OLD.Flex_Campo_50,'00000000') THEN
       p_row_new.flex_campo_19 := p_row_new.flex_campo_50;
       p_row_new.flex_campo_09 := 'CSAL';
    END IF;
    --
    IF NVL(p_row_new.flex_campo_49,'00000000') <> NVL(P_ROW_OLD.Flex_Campo_49,'00000000') THEN
       p_row_new.flex_campo_20 := p_row_new.flex_campo_49;
       p_row_new.flex_campo_09 := 'CSAL';
    END IF;

    IF (p_row_new.tipopag NOT IN ('ESPEC','SEMCC') AND (NVL(p_row_new.flex_campo_49,'00000000') <> NVL(P_ROW_OLD.Flex_Campo_49,'00000000') OR NVL(p_row_new.flex_campo_50,'00000000') <> NVL(P_ROW_OLD.Flex_Campo_50,'00000000'))) THEN
       TGRJ_VALIDA_CC (p_row_new.banco,p_row_new.flex_campo_19,P_ROW_NEW.flex_campo_20, p_row_new.tipopag);
    END IF;
/*
    --Atualiza ou insere a base do Portal ADM Servidor
    IF P_UPDATING THEN

      IF NVL(P_ROW_NEW.FLEX_CAMPO_03,'XXXX') <> NVL(P_ROW_OLD.FLEX_CAMPO_03,'XXXX') THEN

          IF NOT PGOV_VALIDA_EMAIL(P_ROW_NEW.FLEX_CAMPO_03) THEN
              p_mens := 'Formatação do Email incorreto, favor verificar.';
              RETURN (TRUE);
          END IF;

          UPDATE funcionario@DBL_PORTAL_ADM FU
            SET EMAIL = P_ROW_NEW.FLEX_CAMPO_03,
                DT_UPDATE = SYSDATE
          WHERE IDFUNC = SUBSTR(P_ROW_NEW.FLEX_CAMPO_04,1, LENGTH(P_ROW_NEW.FLEX_CAMPO_04) - 1);

          IF SQL%NOTFOUND THEN
            p_mens := 'Problema ao atualizar o Email no portal ADM';
            RETURN (TRUE);
          END IF;

      END IF;

    END IF;
*/
  /*A inclusão ou a alteração dos campos CPF e FLEX_CAMPO_04(NUMFUNC do Pensionista) 
  na tela PENSIONISTA (MS605, Previdenciário e Pensionistas) não poderão receber o CPF e o 
  NUMFUNC do Instituidor. Na atualização de cadastro dos pensionistas estes campos CPF e 
  FLEX_CAMPO_04 deverão existir na tabela de funcionários. 
  E só poderão ser atualizados caso o usuário possua o privilégio 'PRIVILEG_LIVRE'.
  Solicitado por Maria do Carmo. SGD 2407. Luana 15/10/2015.*/  
  -- 
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
     
  IF FLAG_PACK.GET_TRANSACAO in ('RJadm00039', 'RJadm00067', 'Dados Gerais MS605', 'Pensionista Previdenciário', 'Pensionistas', 'Instituidor de Pensão') then
     --
     IF P_INSERTING THEN
       
        BEGIN          
           SELECT CPF
             INTO V_CPF_INST
             FROM FUNCIONARIOS  
            WHERE NUMERO = P_ROW_NEW.NUMFUNC;
        EXCEPTION
           WHEN NO_DATA_FOUND THEN
              NULL;
           WHEN TOO_MANY_ROWS THEN
              P_MENS := 'CPF duplicado no cadastro de funcionários. Favor verificar!'||SQLERRM; 
              RETURN(TRUE); 
           WHEN OTHERS THEN
              P_MENS := 'Erro. '||sqlerrm;
              RETURN(TRUE);    
        END;                        
        --                     
        IF (P_ROW_NEW.NUMFUNC = P_ROW_NEW.FLEX_CAMPO_04 OR V_CPF_INST = P_ROW_NEW.CPF) THEN
           P_MENS := 'Não é permitido incluir pensionista com Id Funcional e/ou CPF do Instituidor. ';
           RETURN(TRUE);                       
        END IF;   
        --         
        BEGIN          
           SELECT CPF
             INTO V_CPF_PENS
             FROM FUNCIONARIOS  
            WHERE NUMERO = P_ROW_NEW.FLEX_CAMPO_04;
        EXCEPTION
           WHEN NO_DATA_FOUND THEN
              IF P_ROW_NEW.FLEX_CAMPO_04 IS NOT NULL THEN
                 P_MENS := 'Este Id Funcional do Pensionista não existe no cadastro de Funcionários. Favor verificar! ';
                 RETURN(TRUE);   
              END IF;         
           WHEN TOO_MANY_ROWS THEN
              P_MENS := 'CPF duplicado no cadastro de funcionários. Favor verificar!'||SQLERRM; 
              RETURN(TRUE); 
           WHEN OTHERS THEN
              P_MENS := 'Erro. '||sqlerrm;
              RETURN(TRUE);    
        END;                    
        IF P_ROW_NEW.CPF <> V_CPF_PENS THEN
           P_MENS := 'Este CPF não pertence ao Id Funcional do Pensionista informado. Favor verificar! ';
           RETURN(TRUE);         
        END IF; 
          
     ELSIF P_UPDATING THEN       
        BEGIN          
           SELECT CPF
             INTO V_CPF_INST
             FROM FUNCIONARIOS  
            WHERE NUMERO = P_ROW_NEW.NUMFUNC;
        EXCEPTION
           WHEN NO_DATA_FOUND THEN
              NULL; 
           WHEN TOO_MANY_ROWS THEN
              P_MENS := 'CPF duplicado no cadastro de funcionários. Favor verificar!'||SQLERRM; 
              RETURN(TRUE); 
           WHEN OTHERS THEN
              P_MENS := 'Erro. '||sqlerrm;
              RETURN(TRUE);    
        END;       
        --
        IF P_ROW_NEW.FLEX_CAMPO_04 IS NULL THEN
           P_MENS := 'Id Funcional deve ser informado. ';
           RETURN(TRUE);             
        ELSIF (P_ROW_NEW.NUMFUNC = P_ROW_NEW.FLEX_CAMPO_04 OR V_CPF_INST = P_ROW_NEW.CPF) THEN
           P_MENS := 'Não é permitido incluir pensionista com Id Funcional e/ou CPF do Instituidor. ';
           RETURN(TRUE);  
        ELSIF (P_ROW_OLD.FLEX_CAMPO_04 <> P_ROW_NEW.FLEX_CAMPO_04 OR P_ROW_OLD.CPF <> P_ROW_NEW.CPF) THEN
           IF V_PRIVILEG_LIVRE = 'N' THEN  
              P_MENS := ' Usuário não possui privilégio para alterar Id Funcional e/ou CPF do Pensionista. ';
              RETURN(TRUE); 
           END IF;                     
        END IF;
        --
        BEGIN          
           SELECT CPF
             INTO V_CPF_PENS
             FROM FUNCIONARIOS  
            WHERE NUMERO = P_ROW_NEW.FLEX_CAMPO_04;
        EXCEPTION
           WHEN NO_DATA_FOUND THEN
              P_MENS := 'Este Id Funcional do Pensionista não existe no cadastro de Funcionários. Favor verificar! ';
              RETURN(TRUE); 
           WHEN TOO_MANY_ROWS THEN
              P_MENS := 'CPF duplicado no cadastro de funcionários. Favor verificar!'||SQLERRM; 
              RETURN(TRUE); 
           WHEN OTHERS THEN
              P_MENS := 'Erro. '||sqlerrm;
              RETURN(TRUE);    
        END;   
        --              
        IF P_ROW_NEW.CPF <> V_CPF_PENS THEN
           P_MENS := 'Este CPF não pertence ao Id Funcional do Pensionista informado. Favor verificar! ';
           RETURN(TRUE); 
        ELSIF P_ROW_OLD.CPF <> P_ROW_NEW.CPF THEN
           IF V_PRIVILEG_LIVRE = 'N' THEN  
              P_MENS := 'Usuário não possui privilégio para alterar CPF do Pensionista. ';
              RETURN(TRUE); 
           END IF;                
        END IF; 
     END IF; 
     --          
  END IF;   
 --Luana 15/10/2015.
  
  -- Atualiza o numero do ID_FUNCIONAL do PENSIONISTA de acordo com o CPF se o mesmo ja exitir na tabela de FUNCIONARIOS
  --
  IF P_INSERTING OR P_UPDATING THEN
     BEGIN
        SELECT NUMERO INTO V_NUMERO
          FROM FUNCIONARIOS
          WHERE CPF = P_ROW_NEW.CPF;
        EXCEPTION
          WHEN OTHERS THEN
               V_NUMERO := NULL;
        END;
        IF V_NUMERO IS NOT NULL THEN
           P_ROW_NEW.FLEX_CAMPO_04 := V_NUMERO;
        END IF;
  END IF;

    --
  --
  IF P_DELETING  THEN
   DELETE FROM TGRJ_DOC_PENSIONISTA
   WHERE NUMFUNC = P_ROW_OLD.NUMFUNC
   AND   NUMVINC = P_ROW_OLD.NUMVINC;
  END IF;
  --
  
  -- Feito por Ismael Lauro em 24/05/2016 SGD 988
  -- Verificar se o campo CORREIO (flex_campo_01) está em branco e se sim atribuir a letra 'S' 
  IF (P_INSERTING OR P_UPDATING) THEN
    IF P_ROW_NEW.FLEX_CAMPO_01 IS NULL THEN
      P_ROW_NEW.FLEX_CAMPO_01 := 'S';
    END IF;
  END IF; 

    RETURN (TRUE);
  END;
/
