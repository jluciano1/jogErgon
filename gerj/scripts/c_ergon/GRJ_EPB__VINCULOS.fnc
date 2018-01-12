prompt ***ATENÇÃO!!!*** Objeto GRJ_EPB__VINCULOS não possui replace e deve ser mesclado manualmente com a versão existente no banco.
--
--  EP com get_transacao. 
--  Não altere essa função. Ela deverá ser alterado no cliente.
--
create FUNCTION "GRJ_EPB__VINCULOS" (
      P_ROW_NEW   IN OUT NOCOPY VINCULOS%ROWTYPE,
      P_ROW_OLD   IN VINCULOS%ROWTYPE,
      P_INSERTING IN BOOLEAN,
      P_UPDATING  IN BOOLEAN,
      P_DELETING  IN BOOLEAN,
      P_MENS OUT NOCOPY VARCHAR2 )
    RETURN BOOLEAN
  IS
    --
    --
    --v_numfunc VINCULOS.NUMFUNC%TYPE;
    --v_numvinc VINCULOS.NUMFUNC%TYPE;
    --v_setor1     VARCHAR2(15);
    --v_setor2     VARCHAR2(15);
    --v_usu_privil VARCHAR2(1);
    --
    v_flex_campo_02 erg_ingresso.flex_campo_02%TYPE;
    --
    V_PRIVILEG_LIVRE VARCHAR2(1);
    V_NAO_TEMP_PASEP NUMBER := 0;
    V_TEM_COMIS      NUMBER := 0;
    --V_TEM_GLP        NUMBER := 0;
    V_COUNT          NUMBER := 0;
    --V_JORNADA        NUMBER := 0;
    --v_cont_vinc      NUMBER := 0;
    v_cont_orgao     NUMBER := 0;
    v_cont_orgao_ant NUMBER := 0;
    --V_CONTA          VARCHAR2(20);
    V_IDADE_TPVINC   NUMBER := 0;
    V_IDADE_FUNC     NUMBER := 0;
    --V_COUNT_MILITAR  NUMBER := 0;
    V_ITEM           VARCHAR2(100);
    v_privil         number;

    v_nome_transacao varchar2(1000) := flag_pack.get_transacao;
    --V_TEM_REPR_LEGAL NUMBER := 0;
    V_MATRICULA1_AUX VINCULOS.MATRICULA1%TYPE; --SGD-1678
    --
    V_COD_SUBESP     ERG_INGRESSO.FLEX_CAMPO_09%TYPE;
    V_DESC_SUBESP    ERG_INGRESSO.FLEX_CAMPO_10%TYPE;
    V_SUBESP         VINCULOS.FLEX_CAMPO_18%TYPE;
    V_CODIGO_ATIVIDADE      ERG_INGRESSO.FLEX_CAMPO_01%TYPE:=NULL;
    V_CODIGO_DISCIPLINA     ERG_INGRESSO.FLEX_CAMPO_01%TYPE:=NULL;
    V_DESCRICAO_ATIVIDADE   ERG_INGRESSO.FLEX_CAMPO_01%TYPE;
    V_DESCRICAO_DISCIPLINA  ERG_INGRESSO.FLEX_CAMPO_01%TYPE;
    v_existe_categoria NUMBER := 0;
    V_FLEX_CAMPO_09 ERG_INGRESSO.FLEX_CAMPO_09%TYPE;
    v_vinc_ number :=0;
    V_OPCAO varchar2(100);

  BEGIN

    -- Verifica se o usuário é privilegiado --
    select count(1)
    into v_privil
    from usuario
    where usuario = flag_pack.get_usuario
    and privil = 'S';

    -- impedir que usuários não privilegiados alterem o campo SISOBI (FLEX_CAMPO_11) e
    -- impedir a forma de vacância seja alterada quando SISOBI = 'S'
    -- Reinaldo Mesquita, 21/06/2016, SGD 2841
    if v_nome_transacao in ('Vacância','Vínculo','ERGadm00153', 'ERGadm00229') then
      if (p_inserting) or (p_updating) then
        if v_privil = 0 then
          if P_ROW_NEW.FLEX_CAMPO_11 <> P_ROW_OLD.FLEX_CAMPO_11 then
            p_mens := 'O usuário não possui permissão para alterar o campo SISOBI.';
            return true;
          end if;
          if P_ROW_OLD.FLEX_CAMPO_11 = 'S' then
            if P_ROW_NEW.FORMAVAC <> P_ROW_OLD.FORMAVAC then
              p_mens := 'O usuário não possui permissão para alterar a forma de desligamento de proveniente do SISOBI.';
              return true;
            end if;
          end if;
        end if;
      end if;
    end if;

  --caso exista uma vacancia para clt não permite gerar evento de instituidor de pensão.
 IF P_UPDATING AND flag_pack.get_transacao in ( 'Vacância','ERGadm00153' ) THEN
   --------------------------------------------------------------------------------
              --Inicio Inserido por Rodrigo Machado em 16/07/2015--
     --------------------------------------------------------------------------------
     V_OPCAO := PACK_HADES.GET_OPCAO('Ergon', 'ERGON', 'VAC_FALEC');

     IF  p_row_new.formavac = V_OPCAO THEN
                   
         IF p_row_new.regimejur = 'CLT' THEN 
             Begin
                 update had_opcoes_itens
                    set valor = 'N'
                  where sis   = 'Ergon'
                    and grupo = 'ERGON'
                    and opcao = 'VAC_AUT' ;
             End ;
         ELSE
             BEGIN
                 update had_opcoes_itens
                    set valor = 'S'
                  where sis   = 'Ergon'
                    and grupo = 'ERGON'
                    and opcao = 'VAC_AUT' ;
             END;

         END IF;
         
     END IF; 
     
     --------------------------------------------------------------------------------
              --fim Inserido por Rodrigo Machado em 16/07/2015--
     --------------------------------------------------------------------------------
 END IF;  

  --Bernardo 04/08/2015 Início
  IF (P_INSERTING) OR (P_UPDATING) THEN
    IF P_ROW_NEW.FLEX_CAMPO_02 IS NOT NULL THEN
      IF (P_ROW_NEW.FLEX_CAMPO_02 = 'S') OR (P_ROW_NEW.FLEX_CAMPO_02 = 's') OR (P_ROW_NEW.FLEX_CAMPO_02 = 'sim') THEN

         P_ROW_NEW.FLEX_CAMPO_02 := 'SIM';

      ELSIF (P_ROW_NEW.FLEX_CAMPO_02 = 'N') OR (P_ROW_NEW.FLEX_CAMPO_02 = 'n') OR (P_ROW_NEW.FLEX_CAMPO_02 = 'nao')
         OR (P_ROW_NEW.FLEX_CAMPO_02 = 'não') OR (P_ROW_NEW.FLEX_CAMPO_02 = 'NÃO') THEN

         P_ROW_NEW.FLEX_CAMPO_02 := 'NAO';

      END IF;
    END IF;
  END IF;
  --Bernardo 04/08/2015 Fim

 --Bernardo 13/07/2015 Início
 if (P_INSERTING or P_UPDATING) and (v_nome_transacao IN ('Ingresso'))  then

   BEGIN
     SELECT FLEX_CAMPO_09
     INTO V_FLEX_CAMPO_09
     FROM ERG_INGRESSO
     WHERE NUMFUNC = P_ROW_NEW.NUMFUNC
     AND NUMVINC = P_ROW_NEW.NUMERO;
   EXCEPTION
     WHEN OTHERS THEN
       V_FLEX_CAMPO_09 := NULL;
   END;

   PCK_VINCULOS.V_ROW_NEW.FLEX_CAMPO_05 := V_FLEX_CAMPO_09;

   if PCK_VINCULOS.V_ROW_NEW.CATEGORIA
      in ('01 MAGISTERIO')
      and PCK_VINCULOS.V_ROW_NEW.FLEX_CAMPO_05 is null then

        P_MENS := 'Para vínculos da educação é necessário informar a disciplina';

   end if;

 end if;
 --Bernardo 13/07/2015 Fim

