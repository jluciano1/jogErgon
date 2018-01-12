prompt ***ATEN��O!!!*** Objeto GRJ_EPB__VINCULOS n�o possui replace e deve ser mesclado manualmente com a vers�o existente no banco.
--
--  EP com get_transacao. 
--  N�o altere essa fun��o. Ela dever� ser alterado no cliente.
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

    -- Verifica se o usu�rio � privilegiado --
    select count(1)
    into v_privil
    from usuario
    where usuario = flag_pack.get_usuario
    and privil = 'S';

    -- impedir que usu�rios n�o privilegiados alterem o campo SISOBI (FLEX_CAMPO_11) e
    -- impedir a forma de vac�ncia seja alterada quando SISOBI = 'S'
    -- Reinaldo Mesquita, 21/06/2016, SGD 2841
    if v_nome_transacao in ('Vac�ncia','V�nculo','ERGadm00153', 'ERGadm00229') then
      if (p_inserting) or (p_updating) then
        if v_privil = 0 then
          if P_ROW_NEW.FLEX_CAMPO_11 <> P_ROW_OLD.FLEX_CAMPO_11 then
            p_mens := 'O usu�rio n�o possui permiss�o para alterar o campo SISOBI.';
            return true;
          end if;
          if P_ROW_OLD.FLEX_CAMPO_11 = 'S' then
            if P_ROW_NEW.FORMAVAC <> P_ROW_OLD.FORMAVAC then
              p_mens := 'O usu�rio n�o possui permiss�o para alterar a forma de desligamento de proveniente do SISOBI.';
              return true;
            end if;
          end if;
        end if;
      end if;
    end if;

  --caso exista uma vacancia para clt n�o permite gerar evento de instituidor de pens�o.
 IF P_UPDATING AND flag_pack.get_transacao in ( 'Vac�ncia','ERGadm00153' ) THEN
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

  --Bernardo 04/08/2015 In�cio
  IF (P_INSERTING) OR (P_UPDATING) THEN
    IF P_ROW_NEW.FLEX_CAMPO_02 IS NOT NULL THEN
      IF (P_ROW_NEW.FLEX_CAMPO_02 = 'S') OR (P_ROW_NEW.FLEX_CAMPO_02 = 's') OR (P_ROW_NEW.FLEX_CAMPO_02 = 'sim') THEN

         P_ROW_NEW.FLEX_CAMPO_02 := 'SIM';

      ELSIF (P_ROW_NEW.FLEX_CAMPO_02 = 'N') OR (P_ROW_NEW.FLEX_CAMPO_02 = 'n') OR (P_ROW_NEW.FLEX_CAMPO_02 = 'nao')
         OR (P_ROW_NEW.FLEX_CAMPO_02 = 'n�o') OR (P_ROW_NEW.FLEX_CAMPO_02 = 'N�O') THEN

         P_ROW_NEW.FLEX_CAMPO_02 := 'NAO';

      END IF;
    END IF;
  END IF;
  --Bernardo 04/08/2015 Fim

 --Bernardo 13/07/2015 In�cio
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

        P_MENS := 'Para v�nculos da educa��o � necess�rio informar a disciplina';

   end if;

 end if;
 --Bernardo 13/07/2015 Fim

-- RETURN TRUE;

  -- O seguinte trecho � feito para que na hora em que seja gerado um v�nculo pela tela de Ingresso
  -- seja carregada a SUBESPECIALIDADE utilizando os dados inseridos pela tela na tabela ERG_INGRESSO
  -- campos FLEX_CAMPO_09 e FLEX_CAMPO_10.
  -- Bernardo C�mera, 23/10/2014.
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
             P_MENS := 'Erro n�o esperado GRJ_EPB__VINCULOS (1): '||sqlerrm(sqlcode);
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
            P_MENS := 'Erro n�o esperado GRJ_EPB__VINCULOS (2): '||sqlerrm(sqlcode);
            RETURN(TRUE);

      END;
   END IF;
  ---
  --SGD-875 05/02/2015 Bernardo C�mera In�cio
  /*
  IF (P_INSERTING or P_UPDATING) AND V_NOME_TRANSACAO = 'V�nculo' then
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
       --P_MENS := 'A data de posse n�o condiz com o v�nculo informado..|';
    END IF;

   END IF;
  END IF;
  */
   --SGD-875 05/02/2015 Bernardo C�mera Fim

  --Bernardo 30/06/2015 In�cio
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

   --Pego a descri��o da Atividade
   IF V_CODIGO_ATIVIDADE IS NOT NULL THEN
    BEGIN
     SELECT NOME
     INTO V_DESCRICAO_ATIVIDADE
     FROM RH_ATIVIDADE_ A
     WHERE A.CODIGO = V_CODIGO_ATIVIDADE;
    EXCEPTION
     WHEN OTHERS THEN
       P_MENS := 'Erro n�o esperado ao tentar recuperar a descri��o da atividade: '||sqlerrm;
       RETURN(TRUE);
    END;
   END IF;
   --Pego a descri��o da Disciplina
   IF V_CODIGO_DISCIPLINA IS NOT NULL THEN
    BEGIN
      SELECT DESCRICAO
      INTO V_DESCRICAO_DISCIPLINA
      FROM RH_DISCIPLINAS D
      WHERE D.DISCIPLINA = V_CODIGO_DISCIPLINA;
    EXCEPTION
      WHEN OTHERS THEN
       P_MENS := 'Erro n�o esperado ao tentar recuperar a descri��o da disciplina: '||sqlerrm;
       RETURN(TRUE);
    END;
   END IF;

    --Concateno c�digos de atividade e disciplina com as respectivas descri��es.
    IF V_CODIGO_ATIVIDADE IS NOT NULL THEN
       P_ROW_NEW.FLEX_CAMPO_04 := V_CODIGO_ATIVIDADE || '-' || V_DESCRICAO_ATIVIDADE;
    END IF;

    IF V_CODIGO_DISCIPLINA IS NOT NULL THEN
        P_ROW_NEW.FLEX_CAMPO_05 := V_CODIGO_DISCIPLINA || '-' || V_DESCRICAO_DISCIPLINA;
    END IF;
  END IF;
  --Bernardo 30/06/2015 Fim

  -- Trecho abaixo inserido para incluir uma cr�tica alertando ao usu�rio a exclus�o de campos
  -- caso o altere o FLEX_CAMPO_02 para NAO. Permitindo somente quando comfirmar, colocando SIM no FLEX_CAMPO_17.
  -- Reinaldo Mesquita, 23/07/2014, SGD 1266
  IF P_UPDATING
  AND V_NOME_TRANSACAO = 'V�nculo'
  AND P_ROW_OLD.FLEX_CAMPO_02 = 'SIM'
  AND P_ROW_NEW.FLEX_CAMPO_02 = 'NAO'
  AND NVL(P_ROW_NEW.FLEX_CAMPO_17,'NAO') <> 'SIM' THEN
    P_MENS := '� necessario confirmar a altera��o do campo: Servidor Estatut�rio tomando posse sem interrup��o e sem acumula��o '||CHR(10)||'(essa confirma��o ir� excluir os dados da aba Vinculo Anterior).';
    RETURN(TRUE);
  END IF;

  IF ((p_inserting) or (p_updating)) AND P_ROW_NEW.FLEX_CAMPO_02 = 'SIM' OR P_ROW_NEW.FLEX_CAMPO_02 IS NULL THEN
    P_ROW_NEW.FLEX_CAMPO_17 := NULL;
  END IF;
  -- fim do trecho referente ao SGD 1266

  -- Trecho abaixo inserido para atender a solicita��o de uma cr�tica para
  -- evitar o ingresso em CONCURSO PUBLICO de servidores com mais de 70 anos
  -- Reinaldo Mesquita, 14/05/2014, SGD 1430
  IF (p_inserting) OR (p_updating AND P_ROW_OLD.TIPOVINC <> P_ROW_NEW.TIPOVINC)
  AND v_nome_transacao IN ('V�nculo','Ingresso') THEN

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
        P_MENS := 'Erro n�o espedado GRJ_EPB__VINCULOS (3): '||sqlerrm(sqlcode);
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
          P_MENS := 'Erro n�o espedado GRJ_EPB__VINCULOS (4): '||sqlerrm(sqlcode);
          RETURN(TRUE);
      END;

      IF V_IDADE_FUNC IS NULL THEN
        P_MENS := 'Para fazer o ingresso � necess�rio preencher a data de nascimento do servidor na tela de DADOS GERAIS';
        RETURN (TRUE);
      ELSE
        IF V_IDADE_FUNC > V_IDADE_TPVINC THEN
          P_MENS := 'N�o � permitido fazer o ingresso nesse tipo de v�nculo servidor com mais de '||V_IDADE_TPVINC||' anos.';
          RETURN (TRUE);
        END IF;
      END IF;
    END IF;
  END IF;
  -- fim do trecho referente ao SGD 1430
  --