-- RETURN TRUE;

  -- O seguinte trecho é feito para que na hora em que seja gerado um vínculo pela tela de Ingresso
  -- seja carregada a SUBESPECIALIDADE utilizando os dados inseridos pela tela na tabela ERG_INGRESSO
  -- campos FLEX_CAMPO_09 e FLEX_CAMPO_10.
  -- Bernardo Cámera, 23/10/2014.
   IF ((p_inserting) OR (p_updating)) AND (v_nome_transacao IN ('Ingresso')) THEN
     BEGIN
      SELECT FLEX_CAMPO_09,
             FLEX_CAMPO_10
      INTO   V_COD_SUBESP,
             V_DESC_SUBESP
      FROM   ERG_INGRESSO
      WHERE  NUMFUNC = P_ROW_NEW.NUMFUNC
        AND  NUMVINC = P_ROW_NEW.NUMERO;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
             V_COD_SUBESP := NULL;
             V_DESC_SUBESP := NULL;
        WHEN TOO_MANY_ROWS THEN
             V_COD_SUBESP := NULL;
             V_DESC_SUBESP := NULL;
        WHEN OTHERS THEN
             P_MENS := 'Erro não esperado GRJ_EPB__VINCULOS (1): '||sqlerrm(sqlcode);
             RETURN(TRUE);
      END;

      V_SUBESP := V_COD_SUBESP || ' - ' || V_DESC_SUBESP;

      BEGIN
       /* SGD-1469
       UPDATE VINCULOS
       SET FLEX_CAMPO_18 = V_SUBESP
       WHERE  NUMFUNC = P_ROW_NEW.NUMFUNC
       AND   NUMERO = P_ROW_NEW.NUMERO;
       */
       P_ROW_NEW.FLEX_CAMPO_18 := V_SUBESP; --SGD-1469
      EXCEPTION
       WHEN OTHERS THEN
            P_MENS := 'Erro não esperado GRJ_EPB__VINCULOS (2): '||sqlerrm(sqlcode);
            RETURN(TRUE);

      END;
   END IF;
  ---
  --SGD-875 05/02/2015 Bernardo Cámera Início
  /*
  IF (P_INSERTING or P_UPDATING) AND V_NOME_TRANSACAO = 'Vínculo' then
   IF P_ROW_NEW.FLEX_CAMPO_41 IS NOT NULL AND P_ROW_NEW.FLEX_CAMPO_44 IS NOT NULL THEN

    BEGIN
     SELECT DTPOSSE
     INTO v_data_posse
     FROM VINCULOS
     WHERE NUMFUNC = P_ROW_NEW.NUMFUNC
     AND NUMERO = P_ROW_NEW.FLEX_CAMPO_44;
    EXCEPTION
     WHEN NO_DATA_FOUND THEN P_MENS := 'NO_DATA_FOUND';
     WHEN TOO_MANY_ROWS THEN
       BEGIN
          P_MENS := 'Muitas datas de posse anterior';
       END;
     WHEN OTHERS THEN P_MENS := SQLCODE || SUBSTR(SQLERRM, 1, 50);
    END;


    IF (TRUNC(TO_DATE(P_ROW_NEW.FLEX_CAMPO_41,'DD/MM/YYYY')) != TRUNC(v_data_posse)) THEN
       P_MENS := '1: FLEX_CAMPO_41 :'||P_ROW_NEW.FLEX_CAMPO_41||' v_data_posse : '||to_char(v_data_posse,'DD/MM/YYYY')||
                 ' FLEX_CAMPO_44 :'||P_ROW_NEW.FLEX_CAMPO_44;
       --P_MENS := 'A data de posse não condiz com o vínculo informado..|';
    END IF;

   END IF;
  END IF;
  */
   --SGD-875 05/02/2015 Bernardo Cámera Fim

  --Bernardo 30/06/2015 Início
  IF ((p_inserting) OR (p_updating)) AND (v_nome_transacao IN ('Ingresso')) THEN

   --Pego os codigos de atividade e disciplina da erg_ingresso

    BEGIN
      SELECT E.FLEX_CAMPO_01,
             E.FLEX_CAMPO_09
      INTO   V_CODIGO_ATIVIDADE,
             V_CODIGO_DISCIPLINA
      FROM ERG_INGRESSO E
       WHERE E.NUMFUNC = P_ROW_NEW.NUMFUNC
         AND E.NUMVINC = P_ROW_NEW.NUMERO;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        V_CODIGO_ATIVIDADE := NULL;
        V_CODIGO_DISCIPLINA := NULL;
      WHEN OTHERS THEN
        V_CODIGO_ATIVIDADE := NULL;
        V_CODIGO_DISCIPLINA := NULL;
    END;

   --Pego a descrição da Atividade
   IF V_CODIGO_ATIVIDADE IS NOT NULL THEN
    BEGIN
     SELECT NOME
     INTO V_DESCRICAO_ATIVIDADE
     FROM RH_ATIVIDADE_ A
     WHERE A.CODIGO = V_CODIGO_ATIVIDADE;
    EXCEPTION
     WHEN OTHERS THEN
       P_MENS := 'Erro não esperado ao tentar recuperar a descrição da atividade: '||sqlerrm;
       RETURN(TRUE);
    END;
   END IF;
   --Pego a descrição da Disciplina
   IF V_CODIGO_DISCIPLINA IS NOT NULL THEN
    BEGIN
      SELECT DESCRICAO
      INTO V_DESCRICAO_DISCIPLINA
      FROM RH_DISCIPLINAS D
      WHERE D.DISCIPLINA = V_CODIGO_DISCIPLINA;
    EXCEPTION
      WHEN OTHERS THEN
       P_MENS := 'Erro não esperado ao tentar recuperar a descrição da disciplina: '||sqlerrm;
       RETURN(TRUE);
    END;
   END IF;

    --Concateno códigos de atividade e disciplina com as respectivas descrições.
    IF V_CODIGO_ATIVIDADE IS NOT NULL THEN
       P_ROW_NEW.FLEX_CAMPO_04 := V_CODIGO_ATIVIDADE || '-' || V_DESCRICAO_ATIVIDADE;
    END IF;

    IF V_CODIGO_DISCIPLINA IS NOT NULL THEN
        P_ROW_NEW.FLEX_CAMPO_05 := V_CODIGO_DISCIPLINA || '-' || V_DESCRICAO_DISCIPLINA;
    END IF;
  END IF;
  --Bernardo 30/06/2015 Fim

  -- Trecho abaixo inserido para incluir uma crítica alertando ao usuário a exclusão de campos
  -- caso o altere o FLEX_CAMPO_02 para NAO. Permitindo somente quando comfirmar, colocando SIM no FLEX_CAMPO_17.
  -- Reinaldo Mesquita, 23/07/2014, SGD 1266
  IF P_UPDATING
  AND V_NOME_TRANSACAO = 'Vínculo'
  AND P_ROW_OLD.FLEX_CAMPO_02 = 'SIM'
  AND P_ROW_NEW.FLEX_CAMPO_02 = 'NAO'
  AND NVL(P_ROW_NEW.FLEX_CAMPO_17,'NAO') <> 'SIM' THEN
    P_MENS := 'É necessario confirmar a alteração do campo: Servidor Estatutário tomando posse sem interrupção e sem acumulação '||CHR(10)||'(essa confirmação irá excluir os dados da aba Vinculo Anterior).';
    RETURN(TRUE);
  END IF;

  IF ((p_inserting) or (p_updating)) AND P_ROW_NEW.FLEX_CAMPO_02 = 'SIM' OR P_ROW_NEW.FLEX_CAMPO_02 IS NULL THEN
    P_ROW_NEW.FLEX_CAMPO_17 := NULL;
  END IF;
  -- fim do trecho referente ao SGD 1266

  -- Trecho abaixo inserido para atender a solicitação de uma crítica para
  -- evitar o ingresso em CONCURSO PUBLICO de servidores com mais de 70 anos
  -- Reinaldo Mesquita, 14/05/2014, SGD 1430
  IF (p_inserting) OR (p_updating AND P_ROW_OLD.TIPOVINC <> P_ROW_NEW.TIPOVINC)
  AND v_nome_transacao IN ('Vínculo','Ingresso') THEN

    BEGIN
      SELECT ITEM1
      INTO V_IDADE_TPVINC
      FROM ITEMTABELA
      WHERE TAB = 'PGOV_TPVINC_IDADEMAX'
      AND ITEM = P_ROW_NEW.TIPOVINC;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        V_IDADE_TPVINC := NULL;
      WHEN OTHERS THEN
        P_MENS := 'Erro não espedado GRJ_EPB__VINCULOS (3): '||sqlerrm(sqlcode);
        RETURN(TRUE);
    END;

    IF V_IDADE_TPVINC IS NOT NULL THEN

      BEGIN
        SELECT TO_NUMBER(TRUNC((MONTHS_BETWEEN(SYSDATE, F.DTNASC))/12))
        INTO V_IDADE_FUNC
        FROM FUNCIONARIOS F
        WHERE F.NUMERO = P_ROW_NEW.NUMFUNC;
      EXCEPTION
        WHEN OTHERS THEN
          P_MENS := 'Erro não espedado GRJ_EPB__VINCULOS (4): '||sqlerrm(sqlcode);
          RETURN(TRUE);
      END;

      IF V_IDADE_FUNC IS NULL THEN
        P_MENS := 'Para fazer o ingresso é necessário preencher a data de nascimento do servidor na tela de DADOS GERAIS';
        RETURN (TRUE);
      ELSE
        IF V_IDADE_FUNC > V_IDADE_TPVINC THEN
          P_MENS := 'Não é permitido fazer o ingresso nesse tipo de vínculo servidor com mais de '||V_IDADE_TPVINC||' anos.';
          RETURN (TRUE);
        END IF;
      END IF;
    END IF;
  END IF;
  -- fim do trecho referente ao SGD 1430
  --