/*
  Quando implantar toda a Administra��o Direta:
    Devemos verificar se o vinculo � de REQUISICAO INTERNA, deve ser informado o vinculo na origem (FLEX_08).
   O treche de codigo abaixo deve ser liberado para consistencia.

    if p_row_new.tipovinc like 'REQUISICAO EXTERNA' then
      if p_row_new.flex_campo_08 is null then
        p_mens := 'Para Vinculo de REQUISICAO EXTERNA, deve ser informado o Vinculo na Origem!';
      end if;
    end if;
*/





     -- Obrigar o preenchimento dos campos da aba "Requisi��o/Contrato" em caso de tipovinc = REQUISICAO EXTERNA ou REQUISICAO INTERNA.
     -- Em caso de REQUISICAO INTERNA obrigar o preenchimento do campo V�nculo na Origem (FLEX_08).
     -- Reinaldo Mesquita - 04/10/2013 (SGD 1038)
     IF ((p_inserting) or (p_updating)) and v_nome_transacao = 'V�nculo' THEN




       -- Impedir o ingresso de tipovinc = EFETIVO, ADM ESTAVEL e ADM NAO ESTAVEL
       -- Reinaldo Mesquita - 04/10/2013 (SGD 875)
       if P_ROW_NEW.Tipovinc = 'EFETIVO' and  p_row_new.dtexerc >= to_date('04/09/2013','dd/mm/yyyy') then
         P_MENS := 'N�o pode ser realizado o ingressos de servidores EFETIVOS. A partir de 05/10/1988 todo EFETIVO dever� ser cadastrado como CONCURSO PUBLICO.';
         return(true);
       end if;

       if P_ROW_NEW.Tipovinc in('ADM ESTAVEL','ADM NAO ESTAVEL') and  p_row_new.dtexerc >= to_date('04/09/2013','dd/mm/yyyy') then
         P_MENS := 'N�o pode ser realizado o ingressos de servidores com Tipo de V�nculo ADM ESTAVEL e ADM NAO ESTAVEL.';
         return(true);
       end if;


       if P_ROW_NEW.Tipovinc = 'REQUISICAO EXTERNA' or P_ROW_NEW.Tipovinc = 'REQUISICAO INTERNA' then

         if P_ROW_NEW.Flex_Campo_06 is null then
           P_MENS := 'Para '||P_ROW_NEW.Tipovinc||' � obrigat�rio preencher o campo Tipo de �rg�o na aba Requisi��o/Contrato.';
           return(true);
         end if;

         if P_ROW_NEW.Flex_Campo_07 is null then
           P_MENS := 'Para '||P_ROW_NEW.Tipovinc||' � obrigat�rio preencher o campo �rg�o na aba Requisi��o/Contrato.';
           return(true);
         end if;

         if P_ROW_NEW.Funcao_Req is null then
           P_MENS := 'Para '||P_ROW_NEW.Tipovinc||' � obrigat�rio preencher o campo Cargo na Origem na aba Requisi��o/Contrato.';
           return(true);
         end if;

         if P_ROW_NEW.Tipovinc = 'REQUISICAO EXTERNA' then
           if P_ROW_NEW.Tipo_Req <> 'EXTERNA' then
             P_MENS := 'Para REQUISICAO EXTERNA � obrigat�rio informar o Tipo de Requisi��o como EXTERNA.';
             return(true);
           end if;
         end if;

         if P_ROW_NEW.Tipovinc = 'REQUISICAO INTERNA' then
           if P_ROW_NEW.Tipo_Req <> 'INTERNA' then
             P_MENS := 'Para REQUISICAO INTERNA � obrigat�rio informar o Tipo de Requisi��o como INTERNA.';
             return(true);
           end if;

           -- verifica se o org�o selecionado est� no SigRH --
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
               P_MENS := 'Erro n�o esperado GRJ_EPB__VINCULOS (1): '||sqlerrm(sqlcode);
               RETURN(TRUE);
           end;

           if v_cont_orgao >= 1 and P_ROW_NEW.FLEX_CAMPO_08 is null then
             P_MENS := ' � obrigat�rio informar o V�nculo na Origem para servidores vindos do �rg�o '||P_ROW_NEW.FLEX_CAMPO_07||'.';
             return(true);
           end if;
         end if;
  --bernardo 01/07/2015 In�cio
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
          P_MENS := 'Para '||P_ROW_NEW.Tipovinc||' � obrigat�rio preencher a Origem na aba Requisi��o/Contrato.';
          return(true);
        end if;

        if P_ROW_NEW.Flex_Campo_07 is null then
          P_MENS := 'Para '||P_ROW_NEW.Tipovinc||' � obrigat�rio preencher a Origem na aba Requisi��o/Contrato.';
          return(true);
        end if;

        if P_ROW_NEW.Funcao_Req is null then
          P_MENS := 'Para '||P_ROW_NEW.Tipovinc||' � obrigat�rio preencher a Origem na aba Requisi��o/Contrato.';
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
           P_MENS := ' O Bloco Requisi��o n�o deve ser preenchido no caso de '||P_ROW_NEW.Tipovinc||'.';
           return(true);
         end if;
       end if;
        -- Ismael Lauro em 19/05/2016 SGD 2791
        -- Inclu�do o tipo de v�nculo PREST TAREFA T CERTO para passar a regra das datas preenchidas
       if P_ROW_NEW.Tipovinc not in ('CONTR TEMPORARIO','PREST TAREFA T CERTO') then
         if P_ROW_NEW.Dtinicontr     is not null
         or P_ROW_NEW.Dtfimcontr     is not null
         or P_ROW_NEW.Dtprorrogcontr is not null
         then
           P_MENS := ' O Bloco Contrato por Tempo Determinado n�o deve ser preenchido no caso de '||P_ROW_NEW.Tipovinc||'.';
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


     if v_nome_transacao = 'V�nculo' or v_nome_transacao = 'Ingresso' then

       if p_row_new.regimejur = 'ESTATUTO CIVIL' and p_row_new.tipovinc = 'CONCURSO PUBLICO' then

         --P_MENS := 'Linha 341 FLEX_CAMPO_41 :'||P_ROW_NEW.FLEX_CAMPO_41||' FLEX_CAMPO_44 :'||P_ROW_NEW.FLEX_CAMPO_44
         --            ||' dtexerc :'||p_row_new.dtexerc;

         if p_row_new.dtexerc >= to_date('04/09/2013','dd/mm/yyyy') then

           --P_MENS := 'Linha 345 FLEX_CAMPO_41 :'||P_ROW_NEW.FLEX_CAMPO_41||' FLEX_CAMPO_44 :'||P_ROW_NEW.FLEX_CAMPO_44;


           if p_row_new.flex_campo_02 is null then
             p_mens := '� obrigat�rio informar se o funcion�rio teve v�nculo estatut�rio anterior!';
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
               p_mens := '� necess�rio informar se teve ou n�o Previd�ncia Complementar no V�nculo Ininterr�pto.';
               RETURN (TRUE);
             end if;

             if p_row_new.flex_campo_43 is null then
               p_mens := '� necess�rio informar o Tipo de �rg�o do V�nculo Ininterr�pto.';
               RETURN (TRUE);
             end if;

             if p_row_new.flex_campo_40 is null then
               p_mens := '� necess�rio informar �rg�o do V�nculo Ininterr�pto.';
               RETURN (TRUE);
             end if;

             if p_row_new.flex_campo_41 is null then
               p_mens := '� necess�rio informar a Data de Posse do V�nculo Ininterr�pto.';
               RETURN (TRUE);
             end if;


             if P_ROW_NEW.flex_campo_43 in ('ADMINISTRACAO DIRETA','FUNDACAO','AUTARQUIA','EMPRESA','COMPANHIA')
                AND p_row_new.flex_campo_44 is null then
                    p_mens := 'O N�mero do V�nculo Ininterr�pto deve ser informado.';
                    RETURN (TRUE);
             end if;

             -- Verificando se o campo Tipo de Org�o(flex_43) corresponde ao campo Org�o Anterior(flex_40)
             -- Altera��o realizada para atender a demanda acrescentada ao SGD 875 no dia 21/01/2014
             -- Reinaldo Mesquita - 21/01/2014 (SGD 875)
             
             -- Alterado por Giselle da Silva em 22/02/2016  SGD 2635  
             -- Fazer a verifica��o do �rg�o anterior separadamente para ADMINSTRA��O DIRETA e FUNDA��O/AUTARQUIA           
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
                   P_MENS := 'Erro n�o esperado GRJ_EPB__VINCULOS (6): '||sqlerrm(sqlcode);
                   RETURN(TRUE);
               end;

               if v_cont_orgao_ant = 0 or v_cont_orgao_ant is null then
                 p_mens := 'O Campo Org�o Anterior n�o est� de acordo com o Tipo de Org�o selecionado - 20.';
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
                     P_MENS := 'Erro n�o esperado GRJ_EPB__VINCULOS (7): '||sqlerrm(sqlcode);
                     RETURN(TRUE);
                 end;

                 if v_cont_orgao_ant = 0 or v_cont_orgao_ant is null then
                   p_mens := 'O Campo Org�o Anterior n�o est� de acordo com o Tipo de Org�o selecionado - 30.';
                   RETURN (TRUE);
                 end if;        
           end if; -- Fim da valida��o do campo do v�nculo estatut�rio anterior
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
                 p_mens := 'O Campo Org�o Anterior n�o est� de acordo com o Tipo de Org�o selecionado.';
                 return (true);
               WHEN OTHERS THEN
                 P_MENS := 'Erro n�o esperado GRJ_EPB__VINCULOS (6): '||sqlerrm(sqlcode);
                 RETURN(TRUE);
             end;

             if v_cont_orgao_ant = 0 or v_cont_orgao_ant is null then
               p_mens := 'O Campo Org�o Anterior n�o est� de acordo com o Tipo de Org�o selecionado.';
               RETURN (TRUE);
             end if;*/

           end if;

           else

           --Controle de se possui atributo ou n�o
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
                     P_MENS := 'Os atributos de Previd�ncia Complementar devem ser fechados para que o plano possa ser alterado';
                     RETURN(TRUE);
                   end if;

            --setar regra antiga de plano previdenciario no flex_16--
                         BEGIN
              select DECODE (planoprev_padrao, 'RPPS', 'RIOPREV FINANC', planoprev_padrao)
                into p_row_new.flex_campo_16
                from erg_tipovinc_valid t,
                -- Inclu�do por Giselle da Silva em 20/06/2016 / SGD 2840
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
                P_MENS := 'Erro n�o esperado GRJ_EPB__VINCULOS (2): '||sqlerrm(sqlcode);
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
          --P_MENS := 'Entrou na parte de JUD EST e �rg�o RJ 2';
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
                P_MENS := 'Erro n�o esperado GRJ_EPB__VINCULOS (2): '||sqlerrm(sqlcode);
                RETURN(TRUE);
            END;


           --P_MENS := 'Linha 505 FLEX_CAMPO_41 :'||P_ROW_NEW.FLEX_CAMPO_41||' FLEX_CAMPO_44 :'||P_ROW_NEW.FLEX_CAMPO_44;

           /* --Comentado SGD-875 Bernardo C�mera
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


     -- Permitir que seja atribuida uma vac�ncia, mesmo que o tipo de pagamento seja ESPEC, SEMCC ou a conta corrente incorreta
     -- mas impedir remover a vac�ncia sem antes acertar tipo de pagamento e a conta-corrente.
     -- Reinaldo Mesquita - 14/08/2013 (SGD 955)
     if v_nome_transacao IN ('Vac�ncia','Instituidor de Pens�o') then

       if p_row_new.dtvac is null then -- quando remove uma vac�ncia:

         if p_row_new.TIPOPAG = 'ESPEC' then
           -- Impede atualiza��o de tipo de pagamento em esp�cie na tela de cadstro de v�nculo
           -- Tarefa no Attask - CRIAR TIPO PAG "CONTA SAL�RIO"
           -- Rodrigo Machado - 24/08/2012
           p_mens := 'N�o � mais poss�vel atualizar registros como Esp�cie! 002';
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
             p_mens := 'Funcionario n�o possui conta corrente v�lida ou representante legal com conta corrente v�lida.';
             RETURN (TRUE);
           END IF;

         END IF;
         */
       end if;

    else

      --Libera para quando o servidor tiver a libera��o para pagar em ESPEC
       if NVL(p_row_new.flex_campo_13,'NAO') <> 'SIM' then

         if p_row_new.TIPOPAG = 'ESPEC' then
           -- Impede atualiza��o de tipo de pagamento em esp�cie na tela de cadstro de v�nculo
           -- Tarefa no Attask - CRIAR TIPO PAG "CONTA SAL�RIO"
           -- Rodrigo Machado - 24/08/2012
           p_mens := 'N�o � mais poss�vel atualizar registros como Esp�cie 10012!';
           RETURN (TRUE);
         end if;

       end if;

         -- Valida��o do d�gito da conta corrente do banco Itau
         -- Dagoberto 09/05/2011
         --Modificado por Rodrigo Machado em 06/07/2015, coloquei o NVL abaixo,
         --pois sem ele n�o estava entrando na valida��o. SGD 2130
         IF p_row_new.banco IS NOT NULL AND NVL(p_row_new.formavac,'XXXXX') <> 'FALECIMENTO' THEN
            --TGRJ_VALIDA_CC (p_row_new.banco,p_row_new.agencia, p_row_new.conta, p_row_new.tipopag);

            IF P_ROW_NEW.Conta is null and P_ROW_NEW.FLEX_CAMPO_20 IS NULL and P_ROW_NEW.Tipopag IN ('CONTA','POUPA') then
              p_mens := 'Tipo de conta for CONTA ou POUPA, � obrigat�rio o preenchimento do campo Conta ou Conta Sal�rio.' ;
            ELSE
               IF P_ROW_NEW.Conta is NOT null THEN
                  TGRJ_VALIDA_CC (p_row_new.banco,p_row_new.agencia,P_ROW_NEW.Conta, p_row_new.tipopag);
             --     RETURN (TRUE); linha comentada de acordo com solicita��o do SGD 2151 05/08/2015
               END IF;
               IF P_ROW_NEW.FLEX_CAMPO_20 IS NOT NULL THEN
                 TGRJ_VALIDA_CC (p_row_new.banco,p_row_new.flex_campo_19,P_ROW_NEW.FLEX_CAMPO_20, p_row_new.tipopag);
               END IF;
            END IF;

         END IF;
    end if;

    -- Hor�cio - 31/03/2011 - Transferi para o EPB em 08/04/2011 pois no EPA n�o estava atualizando a dt_pgto_ate
    -- verificar se esta havendo atualiza��o na data de vacancia
    -- Inclui separado pois haviam varios vinculos sem data de pagamento at�
    -- A id�ia � que isto n�o ocorra mais.
    IF (p_row_new.dtvac IS NOT NULL AND p_row_old.dtvac IS NULL) OR (p_row_new.dtvac IS NOT NULL AND p_row_old.dtvac IS NOT NULL AND p_row_new.dtvac <> p_row_old.dtvac) THEN
      -- Seta a data de pagamento at� dois meses depois da vac�ncia para o servidor
      p_row_new.dt_pgto_ate := last_day(add_months(sysdate,2));
    END IF;
    --
    -- Hor�cio em 17/10/2011 - Incluir teste para verificar se est� sendo informada aposentadoria e o servidor
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
          P_MENS := 'Erro n�o espedado GRJ_EPB__VINCULOS (9): '||sqlerrm(sqlcode);
          RETURN(TRUE);
        END;
        IF v_flex_campo_02     IS NOT NULL THEN
          --p_row_new.matricula1 := v_flex_campo_02; --SGD-1678
          p_row_new.matricula1 := UPPER(v_flex_campo_02); --SGD-1678
        END IF;
      END IF;

      --SGD-1678 Bernardo 01/10/2014 In�cio
      IF p_row_new.matricula1 IS NOT NULL THEN
         V_MATRICULA1_AUX := p_row_new.matricula1;
         p_row_new.matricula1 := UPPER(V_MATRICULA1_AUX);
      END IF;
      --SGD-1678 Bernardo 01/10/2014 Fim

      -- Valida��o do PISPASEP
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
        P_MENS := 'Erro n�o espedado GRJ_EPB__VINCULOS (10): '||sqlerrm(sqlcode);
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
          P_MENS := 'Erro n�o espedado GRJ_EPB__VINCULOS (11): '||sqlerrm(sqlcode);
          RETURN(TRUE);
      END;

      IF V_PRIVILEG_LIVRE = 'N' THEN
        IF V_NAO_TEMP_PASEP = 1 AND PACK_HADES.GET_OPCAO('C_Ergon','GOVRJ','PIS_EXIGE') = 'S'
            and  NOT (P_ROW_NEW.DTAPOSENT IS NOT NULL OR
                      P_ROW_NEW.DTVAC IS NOT NULL OR
                      P_ROW_NEW.REGIMEJUR IN ('LEIS DE PENSAO','LEIS PENSAO ESPECIAL','PENSAO ESPECIAL')
                      )
        THEN
          p_mens           := 'O PIS/PASEP do servidor � obrigat�rio.' ||' Cadastre primeiro o PISPASEP na tela de Funcion�rios para ' ||'depois incluir o Vinculo.';
        END IF;
      END IF;

      --
      -- Ricardo Nunes em 21/09/2012 - Todo Vinculo dever� ter a informa��o do Banco Padrao,
      -- mesmo que o TIPOPAG = SEMCC ou ESPEC.
      --
      IF p_row_new.banco IS NULL THEN
         p_row_new.banco := pack_hades.get_opcao('C_Ergon', 'GOVRJ', 'BANCO_PADRAO');
      END IF;
      --
      --Modifica��o solicitada de acordo com o SGD 1499
      --Permitir cadastramento do vinculo PREST TAREFA T CERTO somente para servidor que tenham
      --outro v�nculo de CONCURSO PUBLICO ou EFETIVO e que esteja inativado.

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
            p_mens := 'Tipo de v�nculo PREST TAREFA T CERTO s� pode ser criado ou atualizado se '||
                     'servidor possuir outro v�nculo Regime Jur�dico ESTATUTO MILITAR e Situa��o Inativo.';
         END IF;

      END IF;*/


    END IF;
    --
    -- Gera a matricula para o SAPE
    -- Dagoberto 27/01/2011
    --
    IF (p_inserting) and p_row_new.matricula is null then--Alteracao conforme pedido de Horacio para acertar a grava��o da matricula.25/03/2013.
      p_row_new.matricula := tgrj_calc_digito_mod10 (pack_hades.get_numero ('SAPE', 0));
      p_row_new.matricula := pack_hades.formata_mascara(p_row_new.matricula,'00-0000000-0');
    END IF;
    --
    --
    -- Este procedimento foi adicionado para evitar matr�cula nula vinda do ingresso.
    -- Isto ocorria quando o servidor j� tinha v�nculo cadastrado mas n�o tinha evento
    -- ainda. O campo matricula que vinha do form vinha nulo e sobrescrevia a tabela.
    --
    IF (p_updating) AND p_row_new.matricula IS NULL THEN
      p_row_new.matricula                   := p_row_old.matricula;
    END IF;
    --
    IF (p_row_new.dtexerc > SYSDATE) OR (p_row_new.dtnom > SYSDATE) OR (p_row_new.dtposse > SYSDATE) THEN
      p_mens             := 'N�o s�o permitidos lan�amentos futuros.';
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

        P_MENS := 'Para esta Categoria do V�nculo � Necess�rio informar a Atividade/Especialidade.';

     END IF;



    END IF;


    --Inserido por Rodrigo Machado em 13/05/2016 para atender o SGD 2721 conforme regra
    -- N�o permitir per�odo entre a data in�cio e fim superior a 2 anos e a data in�cio e prorroga��o superior a 3 anos.
    IF P_INSERTING or P_UPDATING AND P_ROW_NEW.TIPOVINC = 'CONTR TEMPORARIO' THEN

      SELECT COUNT(1)
       INTO V_COUNT
       FROM VINCULOS VI
      WHERE VI.NUMFUNC = P_ROW_NEW.NUMFUNC
        AND VI.TIPOVINC = 'CONTR TEMPORARIO'
        AND nvl(VI.DTFIMCONTR,pack_hades.DATA_MAXIMA) >= P_ROW_NEW.DTINICONTR
        AND VI.NUMERO <> P_ROW_NEW.NUMERO;

      IF V_COUNT > 0 THEN

        P_MENS := 'J� existe pelo menos um CONTRATO TEMPORARIO em aberto no per�odo, n�o � permitido ter dois CONTRATOS TEMPORARIOS acumul�veis.';
        RETURN (TRUE);

      END IF;

      IF P_ROW_NEW.DTEXERC <> NVL(P_ROW_NEW.DTINICONTR,pack_hades.DATA_MAXIMA) THEN

        P_MENS := 'Data de In�cio do contrato n�o pode ser diferente da data de exerc�cio.';
        RETURN (TRUE);

      END IF;


      DECLARE
        V_TEMPO NUMBER;
        V_TEMPO_MAXIMO NUMBER;
      BEGIN

        V_TEMPO := NVL(P_ROW_NEW.DTFIMCONTR,pack_hades.DATA_MAXIMA) -  NVL(P_ROW_NEW.DTINICONTR,pack_hades.DATA_MAXIMA);
        V_TEMPO_MAXIMO := add_months(NVL(P_ROW_NEW.DTINICONTR,pack_hades.DATA_MAXIMA),24) - NVL(P_ROW_NEW.DTINICONTR,pack_hades.DATA_MAXIMA);

        IF V_TEMPO > V_TEMPO_MAXIMO THEN
          P_MENS := 'Per�odo de contrata��o n�o pode ser superior a 2 anos.';
          RETURN (TRUE);
        END IF;


        V_TEMPO := NVL(P_ROW_NEW.DTPRORROGCONTR,pack_hades.DATA_MAXIMA) -  NVL(P_ROW_NEW.DTINICONTR,pack_hades.DATA_MAXIMA);
        V_TEMPO_MAXIMO := add_months(NVL(P_ROW_NEW.DTINICONTR,pack_hades.DATA_MAXIMA),36) - NVL(P_ROW_NEW.DTINICONTR,pack_hades.DATA_MAXIMA);

         IF V_TEMPO > V_TEMPO_MAXIMO THEN
          P_MENS := 'Per�odo de  prorroga��o n�o pode ser supeiror a 3 anos da data in�cio do contrato.';
          RETURN (TRUE);
        END IF;

       END;

    END IF;