/*
  Quando implantar toda a Administração Direta:
    Devemos verificar se o vinculo é de REQUISICAO INTERNA, deve ser informado o vinculo na origem (FLEX_08).
   O treche de codigo abaixo deve ser liberado para consistencia.

    if p_row_new.tipovinc like 'REQUISICAO EXTERNA' then
      if p_row_new.flex_campo_08 is null then
        p_mens := 'Para Vinculo de REQUISICAO EXTERNA, deve ser informado o Vinculo na Origem!';
      end if;
    end if;
*/





     -- Obrigar o preenchimento dos campos da aba "Requisição/Contrato" em caso de tipovinc = REQUISICAO EXTERNA ou REQUISICAO INTERNA.
     -- Em caso de REQUISICAO INTERNA obrigar o preenchimento do campo Vínculo na Origem (FLEX_08).
     -- Reinaldo Mesquita - 04/10/2013 (SGD 1038)
     IF ((p_inserting) or (p_updating)) and v_nome_transacao = 'Vínculo' THEN




       -- Impedir o ingresso de tipovinc = EFETIVO, ADM ESTAVEL e ADM NAO ESTAVEL
       -- Reinaldo Mesquita - 04/10/2013 (SGD 875)
       if P_ROW_NEW.Tipovinc = 'EFETIVO' and  p_row_new.dtexerc >= to_date('04/09/2013','dd/mm/yyyy') then
         P_MENS := 'Não pode ser realizado o ingressos de servidores EFETIVOS. A partir de 05/10/1988 todo EFETIVO deverá ser cadastrado como CONCURSO PUBLICO.';
         return(true);
       end if;

       if P_ROW_NEW.Tipovinc in('ADM ESTAVEL','ADM NAO ESTAVEL') and  p_row_new.dtexerc >= to_date('04/09/2013','dd/mm/yyyy') then
         P_MENS := 'Não pode ser realizado o ingressos de servidores com Tipo de Vínculo ADM ESTAVEL e ADM NAO ESTAVEL.';
         return(true);
       end if;


       if P_ROW_NEW.Tipovinc = 'REQUISICAO EXTERNA' or P_ROW_NEW.Tipovinc = 'REQUISICAO INTERNA' then

         if P_ROW_NEW.Flex_Campo_06 is null then
           P_MENS := 'Para '||P_ROW_NEW.Tipovinc||' é obrigatório preencher o campo Tipo de Órgão na aba Requisição/Contrato.';
           return(true);
         end if;

         if P_ROW_NEW.Flex_Campo_07 is null then
           P_MENS := 'Para '||P_ROW_NEW.Tipovinc||' é obrigatório preencher o campo Órgão na aba Requisição/Contrato.';
           return(true);
         end if;

         if P_ROW_NEW.Funcao_Req is null then
           P_MENS := 'Para '||P_ROW_NEW.Tipovinc||' é obrigatório preencher o campo Cargo na Origem na aba Requisição/Contrato.';
           return(true);
         end if;

         if P_ROW_NEW.Tipovinc = 'REQUISICAO EXTERNA' then
           if P_ROW_NEW.Tipo_Req <> 'EXTERNA' then
             P_MENS := 'Para REQUISICAO EXTERNA é obrigatório informar o Tipo de Requisição como EXTERNA.';
             return(true);
           end if;
         end if;

         if P_ROW_NEW.Tipovinc = 'REQUISICAO INTERNA' then
           if P_ROW_NEW.Tipo_Req <> 'INTERNA' then
             P_MENS := 'Para REQUISICAO INTERNA é obrigatório informar o Tipo de Requisição como INTERNA.';
             return(true);
           end if;

           -- verifica se o orgão selecionado está no SigRH --
           begin
             select count(1)
             into v_cont_orgao
             from subempresas s, empresas e
             where s.emp_codigo = e.empresa
             and e.flex_campo_05 = 1 -- empresas ativas no SigRH
             and s.nome NOT LIKE 'A DEFINIR%'
             and s.nome = P_ROW_NEW.FLEX_CAMPO_07;
           exception
             when no_data_found then
               v_cont_orgao := 0;
             when others then
               P_MENS := 'Erro não esperado GRJ_EPB__VINCULOS (1): '||sqlerrm(sqlcode);
               RETURN(TRUE);
           end;

           if v_cont_orgao >= 1 and P_ROW_NEW.FLEX_CAMPO_08 is null then
             P_MENS := ' É obrigatório informar o Vínculo na Origem para servidores vindos do Órgão '||P_ROW_NEW.FLEX_CAMPO_07||'.';
             return(true);
           end if;
         end if;
  --bernardo 01/07/2015 Início
  elsif (P_ROW_NEW.tipovinc = 'PLANTAO EXTRA SESDEC') or (P_ROW_NEW.tipovinc = 'FORCA EST DE SAUDE') then

        begin
          select 1
          into v_vinc_
          from vinculos v
          where P_ROW_NEW.NUMFUNC = v.numfunc
          and v.tipovinc in ('EFETIVO', 'CONCURSO PUBLICO','CONTR PRZ INDETERM')
          and v.dtvac is null
          and v.dtaposent is null;
        exception
          when no_data_found then
            v_vinc_ := 0;
          when others then
            v_vinc_ := 0;
        end;



      if v_vinc_ = 1 then

        if P_ROW_NEW.Flex_Campo_06 is null then
          P_MENS := 'Para '||P_ROW_NEW.Tipovinc||' é obrigatório preencher a Origem na aba Requisição/Contrato.';
          return(true);
        end if;

        if P_ROW_NEW.Flex_Campo_07 is null then
          P_MENS := 'Para '||P_ROW_NEW.Tipovinc||' é obrigatório preencher a Origem na aba Requisição/Contrato.';
          return(true);
        end if;

        if P_ROW_NEW.Funcao_Req is null then
          P_MENS := 'Para '||P_ROW_NEW.Tipovinc||' é obrigatório preencher a Origem na aba Requisição/Contrato.';
          return(true);
        end if;
      end if;
  --Bernardo 01/07/2015 Fim

  elsif P_ROW_NEW.Tipovinc not in ('REQUISICAO EXTERNA','REQUISICAO INTERNA','FORCA EST DE SAUDE','PLANTAO EXTRA SESDEC') then --Bernardo

         if P_ROW_NEW.Tipo_Req         is not null
         or P_ROW_NEW.Dtini_Cessao     is not null
         or P_ROW_NEW.Dtfim_Cessao     is not null
         or P_ROW_NEW.Flex_Campo_06    is not null
         or P_ROW_NEW.Flex_Campo_07    is not null
         or P_ROW_NEW.Funcao_Req       is not null
         or P_ROW_NEW.Flex_Campo_08    is not null
         or P_ROW_NEW.Tipo_Onus_Req    is not null
         or P_ROW_NEW.Numfunc_Permut_1 is not null
         or P_ROW_NEW.Numero_Permut_1  is not null
         or P_ROW_NEW.Numfunc_Permut_2 is not null
         or P_ROW_NEW.Numero_Permut_2  is not null
         then
           P_MENS := ' O Bloco Requisição não deve ser preenchido no caso de '||P_ROW_NEW.Tipovinc||'.';
           return(true);
         end if;
       end if;
        -- Ismael Lauro em 19/05/2016 SGD 2791
        -- Incluído o tipo de vínculo PREST TAREFA T CERTO para passar a regra das datas preenchidas
       if P_ROW_NEW.Tipovinc not in ('CONTR TEMPORARIO','PREST TAREFA T CERTO') then
         if P_ROW_NEW.Dtinicontr     is not null
         or P_ROW_NEW.Dtfimcontr     is not null
         or P_ROW_NEW.Dtprorrogcontr is not null
         then
           P_MENS := ' O Bloco Contrato por Tempo Determinado não deve ser preenchido no caso de '||P_ROW_NEW.Tipovinc||'.';
           return(true);
         end if;
       end if;
     END IF;


     -- Tratar o preenchimento do plano previdenciario(flex_16) para os casos de 'ESTATUTO CIVIL' de 'CONCURSO PUBLICO'
     -- Tratar o prenchimento dos campos referentes ao vinculo anterior (flex_40_41_42_43_44)
     -- Reinaldo Mesquita - 10/09/2013 (SGD 875)

     if v_nome_transacao = 'Ingresso' then

       SELECT COUNT(1)
         INTO V_COUNT
         FROM ERG_INGRESSO
        WHERE NUMFUNC = P_ROW_NEW.numfunc
          AND NUMVINC = P_ROW_NEW.numero;

       IF V_COUNT = 1 THEN

        SELECT FLEX_CAMPO_26,
               FLEX_CAMPO_27,
               FLEX_CAMPO_28,
               FLEX_CAMPO_29,
               FLEX_CAMPO_30,
               FLEX_CAMPO_24,
               FLEX_CAMPO_25
          INTO p_row_new.flex_campo_02,
               p_row_new.flex_campo_16,
               p_row_new.flex_campo_40,
               p_row_new.flex_campo_41,
               p_row_new.flex_campo_42,
               p_row_new.flex_campo_43,
               p_row_new.flex_campo_44
          FROM ERG_INGRESSO
         WHERE NUMFUNC = P_ROW_NEW.numfunc
           AND NUMVINC = P_ROW_NEW.numero;

       end if;
     end if;


     if v_nome_transacao = 'Vínculo' or v_nome_transacao = 'Ingresso' then

       if p_row_new.regimejur = 'ESTATUTO CIVIL' and p_row_new.tipovinc = 'CONCURSO PUBLICO' then

         --P_MENS := 'Linha 341 FLEX_CAMPO_41 :'||P_ROW_NEW.FLEX_CAMPO_41||' FLEX_CAMPO_44 :'||P_ROW_NEW.FLEX_CAMPO_44
         --            ||' dtexerc :'||p_row_new.dtexerc;

         if p_row_new.dtexerc >= to_date('04/09/2013','dd/mm/yyyy') then

           --P_MENS := 'Linha 345 FLEX_CAMPO_41 :'||P_ROW_NEW.FLEX_CAMPO_41||' FLEX_CAMPO_44 :'||P_ROW_NEW.FLEX_CAMPO_44;


           if p_row_new.flex_campo_02 is null then
             p_mens := 'É obrigatório informar se o funcionário teve vínculo estatutário anterior!';
             RETURN (TRUE);

           elsif p_row_new.flex_campo_02 = 'NAO' then

             --P_MENS := 'Linha 353';

             p_row_new.flex_campo_16 := 'RIOPREV PREVID';
             p_row_new.flex_campo_40 := null;
             p_row_new.flex_campo_41 := null;
             p_row_new.flex_campo_42 := null;
             p_row_new.flex_campo_43 := null;
             p_row_new.flex_campo_44 := null;


           else

             --P_MENS := 'Linha 365';

             if p_row_new.flex_campo_42 is null then
               p_mens := 'É necessário informar se teve ou não Previdência Complementar no Vínculo Ininterrúpto.';
               RETURN (TRUE);
             end if;

             if p_row_new.flex_campo_43 is null then
               p_mens := 'É necessário informar o Tipo de Órgão do Vínculo Ininterrúpto.';
               RETURN (TRUE);
             end if;

             if p_row_new.flex_campo_40 is null then
               p_mens := 'É necessário informar Órgão do Vínculo Ininterrúpto.';
               RETURN (TRUE);
             end if;

             if p_row_new.flex_campo_41 is null then
               p_mens := 'É necessário informar a Data de Posse do Vínculo Ininterrúpto.';
               RETURN (TRUE);
             end if;


             if P_ROW_NEW.flex_campo_43 in ('ADMINISTRACAO DIRETA','FUNDACAO','AUTARQUIA','EMPRESA','COMPANHIA')
                AND p_row_new.flex_campo_44 is null then
                    p_mens := 'O Número do Vínculo Ininterrúpto deve ser informado.';
                    RETURN (TRUE);
             end if;

             -- Verificando se o campo Tipo de Orgão(flex_43) corresponde ao campo Orgão Anterior(flex_40)
             -- Alteração realizada para atender a demanda acrescentada ao SGD 875 no dia 21/01/2014
             -- Reinaldo Mesquita - 21/01/2014 (SGD 875)
             
             -- Alterado por Giselle da Silva em 22/02/2016  SGD 2635  
             -- Fazer a verificação do órgão anterior separadamente para ADMINSTRAÇÃO DIRETA e FUNDAÇÃO/AUTARQUIA           
             if P_ROW_NEW.flex_campo_43 = 'ADMINISTRACAO DIRETA' then 

               begin
                 select sum(a.orgao) into v_cont_orgao_ant from (
                   SELECT 1 orgao
                   FROM subempresas se, empresas e, itemtabela it
                   WHERE se.nome NOT LIKE 'A DEFINIR%'
                   AND se.emp_codigo = e.empresa
                   AND e.flex_campo_04 = p_row_new.flex_campo_43
                   AND it.item = e.flex_campo_04
                   AND it.tab = 'GRJ_TIPO_ORGAO_EXT'
                   AND it.item1 = 'INTERNO'
                   and se.nome = p_row_new.flex_campo_40
                   UNION ALL
                   SELECT 1 orgao
                   FROM orgaos_externos oe
                   WHERE oe.flex_campo_01 = p_row_new.flex_campo_43
                   and oe.descr = p_row_new.flex_campo_40)a ;
               exception                 
                 WHEN OTHERS THEN
                   P_MENS := 'Erro não esperado GRJ_EPB__VINCULOS (6): '||sqlerrm(sqlcode);
                   RETURN(TRUE);
               end;

               if v_cont_orgao_ant = 0 or v_cont_orgao_ant is null then
                 p_mens := 'O Campo Orgão Anterior não está de acordo com o Tipo de Orgão selecionado - 20.';
                 RETURN (TRUE);
               end if;

           --  end if;
           
           elsif P_ROW_NEW.flex_campo_43 in ('FUNDACAO','AUTARQUIA') then
           
             begin
                   select sum(a.orgao) into v_cont_orgao_ant from (
                     SELECT 1 orgao
                     FROM empresas e, itemtabela it
                     WHERE e.flex_campo_04 = p_row_new.flex_campo_43
                     AND it.item = e.flex_campo_04
                     AND it.tab = 'GRJ_TIPO_ORGAO_EXT'
                     AND it.item1 = 'INTERNO'
                     and e.nome = p_row_new.flex_campo_40
                     UNION ALL
                     SELECT 1 orgao
                     FROM orgaos_externos oe
                     WHERE oe.flex_campo_01 = p_row_new.flex_campo_43
                     and oe.descr = p_row_new.flex_campo_40)a ;
                 exception                   
                   WHEN OTHERS THEN
                     P_MENS := 'Erro não esperado GRJ_EPB__VINCULOS (7): '||sqlerrm(sqlcode);
                     RETURN(TRUE);
                 end;

                 if v_cont_orgao_ant = 0 or v_cont_orgao_ant is null then
                   p_mens := 'O Campo Orgão Anterior não está de acordo com o Tipo de Orgão selecionado - 30.';
                   RETURN (TRUE);
                 end if;        
           end if; -- Fim da validação do campo do vínculo estatutário anterior
           -- Fim Giselle
           
             /*
             begin
               select sum(a.orgao) into v_cont_orgao_ant from (
                 SELECT 1 orgao
                 FROM subempresas se, empresas e, itemtabela it
                 WHERE se.nome NOT LIKE 'A DEFINIR%'
                 AND se.emp_codigo = e.empresa
                 AND e.flex_campo_04 = p_row_new.flex_campo_43
                 AND it.item = e.flex_campo_04
                 AND it.tab = 'GRJ_TIPO_ORGAO_EXT'
                 AND it.item1 = 'INTERNO'
                 and se.nome = p_row_new.flex_campo_40
                 UNION ALL
                 SELECT 1 orgao
                 FROM orgaos_externos oe
                 WHERE oe.flex_campo_01 = p_row_new.flex_campo_43
                 and oe.descr = p_row_new.flex_campo_40)a ;
             exception
               when no_data_found then
                 p_mens := 'O Campo Orgão Anterior não está de acordo com o Tipo de Orgão selecionado.';
                 return (true);
               WHEN OTHERS THEN
                 P_MENS := 'Erro não esperado GRJ_EPB__VINCULOS (6): '||sqlerrm(sqlcode);
                 RETURN(TRUE);
             end;

             if v_cont_orgao_ant = 0 or v_cont_orgao_ant is null then
               p_mens := 'O Campo Orgão Anterior não está de acordo com o Tipo de Orgão selecionado.';
               RETURN (TRUE);
             end if;*/

           end if;

           else

           --Controle de se possui atributo ou não
                   begin
                     select 1
                     into v_count
                     from vantagens
                     where numfunc = P_ROW_NEW.numfunc
                     and numvinc = P_ROW_NEW.numero
                     and vantagem IN ('RJPREV FACUL PL FIN', 'RJPREV PATROCINADA')
                     and dtfim is null;
                    exception
                     when no_data_found then
                       v_count := 0;
                     when too_many_rows then
                       v_count := 1;
                     when others then
                       v_count := 0;
                   end;

                   if v_count = 1 then
                     P_MENS := 'Os atributos de Previdência Complementar devem ser fechados para que o plano possa ser alterado';
                     RETURN(TRUE);
                   end if;

            --setar regra antiga de plano previdenciario no flex_16--
                         BEGIN
              select DECODE (planoprev_padrao, 'RPPS', 'RIOPREV FINANC', planoprev_padrao)
                into p_row_new.flex_campo_16
                from erg_tipovinc_valid t,
                -- Incluído por Giselle da Silva em 20/06/2016 / SGD 2840
                     erg_tipovinc_valid_empresa te
               where t.tipovinc = te.tipovinc
                 and t.categoria = te.categoria
                 and t.regimejur = te.regimejur
                 and te.empresa   = flag_pack.get_empresa
              --
                 and t.tipovinc  = p_row_new.TIPOVINC
                 and t.regimejur = p_row_new.REGIMEJUR
                 and t.categoria = p_row_new.CATEGORIA;
            EXCEPTION
              when no_data_found then
                p_row_new.flex_campo_16 := NULL;
              when others then
                P_MENS := 'Erro não esperado GRJ_EPB__VINCULOS (2): '||sqlerrm(sqlcode);
                RETURN(TRUE);
            END;


           p_row_new.flex_campo_02 := null;
           p_row_new.flex_campo_40 := null;
           p_row_new.flex_campo_41 := null;
           p_row_new.flex_campo_42 := null;
           p_row_new.flex_campo_43 := null;
           p_row_new.flex_campo_44 := null;

             --null;

             --P_MENS := 'Linha 488';

             /*
             p_row_new.flex_campo_02 := null;
             p_row_new.flex_campo_16 := 'RIOPREV FINANC';
             p_row_new.flex_campo_40 := null;
             p_row_new.flex_campo_41 := null;
             p_row_new.flex_campo_42 := null;
             p_row_new.flex_campo_43 := null;
             p_row_new.flex_campo_44 := null;
             */

           end if;

         else

           --veio pelo else
           --P_MENS := 'Else Linha 493 FLEX_CAMPO_41 :'||P_ROW_NEW.FLEX_CAMPO_41||' FLEX_CAMPO_44 :'||P_ROW_NEW.FLEX_CAMPO_44;


         --setar regra antiga de plano previdenciario no flex_16--
          --P_MENS := 'Entrou na parte de JUD EST e Órgão RJ 2';
          --     RETURN (TRUE);

            BEGIN
              select DECODE (planoprev_padrao, 'RPPS', 'RIOPREV FINANC', planoprev_padrao)
                into p_row_new.flex_campo_16
                from erg_tipovinc_valid
               where tipovinc  = p_row_new.TIPOVINC
                 and regimejur = p_row_new.REGIMEJUR
                 and categoria = p_row_new.CATEGORIA;
            EXCEPTION
              when no_data_found then
                p_row_new.flex_campo_16 := NULL;
              when others then
                P_MENS := 'Erro não esperado GRJ_EPB__VINCULOS (2): '||sqlerrm(sqlcode);
                RETURN(TRUE);
            END;


           --P_MENS := 'Linha 505 FLEX_CAMPO_41 :'||P_ROW_NEW.FLEX_CAMPO_41||' FLEX_CAMPO_44 :'||P_ROW_NEW.FLEX_CAMPO_44;

           /* --Comentado SGD-875 Bernardo Cámera
           p_row_new.flex_campo_02 := null;
           p_row_new.flex_campo_40 := null;
           p_row_new.flex_campo_41 := null;
           p_row_new.flex_campo_42 := null;
           p_row_new.flex_campo_43 := null;
           p_row_new.flex_campo_44 := null;
           */
       end if;

     end if;

 --    P_MENS := 'Linha 535 FLEX_CAMPO_41 :'||P_ROW_NEW.FLEX_CAMPO_41||' FLEX_CAMPO_44 :'||P_ROW_NEW.FLEX_CAMPO_44;


     -- Permitir que seja atribuida uma vacância, mesmo que o tipo de pagamento seja ESPEC, SEMCC ou a conta corrente incorreta
     -- mas impedir remover a vacância sem antes acertar tipo de pagamento e a conta-corrente.
     -- Reinaldo Mesquita - 14/08/2013 (SGD 955)
     if v_nome_transacao IN ('Vacância','Instituidor de Pensão') then

       if p_row_new.dtvac is null then -- quando remove uma vacância:

         if p_row_new.TIPOPAG = 'ESPEC' then
           -- Impede atualização de tipo de pagamento em espécie na tela de cadstro de vínculo
           -- Tarefa no Attask - CRIAR TIPO PAG "CONTA SALÁRIO"
           -- Rodrigo Machado - 24/08/2012
           p_mens := 'Não é mais possível atualizar registros como Espécie! 002';
           RETURN (TRUE);
         end if;

         /*
         if p_row_new.TIPOPAG = 'SEMCC' then

           BEGIN
             SELECT COUNT(1)
             INTO V_TEM_REPR_LEGAL
             FROM ERG_FUNC_REPR FR, ERG_REPRES_LEGAL RL
             WHERE FR.NUMREP = RL.NUMERO
             AND P_ROW_NEW.NUMFUNC = FR.NUMFUNC
             AND SYSDATE BETWEEN FR.DTINI AND NVL(FR.DTFIM, PACK_ERGON.DATA_MAXIMA)
             AND FR.RECEBE_CREDITO = 'S'
             AND RL.CONTA IS NOT NULL;
           EXCEPTION
             WHEN OTHERS THEN
               V_TEM_REPR_LEGAL := 0;
           END;

           IF V_TEM_REPR_LEGAL = 0 THEN
             p_mens := 'Funcionario não possui conta corrente válida ou representante legal com conta corrente válida.';
             RETURN (TRUE);
           END IF;

         END IF;
         */
       end if;

    else

      --Libera para quando o servidor tiver a liberação para pagar em ESPEC
       if NVL(p_row_new.flex_campo_13,'NAO') <> 'SIM' then

         if p_row_new.TIPOPAG = 'ESPEC' then
           -- Impede atualização de tipo de pagamento em espécie na tela de cadstro de vínculo
           -- Tarefa no Attask - CRIAR TIPO PAG "CONTA SALÁRIO"
           -- Rodrigo Machado - 24/08/2012
           p_mens := 'Não é mais possível atualizar registros como Espécie 10012!';
           RETURN (TRUE);
         end if;

       end if;

         -- Validação do dígito da conta corrente do banco Itau
         -- Dagoberto 09/05/2011
         --Modificado por Rodrigo Machado em 06/07/2015, coloquei o NVL abaixo,
         --pois sem ele não estava entrando na validação. SGD 2130
         IF p_row_new.banco IS NOT NULL AND NVL(p_row_new.formavac,'XXXXX') <> 'FALECIMENTO' THEN
            --TGRJ_VALIDA_CC (p_row_new.banco,p_row_new.agencia, p_row_new.conta, p_row_new.tipopag);

            IF P_ROW_NEW.Conta is null and P_ROW_NEW.FLEX_CAMPO_20 IS NULL and P_ROW_NEW.Tipopag IN ('CONTA','POUPA') then
              p_mens := 'Tipo de conta for CONTA ou POUPA, é obrigatório o preenchimento do campo Conta ou Conta Salário.' ;
            ELSE
               IF P_ROW_NEW.Conta is NOT null THEN
                  TGRJ_VALIDA_CC (p_row_new.banco,p_row_new.agencia,P_ROW_NEW.Conta, p_row_new.tipopag);
             --     RETURN (TRUE); linha comentada de acordo com solicitação do SGD 2151 05/08/2015
               END IF;
               IF P_ROW_NEW.FLEX_CAMPO_20 IS NOT NULL THEN
                 TGRJ_VALIDA_CC (p_row_new.banco,p_row_new.flex_campo_19,P_ROW_NEW.FLEX_CAMPO_20, p_row_new.tipopag);
               END IF;
            END IF;

         END IF;
    end if;

    -- Horácio - 31/03/2011 - Transferi para o EPB em 08/04/2011 pois no EPA não estava atualizando a dt_pgto_ate
    -- verificar se esta havendo atualização na data de vacancia
    -- Inclui separado pois haviam varios vinculos sem data de pagamento até
    -- A idéia é que isto não ocorra mais.
    IF (p_row_new.dtvac IS NOT NULL AND p_row_old.dtvac IS NULL) OR (p_row_new.dtvac IS NOT NULL AND p_row_old.dtvac IS NOT NULL AND p_row_new.dtvac <> p_row_old.dtvac) THEN
      -- Seta a data de pagamento até dois meses depois da vacância para o servidor
      p_row_new.dt_pgto_ate := last_day(add_months(sysdate,2));
    END IF;
    --
    -- Horácio em 17/10/2011 - Incluir teste para verificar se está sendo informada aposentadoria e o servidor
    -- possui evento de comissionado aberto;
    --
    if  p_updating and p_row_new.dtaposent is not null and p_row_old.dtaposent is null then
      begin
        select sum(1)
        into v_tem_comis
        from evento_func
        where numfunc = p_row_new.numfunc
        and numvinc = p_row_new.numero
        and tipoevento in ('PROV CARGO COMISSAO','DESIG FUNCAO')
        AND DTINI <= P_ROW_NEW.DTAPOSENT
        AND NVL(DTFIM, PACK_HADES.DATA_MAXIMA) > P_ROW_NEW.DTAPOSENT;
      exception
      when others then
        v_tem_comis := 0;
      end;
      if  v_tem_comis > 0 then
        p_mens := 'Encerre primeiro o Evento Comissionado antes de informar Aposentadoria!';
        RETURN (TRUE);
      end if;
    end if;
    --
    --

    IF (p_inserting) OR (p_updating) THEN
      --
      -- Campo Matricula1 se tiver nula inserir o valor que esta no campo Flex_02 do erg_ingresso
      -- KARYNA 12/05/2010
      IF p_row_new.matricula1 IS NULL THEN
        BEGIN
          SELECT flex_campo_02
          INTO v_flex_campo_02
          FROM erg_ingresso
          WHERE numfunc = p_row_new.numfunc
          AND numvinc   = p_row_new.numero;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
          v_flex_campo_02 := NULL;
        WHEN OTHERS THEN
          P_MENS := 'Erro não espedado GRJ_EPB__VINCULOS (9): '||sqlerrm(sqlcode);
          RETURN(TRUE);
        END;
        IF v_flex_campo_02     IS NOT NULL THEN
          --p_row_new.matricula1 := v_flex_campo_02; --SGD-1678
          p_row_new.matricula1 := UPPER(v_flex_campo_02); --SGD-1678
        END IF;
      END IF;

      --SGD-1678 Bernardo 01/10/2014 Início
      IF p_row_new.matricula1 IS NOT NULL THEN
         V_MATRICULA1_AUX := p_row_new.matricula1;
         p_row_new.matricula1 := UPPER(V_MATRICULA1_AUX);
      END IF;
      --SGD-1678 Bernardo 01/10/2014 Fim

      -- Validação do PISPASEP
      --
      BEGIN
        SELECT 1
        INTO V_NAO_TEMP_PASEP
        FROM FUNCIONARIOS
        WHERE NUMERO   = p_row_new.numfunc
        AND (PISPASEP IS NULL
        OR PISPASEP    = 0);
        --
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        V_NAO_TEMP_PASEP := NULL;
      WHEN OTHERS THEN
        P_MENS := 'Erro não espedado GRJ_EPB__VINCULOS (10): '||sqlerrm(sqlcode);
        RETURN(TRUE);
      END;
      --
      -- De acordo com o SGD 764, Foi solicitado pela vera o tratamento do perfil PRIVILEG_LIVRE. Feito por: Bruno Leal
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
        WHEN OTHERS THEN
          P_MENS := 'Erro não espedado GRJ_EPB__VINCULOS (11): '||sqlerrm(sqlcode);
          RETURN(TRUE);
      END;

      IF V_PRIVILEG_LIVRE = 'N' THEN
        IF V_NAO_TEMP_PASEP = 1 AND PACK_HADES.GET_OPCAO('C_Ergon','GOVRJ','PIS_EXIGE') = 'S'
            and  NOT (P_ROW_NEW.DTAPOSENT IS NOT NULL OR
                      P_ROW_NEW.DTVAC IS NOT NULL OR
                      P_ROW_NEW.REGIMEJUR IN ('LEIS DE PENSAO','LEIS PENSAO ESPECIAL','PENSAO ESPECIAL')
                      )
        THEN
          p_mens           := 'O PIS/PASEP do servidor é obrigatório.' ||' Cadastre primeiro o PISPASEP na tela de Funcionários para ' ||'depois incluir o Vinculo.';
        END IF;
      END IF;

      --
      -- Ricardo Nunes em 21/09/2012 - Todo Vinculo deverá ter a informação do Banco Padrao,
      -- mesmo que o TIPOPAG = SEMCC ou ESPEC.
      --
      IF p_row_new.banco IS NULL THEN
         p_row_new.banco := pack_hades.get_opcao('C_Ergon', 'GOVRJ', 'BANCO_PADRAO');
      END IF;
      --
      --Modificação solicitada de acordo com o SGD 1499
      --Permitir cadastramento do vinculo PREST TAREFA T CERTO somente para servidor que tenham
      --outro vínculo de CONCURSO PUBLICO ou EFETIVO e que esteja inativado.

      /*IF P_ROW_NEW.Tipovinc = 'PREST TAREFA T CERTO' THEN

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
         END IF;

      END IF;*/


    END IF;
    --
    -- Gera a matricula para o SAPE
    -- Dagoberto 27/01/2011
    --
    IF (p_inserting) and p_row_new.matricula is null then--Alteracao conforme pedido de Horacio para acertar a gravação da matricula.25/03/2013.
      p_row_new.matricula := tgrj_calc_digito_mod10 (pack_hades.get_numero ('SAPE', 0));
      p_row_new.matricula := pack_hades.formata_mascara(p_row_new.matricula,'00-0000000-0');
    END IF;
    --
    --
    -- Este procedimento foi adicionado para evitar matrícula nula vinda do ingresso.
    -- Isto ocorria quando o servidor já tinha vínculo cadastrado mas não tinha evento
    -- ainda. O campo matricula que vinha do form vinha nulo e sobrescrevia a tabela.
    --
    IF (p_updating) AND p_row_new.matricula IS NULL THEN
      p_row_new.matricula                   := p_row_old.matricula;
    END IF;
    --
    IF (p_row_new.dtexerc > SYSDATE) OR (p_row_new.dtnom > SYSDATE) OR (p_row_new.dtposse > SYSDATE) THEN
      p_mens             := 'Não são permitidos lançamentos futuros.';
    END IF;

    --

    IF ((p_inserting) OR (p_updating)) THEN
       --0--
       BEGIN

         SELECT 1
         INTO v_existe_categoria
         FROM rh_atividade_ a
         WHERE EXISTS (
              SELECT 1
              FROM rh_ativ_cargo rh,
                   cargos_ c
              WHERE PCK_VINCULOS.V_ROW_NEW.CATEGORIA = c.categoria
              AND rh.cargo = c.cargo
              AND a.codigo = rh.atividade
             )
          AND a.flex_campo_02 IN ('INGRESSO','ING/EXEC');
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
               v_existe_categoria := 0;
          WHEN OTHERS THEN
               v_existe_categoria := 0;
        END;


     IF (v_existe_categoria = 1) AND (PCK_VINCULOS.V_ROW_NEW.FLEX_CAMPO_04 IS NULL) THEN

        P_MENS := 'Para esta Categoria do Vínculo é Necessário informar a Atividade/Especialidade.';

     END IF;



    END IF;


    --Inserido por Rodrigo Machado em 13/05/2016 para atender o SGD 2721 conforme regra
    -- Não permitir período entre a data início e fim superior a 2 anos e a data início e prorrogação superior a 3 anos.
    IF P_INSERTING or P_UPDATING AND P_ROW_NEW.TIPOVINC = 'CONTR TEMPORARIO' THEN

      SELECT COUNT(1)
       INTO V_COUNT
       FROM VINCULOS VI
      WHERE VI.NUMFUNC = P_ROW_NEW.NUMFUNC
        AND VI.TIPOVINC = 'CONTR TEMPORARIO'
        AND nvl(VI.DTFIMCONTR,pack_hades.DATA_MAXIMA) >= P_ROW_NEW.DTINICONTR
        AND VI.NUMERO <> P_ROW_NEW.NUMERO;

      IF V_COUNT > 0 THEN

        P_MENS := 'Já existe pelo menos um CONTRATO TEMPORARIO em aberto no período, não é permitido ter dois CONTRATOS TEMPORARIOS acumuláveis.';
        RETURN (TRUE);

      END IF;

      IF P_ROW_NEW.DTEXERC <> NVL(P_ROW_NEW.DTINICONTR,pack_hades.DATA_MAXIMA) THEN

        P_MENS := 'Data de Início do contrato não pode ser diferente da data de exercício.';
        RETURN (TRUE);

      END IF;


      DECLARE
        V_TEMPO NUMBER;
        V_TEMPO_MAXIMO NUMBER;
      BEGIN

        V_TEMPO := NVL(P_ROW_NEW.DTFIMCONTR,pack_hades.DATA_MAXIMA) -  NVL(P_ROW_NEW.DTINICONTR,pack_hades.DATA_MAXIMA);
        V_TEMPO_MAXIMO := add_months(NVL(P_ROW_NEW.DTINICONTR,pack_hades.DATA_MAXIMA),24) - NVL(P_ROW_NEW.DTINICONTR,pack_hades.DATA_MAXIMA);

        IF V_TEMPO > V_TEMPO_MAXIMO THEN
          P_MENS := 'Período de contratação não pode ser superior a 2 anos.';
          RETURN (TRUE);
        END IF;


        V_TEMPO := NVL(P_ROW_NEW.DTPRORROGCONTR,pack_hades.DATA_MAXIMA) -  NVL(P_ROW_NEW.DTINICONTR,pack_hades.DATA_MAXIMA);
        V_TEMPO_MAXIMO := add_months(NVL(P_ROW_NEW.DTINICONTR,pack_hades.DATA_MAXIMA),36) - NVL(P_ROW_NEW.DTINICONTR,pack_hades.DATA_MAXIMA);

         IF V_TEMPO > V_TEMPO_MAXIMO THEN
          P_MENS := 'Período de  prorrogação não pode ser supeiror a 3 anos da data início do contrato.';
          RETURN (TRUE);
        END IF;

       END;

    END IF;