--    IF P_INSERTING or P_UPDATING THEN
      /* Fernando Garatini da Silva
         A verifica��o abaixo foi desenvolvida com o intuito de n�o permitir cadastrar um novo vinculo
         para o funcionario que estiver com uma GLP em aberto e com uma carga hor�ria maior do que 12 horas
      */

      /*and ( c.dtvac is null or c.dtvac >= P_DATA)
      and ( c.dtfimcontr is null or c.dtfimcontr >= p_data)
      and ( c.dtaposent is null or c.dtaposent >= p_data)*/
/*
Hor�cio:

      SELECT SUM(NVL(HORASSEM,0))HORASSEM
         INTO V_JORNADA
         FROM EXERCICIOS
        WHERE ATIVIDADE = 100
          AND DTINI <= NVL(NVL(NVL(P_ROW_NEW.DTAPOSENT,P_ROW_NEW.DTVAC), P_ROW_NEW.DTFIMCONTR),pack_ergon.data_maxima)
          AND NVL(dtfim, pack_ergon.data_maxima) >= P_ROW_NEW.DTEXERC
          AND NUMFUNC = p_row_new.Numfunc
          and numvinc = p_row_new.numero;

      IF V_JORNADA > 12 THEN
         p_mens := 'Funcion�rio possui GLP maior que 12 horas.';
      END IF;
*/
--    END IF;
     /* Fim Verifica��o Fernando Garatini da Silva */
     /*
     IF PACK_HADES.GET_OPCAO('Ergon', 'ERGON', 'VAC_AUT') = 'N' THEN
        update had_opcoes_itens
                 set valor = 'S'
               where sis   = 'Ergon'
                 and grupo = 'ERGON'
                 and opcao = 'VAC_AUT' ;
    END IF;
    */
    
    --Inclu�do por Rodrigo Machado em 10/10/2016 
    --conforme solicita��o do SGD 3045
    IF v_nome_transacao = 'Requisi��o' THEN
      
      IF P_ROW_NEW.TIPO_ONUS_REQ = 'Com Onus' THEN
      
         IF P_ROW_NEW.FLEX_CAMPO_23 IS NULL OR P_ROW_NEW.FLEX_CAMPO_23 <= 0 THEN
         
            P_MENS := 'Quando tipo de �nus for Com Onus, o Valor do Ressarcimento � obrigat�rio.';  
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

           p_mens := 'Erro n�o esperado GRJ_EPB__VINCULOS (0): '||sqlerrm(sqlcode);
           return (true) ;
  END;
/	