--    IF P_INSERTING or P_UPDATING THEN
      /* Fernando Garatini da Silva
         A verificação abaixo foi desenvolvida com o intuito de não permitir cadastrar um novo vinculo
         para o funcionario que estiver com uma GLP em aberto e com uma carga horária maior do que 12 horas
      */

      /*and ( c.dtvac is null or c.dtvac >= P_DATA)
      and ( c.dtfimcontr is null or c.dtfimcontr >= p_data)
      and ( c.dtaposent is null or c.dtaposent >= p_data)*/
/*
Horácio:

      SELECT SUM(NVL(HORASSEM,0))HORASSEM
         INTO V_JORNADA
         FROM EXERCICIOS
        WHERE ATIVIDADE = 100
          AND DTINI <= NVL(NVL(NVL(P_ROW_NEW.DTAPOSENT,P_ROW_NEW.DTVAC), P_ROW_NEW.DTFIMCONTR),pack_ergon.data_maxima)
          AND NVL(dtfim, pack_ergon.data_maxima) >= P_ROW_NEW.DTEXERC
          AND NUMFUNC = p_row_new.Numfunc
          and numvinc = p_row_new.numero;

      IF V_JORNADA > 12 THEN
         p_mens := 'Funcionário possui GLP maior que 12 horas.';
      END IF;
*/
--    END IF;
     /* Fim Verificação Fernando Garatini da Silva */
     /*
     IF PACK_HADES.GET_OPCAO('Ergon', 'ERGON', 'VAC_AUT') = 'N' THEN
        update had_opcoes_itens
                 set valor = 'S'
               where sis   = 'Ergon'
                 and grupo = 'ERGON'
                 and opcao = 'VAC_AUT' ;
    END IF;
    */
    
    --Incluído por Rodrigo Machado em 10/10/2016 
    --conforme solicitação do SGD 3045
    IF v_nome_transacao = 'Requisição' THEN
      
      IF P_ROW_NEW.TIPO_ONUS_REQ = 'Com Onus' THEN
      
         IF P_ROW_NEW.FLEX_CAMPO_23 IS NULL OR P_ROW_NEW.FLEX_CAMPO_23 <= 0 THEN
         
            P_MENS := 'Quando tipo de ônus for Com Onus, o Valor do Ressarcimento é obrigatório.';  
            RETURN (TRUE);
            
         END IF;
      
      END IF;
    
    END IF;
    
    RETURN (TRUE);

  EXCEPTION
     WHEN OTHERS THEN
           update had_opcoes_itens
                           set valor = 'S'
                         where sis   = 'Ergon'
                           and grupo = 'ERGON'
                           and opcao = 'VAC_AUT' ;

           p_mens := 'Erro não esperado GRJ_EPB__VINCULOS (0): '||sqlerrm(sqlcode);
           return (true) ;
  END;
/	